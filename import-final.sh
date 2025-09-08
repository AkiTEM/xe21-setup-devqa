#!/bin/bash

echo "================================================="
echo "  INICIANDO PROCESSO DE CONFIGURAÇÃO DO BANCO    "
echo "================================================="
echo "Este processo pode levar vários minutos. Por favor, aguarde..."
echo ""

echo "[1/4] Criando diretório no CDB e PDB..."
sqlplus -s / as sysdba << EOF
-- Criar no CDB
ALTER SESSION SET CONTAINER = CDB\$ROOT;
CREATE OR REPLACE DIRECTORY TEMP_DUMP_DIR AS '/opt/oracle/admin/XE/dpdump';
GRANT READ, WRITE ON DIRECTORY TEMP_DUMP_DIR TO SYSTEM;

-- Criar diretório para datafiles
HOST mkdir -p /opt/oracle/oradata/XE/GFHOM/

-- Criar no PDB
ALTER SESSION SET CONTAINER = GFHOM;
CREATE OR REPLACE DIRECTORY TEMP_DUMP_DIR AS '/opt/oracle/admin/XE/dpdump';
GRANT READ, WRITE ON DIRECTORY TEMP_DUMP_DIR TO SYSTEM;

-- Criar tablespaces necessários
echo "[2/4] Criando tablespace de dados (8GB)..."
CREATE TABLESPACE TBS_DADOS_GFHOM DATAFILE '/opt/oracle/oradata/XE/GFHOM/tbs_dados_gfhom01.dbf' 
SIZE 8G AUTOEXTEND ON NEXT 100M MAXSIZE 8G;

echo "[2/4] Criando tablespace de índices (2GB)..."
CREATE TABLESPACE TBS_INDICES_GFHOM DATAFILE '/opt/oracle/oradata/XE/GFHOM/tbs_indices_gfhom01.dbf' 
SIZE 2G AUTOEXTEND ON NEXT 100M MAXSIZE 2G;

-- Verificar tablespaces e diretórios
SELECT tablespace_name FROM dba_tablespaces;
SELECT directory_name, directory_path FROM dba_directories WHERE directory_name = 'TEMP_DUMP_DIR';
EXIT;
EOF

echo ""
echo "[3/4] Executando importação no PDB GFHOM..."
echo "Esta etapa pode levar de 5 a 10 minutos dependendo do hardware."
echo "É normal ver mensagens de compilação com warnings durante a importação."
echo "Por favor, aguarde até que a importação seja concluída..."
echo ""

impdp system/manager@//localhost:1521/GFHOM directory=TEMP_DUMP_DIR \
  dumpfile=FULL_BACKUP.dmp \
  logfile=import.log \
  schemas=GFHOM,GF 

# Verifica se a importação foi bem sucedida
if [ $? -eq 0 ]; then
    echo ""
    echo "[4/4] Importação concluída com sucesso!"
    echo "Podem aparecer alguns warnings de compilação, isso é normal e não afeta o funcionamento."
    echo ""
    
    # Verificar tabelas importadas
    echo "Verificando tabelas carregadas..."
    echo "[DEBUG] Criando arquivo de verificação /tmp/verify.sql"
    echo 'ALTER SESSION SET CONTAINER = GFHOM;' > /tmp/verify.sql
    echo 'SET LINESIZE 120' >> /tmp/verify.sql
    echo 'SET PAGESIZE 100' >> /tmp/verify.sql
    echo 'COLUMN owner FORMAT A20' >> /tmp/verify.sql
    echo 'COLUMN tables_carregadas FORMAT 999999' >> /tmp/verify.sql
    echo "SELECT owner, COUNT(*) AS tables_carregadas FROM all_tables WHERE owner IN ('GFHOM', 'GF') GROUP BY owner;" >> /tmp/verify.sql
    
    # Verificar se o arquivo foi criado
    if [ -f /tmp/verify.sql ]; then
        echo "[DEBUG] Arquivo /tmp/verify.sql criado com sucesso"
        echo "[DEBUG] Conteúdo do arquivo de verificação:"
        cat /tmp/verify.sql
        
        echo "[DEBUG] Executando verificação..."
        # Redirecionar saída para um arquivo de log e para o console
        sqlplus -s '/ as sysdba' @/tmp/verify.sql | tee /opt/oracle/admin/XE/dpdump/verify_result.log
        
        echo "[DEBUG] Resultado da verificação salvo em /opt/oracle/admin/XE/dpdump/verify_result.log"
        echo "[DEBUG] Conteúdo do resultado:"
        cat /opt/oracle/admin/XE/dpdump/verify_result.log
    else
        echo "[ERROR] Falha ao criar arquivo /tmp/verify.sql"
    fi
    
    echo ""
    echo "================================================="
    echo "  BANCO DE DADOS CONFIGURADO COM SUCESSO!       "
    echo "================================================="
    echo "Pronto para uso com o seguinte esquema:"
    echo "- Tablespace de dados: TBS_DADOS_GFHOM (8GB)"
    echo "- Tablespace de índices: TBS_INDICES_GFHOM (2GB)"
    echo "- Schemas importados: GFHOM, GF"
    echo ""
    echo "Você pode conectar-se usando:"
    echo "Host: localhost"
    echo "Porta: 1521"
    echo "Service: GFHOM"
    echo "Usuário: devqa"
    echo "Senha: manager"
    echo "================================================="
else
    echo ""
    echo "[4/4] ERRO: Falha na importação. Verificando o log:"
    cat /opt/oracle/admin/XE/dpdump/import.log
fi
