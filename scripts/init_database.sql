
/*
====================================================================================
SCRIPT: Creación de Base de Datos y Esquemas Base del Data Warehouse
====================================================================================
Descripción:
    Este script se encarga de crear desde cero la base de datos 'DataWarehouse',
    incluyendo la definición de los esquemas fundamentales que soportan la
    arquitectura por capas (Bronze, Silver y Gold).

Objetivo:
    - Garantizar una creación limpia y controlada del Data Warehouse.
    - Establecer una separación lógica de los datos según su nivel de
      transformación y calidad.

Notas:
    - Si la base de datos ya existe, será eliminada previamente.
    - La eliminación fuerza la desconexión de usuarios activos para evitar errores.
    - Ejecutar con privilegios de administrador.
====================================================================================
*/

USE master;
GO

/*------------------------------------------------------------------------------
Validación de existencia de la base de datos
- Si la base de datos 'DataWarehouse' existe, se fuerza el modo SINGLE_USER
  para cerrar conexiones activas y permitir su eliminación controlada.
------------------------------------------------------------------------------*/
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse
        SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE DataWarehouse;
END;
GO

/*------------------------------------------------------------------------------
Creación de la base de datos DataWarehouse
- Base de datos principal que contendrá toda la arquitectura analítica.
------------------------------------------------------------------------------*/
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

/*------------------------------------------------------------------------------
Creación de esquemas por capa
- bronze : Almacenamiento de datos crudos provenientes de las fuentes origen.
- silver : Datos depurados, estandarizados y con reglas de calidad aplicadas.
- gold   : Datos listos para consumo analítico (reportes, dashboards y modelos).
------------------------------------------------------------------------------*/
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
