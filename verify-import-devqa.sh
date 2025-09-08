#!/bin/bash

# Script para verificar os dados carregados na importação

echo "Verificando tabelas carregadas..."
docker exec oracle-xe-devqa bash -c "echo 'ALTER SESSION SET CONTAINER = GFHOM;' > /tmp/tables.sql && echo 'SET LINESIZE 120' >> /tmp/tables.sql && echo 'SET PAGESIZE 100' >> /tmp/tables.sql && echo 'COLUMN owner FORMAT A20' >> /tmp/tables.sql && echo 'COLUMN tables_carregadas FORMAT 999999' >> /tmp/tables.sql && echo \"SELECT owner, COUNT(*) AS tables_carregadas FROM all_tables WHERE owner IN ('GFHOM', 'GF') GROUP BY owner;\" >> /tmp/tables.sql && sqlplus -s '/ as sysdba' @/tmp/tables.sql"

echo "Verificando usuários do PDB..."
docker exec oracle-xe-devqa bash -c "echo 'ALTER SESSION SET CONTAINER = GFHOM;' > /tmp/users.sql && echo 'SELECT username FROM all_users ORDER BY username;' >> /tmp/users.sql && sqlplus -s '/ as sysdba' @/tmp/users.sql"

echo "Verificando tablespaces..."
docker exec oracle-xe-devqa bash -c "echo 'ALTER SESSION SET CONTAINER = GFHOM;' > /tmp/tbs.sql && echo 'SELECT tablespace_name, ROUND(bytes/1024/1024/1024, 2) as SIZE_GB FROM dba_data_files;' >> /tmp/tbs.sql && sqlplus -s '/ as sysdba' @/tmp/tbs.sql"
