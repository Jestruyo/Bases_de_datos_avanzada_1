# Taller: Índices y Restricciones en Oracle

Este directorio contiene los scripts SQL para el taller sobre índices y restricciones en Oracle utilizando el esquema HR.

## Estructura de Scripts

Los scripts están numerados en orden de ejecución:

1. **01_consultar_indices.sql**: Consulta los índices disponibles en las tablas `employees` y `departments`
2. **02_desactivar_restricciones.sql**: Desactiva todas las restricciones de las tablas `employees` y `departments`
3. **03_insertar_tuplas_invalidas.sql**: Inserta tuplas que no cumplen las restricciones (con restricciones desactivadas)
4. **00_limpiar_datos_invalidos.sql**: Limpia los datos inválidos insertados (opcional, antes de reactivar restricciones)
5. **04_reactivar_restricciones.sql**: Intenta reactivar las restricciones
6. **05_crear_departments2.sql**: Crea una copia de `departments` llamada `departments2` e inserta tres tuplas
7. **06_transacciones_y_rollback.sql**: Ejemplos de transacciones, COMMIT, ROLLBACK y SAVEPOINT
8. **07_archivos_redo.sql**: Consultas sobre archivos Redo Log y modos de funcionamiento

## Requisitos Previos

- Oracle Database 11g o superior
- Usuario HR desbloqueado y con privilegios
- Esquema HR con las tablas `employees` y `departments` pobladas

## Guía Rápida de Inicio

**📖 Para una guía completa paso a paso, consulta:** `docs/GUIA_EJECUCION_TALLER.md`

### Preparación Rápida (Automática)

Ejecuta el script de preparación desde la raíz del proyecto:

```bash
cd /Users/conbjtrujillo/Projects/Personal/Bases_de_datos_avanzada_1
./scripts/taller_indices/preparar_entorno.sh
```

Este script:
- Verifica que Docker esté corriendo
- Levanta el contenedor si es necesario
- Copia los scripts al contenedor
- Prepara el esquema HR con las tablas necesarias

### Preparación Manual

Si prefieres hacerlo manualmente:

```bash
# 1. Levantar contenedor
docker compose up -d

# 2. Esperar a que esté healthy
docker compose ps

# 3. Copiar scripts
docker cp ./scripts oracle-xml-lab:/opt/oracle/scripts

# 4. Preparar esquema HR
docker compose exec oracle-xe sqlplus hr/hr@XEPDB1 @/opt/oracle/scripts/00_seed_hr_sample.sql
```

## Instrucciones de Ejecución

### Opción 1: Ejecución Individual

Ejecuta cada script en orden usando SQL Developer o SQL*Plus:

```bash
# Desde SQL*Plus como usuario HR
sqlplus hr/hr@XEPDB1 @scripts/taller_indices/01_consultar_indices.sql
sqlplus hr/hr@XEPDB1 @scripts/taller_indices/02_desactivar_restricciones.sql
sqlplus hr/hr@XEPDB1 @scripts/taller_indices/03_insertar_tuplas_invalidas.sql
sqlplus hr/hr@XEPDB1 @scripts/taller_indices/00_limpiar_datos_invalidos.sql
sqlplus hr/hr@XEPDB1 @scripts/taller_indices/04_reactivar_restricciones.sql
sqlplus hr/hr@XEPDB1 @scripts/taller_indices/05_crear_departments2.sql
sqlplus hr/hr@XEPDB1 @scripts/taller_indices/06_transacciones_y_rollback.sql
```

Para el script 07 (archivos Redo), necesitas privilegios SYSDBA:

```bash
sqlplus / as sysdba @scripts/taller_indices/07_archivos_redo.sql
```

### Opción 2: Desde SQL Developer

1. Conecta como usuario `hr`
2. Abre cada script en orden
3. Ejecuta cada script completo (F5)
4. Toma capturas de pantalla de los resultados

## Notas Importantes

- **Script 03**: Inserta datos inválidos que violan restricciones. Estos datos solo se pueden insertar porque las restricciones están desactivadas.
- **Script 04**: Si intentas reactivar las restricciones sin limpiar los datos inválidos, algunas restricciones fallarán. Usa el script 00 para limpiar antes de reactivar.
- **Script 07**: Requiere privilegios de administrador. Algunas consultas pueden fallar si no tienes los privilegios necesarios.

## Consulta después de cerrar sesión

Para verificar que los datos persisten después de cerrar sesión:

```sql
-- Reconectar como usuario HR
SELECT * FROM departments2 ORDER BY department_id;
```

Los datos deberían estar disponibles porque se hizo COMMIT antes de cerrar la sesión.

