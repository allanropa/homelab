# Guild Wars 2 MCP

El despliegue obtiene la rama `main` por SSH y genera una imagen temporal a partir del codigo upstream. Revisa el codigo antes de aplicar: la revision no esta fijada. El servidor no publica puertos y necesita acceso saliente a la API de Guild Wars 2.

1. Inicia Hermes con `docker compose -f hermes/docker-compose.yml up -d`. Compose crea la red compartida `hermes_guild_wars_2_connector` automaticamente.
2. Opcionalmente, exporta `GW2_API_KEY` en el entorno desde un almacen seguro antes de desplegar. Sin ella solo estan disponibles los datos publicos; para los datos personales la clave necesita los permisos correspondientes. No guardes la clave en este repositorio.
3. Ejecuta `bash guild-wars-2-mcp/deploy.sh` para validar, o `bash guild-wars-2-mcp/deploy.sh --apply` para construir y desplegar. Al recrear el servidor, proporciona de nuevo la clave si la utilizas.
4. Comprueba la conexion con `docker exec hermes hermes mcp test guild_wars_2`.

El endpoint MCP no tiene autenticacion: cualquier contenedor conectado a esta red puede consultar los datos accesibles con la clave configurada. Limita su acceso a contenedores de confianza. La clave queda disponible en la configuracion del contenedor para administradores de Docker.
