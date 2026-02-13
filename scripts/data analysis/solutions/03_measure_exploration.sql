/*
======================================================================================
Exploración De Medidas (Métricas Clave)
======================================================================================
Objetivo:
    - Calcular métricas agregadas (p. ej., totales, promedios) para obtener
      información rápida.
    - Identificar tendencias generales o detectar anomalías.

Funciones SQL utilizadas:
    - COUNT()
    - SUM()
    - AVG()
======================================================================================
*/

-- Calcular las ventas totales

SELECT
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales;

-- Calcular cuántos artículos se han vendido

SELECT
    SUM(quantity) AS items_sold
FROM gold.fact_sales;

-- Calcular el precio medio de venta

SELECT
    AVG(price) AS avg_price
FROM gold.fact_sales;

-- Calcular el número total de ordenes

SELECT
    COUNT(order_number) AS total_orders
FROM gold.fact_sales;

SELECT
    COUNT(DISTINCT order_number) AS total_unique_orders
FROM gold.fact_sales;

-- Calcular el número total de productos

SELECT
    COUNT(product_id) AS total_products
FROM gold.dim_products;

-- Calcular el número total de clientes

SELECT
    COUNT(customer_id) AS total_customers
FROM gold.dim_customers;

-- Calcular el número total de clientes que han realizado pedidos

SELECT
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales;

-- Generar un informe que muestre todas las métricas clave del negocio

SELECT
    'Total Sales'     AS measure_name,
    SUM(sales_amount) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT
    'Items Sold'  AS measure_name,
    SUM(quantity) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT
    'Average Price' AS measure_name,
    AVG(price)      AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT
    'Total Orders'               AS measure_name,
    COUNT(DISTINCT order_number) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT
    'Total Customers'  AS measure_name,
    COUNT(customer_id) AS measure_value
FROM gold.dim_customers

UNION ALL

SELECT
    'Total Products'  AS measure_name,
    COUNT(product_id) AS measure_value
FROM gold.dim_products;
