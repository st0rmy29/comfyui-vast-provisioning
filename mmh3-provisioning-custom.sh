#!/bin/bash

source /venv/main/bin/activate
COMFYUI_DIR=${WORKSPACE}/ComfyUI

APT_PACKAGES=(
    "aria2"
)

PIP_PACKAGES=(
    "--upgrade --force-reinstall --no-cache-dir https://github.com/JamePeng/llama-cpp-python/releases/download/v0.4.3-cu131-linux-20261017/llama_cpp_python-0.4.3+cu131-cp312-cp312-linux_x86_64.whl"
    "huggingface_hub"
    "comfyui-manager"
    "tensorrt-cu13==10.15.1.29"
    "tensorrt-cu13-bindings==10.15.1.29"
    "tensorrt-cu13-libs==10.15.1.29"
)

NODES=(
    "https://github.com/ClownsharkBatwing/RES4LYF"
    "https://github.com/huchukato/ComfyUI-TagForge"
    "https://github.com/huchukato/ComfyUI-QwenVL-Mod"
    "https://github.com/huchukato/ComfyUI-CharSheet"
    "https://github.com/huchukato/ComfyUI-RIFE-TensorRT-Auto"
    "https://github.com/huchukato/ComfyUI-Upscaler-TensorRT-Auto"
    "https://github.com/huchukato/ComfyUI-HuggingFace"
    "https://github.com/Koishi-Star/Euler-Smea-Dyn-Sampler"
    "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/yolain/ComfyUI-Easy-Use"
    "https://github.com/MoonGoblinDev/Civicomfy"
    "https://github.com/pixaroma/ComfyUI-Pixaroma"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
    "https://github.com/ltdrdata/ComfyUI-Impact-Subpack"
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/huchukato/ComfyUI-PerfectVideoResolution"
    "https://github.com/huchukato/ComfyUI-MiniMaxH3-Director-Enhanced"
    "https://github.com/huchukato/ComfyUI-Gallery"
)

WORKFLOWS=(
    "https://raw.githubusercontent.com/st0rmy29/comfyui-vast-provisioning/main/workflows/MiniMaxH3-PikaFlex085-R2VA-beta57-Qwen38-27B-Fable709-INT8.json"
)

CHECKPOINT_MODELS=(
)

UNET_MODELS=(
)

LORA_MODELS=(
)

VAE_MODELS=(
)

ESRGAN_MODELS=(

)

TEXT_ENCODERS=(
)

CONTROLNET_MODELS=(
)

