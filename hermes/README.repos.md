# Repositorios para Hermes

Hermes monta `/root/repos` en `/workspace/repos` con lectura y escritura. Puede
modificar o borrar cualquier archivo de esos repositorios, incluidos sus
metadatos Git y los scripts de despliegue. El contenido puede afectar al host
si se ejecuta o despliega posteriormente. No guardar secretos ni credenciales
con permisos de escritura en ese directorio. Los repositorios nuevos dentro de
`/root/repos` tambien quedan expuestos.

La configuracion Git de Hermes convierte las URLs SSH habituales de GitHub a
HTTPS, sin cambiar los remotos del host, y busca la credencial en
`/opt/data/github-readonly.credentials`. Otros formatos de URL, proveedores,
configuraciones locales de Git o credenciales adicionales pueden necesitar
configuracion distinta. El token es accesible para Hermes: sus permisos en
GitHub, no esta configuracion de Git, son los que impiden publicar cambios.

## Crear un token

En GitHub, abre Settings > Developer settings > Personal access tokens >
Fine-grained tokens > Generate new token. Selecciona el propietario correcto,
una caducidad y `Only select repositories`; incluye todos los repositorios que
deba consultar. En `Repository permissions`, concede `Contents: Read-only` y
ningun permiso de escritura. Crea el token y copialo cuando GitHub lo muestre.
Si los repositorios pertenecen a varios propietarios, se necesita un token por
propietario y esta configuracion de credenciales requiere adaptacion. Una
organizacion puede exigir aprobacion o restringir estos tokens.

## Instalar y comprobar

Recrea el servicio para aplicar el montaje y la configuracion:

```sh
docker compose -f /opt/homelab/hermes/docker-compose.yml up -d hermes
```

Introduce el token de forma interactiva, sin incluirlo en el historial de
comandos. El archivo queda dentro del volumen persistente de Hermes:

```sh
docker exec -it hermes bash -c 'umask 077; read -rs -p "Token GitHub: " token; printf "\n"; printf "protocol=https\nhost=github.com\nusername=x-access-token\npassword=%s\n\n" "$token" | git credential approve; unset token'
```

Prueba la lectura con cada repositorio privado, por ejemplo:

```sh
docker exec hermes git -C /workspace/repos/homelab ls-remote origin HEAD
docker exec hermes git -C /workspace/repos/homelab pull --ff-only
```

`pull` puede fallar si hay cambios locales en conflicto o si la rama no puede
avanzar limpiamente. No uses un `push` real para probar permisos. Verifica en
GitHub que el token solo tiene `Contents: Read-only` y revocalo si se expone.
Para sustituirlo, elimina primero `/srv/homelab/hermes/github-readonly.credentials`
en el host y repite la instalacion; para revocarlo, hazlo tambien en GitHub.
