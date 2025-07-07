#!/bin/bash
# Script para crear y activar un swapfile de 16GB (recomendado para FLUX)

echo "=== SCRIPT PARA AUMENTAR SWAP PARA COMFYUI/FLUX ==="
echo ""

# Mostrar estado actual
echo "Estado actual de memoria:"
free -h
echo ""

# Preguntar al usuario el tamaño
read -p "¿Cuántos GB de swap quieres crear? (recomendado: 16 para FLUX): " swap_size

# Validar entrada
if ! [[ "$swap_size" =~ ^[0-9]+$ ]] || [ "$swap_size" -lt 4 ]; then
    echo "Error: Ingresa un número válido (mínimo 4 GB)"
    exit 1
fi

echo ""
echo "Creando swapfile de ${swap_size}GB..."
echo "⚠️  Esto puede tomar varios minutos..."

# Desactivar swap actual
echo "Desactivando swap actual..."
sudo swapoff -a

# Crear nuevo swapfile
echo "Creando archivo swap de ${swap_size}GB..."
sudo dd if=/dev/zero of=/swapfile bs=1G count=$swap_size status=progress

# Configurar como swap
echo "Configurando como swap..."
sudo mkswap /swapfile
sudo chmod 600 /swapfile

# Activar el nuevo swap
echo "Activando swap..."
sudo swapon /swapfile

echo ""
echo "✅ Swap creado y activado exitosamente!"
echo ""
echo "Estado actual de memoria:"
free -h

echo ""
echo "📝 Para hacer permanente este swap (recomendado), ejecuta:"
echo "echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab"
echo ""
echo "🚀 Ahora puedes intentar ejecutar ComfyUI con FLUX nuevamente:"
echo "docker compose up -d"
