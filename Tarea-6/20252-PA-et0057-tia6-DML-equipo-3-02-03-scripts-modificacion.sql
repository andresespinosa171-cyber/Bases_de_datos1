----------------------------------------------------------------------
-- PARTE 2: ACTUALIZACIONES (UPDATE) - 30 Sentencias
----------------------------------------------------------------------

-- A. 5 Actualizaciones en PACIENTES (Tabla: paciente)
-- --------------------------------------------------
-- 1. Actualizar email para el paciente 1
UPDATE paciente
SET email = 'paciente_uno_nuevo@hceantioquia.com'
WHERE id_paciente = 1;

-- 2. Actualizar teléfono principal para el paciente 2
UPDATE paciente
SET telefono_principal = '3112223344'
WHERE id_paciente = 2;

-- 3. Incrementar tarjetas disponibles para el paciente 3
UPDATE paciente
SET tarjetas_disponibles = tarjetas_disponibles + 5
WHERE id_paciente = 3;

-- 4. Actualizar tarjetas utilizadas para el paciente 4
UPDATE paciente
SET tarjetas_utilizadas = tarjetas_utilizadas + 1
WHERE id_paciente = 4;

-- 5. Dar de alta (fecha_alta) al paciente 5
UPDATE paciente
SET fecha_alta = CURRENT_DATE
WHERE id_paciente = 5 AND fecha_alta IS NULL;


-- B. 5 Actualizaciones en MÉDICOS (Tabla: medico)
-- ---------------------------------------------
-- 6. Desactivar el estado del médico 1
UPDATE medico
SET estado = FALSE
WHERE medico_id = 1;

-- 7. Actualizar teléfono del médico 2
UPDATE medico
SET telefono = '3129876543'
WHERE medico_id = 2;

-- 8. Actualizar nombre completo del médico 3
UPDATE medico
SET nombre_completo = 'Dr/a. Nuevo Nombre Apellido'
WHERE medico_id = 3;

-- 9. Actualizar código profesional del médico 4
UPDATE medico
SET codigo_profesional = 'MED0004_ACTUALIZADO'
WHERE medico_id = 4;

-- 10. Cambiar especialidad del médico 5 a una nueva existente
UPDATE medico
SET especialidad_id = 4
WHERE medico_id = 5;


-- C. 5 Actualizaciones en ESPECIALIDADES MÉDICAS (Tabla: especialidad)
-- ------------------------------------------------------------------
-- 11. Renombrar Cardiología
UPDATE especialidad
SET nombre_especialidad = 'Cardiología Intervencionista'
WHERE especialidad_id = 1;

-- 12. Renombrar Neurología
UPDATE especialidad
SET nombre_especialidad = 'Neurocirugía'
WHERE especialidad_id = 2;

-- 13. Renombrar Medicina Interna
UPDATE especialidad
SET nombre_especialidad = 'Infectología'
WHERE especialidad_id = 3;

-- 14. Renombrar Pediatría
UPDATE especialidad
SET nombre_especialidad = 'Neonatología'
WHERE especialidad_id = 4;

-- 15. Renombrar Ortopedia
UPDATE especialidad
SET nombre_especialidad = 'Traumatología'
WHERE especialidad_id = 5;


-- D. 5 Actualizaciones en ENFERMERAS (Tabla: enfermera)
-- ----------------------------------------------------
-- 16. Actualizar teléfono de la enfermera 1
UPDATE enfermera
SET telefono = '3001112233'
WHERE enfermera_id = 1;

-- 17. Desactivar el estado de la enfermera 2
UPDATE enfermera
SET estado = FALSE
WHERE enfermera_id = 2;

-- 18. Actualizar nombre de la enfermera 3
UPDATE enfermera
SET nombre = 'Enfermera Maria Lopez'
WHERE enfermera_id = 3;

-- 19. Transferir enfermera 4 a otro hospital (Hospital 2)
UPDATE enfermera
SET hospital_id = 2
WHERE enfermera_id = 4;

-- 20. Actualizar licencia profesional de la enfermera 5
UPDATE enfermera
SET licencia_profesional = 'ENF0005_NEW'
WHERE enfermera_id = 5;


