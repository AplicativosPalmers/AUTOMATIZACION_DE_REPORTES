USE dw_palmeras; GO

-- ═══ FACT PRODUCCIÓN PALMA ══════════════════════════════════════
IF OBJECT_ID('dbo.fact_produccion_palma','U') IS NULL
CREATE TABLE dbo.fact_produccion_palma (
    id             BIGINT       NOT NULL PRIMARY KEY IDENTITY(1,1),
    fecha          DATE         NOT NULL,
    cod_finca      VARCHAR(10)  NOT NULL,
    cod_lote       VARCHAR(10)  NOT NULL,
    cod_material   VARCHAR(10)  NOT NULL DEFAULT 'SIN',
    fuente         VARCHAR(15)  NOT NULL,  -- Propia/Terceros/La Loma
    extractora     VARCHAR(30)  NULL,
    labor_nombre   VARCHAR(120) NULL,      -- variante exacta de FRUTA
    kg_cosechados  DECIMAL(14,2) NOT NULL DEFAULT 0,
    calidad_dato   VARCHAR(10)  NOT NULL DEFAULT 'completo'
                   CHECK (calidad_dato IN ('completo','parcial','estimado')),
    fecha_cargue   DATETIME     NOT NULL DEFAULT GETDATE(),
    -- Índices para performance en dashboards y agente IA
    INDEX ix_fpp_fecha      (fecha),
    INDEX ix_fpp_finca      (cod_finca, fecha),
    INDEX ix_fpp_material   (cod_material, fecha),
    INDEX ix_fpp_fuente     (fuente, fecha)
);
GO

-- ═══ FACT LECHERÍA DIARIA ════════════════════════════════════════
IF OBJECT_ID('dbo.fact_lecheria_diaria','U') IS NULL
CREATE TABLE dbo.fact_lecheria_diaria (
    id                BIGINT       NOT NULL PRIMARY KEY IDENTITY(1,1),
    fecha             DATE         NOT NULL,
    id_animal         INT          NOT NULL,
    litros_producidos DECIMAL(8,2) NOT NULL DEFAULT 0,
    litros_despachados DECIMAL(8,2) NOT NULL DEFAULT 0,
    dias_en_leche     INT          NULL,   -- DIM del animal
    calidad_dato      VARCHAR(10)  NOT NULL DEFAULT 'completo'
                      CHECK (calidad_dato IN ('completo','parcial','estimado')),
    fecha_cargue      DATETIME     NOT NULL DEFAULT GETDATE(),
    INDEX ix_fld_fecha    (fecha),
    INDEX ix_fld_animal   (id_animal, fecha)
);
GO

-- ═══ TABLA DE CONTROL ETL ════════════════════════════════════════
IF OBJECT_ID('dbo.etl_control','U') IS NULL
CREATE TABLE dbo.etl_control (
    id             INT          NOT NULL PRIMARY KEY IDENTITY(1,1),
    nombre_job     VARCHAR(60)  NOT NULL,
    ultima_fecha   DATE         NULL,      -- último día cargado exitosamente
    ultima_ejecucion DATETIME   NULL,
    estado         VARCHAR(15)  NOT NULL DEFAULT 'OK',
    filas_cargadas INT          NULL,
    mensaje        VARCHAR(500) NULL
);
INSERT INTO dbo.etl_control (nombre_job, ultima_fecha, estado)
VALUES ('ETL_Produccion_Palma', '2025-01-01', 'inicial'),
       ('ETL_Lecheria_Diaria',  '2025-01-01', 'inicial');
GO
