ALTER TABLE cine_campo_amplio
    ALTER COLUMN cine_campo_amplio TYPE VARCHAR(255);

ALTER TABLE cine_campo_especifico
    ALTER COLUMN cine_campo_especifico TYPE VARCHAR(255);

ALTER TABLE cine_codigo_detallado
    ALTER COLUMN cine_codigo_detallado TYPE VARCHAR(255);

-- SEXO
INSERT INTO sexo (nombre_sexo)
SELECT DISTINCT TRIM(sexo)
FROM dataset_temporal
WHERE sexo IS NOT NULL AND TRIM(sexo) <> ''
ON CONFLICT (nombre_sexo) DO NOTHING;

-- SECTOR IES
INSERT INTO sector_ies (nombre_sector_ies)
SELECT DISTINCT TRIM(sector_ies)
FROM dataset_temporal
WHERE sector_ies IS NOT NULL AND TRIM(sector_ies) <> ''
ON CONFLICT (nombre_sector_ies) DO NOTHING;

-- CARÁCTER IES
INSERT INTO caracter_ies (caracter_ies)
SELECT DISTINCT TRIM(caracter_ies)
FROM dataset_temporal
WHERE caracter_ies IS NOT NULL AND TRIM(caracter_ies) <> ''
ON CONFLICT (caracter_ies) DO NOTHING;

-- METODOLOGÍA
INSERT INTO metodologia (metodologia)
SELECT DISTINCT TRIM(metodologia)
FROM dataset_temporal
WHERE metodologia IS NOT NULL AND TRIM(metodologia) <> ''
ON CONFLICT (metodologia) DO NOTHING;

-- NIVEL ACADÉMICO
INSERT INTO nivel_academico (nivel_academico)
SELECT DISTINCT TRIM(nivel_academico)
FROM dataset_temporal
WHERE nivel_academico IS NOT NULL AND TRIM(nivel_academico) <> ''
ON CONFLICT (nivel_academico) DO NOTHING;

-- ÁREA DE CONOCIMIENTO
INSERT INTO area_conocimiento (area_conocimiento)
SELECT DISTINCT TRIM(area_de_conocimiento)
FROM dataset_temporal
WHERE area_de_conocimiento IS NOT NULL AND TRIM(area_de_conocimiento) <> ''
ON CONFLICT (area_conocimiento) DO NOTHING;

-- CINE AMPLIO
INSERT INTO cine_campo_amplio (cine_campo_amplio)
SELECT DISTINCT TRIM(desc_cine_campo_amplio)
FROM dataset_temporal
WHERE desc_cine_campo_amplio IS NOT NULL AND TRIM(desc_cine_campo_amplio) <> ''
ON CONFLICT (cine_campo_amplio) DO NOTHING;

-- CINE ESPECÍFICO
INSERT INTO cine_campo_especifico (cine_campo_especifico, id_cine_campo_amplio_fk)
SELECT DISTINCT
    TRIM(d.desc_cine_campo_especifico),
    ca.id_cine_campo_amplio
FROM dataset_temporal d
JOIN cine_campo_amplio ca ON TRIM(d.desc_cine_campo_amplio) = ca.cine_campo_amplio
WHERE d.desc_cine_campo_especifico IS NOT NULL AND TRIM(d.desc_cine_campo_especifico) <> ''
ON CONFLICT (cine_campo_especifico) DO NOTHING;

-- CINE DETALLADO
INSERT INTO cine_codigo_detallado (cine_codigo_detallado, id_cine_campo_especifico_fk)
SELECT DISTINCT
    TRIM(d.desc_cine_codigo_detallado),
    ce.id_cine_campo_especifico
FROM dataset_temporal d
JOIN cine_campo_especifico ce ON TRIM(d.desc_cine_campo_especifico) = ce.cine_campo_especifico
WHERE d.desc_cine_codigo_detallado IS NOT NULL AND TRIM(d.desc_cine_codigo_detallado) <> ''
ON CONFLICT (cine_codigo_detallado) DO NOTHING;

-- NIVEL DE FORMACIÓN
INSERT INTO nivel_formacion (nivel_formacion, id_nivel_academico_fk)
SELECT DISTINCT
    TRIM(d.nivel_de_formacion),
    na.id_nivel_academico
FROM dataset_temporal d
JOIN nivel_academico na ON TRIM(d.nivel_academico) = na.nivel_academico
WHERE d.nivel_de_formacion IS NOT NULL AND TRIM(d.nivel_de_formacion) <> ''
ON CONFLICT (nivel_formacion) DO NOTHING;

-- NBC
INSERT INTO nucleo_conocimiento (nucleo_conocimiento, id_area_conocimiento_fk)
SELECT DISTINCT
    TRIM(d.nucleo_basico_del_conocimiento_nbc),
    ac.id_area_conocimiento
FROM dataset_temporal d
JOIN area_conocimiento ac ON TRIM(d.area_de_conocimiento) = ac.area_conocimiento
WHERE d.nucleo_basico_del_conocimiento_nbc IS NOT NULL AND TRIM(d.nucleo_basico_del_conocimiento_nbc) <> ''
ON CONFLICT (nucleo_conocimiento) DO NOTHING;

-- DEPARTAMENTOS
INSERT INTO departamento (id_departamento, nombre_departamento)
SELECT DISTINCT
    LPAD(TRIM(cod_depto), 2, '0'),
    nom_depto
