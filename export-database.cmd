@echo off
echo Gerando backup do banco Oracle...

docker exec oracle-devqa expdp devqa/manager@GFHOM \
  directory=DATA_PUMP_DIR \
  dumpfile=FULL_BACKUP.dmp \
  logfile=FULL_BACKUP.log \
  full=y

echo Copiando arquivo de backup do container...
docker cp oracle-devqa:/opt/oracle/admin/XE/dpdump/FULL_BACKUP.dmp ./FULL_BACKUP.dmp

echo Criando nova imagem Docker...
docker build -t rafaelsantos440/oracle-xe-21:latest .