-- E. 5 Actualizaciones en HOSPITALES (Tabla: hospital)
-- -------------------------------------------------
-- 21. Actualizar dirección del hospital 1
UPDATE hospital
SET direccion = 'Calle 10 # 50 - 20, Nuevo Bloque'
WHERE hospital_id = 1;

-- 22. Actualizar nombre del hospital 2
UPDATE hospital
SET nombre_hospital = 'Clínica Especializada del Norte'
WHERE hospital_id = 2;

-- 23. Cambiar ciudad de hospital 3 (Ciudad 5: Cartagena)
UPDATE hospital
SET ciudad_id = 5
WHERE hospital_id = 3;

-- 24. Actualizar código del hospital 4
UPDATE hospital
SET codigo_hospital = 'HOS04_ACT'
WHERE hospital_id = 4;

-- 25. Actualizar dirección del hospital 5
UPDATE hospital
SET direccion = 'Avenida Oriental # 100 - 30'
WHERE hospital_id = 5;


-- F. 5 Actualizaciones en HOSPITALIZACIONES (Tabla: asignacion)
-- ----------------------------------------------------------
-- 26. Cambiar motivo de asignación para la asignación 1
UPDATE asignacion
SET motivo_asignacion = 'Cambio de unidad por evolución positiva.'
WHERE asig_id = 1;

-- 27. Reasignar cuarto (cambio de habitación) para la asignación 2 (Cuarto 2)
UPDATE asignacion
SET cuarto_id = 2
WHERE asig_id = 2;

-- 28. Cambiar motivo de asignación para la asignación 3
UPDATE asignacion
SET motivo_asignacion = 'Necesidad de aislamiento por precaución.'
WHERE asig_id = 3;

-- 29. Reasignar cuarto (cambio de habitación) para la asignación 4 (Cuarto 4)
UPDATE asignacion
SET cuarto_id = 4
WHERE asig_id = 4;

-- 30. Cambiar motivo de asignación para la asignación 5
UPDATE asignacion
SET motivo_asignacion = 'Preparación pre-quirúrgica final.'
WHERE asig_id = 5;

--DELETE-------------------------------------------------------------------------------------
----------------------------------------------------------------------
-- PARTE 3: ELIMINACIONES (DELETE) - 27 Sentencias Solicitadas
----------------------------------------------------------------------

-- ************************************************************************************
-- LIMPIEZA DE DEPENDENCIAS: ORDEN ESTRICTO PARA EVITAR ERRORES DE FK
-- ************************************************************************************

-- A. Limpieza de la cadena de Tratamiento, Diagnóstico y Atención (Niveles más profundos)
-- 1. Eliminar tratamiento_medicamento
DELETE FROM tratamiento_medicamento WHERE paciente_trat_id IN (
    SELECT paciente_trat_id FROM tratamiento_paciente WHERE paciente_id IN (6, 7, 8, 9, 10)
);
-- 2. Eliminar tratamiento_paciente
DELETE FROM tratamiento_paciente WHERE paciente_id IN (6, 7, 8, 9, 10);
-- 3. Eliminar diagnostico_medico
DELETE FROM diagnostico_medico WHERE diag_paciente_id IN (
    SELECT diag_paciente_id FROM diagnostico_paciente WHERE atencion_id IN (
        SELECT atencion_id FROM atencion WHERE medico_paciente_id IN (6, 7, 8, 9, 10)
    )
) OR medico_id IN (6, 7, 8, 9, 10);
-- 4. Eliminar diagnostico_paciente
DELETE FROM diagnostico_paciente WHERE atencion_id IN (
    SELECT atencion_id FROM atencion WHERE medico_paciente_id IN (6, 7, 8, 9, 10)
);
-- 5. Eliminar atencion
DELETE FROM atencion WHERE medico_paciente_id IN (6, 7, 8, 9, 10);

