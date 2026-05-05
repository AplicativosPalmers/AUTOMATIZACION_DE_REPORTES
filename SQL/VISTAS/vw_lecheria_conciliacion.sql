CREATE OR ALTER VIEW dbo.vw_lecheria_conciliacion AS
SELECT
    fl.fecha,
    dt.semana_iso, dt.mes, dt.mes_nombre, dt.anio,
    ROUND(SUM(fl.litros_producidos),  1) AS total_producido_lts,
    ROUND(SUM(fl.litros_despachados), 1) AS total_despachado_lts,
    ROUND(SUM(fl.litros_producidos) - SUM(fl.litros_despachados), 1) AS leche_terneros_lts,
    CASE
        WHEN SUM(fl.litros_producidos) = 0 THEN 'sin_datos'
        WHEN ABS(SUM(fl.litros_producidos)-SUM(fl.litros_despachados))
             / SUM(fl.litros_producidos) < 0.02 THEN 'verde'
        WHEN ABS(SUM(fl.litros_producidos)-SUM(fl.litros_despachados))
             / SUM(fl.litros_producidos) < 0.05 THEN 'amarillo'
        ELSE 'rojo'
    END                                  AS estado_conciliacion,
    ROUND(
        ABS(SUM(fl.litros_producidos)-SUM(fl.litros_despachados))
        / NULLIF(SUM(fl.litros_producidos),0) * 100, 1
    )                                    AS pct_diferencia
FROM dbo.fact_lecheria_diaria fl
JOIN dbo.dim_tiempo dt ON dt.fecha = fl.fecha
GROUP BY fl.fecha, dt.semana_iso, dt.mes, dt.mes_nombre, dt.anio;
GO
