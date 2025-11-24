CREATE OR REPLACE VIEW vista_detalle_graduados AS
SELECT 
    i.nombre_institucion,
    s.tipo_sede,
    d_sede.nombre_departamento   AS departamento_sede,
    m_sede.nombre_municipio      AS municipio_sede,

    p.nombre_programa,
    nc.nucleo_conocimiento,
    ccd.cine_codigo_detallado,

    d_of.nombre_departamento     AS departamento_oferta,
    m_of.nombre_municipio        AS municipio_oferta,

    sx.nombre_sexo,
    gr.semestre,
    gr.graduados

FROM graduado_registro gr
JOIN sede s                         ON gr.id_sede_fk = s.id_sede
JOIN institucion i                  ON s.id_institucion_fk = i.id_institucion
JOIN municipio m_sede               ON s.id_municipio_sede_fk = m_sede.id_municipio
JOIN departamento d_sede            ON m_sede.id_departamento_fk = d_sede.id_departamento
JOIN programa p                     ON gr.id_programa_fk = p.id_programa
JOIN nucleo_conocimiento nc         ON p.id_nucleo_conocimiento_fk = nc.id_nucleo_conocimiento
JOIN cine_codigo_detallado ccd      ON p.id_cine_codigo_detallado_fk = ccd.id_cine_codigo_detallado
JOIN municipio m_of                 ON gr.id_municipio_oferta_fk = m_of.id_municipio
JOIN departamento d_of              ON m_of.id_departamento_fk = d_of.id_departamento
JOIN sexo sx                        ON gr.id_sexo_fk = sx.id_sexo;
