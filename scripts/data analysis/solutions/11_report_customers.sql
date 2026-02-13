/*
======================================================================================
Reporte De Clientes
======================================================================================
Objetivo:
    - Este reporte consolida métricas clave y comportamientos de los clientes.

Aspectos Destacados:
    1. Recopila campos esenciales como nombres, edades y detalles de transacciones.
    2. Segmenta a los clientes en categorías (VIP, Regular, New) y en grupos de edad.
    3. Agrega métricas a nivel cliente:
       - total de órdenes
       - total de ventas
       - cantidad total comprada
       - total de productos
       - tiempo de relación (en meses)
    4. Calcula KPIs valiosos:
       - recencia (meses desde la última orden)
       - valor promedio por orden
       - gasto mensual promedio
======================================================================================
*/

-- =============================================================================
-- Crear Reporte: gold.report_customers
-- =============================================================================
IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS

WITH base_query AS(
/*---------------------------------------------------------------------------
1) Consulta Base: Recupera columnas principales de las tablas
---------------------------------------------------------------------------*/
    SELECT
    fs.order_number,
    fs.product_key,
    fs.order_date,
    fs.sales_amount,
    fs.quantity,
    dc.customer_key,
    dc.customer_number,
    CONCAT(dc.first_name, ' ', dc.last_name) AS customer_name,
    DATEDIFF(year, dc.birthdate, GETDATE()) age
    FROM gold.fact_sales fs
    LEFT JOIN gold.dim_customers dc
    ON dc.customer_key = fs.customer_key
    WHERE order_date IS NOT NULL)

, customer_aggregation AS (
/*---------------------------------------------------------------------------
2) Agregaciones De Clientes: Resume las métricas clave a nivel de cliente
---------------------------------------------------------------------------*/
    SELECT
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number)                      AS total_orders,
        SUM(sales_amount)                                 AS total_sales,
        SUM(quantity)                                     AS total_quantity,
        COUNT(DISTINCT product_key)                       AS total_products,
        MAX(order_date)                                   AS last_order_date,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY
        customer_key,
        customer_number,
        customer_name,
        age
)
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE
        WHEN age < 20 THEN 'Under 20'
        WHEN age between 20 and 29 THEN '20-29'
        WHEN age between 30 and 39 THEN '30-39'
        WHEN age between 40 and 49 THEN '40-49'
        ELSE '50 and above'
    END                                         AS age_group,
    CASE
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END                                         AS customer_segment,
    last_order_date,
    DATEDIFF(month, last_order_date, GETDATE()) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products
    lifespan,
    -- Calcular el valor promedio del pedido (AOV)
    CASE
        WHEN total_sales = 0 THEN 0
        ELSE total_sales / total_orders
    END                                         AS avg_order_value,
    -- Calcular el gasto mensual promedio
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END                                         AS avg_monthly_spend
FROM customer_aggregation
