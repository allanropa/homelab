# IMAP MCP

El despliegue clona por SSH la rama `master` de `allanropa/imap-mcp` y construye una imagen local. La revision no esta fijada: revisa el codigo upstream antes de aplicar. El servicio necesita acceso saliente al servidor IMAP mediante TLS.

1. Prepara `/etc/homelab/secrets/imap-mcp.env` con `IMAP_HOST`, `IMAP_USER` e `IMAP_PASSWORD` para la cuenta normal y `IMAP_FINANCIAL_HOST`, `IMAP_FINANCIAL_USER` e `IMAP_FINANCIAL_PASSWORD` para la cuenta financiera. Opcionalmente define `IMAP_PORT` e `IMAP_FINANCIAL_PORT` (ambos por defecto `993`). Utiliza contrasenas de aplicacion si el proveedor las requiere. No guardes credenciales en este repositorio.
2. Edita `imap-mcp/financial_rules.json` en esta maquina. Cada regla admite `sender`, `subject_regex` o ambos; los campos de una regla se combinan con AND y las reglas con OR. Reinicia el servicio tras modificar el archivo: las reglas se leen al arrancar.
3. Inicia o recrea Hermes con `docker compose -f hermes/docker-compose.yml up -d`. Compose crea la red compartida `hermes_imap_connector`. Conecta a ella solo contenedores de confianza.
4. Ejecuta `bash imap-mcp/deploy.sh` para validar o `bash imap-mcp/deploy.sh --apply` para construir y desplegar. Se requiere acceso SSH a GitHub.

El endpoint es `http://imap-mcp:8000/mcp` desde la red compartida. No tiene autenticacion ni puertos publicados en el host; cualquier contenedor conectado a esa red puede leer los datos accesibles de la cuenta. `/health` solo comprueba que el servidor responde, no la conexion IMAP. Las credenciales estan disponibles para administradores de Docker.

En Hermes, `buscar_correos` consulta la cuenta normal y `buscar_correos_financieros` consulta la financiera. Para leer un resultado financiero, usa `leer_correo` con su `uid`, `uidvalidity` y `carpeta`, y especifica `cuenta: financiera`; para los resultados normales usa `cuenta: normal` (el valor predeterminado). Los identificadores no son intercambiables entre cuentas.

Tras actualizar las credenciales, vuelve a ejecutar `bash imap-mcp/deploy.sh --apply` para construir la version actual y recrear el contenedor. Comprueba la conexion con `docker exec hermes hermes mcp test imap` y prueba una busqueda en cada cuenta; el test MCP no verifica las credenciales IMAP.
