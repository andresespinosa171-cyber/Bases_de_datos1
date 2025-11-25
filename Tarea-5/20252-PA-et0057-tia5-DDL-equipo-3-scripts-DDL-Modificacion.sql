--
-- Tarea 5 - Parte #1 del Proyecto de Aula
-- SCRIPTS DE MODIFICACIÓN DE LA BASE DE DATOS
--
-- Andrés Felipe Espinosa Ramirez
--Sebastian Tabares Reyes
--Manuel David Fuentes Fernandez

--
-- INSTRUCCIONES DE MODIFICACIÓN SOLICITADAS
--

--
-- 5.1.- Agregar al menos 5 índices diferentes que considere importantes en 5 tablas diferentes.
--

-- 1. Optimizar búsquedas de cédula en paciente
CREATE INDEX idx_paciente_cedula ON paciente(cedula);

-- 2. Optimizar búsquedas de atenciones por fecha
CREATE INDEX idx_visita_fecha_hora ON visita(fecha_hora);

-- 3. Optimizar la búsqueda de cuartos por ubicación
CREATE INDEX idx_cuarto_hospital ON cuarto(planta_id, numero_cuarto);

-- 4. Optimizar el acceso a la lista de especialidades de un médico
CREATE INDEX idx_medico_especialidad_medico ON medico_especialidad(medico_id);

-- 5. Optimizar la búsqueda de pacientes asignados a médicos
CREATE INDEX idx_medico_paciente_paciente ON medico_paciente(paciente_id);

--
-- 5.2.- Agregar 5 campos nuevos en 5 tablas diferentes de su preferencia.
--

-- 1. Agregar campo de correo electrónico al paciente (UNIQUE y obligatorio)
ALTER TABLE paciente
ADD COLUMN email VARCHAR(100) UNIQUE NOT NULL;

-- 2. Agregar campo de fecha de emisión a la tarjeta de visita
ALTER TABLE tarjeta_visita
ADD COLUMN fecha_emision DATE DEFAULT CURRENT_DATE NOT NULL;

-- 3. Agregar campo de observaciones a la visita (para notas)
ALTER TABLE visita
ADD COLUMN observaciones TEXT;

-- 4. Agregar campo de dirección al hospital
ALTER TABLE hospital
ADD COLUMN direccion VARCHAR(250);

-- 5. Agregar campo de estado al médico (para inhabilitar)
ALTER TABLE medico
ADD COLUMN estado BOOLEAN DEFAULT TRUE NOT NULL;


--
-- 5.3.- Agregar 5 “CHECK” diferentes en 5 tablas diferentes de su preferencia.
--

-- 1. CHECK en PACIENTE: Asegura que la fecha de nacimiento no sea futura.
ALTER TABLE paciente
ADD CONSTRAINT check_fecha_nacimie CHECK (fecha_nacimiento <= current_date);

-- 2. CHECK en ATENCION: Asegura que la fecha y hora de atención no sea futura.
ALTER TABLE atencion
ADD CONSTRAINT check_fchahora CHECK (fecha_hora <= CURRENT_TIMESTAMP);

-- 3. CHECK en DIAGNOSTICO: Asegura que el código de diagnóstico no esté vacío.
ALTER TABLE diagnostico
ADD CONSTRAINT check_cod_no_vacio CHECK (TRIM(codigo_diag) <> '');

-- 4. CHECK en DIAGNOSTICO_MEDICO: Restringe el rol del médico a valores predefinidos.
ALTER TABLE diagnostico_medico
ADD CONSTRAINT check_rolmed_atencion CHECK (rol IN ('diagnosticador', 'confirmador', 'consultor', 'revisor'));

-- 5. CHECK en TRATAMIENTO_PACIENTE: Asegura que la fecha de fin sea posterior o igual a la de inicio.
ALTER TABLE tratamiento_paciente
ADD CONSTRAINT check_fechas_tratamiento CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio);


--
-- 5.4. Modificar los nombres de 5 campos diferentes en 5 tablas diferentes.
--

-- 1. Renombrar el código de la EPS a Razón Social para mayor claridad
ALTER TABLE eps
RENAME COLUMN nombre_eps TO razon_social_eps;

-- 2. Renombrar el campo de nombre del médico para especificar que es el nombre completo
ALTER TABLE medico
RENAME COLUMN nombre TO nombre_completo;

-- 3. Renombrar el teléfono 1 del paciente
ALTER TABLE paciente
RENAME COLUMN tel1 TO telefono_principal;

-- 4. Renombrar la descripción del tratamiento para especificar su función
ALTER TABLE tratamiento
RENAME COLUMN descripcion TO detalles_tratamiento;

-- 5. Renombrar el código de enfermera a Licencia Profesional
ALTER TABLE enfermera
RENAME COLUMN codigo_profesional TO licencia_profesional;

