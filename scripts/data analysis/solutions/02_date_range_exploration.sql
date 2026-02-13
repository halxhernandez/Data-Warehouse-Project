/*
======================================================================================
Exploración Del Rango De Fechas
======================================================================================
Objetivo:
    - Determinar los límites temporales de los puntos de datos clave.
    - Comprender el rango de datos históricos.

Funciones SQL utilizadas:
    - MIN()
    - MAX()
    - DATEDIFF()
======================================================================================
*/

-- Determinar la fecha del primer y último pedido, así como su duración total en meses

SELECT
    MIN(order_date)                                   AS first_order_date,
    MAX(order_date)                                   AS last_order_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;

-- Encontrar el cliente más joven y el más mayor según su fecha de nacimiento

SELECT
    MIN(birthdate)                            AS oldest_birthdate,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
    MAX(birthdate)                            AS youngest_birthdate,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS oldest_age
FROM gold.dim_customers;
