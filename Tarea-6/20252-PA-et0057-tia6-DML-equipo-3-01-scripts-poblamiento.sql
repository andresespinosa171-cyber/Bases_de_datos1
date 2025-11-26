--- INSERCIÓN DE DATOS: SCRIPT FINAL Y LIMPIO
--- ----------------------------------------------------------------------

-- 1. Tablas Base (Nivel 0: Sin dependencias)
-- ----------------------------------------
INSERT INTO ciudad_pais (nombre_ciudad, nombre_pais) VALUES
('Medellín', 'Colombia'), ('Bogotá', 'Colombia'), ('Cali', 'Colombia'), ('Barranquilla', 'Colombia'), ('Cartagena', 'Colombia'),
('Bello', 'Colombia'), ('Envigado', 'Colombia'), ('Itagüí', 'Colombia'), ('Rionegro', 'Colombia'), ('Santa Marta', 'Colombia');

INSERT INTO eps (codigo_eps, razon_social_eps) VALUES
('EPS001', 'SURA S.A.S.'), ('EPS002', 'NUEVA EPS'), ('EPS003', 'SALUD TOTAL E.P.S.'), ('EPS004', 'COOMEVA EPS'), ('EPS005', 'SANITAS EPS'),
('EPS006', 'COMPENSAR EPS'), ('EPS007', 'ALIANSALUD'), ('EPS008', 'FAMISANAR EPS'), ('EPS009', 'EPM SALUD'), ('EPS010', 'SERVICIO OCCIDENTAL DE SALUD');

INSERT INTO especialidad (nombre_especialidad) VALUES
('Cardiología'), ('Neurología'), ('Medicina Interna'), ('Pediatría'), ('Ortopedia'),
('Oncología'), ('Urología'), ('Ginecología'), ('Dermatología'), ('Endocrinología');

INSERT INTO tratamiento (codigo_trat, nombre_trat, detalles_tratamiento) VALUES
('TRT001', 'Terapia de Hidratación', 'Administración intravenosa de fluidos y electrolitos.'),
('TRT002', 'Monitorización Cardiaca', 'Supervisión continua de la actividad cardíaca.'),
('TRT003', 'Rehabilitación Neurológica', 'Ejercicios y terapias para recuperar funciones nerviosas.'),
('TRT004', 'Tratamiento antibiótico', 'Administración de antibióticos de amplio espectro.'),
('TRT005', 'Fisioterapia Respiratoria', 'Técnicas de drenaje postural y ejercicios respiratorios.'),
('TRT006', 'Control de Diabetes', 'Ajuste de dosis de insulina y educación nutricional.'),
('TRT007', 'Diálisis Renal', 'Procedimiento de hemodiálisis de 4 horas.'),
('TRT008', 'Cirugía Menor', 'Extracción de quiste sebáceo con anestesia local.'),
('TRT009', 'Cuidados Paliativos', 'Manejo integral del dolor y soporte emocional.'),
('TRT010', 'Terapia Ocupacional', 'Rehabilitación de habilidades motoras finas.');

INSERT INTO medicamento (codigo_med, nombre_med, dosis_estandar) VALUES
('M001', 'Paracetamol 500mg', 'Oral: 1 Tableta'), ('M002', 'Suero Fisiológico 0.9%', 'Intravenosa: 1000ml'), ('M003', 'Dexametasona 4mg', 'Intramuscular: 1 Ampolla'),
('M004', 'Morfina', 'Intravenosa: 5mg'), ('M005', 'Insulina Rápida', 'Subcutánea: 10 UI'), ('M006', 'Omeprazol 20mg', 'Oral: 1 Cápsula'),
('M007', 'Diazepam 5mg', 'Oral: 1 Tableta'), ('M008', 'Sertralina 50mg', 'Oral: 1 Tableta'), ('M009', 'Aspirina 100mg', 'Oral: 1 Tableta'),
('M010', 'Amoxicilina 500mg', 'Oral: 1 Cápsula');

