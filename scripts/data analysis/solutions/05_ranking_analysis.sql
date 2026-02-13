/*
======================================================================================
Análisis De Clasificación
======================================================================================
Objetivo:
    - Clasificar elementos (p. ej., productos, clientes) según su rendimiento u otras
      métricas.
    - Identificar a los de mejor o peor rendimiento.

Funciones SQL utilizadas:
    - Funciones de clasificación: RANK(), TOP
    - GROUP BY
    - ORDER BY
======================================================================================
*/

-- ¿Cuáles son los 5 productos que generan mayores ingresos?

-- Clasificación simple
SELECT TOP 5
    dp.product_name,
    SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
    ON dp.product_key= fs.product_key
GROUP BY dp.product_name
ORDER BY total_revenue DESC;

-- Clasificación compleja pero flexible mediante funciones de ventana

SELECT *
FROM (
    SELECT
        dp.product_name,
        SUM(fs.sales_amount)                            AS total_revenue,
        RANK() OVER(ORDER BY SUM(fs.sales_amount) DESC) AS rank_products
    FROM gold.fact_sales fs
    LEFT JOIN gold.dim_products dp
        ON dp.product_key= fs.product_key
    GROUP BY dp.product_name
) t
WHERE rank_products <= 5
ORDER BY rank_products;

-- ¿Cuáles son los 5 productos con peor rendimiento en ventas?

SELECT TOP 5
    dp.product_name,
    SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
    ON dp.product_key = fs.product_key
GROUP BY dp.product_name
ORDER BY total_revenue;

-- Encuentra a los 10 clientes que han generado mayores ingresos

SELECT TOP 10
    dc.customer_key,
    dc.first_name,
    dc.last_name,
    SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
    ON dc.customer_key= fs.customer_key
GROUP BY
    dc.customer_key,
    dc.first_name,
    dc.last_name
ORDER BY total_revenue DESC;

-- ¿Cuáles son los 3 clientes con menos pedidos?

SELECT TOP 3
    dc.customer_key,
    dc.first_name,
    dc.last_name,
    COUNT(DISTINCT fs.order_number) AS total_orders
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
    ON dc.customer_key= fs.customer_key
GROUP BY
    dc.customer_key,
    dc.first_name,
    dc.last_name
ORDER BY total_orders;
