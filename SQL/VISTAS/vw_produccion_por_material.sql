CREATE OR ALTER VIEW dbo.vw_produccion_por_material AS
SELECT
    fp.fecha,
    dt.semana_iso, dt.mes, dt.mes_nombre, dt.anio,
    df.nombre                                AS finca,
    df.cod_finca,
    fp.fuente,
    dm.nombre                                AS material,
    dm.codigo                                AS cod_material,
    dl.nombre_siembra                        AS siembra,
    dl.ano_siembra,
    dl.edad_palma,
    SUM(fp.kg_cosechados)                    AS kg_cosechados,
    ROUND(SUM(fp.kg_cosechados)/1000.0, 3)  AS toneladas
FROM dbo.fact_produccion_palma fp
JOIN dbo.dim_tiempo    dt ON dt.fecha       = fp.fecha
JOIN dbo.dim_finca     df ON df.cod_finca   = fp.cod_finca
JOIN dbo.dim_material  dm ON dm.codigo      = fp.cod_material
LEFT JOIN dbo.dim_lote dl ON dl.cod_finca   = fp.cod_finca
                          AND dl.cod_lote   = fp.cod_lote
GROUP BY
    fp.fecha, dt.semana_iso, dt.mes, dt.mes_nombre, dt.anio,
    df.nombre, df.cod_finca, fp.fuente,
    dm.nombre, dm.codigo, dl.nombre_siembra, dl.ano_siembra, dl.edad_palma;
GO