INSERT INTO diagnostico (codigo_diag, descripcion) VALUES
('I50.9', 'Fallo cardíaco no especificado'), ('J18.9', 'Neumonía no especificada'), ('G40.9', 'Epilepsia no especificada'),
('E10.9', 'Diabetes tipo 1'), ('K35.8', 'Apendicitis aguda'), ('N20.0', 'Cálculo renal'),
('A09', 'Gastroenteritis'), ('R51', 'Cefalea'), ('M17.9', 'Osteoartritis de rodilla'), ('T07', 'Traumatismos múltiples');


-- 2. Tablas Nivel 1 (FKs a Tablas Base)
-- ----------------------------------------
-- 2.1. Tabla hospital (FK a ciudad_pais)
INSERT INTO hospital (codigo_hospital, nombre_hospital, ciudad_id, direccion)
SELECT
    'HOS' || LPAD(CAST(s AS TEXT), 2, '0'),
    'Hospital ' || CAST(s AS TEXT) || ' de ' || (SELECT nombre_ciudad FROM ciudad_pais OFFSET (s - 1) % 10 LIMIT 1),
    (SELECT ciudad_id FROM ciudad_pais OFFSET (s - 1) % 10 LIMIT 1),
    'Carrera 45 # ' || s || ' - 0'
FROM generate_series(1, 10) AS s;

-- 2.2. Tabla medico (FK a especialidad)
INSERT INTO medico (codigo_profesional, nombre_completo, sexo, especialidad_id, telefono, estado)
SELECT
    'MED' || LPAD(CAST(s AS TEXT), 4, '0'),
    'Dr/a. Nombre ' || CAST(s AS TEXT) || ' Apellido',
    CASE WHEN s % 2 = 1 THEN 'M' ELSE 'F' END,
    (SELECT especialidad_id FROM especialidad OFFSET (s - 1) % 10 LIMIT 1),
    '310' || LPAD(CAST(s * 10000 + 1 AS TEXT), 7, '0'),
    (s % 5 <> 0)
FROM generate_series(1, 30) AS s;

-- 2.3. Tabla planta (FK a hospital)
INSERT INTO planta (hospital_id, piso)
SELECT
    (SELECT hospital_id FROM hospital OFFSET (s - 1) % 10 LIMIT 1),
    (s % 5) + 1
FROM generate_series(1, 10) AS s;

-- 2.4. Tabla enfermera (FK a hospital)
INSERT INTO enfermera (licencia_profesional, nombre, telefono, hospital_id, sexo, estado)
SELECT
    'ENF' || LPAD(CAST(s AS TEXT), 4, '0'),
    'Enfermera ' || CAST(s AS TEXT),
    '300' || LPAD(CAST(s * 1000 + 1 AS TEXT), 7, '0'),
    (SELECT hospital_id FROM hospital OFFSET (s - 1) % 10 LIMIT 1),
    CASE WHEN s % 2 = 1 THEN 'F' ELSE 'M' END,
    TRUE
FROM generate_series(1, 10) AS s;


-- 3. Tablas Nivel 2 (Tablas dependientes de Hospital y la CRÍTICA 'paciente')
-- ----------------------------------------
-- 3.1. Tabla paciente (¡CRÍTICO!)
INSERT INTO paciente (cedula, nombre, primer_apellido, segundo_apellido, email, fecha_nacimiento, sexo, eps_id, ciudad_id, hospital_id, tarjetas_disponibles, tarjetas_utilizadas, telefono_principal, tel2, fecha_alta)
SELECT
    CAST(100000000 + s AS TEXT),
    'Paciente Nombre ' || CAST(s AS TEXT),
    'Apellido1',
    'Apellido2',
    'paciente' || s || '@hceantioquia.com',
    (CURRENT_DATE - INTERVAL '1 day' * (s * 100 % 365 + 18250)),
    CASE WHEN s % 2 = 1 THEN 'F' ELSE 'M' END,
    (SELECT eps_id FROM eps OFFSET (s - 1) % 10 LIMIT 1),
    (SELECT ciudad_id FROM ciudad_pais OFFSET (s - 1) % 10 LIMIT 1),
    (SELECT hospital_id FROM hospital OFFSET (s - 1) % 10 LIMIT 1),
    5,
    0,
    '310' || LPAD(CAST(s * 1000 + 2 AS TEXT), 7, '0'),
    '300' || LPAD(CAST(s * 1000 + 1 AS TEXT), 7, '0'),
    CASE WHEN s % 5 = 0 THEN CURRENT_DATE - INTERVAL '1 day' * (s % 30 - 5) ELSE NULL END
