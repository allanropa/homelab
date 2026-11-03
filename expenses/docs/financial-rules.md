# Reglas financieras implementadas

## Monedas y redondeo

- Solo se aceptan COP y USD en el MVP.
- COP se redondea a pesos enteros y USD a centavos usando `ROUND_HALF_UP`.
- Cada saldo y deuda conserva su moneda original.
- Las tasas mensuales de tarjeta se almacenan con hasta 12 decimales en formato fracción; la interfaz acepta hasta 8 decimales porcentuales.
- Cada compra de tarjeta conserva una copia inmutable de la tasa mensual y método aplicables en su fecha de registro.
- Una conversión siempre conserva monto origen, monto destino y tasa ingresada.

## Cuentas y consumo

- Un ingreso aumenta el movimiento de una cuenta.
- Un gasto de débito reduce el movimiento de una cuenta.
- Una compra de tarjeta crea un consumo y un movimiento de deuda, pero no reduce una cuenta.
- Un pago de tarjeta reduce deuda y, si tiene cuenta origen, reduce esa cuenta; nunca crea consumo.
- Una transferencia crea una salida y una entrada, sin consumo.
- Operaciones confirmadas se revierten; no se eliminan físicamente.

## Cuotas e interés

Para una compra de varias cuotas:

```text
principal_por_cuota = principal_total / cantidad_de_cuotas
interes_por_cuota = principal_total * tasa_mensual
cuota = principal_por_cuota + interes_por_cuota
```

La primera cuota incluye interés. Una compra de una sola cuota no genera interés estimado. La diferencia de redondeo del principal se asigna a la última cuota.

El principal crea deuda real al registrar la compra. El interés de la cuota es una estimación y solo se convierte en deuda cuando se registra el cargo real del banco.

## Corte de tarjeta

- El cálculo utiliza únicamente día de corte; el MVP no calcula vencimiento.
- Si la compra ocurre antes del día de corte, pertenece al corte del mes actual.
- Si ocurre el mismo día o después del corte, pertenece al siguiente corte.
- Un día de corte inexistente se ajusta al último día del mes.

## Presupuestos

- Cada presupuesto tiene una sola moneda.
- Solo cuentan transacciones en la misma moneda; no se convierten automáticamente.
- `debit` cuenta gastos pagados desde cuentas o efectivo.
- `credit` cuenta compras, intereses y cargos de tarjeta en la fecha de consumo.
- Los pagos de tarjeta no vuelven a consumir un presupuesto.
- Los presupuestos no bloquean operaciones.

## Préstamos recibidos

- Los préstamos registrados son obligaciones recibidas por el usuario.
- La tasa ingresada es efectiva anual y queda fija durante el plazo.
- La tasa mensual se calcula como `(1 + tasa_anual)^(1/12) - 1`.
- Las cuotas son mensuales fijas con amortización francesa.
- El usuario decide si el desembolso se registra como ingreso; un préstamo ya gastado puede registrarse sin ingreso.
- El interés pagado se registra como gasto y el capital pagado reduce la deuda.
- Los abonos extraordinarios reducen el capital pendiente y se registran por separado.

## Ajustes de saldos

- Editar un saldo no modifica el saldo inicial ni movimientos anteriores.
- Se calcula la diferencia y se registra una operación independiente de ajuste.
- Los ajustes de cuentas no son ingresos, gastos ni consumo presupuestario.
- Los ajustes de deuda de tarjeta se registran por moneda y tampoco son consumo.
