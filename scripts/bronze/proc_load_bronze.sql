/*
====================================================================================
PROCEDIMIENTO ALMACENADO: bronze.load_bronze
====================================================================================
Descripción:
    Procedimiento encargado de la carga de datos hacia la capa Bronze del
    Data Warehouse. Los datos se cargan directamente desde archivos planos
    (CSV) provenientes de los sistemas origen CRM y ERP.

Objetivo:
    - Automatizar la ingesta de datos crudos.
    - Garantizar cargas repetibles mediante truncado previo de tablas.
    - Registrar tiempos de ejecución por tabla y por lote completo.
    - Centralizar el control de errores durante el proceso de carga.

Notas:
    - Este procedimiento no aplica transformaciones ni reglas de negocio.
    - La capa Bronze preserva la estructura original de los datos.
    - Requiere permisos para ejecutar BULK INSERT y acceso a las rutas físicas.
====================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    /*--------------------------------------------------------------------------
    Declaración de variables para control de tiempos
    --------------------------------------------------------------------------*/
    DECLARE
        @start_time DATETIME,
        @end_time DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time DATETIME;

    BEGIN TRY
        /*----------------------------------------------------------------------
        Inicio del proceso de carga completo
        ----------------------------------------------------------------------*/
        SET @batch_start_time = GETDATE();

        PRINT '========================================================';
        PRINT 'Cargando Capa Bronze';
        PRINT '========================================================';

        /*----------------------------------------------------------------------
        Carga de tablas provenientes del sistema CRM
        ----------------------------------------------------------------------*/
        PRINT '--------------------------------------------------------';
        PRINT 'Cargando Tablas CRM';
        PRINT '--------------------------------------------------------';

        /*---------------------- bronze.crm_cust_info --------------------------*/
        SET @start_time = GETDATE();
        PRINT '>> Truncando Tabla: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Cargando Datos En: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\thinkpad\Projects\Data-Warehouse-Project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,              -- Omite encabezados
            FIELDTERMINATOR = ',',     -- Separador de columnas
            TABLOCK                    -- Optimiza carga masiva
        );

        SET @end_time = GETDATE();
        PRINT '>> Duración De Carga: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR)
              + ' segundos';
        PRINT '----------------------------';

        /*---------------------- bronze.crm_prd_info ---------------------------*/
        SET @start_time = GETDATE();
        PRINT '>> Truncando Tabla: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Cargando Datos En: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\thinkpad\Projects\Data-Warehouse-Project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Duración De Carga: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR)
              + ' segundos';
        PRINT '----------------------------';

        /*------------------ bronze.crm_sales_details --------------------------*/
        SET @start_time = GETDATE();
        PRINT '>> Truncando Tabla: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Cargando Datos En: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\thinkpad\Projects\Data-Warehouse-Project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Duración De Carga: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR)
              + ' segundos';
        PRINT '----------------------------';

        /*----------------------------------------------------------------------
        Carga de tablas provenientes del sistema ERP
        ----------------------------------------------------------------------*/
        PRINT '--------------------------------------------------------';
        PRINT 'Cargando Tablas ERP';
        PRINT '--------------------------------------------------------';

        /*---------------------- bronze.erp_cust_az12 ---------------------------*/
        SET @start_time = GETDATE();
        PRINT '>> Truncando Tabla: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Cargando Datos En: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\thinkpad\Projects\Data-Warehouse-Project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Duración De Carga: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR)
              + ' segundos';
        PRINT '----------------------------';

        /*---------------------- bronze.erp_loc_a101 ----------------------------*/
        SET @start_time = GETDATE();
        PRINT '>> Truncando Tabla: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Cargando Datos En: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\thinkpad\Projects\Data-Warehouse-Project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Duración De Carga: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR)
              + ' segundos';
        PRINT '----------------------------';

        /*------------------ bronze.erp_px_cat_g1v2 -----------------------------*/
        SET @start_time = GETDATE();
        PRINT '>> Truncando Tabla: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Cargando Datos En: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\thinkpad\Projects\Data-Warehouse-Project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Duración De Carga: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR)
              + ' segundos';
        PRINT '----------------------------';

        /*----------------------------------------------------------------------
        Fin del proceso de carga completo
        ----------------------------------------------------------------------*/
        SET @batch_end_time = GETDATE();

        PRINT '========================================================';
        PRINT 'Se Ha Completado La Carga De La Capa Bronze';
        PRINT ' - Duración Total: '
              + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR)
              + ' segundos';
        PRINT '========================================================';

    END TRY
    BEGIN CATCH
        /*----------------------------------------------------------------------
        Manejo de errores del proceso
        ----------------------------------------------------------------------*/
        PRINT '========================================================';
        PRINT 'ERROR OCURRIDO DURANTE LA CARGA DE LA CAPA BRONZE';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Número: '  + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Estado: '  + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '========================================================';
    END CATCH
END
GO
