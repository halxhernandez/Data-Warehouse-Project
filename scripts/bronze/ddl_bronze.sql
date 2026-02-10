/*
====================================================================================
SCRIPT: Creación de Tablas Bronze Layer – Fuentes CRM y ERP
====================================================================================
Descripción:
    Script para la creación de las tablas correspondientes a la capa Bronze del
    Data Warehouse. Estas tablas almacenan los datos crudos provenientes de
    diferentes sistemas origen (CRM y ERP), sin aplicar reglas de negocio ni
    transformaciones complejas.

Objetivo:
    - Persistir los datos tal como llegan desde las fuentes.
    - Mantener trazabilidad y fidelidad con los sistemas origen.
    - Servir como punto de partida para procesos de limpieza y transformación
      hacia la capa Silver.

Notas:
    - Las tablas no incluyen claves primarias ni restricciones.
    - Los tipos de datos reflejan la estructura original de las fuentes.
    - El script elimina previamente las tablas si existen para garantizar
      ejecuciones idempotentes.
====================================================================================
*/

USE DataWarehouse;
GO

/*------------------------------------------------------------------------------
Tabla: bronze.crm_cust_info
Descripción:
    Almacena información básica de clientes proveniente del sistema CRM.
    Contiene datos demográficos y atributos de identificación del cliente.
------------------------------------------------------------------------------*/
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info (
    cst_id             INT,           -- Identificador interno del cliente
    cst_key            NVARCHAR(50),   -- Clave de negocio del cliente en el CRM
    cst_firstname      NVARCHAR(50),   -- Nombre del cliente
    cst_lastname       NVARCHAR(50),   -- Apellido del cliente
    cst_marital_status NVARCHAR(50),   -- Estado civil
    cst_gndr           NVARCHAR(50),   -- Género
    cst_create_date    DATE            -- Fecha de alta del cliente en el sistema
);
GO

/*------------------------------------------------------------------------------
Tabla: bronze.crm_prd_info
Descripción:
    Contiene el catálogo de productos del sistema CRM, incluyendo costos,
    línea de producto y vigencia temporal.
------------------------------------------------------------------------------*/
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info (
    prd_id       INT,           -- Identificador interno del producto
    prd_key      NVARCHAR(50),   -- Clave de negocio del producto
    prd_nm       NVARCHAR(50),   -- Nombre del producto
    prd_cost     INT,            -- Costo base del producto
    prd_line     NVARCHAR(50),   -- Línea o familia del producto
    prd_start_dt DATETIME,       -- Fecha de inicio de vigencia
    prd_end_dt   DATETIME        -- Fecha de fin de vigencia
);
GO

/*------------------------------------------------------------------------------
Tabla: bronze.crm_sales_details
Descripción:
    Registra el detalle de las transacciones de venta provenientes del CRM.
    Incluye información de pedidos, fechas y métricas de venta.
------------------------------------------------------------------------------*/
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  NVARCHAR(50),   -- Número de orden de venta
    sls_prd_key  NVARCHAR(50),   -- Clave del producto vendido
    sls_cust_id  INT,            -- Identificador del cliente
    sls_order_dt INT,            -- Fecha de orden (formato origen)
    sls_ship_dt  INT,            -- Fecha de envío (formato origen)
    sls_due_dt   INT,            -- Fecha comprometida de entrega
    sls_sales    INT,            -- Importe total de la venta
    sls_quantity INT,            -- Cantidad de unidades vendidas
    sls_price    INT             -- Precio unitario
);
GO

/*------------------------------------------------------------------------------
Tabla: bronze.erp_cust_az12
Descripción:
    Información adicional de clientes proveniente del sistema ERP, utilizada
    para complementar atributos demográficos.
------------------------------------------------------------------------------*/
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12 (
    cid   NVARCHAR(50),   -- Identificador del cliente en el ERP
    bdate DATE,           -- Fecha de nacimiento
    gen   NVARCHAR(50)    -- Género
);
GO

/*------------------------------------------------------------------------------
Tabla: bronze.erp_loc_a101
Descripción:
    Tabla de localización de clientes proveniente del ERP.
------------------------------------------------------------------------------*/
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101 (
    cid   NVARCHAR(50),   -- Identificador del cliente
    cntry NVARCHAR(50)    -- País de residencia
);
GO

/*------------------------------------------------------------------------------
Tabla: bronze.erp_px_cat_g1v2
Descripción:
    Catálogo de clasificación de productos proveniente del ERP, incluyendo
    categoría, subcategoría y tipo de mantenimiento.
------------------------------------------------------------------------------*/
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id          NVARCHAR(50),   -- Identificador del producto
    cat         NVARCHAR(50),   -- Categoría principal
    subcat      NVARCHAR(50),   -- Subcategoría
    maintenance NVARCHAR(50)    -- Tipo de mantenimiento
);
GO
