#!/bin/bash
# Script para monitorear recursos mientras usas ComfyUI

echo "Monitoreando recursos del sistema..."
echo "Presiona Ctrl+C para salir"
echo ""

while true; do
    clear
    echo "=== ESTADO DEL SISTEMA $(date) ==="
    echo ""

    echo "=== MEMORIA RAM ==="
    free -h
    echo ""

    echo "=== GPU (NVIDIA) ==="
    nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,memory.used,memory.total,power.draw --format=csv,noheader,nounits
    echo ""

    echo "=== PROCESOS DOCKER ==="
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
    echo ""

    echo "=== LOGS RECIENTES DE COMFYUI ==="
    docker logs --tail 5 comfyui 2>/dev/null || echo "Contenedor ComfyUI no encontrado"
    echo ""

    sleep 2
done
