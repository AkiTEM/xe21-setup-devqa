# xe21-setup-devqa

Oracle XE 21 - Ambiente Dev/QA

Automação para provisionamento de banco Oracle XE 21c em ambientes de desenvolvimento e QA.

Este projeto realiza o download do banco, criação automática de tablespaces, schemas e importação de base de dados, facilitando a preparação de ambientes de testes e homologação.

---

## Pré-requisitos

- Docker instalado e configurado
- Porta 1521 disponível no computador

## Como usar

### 1. Download da imagem
```bash
docker pull rafaelsantos440/oracle-xe-21
```

### 2. Executar o container
```bash
docker run -d -p 1521:1521 --name oracle-xe-dev rafaelsantos440/oracle-xe-21
```

> **Nota**: Na primeira inicialização, o banco pode demorar alguns minutos para estar disponível, pois o script irá importar os dados automaticamente.

### 3. Dados para conexão

#### Usuário Aplicação
- **Host**: localhost
- **Porta**: 1521
- **Service Name**: GFHOM
- **Usuário**: devqa
- **Senha**: manager
- **Characterset**: WE8MSWIN1252

#### Usuário Administrador
- **Usuário**: SYSTEM
- **Senha**: manager

### Strings de conexão

#### DBeaver e ferramentas similares:
- **URL**: `//localhost:1521/GFHOM`
- **JDBC**: `jdbc:oracle:thin:@//localhost:1521/GFHOM`

#### Formato alternativo (usando SID):
- **URL**: `//localhost:1521/XE`
- **JDBC**: `jdbc:oracle:thin:@localhost:1521:XE`

## Comandos úteis

### Verificar status
```bash
# Ver logs do container
docker logs -f oracle-xe-dev

# Ver se o container está rodando
docker ps | findstr oracle-xe-dev
```

### Gerenciamento do container
```bash
# Parar o container
docker stop oracle-xe-dev

# Iniciar o container
docker start oracle-xe-dev

# Remover o container (caso precise reinstalar)
docker rm -f oracle-xe-dev
```

### Mudando a porta (opcional)
Se precisar usar uma porta diferente de 1521:
```bash
docker run -d -p NOVA_PORTA:1521 --name oracle-xe-dev rafaelsantos440/oracle-xe-21
```

## Problemas comuns

1. **Erro de porta em uso**:
   - Verifique se a porta 1521 não está sendo usada por outro processo
   - Use uma porta diferente conforme mostrado acima

2. **Container não inicia**:
   - Verifique os logs com `docker logs -f oracle-xe-dev`
   - Certifique-se de que há memória suficiente disponível

3. **Problemas de conexão**:
   - Verifique se o container está rodando com `docker ps`
   - Aguarde alguns minutos na primeira inicialização
   - Verifique as credenciais de conexão

## Suporte

Em caso de problemas, verificar os logs do container:
```bash
docker logs -f oracle-xe-dev
```

---
Última atualização: Setembro 2025
>>>>>>> 33bb34d (Primeiro commit dos arquivos do setup devqa)
