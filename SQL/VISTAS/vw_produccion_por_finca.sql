USE dw_palmeras; GO

CREATE OR ALTER VIEW dbo.vw_produccion_por_finca AS
SELECT
    fp.fecha,
    dt.semana_iso,
    dt.mes,
    dt.mes_nombre,
    dt.anio,
    df.nombre                                AS finca,
    df.cod_finca,
    fp.fuente,                               -- Propia / Terceros / La Loma
    fp.extractora,
    SUM(fp.kg_cosechados)                    AS kg_cosechados,
    ROUND(SUM(fp.kg_cosechados)/1000.0, 3)  AS toneladas,
    COUNT(DISTINCT fp.cod_lote)              AS lotes_cosechados
FROM dbo.fact_produccion_palma fp
JOIN dbo.dim_tiempo  dt ON dt.fecha    = fp.fecha
JOIN dbo.dim_finca   df ON df.cod_finca = fp.cod_finca
GROUP BY
    fp.fecha, dt.semana_iso, dt.mes, dt.mes_nombre, dt.anio,
    df.nombre, df.cod_finca, fp.fuente, fp.extractora;
GO

-- Prueba rápida:
SELECT TOP 20 * FROM dbo.vw_produccion_por_finca
ORDER BY fecha DESC, kg_cosechados DESC;
