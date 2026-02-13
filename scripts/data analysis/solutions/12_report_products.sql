/*
======================================================================================
Reporte De Productos
======================================================================================
Objetivo:
    - Este reporte consolida métricas clave y comportamientos de los productos.

Aspectos Destacados:
    1. Recopila campos esenciales como nombre del producto, categoría, subcategoría y
       costo.
    2. Segmenta los productos por nivel de ingresos para identificar Alto Rendimiento,
       Rendimiento Medio o Bajo Rendimiento.
    3. Agrega métricas a nivel producto:
       - total de órdenes
       - total de ventas
       - cantidad total vendida
       - total de clientes (únicos)
       - tiempo de vida (en meses)
    4. Calcula KPIs valiosos:
       - recencia (meses desde la última venta)
       - ingreso promedio por orden (AOR)
       - ingreso mensual promedio
======================================================================================
*/

-- =============================================================================
-- Crear Reporte: gold.report_products
-- =============================================================================
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
   DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Consulta Base: Recupera las columnas principales de fact_sales y dim_products
---------------------------------------------------------------------------*/
SELECT
   fs.order_number,
   fs.order_date,
   fs.customer_key,
   fs.sales_amount,
   fs.quantity,
   dp.product_key,
   dp.product_name,
   dp.category,
   dp.subcategory,
   dp.cost
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
   ON fs.product_key = dp.product_key
WHERE order_date IS NOT NULL  -- solo considerar fechas de venta válidas
),

product_aggregations AS (
/*---------------------------------------------------------------------------
2) Agregaciones de Producto: Resume métricas clave a nivel de producto
---------------------------------------------------------------------------*/
SELECT
   product_key,
   product_name,
   category,
   subcategory,
   cost,
   DATEDIFF(MONTH, MIN(order_date), MAX(order_date))               AS lifespan,
   MAX(order_date)                                                 AS last_sale_date,
   COUNT(DISTINCT order_number)                                    AS total_orders,
   COUNT(DISTINCT customer_key)                                    AS total_customers,
   SUM(sales_amount)                                               AS total_sales,
   SUM(quantity)                                                   AS total_quantity,
   ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM base_query
GROUP BY
   product_key,
   product_name,
   category,
   subcategory,
   cost
)

/*---------------------------------------------------------------------------
3) Consulta Final: Combina todos los resultados de producto en una sola salida
---------------------------------------------------------------------------*/
SELECT
   product_key,
   product_name,
   category,
   subcategory,
   cost,
   last_sale_date,
   DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
   CASE
      WHEN total_sales > 50000 THEN 'High-Performer'
      WHEN total_sales >= 10000 THEN 'Mid-Range'
      ELSE 'Low-Performer'
   END                                        AS product_segment,
   lifespan,
   total_orders,
   total_sales,
   total_quantity,
   total_customers,
   avg_selling_price,

   -- Ingreso Promedio por Orden (AOR)
   CASE
      WHEN total_orders = 0 THEN 0
      ELSE total_sales / total_orders
   END                                        AS avg_order_revenue,

   -- Ingreso Promedio Mensual
   CASE
      WHEN lifespan = 0 THEN total_sales
      ELSE total_sales / lifespan
   END                                        AS avg_monthly_revenue

FROM product_aggregations
