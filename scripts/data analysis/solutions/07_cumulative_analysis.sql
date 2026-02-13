/*
======================================================================================
Análisis Acumulativo
======================================================================================
Objetivo:
    - Calcular totales acumulados o promedios móviles para métricas clave.
    - Realizar un seguimiento acumulativo del rendimiento a lo largo del tiempo.

Funciones SQL utilizadas:
    - Funciones de ventana: SUM() OVER(), AVG() OVER()
======================================================================================
*/

-- Calcular las ventas totales mensuales y el total acumulado de ventas
-- lo largo del tiempo

SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_date,
        SUM(sales_amount)            AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
) t;

-- Con CTE
WITH sales_per_month AS (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_date,
        SUM(sales_amount)            AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
)
SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM sales_per_month;
