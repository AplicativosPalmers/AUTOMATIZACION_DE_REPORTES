-- PASO 1: Crear base de datos del Data Warehouse
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'dw_palmeras')
BEGIN
    CREATE DATABASE dw_palmeras
    COLLATE Modern_Spanish_CI_AS;
    PRINT 'Base de datos dw_palmeras creada correctamente.';
END
ELSE
    PRINT 'dw_palmeras ya existe. Continuando...';
GO
USE dw_palmeras;
GO