-- B. Limpieza de Tablas de Relación M:N y Visitas
DELETE FROM medico_paciente WHERE medico_paciente_id IN (6, 7, 8, 9, 10);
DELETE FROM enfermera_paciente WHERE paciente_id IN (6, 7, 8, 9, 10) OR enfermera_id IN (6, 7, 8, 9, 10);
DELETE FROM visita WHERE paciente_id IN (6, 7, 8, 9, 10);
DELETE FROM tarjeta_visita WHERE paciente_id IN (6, 7, 8, 9, 10);
DELETE FROM visitante WHERE paciente_id IN (6, 7, 8, 9, 10);
-- Limpieza de medico_especialidad
DELETE FROM medico_especialidad WHERE medico_id IN (6, 7, 8, 9, 10) OR especialidad_id IN (9, 10);

-- C. Limpieza CRÍTICA de Asignaciones (Hospitalizaciones)
DELETE FROM asignacion WHERE cuarto_id BETWEEN 6 AND 10;

-- D. Romper la llave foránea de MEDICO a ESPECIALIDAD (Para eliminar las especialidades 9 y 10)
UPDATE medico
SET especialidad_id = 1
WHERE especialidad_id IN (9, 10);

-- **E. PASO CRÍTICO CORREGIDO: Romper la llave foránea de PACIENTE a HOSPITAL**
-- Reasigna ABSOLUTAMENTE a todos los pacientes que referencian a los hospitales 6-10.
-- ESTO RESUELVE EL ÚLTIMO ERROR REPORTADO.
UPDATE paciente
SET hospital_id = 1
WHERE hospital_id BETWEEN 6 AND 10;


-- ************************************************************************************
-- SENTENCIAS DELETE PRINCIPALES SOLICITADAS (TOTAL: 27 sentencias)
-- ************************************************************************************

-- 1. 5 Hospitalizaciones (Tabla: asignacion - IDs 6 a 10)
DELETE FROM asignacion WHERE asig_id = 6;
DELETE FROM asignacion WHERE asig_id = 7;
DELETE FROM asignacion WHERE asig_id = 8;
DELETE FROM asignacion WHERE asig_id = 9;
DELETE FROM asignacion WHERE asig_id = 10;

-- 2. Limpieza de la cadena de Ubicación (Cuarto y Planta)
DELETE FROM cuarto WHERE cuarto_id BETWEEN 6 AND 10;
DELETE FROM planta WHERE planta_id BETWEEN 6 AND 10;

-- 3. 5 Pacientes (Tabla: paciente - IDs 6 a 10)
DELETE FROM paciente WHERE id_paciente = 6;
DELETE FROM paciente WHERE id_paciente = 7;
DELETE FROM paciente WHERE id_paciente = 8;
DELETE FROM paciente WHERE id_paciente = 9;
DELETE FROM paciente WHERE id_paciente = 10;

-- 4. 5 Médicos (Tabla: medico - IDs 6 a 10)
DELETE FROM medico WHERE medico_id = 6;
DELETE FROM medico WHERE medico_id = 7;
DELETE FROM medico WHERE medico_id = 8;
DELETE FROM medico WHERE medico_id = 9;
DELETE FROM medico WHERE medico_id = 10;

-- 5. 5 Enfermeras (Tabla: enfermera - IDs 6 a 10)
DELETE FROM enfermera WHERE enfermera_id = 6;
DELETE FROM enfermera WHERE enfermera_id = 7;
DELETE FROM enfermera WHERE enfermera_id = 8;
DELETE FROM enfermera WHERE enfermera_id = 9;
DELETE FROM enfermera WHERE enfermera_id = 10;

-- 6. 2 Especialidades Médicas (Tabla: especialidad - IDs 9 y 10)
DELETE FROM especialidad WHERE especialidad_id = 9;
DELETE FROM especialidad WHERE especialidad_id = 10;

-- 7. 5 Hospitales (Tabla: hospital - IDs 6 a 10)
-- Ahora es seguro eliminar los hospitales, ya que todos los pacientes han sido reasignados.
DELETE FROM hospital WHERE hospital_id = 6;
DELETE FROM hospital WHERE hospital_id = 7;
DELETE FROM hospital WHERE hospital_id = 8;
DELETE FROM hospital WHERE hospital_id = 9;
DELETE FROM hospital WHERE hospital_id = 10;