CREATE OR ALTER VIEW dbo.vw_lecheria_produccion AS
SELECT
    fl.fecha,
    dt.semana_iso, dt.mes, dt.mes_nombre, dt.anio,
    COUNT(DISTINCT fl.id_animal)               AS vacas_ordenadas,
    ROUND(SUM(fl.litros_producidos), 1)        AS total_producido_lts,
    ROUND(AVG(fl.litros_producidos), 2)        AS promedio_vaca_lts,
    ROUND(MAX(fl.litros_producidos), 2)        AS mejor_vaca_lts,
    ROUND(MIN(fl.litros_producidos), 2)        AS menor_vaca_lts,
    ROUND(AVG(CAST(fl.dias_en_leche AS FLOAT)),0) AS dias_promedio_leche
FROM dbo.fact_lecheria_diaria fl
JOIN dbo.dim_tiempo dt ON dt.fecha = fl.fecha
WHERE fl.litros_producidos > 0
GROUP BY fl.fecha, dt.semana_iso, dt.mes, dt.mes_nombre, dt.anio;
GO

-- Prueba rápida:
SELECT TOP 10 * FROM dbo.vw_lecheria_produccion ORDER BY fecha DESC;