FROM (
    SELECT codigo_del_departamento_ies AS cod_depto,
           departamento_de_domicilio_de_la_ies AS nom_depto
    FROM dataset_temporal
    UNION
    SELECT codigo_del_departamento_programa,
           departamento_de_oferta_del_programa
    FROM dataset_temporal
) t
WHERE cod_depto IS NOT NULL AND TRIM(cod_depto) <> ''
ON CONFLICT (id_departamento) DO NOTHING;


-- Eliminar UNIQUE que te causaba error
ALTER TABLE municipio DROP CONSTRAINT IF EXISTS municipio_nombre_municipio_key;

-- MUNICIPIOS
INSERT INTO municipio (id_municipio, nombre_municipio, id_departamento_fk)
SELECT DISTINCT
    LPAD(TRIM(cod_mpio), 5, '0'),
    nom_mpio,
    LPAD(TRIM(cod_depto), 2, '0')
FROM (
    SELECT codigo_del_municipio_ies AS cod_mpio,
           municipio_de_domicilio_de_la_ies AS nom_mpio,
           codigo_del_departamento_ies AS cod_depto
    FROM dataset_temporal
    UNION
    SELECT codigo_del_municipio_programa,
           municipio_de_oferta_del_programa,
           codigo_del_departamento_programa
    FROM dataset_temporal
) t
WHERE cod_mpio IS NOT NULL AND TRIM(cod_mpio) <> ''
ON CONFLICT (id_municipio) DO NOTHING;

INSERT INTO institucion (
    id_institucion,
    nombre_institucion,
    institucion_acreditada,
    id_sector_ies_fk,
    id_caracter_ies_fk
)
SELECT DISTINCT
    CAST(TRIM(d.ies_padre) AS INT),
    d.institucion_de_educacion_superior_ies,
    d.ies_acreditada,
    si.id_sector_ies,
    ci.id_caracter_ies
FROM dataset_temporal d
JOIN sector_ies si ON TRIM(d.sector_ies) = si.nombre_sector_ies
JOIN caracter_ies ci ON TRIM(d.caracter_ies) = ci.caracter_ies
WHERE d.ies_padre IS NOT NULL AND TRIM(d.ies_padre) <> '';

ALTER TABLE programa DROP CONSTRAINT IF EXISTS programa_nombre_programa_key;

INSERT INTO programa (
    id_programa,
    nombre_programa,
    programa_acreditado,
    id_nivel_formacion_fk,
    id_metodologia_fk,
    id_nucleo_conocimiento_fk,
    id_cine_codigo_detallado_fk
)
SELECT DISTINCT
    CAST(TRIM(d.codigo_snies_del_programa) AS INT),
    d.programa_academico,
    d.programa_acreditado,
    nf.id_nivel_formacion,
    me.id_metodologia,
    nc.id_nucleo_conocimiento,
    ccd.id_cine_codigo_detallado
FROM dataset_temporal d
JOIN nivel_formacion nf ON TRIM(d.nivel_de_formacion) = nf.nivel_formacion
JOIN metodologia me ON TRIM(d.metodologia) = me.metodologia
JOIN nucleo_conocimiento nc ON TRIM(d.nucleo_basico_del_conocimiento_nbc) = nc.nucleo_conocimiento
JOIN cine_codigo_detallado ccd ON TRIM(d.desc_cine_codigo_detallado) = ccd.cine_codigo_detallado
WHERE d.codigo_snies_del_programa IS NOT NULL AND TRIM(d.codigo_snies_del_programa) <> '';

INSERT INTO sede (
    id_sede,
    tipo_sede,
    id_institucion_fk,
    id_municipio_sede_fk
)
SELECT DISTINCT
    CAST(TRIM(d.codigo_de_la_institucion) AS INT)      AS id_sede,
    TRIM(d.principal_o_seccional)                      AS tipo_sede,
    CAST(TRIM(d.ies_padre) AS INT)                     AS id_institucion_fk,
    LPAD(TRIM(d.codigo_del_municipio_ies), 5, '0')     AS id_municipio_sede_fk
FROM dataset_temporal d
WHERE d.codigo_de_la_institucion IS NOT NULL
  AND TRIM(d.codigo_de_la_institucion) <> ''
  AND d.principal_o_seccional IS NOT NULL
  AND TRIM(d.principal_o_seccional) <> ''
ON CONFLICT (id_sede) DO NOTHING;




INSERT INTO graduado_registro (
    id_sede_fk,
    id_programa_fk,
    id_municipio_oferta_fk,
    id_sexo_fk,
    semestre,
    graduados
)
SELECT DISTINCT
    CAST(TRIM(d.codigo_de_la_institucion) AS INT),
    CAST(TRIM(d.codigo_snies_del_programa) AS INT),
    LPAD(TRIM(d.codigo_del_municipio_programa), 5, '0'),
    sx.id_sexo,
    CAST(TRIM(d.semestre) AS INT),
    CAST(TRIM(d.graduados) AS INT)
FROM dataset_temporal d
JOIN sexo sx ON TRIM(d.sexo) = sx.nombre_sexo
WHERE d.codigo_de_la_institucion IS NOT NULL
  AND TRIM(d.codigo_de_la_institucion) <> ''
  AND d.codigo_snies_del_programa IS NOT NULL
  AND TRIM(d.codigo_snies_del_programa) <> ''
  AND d.codigo_del_municipio_programa IS NOT NULL
  AND TRIM(d.codigo_del_municipio_programa) <> ''
  AND d.semestre IS NOT NULL
  AND TRIM(d.semestre) <> ''
  AND d.graduados IS NOT NULL
  AND TRIM(d.graduados) <> ''
ON CONFLICT (id_sede_fk, id_programa_fk, id_municipio_oferta_fk, id_sexo_fk, semestre)
DO NOTHING;
