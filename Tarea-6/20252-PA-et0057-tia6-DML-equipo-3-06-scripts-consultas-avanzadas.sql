--
-- Tarea 6 - Parte #2 del Proyecto de Aula
-- SCRIPTS DE CONSULTAS AVANZADAS (SELECT con JOIN)
--
-- Miembros del grupo
--
--
--

-- -----------------------------------------------------------
-- 5. CONSULTAS AVANZADAS (SELECT / Con JOIN)
-- -----------------------------------------------------------

-- A. CONSULTAS CON 1 JOIN (3)

-- 1. COUNT (1 JOIN): Cuenta el número de pacientes por (EPS).
SELECT
    E.razon_social_eps,
    COUNT(P.id_paciente) AS total_pacientes
FROM
    paciente P
JOIN
    eps E ON P.eps_id = E.eps_id
GROUP BY
    E.razon_social_eps
ORDER BY
    total_pacientes DESC;

-- 2. MIN (1 JOIN): Encuentra la fecha de emisión más antigua de una tarjeta de visita para cada paciente.
SELECT
    P.nombre || ' ' || P.primer_apellido || ' ' || P.segundo_apellido AS nombre_paciente,
    MIN(T.fecha_emision) AS primera_fecha_tarjeta
FROM
    tarjeta_visita T
JOIN
    paciente P ON T.paciente_id = P.id_paciente
GROUP BY
    P.id_paciente, nombre_paciente
ORDER BY
    primera_fecha_tarjeta ASC;

-- 3. (1 JOIN): Lista los pacientes y el nombre de su ciudad de nacimiento.
SELECT
    P.nombre || ' ' || P.primer_apellido || ' ' || P.segundo_apellido AS nombre_paciente,
    C.nombre_ciudad,
    C.nombre_pais
FROM
    paciente P
JOIN
    ciudad_pais C ON P.ciudad_id = C.ciudad_id
ORDER BY
    P.primer_apellido ASC;

-- -----------------------------------------------------------
-- B. CONSULTAS CON 2 JOINs (3)
-- -----------------------------------------------------------

-- 4. MAX (2 JOINs): Fecha y hora de la última atención registrada por cada médico.
SELECT
    M.nombre_completo AS nombre_medico,
    MAX(A.fecha_hora) AS ultima_atencion
FROM
    atencion A
JOIN
    medico_paciente MP ON A.medico_paciente_id = MP.medico_paciente_id
JOIN
    medico M ON MP.medico_id = M.medico_id
GROUP BY
    M.nombre_completo
ORDER BY
    ultima_atencion DESC;

-- 5. SUM (2 JOINs): Suma el total de tarjetas de visita disponibles por hospital.
SELECT
    H.nombre_hospital,
    SUM(P.tarjetas_disponibles) AS total_tarjetas_disponibles
FROM
    paciente P
JOIN
    hospital H ON P.hospital_id = H.hospital_id
GROUP BY
    H.nombre_hospital
ORDER BY
    total_tarjetas_disponibles DESC;

-- 6. (2 JOINs): Lista las enfermeras y el nombre del hospital donde están asignadas.
SELECT
    E.nombre AS nombre_enfermera,
    E.licencia_profesional,
    H.nombre_hospital
FROM
    enfermera E
JOIN
    hospital H ON E.hospital_id = H.hospital_id
ORDER BY
    H.nombre_hospital, E.nombre;

-- -----------------------------------------------------------
-- C. CONSULTAS CON 3 JOINs (2)
-- -----------------------------------------------------------

-- 7. AVG (3 JOINs): Calcula el promedio de tarjetas utilizadas por pacientes de cada hospital.
SELECT
    H.nombre_hospital,
    AVG(P.tarjetas_utilizadas) AS promedio_tarjetas_utilizadas
FROM
    paciente P
JOIN
    hospital H ON P.hospital_id = H.hospital_id
JOIN
    ciudad_pais C ON H.ciudad_id = C.ciudad_id -- Tercer JOIN
GROUP BY
    H.nombre_hospital
ORDER BY
    promedio_tarjetas_utilizadas DESC;

-- 8. (3 JOINs): Muestra la fecha/hora de la atención y los detalles del diagnóstico.
SELECT
    A.fecha_hora,
    D.codigo_diag,
    D.descripcion AS descripcion_diagnostico
FROM
    atencion A
JOIN
    diagnostico_paciente DP ON A.atencion_id = DP.atencion_id
JOIN
    diagnostico D ON DP.diag_id = D.diagnostico_id
ORDER BY
    A.fecha_hora DESC;

-- -----------------------------------------------------------
-- D. CONSULTAS CON 4 JOINs (1)
-- -----------------------------------------------------------

-- 9. (4 JOINs) - Muestra paciente, su EPS, médico asignado y especialidad del médico.
SELECT
    P.nombre || ' ' || P.primer_apellido AS nombre_paciente,
    E.razon_social_eps,
    M.nombre_completo AS nombre_medico_asignado,
    ES.nombre_especialidad
FROM
    paciente P
JOIN
    eps E ON P.eps_id = E.eps_id
JOIN
    medico_paciente MP ON P.id_paciente = MP.paciente_id
JOIN
    medico M ON MP.medico_id = M.medico_id
JOIN
    especialidad ES ON M.especialidad_id = ES.especialidad_id
WHERE
    MP.rol = 'consultor' -- Corregido para usar uno de los roles reales
    -- Si desea ver todos los médicos asignados, solo elimine la línea WHERE.
ORDER BY
    P.primer_apellido;
	
-- -----------------------------------------------------------
-- E. CONSULTAS CON 5 JOINs (1)
-- -----------------------------------------------------------

-- 10. (5 JOINs): Muestra paciente, cuarto, planta y ciudad del hospital.
SELECT
    P.nombre || ' ' || P.primer_apellido AS nombre_paciente,
    ASIG.motivo_asignacion,
    C.numero_cuarto,
    PL.piso AS numero_planta,
    CP.nombre_ciudad
FROM
    paciente P
JOIN
    asignacion ASIG ON P.id_paciente = ASIG.paciente_id -- 1er JOIN
JOIN
    cuarto C ON ASIG.cuarto_id = C.cuarto_id -- 2do JOIN
JOIN
    planta PL ON C.planta_id = PL.planta_id -- 3er JOIN
JOIN
    hospital H ON PL.hospital_id = H.hospital_id -- 4to JOIN
JOIN
    ciudad_pais CP ON H.ciudad_id = CP.ciudad_id -- 5to JOIN
ORDER BY
    CP.nombre_ciudad, PL.piso, C.numero_cuarto;