# Large MiniMax H3 models downloaded via hf/huggingface-cli (format: subdir|name|url|min_size_bytes)
MINIMAX_MODELS=(
    "vae|minimax_h3_video_vae_fp16.safetensors|https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_video_vae_fp16.safetensors|5200000000"
    "vae|minimax_h3_audio_vae_fp32.safetensors|https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_audio_vae_fp32.safetensors|600000000"
    # ── Tiny H3 VAE for fast previews (Kijai TAE) → models/vae_approx ──
    "vae_approx|taeh3.safetensors|https://huggingface.co/Kijai/MiniMax-H3-TAE/resolve/main/vae_approx/taeh3.safetensors|9000000"
    # ── Optional PRISM DMAD and selected PikaFlex diffusion models ──
    "diffusion_models|PRISM_DMAD_PDMD_int8.safetensors|https://huggingface.co/OliviaRossi/Minimax-h3_Singularity-x-10Eros-Max_PRISM/resolve/main/PRISM_DMAD_PDMD_int8.safetensors|20000000000"
    "diffusion_models|10Eros_Max_SingularityV2_PRISM2_PikaFlex_0.85_int8HQ.safetensors|https://huggingface.co/OliviaRossi/Minimax-h3_Singularity-x-10Eros-Max_PRISM/resolve/main/10Eros_Max_SingularityV2_PRISM2_PikaFlex_0.85_int8HQ.safetensors|20197393008"
    # ── Full H3 conditioning TE: Ultra Heretic INT8 ConvRot (uncensored, ethanfel) ──
    "text_encoders|qwen3vl_32b_h3_ultra_uncensored_heretic_int8_convrot.safetensors|https://huggingface.co/ethanfel/Qwen3-VL-32B-Ultra-Heretic-H3-ComfyUI-INT8-ConvRot/resolve/main/qwen3vl_32b_h3_ultra_uncensored_heretic_int8_convrot.safetensors|26363476151"
    # ── lightx2v Turbo LoRA 8-step 768p (Apache-2.0, trained at 1344×768) — no custom node needed ──
    # ── fal Realism People LoRA (trigger: r34l1sm) ──
    # ── akatz Character-Swap LoRA — ref2v character swap ──
    # ── TenStrip combined turbo LoRA (4.4GB) — the exact delta fused into the TURBO checkpoint; use with 10Eros non-turbo ──
    # ── Qwen 3.8 Fable 709 Q6_K and its matching vision projector ──
    "LLM/GGUF/DavidAU/Qwen3.8-27B-TWIN-TURBO-Fable-Cold-Fusion-709-ULTRA-HERETIC-Uncensored-NM-DAU-NEO-MTP-GGUF|Qwen3.8-27B-TTURBO-Fable-C-Fusion-709-U-Httic-Uncen-NM-DAU-NEO-MAX-Q6_K.gguf|https://huggingface.co/DavidAU/Qwen3.8-27B-TWIN-TURBO-Fable-Cold-Fusion-709-ULTRA-HERETIC-Uncensored-NM-DAU-NEO-MTP-GGUF/resolve/main/Qwen3.8-27B-TTURBO-Fable-C-Fusion-709-U-Httic-Uncen-NM-DAU-NEO-MAX-Q6_K.gguf|23582390976"
    "LLM/GGUF/DavidAU/Qwen3.8-27B-TWIN-TURBO-Fable-Cold-Fusion-709-ULTRA-HERETIC-Uncensored-NM-DAU-NEO-MTP-GGUF|mmproj-BF16.gguf|https://huggingface.co/DavidAU/Qwen3.8-27B-TWIN-TURBO-Fable-Cold-Fusion-709-ULTRA-HERETIC-Uncensored-NM-DAU-NEO-MTP-GGUF/resolve/main/mmproj-BF16.gguf|931145952"
    # ── Prebuilt TensorRT engines (RTX PRO 6000, TRT 10.15.1.29) — skips ~1min compile at first use ──
    "tensorrt/rife|rife425_ensemble_False_scale_1_sim_fp16_large_1x3x720x720_1x3x1440x1440_1x3x1920x1920_10.15.1.29.trt|https://huggingface.co/huchukato/garage/resolve/main/tensorrt/rife/rife425_ensemble_False_scale_1_sim_fp16_large_1x3x720x720_1x3x1440x1440_1x3x1920x1920_10.15.1.29.trt|40000000"
    "tensorrt/upscaler|2xLexicaRRDBNet_fp16_1x3x256x256_2x3x512x512_2x3x2048x2048_10.15.1.29.trt|https://huggingface.co/huchukato/garage/resolve/main/tensorrt/upscaler/2xLexicaRRDBNet_fp16_1x3x256x256_2x3x512x512_2x3x2048x2048_10.15.1.29.trt|30000000"
)


YOLO_MODELS=(

)

SAM_MODELS=(

)

### DO NOT EDIT BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING ###

