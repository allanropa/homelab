# Estrategia de backup

## Objetivo

Proteger los datos persistentes del homelab frente a borrados accidentales,
fallos del disco del servidor y pérdida física del equipo. Una copia en el
disco raíz no es un backup ante los dos últimos casos.

La estrategia adoptada usa el árbol que Syncthing replica:

- Datos de producción en el servidor.
- Archivos de backup publicados en
  `/root/storage/syncthing/volume_backup`.
- Una réplica de esos archivos en el equipo remoto de Syncthing.

Este directorio está actualmente en el mismo disco raíz que los datos de
producción. Solo protege ante un fallo local cuando Syncthing haya terminado
de replicarlo al otro equipo.

La carpeta de backup debe ser `Send Only` en este host y `Receive Only` en el
receptor. Activar versionado de archivos en el receptor evita que un borrado o
ransomware se replique y elimine la última copia sana.

## Datos incluidos

La copia diaria debe incluir estos orígenes:

| Origen | Contenido | Tratamiento |
| --- | --- | --- |
| Directorios seleccionados de `/srv/homelab` | Datos de aplicaciones y configuraciones persistentes definidos en `EXTRA_DIRS` | Incluir |
| Volúmenes Docker nombrados | `caddy_caddy_config`, `caddy_caddy_data`, `expenses_postgres_data` y otros datos de aplicación | Incluir si contienen datos útiles |
| `/opt/homelab` | Compose files, scripts y configuración versionada | Incluir |
| `/etc/homelab/secrets` | Credenciales necesarias para restaurar los servicios | Incluir en un archivo cifrado |

El inventario actual de `/srv/homelab` incluye PostgreSQL de Expenses e
Immich, SQLite de Vaultwarden, datos de Radicale, Hermes, configuraciones de
los servicios multimedia, Syncthing, Navidrome y Caddy. Todos ellos se
consideran datos de producción.

## Exclusiones

No se debe gastar espacio externo en datos reproducibles:

- El volumen `immich_model-cache`.
- Cachés, miniaturas o modelos que cada aplicación pueda regenerar, tras
  confirmar que no contienen datos de usuario.
- Imágenes, contenedores y capas de Docker.

Los medios que viven fuera de `/srv/homelab` no quedan cubiertos por esta
estrategia. En este host hay rutas montadas bajo `/root/storage` para fotos,
música, notas y multimedia. Deben tener su propio backup si son fuente de
verdad; una sincronización no sustituye una copia con versiones.

## Ejecución diaria

Programar una ejecución nocturna, por ejemplo a las 03:15, con esta secuencia:

1. Verificar que el destino externo está disponible y que queda espacio.
2. Detener ordenadamente los contenedores que escriben datos persistentes.
   Esto incluye al menos PostgreSQL, Immich, Vaultwarden, Radicale, Hermes,
   Caddy, Syncthing, Navidrome y los servicios multimedia.
   Los contenedores configurados en `STOP_CONTAINERS_BY_NAME` se paran antes
   de archivar los directorios extra y se arrancan al terminar; actualmente
   incluye Hermes.
3. Crear un directorio con fecha bajo
   `/root/storage/syncthing/volume_backup`, con archivos comprimidos de los
   volúmenes Docker, los directorios configurados en `EXTRA_DIRS` y
   `/opt/homelab`. Cifrar el archivo que contiene `/etc/homelab/secrets` antes
   de publicarlo.
4. Arrancar de nuevo los contenedores aunque la copia falle y comprobar sus
   healthchecks.
5. Generar un manifiesto SHA-256 para todos los archivos del directorio.
6. Esperar a que Syncthing muestre el directorio sincronizado con el receptor.
7. Aplicar la retención y registrar el resultado; alertar ante cualquier error.

Detener los servicios durante la copia evita copias inconsistentes de los
directorios de datos de PostgreSQL y archivos SQLite. Con el tamaño actual de
`/srv/homelab` (aproximadamente 2.9 GB), esta opción es simple y el corte debe
ser breve. Si el corte deja de ser aceptable, el siguiente paso es generar
`pg_dump` para cada PostgreSQL y usar el mecanismo de backup recomendado por
cada servicio antes de copiar los demás ficheros.

El script existente `backup-docker-volumes.sh` puede usarse como base para los
archivos de volumen, pero debe publicar su resultado bajo el árbol de Syncthing
y ejecutarse dentro de la ventana de parada. Su destino predeterminado está en
el mismo disco y no protege por sí solo ante un fallo de disco.

## Retención y verificación

Aplicar la siguiente política en el directorio publicado. La eliminación se
propagará al receptor, por eso el versionado remoto es obligatorio:

- 7 copias diarias.
- 4 copias semanales.
- 12 copias mensuales.
- 2 copias anuales.

Verificar mensualmente los manifiestos con `sha256sum -c` y restaurar una
muestra cada trimestre en un directorio o host de prueba. Una copia no se
considera válida hasta haber restaurado y abierto datos de al menos una
aplicación y una base de datos.

## Restauración

1. Preparar un host con Docker y clonar o restaurar `/opt/homelab`.
2. Restaurar `/etc/homelab/secrets` con permisos restrictivos.
3. Mantener detenidos los servicios afectados.
4. Restaurar los directorios incluidos de `/srv/homelab` y los archivos de los
   volúmenes Docker en sus rutas originales.
5. Corregir propietario y permisos según cada contenedor, si fuese necesario.
6. Arrancar los Compose correspondientes y revisar logs y healthchecks.
7. Verificar inicio de sesión, datos y acceso a los medios antes de dar por
   concluida la recuperación.

La clave para descifrar los secretos debe guardarse fuera del servidor, por
ejemplo en Vaultwarden y en una copia de emergencia segura. Sin ella no se
podrán restaurar las credenciales de los servicios.

## Pendiente antes de implementar

- Compartir `volume_backup` dentro de la carpeta de Syncthing.
- Configurar `Send Only` en este host, `Receive Only` y versionado en el
  receptor.
- Añadir el script de orquestación y un temporizador systemd.
- Ejecutar una primera copia, comprobar el manifiesto y restaurar una muestra.
