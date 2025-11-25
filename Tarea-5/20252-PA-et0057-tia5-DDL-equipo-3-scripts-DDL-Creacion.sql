--
-- Tarea 5 - Parte #1 del Proyecto de Aula
-- SCRIPTS DE CREACIÓN DE LA BASE DE DATOS
--
-- Miembros del grupo
--Andrés Felipe Espinosa Ramirez
--Sebastian Tabares Reyes
--Manuel David Fuentes Fernandez


---- DDL PARTE 1: CREACIÓN INICIAL DE TABLAS (POSTGRESQL)

-- 1. Tablas Base (Sin dependencias FK)

CREATE TABLE ciudad_pais (
    ciudad_id SERIAL PRIMARY KEY,
    nombre_ciudad VARCHAR(100) NOT NULL,
    nombre_pais VARCHAR(100) NOT NULL,
    -- UK por nombre_ciudad y nombre_pais, según el comentario "unique por pais"
    UNIQUE (nombre_ciudad, nombre_pais)
);

CREATE TABLE eps (
    eps_id SERIAL PRIMARY KEY,
    codigo_eps VARCHAR(50) NOT NULL UNIQUE,
    nombre_eps VARCHAR(150) NOT NULL
);

CREATE TABLE especialidad (
    especialidad_id SERIAL PRIMARY KEY,
    nombre_especialidad VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE medico (
    medico_id SERIAL PRIMARY KEY,
    codigo_profesional VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    sexo CHAR(10) NOT NULL,
    especialidad_id INTEGER NOT NULL REFERENCES especialidad(especialidad_id),
    telefono VARCHAR(15)
);

CREATE TABLE diagnostico (
    diagnostico_id SERIAL PRIMARY KEY,
    codigo_diag VARCHAR(10) UNIQUE NOT NULL,
    descripcion TEXT NOT NULL
    -- CHECK de código_diag se añadirá en ALTER TABLE
);

CREATE TABLE tratamiento (
    trat_id SERIAL PRIMARY KEY,
    codigo_trat VARCHAR(50) UNIQUE NOT NULL,
    nombre_trat VARCHAR(100) NOT NULL,
    descripcion TEXT
);

CREATE TABLE medicamento (
    medicina_id SERIAL PRIMARY KEY,
    codigo_med VARCHAR(20) UNIQUE NOT NULL,
    nombre_med VARCHAR(150) NOT NULL,
    dosis_estandar VARCHAR(50)
);

-- 2. Tablas con Dependencias 

CREATE TABLE hospital (
    hospital_id SERIAL PRIMARY KEY,
    codigo_hospital VARCHAR(50) UNIQUE NOT NULL,
    nombre_hospital VARCHAR(200) NOT NULL,
    ciudad_id INTEGER NOT NULL REFERENCES ciudad_pais(ciudad_id)
);

CREATE TABLE planta (
    planta_id SERIAL PRIMARY KEY,
    hospital_id INTEGER NOT NULL REFERENCES hospital(hospital_id),
    piso INTEGER NOT NULL,
    UNIQUE (hospital_id, piso)
);

CREATE TABLE cuarto (
    cuarto_id SERIAL PRIMARY KEY,
    planta_id INTEGER NOT NULL REFERENCES planta(planta_id),
    numero_cuarto VARCHAR(20) NOT NULL, 
    UNIQUE (planta_id, numero_cuarto)
);

CREATE TABLE paciente (
    id_paciente SERIAL PRIMARY KEY, -- id_paciente
    nombre VARCHAR(100) NOT NULL,
    primer_apellido VARCHAR(100) NOT NULL,
    segundo_apellido VARCHAR(100) NOT NULL,
    cedula VARCHAR(20) UNIQUE NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    sexo VARCHAR(10) NOT NULL,
    ciudad_id INTEGER NOT NULL REFERENCES ciudad_pais(ciudad_id), -- Lugar de nacimiento
    eps_id INTEGER NOT NULL REFERENCES eps(eps_id),
    hospital_id INTEGER NOT NULL REFERENCES hospital(hospital_id),
    tarjetas_disponibles INTEGER NOT NULL,
    tarjetas_utilizadas INTEGER NOT NULL,
    fecha_alta TIMESTAMP, -- Nulo si aún está ingresado
    tel1 VARCHAR(20), 
    tel2 VARCHAR(20) 
    -- Los checks de tel1, tel2 y fechas se añaden en ALTER TABLE.
);

CREATE TABLE visitante (
    paciente_id INTEGER NOT NULL REFERENCES paciente(id_paciente), -- PK (Compuesta)
    numero_visitante INTEGER NOT NULL, -- PK (Compuesta)
    nombre_completo VARCHAR(150) NOT NULL,
    telefono VARCHAR(50),
    PRIMARY KEY (paciente_id, numero_visitante)
);

CREATE TABLE tarjeta_visita (
    tarjeta_id SERIAL PRIMARY KEY,
    paciente_id INTEGER NOT NULL REFERENCES paciente(id_paciente),
    numero_tarj INTEGER NOT NULL, 
    estado BOOLEAN,
    UNIQUE (paciente_id, numero_tarj)
    -- El CHECK del rango 1/2/3/4 se añade en ALTER TABLE.
);

CREATE TABLE visita (
    visita_id SERIAL PRIMARY KEY,
    numero_visitante INTEGER NOT NULL,
    paciente_id INTEGER NOT NULL,
    tarjeta_id INTEGER NOT NULL REFERENCES tarjeta_visita(tarjeta_id),
    fecha_hora TIMESTAMP NOT NULL,
    CONSTRAINT fk_visitante FOREIGN KEY (paciente_id, numero_visitante) REFERENCES visitante(paciente_id, numero_visitante)
    -- CHECKs se añadirán en ALTER TABLE.
);

CREATE TABLE medico_especialidad (
    medico_especialidad_id SERIAL PRIMARY KEY,
    medico_id INTEGER NOT NULL REFERENCES medico(medico_id),
    especialidad_id INTEGER NOT NULL REFERENCES especialidad(especialidad_id),
    UNIQUE (medico_id, especialidad_id)
);

CREATE TABLE medico_paciente (
    medico_paciente_id SERIAL PRIMARY KEY, -- Renombrada la PK
    paciente_id INTEGER NOT NULL REFERENCES paciente(id_paciente),
    medico_id INTEGER NOT NULL REFERENCES medico(medico_id),
    rol VARCHAR(50) NOT NULL,
    UNIQUE (paciente_id, medico_id) -- Asegura que un médico solo puede estar asignado una vez a un paciente
);

CREATE TABLE atencion (
    atencion_id SERIAL PRIMARY KEY, -- PK renombrada
    medico_paciente_id INTEGER NOT NULL REFERENCES medico_paciente(medico_paciente_id), -- FK a la relación M:N
    fecha_hora TIMESTAMP NOT NULL,
    tipo VARCHAR(50) NOT NULL 
);

CREATE TABLE enfermera (
    enfermera_id SERIAL PRIMARY KEY,
    codigo_profesional VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(50),
    hospital_id INTEGER NOT NULL REFERENCES hospital(hospital_id), -- FK al hospital de asignación
    sexo CHAR(1) NOT NULL,
    estado BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE enfermera_paciente (
    enfermera_paciente_id SERIAL PRIMARY KEY,
    enfermera_id INTEGER NOT NULL REFERENCES enfermera(enfermera_id),
    paciente_id INTEGER NOT NULL REFERENCES paciente(id_paciente),
    fecha_asignacion TIMESTAMP, 
    turno VARCHAR(20),
    UNIQUE (enfermera_id, paciente_id, fecha_asignacion)
    -- CHECK de 'turno' se añadirá en ALTER TABLE
);

CREATE TABLE diagnostico_paciente (
    diag_paciente_id SERIAL PRIMARY KEY,
    atencion_id INTEGER NOT NULL REFERENCES atencion(atencion_id), -- FK a la atención donde se registró el diagnóstico
    diag_id INTEGER NOT NULL REFERENCES diagnostico(diagnostico_id), -- FK al diagnóstico (catalogo de diagnósticos)
    descripcion TEXT, -- Campo de descripción o nota del diagnóstico en esta atención
    UNIQUE (atencion_id, diag_id) -- Un diagnóstico específico solo se registra una vez por atención
);

CREATE TABLE diagnostico_medico (
    diag_medico_id SERIAL PRIMARY KEY,
    diag_paciente_id INTEGER NOT NULL REFERENCES diagnostico_paciente(diag_paciente_id),
    medico_id INTEGER NOT NULL REFERENCES medico(medico_id), 
    rol VARCHAR(50) NOT NULL,
    UNIQUE (diag_paciente_id, medico_id, rol) 
);

CREATE TABLE tratamiento_paciente (
    paciente_trat_id SERIAL PRIMARY KEY,
    paciente_id INTEGER NOT NULL REFERENCES paciente(id_paciente),
    trat_id INTEGER NOT NULL REFERENCES tratamiento(trat_id),
    diag_medico INTEGER NOT NULL REFERENCES diagnostico_medico(diag_medico_id),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    descripcion TEXT,
    UNIQUE (paciente_id, trat_id, fecha_inicio)
    -- CHECKs se añadirán en ALTER TABLE
);

CREATE TABLE tratamiento_medicamento (
    trat_medicamento_id SERIAL PRIMARY KEY,
    paciente_trat_id INTEGER NOT NULL REFERENCES tratamiento_paciente(paciente_trat_id),
    medicina_id INTEGER NOT NULL REFERENCES medicamento(medicina_id), 
    desc_dosis TEXT,
    UNIQUE (paciente_trat_id, medicina_id) --
);

CREATE TABLE asignacion (
    asig_id SERIAL PRIMARY KEY,
    paciente_id INTEGER NOT NULL REFERENCES paciente(id_paciente),
    cuarto_id INTEGER NOT NULL REFERENCES cuarto(cuarto_id),
    motivo_asignacion TEXT
);
