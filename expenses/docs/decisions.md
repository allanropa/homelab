# Decisiones de producto y finanzas

## Reglas confirmadas

- Interés fijo mensual plano por cuota.
- Fórmula: `principal / cuotas + principal total * tasa mensual`.
- Las compras con varias cuotas incluyen interés desde la primera cuota.
- Las compras de una sola cuota no generan interés estimado.
- El consumo completo se registra en la fecha de compra; las cuotas no duplican consumo.
- Una compra realizada el día de corte pertenece al ciclo siguiente.
- En meses más cortos, el día de corte se ajusta al último día disponible.
- El MVP no calcula fecha de vencimiento de tarjeta.
- Cada presupuesto tiene una moneda explícita y solo consume operaciones en esa moneda.
- Presupuestos máximos y acumulativos definen si son de débito o crédito.
- Intereses y comisiones son gastos de crédito.
- Las operaciones confirmadas se anulan mediante reversión en lugar de borrarse físicamente.
- Se permiten saldos negativos en cuentas.

## Convenciones técnicas

- Monedas soportadas inicialmente: COP y USD.
- Zona horaria predeterminada: `America/Bogota`.
- Los montos monetarios se almacenarán como `NUMERIC` en PostgreSQL.
- Las tasas de cambio y de interés tendrán mayor precisión que los montos monetarios.
- Las tasas de cambio serán ingresadas manualmente; no se integra ningún proveedor externo en el MVP.
- Los préstamos recibidos usan tasa efectiva anual fija, cuotas mensuales francesas y permiten abonos extraordinarios a capital.
- El desembolso de un préstamo puede registrarse como ingreso o solo como obligación ya existente.
- Los saldos editables se implementan como ajustes auditables, nunca sobrescribiendo movimientos históricos.
