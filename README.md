
# 🐳 Oracle XE 21 - Ambiente de Desenvolvimento

## 🎮 Missão: Ambiente Dev em 30 Minutos! 🚀

Olá, Desenvolvedor(a) Destemido(a)!

Sua missão, caso aceite, é configurar um ambiente Oracle completo em tempo recorde!

> **Nível:** Fácil 🌟  
> **Tempo estimado:** 30 minutos ⏱️  
> **Recompensa:** Um ambiente Oracle pronto para seus projetos! 🏆

*"Prepare-se para uma jornada onde comandos Docker são suas armas, e um ambiente perfeito é seu destino!"* 🎯

---

## ✨ Bem-vindo!

Este container Docker contém uma instalação do Oracle XE 21 com os dados do ambiente de desenvolvimento já configurados e prontos para uso!

Após a configuração bem-sucedida, o banco de dados contará com dois schemas:
- **GFHOM:** Contém todas as tabelas necessárias para utilizar a CAT83
- **GF:** Schema vazio, destinado ao desenvolvimento uniface do GF

---

## 📋 Pré-requisitos

- Rancher Desktop instalado e configurado
- Porta 1521 disponível no computador

---

## 🚀 Como usar

> ⚠️ **Importante:** Todos os comandos devem ser executados no prompt de comando (CMD) do Windows.

### 📥 1. Preparação (para usuários da versão anterior)

> ⚠️ **Atenção:** Se você já tinha a versão anterior instalada, execute:
```sh
docker rm -f oracle-xe-devqa && docker rmi rafaelsantos440/oracle-xe-21
```

### 2. Download da imagem
```sh
docker pull rafaelsantos440/oracle-xe-21:latest
```

### 3. Executar o container
```sh
docker run -d -p 1521:1521 --name oracle-xe-devqa rafaelsantos440/oracle-xe-21:latest
```

> ⚠️ **Atenção:** Antes de prosseguir, é obrigatório acompanhar o status do container pelo log.
> 
> Utilize o comando abaixo e só avance para a configuração do banco após confirmar que o Oracle está pronto para conexões.

### 🔍 Verificar status
```sh
docker logs -f oracle-xe-devqa
```

> **Importante:**
> - Acompanhe o log do container e só prossiga para a configuração do banco após visualizar a mensagem de que o Oracle está pronto para conexões.
> - Durante a inicialização, observe no log as seguintes etapas:
>   - Inicialização do banco de dados
>   - Configuração do diretório para importação
>   - Progresso da importação dos schemas GFHOM e GF
>   - Confirmação de sucesso ou detalhes de qualquer erro

---

## 🔍 Verificando a importação

> Para confirmar que os schemas **GFHOM** e **GF** foram importados corretamente, execute estas verificações:

### Verificar usuários do PDB:
```sh
docker exec oracle-xe-devqa bash -c "echo 'ALTER SESSION SET CONTAINER = GFHOM;' > /tmp/users.sql && echo 'SELECT username FROM all_users ORDER BY username;' >> /tmp/users.sql && sqlplus -s '/ as sysdba' @/tmp/users.sql"
```

### Verificar tablespaces:
```sh
docker exec oracle-xe-devqa bash -c "echo 'ALTER SESSION SET CONTAINER = GFHOM;' > /tmp/tbs.sql && echo 'SELECT tablespace_name, ROUND(bytes/1024/1024/1024, 2) as SIZE_GB FROM dba_data_files;' >> /tmp/tbs.sql && sqlplus -s '/ as sysdba' @/tmp/tbs.sql"
```

### Verificar tabelas carregadas:
```sh
docker exec oracle-xe-devqa bash -c "echo 'ALTER SESSION SET CONTAINER = GFHOM;' > /tmp/tables.sql && echo 'SET LINESIZE 120' >> /tmp/tables.sql && echo 'SET PAGESIZE 100' >> /tmp/tables.sql && echo 'COLUMN owner FORMAT A20' >> /tmp/tables.sql && echo 'COLUMN tables_carregadas FORMAT 999999' >> /tmp/tables.sql && echo \"SELECT owner, COUNT(*) AS tables_carregadas FROM all_tables WHERE owner IN ('GFHOM', 'GF') GROUP BY owner;\" >> /tmp/tables.sql && sqlplus -s '/ as sysdba' @/tmp/tables.sql"
```

> ✅ **Sucesso:** Se a importação foi bem-sucedida, você verá aproximadamente 2.824 tabelas no schema GFHOM e os tablespaces TBS_DADOS_GFHOM (8GB) e TBS_INDICES_GFHOM (2GB) configurados corretamente.

---

## 🔌 Dados para conexão

### Usuário Aplicação
- **Host:** localhost
- **Porta:** 1521
- **Service Name:** GFHOM
- **Usuário:** gfhom
- **Senha:** manager
- **Characterset:** WE8MSWIN1252

### Usuário Administrador
- **Usuário:** SYSTEM
- **Senha:** manager

> 💡 **Dica:** Inicie a conexão usando o usuário SYSTEM. Depois de confirmar que tudo está funcionando, você pode criar novas conexões com o usuário devqa.

### Strings de conexão

#### DBeaver e ferramentas similares:
- **URL:** //localhost:1521/GFHOM
- **JDBC:** jdbc:oracle:thin:@//localhost:1521/GFHOM

#### Formato alternativo (usando SID):
- **URL:** //localhost:1521/XE
- **JDBC:** jdbc:oracle:thin:@localhost:1521:XE

---

## 🛠️ Comandos úteis

### Ver se o container está rodando:
```sh
docker ps | findstr oracle-xe-devqa
```

### Gerenciamento do container
- Parar o container:
   ```sh
   docker stop oracle-xe-devqa
   ```
- Iniciar o container:
   ```sh
   docker start oracle-xe-devqa
   ```
- Remover o container (caso precise reinstalar):
   ```sh
   docker rm -f oracle-xe-devqa
   ```

### Mudando a porta (opcional)
```sh
docker run -d -p NOVA_PORTA:1521 --name oracle-xe-devqa rafaelsantos440/oracle-xe-21:latest
```

---

## ⚠️ Problemas comuns

1. **Erro de porta em uso:**
    - Verifique se a porta 1521 não está sendo usada por outro processo
    - Use uma porta diferente conforme mostrado acima

2. **Container não inicia:**
    - Verifique os logs com `docker logs -f oracle-xe-devqa`
    - Certifique-se de que há memória suficiente disponível

3. **Problemas de conexão:**
    - Verifique se o container está rodando com `docker ps`
    - Aguarde alguns minutos na primeira inicialização
    - Verifique as credenciais de conexão

---

## 🆘 Suporte

Em caso de problemas, verificar os logs do container:
```sh
docker logs -f oracle-xe-devqa
```

---

Última atualização: Setembro 2025
