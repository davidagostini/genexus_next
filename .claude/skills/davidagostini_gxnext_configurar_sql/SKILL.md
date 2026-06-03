---
name: davidagostini_gxnext_configurar_sql
description: >-
  Configura a conexao do GeneXus Next (Windows) com o SQL Server, criando ou editando o
  settings-overrides.json com ProjectsFolder, ProjectsDataFolder, SqlServerDefaultInstance,
  SqlUserName e SqlUserPassword. Use SEMPRE que o usuario quiser configurar o SQL Server do
  GeneXus Next, apontar a instancia do banco, definir usuario/senha do SQL, mudar a pasta das
  Knowledge Bases (ProjectsFolder/ProjectsDataFolder), ou mencionar "settings-overrides.json do SQL".
  TESTA a conexao com o SQL antes de finalizar e so grava se estiver OK. Preserva chaves ja
  existentes (como PluginsCatalogPath do WorkWithPlus). Plataforma: Windows + PowerShell.
---

# Configurar o SQL Server no GeneXus Next

Aponta o GeneXus Next para o SQL Server gravando as chaves de conexão no `settings-overrides.json`
(em `<instalação>\bl\`, mesmo mecanismo do WorkWithPlus). **Testa a conexão antes de gravar** — se a
conexão falhar, nada é escrito. O arquivo é **mesclado**: chaves de plugin (ex.: `PluginsCatalogPath`)
são preservadas.

Fonte oficial: [GeneXus for Agents – Installation guide for Windows Native](https://docs.genexus.com/en/wiki?61635,GeneXus+for+Agents+-+Installation+guide+for+Windows+Native).

## Scripts desta skill

Script em `scripts/configure-sql.ps1` **ao lado deste arquivo**. Use o caminho absoluto da pasta desta
skill (pode estar em `~/.claude/skills/...` ou em `<repo>/.claude/skills/...`). Nos exemplos, troque
`<skill>` pelo caminho real.

## Passo 1 — Coletar os dados

Pergunte e **confirme** com o usuário:

1. **Pasta de configuração** — onde está o `settings.json`:
   - Desktop: a pasta de instalação do GeneXus Next (que contém `bl`) → `-GxNextPath`.
   - Docker: o bind mount `gxbl` do container → `-SettingsDir`.
2. **`ProjectsFolder`** — pasta das Knowledge Bases (ex.: `C:\modelos\david.agostini\next\KBNome`). Troque `KBNome` pelo nome real da KB.
3. **`ProjectsDataFolder`** — normalmente igual ao `ProjectsFolder` (se omitido, o script repete o valor).
4. **`SqlServerDefaultInstance`** — instância/servidor SQL (ex.: `localhost`, `.\SQLEXPRESS`, `NOME-MAQUINA\INSTANCIA`).
5. **Autenticação:**
   - **SQL** (usuário/senha): informe `-SqlUserName` e `-SqlUserPassword`.
   - **Windows** (integrada): use `-WindowsAuth` (não grava usuário/senha).

> 🔒 A senha vai em texto no arquivo. Avise o usuário para **não versionar** o `settings-overrides.json` e restringir o acesso à máquina.

## Passo 2 — Executar

Exemplo (autenticação SQL, Desktop):

```powershell
pwsh -ExecutionPolicy Bypass -File "<skill>\scripts\configure-sql.ps1" `
  -GxNextPath "C:\Program Files\GeneXus\GeneXus Next" `
  -ProjectsFolder "C:\modelos\david.agostini\next\KBNome" `
  -SqlServerDefaultInstance "NOME-MAQUINA\SQLEXPRESS" `
  -SqlUserName "usuario" -SqlUserPassword "senha"
```

Exemplo (autenticação Windows):

```powershell
pwsh -ExecutionPolicy Bypass -File "<skill>\scripts\configure-sql.ps1" `
  -GxNextPath "C:\Program Files\GeneXus\GeneXus Next" `
  -ProjectsFolder "C:\modelos\david.agostini\next\KBNome" `
  -SqlServerDefaultInstance "localhost" -WindowsAuth
```

**Comportamento:** o script **testa a conexão primeiro**:
- Conexão **OK** → grava as chaves no `settings-overrides.json` e cria a `ProjectsFolder`.
- Conexão **falha** → **não grava nada** e mostra o erro (use `-Force` para gravar mesmo assim).
- Para pular o teste, use `-SkipConnectionTest`.

## Passo 3 — Aplicar e validar

1. **Feche e reabra** o GeneXus Next (ou rode `genexus.services.host.exe`).
2. **Crie/abra uma KB** — será criada na `ProjectsFolder` e os bancos na instância configurada.
3. Confirme no **SSMS** que os bancos apareceram.

Se o teste acusar `Login failed`, verifique o **modo de autenticação mista**, a senha e as permissões
do login. Se acusar erro de conexão, confira o nome da instância, **TCP/IP** e o **SQL Browser**.
