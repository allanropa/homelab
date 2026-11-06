# Mis Finanzas

Aplicación web de finanzas personales con FastAPI, React, PostgreSQL y Docker Compose.

## Configuración y despliegue

- Revisa la configuración de Compose y adapta dominios, almacenamiento y acceso
  a tu entorno antes de desplegar.
- Prepara el archivo de secretos requerido por la configuración a partir de
  `.env.example` y establece una contraseña segura para PostgreSQL. No
  sobrescribas un archivo de secretos existente ni lo incluyas en Git.
- El backend y el frontend se obtienen de repositorios separados. Configura
  `BACKEND_REPOSITORY` y `FRONTEND_REPOSITORY` con repositorios accesibles y,
  si es necesario, `BACKEND_BRANCH` y `FRONTEND_BRANCH` con las ramas deseadas.
  Proporciona credenciales de lectura cuando sean necesarias.
- Revisa `deploy.sh` y los archivos Compose antes de usarlos. El script crea
  imágenes y actualiza servicios; también elimina imágenes Docker sin etiqueta.
  Comprueba que estas acciones sean apropiadas para el entorno.

Configura el acceso a la aplicación y a la API según tu entorno, protegiendo
las conexiones y restringiendo el acceso cuando corresponda.

## Respaldos

Antes de cambios o actualizaciones, realiza y verifica copias de seguridad de
la base de datos y de la configuración necesaria para recuperarla. Guarda los
secretos por separado y de forma segura. Consulta `docs/operations.md` para
obtener detalles operativos, teniendo en cuenta que pueden requerir adaptación.
