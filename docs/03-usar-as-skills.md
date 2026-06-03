# 03 — Usar as skills de automação (inclusive em outra máquina)

O repositório traz duas skills do **Claude Code** que automatizam os guias 01 e 02:

| Skill | O que faz |
|-------|-----------|
| `/davidagostini_gxnext_instalar_wwp` | Instala/atualiza o **WorkWithPlus** no GeneXus Next (Desktop ou Docker). |
| `/davidagostini_gxnext_configurar_sql` | Configura o **SQL Server** no `settings-overrides.json` (testa a conexão antes de gravar). |

Elas ficam em `.claude/skills/` dentro do repositório, então **viajam junto no git**.

---

## Pré-requisitos na máquina

| Item | Detalhe |
|------|---------|
| Windows + **PowerShell 7** (`pwsh`) | Os scripts assumem `pwsh`. (São compatíveis com o 5.1, mas use o 7 se possível.) |
| **Claude Code** instalado | Para invocar as skills com `/`. |
| **Git** | Para clonar o repositório. |
| **GeneXus Next** | Desktop (Windows Native) ou rodando via Docker. |
| Para o WWP | O `.zip` do plugin — baixe em [developer.workwithplus.com/downloads](https://developer.workwithplus.com/downloads) → **GeneXus Next**. |
| Para o SQL | SQL Server acessível (instância + usuário/senha, ou autenticação Windows). |

---

## 🟦 Passo 1 — Clonar o repositório

```powershell
git clone https://github.com/davidagostini/genexus_next.git
cd genexus_next
```

## 🟦 Passo 2 — Habilitar as skills

Escolha **uma** opção:

- **A) Usar como skills do projeto (recomendado):** basta **abrir o Claude Code dentro da pasta `genexus_next`**. As skills em `.claude/skills/` são reconhecidas automaticamente.
- **B) Usar em qualquer pasta (nível usuário):** copie para o seu perfil:
  ```powershell
  Copy-Item ".\.claude\skills\*" "$env:USERPROFILE\.claude\skills\" -Recurse -Force
  ```

Depois, **reinicie o Claude Code** para ele listar as skills.

## 🟦 Passo 2.1 — Rodar também no Codex (mesma fonte de arquivos)

Cada agente procura skills em pastas diferentes:

| Agente | Onde lê |
|--------|---------|
| Claude Code | `.claude/skills/` |
| Codex CLI | `.codex/skills/` e `.agents/skills/` |
| Gemini CLI | `.agents/skills/` |

Para os **dois (ou três) lerem os MESMOS arquivos**, sem duplicar nada, rode **uma vez** após clonar:

```powershell
pwsh -ExecutionPolicy Bypass -File .\setup-skills.ps1
```

Isso cria *junctions* (atalhos de diretório do Windows — **não precisam de admin**) `.agents/skills` e `.codex/skills` apontando para `.claude/skills`. A partir daí:

- A pasta **real e única** é `.claude/skills/` — edite as skills só ali.
- **Claude, Codex e Gemini** passam a ler os **mesmos arquivos**.
- As junctions são locais (estão no `.gitignore`) — rode o `setup-skills.ps1` **uma vez por clone/máquina**.

## 🟦 Passo 3 — Verificar

Digite `/` e confirme que aparecem:

```
/davidagostini_gxnext_instalar_wwp
/davidagostini_gxnext_configurar_sql
```

## 🟦 Passo 4 — Configurar o SQL Server

Rode a skill e responda às perguntas (pasta de instalação, `ProjectsFolder`, instância, usuário/senha ou Windows auth):

```
/davidagostini_gxnext_configurar_sql
```

O script **testa a conexão primeiro** e só grava se estiver OK (use `-Force` para forçar, `-SkipConnectionTest` para pular).

**Ou rode direto** (sem a skill):

```powershell
pwsh -ExecutionPolicy Bypass -File ".\.claude\skills\davidagostini_gxnext_configurar_sql\scripts\configure-sql.ps1" `
  -GxNextPath "C:\Program Files\GeneXus\GeneXus Next" `
  -ProjectsFolder "C:\modelos\next" `
  -SqlServerDefaultInstance "NOME-MAQUINA\SQLEXPRESS" `
  -SqlUserName "usuario_sql" -SqlUserPassword "senha_sql"
```

**Casos validados:**

- Desktop: `-GxNextPath "C:\GeneXus\Next"`, `-ProjectsFolder "C:\modelos\next"` e `-SqlServerDefaultInstance "127.0.0.1"`.
- Docker: `-SettingsDir "D:\docker\nextdocker\data\gxbl"`, `-ProjectsFolder "/app/kbs"` e `-SqlServerDefaultInstance "host.docker.internal"`.
- Use placeholders como `usuario_sql` e `senha_sql` na documentação; nunca registre credenciais reais.

