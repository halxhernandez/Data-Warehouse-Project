/*
======================================================================================
Análisis De Segmentación De Datos
======================================================================================
Objetivo:
    - Agrupar datos en categorías significativas para obtener información específica.
    - Segmentar clientes y categorizar productos.

Funciones SQL utilizadas:
    - CASE
    - GROUP BY
======================================================================================
*/

/*
Segmentar los productos en rangos de precio y contar cuántos productos pertenecen
a cada segmento:

    - Si el costo es menor a 100 el rango es 'Below 100'
    - Si el costo se encuentra entre 100 y 500 el rango es '100-500'
    - Si el costo se encuentra entre 500 y 1000 el rango es '500-1000'
    - Si el costo es mayor a 1000 el rango es 'Above 1000'
*/

WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)
SELECT
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

/*
Agrupar a los clientes en tres segmentos según su comportamiento de gasto:

    - VIP: Clientes con al menos 12 meses de historial y un gasto superior a 5000
    - Regular: Clientes con al menos 12 meses de historial, pero con un gasto de 500
      o menos
    - New: Clientes con una vida útil inferior a 12 meses

y calcular el número total de clientes de cada grupo
*/

WITH customer_spending AS (
    SELECT
        dc.customer_key,
        SUM(fs.sales_amount)                                    AS total_spending,
        MIN(fs.order_date)                                      AS first_order,
        MAX(fs.order_date)                                      AS last_order,
        DATEDIFF(MONTH, MIN(fs.order_date), MAX(fs.order_date)) AS lifespan
    FROM gold.fact_sales fs
    LEFT JOIN gold.dim_customers dc
        ON dc.customer_key = fs.customer_key
    GROUP BY dc.customer_key
),
segmented_customers AS (
    SELECT
        customer_key,
        CASE
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segments
    FROM customer_spending
)
SELECT
    customer_segments,
    COUNT(customer_key) As total_customers
FROM segmented_customers
GROUP BY customer_segments
ORDER BY total_customers DESC;
