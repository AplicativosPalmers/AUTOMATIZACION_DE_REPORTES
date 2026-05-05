USE dw_palmeras; GO

-- ═══ DIMENSIÓN TIEMPO ═══════════════════════════════════════════
IF OBJECT_ID('dbo.dim_tiempo','U') IS NULL
CREATE TABLE dbo.dim_tiempo (
    fecha          DATE         NOT NULL PRIMARY KEY,
    dia_semana     VARCHAR(12)  NOT NULL,  -- 'Lunes','Martes'...
    semana_iso     INT          NOT NULL,  -- 1-53
    mes            INT          NOT NULL,  -- 1-12
    mes_nombre     VARCHAR(15)  NOT NULL,  -- 'Enero','Febrero'...
    anio           INT          NOT NULL,
    trimestre      INT          NOT NULL,  -- 1-4
    es_fin_semana  BIT          NOT NULL DEFAULT 0
);
GO

-- ═══ DIMENSIÓN FINCA ════════════════════════════════════════════
IF OBJECT_ID('dbo.dim_finca','U') IS NULL
CREATE TABLE dbo.dim_finca (
    id_finca       INT          NOT NULL PRIMARY KEY IDENTITY(1,1),
    cod_finca      VARCHAR(10)  NOT NULL UNIQUE,  -- fincacodi de PALMERAS2013
    nombre         VARCHAR(120) NOT NULL,          -- fincadesc
    fuente         VARCHAR(15)  NOT NULL           -- 'Propia','Terceros','La Loma'
                   CHECK (fuente IN ('Propia','Terceros','La Loma')),
    municipio      VARCHAR(80)  NULL,
    activa         BIT          NOT NULL DEFAULT 1
);
GO

-- ═══ DIMENSIÓN MATERIAL ═════════════════════════════════════════
IF OBJECT_ID('dbo.dim_material','U') IS NULL
CREATE TABLE dbo.dim_material (
    id_material    INT          NOT NULL PRIMARY KEY IDENTITY(1,1),
    codigo         VARCHAR(10)  NOT NULL UNIQUE,  -- valor de lotefruta
    nombre         VARCHAR(60)  NOT NULL          -- nombre legible
);
GO
-- Poblar dim_material con los valores confirmados
IF NOT EXISTS (SELECT 1 FROM dbo.dim_material WHERE codigo='HIB')
    INSERT INTO dbo.dim_material (codigo,nombre) VALUES ('HIB','Hibrido OxG');
IF NOT EXISTS (SELECT 1 FROM dbo.dim_material WHERE codigo='GIN')
    INSERT INTO dbo.dim_material (codigo,nombre) VALUES ('GIN','Guineensis');
IF NOT EXISTS (SELECT 1 FROM dbo.dim_material WHERE codigo='SIN')
    INSERT INTO dbo.dim_material (codigo,nombre) VALUES ('SIN','Sin clasificar');
GO

-- ═══ DIMENSIÓN LOTE ═════════════════════════════════════════════
IF OBJECT_ID('dbo.dim_lote','U') IS NULL
CREATE TABLE dbo.dim_lote (
    id_lote        INT          NOT NULL PRIMARY KEY IDENTITY(1,1),
    cod_finca      VARCHAR(10)  NOT NULL,  -- FK lógica a dim_finca.cod_finca
    cod_lote       VARCHAR(10)  NOT NULL,
    nombre_lote    VARCHAR(120) NOT NULL,
    cod_material   VARCHAR(10)  NOT NULL DEFAULT 'SIN',  -- FK a dim_material.codigo
    siembra        VARCHAR(20)  NULL,      -- código centcos
    nombre_siembra VARCHAR(100) NULL,
    ano_siembra    INT          NULL,
    palmas_activas INT          NULL,      -- lotematas - lotemuerte
    hectareas      DECIMAL(10,2) NULL,     -- palmas_activas / DENSIDPALM
    edad_palma     VARCHAR(10)  NULL,      -- 'Adulta' / 'Joven'
    extractora     VARCHAR(30)  NULL,      -- 'Extractora Porvenir' / 'Extractora Palmeras'
    UNIQUE (cod_finca, cod_lote)
);
GO

-- ═══ DIMENSIÓN ANIMAL ═══════════════════════════════════════════
IF OBJECT_ID('dbo.dim_animal','U') IS NULL
CREATE TABLE dbo.dim_animal (
    id_animal      INT          NOT NULL PRIMARY KEY,  -- OID de DDM
    nombre         VARCHAR(80)  NULL,
    sexo           TINYINT      NULL,      -- 1=Macho, 2=Hembra
    estado         VARCHAR(15)  NOT NULL DEFAULT 'activo'
                   CHECK (estado IN ('activo','seco','vendido','muerto'))
);
GO
