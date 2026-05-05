USE dw_palmeras; GO

-- Poblar dim_tiempo con fechas 2020-01-01 a 2030-12-31
DECLARE @fecha DATE = '2020-01-01';
DECLARE @fin   DATE = '2030-12-31';

WHILE @fecha <= @fin
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.dim_tiempo WHERE fecha = @fecha)
    INSERT INTO dbo.dim_tiempo (fecha, dia_semana, semana_iso, mes, mes_nombre, anio, trimestre, es_fin_semana)
    SELECT
        @fecha,
        DATENAME(WEEKDAY, @fecha),
        DATEPART(ISO_WEEK, @fecha),
        MONTH(@fecha),
        DATENAME(MONTH, @fecha),
        YEAR(@fecha),
        DATEPART(QUARTER, @fecha),
        CASE WHEN DATEPART(WEEKDAY, @fecha) IN (1,7) THEN 1 ELSE 0 END;
    SET @fecha = DATEADD(DAY, 1, @fecha);
END
PRINT 'dim_tiempo poblada. Filas: ' + CAST(COUNT(*) AS VARCHAR)
      + ' en dbo.dim_tiempo' FROM dbo.dim_tiempo;  -- verificar
-- Verificar: SELECT COUNT(*) FROM dbo.dim_tiempo  → debe ser 3653
GO
