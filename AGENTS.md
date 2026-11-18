# Gestión de secretos

Los agentes no tienen permiso para leer ni escribir en `/etc/homelab/secrets`.

Cuando un servicio necesite secretos, crear un archivo `.env.example` sin valores
reales dentro de su directorio y explicar al usuario que debe copiarlo y
completarlo manualmente en `/etc/homelab/secrets/<servicio>.env`.
