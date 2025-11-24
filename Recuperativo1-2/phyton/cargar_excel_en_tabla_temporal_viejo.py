# LIBRERÍAS NECESARIAS
import pandas as pd
from sqlalchemy import create_engine, text
import os
import re

# ------------------------------------------------------------
# 1.- CONFIGURACIÓN DE CONEXIÓN
# ------------------------------------------------------------
DB_USER = "postgres"
DB_PASS = "root"
DB_HOST = "localhost"
DB_PORT = "5433"
DB_NAME = "graduados_2021"

engine = create_engine(f"postgresql+psycopg2://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}")
print(f"Conexión correcta a bases de datos.")

# ------------------------------------------------------------
# 2.- CARGAR ARCHIVO EXCEL
# ------------------------------------------------------------
archivo_excel = "dataset-reducido.xlsx"
df = pd.read_excel(archivo_excel)
print(f"Carga correcta de archivo excel.")

# ------------------------------------------------------------
# 3.- LIMPIAR NOMBRES DE COLUMNAS (VERSIÓN MÁS ROBUSTA)
# ------------------------------------------------------------
def limpiar_nombre(col):
    col = col.strip().lower()

    # Reemplazos básicos
    col = col.replace(" ", "_")
    col = col.replace("(", "").replace(")", "")
    col = col.replace("/", "_").replace("-", "_")
    col = col.replace(":", "_").replace(".", "_")   # <-- PROBLEMA ORIGINAL SOLUCIONADO

    # Eliminar acentos y ñ
    reemplazos = {
        "á": "a", "é": "e", "í": "i",
        "ó": "o", "ú": "u", "ñ": "n"
    }
    for k, v in reemplazos.items():
        col = col.replace(k, v)

    # Reemplazar cualquier caracter raro por "_"
    col = re.sub(r"[^a-z0-9_]", "_", col)

    # Evitar columnas que empiezan con número (ilegal en SQL)
    if re.match(r"^\d", col):
        col = "c_" + col

    return col

df.columns = [limpiar_nombre(c) for c in df.columns]

print("Limpieza de columnas correcta:")
print(df.columns)

# ------------------------------------------------------------
# 4.- CREAR TABLA TEMPORAL
# ------------------------------------------------------------
nombre_tabla = "dataset_temporal"

with engine.connect() as conn:
    conn.execute(text(f"DROP TABLE IF EXISTS public.{nombre_tabla};"))
    conn.commit()

column_defs = ",\n    ".join([f"{col} TEXT" for col in df.columns])

create_table_sql = f"""
CREATE TABLE public.{nombre_tabla} (
    id SERIAL PRIMARY KEY,
    {column_defs}
);
"""

with engine.connect() as conn:
    conn.execute(text(create_table_sql))
    conn.commit()

print(f"Tabla 'public.{nombre_tabla}' creada correctamente.")

# ------------------------------------------------------------
# 5.- INSERTAR DATOS
# ------------------------------------------------------------
print("Insertando los datos ...")

# IMPORTANTE: evitar que to_sql intente recrear la tabla o meta columna id
df.to_sql(nombre_tabla, engine, if_exists="append", index=False)

print(f"Datos insertados correctamente en 'public.{nombre_tabla}'.")
