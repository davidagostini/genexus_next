# Documentação GeneXus Next

Guias **práticos** de configuração e uso do GeneXus Next — direto ao ponto, focados em "como fazer", sem teoria desnecessária.

> Estes documentos assumem que você **já tem o GeneXus Next instalado** e uma Knowledge Base (KB) criada. O foco aqui é configurar e usar.

## Índice

| # | Documento | Status |
|---|-----------|--------|
| 01 | [Adicionar o Work With Plus](docs/01-adicionar-work-with-plus.md) | ✅ Pronto |
| 02 | [Configurar o SQL Server](docs/02-configurar-sql-server.md) | ✅ Pronto |
| 03 | [Usar as skills de automação](docs/03-usar-as-skills.md) | ✅ Pronto |

## Skills de automação (Claude Code + Codex)

O repositório inclui duas skills (padrão aberto `SKILL.md`) que automatizam os guias acima:

- **`/davidagostini_gxnext_instalar_wwp`** — instala/atualiza o WorkWithPlus (Desktop ou Docker).
- **`/davidagostini_gxnext_configurar_sql`** — configura o SQL Server (testa a conexão antes de gravar).

A pasta **canônica** é `.claude/skills/` (lida pelo Claude Code). Para o **Codex/Gemini** lerem os
**mesmos arquivos** (fonte única, sem cópia), rode uma vez após clonar:

```powershell
pwsh -ExecutionPolicy Bypass -File .\setup-skills.ps1
```

Passo a passo completo em **[03 — Usar as skills de automação](docs/03-usar-as-skills.md)**.

## Como usar esta documentação

- Cada documento é independente e em formato passo a passo.
- Pré-requisitos vêm sempre no início de cada guia.
- Onde a interface muda entre versões, há um link para a documentação oficial.

## Convenções

- 🟦 **Passo** — ação que você executa.
- ⚠️ **Atenção** — ponto que costuma dar problema.
- 💡 **Dica** — atalho ou boa prática.
- 🔗 **Referência** — link oficial para aprofundar.

---

_Documentação mantida para uso interno da equipe. Sugestões e correções são bem-vindas._