function provisioning_start() {
    provisioning_print_header
    echo "🚀 Starting provisioning process..."

    echo "📦 Installing APT packages..."
    provisioning_get_apt_packages

    echo "🔧 Installing custom nodes..."
    provisioning_get_nodes

    echo "📦 Installing PIP packages..."
    provisioning_get_pip_packages

    echo "📁 Downloading workflows..."
    WF_BASE="${COMFYUI_DIR}/user/default/workflows"
    for url in "${WORKFLOWS[@]}"; do
        rel="${url#*workflows/}"
        subdir=$(dirname "$rel")
        mkdir -p "$WF_BASE/$subdir"
        if ! provisioning_download "$url" "$WF_BASE/$subdir"; then
            echo "❌ Failed to download workflow: $rel"
            return 1
        fi
    done

    echo "✅ Workflows downloaded to: $WF_BASE"

    # ── Download PMP wildcards from Garage (yaml files) ──
    echo "🔄 Downloading PMP wildcards from Garage..."
    WILDCARD_DIR="${COMFYUI_DIR}/custom_nodes/ComfyUI-TagForge/wildcards"
    WILDCARD_BASE="https://github.com/huchukato/ComfyUI-Garage/raw/master/wildcards"
    WILDCARD_FILES="pmp/act.yaml pmp/actff.yaml pmp/actffm.yaml pmp/actmmf.yaml pmp/actsolo.yaml pmp/blwjob.yaml pmp/qwen21.yaml pmp/prmpt/acc.yaml pmp/prmpt/char.yaml pmp/prmpt/clths.yaml pmp/prmpt/exprss.yaml pmp/prmpt/hair.yaml pmp/prmpt/imgcmp.yaml pmp/prmpt/lctns.yaml pmp/prmpt/light.yaml pmp/prmpt/pose.yaml pmp/prmpt/styles.yaml pmp/prmpt/dynmc.yaml mmh3/camera.yaml mmh3/music.yaml mmh3/nsfw.yaml mmh3/style.yaml mmh3/vfx.yaml"
    for wf in $WILDCARD_FILES; do
        mkdir -p "$WILDCARD_DIR/$(dirname "$wf")"
        wget -q --tries=3 --timeout=30 "$WILDCARD_BASE/$wf" -O "$WILDCARD_DIR/$wf" || echo "⚠️ wildcard $wf download failed"
    done
    find "$WILDCARD_DIR/pmp" -name "*.txt" -delete 2>/dev/null
    echo "✅ PMP wildcards updated in $WILDCARD_DIR/pmp"

    echo "🎯 Downloading checkpoint models..."
    provisioning_get_files \
        "${COMFYUI_DIR}/models/checkpoints" \
        "${CHECKPOINT_MODELS[@]}"

    echo "🧠 Downloading U-NET models..."
    provisioning_get_files \
        "${COMFYUI_DIR}/models/unet" \
        "${UNET_MODELS[@]}"

    echo "🎨 Downloading LoRA models..."
    provisioning_get_files \
        "${COMFYUI_DIR}/models/loras" \
        "${LORA_MODELS[@]}"

    echo "🎮 Downloading ControlNet models..."
    provisioning_get_files \
        "${COMFYUI_DIR}/models/controlnet" \
        "${CONTROLNET_MODELS[@]}"

    echo "🔮 Downloading VAE models..."
    provisioning_get_files \
        "${COMFYUI_DIR}/models/vae" \
        "${VAE_MODELS[@]}"

    echo "⚡ Downloading upscale models..."
    provisioning_get_files \
        "${COMFYUI_DIR}/models/upscale_models" \
        "${ESRGAN_MODELS[@]}"

    echo "📝 Downloading text encoders..."
    provisioning_get_files \
        "${COMFYUI_DIR}/models/text_encoders" \
        "${TEXT_ENCODERS[@]}"

    echo "🎬 Downloading MiniMax H3 models (large files via hf)..."
    download_minimax_models || { echo "❌ Required model downloads failed; provisioning stopped."; return 1; }
    download_civitai_lora || { echo "❌ Required Civitai LoRA download failed; provisioning stopped."; return 1; }

    echo "🔍 Downloading YOLO models..."
    mkdir -p "${COMFYUI_DIR}/models/ultralytics/bbox"
    provisioning_get_files         "${COMFYUI_DIR}/models/ultralytics/bbox"         "${YOLO_MODELS[@]}"
        
    echo "🧩 Downloading SAM models..."
    mkdir -p "${COMFYUI_DIR}/models/sams"
    provisioning_get_files         "${COMFYUI_DIR}/models/sams"         "${SAM_MODELS[@]}"
        
    provisioning_print_end
}

function provisioning_get_apt_packages() {
    if [[ -n $APT_PACKAGES ]]; then
        sudo $APT_INSTALL ${APT_PACKAGES[@]}
    fi
}

