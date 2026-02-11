/*
====================================================================================
CAPA GOLD - MODELO ESTRELLA
====================================================================================
Descripción General:
Este script construye las vistas principales del modelo estrella en la capa Gold:

1) gold.dim_customers  → Dimensión de Clientes
2) gold.dim_products   → Dimensión de Productos
3) gold.fact_sales     → Tabla de Hechos de Ventas

Arquitectura:
Silver (datos limpios e integrados) → Gold (modelo analítico)

Consideraciones Técnicas:
- Las surrogate keys son generadas dinámicamente mediante ROW_NUMBER().
- Se utilizan LEFT JOIN para preservar la integridad de los registros.
- El modelo está diseñado para consumo en herramientas de BI (Power BI).
====================================================================================
*/

------------------------------------------------------------------------------------
-- DIMENSIÓN: CUSTOMERS
------------------------------------------------------------------------------------

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS

SELECT
    -- Surrogate Key dinámica (ordenada por ID de cliente)
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,

    -- Claves de negocio
    ci.cst_id        AS customer_id,
    ci.cst_key       AS customer_number,

    -- Información personal
    ci.cst_firstname AS first_name,
    ci.cst_lastname  AS last_name,

    -- Información geográfica (ERP)
    la.cntry         AS country,

    -- Estado civil
    ci.cst_marital_status AS marital_status,

    -- Regla de prioridad para género:
    -- 1) Usar CRM si no es 'n/a'
    -- 2) Si es 'n/a', usar ERP
    -- 3) Si ambos son NULL, asignar 'n/a'
    CASE
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,

    -- Fecha de nacimiento (ERP)
    ca.bdate AS birthdate,

    -- Fecha de creación del cliente
    ci.cst_create_date AS create_date

FROM silver.crm_cust_info ci

LEFT JOIN silver.erp_loc_a101 la
    ON la.cid = ci.cst_key

LEFT JOIN silver.erp_cust_az12 ca
    ON ca.cid = ci.cst_key;
GO


------------------------------------------------------------------------------------
-- DIMENSIÓN: PRODUCTS
------------------------------------------------------------------------------------

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS

SELECT
    -- Surrogate Key dinámica (ordenada por fecha de inicio y clave)
    ROW_NUMBER() OVER (ORDER BY pi.prd_start_dt, pi.prd_key) AS product_key,

    -- Claves de negocio
    pi.prd_id  AS product_id,
    pi.prd_key AS product_number,

    -- Información descriptiva
    pi.prd_nm  AS product_name,

    -- Información de categoría
    pi.cat_id  AS category_id,
    pc.cat     AS category,
    pc.subcat  AS subcategory,
    pc.maintenance AS maintenance,

    -- Información financiera y operativa
    pi.prd_cost     AS cost,
    pi.prd_line     AS product_line,
    pi.prd_start_dt AS start_date

FROM silver.crm_prd_info pi

LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pc.id = pi.cat_id;
GO


------------------------------------------------------------------------------------
-- FACT TABLE: SALES
------------------------------------------------------------------------------------

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS

SELECT
    -- Clave de negocio de la orden
    sd.sls_ord_num AS order_number,

    -- Surrogate Keys provenientes de dimensiones
    pr.product_key  AS product_key,
    cu.customer_key AS customer_key,

    -- Fechas del proceso de venta
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,

    -- Métricas cuantitativas
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price

FROM silver.crm_sales_details sd

LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number

LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;
GO


/*
====================================================================================
FIN DEL SCRIPT - CAPA GOLD
====================================================================================
Resultado:
- Modelo estrella listo para consumo analítico.
- Dimensiones relacionadas mediante surrogate keys.
- Fact table con granularidad por línea de venta.

Recomendación Profesional:
En entornos productivos, las surrogate keys deberían generarse en tablas físicas
durante el proceso ETL para garantizar estabilidad y rendimiento.
====================================================================================
*/
