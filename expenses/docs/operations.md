# Operación local

## Inicio

1. Copiar `.env.example` a `/etc/homelab/secrets/expenses.env` y cambiar la
   contraseña de PostgreSQL.
2. Ejecutar `./deploy.sh`.
3. Abrir `http://localhost:5173`.
4. La API y OpenAPI estarán disponibles en `http://localhost:8000/docs`.

PostgreSQL escucha únicamente en `5432` dentro de la red Docker. La API debe
seguir usando `db:5432` en `DATABASE_URL`.

## Caddy

La configuración del servidor Caddy incluye:

- `expenses.lan.rpamplona.com` hacia `localhost:5173`.
- `expenses-api.lan.rpamplona.com` hacia `localhost:8000`.

Para ese acceso, configurar el entorno de la aplicación con:

```bash
COOKIE_SECURE=true
FRONTEND_ORIGIN=https://expenses.lan.rpamplona.com
FRONTEND_ORIGINS=https://expenses.lan.rpamplona.com,https://expenses.rpamplona.com
VITE_API_URL=https://expenses-api.lan.rpamplona.com
```

`POSTGRES_PASSWORD` solo se usa al inicializar el volumen de PostgreSQL. Si se
cambia después, hay que actualizar también la contraseña del rol existente o
el backend no podrá arrancar y el navegador puede mostrarlo erróneamente como
un fallo de CORS.

El script clona el backend y frontend en un directorio temporal para construir
las imágenes. El directorio de despliegue no contiene código de aplicación.

## Cloudflare Tunnel

El túnel público expone `expenses.rpamplona.com` (frontend) y
`expenses-api.rpamplona.com` (API) a través de un contenedor `cloudflared`
definido en `/root/cloudflared/`. Ambos proyectos comparten la red externa
aislada `cloudflared` (`docker network create cloudflared`), de modo que
`cloudflared` solo alcanza a los servicios de expenses y viceversa; el resto
del homelab no tiene acceso a esa red.

El frontend deriva la URL de la API según el hostname de acceso, así que el
mismo build sirve para la LAN (`expenses-api.lan.rpamplona.com`) y para el
túnel (`expenses-api.rpamplona.com`).

## Pruebas

Ejecutar las pruebas en el repositorio del backend. Las migraciones se aplican
automáticamente durante `./deploy.sh`.

```bash
cd /ruta/al/repositorio/expenses-be && pytest
```

## Backup y restauración

```bash
docker compose -p expenses exec db pg_dump -U expenses expenses > backup.sql
cat backup.sql | docker compose -p expenses exec -T db psql -U expenses expenses
```
