/*
======================================================================================
Análisis De Cambios A Lo Largo Del Tiempo
======================================================================================
Objetivo:
    - Para rastrear tendencias, crecimiento y cambios en métricas clave.
    - Para análisis de series temporales e identificación de estacionalidad.
    - Para medir el crecimiento o la disminución en períodos específicos.

Funciones SQL utilizadas:
    - Funciones de fecha: DATEPART(), DATETRUNC(), FORMAT()
    - Funciones de agregación: SUM(), COUNT(), AVG()
======================================================================================
*/

-- Analizar el rendimiento de las ventas a lo largo del tiempo

-- Funciones de fecha rápida
SELECT
    YEAR(order_date)             AS order_year,
    MONTH(order_date)            AS order_month,
    SUM(sales_amount)            AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity)                AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    YEAR(order_date),
    MONTH(order_date);

-- DATETRUNC()
SELECT
    DATETRUNC(MONTH, order_date) AS order_date,
    SUM(sales_amount)            AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity)                AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date);

-- FORMAT()
SELECT
    FORMAT(order_date, 'yyyy-MMM') AS order_date,
    SUM(sales_amount)              AS total_sales,
    COUNT(DISTINCT customer_key)   AS total_customers,
    SUM(quantity)                  AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM');
