/*
====================================================================================
SCRIPT: Creación de Tablas Silver Layer – Fuentes CRM y ERP
====================================================================================
Descripción:
    Script para la creación de las tablas correspondientes a la capa Silver del
    Data Warehouse. Esta capa contiene datos provenientes de la capa Bronze
    que han sido limpiados, estandarizados y preparados para su consumo
    analítico o posterior modelado dimensional.

Objetivo:
    - Aplicar un primer nivel de calidad y consistencia a los datos.
    - Estandarizar estructuras y tipos de datos.
    - Incorporar metadatos de auditoría para trazabilidad.
    - Servir como base confiable para la capa Gold.

Notas:
    - Las tablas no implementan relaciones físicas ni constraints.
    - Se agrega la columna dwh_create_date para control de carga.
    - El script elimina previamente las tablas si existen para permitir
      ejecuciones controladas y repetibles.
====================================================================================
*/

USE DataWarehouse;
GO

/*------------------------------------------------------------------------------
Tabla: silver.crm_cust_info
Descripción:
    Tabla de clientes depurada proveniente del CRM. Contiene información
    demográfica estandarizada y lista para análisis.
------------------------------------------------------------------------------*/
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info (
    cst_id             INT,            -- Identificador interno del cliente
    cst_key            NVARCHAR(50),    -- Clave de negocio del cliente
    cst_firstname      NVARCHAR(50),    -- Nombre del cliente
    cst_lastname       NVARCHAR(50),    -- Apellido del cliente
    cst_marital_status NVARCHAR(50),    -- Estado civil normalizado
    cst_gndr           NVARCHAR(50),    -- Género estandarizado
    cst_create_date    DATE,            -- Fecha de alta del cliente
    dwh_create_date    DATETIME2
        DEFAULT GETDATE()               -- Fecha de carga en el Data Warehouse
);
GO

/*------------------------------------------------------------------------------
Tabla: silver.crm_prd_info
Descripción:
    Catálogo de productos del CRM con atributos normalizados y control de
    vigencia temporal.
------------------------------------------------------------------------------*/
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id          INT,             -- Identificador interno del producto
    cat_id          NVARCHAR(50),    -- Identificador interno de la categoría
    prd_key         NVARCHAR(50),    -- Clave de negocio del producto
    prd_nm          NVARCHAR(50),    -- Nombre del producto
    prd_cost        INT,             -- Costo base
    prd_line        NVARCHAR(50),    -- Línea o familia del producto
    prd_start_dt    DATETIME,        -- Inicio de vigencia
    prd_end_dt      DATETIME,        -- Fin de vigencia
    dwh_create_date DATETIME2
        DEFAULT GETDATE()            -- Fecha de carga en Silver
);
GO

/*------------------------------------------------------------------------------
Tabla: silver.crm_sales_details
Descripción:
    Tabla de hechos transaccionales depurados del CRM. Registra información
    de ventas a nivel de detalle, preparada para agregaciones analíticas.
------------------------------------------------------------------------------*/
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num     NVARCHAR(50),    -- Número de orden
    sls_prd_key     NVARCHAR(50),    -- Clave del producto
    sls_cust_id     INT,             -- Identificador del cliente
    sls_order_dt    INT,             -- Fecha de orden (pendiente de conversión)
    sls_ship_dt     INT,             -- Fecha de envío
    sls_due_dt      INT,             -- Fecha comprometida
    sls_sales       INT,             -- Importe de la venta
    sls_quantity    INT,             -- Unidades vendidas
    sls_price       INT,             -- Precio unitario
    dwh_create_date DATETIME2
        DEFAULT GETDATE()            -- Fecha de carga en Silver
);
GO

/*------------------------------------------------------------------------------
Tabla: silver.erp_cust_az12
Descripción:
    Información demográfica complementaria del cliente proveniente del ERP,
    integrada para enriquecer el análisis de clientes.
------------------------------------------------------------------------------*/
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
    cid             NVARCHAR(50),    -- Identificador del cliente
    bdate           DATE,            -- Fecha de nacimiento
    gen             NVARCHAR(50),    -- Género
    dwh_create_date DATETIME2
        DEFAULT GETDATE()            -- Fecha de carga en Silver
);
GO

/*------------------------------------------------------------------------------
Tabla: silver.erp_loc_a101
Descripción:
    Tabla de localización de clientes normalizada a partir del sistema ERP.
------------------------------------------------------------------------------*/
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
    cid             NVARCHAR(50),    -- Identificador del cliente
    cntry           NVARCHAR(50),    -- País de residencia
    dwh_create_date DATETIME2
        DEFAULT GETDATE()            -- Fecha de carga en Silver
);
GO

/*------------------------------------------------------------------------------
Tabla: silver.erp_px_cat_g1v2
Descripción:
    Catálogo maestro de clasificación de productos proveniente del ERP,
    utilizado para análisis por categoría y subcategoría.
------------------------------------------------------------------------------*/
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id              NVARCHAR(50),    -- Identificador del producto
    cat             NVARCHAR(50),    -- Categoría principal
    subcat          NVARCHAR(50),    -- Subcategoría
    maintenance     NVARCHAR(50),    -- Tipo de mantenimiento
    dwh_create_date DATETIME2
        DEFAULT GETDATE()            -- Fecha de carga en Silver
);
GO
