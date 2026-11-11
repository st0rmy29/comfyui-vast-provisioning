#!/usr/bin/env python3
"""Download Noct Q assets to an existing ComfyUI without exposing credentials."""
import concurrent.futures
import hashlib
import os
from pathlib import Path
import time
import urllib.error
import urllib.parse
import urllib.request

ROOT = Path(os.environ.get('WORKSPACE', '/workspace')) / 'ComfyUI/models'

class SafeRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        redirected = super().redirect_request(req, fp, code, msg, headers, newurl)
        if redirected:
            old = urllib.parse.urlsplit(req.full_url)
            new = urllib.parse.urlsplit(newurl)
            if (old.scheme, old.hostname, old.port) != (new.scheme, new.hostname, new.port):
                redirected.remove_header('Authorization')
        return redirected

OPENER = urllib.request.build_opener(SafeRedirect())
FILES = [
    ('diffusion_models/NoctQ_V4_bf16.safetensors', 'https://civitai.com/api/download/models/3372040?fileId=3260162', 14230280896, '0e4b9285fe54571660d0b5d2559ade4bec9a350ce633ad2d31192f88f9d5e0d3', True),
    ('text_encoders/qwen3vl_8b_bf16.safetensors', 'https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/text_encoders/qwen3vl_8b_bf16.safetensors', 17534334616, '68bdc82bc1b66851162ae656225e7e2068166b603db19bd5d5a3b90eb12669a9', False),
    ('text_encoders/qwen3vl_8b_int8_convrot.safetensors', 'https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/text_encoders/qwen3vl_8b_int8_convrot.safetensors', 9350798360, '8bfd0f6e12abf2d2d697ecc888e5e90b0d6741d6708f05799f53afa560452e8f', False),
    ('vae/qwen_image_2.1_vae_bf16.safetensors', 'https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/vae/qwen_image_2.1_vae_bf16.safetensors', 675509688, 'bb21f7473051e1ac368515dd3f2e15cd44d7a11748ee8823e1ddca3e4876b7c9', False),
    ('loras/bfs_head_v1.1_qwen_2.1.safetensors', 'https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/resolve/main/bfs_head_v1.1_qwen_2.1.safetensors', 260096144, 'd1d748d5601077f3b6d05766f6823510e901970d916afa404a97e85dc92fa88e', False),
    ('loras/bfs_body_swap_v1.0_qwen_2.1.safetensors', 'https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/resolve/main/bfs_body_swap_v1.0_qwen_2.1.safetensors', 209753576, '7dc0a53aba4dbc70c204f498936a619d226559da11011f748c389189af46b664', False),
]

def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(4 * 1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()

def download(item):
    relative, url, size, expected, authenticated = item
    path = ROOT / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        if path.stat().st_size == size and digest(path) == expected:
            print('VERIFIED existing', relative, flush=True)
            return True
        print('ERROR existing file has wrong size or hash:', relative, flush=True)
        return False
    partial = path.with_name('.' + path.name + '.noct-part')
    headers = {'User-Agent': 'NoctQ-Photo-Setup/1.0'}
    if authenticated:
        token = os.environ.get('CIVITAI_TOKEN', '')
        if not token:
            print('ERROR missing CIVITAI_TOKEN for', relative, flush=True)
            return False
        headers['Authorization'] = 'Bearer ' + token
    for attempt in range(1, 5):
        try:
            start = partial.stat().st_size if partial.exists() else 0
            request_headers = dict(headers)
            if start:
                request_headers['Range'] = 'bytes=%d-' % start
            request = urllib.request.Request(url, headers=request_headers)
            with OPENER.open(request, timeout=120) as response:
                append = start > 0 and response.status == 206 and response.headers.get('Content-Range', '').startswith('bytes %d-' % start)
                if not append:
                    start = 0
                with partial.open('ab' if append else 'wb') as stream:
                    while True:
                        block = response.read(4 * 1024 * 1024)
                        if not block:
                            break
                        stream.write(block)
            got = partial.stat().st_size
            if got != size:
                print('RETRY size', relative, got, 'expected', size, flush=True)
                time.sleep(3 * attempt)
                continue
            print('HASHING', relative, flush=True)
            if digest(partial) != expected:
                print('ERROR checksum mismatch:', relative, flush=True)
                return False
            os.replace(partial, path)
            print('VERIFIED downloaded', relative, flush=True)
            return True
        except (OSError, urllib.error.URLError) as exc:
            print('RETRY', relative, 'attempt', attempt, 'error', type(exc).__name__, flush=True)
            time.sleep(3 * attempt)
    print('ERROR download incomplete:', relative, flush=True)
    return False

if __name__ == '__main__':
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
        results = list(pool.map(download, FILES))
    print('RESULT', 'OK' if all(results) else 'FAILED', flush=True)
    raise SystemExit(0 if all(results) else 1)
