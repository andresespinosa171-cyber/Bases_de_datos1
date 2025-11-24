--8.1
SELECT 
    i.nombre_institucion,
    SUM(gr.graduados) AS total_graduados
FROM graduado_registro gr
JOIN sede s ON gr.id_sede_fk = s.id_sede
JOIN institucion i ON s.id_institucion_fk = i.id_institucion
GROUP BY i.nombre_institucion
ORDER BY total_graduados DESC
LIMIT 10;

--8.2
SELECT 
    p.nombre_programa,
    SUM(gr.graduados) AS total_graduados
FROM graduado_registro gr
JOIN programa p ON gr.id_programa_fk = p.id_programa
GROUP BY p.nombre_programa
ORDER BY total_graduados DESC
LIMIT 10;

--8.3
WITH ranking AS (
    SELECT 
        i.nombre_institucion,
        SUM(gr.graduados) AS total_graduados,
        RANK() OVER (ORDER BY SUM(gr.graduados) DESC) AS posicion
    FROM graduado_registro gr
    JOIN sede s ON gr.id_sede_fk = s.id_sede
    JOIN institucion i ON s.id_institucion_fk = i.id_institucion
    GROUP BY i.nombre_institucion
)
SELECT *
FROM ranking
WHERE nombre_institucion ILIKE '%Pascual Bravo%';

--8.4
SELECT 
    p.nombre_programa,
    SUM(gr.graduados) AS total_hombres
FROM graduado_registro gr
JOIN programa p ON gr.id_programa_fk = p.id_programa
JOIN sexo sx ON gr.id_sexo_fk = sx.id_sexo
WHERE sx.nombre_sexo ILIKE 'M%'
GROUP BY p.nombre_programa
ORDER BY total_hombres DESC
LIMIT 10;

--8.5
SELECT 
    p.nombre_programa,
    SUM(gr.graduados) AS total_mujeres
FROM graduado_registro gr
JOIN programa p ON gr.id_programa_fk = p.id_programa
JOIN sexo sx ON gr.id_sexo_fk = sx.id_sexo
WHERE sx.nombre_sexo ILIKE 'F%'
GROUP BY p.nombre_programa
ORDER BY total_mujeres DESC
LIMIT 10;

--8.6
SELECT 
    d.nombre_departamento,
    SUM(gr.graduados) AS total_graduados
FROM graduado_registro gr
JOIN municipio m ON gr.id_municipio_oferta_fk = m.id_municipio
JOIN departamento d ON m.id_departamento_fk = d.id_departamento
GROUP BY d.nombre_departamento
ORDER BY total_graduados DESC
LIMIT 3;

--8.7
SELECT 
    m.nombre_municipio,
    d.nombre_departamento,
    SUM(gr.graduados) AS total_graduados
FROM graduado_registro gr
JOIN municipio m ON gr.id_municipio_oferta_fk = m.id_municipio
JOIN departamento d ON m.id_departamento_fk = d.id_departamento
GROUP BY m.nombre_municipio, d.nombre_departamento
ORDER BY total_graduados DESC
LIMIT 3;

--8.8
SELECT 
    i.nombre_institucion,
    d.nombre_departamento,
    m.nombre_municipio,
    SUM(gr.graduados) AS total_graduados
FROM institucion i
JOIN sede s ON i.id_institucion = s.id_institucion_fk
JOIN municipio m ON s.id_municipio_sede_fk = m.id_municipio
JOIN departamento d ON m.id_departamento_fk = d.id_departamento
JOIN graduado_registro gr ON gr.id_sede_fk = s.id_sede
GROUP BY i.nombre_institucion, d.nombre_departamento, m.nombre_municipio
ORDER BY i.nombre_institucion ASC;

--8.9
SELECT 
    p.nombre_programa,
    i.nombre_institucion,
    d.nombre_departamento,
    m.nombre_municipio,
    SUM(gr.graduados) AS total_graduados
FROM programa p
JOIN graduado_registro gr ON p.id_programa = gr.id_programa_fk
JOIN sede s ON gr.id_sede_fk = s.id_sede
JOIN institucion i ON s.id_institucion_fk = i.id_institucion
JOIN municipio m ON gr.id_municipio_oferta_fk = m.id_municipio
JOIN departamento d ON m.id_departamento_fk = d.id_departamento
GROUP BY p.nombre_programa, i.nombre_institucion, d.nombre_departamento, m.nombre_municipio
ORDER BY p.nombre_programa ASC;

--8.10
SELECT 
    d.nombre_departamento,
    m.nombre_municipio,
    SUM(gr.graduados) AS total_graduados
FROM graduado_registro gr
JOIN municipio m ON gr.id_municipio_oferta_fk = m.id_municipio
JOIN departamento d ON m.id_departamento_fk = d.id_departamento
GROUP BY d.nombre_departamento, m.nombre_municipio
ORDER BY total_graduados DESC;

