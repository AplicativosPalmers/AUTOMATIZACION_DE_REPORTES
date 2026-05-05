USE dw_palmeras; GO

-- ── POBLAR dim_finca desde PALMERAS2013 ─────────────────────────
MERGE dbo.dim_finca AS tgt
USING (
    SELECT RTRIM(fincacodi) AS cod_finca,
           RTRIM(fincadesc) AS nombre,
           CASE WHEN RTRIM(fincacodi)='90' THEN 'Terceros'
                WHEN RTRIM(fincacodi)='71' THEN 'La Loma'
                ELSE 'Propia' END AS fuente
    FROM PALMERAS2013.Dbo.fincas
) AS src ON tgt.cod_finca = src.cod_finca
WHEN NOT MATCHED THEN
    INSERT (cod_finca, nombre, fuente) VALUES (src.cod_finca, src.nombre, src.fuente);
PRINT 'dim_finca: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' fincas insertadas.';
GO

-- ── POBLAR dim_lote desde PALMERAS2013 ──────────────────────────
MERGE dbo.dim_lote AS tgt
USING (
    SELECT
        RTRIM(lt.fincacodi)  AS cod_finca,
        RTRIM(lt.lotecodi)   AS cod_lote,
        RTRIM(lt.lotenomb)   AS nombre_lote,
        ISNULL(NULLIF(RTRIM(lt.lotefruta),''),'SIN') AS cod_material,
        RTRIM(lt.lotecodcc)  AS siembra,
        RTRIM(cc.nombre)     AS nombre_siembra,
        YEAR(lt.lotefechas)  AS ano_siembra,
        (lt.lotematas - lt.lotemuerte) AS palmas_activas,
        CASE WHEN ISNULL(lt.DENSIDPALM,0)>0
             THEN ROUND((lt.lotematas-lt.lotemuerte)*1.0/lt.DENSIDPALM,2)
             ELSE ROUND((lt.lotematas-lt.lotemuerte)*1.0/143,2) END AS hectareas,
        CASE WHEN YEAR(lt.lotefechas)<=YEAR(GETDATE())-10 THEN 'Adulta'
             ELSE 'Joven' END AS edad_palma,
        CASE WHEN lt.fincacodi IN('03','09') OR lt.lotecodcc='20101'
             THEN 'Extractora Porvenir' ELSE 'Extractora Palmeras' END AS extractora
    FROM PALMERAS2013.Dbo.lotes lt
    LEFT JOIN PALMERAS2013.Dbo.centcos cc ON cc.codcc = lt.lotecodcc
) AS src ON tgt.cod_finca = src.cod_finca AND tgt.cod_lote = src.cod_lote
WHEN NOT MATCHED THEN
    INSERT (cod_finca,cod_lote,nombre_lote,cod_material,siembra,nombre_siembra,
            ano_siembra,palmas_activas,hectareas,edad_palma,extractora)
    VALUES (src.cod_finca,src.cod_lote,src.nombre_lote,src.cod_material,src.siembra,
            src.nombre_siembra,src.ano_siembra,src.palmas_activas,src.hectareas,
            src.edad_palma,src.extractora);
PRINT 'dim_lote: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' lotes insertados.';
GO

-- ── POBLAR dim_animal desde DDM_Mirror ──────────────────────────
MERGE dbo.dim_animal AS tgt
USING (
    SELECT OID AS id_animal, NULL AS nombre, Sex AS sexo, 'activo' AS estado
    FROM DDM_Mirror.Dbo.BasicAnimal
) AS src ON tgt.id_animal = src.id_animal
WHEN NOT MATCHED THEN
    INSERT (id_animal, nombre, sexo, estado)
    VALUES (src.id_animal, src.nombre, src.sexo, src.estado);
PRINT 'dim_animal: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' animales insertados.';
GO
