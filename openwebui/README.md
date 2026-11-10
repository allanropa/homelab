# Open WebUI

El servicio guarda su configuracion, base de datos y archivos en
`/srv/homelab/openwebui`. Docker Compose lee las variables de
`/etc/homelab/secrets/openwebui.env`; usa `env.example` como referencia y
genera una clave persistente con `openssl rand -hex 32`. Protege el archivo de
secretos y no sustituyas una clave existente al actualizar.

Antes de iniciar, crea el directorio de datos y el archivo de secretos. Despues,
desde este directorio:

```bash
docker compose config --quiet
docker compose pull
docker compose up -d
```

Caddy expone la interfaz en `https://openwebui.lan.rpamplona.com`; configura la
resolucion DNS de ese nombre y recarga Caddy tras modificar su configuracion.
El primer usuario registrado es administrador: crealo antes de permitir acceso
a otras personas. Configura un proveedor de modelos desde la interfaz o mediante
las variables de entorno. Este servicio no incluye Ollama ni modelos locales.

## Conexion con Hermes

Hermes crea la red compartida `hermes_openwebui_connector`, por lo que debe
iniciarse antes que Open WebUI. Configura `API_SERVER_KEY`, `API_SERVER_HOST`
y `API_SERVER_PORT` en `/etc/homelab/secrets/hermes.env` siguiendo
`hermes/env.example`. Genera una clave fuerte con `openssl rand -hex 32` y
conserva su valor para configurarlo tambien en Open WebUI.

Tras actualizar el archivo de secretos y los Compose, recrea ambos servicios:

```bash
docker compose -f /opt/homelab/hermes/docker-compose.yml up -d
docker compose -f /opt/homelab/openwebui/docker-compose.yml up -d
```

En las conexiones OpenAI de Open WebUI, agrega `http://hermes:8642/v1` como
URL y el valor de `API_SERVER_KEY` como clave. La API de Hermes ejecuta un
agente con acceso a sus herramientas; limita el acceso a la clave y a la red.

La imagen usa la etiqueta `main`, por lo que una descarga puede actualizar la
version. Revisa las notas de publicacion antes de actualizar y conserva copias
de seguridad del directorio de datos y de la clave secreta por separado.