FROM generate_series(1, 100) AS s;

-- 3.2. Tabla cuarto (FK a planta)
INSERT INTO cuarto (planta_id, numero_cuarto)
SELECT
    (SELECT planta_id FROM planta OFFSET (s - 1) % 10 LIMIT 1),
    s * 10 + 1
FROM generate_series(1, 10) AS s;

-- 3.3. Tabla tarjeta_visita (FK a paciente)
INSERT INTO tarjeta_visita (paciente_id, numero_tarj, estado)
SELECT
    s,
    (s % 3) + 1,
    TRUE
FROM generate_series(1, 10) AS s;

-- 3.4. Tabla visitante (FK a paciente)
INSERT INTO visitante (paciente_id, numero_visitante, nombre_completo, telefono)
SELECT
    s,
    (s % 3) + 1,
    'Visitante ' || CAST(s AS TEXT) || ' Apellido',
    '321' || LPAD(CAST(s * 1000 + 1 AS TEXT), 7, '0')
FROM generate_series(1, 10) AS s;


-- 4. Tablas Nivel 3 (Relacionales y Atenciones)
-- ----------------------------------------
-- 4.1. Tabla asignacion (FK a paciente, cuarto)
INSERT INTO asignacion (paciente_id, cuarto_id, motivo_asignacion)
SELECT
    s,
    (SELECT cuarto_id FROM cuarto OFFSET (s - 1) % 10 LIMIT 1),
    'Asignación inicial por patología ' || s
FROM generate_series(1, 100) AS s;

-- 4.2. Tabla medico_especialidad (FK a medico, especialidad)
INSERT INTO medico_especialidad (medico_id, especialidad_id)
SELECT
    (SELECT medico_id FROM medico OFFSET s - 1 LIMIT 1),
    (SELECT especialidad_id FROM especialidad OFFSET (s - 1) % 10 LIMIT 1)
FROM generate_series(1, 10) AS s;

-- 4.3. Tabla medico_paciente (FK a medico, paciente)
INSERT INTO medico_paciente (medico_id, paciente_id, rol)
SELECT
    (SELECT medico_id FROM medico OFFSET s - 1 LIMIT 1),
    (SELECT id_paciente FROM paciente OFFSET s - 1 LIMIT 1),
    CASE WHEN s % 2 = 0 THEN 'tratante' ELSE 'consultor' END
FROM generate_series(1, 10) AS s;

-- 4.4. Tabla atencion (FK a medico_paciente)
INSERT INTO atencion (medico_paciente_id, fecha_hora, tipo)
SELECT
    (SELECT medico_paciente_id FROM medico_paciente OFFSET s - 1 LIMIT 1),
    CURRENT_TIMESTAMP - INTERVAL '1 hour' * (s % 10),
    'Control de evolución'
FROM generate_series(1, 10) AS s;

