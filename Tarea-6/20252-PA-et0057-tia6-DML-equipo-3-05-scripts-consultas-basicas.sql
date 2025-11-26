--
-- Tarea 6 - Parte #2 del Proyecto de Aula
-- SCRIPTS DE CONSULTAS BÁSICAS (SELECT sin JOIN)
--
-- Miembros del grupo
--Andrés Felipe Espinosa Ramirez
--
--

-- -----------------------------------------------------------
-- 4. CONSULTAS BÁSICAS CORREGIDAS (SELECT / Sin JOIN)
-- -----------------------------------------------------------

-- 1. Consulta con COUNT: Cuenta el número total de pacientes registrados.
SELECT
    COUNT(id_paciente) AS total_pacientes
FROM
    paciente
ORDER BY
    total_pacientes DESC;

-- 2. Consulta con MAX: Obtiene la fecha/hora más reciente de una atención médica 
SELECT
    MAX(fecha_hora) AS fecha_hora_mas_reciente_atencion
FROM
    atencion
ORDER BY
    fecha_hora_mas_reciente_atencion DESC;

-- 3. Consulta con MIN: Obtiene la fecha de emisión más antigua de las tarjetas de visita.
SELECT
    MIN(fecha_emision) AS primera_emision_tarjeta
FROM
    tarjeta_visita
ORDER BY
    1; -- Ordena por la primera columna seleccionada

-- 4. Consulta con AVG (CORREGIDA): Calcula el promedio de tarjetas de visita utilizadas por los pacientes.
SELECT
    AVG(tarjetas_utilizadas) AS promedio_tarjetas_utilizadas
FROM
    paciente
ORDER BY
    promedio_tarjetas_utilizadas;

-- 5. Consulta con SUM: Calcula la suma total de días de duración para tratamientos completados.
SELECT
    SUM(fecha_fin - fecha_inicio) AS duracion_total_tratamientos_dias
FROM
    tratamiento_paciente
WHERE
    fecha_fin IS NOT NULL
ORDER BY
    1 DESC;

-- -----------------------------------------------------------
-- Consultas Básicas Estándar (Sin Agregación)
-- -----------------------------------------------------------

-- 6. Lista todos los hospitales, ordenados alfabéticamente por nombre.
SELECT
    hospital_id,
    nombre_hospital,
    direccion
FROM
    hospital
ORDER BY
    nombre_hospital ASC;

-- 7. Muestra el ID, nombre y código profesional de todos los médicos, ordenados por código profesional.
SELECT
    medico_id,
    nombre_completo,
    codigo_profesional,
    telefono
FROM
    medico
ORDER BY
    codigo_profesional;

-- 8. Lista los diagnósticos (ID, código y descripción), ordenados por ID.
SELECT
    diagnostico_id,
    codigo_diag,
    descripcion
FROM
    diagnostico
ORDER BY
    diagnostico_id;

-- 9. Obtiene los detalles de todos los visitantes registrados, ordenados alfabéticamente por nombre completo.
SELECT
    paciente_id,
    nombre_completo,
    telefono
FROM
    visitante
ORDER BY
    nombre_completo;

-- 10. Muestra el ID de la planta, el piso y el hospital al que pertenece, ordenados por hospital.
SELECT
    planta_id,
    piso,
    hospital_id
FROM
    planta
ORDER BY
    hospital_id, piso DESC;

