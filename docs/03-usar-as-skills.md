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
  -ProjectsFolder "C:\modelos\david.agostini\next\KBNome" `
  -SqlServerDefaultInstance "NOME-MAQUINA\SQLEXPRESS" `
  -SqlUserName "usuario" -SqlUserPassword "senha"
```

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

Depois faça os **passos manuais finais**: reiniciar o GeneXus Next → **Plugin Explorer** (habilitar/atualizar) → conferir no **About** que frontend e backend coincidem.

---

## Observações

- **Ordem:** tanto faz começar pelo SQL ou pelo WWP — o `settings-overrides.json` é **mesclado**, então uma config não apaga a outra.
- 🔒 O `settings-overrides.json` (com a senha) **não é versionado** — já está no `.gitignore`.
- Caminho do script: nos exemplos é relativo à raiz do repo (`.\.claude\skills\...`). Se copiou para o usuário (opção B), use `"$env:USERPROFILE\.claude\skills\..."`.

---

⬅️ [Voltar ao índice](../README.md) · ⬅️ Anterior: [02 — Configurar o SQL Server](02-configurar-sql-server.md)
