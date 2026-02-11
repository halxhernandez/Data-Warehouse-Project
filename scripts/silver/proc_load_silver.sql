/*
====================================================================================
PROCEDIMIENTO ALMACENADO: silver.load_silver
====================================================================================
Descripción:
    Procedimiento encargado de transformar y depurar los datos provenientes
    de la capa Bronze hacia la capa Silver del Data Warehouse.

    En esta etapa se aplican:
        - Reglas de limpieza
        - Normalización de valores categóricos
        - Corrección de inconsistencias
        - Eliminación de duplicados
        - Conversión de tipos de datos
        - Validaciones básicas de calidad

Objetivo:
    - Garantizar datos consistentes y confiables.
    - Preparar información estructurada para la capa Gold.
    - Incorporar lógica técnica sin aplicar aún reglas de negocio complejas.

Notas:
    - El proceso es full refresh (TRUNCATE + INSERT).
    - Se registra duración por tabla y duración total del lote.
====================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN

    -------------------------------------------------------------------------------
    -- Declaración de variables para control de tiempos de ejecución
    -------------------------------------------------------------------------------
    DECLARE @start_time DATETIME,
            @end_time DATETIME,
            @batch_start_time DATETIME,
            @batch_end_time DATETIME;

    BEGIN TRY

        ---------------------------------------------------------------------------
        -- Inicio del proceso general de carga
        ---------------------------------------------------------------------------
        SET @batch_start_time = GETDATE();

        PRINT '================================================';
        PRINT 'Cargando Capa Silver';
        PRINT '================================================';

        PRINT '------------------------------------------------';
        PRINT 'Cargando Tablas CRM';
        PRINT '------------------------------------------------';

        ---------------------------------------------------------------------------
        -- Carga de tabla: silver.crm_cust_info
        -- Objetivo:
        --  • Eliminar duplicados conservando el registro más reciente
        --  • Estandarizar valores categóricos
        --  • Limpiar espacios en blanco
        ---------------------------------------------------------------------------
        SET @start_time = GETDATE();

        PRINT '>> Truncando Tabla: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Insertando Datos En: silver.crm_cust_info';

        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname, -- Eliminación de espacios innecesarios
            TRIM(cst_lastname) AS cst_lastname,
            CASE
                -- Normalización del estado civil
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END AS cst_marital_status,
            CASE
                -- Normalización del género
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END AS cst_gndr,
            cst_create_date
        FROM (
            -- Eliminación de duplicados conservando el registro más reciente
            SELECT *,
                   ROW_NUMBER() OVER (
                       PARTITION BY cst_id
                       ORDER BY cst_create_date DESC
                   ) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flag_last = 1;

        SET @end_time = GETDATE();
        PRINT '>> Duración De Carga: ' +
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';
        PRINT '>> -------------';

        ---------------------------------------------------------------------------
        -- Carga de tabla: silver.crm_prd_info
        -- Objetivo:
        --  • Separar claves compuestas
        --  • Normalizar líneas de producto
        --  • Calcular fechas de vigencia (SCD Tipo 2 simplificado)
        ---------------------------------------------------------------------------
        SET @start_time = GETDATE();

        PRINT '>> Truncando Tabla: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT '>> Insertando Datos En: silver.crm_prd_info';

        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Extracción de categoría
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,        -- Extracción de clave producto
            prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost,                       -- Control de valores nulos
            CASE
                -- Normalización de línea de producto
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,
            CAST(prd_start_dt AS DATE) AS prd_start_dt,
            -- Cálculo de fecha fin como el día anterior al siguiente registro
            CAST(
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt
                ) - 1 AS DATE
            ) AS prd_end_dt
        FROM bronze.crm_prd_info;

        SET @end_time = GETDATE();
        PRINT '>> Duración De Carga: ' +
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';
        PRINT '>> -------------';

        ---------------------------------------------------------------------------
        -- Carga de tabla: silver.crm_sales_details
        -- Objetivo:
        --  • Validar y convertir fechas
        --  • Recalcular métricas inconsistentes
        --  • Garantizar integridad aritmética
        ---------------------------------------------------------------------------
        SET @start_time = GETDATE();

        PRINT '>> Truncando Tabla: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT '>> Insertando Datos En: silver.crm_sales_details';

        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            -- Conversión segura de fechas en formato YYYYMMDD
            CASE
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END,
            CASE
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END,
            CASE
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END,

            -- Recalcular ventas si el valor original es inválido
            CASE
                WHEN sls_sales IS NULL
                     OR sls_sales <= 0
                     OR sls_sales != sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales,

            sls_quantity,

            -- Derivar precio si es inválido o nulo
            CASE
                WHEN sls_price IS NULL OR sls_price <= 0
                THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END AS sls_price

        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();
        PRINT '>> Duración De Carga: ' +
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';
        PRINT '>> -------------';

        PRINT '------------------------------------------------';
        PRINT 'Cargando Tablas ERP';
        PRINT '------------------------------------------------';

        ---------------------------------------------------------------------------
        -- Carga de tabla: silver.erp_cust_az12
        -- Objetivo:
        --  • Limpiar identificadores de cliente
        --  • Validar fechas de nacimiento
        --  • Normalizar valores de género
        ---------------------------------------------------------------------------
        SET @start_time = GETDATE();

        PRINT '>> Truncando Tabla: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT '>> Insertando Datos En: silver.erp_cust_az12';

        INSERT INTO silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        SELECT
            -- Eliminación del prefijo 'NAS' en caso de existir
            CASE
                WHEN cid LIKE 'NAS%'
                    THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END AS cid,

            -- Validación de fechas futuras
            CASE
                WHEN bdate > GETDATE() THEN NULL
                ELSE bdate
            END AS bdate,

            -- Normalización del género
            CASE
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'n/a'
            END AS gen

        FROM bronze.erp_cust_az12;

        SET @end_time = GETDATE();
        PRINT '>> Duración De Carga: ' +
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';
        PRINT '>> -------------';

        ---------------------------------------------------------------------------
        -- Carga de tabla: silver.erp_loc_a101
        -- Objetivo:
        --  • Estandarizar identificadores
        --  • Normalizar códigos de país
        --  • Controlar valores nulos o vacíos
        ---------------------------------------------------------------------------
        SET @start_time = GETDATE();

        PRINT '>> Truncando Tabla: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT '>> Insertando Datos En: silver.erp_loc_a101';

        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT
            -- Eliminación de guiones en el identificador
            REPLACE(cid, '-', '') AS cid,

            -- Normalización de códigos de país
            CASE
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
                WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
                ELSE TRIM(cntry)
            END AS cntry

        FROM bronze.erp_loc_a101;

        SET @end_time = GETDATE();
        PRINT '>> Duración De Carga: ' +
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';
        PRINT '>> -------------';

        ---------------------------------------------------------------------------
        -- Carga de tabla: silver.erp_px_cat_g1v2
        -- Objetivo:
        --  • Transferencia estructurada de categorías y subcategorías
        --  • Mantener consistencia para futuras relaciones dimensionales
        ---------------------------------------------------------------------------
        SET @start_time = GETDATE();

        PRINT '>> Truncando Tabla: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT '>> Insertando Datos En: silver.erp_px_cat_g1v2';

        INSERT INTO silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            id,
            cat,
            subcat,
            maintenance
        FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();
        PRINT '>> Duración De Carga: ' +
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';
        PRINT '>> -------------';

        ---------------------------------------------------------------------------
        -- Finalización del proceso general
        ---------------------------------------------------------------------------
        SET @batch_end_time = GETDATE();

        PRINT '==========================================';
        PRINT 'Carga En la Capa Silver Completada ';
        PRINT 'Duración Total De Carga: ' +
              CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR)
              + ' segundos';
        PRINT '==========================================';

    END TRY

    -------------------------------------------------------------------------------
    -- Manejo de errores
    -------------------------------------------------------------------------------
    BEGIN CATCH
        PRINT '===================================================';
        PRINT 'ERROR OCURRIDO DURANTE LA CARGA DE LA CAPA SILVER';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Número: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Estado: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '===================================================';
    END CATCH

END;
