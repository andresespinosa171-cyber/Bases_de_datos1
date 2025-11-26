-- LIMPIEZA INICIAL: Es esencial ejecutar esta línea primero para cerrar cualquier
-- transacción fallida pendiente (ERROR 25P02 de sesiones anteriores).
ROLLBACK;

-- ----------------------------------------------------------------------
-- A. VALIDACIÓN DE INSERT (3 OPERACIONES)
-- Se usa 'sexo' en lugar de 'genero' y 'cedula' como identificador.
-- ----------------------------------------------------------------------

-- 1. INSERT EXITOSO (Demuestra ATOMICIDAD y DURABILIDAD)
-- Se inserta un nuevo registro y se confirma (COMMIT), garantizando que el cambio es indivisible y permanente.
BEGIN;
    INSERT INTO paciente (nombre, primer_apellido, segundo_apellido, fecha_nacimiento, sexo, cedula, telefono_principal, email, eps_id, hospital_id, ciudad_id, tarjetas_disponibles, tarjetas_utilizadas)
    VALUES ('Prueba', 'ACID', 'Durabilidad', '1990-01-01', 'M', 'C-ACID-1', '123456789', 'acid.test.c1@temp.com', 1, 1, 1, 10, 0);
COMMIT;
-- RESULTADO: El paciente C-ACID-1 es insertado permanentemente (A y D).

-- 2. INSERT FALLIDO (Demuestra CONSISTENCIA)
-- Se intenta insertar un registro que viola la restricción UNIQUE NOT NULL del campo email.
BEGIN;
    -- Intenta insertar con el EMAIL que ya existe ('acid.test.c1@temp.com')
    INSERT INTO paciente (nombre, primer_apellido, segundo_apellido, fecha_nacimiento, sexo, cedula, telefono_principal, email, eps_id, hospital_id, ciudad_id, tarjetas_disponibles, tarjetas_utilizadas)
    VALUES ('Error', 'Prueba', 'Consistencia', '1995-05-05', 'F', 'C-ACID-2', '987654321', 'acid.test.c1@temp.com', 1, 1, 1, 10, 0);
-- ERROR ESPERADO: violación de la restricción UNIQUE 'paciente_email_key'.
ROLLBACK;
-- RESULTADO: La base de datos rechaza la operación, manteniendo la Consistencia (C).

-- 3. BLOQUE INSERT con ROLLBACK (Demuestra ATOMICIDAD)
-- Se insertan múltiples registros, pero la transacción se deshace (ROLLBACK), asegurando que ninguna de las partes se aplique.
BEGIN;
    INSERT INTO paciente (nombre, primer_apellido, segundo_apellido, fecha_nacimiento, sexo, cedula, telefono_principal, email, eps_id, hospital_id, ciudad_id, tarjetas_disponibles, tarjetas_utilizadas)
    VALUES ('Temporal', 'Rollback', 'Uno', '2000-01-01', 'M', 'C-ACID-3', '111', 'acid.test.c3@temp.com', 1, 1, 1, 10, 0);
    INSERT INTO paciente (nombre, primer_apellido, segundo_apellido, fecha_nacimiento, sexo, cedula, telefono_principal, email, eps_id, hospital_id, ciudad_id, tarjetas_disponibles, tarjetas_utilizadas)
    VALUES ('Temporal', 'Rollback', 'Dos', '2000-02-02', 'F', 'C-ACID-4', '222', 'acid.test.c4@temp.com', 1, 1, 1, 10, 0);
ROLLBACK;
-- RESULTADO: Ambos pacientes son descartados. Se verifica la Atomicidad (A).


-- **********************************************************************
-- B. VALIDACIÓN DE UPDATE (3 OPERACIONES)
-- **********************************************************************

-- 4. UPDATE EXITOSO (Demuestra ATOMICIDAD y DURABILIDAD)
-- La actualización del registro se confirma, siendo el cambio completo y persistente.
BEGIN;
    -- Actualizar el teléfono del paciente de prueba usando su cédula
    UPDATE paciente
    SET telefono_principal = '5555-5555'
    WHERE cedula = 'C-ACID-1';
COMMIT;
-- RESULTADO: El teléfono es actualizado permanentemente (A y D).

-- 5. UPDATE FALLIDO (Demuestra CONSISTENCIA)
-- Intenta violar la restricción CHECK de fecha_fin >= fecha_inicio en tratamiento_paciente.
BEGIN;
    -- Asumiendo que paciente_trat_id=1 existe y tiene fecha_inicio posterior
    UPDATE tratamiento_paciente
    SET fecha_fin = '2024-01-01'
    WHERE paciente_trat_id = 1;
-- ERROR ESPERADO: violación de la restricción CHECK 'check_fechas_tratamiento'.
ROLLBACK;
-- RESULTADO: La base de datos no acepta el estado inconsistente. Se mantiene la Consistencia (C).

-- 6. BLOQUE UPDATE con ROLLBACK (Demuestra ATOMICIDAD)
-- Se modifica el nombre de un paciente, pero el cambio se anula con el ROLLBACK.
BEGIN;
    -- Se cambia temporalmente el nombre del paciente de prueba
    UPDATE paciente
    SET nombre = 'Nombre_Temporal'
    WHERE cedula = 'C-ACID-1';
ROLLBACK;
-- RESULTADO: El nombre del paciente revierte a 'Prueba'. Se confirma la Atomicidad (A).


-- **********************************************************************
-- C. VALIDACIÓN DE DELETE (3 OPERACIONES)
-- **********************************************************************

-- 7. DELETE EXITOSO (Demuestra ATOMICIDAD y DURABILIDAD)
-- El registro del paciente se elimina y se confirma, siendo la eliminación total y permanente.
BEGIN;
    -- Eliminar el paciente de prueba (C-ACID-1)
    DELETE FROM paciente
    WHERE cedula = 'C-ACID-1';
COMMIT;
-- RESULTADO: El paciente es eliminado de forma permanente (A y D).

-- 8. DELETE FALLIDO (Demuestra CONSISTENCIA)
-- Intenta eliminar una EPS que tiene pacientes dependientes (violación de Clave Foránea).
BEGIN;
    -- Intenta eliminar la EPS 1
    DELETE FROM eps
    WHERE eps_id = 1;
-- ERROR ESPERADO: violación de la restricción FOREIGN KEY 'paciente_eps_id_fkey'.
ROLLBACK;
-- RESULTADO: La EPS 1 no se elimina. La integridad referencial y la Consistencia (C) se mantienen.
-- 9. BLOQUE DELETE con ROLLBACK (Demuestra ATOMICIDAD) - FINAL
-- Usa la tabla 'visita' que tiene FK a (paciente_id, numero_visitante)

BEGIN;

    -- Borra el registro del visitante dentro de la transacción.
    DELETE FROM visitante
    WHERE paciente_id = 1 AND numero_visitante = 1; 

-- ROLLBACK revierte el DELETE, el registro no se borra permanentemente.
ROLLBACK;
-- RESULTADO: El registro de la visita es restaurado.