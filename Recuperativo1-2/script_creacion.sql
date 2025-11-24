-- PUNTO 6: DDL SCRIPT PARA POSTGRESQL (MODELO 3FN - 17 TABLAS)

-- ----------------------------------------------------
-- 1. CREACIÓN DE TABLAS DE CLASIFICACIÓN Y DIMENSIONES
-- ----------------------------------------------------

-- TABLAS SIMPLES
CREATE TABLE sexo (
    id_sexo SERIAL PRIMARY KEY,
    nombre_sexo VARCHAR(10) NOT NULL UNIQUE
);

CREATE TABLE sector_ies (
    id_sector_ies SERIAL PRIMARY KEY,
    nombre_sector_ies VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE caracter_ies (
    id_caracter_ies SERIAL PRIMARY KEY,
    caracter_ies VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE metodologia (
    id_metodologia SERIAL PRIMARY KEY,
    metodologia VARCHAR(20) NOT NULL UNIQUE
);

-- TABLAS GEOGRÁFICAS
CREATE TABLE departamento (
    id_departamento CHAR(2) PRIMARY KEY, -- Código DANE CHAR(2)
    nombre_departamento VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE municipio (
    id_municipio CHAR(5) PRIMARY KEY, -- Código DANE CHAR(5)
    nombre_municipio VARCHAR(100) NOT NULL UNIQUE,
    id_departamento_fk CHAR(2) NOT NULL REFERENCES departamento(id_departamento)
);

-- TABLAS JERÁRQUICAS DE NIVELES (NIVEL ACADÉMICO)
CREATE TABLE nivel_academico (
    id_nivel_academico SERIAL PRIMARY KEY,
    nivel_academico VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE nivel_formacion (
    id_nivel_formacion SERIAL PRIMARY KEY,
    nivel_formacion VARCHAR(50) NOT NULL UNIQUE,
    id_nivel_academico_fk INT NOT NULL REFERENCES nivel_academico(id_nivel_academico)
);

-- TABLAS JERÁRQUICAS DE CONOCIMIENTO (NBC)
CREATE TABLE area_conocimiento (
    id_area_conocimiento SERIAL PRIMARY KEY,
    area_conocimiento VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE nucleo_conocimiento (
    id_nucleo_conocimiento SERIAL PRIMARY KEY,
    nucleo_conocimiento VARCHAR(100) NOT NULL UNIQUE,
    id_area_conocimiento_fk INT NOT NULL REFERENCES area_conocimiento(id_area_conocimiento)
);

-- TABLAS JERÁRQUICAS DE CLASIFICACIÓN CINE
CREATE TABLE cine_campo_amplio (
    id_cine_campo_amplio SERIAL PRIMARY KEY,
    cine_campo_amplio VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE cine_campo_especifico (
    id_cine_campo_especifico SERIAL PRIMARY KEY,
    cine_campo_especifico VARCHAR(100) NOT NULL UNIQUE,
    id_cine_campo_amplio_fk INT NOT NULL REFERENCES cine_campo_amplio(id_cine_campo_amplio)
);

CREATE TABLE cine_codigo_detallado (
    id_cine_codigo_detallado SERIAL PRIMARY KEY,
    cine_codigo_detallado VARCHAR(100) NOT NULL UNIQUE,
    id_cine_campo_especifico_fk INT NOT NULL REFERENCES cine_campo_especifico(id_cine_campo_especifico)
);

-- ----------------------------------------------------
-- 2. TABLAS INSTITUCIÓN Y PROGRAMA
-- ----------------------------------------------------

CREATE TABLE institucion (
    id_institucion INT PRIMARY KEY, -- IES_PADRE
    nombre_institucion VARCHAR(255) NOT NULL UNIQUE,
    institucion_acreditada CHAR(1) NOT NULL, -- S/N
    id_sector_ies_fk INT NOT NULL REFERENCES sector_ies(id_sector_ies),
    id_caracter_ies_fk INT NOT NULL REFERENCES caracter_ies(id_caracter_ies)
);

CREATE TABLE sede (
    id_sede INT PRIMARY KEY, -- CÓDIGO DE LA INSTITUCIÓN
    tipo_sede VARCHAR(10) NOT NULL, -- Principal/Seccional
    id_institucion_fk INT NOT NULL REFERENCES institucion(id_institucion),
    id_municipio_sede_fk CHAR(5) NOT NULL REFERENCES municipio(id_municipio) -- Domicilio de la Sede
);

CREATE TABLE programa (
    id_programa INT PRIMARY KEY, -- SNIES
    nombre_programa VARCHAR(255) NOT NULL UNIQUE,
    programa_acreditado CHAR(1) NOT NULL, -- S/N
    id_nivel_formacion_fk INT NOT NULL REFERENCES nivel_formacion(id_nivel_formacion),
    id_metodologia_fk INT NOT NULL REFERENCES metodologia(id_metodologia),
    id_nucleo_conocimiento_fk INT NOT NULL REFERENCES nucleo_conocimiento(id_nucleo_conocimiento),
    id_cine_codigo_detallado_fk INT NOT NULL REFERENCES cine_codigo_detallado(id_cine_codigo_detallado)
);

-- ----------------------------------------------------
-- 3. TABLA DE HECHOS
-- ----------------------------------------------------

CREATE TABLE graduado_registro (
    id_sede_fk INT NOT NULL REFERENCES sede(id_sede),
    id_programa_fk INT NOT NULL REFERENCES programa(id_programa),
    id_municipio_oferta_fk CHAR(5) NOT NULL REFERENCES municipio(id_municipio), -- Municipio donde se ofertó el programa
    id_sexo_fk INT NOT NULL REFERENCES sexo(id_sexo),
    semestre INT NOT NULL, -- 1 o 2
    graduados INT NOT NULL, -- MEDIDA

    -- Clave Primaria Compuesta (Combinación única de dimensiones)
    PRIMARY KEY (id_sede_fk, id_programa_fk, id_municipio_oferta_fk, id_sexo_fk, semestre)
);