#!/bin/bash
set -e

# Executar o entrypoint original em background
# Isso garante que o Oracle seja inicializado corretamente
/opt/oracle/container-entrypoint.sh "$@" &
ENTRYPOINT_PID=$!

# Aguardar o banco de dados estar completamente pronto
echo "Aguardando o banco de dados iniciar completamente..."
while true; do
    # Tenta uma consulta simples para verificar se o banco está realmente funcionando
    if sqlplus -s / as sysdba <<EOF
        SELECT 1 FROM dual;
        EXIT;
EOF
    then
        # Verifica se o listener está funcionando
        if lsnrctl status | grep -q "The command completed successfully"; then
            echo "Banco de dados e listener estão prontos!"
            break
        fi
    fi
    echo "Aguardando o Oracle inicializar completamente..."
    sleep 10
done

# Aguardar mais um pouco para garantir que o PDB também está pronto
echo "Aguardando mais 30 segundos para garantir que o PDB esteja pronto..."
sleep 30

# Executar script de importação
echo "Executando script de importação..."
bash /opt/oracle/scripts/import-final.sh

# Manter o container rodando
wait $ENTRYPOINT_PID
