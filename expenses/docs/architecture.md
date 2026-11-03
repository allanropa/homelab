# Arquitectura

La aplicación es un monolito modular compuesto por una API FastAPI, un frontend React/Vite y PostgreSQL. Docker Compose es la única infraestructura de ejecución.

El backend separa controladores HTTP, servicios de dominio y persistencia. Las operaciones financieras se representan con una operación raíz y movimientos especializados de cuentas o tarjetas. Los cálculos de saldos, cuotas, intereses, presupuestos y conversiones viven en servicios Python testeables sin interfaz.

Las operaciones relacionadas se ejecutan en una transacción de base de datos. Los recursos financieros siempre se consultan junto con el `user_id` autenticado. Las operaciones confirmadas se conservan para auditoría y se revierten mediante una operación compensatoria.
