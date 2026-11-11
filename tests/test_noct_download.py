import hashlib
import importlib.util
import os
from pathlib import Path
import tempfile
import threading
import unittest
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from unittest import mock


spec = importlib.util.spec_from_file_location('noct_download', Path(__file__).parents[1] / 'scripts' / 'noct_download.py')
download_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(download_module)
PAYLOAD = b'confirmed model bytes' * 100
SHA = hashlib.sha256(PAYLOAD).hexdigest()


class Handler(BaseHTTPRequestHandler):
    observed_auth = []

    def log_message(self, *_args):
        pass

    def do_GET(self):
        Handler.observed_auth.append((self.path, self.headers.get('Authorization')))
        if self.path == '/redirect':
            self.send_response(302)
            self.send_header('Location', 'http://localhost:%d/model' % self.server.server_port)
            self.end_headers()
            return
        pos = int(self.headers.get('Range', 'bytes=0-')[6:-1])
        self.send_response(206 if pos else 200)
        if pos:
            self.send_header('Content-Range', 'bytes %d-%d/%d' % (pos, len(PAYLOAD) - 1, len(PAYLOAD)))
        self.send_header('Content-Length', str(len(PAYLOAD) - pos))
        self.end_headers()
        self.wfile.write(PAYLOAD[pos:])


class DownloadTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = ThreadingHTTPServer(('127.0.0.1', 0), Handler)
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join()

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.root_patch = mock.patch.object(download_module, 'ROOT', self.root)
        self.root_patch.start()
        self.addCleanup(self.root_patch.stop)
        Handler.observed_auth.clear()
        self.url = 'http://127.0.0.1:%d' % self.server.server_port

    def item(self, url='/model', sha=SHA, auth=False):
        return ('diffusion_models/test.safetensors', self.url + url, len(PAYLOAD), sha, auth)

    def test_resume_and_verify_checksum(self):
        folder = self.root / 'diffusion_models'
        folder.mkdir()
        (folder / '.test.safetensors.noct-part').write_bytes(PAYLOAD[:300])
        self.assertTrue(download_module.download(self.item()))
        self.assertEqual((folder / 'test.safetensors').read_bytes(), PAYLOAD)

    def test_mismatch_does_not_replace_existing_file(self):
        folder = self.root / 'diffusion_models'
        folder.mkdir()
        target = folder / 'test.safetensors'
        target.write_bytes(b'keep this')
        self.assertFalse(download_module.download(self.item()))
        self.assertEqual(target.read_bytes(), b'keep this')

    def test_bad_checksum_is_not_published(self):
        self.assertFalse(download_module.download(self.item(sha='0' * 64)))
        self.assertFalse((self.root / 'diffusion_models/test.safetensors').exists())

    def test_token_is_not_forwarded_to_another_host(self):
        with mock.patch.dict(os.environ, {'CIVITAI_TOKEN': 'test-token'}):
            self.assertTrue(download_module.download(self.item('/redirect', auth=True)))
        self.assertEqual(Handler.observed_auth[0], ('/redirect', 'Bearer test-token'))
        self.assertEqual(Handler.observed_auth[1], ('/model', None))


if __name__ == '__main__':
    unittest.main()
