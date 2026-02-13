/*
======================================================================================
Análisis De Magnitud
======================================================================================
Objetivo:
    - Cuantificar los datos y agrupar los resultados por dimensiones específicas.
    - Comprender la distribución de los datos en las distintas categorías.

Funciones SQL utilizadas:
    - Funciones de agregación: SUM(), COUNT(), AVG()
    - GROUP BY
    - ORDER BY
======================================================================================
*/

-- Encontrar el total de clientes por país

SELECT
    country,
    COUNT(customer_id) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Encontrar el total de clientes por género

SELECT
    gender,
    COUNT(customer_id) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Encontrar el total de productos por categoría

SELECT
    category,
    COUNT(product_id) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- ¿Cuáles son los costos promedio en cada categoría?

SELECT
    category,
    AVG(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- ¿Cuáles son los ingresos totales generados por cada categoría?

SELECT
    dp.category,
    SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
    ON dp.product_id = fs.product_key
GROUP BY dp.category
ORDER BY total_revenue DESC;

-- ¿Cuáles son los ingresos totales generados por cada cliente?

SELECT
    dc.customer_key,
    dc.first_name,
    dc.last_name,
    SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
    ON dc.customer_id = fs.customer_key
GROUP BY
    dc.customer_key,
    dc.first_name,
    dc.last_name
ORDER BY total_revenue DESC;

-- ¿Cuál es la distribución de los artículos vendidos por país?

SELECT
    dc.country,
    SUM(fs.quantity) AS items_sold
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
    ON dc.customer_id = fs.customer_key
GROUP BY dc.country
ORDER BY items_sold DESC;
