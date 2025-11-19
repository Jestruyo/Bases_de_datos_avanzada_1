#!/bin/bash
# Script de preparación del entorno para el taller de índices y restricciones
# Uso: ./preparar_entorno.sh

set -e

echo "=========================================="
echo "Preparación del Entorno - Taller de Índices"
echo "=========================================="
echo ""

# Verificar que Docker está corriendo
if ! docker ps > /dev/null 2>&1; then
    echo "❌ Error: Docker no está corriendo. Por favor inicia Docker Desktop."
    exit 1
fi

# Verificar que el contenedor existe
if ! docker ps -a | grep -q oracle-xml-lab; then
    echo "⚠️  El contenedor no existe. Levantando contenedor..."
    docker compose up -d
    echo "⏳ Esperando a que el contenedor esté listo (esto puede tomar 2-5 minutos)..."
    
    # Esperar a que el contenedor esté healthy
    while ! docker compose ps | grep -q "healthy"; do
        sleep 5
        echo -n "."
    done
    echo ""
    echo "✅ Contenedor listo"
else
    # Verificar si el contenedor está corriendo
    if ! docker ps | grep -q oracle-xml-lab; then
        echo "⚠️  El contenedor existe pero no está corriendo. Iniciando..."
        docker compose start
        sleep 10
    fi
    
    # Verificar estado
    if docker compose ps | grep -q "healthy"; then
        echo "✅ Contenedor está corriendo y saludable"
    else
        echo "⏳ Esperando a que el contenedor esté listo..."
        sleep 10
    fi
fi

echo ""
echo "📦 Copiando scripts al contenedor..."
docker cp ./scripts oracle-xml-lab:/opt/oracle/scripts 2>/dev/null || {
    echo "⚠️  No se pudieron copiar los scripts. Continuando..."
}

echo ""
echo "🔧 Preparando esquema HR..."
docker compose exec -T oracle-xe sqlplus hr/hr@XEPDB1 <<EOF 2>/dev/null || {
    echo "⚠️  No se pudo conectar como HR. Verificando si el usuario existe..."
    
    # Intentar desbloquear el usuario HR
    docker compose exec -T oracle-xe sqlplus / as sysdba <<'SYSDBASQL'
ALTER SESSION SET CONTAINER = XEPDB1;
ALTER USER hr IDENTIFIED BY hr ACCOUNT UNLOCK;
EXIT;
SYSDBASQL
    
    echo "✅ Usuario HR desbloqueado. Intentando nuevamente..."
    sleep 2
}

# Ejecutar script de semilla
docker compose exec -T oracle-xe sqlplus hr/hr@XEPDB1 <<'SEEDSQL'
SET ECHO OFF
SET FEEDBACK OFF
@/opt/oracle/scripts/00_seed_hr_sample.sql
EXIT;
SEEDSQL

echo ""
echo "✅ Verificando que las tablas existen..."
docker compose exec -T oracle-xe sqlplus -S hr/hr@XEPDB1 <<'VERIFYSQL'
SET PAGESIZE 0
SET FEEDBACK OFF
SELECT 'Tablas encontradas: ' || COUNT(*) FROM user_tables 
WHERE table_name IN ('EMPLOYEES', 'DEPARTMENTS', 'LOCATIONS');
SELECT 'Empleados: ' || COUNT(*) FROM employees;
SELECT 'Departamentos: ' || COUNT(*) FROM departments;
EXIT;
VERIFYSQL

echo ""
echo "=========================================="
echo "✅ Preparación completada"
echo "=========================================="
echo ""
echo "Próximos pasos:"
echo "1. Entra al contenedor: docker compose exec oracle-xe bash"
echo "2. Ve al directorio: cd /opt/oracle/scripts/taller_indices"
echo "3. Ejecuta los scripts en orden:"
echo "   sqlplus hr/hr@XEPDB1 @01_consultar_indices.sql"
echo ""
echo "O usa SQL Developer con:"
echo "   Host: localhost"
echo "   Puerto: 1521"
echo "   SID: XEPDB1"
echo "   Usuario: hr"
echo "   Contraseña: hr"
echo ""

