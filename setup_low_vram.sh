#!/bin/bash
# Script para configurar ComfyUI en modo Low VRAM para RTX 3060

echo "=== CONFIGURANDO COMFYUI PARA LOW VRAM (RTX 3060) ==="
echo ""

# Verificar si ComfyUI está corriendo
if docker ps | grep -q comfyui; then
    echo "⚠️  ComfyUI está ejecutándose. Deteniéndolo..."
    docker compose stop
    sleep 2
fi

echo "📁 Configurando archivos de configuración..."

# Crear directorio de configuración si no existe
mkdir -p "${DOCKER_VOLUMES}/comfyui_volumes/user/default"

# Crear archivo de configuración para low VRAM
cat > "${DOCKER_VOLUMES}/comfyui_volumes/user/default/extra_model_paths.yaml" << 'EOF'
# Extra model paths configuration for Low VRAM
# This forces ComfyUI to use CPU RAM for model storage when possible

checkpoints: /opt/comfyui/models/checkpoints
vae: /opt/comfyui/models/vae
loras: /opt/comfyui/models/loras
upscale_models: /opt/comfyui/models/upscale_models
embeddings: /opt/comfyui/models/embeddings
hypernetworks: /opt/comfyui/models/hypernetworks
controlnet: /opt/comfyui/models/controlnet
clip: /opt/comfyui/models/clip
unet: /opt/comfyui/models/unet
clip_vision: /opt/comfyui/models/clip_vision
style_models: /opt/comfyui/models/style_models
EOF

echo "✅ Configuración Low VRAM aplicada"
echo ""
echo "📋 Configuraciones recomendadas en ComfyUI Web UI:"
echo "   • Ir a Settings (rueda dentada)"
echo "   • Enable: 'Enable Dev mode Options'"
echo "   • Enable: 'Use CPU for VAE if not enough VRAM'"
echo "   • Enable: 'Disable VRAM auto detection'"
echo "   • Set: 'Free VRAM when not in use' to ON"
echo ""
echo "🚀 Iniciando ComfyUI con configuración optimizada..."

# Iniciar ComfyUI
docker compose up -d

echo ""
echo "⏳ Esperando que ComfyUI se inicie..."
sleep 5

echo ""
echo "🌐 ComfyUI debería estar disponible en: http://localhost:8188"
echo ""
echo "💡 Recomendaciones para generar con FLUX en RTX 3060:"
echo "   • Resolución: 768x768 (máximo 1024x768)"
echo "   • CFG Scale: 3.5-7"
echo "   • Steps: 20-28"
echo "   • Batch size: 1"
echo "   • Considera usar FLUX Schnell en lugar de FLUX Dev"
