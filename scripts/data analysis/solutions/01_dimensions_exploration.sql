/*
======================================================================================
Exploración De Dimensiones
======================================================================================
Objetivo:
    - Explorar la estructura de las tablas de dimensiones.

Funciones SQL utilizadas:
    - DISTINCT
    - ORDER BY
======================================================================================
*/

-- Obtener una lista de países únicos de origen de los clientes

SELECT
    DISTINCT country
FROM gold.dim_customers
ORDER BY country;

-- Obtener una lista de categorías, subcategorías y productos únicos

SELECT DISTINCT
    category,
    subcategory,
    product_name
FROM gold.dim_products
ORDER BY
    category,
    subcategory,
    product_name;
