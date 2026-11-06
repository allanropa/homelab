# Configuración gestionada de Hermes

Este directorio contiene configuración gestionada para una integración MCP. Consulta la [documentación de Hermes](https://hermes-agent.nousresearch.com/docs/user-guide/managed-scope) y comprueba la compatibilidad con la versión utilizada antes de aplicarla o actualizarla.

La configuración gestionada puede tener prioridad sobre la configuración de usuario. Revisa las reglas de fusión, especialmente el tratamiento de listas, los conflictos de tipos y los permisos antes de introducir cambios. Evita sustituir configuraciones existentes sin verificar sus efectos y conserva un procedimiento de reversión.

Tras aplicar cambios, comprueba la configuración efectiva y el funcionamiento de la integración sin exponer secretos. Según el despliegue, puede ser necesario reiniciar o recrear el proceso para que se apliquen.

No guardes credenciales, tokens, conversaciones ni memoria en archivos destinados al repositorio público. Limita el acceso al servidor MCP, configura autenticación cuando corresponda y revisa los permisos de sus operaciones, incluidas las de escritura.
