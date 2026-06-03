---
name: davidagostini_gxnext_instalar_wwp
description: >-
  Instala ou atualiza o plugin WorkWithPlus (WWP) em uma instância do GeneXus Next no Windows,
  cobrindo os dois cenários de deploy: Desktop nativo e Docker. Use SEMPRE que o usuário quiser
  adicionar, instalar, atualizar ou habilitar o WorkWithPlus no GeneXus Next — inclusive quando
  mencionar "plugin do workwithplus", "PluginsCatalogPath", "catálogo de plugins",
  "settings-overrides.json do WWP", apontar um .zip do WorkWithPlus, ou disser apenas "instalar o
  workwith no next". A skill pergunta Desktop ou Docker, coleta os caminhos, configura o
  settings-overrides.json, monta o catálogo de plugins, extrai o zip e orienta o restart (no Docker,
  sobe o container de volta). Plataforma: Windows + PowerShell.
---

# Instalar/atualizar o WorkWithPlus no GeneXus Next

Automatiza a instalação do plugin WorkWithPlus no GeneXus Next, nos dois cenários suportados:

- **Desktop (Windows Native):** configura `PluginsCatalogPath` no `settings-overrides.json` e monta o catálogo de plugins (`...\WorkWithPlus\<versão>\`).
- **Docker:** localiza o bind mount `user-app-data` (pasta `gxbl`) do container do GeneXus e aplica o plugin ali; o container volta ao ar ao reiniciar o GeneXus Next.

Fontes oficiais: [WorkWithPlus Next Install](https://docs.workwithplus.com/wiki?5501,WorkWithPlus+Next+Install,) · [Update using Desktop](https://docs.workwithplus.com/wiki?5525,WorkWithPlus+Next+Update+Desktop,) · [Update using Docker](https://docs.workwithplus.com/wiki?5506,WorkWithPlus+Next+Update+Docker,) · [settings-overrides.json (GeneXus)](https://docs.genexus.com/en/wiki?61635,GeneXus+for+Agents+-+Installation+guide+for+Windows+Native).

## Scripts desta skill

Os scripts estão em `scripts/` **ao lado deste arquivo**. Ao executar, use o caminho absoluto da pasta
desta skill — que pode estar em dois lugares:
- Instalada no usuário: `~/.claude/skills/davidagostini_gxnext_instalar_wwp/scripts/...`
- Vinda pelo repositório: `<repo>/.claude/skills/davidagostini_gxnext_instalar_wwp/scripts/...`

Nos exemplos abaixo, troque `<skill>` pelo caminho real desta pasta.

## Passo 1 — Descobrir o cenário e coletar os dados

Antes de executar, **pergunte ao usuário** (seletor Desktop × Docker) e **confirme os valores**:

1. **Cenário:** Desktop ou Docker?
2. **Caminho do `.zip` do WorkWithPlus** (obrigatório). Valide que o arquivo existe.
   - Última versão sempre em [developer.workwithplus.com/downloads](https://developer.workwithplus.com/downloads) → selecionar **GeneXus Next**.
3. **Se Desktop:**
   - **Pasta de instalação do GeneXus Next** — a que contém a subpasta `bl` (ex.: `C:\Program Files\GeneXus\GeneXus Next`). Dica: é a pasta que tem `bl\settings.json`.
   - **Pasta do catálogo de plugins** (`PluginsCatalogPath`). Padrão sugerido: `C:\GeneXus\pluginsCatalog`.
4. **Se Docker:**
   - O script tenta **descobrir sozinho** o bind mount `user-app-data` (`gxbl`) via `docker`. Só peça o caminho manualmente se a descoberta falhar (aba **Bind mounts** do container no Docker Desktop).

> Confirme o resumo com o usuário antes de rodar — a skill escreve arquivos e extrai o zip.

## Passo 2 — Executar

### Desktop

```powershell
pwsh -ExecutionPolicy Bypass -File "<skill>\scripts\install-wwp-desktop.ps1" `
  -GxNextPath "C:\Program Files\GeneXus\GeneXus Next" `
  -ZipPath "C:\Downloads\WorkWithPlus_Next_Plugin_v16u1.0_8078.zip" `
  -PluginsCatalogPath "C:\GeneXus\pluginsCatalog"
```

Mescla `PluginsCatalogPath` no `settings-overrides.json` (preservando outras chaves, ex.: as do SQL),
detecta a versão pelo `plugin.json`, cria `...\WorkWithPlus\<versão>\` e copia os arquivos.
Use `-ClearCache` para limpar o cache ao final.

### Docker

```powershell
pwsh -ExecutionPolicy Bypass -File "<skill>\scripts\install-wwp-docker.ps1" `
  -ZipPath "C:\Downloads\WorkWithPlus_Next_Plugin_v16u1.0_8078.zip"
```

Localiza o container do GeneXus e o bind mount `user-app-data` (`gxbl`), extrai o plugin ali e expande
`frontend.zip` e `backend.zip`. Use `-RestartContainer` para reiniciar o container ao final, ou
`-UserAppDataPath` para informar a pasta manualmente.

## Passo 3 — Passos manuais finais (sempre)

1. **Reinicie o GeneXus Next.** (No Docker, isso recicla e **sobe o container de volta no ar**.)
2. **View → Other Tool Windows → Plugin Explorer** → habilite/atualize o **WorkWithPlus**.
3. No diálogo **About**, confirme que **frontend** e **backend** mostram a mesma versão.
4. Se **não baterem**: limpe `%AppData%\GeneXus Next\Cache\Cache_Data` (ou rode o script Desktop com `-ClearCache`) e reabra.

## Observações

- O `settings-overrides.json` é **mesclado**, não sobrescrito — chaves do SQL são preservadas.
- A estrutura interna do plugin no Docker pode variar por versão; o script registra o que fez — confira contra o [guia oficial de Docker](https://docs.workwithplus.com/wiki?5506,WorkWithPlus+Next+Update+Docker,) se algo divergir.
- A edição do WWP para Next é **BETA com validade de 60 dias** — mantenha o plugin atualizado.
