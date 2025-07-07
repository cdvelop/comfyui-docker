# ComfyUI Docker

This is a Docker image for [ComfyUI](https://www.comfy.org/), which makes it extremely easy to run # Verificar y solucionar errores de memoria (OOM Killed)

Si al generar una imagen el contenedor se reinicia o ves mensajes como `Killed` o `exited with code 0`, probablemente tu sistema se está quedando sin memoria RAM o VRAM y el proceso es terminado por el sistema operativo (OOM: Out Of Memory).

## Recomendaciones para RTX 3060 (6GB VRAM)

⚠️ **IMPORTANTE**: El modelo FLUX Dev 1 es extremadamente demandante y puede no funcionar correctamente en GPUs con menos de 8GB de VRAM. Para RTX 3060:

1. **Usa modelos más ligeros** como SDXL, SD 1.5, o versiones cuantizadas de FLUX
2. **Reduce la resolución** de las imágenes generadas (ej: 512x512 en lugar de 1024x1024)
3. **Activa la optimización de memoria** en ComfyUI
4. **Aumenta significativamente el swap** de tu sistema

## Pasos para diagnosticar y solucionar:UI on Linux and Windows WSL2. The image also includes the [ComfyUI Manager](https://github.com/ltdrdata/ComfyUI-Managergithub ) extension.

## Getting Started

To get started, you have to install [Docker](https://www.docker.com/). This can be either Docker Engine, which can be installed by following the [Docker Engine Installation Manual](https://docs.docker.com/engine/install/) or Docker Desktop, which can be installed by [downloading the installer](https://www.docker.com/products/docker-desktop/) for your operating system.

To enable the usage of NVIDIA GPUs, the NVIDIA Container Toolkit must be installed. The installation process is detailed in the [official documentation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

## Installation

The ComfyUI Docker image is available from the [GitHub Container Registry](https://ghcr.io). Installing ComfyUI is as simple as pulling the image and starting a container, which can be achieved using the following command:

```shell
docker run \
    --name comfyui \
    --detach \
    --restart unless-stopped \
    --env USER_ID="$(id -u)" \
    --env GROUP_ID="$(id -g)" \
    --volume "$DOCKER_MODELS/comfyui_models:/opt/comfyui/models:rw" \
    --volume "$DOCKER_VOLUMES/comfyui_volumes:/opt/comfyui/custom_nodes:rw" \
    --publish 8188:8188 \
    --runtime nvidia \
    --gpus all \
    ghcr.io/lecode-official/comfyui-docker:latest
```


**Nota:** Se recomienda definir las siguientes variables de entorno en tu `~/.bashrc` para facilitar la gestión de rutas:

```sh
export DOCKER_MODELS="$HOME/Dev/Docker/models"
export DOCKER_VOLUMES="$HOME/Dev/Docker/Volumes"
```

Luego crea las carpetas necesarias para ComfyUI:

```sh
mkdir -p "$DOCKER_MODELS/comfyui_models" "$DOCKER_VOLUMES/comfyui_volumes"
```

The `--detach` flag causes the container to run in the background and `--restart unless-stopped` configures the Docker Engine to automatically restart the container if it stopped itself, experienced an error, or the computer was shutdown, unless you explicitly stopped the container using `docker stop`. This means that ComfyUI will be automatically started in the background when you boot your computer. The two `--env` arguments inject the user ID and group ID of the current host user into the container. During startup, a user with the same user ID and group ID will be created, and ComfyUI will be run using this user. This ensures that files written to the volumes (e.g., models and custom nodes installed with the ComfyUI Manager) will be owned by the host system's user. Normally, the user inside the container is `root`, which means that the files that are written from the container to the host system are also owned by `root`. If you have run ComfyUI Docker without setting the environment variables, then you may have to change the owner of the files in the models and custom nodes directories: `sudo chown -r "$(id -un):$(id -gn)" <path/to/models/folder> <path/to/custom/nodes/folder>`. The `--runtime nvidia` and `--gpus all` arguments enable ComfyUI to access the GPUs of your host system. If you do not want to expose all GPUs, you can specify the desired GPU index or ID instead.

After the container has started, you can navigate to [localhost:8188](http://localhost:8188) to access ComfyUI.

If you want to stop ComfyUI, you can use the following commands:

```shell
docker stop comfyui
docker rm comfyui
```

> [!WARNING]
> While the custom nodes themselves are installed outside of the container, their requirements are installed inside of the container. This means that stopping and removing the container will remove the installed requirements. When the container is started again, the requirements will be automatically installed, but this may, depending on the number of custom nodes and their requirements, take some time.

## Updating

To update ComfyUI Docker to the latest version you have to first stop the running container, then pull the new version, optionally remove dangling images, and then restart the container:

```shell
docker stop comfyui
docker rm comfyui

docker pull ghcr.io/lecode-official/comfyui-docker:latest
docker image prune # Optionally remove dangling images

docker run \
    --name comfyui \
    --detach \
    --restart unless-stopped \
    --env USER_ID="$(id -u)" \
    --env GROUP_ID="$(id -g)" \
    --volume "$DOCKER_MODELS/comfyui_models:/opt/comfyui/models:rw" \
    --volume "$DOCKER_VOLUMES/comfyui_volumes:/opt/comfyui/custom_nodes:rw" \
    --publish 8188:8188 \
    --runtime nvidia \
    --gpus all \
    ghcr.io/lecode-official/comfyui-docker:latest
```

## Building

If you want to use the bleeding edge development version of the Docker image, you can also clone the repository and build the image yourself:

```shell
git clone https://github.com/lecode-official/comfyui-docker.git
docker build --tag lecode/comfyui-docker:latest source
```



## requisito previo pra docker y nvidia
NVIDIA Container Toolkit siguiendo la guía oficial:
https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html


# para iniciar:
```bash
docker run --rm -it \
  --gpus all \
  --runtime=nvidia \
  --env USER_ID=$(id -u) \
  --env GROUP_ID=$(id -g) \
  --volume "$DOCKER_MODELS/comfyui_models:/opt/comfyui/models:rw" \
  --volume "$DOCKER_VOLUMES/comfyui_volumes:/opt/comfyui/custom_nodes:rw" \
  -p 8188:8188 \
  --name comfyui \
  comfyui:local
```

# iniciar con docker compose
```bash
docker compose up -d
```

# Verificar y solucionar errores de memoria (OOM Killed)

Si al generar una imagen el contenedor se reinicia o ves mensajes como `Killed` o `exited with code 0`, probablemente tu sistema se está quedando sin memoria RAM o VRAM y el proceso es terminado por el sistema operativo (OOM: Out Of Memory).

**Pasos para diagnosticar y solucionar:**

1. **Verifica el uso de RAM y SWAP en tu sistema host:**
   ```bash
   free -h
   ```
   y para la GPU:
   ```bash
   watch -n 1 nvidia-smi
   ```

2. **Aumenta el swap** de tu sistema si tienes poca RAM.
   Puedes crear un archivo de swap de 16GB ejecutando este script:
   ```bash
   #!/bin/bash
   # Script para crear y activar un swapfile de 16GB (recomendado para FLUX)
   sudo swapoff -a
   sudo dd if=/dev/zero of=/swapfile bs=1G count=16
   sudo mkswap /swapfile
   sudo chmod 600 /swapfile
   sudo swapon /swapfile
   free -h
   ```
   Puedes ajustar el tamaño cambiando el valor de `count=16` (mínimo recomendado para FLUX: 16GB).

   Para que el swap se active automáticamente al reiniciar, agrega esta línea a tu `/etc/fstab`:
   ```
   /swapfile none swap sw 0 0
   ```
   ```

3. **Asegúrate de no tener límites de memoria en tu docker-compose.yml.** Si tienes algo como:
   ```yaml
   deploy:
     resources:
       limits:
         memory: 4G
   ```
   elimínalo o súbelo.

4. **Prueba con un modelo más pequeño** para ver si el problema es por falta de recursos.

5. **Revisa los logs del sistema** (dmesg) para ver si hay mensajes de OOM killer:
   ```bash
   dmesg | grep -i kill
   ```

6. **Ver logs del contenedor:**
   ```bash
   docker compose logs -f comfyui
   ```

Si el problema persiste, revisa la configuración de tu hardware o consulta la documentación oficial de Docker y ComfyUI.

Para ver los logs del contenedor comfyui-docker, ejecuta este comando en tu terminal:

```bash
docker compose logs -f comfyui
```

Esto mostrará los logs en tiempo real del servicio comfyui definido en tu docker-compose.yml. Si quieres ver solo los últimos logs sin seguir en tiempo real, puedes omitir el `-f`:

```bash
docker compose logs comfyui
```

Si usaste solo `docker run` (sin compose), sería:

```bash
docker logs -f comfyui
```

## Tutorial de uso de ComfyUI
[![Alt text](https://img.youtube.com/vi/G-SEKbx6Imk/0.jpg)](https://www.youtube.com/watch?v=G-SEKbx6Imk)


## para detener el contenedor
```bash
docker compose stop comfyui
```
## todos los contenedores
```bash
docker compose stop
```

## Scripts de utilidad incluidos

Para ayudarte a gestionar ComfyUI y diagnosticar problemas, se incluyen los siguientes scripts:

### Aumentar SWAP (recomendado antes de usar FLUX)
```bash
./increase_swap.sh
```

### Configurar modo Low VRAM para RTX 3060
```bash
./setup_low_vram.sh
```

### Monitorear recursos del sistema
```bash
./monitor_resources.sh
```

### Comandos útiles para diagnosticar problemas

**Ver uso de GPU en tiempo real:**
```bash
watch -n 1 nvidia-smi
```

**Ver logs de ComfyUI en tiempo real:**
```bash
docker logs -f comfyui
```

**Ver estadísticas de Docker:**
```bash
docker stats
```

**Verificar procesos que están usando la GPU:**
```bash
nvidia-smi pmon -i 0
```

## Modelos recomendados para RTX 3060

Dado que FLUX Dev 1 requiere mucha VRAM, para tu RTX 3060 se recomienda usar:

1. **SDXL** - Excelente calidad, menor uso de VRAM
2. **SD 1.5** - Muy estable y rápido
3. **FLUX Schnell** - Versión optimizada de FLUX
4. **Modelos cuantizados** (fp8, fp16) que usan menos memoria

## Configuraciones recomendadas en ComfyUI

Para optimizar el rendimiento en tu RTX 3060:

1. **Usa CFG Scale más bajo** (6-8 en lugar de 10-15)
2. **Reduce los pasos** (15-20 pasos en lugar de 30-50)
3. **Resolución moderada** (768x768 o 512x768 en lugar de 1024x1024)
4. **Activa "Low VRAM" mode** en configuraciones de ComfyUI

## Configuración específica para FLUX en RTX 3060

Si experimentas reinicios al cargar modelos FLUX, sigue estos pasos en orden:

### 1. Ejecuta el setup automático
```bash
./setup_low_vram.sh
```

### 2. Configuraciones adicionales en ComfyUI Web UI
Una vez que ComfyUI esté ejecutándose, ve a la interfaz web (http://localhost:8188) y:

1. **Click en el ícono de configuración** (⚙️) en la esquina superior derecha
2. **Habilita las siguientes opciones:**
   - ✅ `Enable Dev mode Options`
   - ✅ `Use CPU for VAE if not enough VRAM`
   - ✅ `Disable VRAM auto detection`
   - ✅ `Free VRAM when not in use`
   - ✅ `Lowvram` o `CPU offload` (si está disponible)

### 3. Parámetros recomendados para generar
- **Resolución**: 768x768 (máximo 1024x768)
- **CFG Scale**: 3.5-7 (en lugar de 10-15)
- **Steps**: 20-28 (en lugar de 50+)
- **Batch size**: 1
- **Considera FLUX Schnell** en lugar de FLUX Dev (más rápido y eficiente)

### 4. Si el problema persiste
Si ComfyUI sigue reiniciándose con FLUX Dev:

```bash
# Aumenta el swap a 20GB o más
./increase_swap.sh  # Elige 20 cuando pregunte

# Verifica que no hay procesos usando VRAM
nvidia-smi

# Reinicia ComfyUI
docker compose restart
```


## License

The ComfyUI Docker image is licensed under the [MIT License](LICENSE). [ComfyUI](https://github.com/comfyanonymous/ComfyUI/blob/master/LICENSE) and the [ComfyUI Manager](https://github.com/ltdrdata/ComfyUI-Manager/blob/main/LICENSE.txt) are both licensed under the GPL 3.0 license.