function provisioning_get_pip_packages() {
    if [[ -n $PIP_PACKAGES ]]; then
        echo "Installing PIP packages..."
        for package in "${PIP_PACKAGES[@]}"; do
            echo "Installing: $package"
            pip install --root-user-action=ignore --no-cache-dir $package
            echo "✓ Completed: $package"
        done
        echo "All PIP packages installed successfully!"
    fi
}

function provisioning_get_nodes() {
    echo "Processing ${#NODES[@]} nodes..."
    local count=0
    for repo in "${NODES[@]}"; do
        ((count++))
        dir="${repo##*/}"
        path="${COMFYUI_DIR}/custom_nodes/${dir}"
        requirements="${path}/requirements.txt"

        echo "[$count/${#NODES[@]}] Processing node: $dir"

        if [[ -d $path ]]; then
            if [[ ${AUTO_UPDATE,,} != "false" ]]; then
                echo "  → Updating existing node..."
                local branch
                branch=$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
                if git -C "$path" pull --ff-only origin "$branch" 2>/dev/null; then
                    echo "  ✅ $dir updated"
                else
                    echo "  ⚠️  $dir pull failed, resetting to origin/$branch..."
                    git -C "$path" fetch origin "$branch" 2>/dev/null && \
                        git -C "$path" reset --hard "origin/$branch" 2>/dev/null || \
                        echo "  ⚠️  $dir reset failed, leaving as-is"
                fi
                if [[ -e $requirements ]]; then
                    echo "  → Installing requirements..."
                    pip install --root-user-action=ignore --no-cache-dir -r "$requirements"
                fi
            else
                echo "  → Node exists, skipping (AUTO_UPDATE=false)"
            fi
        else
            echo "  → Downloading new node..."
            git clone "${repo}" "${path}" --recursive
            if [[ -e $requirements ]]; then
                echo "  → Installing requirements..."
                pip install --root-user-action=ignore --no-cache-dir -r "${requirements}"
            fi
        fi

    done
    echo "All nodes processed successfully!"
}

function provisioning_get_files() {
    if [[ -z $2 ]]; then return 1; fi

    dir="$1"
    mkdir -p "$dir"
    shift
    arr=("$@")
    echo "Downloading ${#arr[@]} file(s) to $dir..."
    local count=0
    for url in "${arr[@]}"; do
        ((count++))
        echo "[$count/${#arr[@]}] Downloading: $(basename "$url")"
        provisioning_download "${url}" "${dir}"
        echo "  ✓ Download completed"
    done
    echo "All files downloaded successfully!"
}

function provisioning_print_header() {
    printf "\n##############################################\n#                                            #\n#          Provisioning container            #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"
}

function provisioning_print_end() {
    printf "\nProvisioning complete:  Application will start now\n\n"
}

function provisioning_has_valid_hf_token() {
    [[ -n "$HF_TOKEN" ]] || return 1
    url="https://huggingface.co/api/whoami-v2"

    response=$(curl -o /dev/null -s -w "%{http_code}" -X GET "$url" \
        -H "Authorization: Bearer $HF_TOKEN" \
        -H "Content-Type: application/json")

    if [ "$response" -eq 200 ]; then
        return 0
    else
        return 1
    fi
}

function provisioning_has_valid_civitai_token() {
    [[ -n "$CIVITAI_TOKEN" ]] || return 1
    url="https://civitai.com/api/v1/models?hidden=1&limit=1"

    response=$(curl -o /dev/null -s -w "%{http_code}" -X GET "$url" \
        -H "Authorization: Bearer $CIVITAI_TOKEN" \
        -H "Content-Type: application/json")

    if [ "$response" -eq 200 ]; then
        return 0
    else
        return 1
    fi
}