-- 4.5. Tabla enfermera_paciente (FK a enfermera, paciente)
INSERT INTO enfermera_paciente (enfermera_id, paciente_id, fecha_asignacion, turno)
SELECT
    (SELECT enfermera_id FROM enfermera OFFSET (s - 1) % 10 LIMIT 1),
    (SELECT id_paciente FROM paciente OFFSET s - 1 LIMIT 1),
    CURRENT_TIMESTAMP - INTERVAL '1 hour' * (s % 5 + 1),
    CASE WHEN s % 2 = 0 THEN 'Diurno' ELSE 'Nocturno' END
FROM generate_series(1, 10) AS s;

-- 4.6. Tabla visita (FK a paciente, visitante, tarjeta_visita)
INSERT INTO visita (paciente_id, numero_visitante, tarjeta_id, fecha_hora, observaciones)
SELECT
    (SELECT paciente_id FROM visitante OFFSET s - 1 LIMIT 1),
    (SELECT numero_visitante FROM visitante OFFSET s - 1 LIMIT 1),
    (SELECT tarjeta_id FROM tarjeta_visita OFFSET s - 1 LIMIT 1),
    CURRENT_TIMESTAMP - INTERVAL '1 hour' * (s % 10 + 1),
    'Familiares trajeron elementos personales.'
FROM generate_series(1, 10) AS s;


-- 5. Tablas Nivel 4 (Tratamiento y Diagnóstico Detallado)
-- ----------------------------------------
-- 5.1. Tabla diagnostico_paciente (FK a diagnostico, atencion)
INSERT INTO diagnostico_paciente (diag_id, atencion_id, descripcion)
SELECT
    (SELECT diagnostico_id FROM diagnostico OFFSET (s - 1) % 10 LIMIT 1),
    (SELECT atencion_id FROM atencion OFFSET s - 1 LIMIT 1),
    'Diagnóstico confirmado al ingreso. Se requiere tratamiento inmediato.'
FROM generate_series(1, 10) AS s;

-- 5.2. Tabla diagnostico_medico (FK a diag_paciente, medico)
INSERT INTO diagnostico_medico (diag_paciente_id, medico_id, rol)
SELECT
    (SELECT diag_paciente_id FROM diagnostico_paciente OFFSET s - 1 LIMIT 1),
    (SELECT medico_id FROM medico OFFSET (s - 1) % 30 LIMIT 1),
    CASE (s % 4)
        WHEN 0 THEN 'diagnosticador'
        WHEN 1 THEN 'confirmador'
        WHEN 2 THEN 'consultor'
        ELSE 'revisor'
    END
FROM generate_series(1, 10) AS s;

-- 5.3. Tabla tratamiento_paciente (FK a paciente, tratamiento, diag_medico)
INSERT INTO tratamiento_paciente (paciente_id, trat_id, diag_medico, fecha_inicio, fecha_fin, descripcion)
SELECT
    (SELECT id_paciente FROM paciente OFFSET s - 1 LIMIT 1),
    (SELECT trat_id FROM tratamiento OFFSET (s - 1) % 10 LIMIT 1),
    (SELECT diag_medico_id FROM diagnostico_medico OFFSET s - 1 LIMIT 1),
    CURRENT_DATE - INTERVAL '10 day' * (s % 5 + 1),
    CASE WHEN s % 3 = 0 THEN CURRENT_DATE - INTERVAL '5 day' * (s % 5 + 1) ELSE NULL END,
    'Inicio de tratamiento ' || CAST(s AS TEXT) || ' según las directrices médicas.'
FROM generate_series(1, 10) AS s;

-- 5.4. Tabla tratamiento_medicamento (FK a paciente_trat, medicina)
INSERT INTO tratamiento_medicamento (paciente_trat_id, medicina_id, desc_dosis)
SELECT
    (SELECT paciente_trat_id FROM tratamiento_paciente OFFSET s - 1 LIMIT 1),
    (SELECT medicina_id FROM medicamento OFFSET (s - 1) % 10 LIMIT 1),
    'Dosis: ' || CAST((s % 3) + 1 AS TEXT) || ' veces al día, por 7 días.'
FROM generate_series(1, 10) AS s;