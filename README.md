# MiniMax H3: Vast.ai provisioning

Personal copy of [ComfyUI-Garage's provisioning script](https://github.com/huchukato/ComfyUI-Garage/blob/master/vastai/mmh3-provisioning.sh). The Vast.ai template points to `mmh3-provisioning-custom.sh` in this repository. Changes upstream are not merged automatically.

## Model selection

The startup script installs `MiniMaxH3-PikaFlex085-R2VA-8step-beta57.json` into ComfyUI's workflow folder. This public copy retains the user's model and sampling settings, with private prompt, reference filenames and preview data removed. Select references and enter a prompt before use. The workflow needs the PikaFlex model (`MINIMAX_MODEL=both` or `pikaflex`); choosing `prism` does not download it.

Set `MINIMAX_MODEL` as a Vast.ai template environment variable before creating an instance:

| Value | Diffusion models downloaded |
| --- | --- |
| `both` (default) | PRISM DMAD PDMD and PRISM2 PikaFlex 0.85 |
| `prism` | PRISM DMAD PDMD only |
| `pikaflex` | PRISM2 PikaFlex 0.85 only |

Common components, such as the MiniMax H3 video/audio VAE, Qwen3-VL text encoder, Qwen3.5 prompt enhancer and associated nodes, are retained. An existing workflow may need its model loader adjusted to match the downloaded filename. Turbo beta7, Singularity ref2va v2, and Hybrid DMAD PDMD were removed from the original download list.

For `prism` and `both`, the script also downloads `Minimax_H3_Unlocked_V3.safetensors` (Civitai model version 3446226) into `models/loras` and verifies its SHA-256. Set `CIVITAI_TOKEN` in the private Vast.ai template; never put its value into this public repository. The token is accessible to the template and instance environment, so it should be read-only and treated as exposed to code running there. The `pikaflex` mode does not download the LoRA. An existing file with a different hash is left untouched and causes a provisioning failure.

## Downloads

RES4LYF is installed as a custom node; it registers the `beta57` scheduler (alpha 0.5, beta 0.7) and additional samplers. ComfyUI must restart after installation before the scheduler appears in standard scheduler selectors. The existing standalone `BetaSamplingScheduler` configuration with the same alpha and beta already provides the equivalent schedule without RES4LYF.

`MODEL_DOWNLOAD_WORKERS` sets the maximum number of simultaneous model downloads; allowed values are 1–4 and the default is 2. Parallel downloads can compete for network or disk resources. Each file has up to three attempts. Existing files meeting the configured minimum byte size are reused; newly downloaded files are checked against the same minimum size. These size checks do not establish file integrity; use checksums where needed.

If a selected model fails all attempts, the script returns a failure so the provisioner can report/retry it. Application behavior after a failed provisioning run depends on the Vast.ai image and provisioner settings; check logs instead of assuming readiness. Model selection only changes model downloads in future provisioning runs; it does not remove files or change existing workflows.

## Maintenance

The template uses `vastai/comfy:@vastai-automatic-tag`: Vast.ai selects an image for the host, but this does not guarantee the newest release or CUDA 13.2. The provisioning script currently installs CUDA 13 TensorRT packages and an x86_64 llama-cpp-python wheel; validate compatibility when changing GPU, CPU architecture, or image. First boot and a representative generation should be tested after updates.
