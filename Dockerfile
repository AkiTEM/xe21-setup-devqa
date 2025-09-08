FROM gvenzl/oracle-xe:21-slim

# Configurações do banco
ENV ORACLE_CHARACTERSET=WE8MSWIN1252
ENV ORACLE_PASSWORD=manager
ENV ORACLE_DATABASE=GFHOM
ENV APP_USER=devqa
ENV APP_USER_PASSWORD=manager

# Criar diretório para o backup
RUN mkdir -p /opt/oracle/admin/XE/dpdump/

# Copiar o arquivo de backup
COPY FULL_BACKUP.dmp /opt/oracle/admin/XE/dpdump/
USER root
RUN chmod 644 /opt/oracle/admin/XE/dpdump/FULL_BACKUP.dmp && \
    chown oracle:oinstall /opt/oracle/admin/XE/dpdump/FULL_BACKUP.dmp

# Script de importação
COPY import-final.sh /opt/oracle/scripts/import-final.sh
RUN chown oracle:oinstall /opt/oracle/scripts/import-final.sh && \
    chmod 755 /opt/oracle/scripts/import-final.sh

# Configurar entrypoint personalizado
COPY custom-entrypoint.sh /opt/oracle/custom-entrypoint.sh
RUN chmod +x /opt/oracle/custom-entrypoint.sh && \
    chown oracle:oinstall /opt/oracle/custom-entrypoint.sh
USER oracle

# Definir o entrypoint personalizado
ENTRYPOINT ["/opt/oracle/custom-entrypoint.sh"]
