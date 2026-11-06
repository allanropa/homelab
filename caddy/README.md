# Caddy y separación de redes

Caddy puede actuar como proxy inverso para servicios web. Su configuración debe adaptarse al entorno y al nivel de acceso requerido por cada servicio.

## Seguridad de red

- Limitar las interfaces y redes de acceso según las necesidades del despliegue, y configurar autenticación y autorización cuando corresponda.
- Las redes Docker separadas reducen la conectividad directa, pero no garantizan aislamiento frente a puertos publicados, proxies u otras rutas. Compartir una red tampoco establece permisos direccionales.
- Revisar tanto IPv4 como IPv6, las rutas externas y la exposición directa de cada servicio. Verificar los controles con pruebas desde las redes relevantes.
- Conceder a los contenedores los permisos mínimos necesarios. El acceso al socket de Docker puede otorgar privilegios elevados, incluso si se monta en modo de solo lectura.
- Antes de cambiar redes o reglas de firewall, evaluar el impacto y preparar un procedimiento de reversión que conserve el acceso administrativo.
