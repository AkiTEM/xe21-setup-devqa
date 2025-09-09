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


# Aguardar o PDB GFHOM estar disponível e aberto
echo "Aguardando o PDB GFHOM estar disponível e aberto..."
while true; do
    STATUS=$(echo "SELECT open_mode FROM v\$pdbs WHERE name = 'GFHOM';" | sqlplus -s / as sysdba | grep "READ WRITE" || true)
    if [ ! -z "$STATUS" ]; then
        echo "PDB GFHOM está aberto!"
        break
    fi
    echo "PDB GFHOM ainda não está disponível. Aguardando 10 segundos..."
    sleep 10
done

# Executar script de importação
echo "Executando script de importação..."
bash /opt/oracle/scripts/import-final.sh

# Manter o container rodando
wait $ENTRYPOINT_PID
