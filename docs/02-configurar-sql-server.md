# 02 — Configurar o SQL Server

Guia prático para apontar o **GeneXus Next** para o seu **SQL Server** (onde as Knowledge Bases são criadas e armazenadas), usando o arquivo **`settings-overrides.json`**.

> O GeneXus Next conecta a **SQL Server** (ou LocalDB). A configuração é feita por overrides em `<Instalação do GeneXus Next>\bl\`, o mesmo mecanismo usado para o Work With Plus. (Fonte oficial: [GeneXus for Agents – Installation guide for Windows Native](https://docs.genexus.com/en/wiki?61635,GeneXus+for+Agents+-+Installation+guide+for+Windows+Native).)

---

## Antes de começar (pré-requisitos)

| Item | Detalhe |
|------|---------|
| GeneXus Next Desktop | Instalado (Windows Native). |
| SQL Server acessível | Instância local ou em rede que o GeneXus Next vai usar. |
| Autenticação | Este guia usa **autenticação SQL** (usuário + senha). Exige o SQL em **modo de autenticação mista**. |
| Permissão de administrador | Para editar arquivos em `…\bl\` e configurar o SQL Server. |
| Pasta da KB | A pasta de `ProjectsFolder`/`ProjectsDataFolder` deve existir (ou será criada) e ter permissão de escrita. |

---

## Onde fica a configuração

- **Padrão (não edite):** `<Instalação do GeneXus Next>\bl\settings.json`
- **Seus overrides (crie/edite):** `<Instalação do GeneXus Next>\bl\settings-overrides.json`
  → tem **prioridade** sobre o `settings.json`.

---

## 🟦 Passo 1 — Criar/editar o `settings-overrides.json`

Na pasta `<Instalação do GeneXus Next>\bl\`, crie (ou edite) o arquivo **`settings-overrides.json`** com:

```json
{
  "ProjectsFolder": "C:\\modelos\\next",
  "ProjectsDataFolder": "C:\\modelos\\next",
  "SqlServerDefaultInstance": "127.0.0.1",
  "SqlUserName": "usuario_sql",
  "SqlUserPassword": "senha_sql"
}
```

> ⚠️ Use barras invertidas **duplas** (`\\`) nos caminhos do Windows e mantenha o JSON válido (vírgulas e aspas).

### O que cada chave faz

| Chave | Função | Como preencher |
|-------|--------|----------------|
| `ProjectsFolder` | Pasta onde as Knowledge Bases são criadas/buscadas. | Caminho da sua KB. Troque **`KBNome`** pelo nome real da KB. |
| `ProjectsDataFolder` | Pasta de dados das KBs. | Normalmente o mesmo caminho do `ProjectsFolder`. |
| `SqlServerDefaultInstance` | Instância/servidor SQL que o Next vai usar. | Nome da máquina/servidor. Ex.: `localhost`, `.` , `.\SQLEXPRESS`, `SERVIDOR\INSTANCIA`. |
| `SqlUserName` | Usuário do SQL (autenticação SQL). | Login criado no SQL Server. |
| `SqlUserPassword` | Senha do usuário SQL. | Senha desse login. |

💡 **Instância padrão vs nomeada:** instância padrão local → `localhost`, `.` ou o nome da máquina; instância nomeada → `MAQUINA\INSTANCIA` (ex.: `.\SQLEXPRESS`).

💡 **Desktop vs Docker:** no Desktop, `127.0.0.1` aponta para o Windows. No Docker, `127.0.0.1` aponta para o próprio container; para acessar o SQL exposto no host, use normalmente `host.docker.internal`. Se o SQL estiver no mesmo `docker-compose`, também pode existir um alias de rede como `sql`.

💡 **Autenticação Windows (integrada):** se for usar a conta do Windows em vez de usuário/senha, normalmente **omita** `SqlUserName` e `SqlUserPassword`. Para **autenticação SQL**, informe os dois (como acima).

> 🔒 **Segurança:** este arquivo guarda a senha em texto. **Não** versione (commit) o `settings-overrides.json` em repositório e restrinja o acesso à máquina.

---

## 🟦 Passo 2 — Preparar o SQL Server (autenticação)

Para a autenticação SQL (`SqlUserName`/`SqlUserPassword`) funcionar:

1. **Modo de autenticação mista:** no SSMS → botão direito no servidor → **Properties → Security** → marque **SQL Server and Windows Authentication mode** → **OK**. Reinicie o serviço do SQL Server.
2. **Login:** garanta que o login (`usuario`) exista, com senha e **permissão para criar/usar bancos** (ex.: role `dbcreator`, ou `db_owner` nas bases da KB).
3. **Rede (instância remota/nomeada):** habilite **TCP/IP** no *SQL Server Configuration Manager* e mantenha o serviço **SQL Server Browser** em execução (necessário para instâncias nomeadas). Libere a porta no firewall, se aplicável.
4. **Teste:** conecte pelo SSMS usando **SQL Server Authentication** com o mesmo usuário/senha para confirmar.

---

## 🟦 Passo 3 — Aplicar e validar

1. **Salve** o `settings-overrides.json`.
2. **Feche e reabra** o GeneXus Next (ou rode `genexus.services.host.exe`).
3. **Crie ou abra uma KB** — ela será criada na `ProjectsFolder` e os bancos no SQL Server configurado.
4. Confirme no **SSMS** que os bancos da KB apareceram na instância.

### Caso de uso validado — Desktop

Exemplo validado com SQL Server acessível em `127.0.0.1`, autenticação SQL e pasta de KBs em `C:\modelos\next`:

```powershell
pwsh -ExecutionPolicy Bypass -File ".\.claude\skills\davidagostini_gxnext_configurar_sql\scripts\configure-sql.ps1" `
  -GxNextPath "C:\GeneXus\Next" `
  -ProjectsFolder "C:\modelos\next" `
  -ProjectsDataFolder "C:\modelos\next" `
  -SqlServerDefaultInstance "127.0.0.1" `
  -SqlUserName "usuario_sql" `
  -SqlUserPassword "senha_sql"
