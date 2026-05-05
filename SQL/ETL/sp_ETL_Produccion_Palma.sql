USE dw_palmeras; GO

CREATE OR ALTER PROCEDURE dbo.sp_ETL_Produccion_Palma
    @dias_atras INT = 3  -- por defecto recarga los últimos 3 días
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @inicio DATE = DATEADD(DAY, -@dias_atras, CAST(GETDATE() AS DATE));
    DECLARE @fin    DATE = CAST(GETDATE() AS DATE);
    DECLARE @filas  INT  = 0;

    BEGIN TRY
        -- 1. Borrar el rango a recargar (evita duplicados)
        DELETE FROM dbo.fact_produccion_palma
        WHERE fecha >= @inicio AND fecha <= @fin;

        -- 2. Insertar datos desde PALMERAS2013
        INSERT INTO dbo.fact_produccion_palma
            (fecha, cod_finca, cod_lote, cod_material, fuente,
             extractora, labor_nombre, kg_cosechados, calidad_dato)
        SELECT
            CAST(TQ.tiquefecha AS DATE)                     AS fecha,
            RTRIM(TQ.tiquefinca)                            AS cod_finca,
            RTRIM(TQ.tiquelote)                             AS cod_lote,
            ISNULL(NULLIF(RTRIM(LT.lotefruta),''),'SIN')   AS cod_material,
            CASE WHEN RTRIM(TQ.tiquefinca)='90' THEN 'Terceros'
                 WHEN RTRIM(TQ.tiquefinca)='71' THEN 'La Loma'
                 ELSE 'Propia' END                          AS fuente,
            CASE WHEN TQ.tiquefinca IN('03','09')
                   OR TQ.tiquecodcc='20101'
                 THEN 'Extractora Porvenir'
                 ELSE 'Extractora Palmeras' END             AS extractora,
            RTRIM(LB.labonomb)                              AS labor_nombre,
            SUM(TQ.tiquecanti)                              AS kg_cosechados,
            'completo'                                      AS calidad_dato
        FROM PALMERAS2013.Dbo.tiquete AS TQ
            LEFT JOIN PALMERAS2013.Dbo.labores AS LB
                ON TQ.tiquelabor = LB.labocodi
            LEFT JOIN PALMERAS2013.Dbo.lotes   AS LT
                ON TQ.tiquefinca = LT.fincacodi
               AND TQ.tiquelote  = LT.lotecodi
        WHERE
            LB.labonomb LIKE '%FRUTA%'
            AND LB.labonomb NOT LIKE '%TRASLADO%'
            AND LB.labonomb NOT LIKE '%CANJE%'
            AND TQ.tiquecanti > 0
            AND TQ.tiquefecha >= @inicio
            AND TQ.tiquefecha <= @fin
        GROUP BY
            CAST(TQ.tiquefecha AS DATE), RTRIM(TQ.tiquefinca),
            RTRIM(TQ.tiquelote), RTRIM(LT.lotefruta),
            TQ.tiquefinca, TQ.tiquecodcc, RTRIM(LB.labonomb);

        SET @filas = @@ROWCOUNT;

        -- 3. Actualizar tabla de control
        UPDATE dbo.etl_control
        SET ultima_fecha      = @fin,
            ultima_ejecucion  = GETDATE(),
            estado            = 'OK',
            filas_cargadas    = @filas,
            mensaje           = 'Carga exitosa. Rango: '
                                + CONVERT(VARCHAR,@inicio,23)
                                + ' a ' + CONVERT(VARCHAR,@fin,23)
        WHERE nombre_job = 'ETL_Produccion_Palma';

        PRINT 'ETL Produccion OK. Filas: ' + CAST(@filas AS VARCHAR);
    END TRY
    BEGIN CATCH
        UPDATE dbo.etl_control
        SET estado   = 'ERROR',
            mensaje  = ERROR_MESSAGE(),
            ultima_ejecucion = GETDATE()
        WHERE nombre_job = 'ETL_Produccion_Palma';
        THROW;
    END CATCH
END
GO
