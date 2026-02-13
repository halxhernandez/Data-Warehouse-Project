/*
======================================================================================
Análisis De Rendimiento
======================================================================================
Objetivo:
    - Medir el rendimiento de productos, clientes o regiones a lo largo del tiempo.
    - Realizar evaluaciones comparativas e identificar entidades de alto rendimiento.
    - Realizar seguimientos de las tendencias y crecimientos anuales.

Funciones SQL utilizadas:
    - Funciones de ventana: LAG() OVER(), AVG() OVER()
    - CASE
======================================================================================
*/

-- Analizar el rendimiento anual de los productos comparando sus ventas con el
-- rendimiento promedio de ventas del producto y las ventas del año anterior.

WITH yearly_product_sales AS (
    SELECT
        YEAR(fs.order_date)  AS order_year,
        dp.product_name,
        SUM(fs.sales_amount) AS current_sales
    FROM gold.fact_sales fs
    LEFT JOIN gold.dim_products dp
        ON fs.product_key = dp.product_key
    WHERE fs.order_date IS NOT NULL
    GROUP BY
        YEAR(fs.order_date),
        dp.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    -- Análisis interanual
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;