function provisioning_download() {
    if [[ -n $HF_TOKEN && $1 =~ ^https://([a-zA-Z0-9_-]+\.)?huggingface\.co(/|$|\?) ]]; then
        auth_token="$HF_TOKEN"
    elif
        [[ -n $CIVITAI_TOKEN && $1 =~ ^https://([a-zA-Z0-9_-]+\.)?civitai\.com(/|$|\?) ]]; then
        auth_token="$CIVITAI_TOKEN"
    fi
    if [[ -n $auth_token ]];then
        wget --header="Authorization: Bearer $auth_token" --content-disposition -e dotbytes="${3:-4M}" -P "$2" "$1"
    else
        wget --content-disposition -e dotbytes="${3:-4M}" -P "$2" "$1"
    fi
}

# Polls the temp dir size while hf/hf_transfer downloads (hf_transfer emits no
# parseable progress), printing a bar + % + MB every 20s.
function monitor_progress() {
    local watch_dir="$1" expected="$2" name="$3"
    local cur pct filled pad bar exp_mb
    exp_mb=$(( expected / 1048576 ))
    while :; do
        cur=$(du -sb "$watch_dir" 2>/dev/null | awk '{print $1}')
        cur=${cur:-0}
        pct=$(( cur * 100 / expected ))
        [ "$pct" -gt 100 ] && pct=100
        filled=$(( pct / 5 ))
        printf -v bar '%*s' "$filled" ''; bar=${bar// /#}
        printf -v pad '%*s' "$((20 - filled))" ''; pad=${pad// /-}
        echo "   ⏳ $name [${bar}${pad}] ${pct}% ($((cur / 1048576))/${exp_mb} MB)"
        sleep 20
    done
}

function download_civitai_lora() {
    local choice="${MINIMAX_MODEL:-pikaflex}"
    if [[ "$choice" != prism && "$choice" != both && "$choice" != pikaflex ]]; then
        echo "❌ Invalid MINIMAX_MODEL: $choice"
        return 1
    fi
    local name='Minimax_H3_Unlocked_V3.safetensors'
    local expected='a423ceb3363ab5bf305d99236e6acc7fddab265896e7b4a3d85778396ebc4963'
    local dir="${COMFYUI_DIR}/models/loras" dest tmp actual attempt
    dest="$dir/$name"
    mkdir -p "$dir" || return 1
    if [ -f "$dest" ]; then
        actual=$(sha256sum "$dest" | cut -d' ' -f1)
        if [ "$actual" = "$expected" ]; then
            echo "✅ $name already present and SHA-256 verified"
            return 0
        fi
        echo "❌ Existing $name has an unexpected SHA-256; leaving it untouched"
        return 1
    fi
    if [[ -z "${CIVITAI_TOKEN:-}" || ! "$CIVITAI_TOKEN" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        echo "❌ Set a valid CIVITAI_TOKEN in the private Vast.ai template"
        return 1
    fi
    tmp=$(mktemp "$dir/.civitai-lora.XXXXXXXX") || return 1
    for attempt in 1 2 3; do
        echo "📥 Downloading $name (attempt $attempt/3)"
        if printf 'header = "Authorization: Bearer %s"\n' "$CIVITAI_TOKEN" | \
            curl --config - --fail --silent --show-error --location --connect-timeout 30 --max-time 600 \
            'https://civitai.com/api/download/models/3446226' --output "$tmp"; then
            actual=$(sha256sum "$tmp" | cut -d' ' -f1)
            if [ "$actual" = "$expected" ]; then
                if [ -e "$dest" ]; then
                    echo "❌ $name appeared during download; leaving it untouched"
                    rm -f "$tmp"
                    return 1
                fi
                mv "$tmp" "$dest" || { rm -f "$tmp"; return 1; }
                echo "✅ $name downloaded and SHA-256 verified"
                return 0
            fi
            echo "⚠️ $name SHA-256 mismatch (attempt $attempt/3)"
        else
            echo "⚠️ $name download failed (attempt $attempt/3)"
        fi
        [ "$attempt" -lt 3 ] && sleep $((attempt * 5))
    done
    rm -f "$tmp"
    echo "❌ Failed to download and verify $name after 3 attempts"
    return 1
}

function download_one_minimax_model() {
    local entry="$1" base_dir="$2" hf_cmd="$3"
    local subdir name url min_size dest size repo_id repo_path tmp_dir downloaded_path attempt
    IFS='|' read -r subdir name url min_size <<< "$entry"
    dest="$base_dir/$subdir/$name"
    if [ -f "$dest" ]; then
        size=$(stat -L -c%s "$dest" 2>/dev/null || echo 0)
        if [ "$size" -ge "$min_size" ]; then
            echo "✅ $name already present ($size bytes), skipping"
            return 0
        fi
    fi
    repo_id=$(echo "$url" | awk -F/ '{print $4"/"$5}')
    repo_path=$(echo "$url" | sed -E 's#https?://[^/]+/[^/]+/[^/]+/resolve/main/(.+)#\1#')
    tmp_dir="$base_dir/.tmp_download_${name//\//_}"
    mkdir -p "$tmp_dir" "$(dirname "$dest")" || return 1
    export HF_HUB_ENABLE_HF_TRANSFER=1 HF_XET_HIGH_PERFORMANCE=1
    for attempt in 1 2 3; do
        echo "📥 $name: attempt $attempt/3"
        if "$hf_cmd" download "$repo_id" "$repo_path" --local-dir "$tmp_dir"; then
            downloaded_path="$tmp_dir/$repo_path"
            size=$(stat -L -c%s "$downloaded_path" 2>/dev/null || echo 0)
            if [ "$size" -ge "$min_size" ] && mv -f "$downloaded_path" "$dest"; then
                rm -rf "$tmp_dir"
                echo "✅ $name downloaded successfully ($size bytes)"
                return 0
            fi
            echo "⚠️ $name missing or too small ($size / $min_size bytes)"
        fi
        [ "$attempt" -lt 3 ] && sleep $((attempt * 5))
    done
    echo "❌ Failed to download $name after 3 attempts"
    return 1
}

function download_minimax_models() {
    local base_dir="${COMFYUI_DIR}/models"
    mkdir -p "$base_dir"/{vae,vae_approx,diffusion_models,text_encoders,clip_projections,loras,LLM/GGUF}

    local hf_cmd="hf" choice="${MINIMAX_MODEL:-pikaflex}" workers="${MODEL_DOWNLOAD_WORKERS:-2}"
    local entry name pid failed=0 batch_count=0
    local -a pids=()
    case "$choice" in both|prism|pikaflex) ;; *) echo "❌ MINIMAX_MODEL must be both, prism or pikaflex (got: $choice)"; return 1 ;; esac
    case "$workers" in 1|2|3|4) ;; *) echo "❌ MODEL_DOWNLOAD_WORKERS must be 1, 2, 3 or 4"; return 1 ;; esac
    command -v hf >/dev/null 2>&1 || hf_cmd="huggingface-cli"
    echo "🎛️ MINIMAX_MODEL=$choice; MODEL_DOWNLOAD_WORKERS=$workers"
    for entry in "${MINIMAX_MODELS[@]}"; do
        IFS='|' read -r _ name _ <<< "$entry"
        if [[ "$name" == PRISM_DMAD_PDMD_int8.safetensors && "$choice" == pikaflex ]] ||
           [[ "$name" == 10Eros_Max_SingularityV2_PRISM2_PikaFlex_0.85_int8HQ.safetensors && "$choice" == prism ]]; then
            echo "⏭️ Skipping $name (MINIMAX_MODEL=$choice)"
            continue
        fi
        download_one_minimax_model "$entry" "$base_dir" "$hf_cmd" &
        pids+=("$!")
        ((batch_count+=1))
        if [ "$batch_count" -ge "$workers" ]; then
            for pid in "${pids[@]}"; do wait "$pid" || failed=1; done
            pids=(); batch_count=0
        fi
    done
    for pid in "${pids[@]}"; do wait "$pid" || failed=1; done
    if [ "$failed" -ne 0 ]; then echo "❌ Model validation failed; check download errors above"; return 1; fi
    echo "✅ All selected models are present and meet minimum size checks"
}

if [[ ! -f /.noprovisioning ]]; then
    provisioning_start
fi
