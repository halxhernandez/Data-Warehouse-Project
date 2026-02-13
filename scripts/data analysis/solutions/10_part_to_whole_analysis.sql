/*
======================================================================================
Análisis De La Parte Al Todo
======================================================================================
Objetivo:
    - Comparar el rendimiento o las métricas entre dimensiones o períodos de tiempo.
    - Evaluar las diferencias entre categorías.
    - Realizar pruebas A/B o comparaciones regionales.

Funciones SQL utilizadas:
    - SUM()
    - AVG()
    - SUM() OVER()
======================================================================================
*/

-- ¿Qué categorías contribuyen más a las ventas totales?

WITH category_sales AS (
    SELECT
        dp.category,
        SUM(fs.sales_amount) AS total_sales
    FROM gold.fact_sales fs
    LEFT JOIN gold.dim_products dp
        ON dp.product_key = fs.product_key
    GROUP BY dp.category
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER ()                                                AS overall_sales,
    ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2) AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;
