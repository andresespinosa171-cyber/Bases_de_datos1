--
-- Tarea 6 - Parte #2 del Proyecto de Aula
-- SCRIPTS DE CREACIÓN y CONSULTAS DE UNA VISTA 
--
-- Miembros del grupo
--
--
--

-- -----------------------------------------------------------
-- 6. CREACIÓN Y USO DE VISTAS (VIEW)
-- -----------------------------------------------------------

-- A. CONSTRUCCIÓN DE LA SUPER VISTA (6 JOINs)
-- La vista une: Paciente -> Asignacion -> Cuarto -> Planta -> Hospital -> Ciudad_Pais -> EPS
-- Incluye la ubicación completa del paciente y su información de aseguramiento.

CREATE OR REPLACE VIEW vista_super_hospitalizacion AS
SELECT
    P.id_paciente,
    P.nombre || ' ' || P.primer_apellido AS nombre_completo_paciente,
    P.tarjetas_utilizadas,
    P.tarjetas_disponibles,
    ASIG.motivo_asignacion,
    ASIG.asig_id, -- ID de la asignación
    C.numero_cuarto,
    PL.piso AS numero_planta,
    H.nombre_hospital,
    CP.nombre_ciudad,
    CP.nombre_pais,
    E.razon_social_eps
FROM
    paciente P
JOIN
    asignacion ASIG ON P.id_paciente = ASIG.paciente_id      -- 1er JOIN
JOIN
    cuarto C ON ASIG.cuarto_id = C.cuarto_id                  -- 2do JOIN
JOIN
    planta PL ON C.planta_id = PL.planta_id                    -- 3er JOIN
JOIN
    hospital H ON PL.hospital_id = H.hospital_id              -- 4to JOIN
JOIN
    ciudad_pais CP ON H.ciudad_id = CP.ciudad_id              -- 5to JOIN
JOIN
    eps E ON P.eps_id = E.eps_id                               -- 6to JOIN
ORDER BY
    P.id_paciente;


-- -----------------------------------------------------------
-- B. CONSULTAS UTILIZANDO LA VISTA
-- -----------------------------------------------------------

-- 1. Consulta con COUNT y GROUP BY: Cuenta el número total de pacientes asignados por EPS.
SELECT
    razon_social_eps,
    COUNT(id_paciente) AS total_pacientes_asignados
FROM
    vista_super_hospitalizacion
GROUP BY
    razon_social_eps
ORDER BY
    total_pacientes_asignados DESC;

-- 2. Consulta con SUM y GROUP BY: Suma el total de tarjetas de visita utilizadas por cada hospital.
SELECT
    nombre_hospital,
    SUM(tarjetas_utilizadas) AS suma_tarjetas_utilizadas
FROM
    vista_super_hospitalizacion
GROUP BY
    nombre_hospital
ORDER BY
    suma_tarjetas_utilizadas DESC;

-- 3. Consulta con MAX y GROUP BY: Encuentra el número máximo de tarjetas utilizadas por paciente por cada ciudad donde hay un hospital.
SELECT
    nombre_ciudad,
    MAX(tarjetas_utilizadas) AS max_tarjetas_utilizadas_en_ciudad
FROM
    vista_super_hospitalizacion
GROUP BY
    nombre_ciudad
ORDER BY
    max_tarjetas_utilizadas_en_ciudad DESC;

-- 4. Consulta con MIN y GROUP BY: Mínimo de tarjetas disponibles por paciente en cada planta (piso) y hospital.
SELECT
    nombre_hospital,
    numero_planta,
    MIN(tarjetas_disponibles) AS min_tarjetas_disponibles
FROM
    vista_super_hospitalizacion
GROUP BY
    nombre_hospital, numero_planta
ORDER BY
    nombre_hospital, numero_planta ASC;

-- 5. Consulta con AVG y GROUP BY: Calcula el promedio de tarjetas utilizadas por el motivo de asignación.
SELECT
    motivo_asignacion,
    AVG(tarjetas_utilizadas) AS promedio_tarjetas_utilizadas
FROM
    vista_super_hospitalizacion
GROUP BY
    motivo_asignacion
ORDER BY
    promedio_tarjetas_utilizadas DESC;