## 🟦 Passo 5 — Instalar o WorkWithPlus

```
/davidagostini_gxnext_instalar_wwp
```

Responda: **Desktop ou Docker**, caminho do `.zip`, pasta de instalação e pasta do catálogo de plugins.

**Ou rode direto** (Desktop):

```powershell
pwsh -ExecutionPolicy Bypass -File ".\.claude\skills\davidagostini_gxnext_instalar_wwp\scripts\install-wwp-desktop.ps1" `
  -GxNextPath "C:\Program Files\GeneXus\GeneXus Next" `
  -ZipPath "C:\Downloads\WorkWithPlus_Next_Plugin_v16u1.0_8078.zip" `
  -PluginsCatalogPath "C:\GeneXus\pluginsCatalog"
```

**Ou rode direto** (Docker):

```powershell
pwsh -ExecutionPolicy Bypass -File ".\.claude\skills\davidagostini_gxnext_instalar_wwp\scripts\install-wwp-docker.ps1" `
  -ZipPath "C:\Downloads\WorkWithPlus_Next_Plugin_v16u1.0_8078.zip" `
  -RestartContainer
```

Depois faça os **passos manuais finais**: reiniciar o GeneXus Next → abrir **View → Other Tool Windows → Plugin Explorer** → localizar **WorkWithPlus** → clicar em **Install** (ou atualizar/habilitar) → conferir no **About** que frontend e backend coincidem.

> ⚠️ A skill prepara os arquivos do plugin, mas não clica no GeneXus Next. Depois de rodar o script, sempre acesse **View → Other Tool Windows → Plugin Explorer** e instale/habilite o **WorkWithPlus** manualmente.

### Caso de uso validado — Desktop

Exemplo validado em um ambiente com GeneXus Next Desktop instalado em `C:\GeneXus\Next` e cache limpo ao final:

```powershell
pwsh -ExecutionPolicy Bypass -File ".\.claude\skills\davidagostini_gxnext_instalar_wwp\scripts\install-wwp-desktop.ps1" `
  -GxNextPath "C:\GeneXus\Next" `
  -ZipPath "C:\Downloads\WorkWithPlus_Next_Plugin_v16u1.0_8078.zip" `
  -PluginsCatalogPath "C:\GeneXus\pluginsCatalog" `
  -ClearCache
```

Resultado esperado:

- `PluginsCatalogPath` gravado em `C:\GeneXus\Next\bl\settings-overrides.json`.
- Plugin copiado para `C:\GeneXus\pluginsCatalog\WorkWithPlus\<versão interna do pacote>`.
- Para o zip `WorkWithPlus_Next_Plugin_v16u1.0_8078.zip`, a versão interna detectada pode ser `16.1.0-b08078`.
- Cache limpo em `%AppData%\GeneXus Next\Cache\Cache_Data`.

### Caso de uso validado — Docker

Exemplo validado em um ambiente com containers `genexus-*` ativos no Docker Desktop e bind mount `user-app-data` apontando para uma pasta Windows:

```powershell
pwsh -ExecutionPolicy Bypass -File ".\.claude\skills\davidagostini_gxnext_instalar_wwp\scripts\install-wwp-docker.ps1" `
  -ZipPath "C:\Downloads\WorkWithPlus_Next_Plugin_v16u1.0_8078.zip" `
  -UserAppDataPath "D:\docker\nextdocker\data\gxbl"
```

Resultado esperado:

- Plugin extraído em `D:\docker\nextdocker\data\gxbl\<versão interna do pacote>`.
- `frontend.zip` expandido para `...\frontend`.
- `backend.zip` expandido para `...\backend`.
- Quando o script descobre automaticamente um caminho como `/run/desktop/mnt/host/d/...`, ele converte para `D:\...` antes de gravar.

---

## Observações

- **Ordem:** tanto faz começar pelo SQL ou pelo WWP — o `settings-overrides.json` é **mesclado**, então uma config não apaga a outra.
- 🔒 O `settings-overrides.json` (com a senha) **não é versionado** — já está no `.gitignore`.
- Caminho do script: nos exemplos é relativo à raiz do repo (`.\.claude\skills\...`). Se copiou para o usuário (opção B), use `"$env:USERPROFILE\.claude\skills\..."`.

---

⬅️ [Voltar ao índice](../README.md) · ⬅️ Anterior: [02 — Configurar o SQL Server](02-configurar-sql-server.md)