```

Resultado esperado:

- Conexão testada antes de gravar.
- `settings-overrides.json` atualizado em `C:\GeneXus\Next\bl\`.
- Pasta `C:\modelos\next` criada automaticamente se não existir.
- Chaves existentes, como `PluginsCatalogPath`, preservadas.

### Caso de uso validado — Docker

Exemplo validado com o bind mount `gxbl` em `D:\docker\nextdocker\data\gxbl` e pasta de KBs montada no container como `/app/kbs`:

```powershell
pwsh -ExecutionPolicy Bypass -File ".\.claude\skills\davidagostini_gxnext_configurar_sql\scripts\configure-sql.ps1" `
  -SettingsDir "D:\docker\nextdocker\data\gxbl" `
  -ProjectsFolder "/app/kbs" `
  -ProjectsDataFolder "/app/kbs" `
  -SqlServerDefaultInstance "host.docker.internal" `
  -SqlUserName "usuario_sql" `
  -SqlUserPassword "senha_sql"
```

Resultado esperado:

- Conexão testada antes de gravar.
- `settings-overrides.json` atualizado no bind mount `gxbl`.
- A pasta `/app/kbs` não é criada pelo PowerShell no host; ela deve existir como mount do container.
- Reinicie o container/serviço do GeneXus Next para reler a configuração.

---

## Solução de problemas

| Sintoma | Possível causa / solução |
|---------|--------------------------|
| `Login failed for user 'usuario'` | Modo misto não habilitado (Passo 2.1), senha errada, ou login sem permissão. |
| `Cannot connect to instance` / timeout | Nome da instância errado em `SqlServerDefaultInstance`, **TCP/IP** desabilitado, **SQL Browser** parado, ou firewall bloqueando. |
| KB não cria / erro de caminho | A pasta de `ProjectsFolder`/`ProjectsDataFolder` não existe ou está sem permissão de escrita. Crie a pasta. |
| Erro ao ler o arquivo de configuração | JSON inválido (vírgula/àspas) ou barras simples. Use `\\` e valide o JSON. |
| Mudança não aplicou | Faltou **fechar e reabrir** o GeneXus Next após salvar o arquivo. |
| Quer usar autenticação Windows | Remova `SqlUserName`/`SqlUserPassword` e use uma conta com acesso ao SQL. |

---

## Referências oficiais

- 🔗 [GeneXus for Agents – Installation guide for Windows Native](https://docs.genexus.com/en/wiki?61635,GeneXus+for+Agents+-+Installation+guide+for+Windows+Native) ← `settings-overrides.json`, `ProjectsFolder`, `ProjectsDataFolder`, `SqlServerDefaultInstance`
- 🔗 [GeneXus Next features](https://docs.genexus.com/en/wiki?37055,GeneXus+Next+features)

---

⬅️ [Voltar ao índice](../README.md) · ⬅️ Anterior: [01 — Adicionar o Work With Plus](01-adicionar-work-with-plus.md)
