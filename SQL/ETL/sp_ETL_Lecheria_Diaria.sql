USE dw_palmeras; GO

CREATE OR ALTER PROCEDURE dbo.sp_ETL_Lecheria_Diaria
    @dias_atras INT     = 3,
    @factor     DECIMAL(5,4) = 1.0300  -- factor de calibración (ajustar con veterinario)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @inicio DATE = DATEADD(DAY, -@dias_atras, CAST(GETDATE() AS DATE));
    DECLARE @fin    DATE = CAST(GETDATE() AS DATE);
    DECLARE @filas  INT  = 0;

    BEGIN TRY
        -- 1. Sincronizar dim_animal con nuevos animales del mirror
        MERGE dbo.dim_animal AS tgt
        USING (
            SELECT OID AS id_animal, Sex AS sexo
            FROM DDM_Mirror.Dbo.BasicAnimal
        ) AS src ON tgt.id_animal = src.id_animal
        WHEN NOT MATCHED THEN
            INSERT (id_animal, sexo, estado) VALUES (src.id_animal, src.sexo, 'activo');

        -- 2. Borrar rango a recargar
        DELETE FROM dbo.fact_lecheria_diaria
        WHERE fecha >= @inicio AND fecha <= @fin;

        -- 3. Insertar datos combinando AnimalDaily + SessionMilkYield
        INSERT INTO dbo.fact_lecheria_diaria
            (fecha, id_animal, litros_producidos, litros_despachados,
             dias_en_leche, calidad_dato)
        SELECT
            CAST(ad.Date AS DATE)                      AS fecha,
            ad.BasicAnimal                             AS id_animal,
            ROUND(ad.TotalYield * @factor, 2)          AS litros_producidos,
            ROUND(ISNULL(desp.total_sesion,0) * @factor, 2) AS litros_despachados,
            ad.DIM                                     AS dias_en_leche,
            'completo'                                 AS calidad_dato
        FROM DDM_Mirror.Dbo.AnimalDaily ad
        LEFT JOIN (
            -- Agrupar todas las sesiones del día por animal
            SELECT BasicAnimal,
                   CAST(BeginTime AS DATE) AS fecha_sesion,
                   SUM(TotalYield)         AS total_sesion
            FROM DDM_Mirror.Dbo.SessionMilkYield
            WHERE CAST(BeginTime AS DATE) >= @inicio
              AND CAST(BeginTime AS DATE) <= @fin
            GROUP BY BasicAnimal, CAST(BeginTime AS DATE)
        ) desp ON desp.BasicAnimal    = ad.BasicAnimal
              AND desp.fecha_sesion   = CAST(ad.Date AS DATE)
        WHERE
            ad.IsYieldValid = 0
            AND ad.TotalYield > 0
            AND CAST(ad.Date AS DATE) >= @inicio
            AND CAST(ad.Date AS DATE) <= @fin;

        SET @filas = @@ROWCOUNT;

        -- 4. Actualizar control
        UPDATE dbo.etl_control
        SET ultima_fecha     = @fin,
            ultima_ejecucion = GETDATE(),
            estado           = 'OK',
            filas_cargadas   = @filas,
            mensaje          = 'Carga exitosa. Factor=' + CAST(@factor AS VARCHAR)
                               + ' Rango: ' + CONVERT(VARCHAR,@inicio,23)
                               + ' a ' + CONVERT(VARCHAR,@fin,23)
        WHERE nombre_job = 'ETL_Lecheria_Diaria';

        PRINT 'ETL Lecheria OK. Filas: ' + CAST(@filas AS VARCHAR);
    END TRY
    BEGIN CATCH
        UPDATE dbo.etl_control
        SET estado = 'ERROR', mensaje = ERROR_MESSAGE(),
            ultima_ejecucion = GETDATE()
        WHERE nombre_job = 'ETL_Lecheria_Diaria';
        THROW;
    END CATCH
END
GO
