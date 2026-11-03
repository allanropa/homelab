# Mis Finanzas

Aplicación web de finanzas personales con FastAPI, React, PostgreSQL y Docker Compose.

## Despliegue de producción (esta máquina)

El despliegue de producción vive en `/opt/homelab/expenses`. Este repositorio
solo contiene la configuración de despliegue; el backend y el frontend siguen
en sus propios repositorios. Incluye la configuración para servir
`expenses.lan.rpamplona.com` (frontend) y `expenses-api.lan.rpamplona.com`
(API).

```bash
cp .env.example /etc/homelab/secrets/expenses.env   # editar POSTGRES_PASSWORD
./deploy.sh
```

El archivo de secretos está fuera del repositorio en
`/etc/homelab/secrets/expenses.env`. Los datos de PostgreSQL se almacenan en
`/srv/homelab/expenses/postgres_data`.

`deploy.sh` clona ambos repositorios de aplicación en un directorio temporal,
construye las imágenes desde allí y borra ese directorio al terminar. Requiere
una clave SSH con acceso de lectura a `allanropa/expenses-be` y
`allanropa/expenses-fe`. Por defecto despliega la rama `master` de ambos;
`BACKEND_BRANCH`, `FRONTEND_BRANCH`, `BACKEND_REPOSITORY` y
`FRONTEND_REPOSITORY` permiten cambiarlo puntualmente.

Al migrar esta copia existente, ejecutar primero un despliegue correcto y
después eliminar los directorios locales heredados `backend/` y `frontend/` del
repositorio de despliegue. No forman parte de la ejecución ni afecta a sus
repositorios remotos.

- Frontend: `https://expenses.lan.rpamplona.com`
- API: `https://expenses-api.lan.rpamplona.com`
- OpenAPI: `https://expenses-api.lan.rpamplona.com/docs`

### Cloudflare Tunnel (acceso público)

Además del acceso por Caddy en la LAN, la app puede exponerse públicamente
mediante un túnel de Cloudflare. La configuración vive en `/root/cloudflared/`
(servicio `cloudflared`) y comparte con `expenses` una red Docker aislada
llamada `cloudflared`, a la que ningún otro contenedor del homelab tiene acceso.

1. Crear la red aislada (una sola vez):

   ```bash
   docker network create cloudflared
   ```

2. Configurar el túnel y sus hostnames públicos siguiendo
   `/root/cloudflared/.env.example`, y arrancar:

   ```bash
   docker compose -f /root/cloudflared/docker-compose.yml up -d
   ```

3. Redesplegar expenses (ahora unido a la red `cloudflared`):

   ```bash
   ./deploy.sh
   ```

- Público frontend: `https://expenses.rpamplona.com`
- Público API: `https://expenses-api.rpamplona.com`

### Redesplegar

```bash
./deploy.sh
```

Clona las versiones configuradas del backend y frontend en un directorio
temporal, reconstruye las imágenes y levanta los servicios con la configuración
de Caddy. El código fuente no permanece en este directorio después del
despliegue.

El detalle de operación, migraciones, pruebas y backup está en `docs/operations.md`.
