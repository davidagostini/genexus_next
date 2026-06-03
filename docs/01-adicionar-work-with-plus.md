# 01 — Adicionar o Work With Plus

Guia prático para instalar/habilitar o **Work With Plus (WWP)** na sua Knowledge Base do **GeneXus Next** e aplicar o pattern.

O Work With Plus é um acelerador da **Dvelop** que gera telas (Work With, cadastros, dashboards) já prontas, com um Design System moderno e responsivo, no lugar do pattern Work With padrão do GeneXus.

> ⚠️ No **GeneXus Next** o Work With Plus é um **plugin** (não o instalador `.exe` clássico do GeneXus 18). Ele é habilitado pelo **Plugin Explorer** e atualizado a partir de um pacote `.zip`.

> 🧪 **A edição do WWP para GeneXus Next está em BETA por tempo limitado:** a build para de funcionar **60 dias após o lançamento** e **não é recomendada para produção**. Mantenha o plugin sempre atualizado. (Fonte: [WorkWithPlus - GeneXus Next Edition](https://docs.workwithplus.com/wiki?5348,Toc%3AWorkWithPlus+-+GeneXus+Next+Edition,))

---

## 📥 Onde baixar — sempre verifique a versão mais recente

**Página oficial de downloads:** **[developer.workwithplus.com/downloads](https://developer.workwithplus.com/downloads)**

1. Acesse a página acima (requer login).
2. No primeiro seletor, escolha **GeneXus Next**.
3. Escolha o **Setup** e a **Version** desejada (produto: WorkWithPlus base, Web, Mobile, Audit, BI ou Videocall).
4. Clique em **Download** (cada versão também tem **Release notes**).

> ⭐ **Sempre consulte essa página para pegar a versão mais recente** — não fixe uma build antiga (lembre do limite de 60 dias da BETA).

**Referência (build atual em jun/2026):**

| Produto | Versão | GeneXus Next alvo |
|---------|--------|-------------------|
| GeneXus Next plugin (WorkWithPlus) | **16.1.0.8078** | **2026.01** |

- Link direto desta build (exemplo): [`WorkWithPlus_Next_Plugin_v16u1.0_8078.zip`](https://workwithplus.s3.us-east-1.amazonaws.com/setups/next/WorkWithPlus_Next_Plugin_v16u1.0_8078.zip)
- Variantes no seletor: **WorkWithPlus (Web)**, **Mobile**, **Audit**, **BI**, **Videocall**.

---

## Antes de começar (pré-requisitos)

| Item | Detalhe |
|------|---------|
| GeneXus Next | **2025.2 ou superior** (o WWP para Next está disponível a partir dessa versão). |
| Deploy **Desktop** | Este guia cobre o **GeneXus Next Desktop**. Ao abrir o Next, se o **Docker** iniciar, você está na versão Docker — use o guia [Update version using Docker](https://docs.workwithplus.com/wiki?5506,WorkWithPlus+Next+Update+Docker,). |
| Knowledge Base | Já criada e abrindo normalmente. |
| Licença do Work With Plus | Se for a primeira vez, solicite ao seu **distribuidor local**. |
| Permissão de administrador | Necessária para copiar arquivos na pasta de instalação (Caminho B). |

---

## Instalação — escolha um caminho

O **Caminho A** é o mais rápido; o **Caminho B** garante a **versão mais recente** (recomendado pela BETA de 60 dias).

### 🟦 Caminho A — Habilitar pelo Plugin Explorer (rápido)

Instala a versão do WWP que **acompanha** o seu GeneXus Next.

1. No menu, vá em **View → Other Tool Windows → Plugin Explorer**.
2. Localize o **WorkWithPlus** na lista e clique em **Install**.
3. Após alguns minutos, surge uma janela modal — clique em **Restart** para concluir.

✅ O WorkWithPlus fica disponível na KB.

### 🟦 Caminho B — Instalar a versão mais recente (Desktop)

Procedimento oficial para colocar a build mais nova manualmente.

**1. Baixe o plugin**
Baixe o `.zip` em [developer.workwithplus.com/downloads](https://developer.workwithplus.com/downloads) → **GeneXus Next**.

**2. Defina o caminho do catálogo de plugins (`PluginsCatalogPath`)**

O GeneXus Next lê as configurações de `<Instalação do GeneXus Next>\bl\settings.json`. Para sobrescrever valores **sem editar o arquivo padrão**, crie um **`settings-overrides.json`** na **mesma pasta `\bl\`** — ele tem prioridade sobre o `settings.json`. (Mecanismo documentado no guia oficial [GeneXus for Agents – Installation guide for Windows Native](https://docs.genexus.com/en/wiki?61635,GeneXus+for+Agents+-+Installation+guide+for+Windows+Native).)

1. Abra `<Instalação do GeneXus Next>\bl\settings.json` e procure a chave **`"PluginsCatalogPath"`**.
2. Se **não existir** ou estiver **`null`**, crie/edite **`<Instalação do GeneXus Next>\bl\settings-overrides.json`** com:
   ```json
   {
     "PluginsCatalogPath": "C:\\GeneXus\\pluginsCatalog"
   }
   ```
   > ⚠️ Use barras invertidas **duplas** (`\\`) nos caminhos do Windows.

💡 O mesmo `settings-overrides.json` aceita outras chaves de override (ex.: `ProjectsFolder`, `SqlServerDefaultInstance`) — usaremos isso no doc **02 — Configurar o SQL Server**.

**3. Crie a estrutura de pastas**
```
<PluginsCatalogPath>\WorkWithPlus\<versão>\
```
Ex.: `C:\GeneXus\pluginsCatalog\WorkWithPlus\16.1.0.8078\`

**4. Extraia o `.zip` na pasta da versão**
O conteúdo deve conter `plugin.json`, `backend.zip`, `frontend.zip` e demais arquivos.

**5. Reinicie o GeneXus Next**
Feche e reabra o aplicativo Desktop **completamente**.

**6. Habilite/atualize e verifique a versão**
- Use o **Plugin Explorer** para **habilitar/atualizar** o WorkWithPlus.
- Confirme no diálogo **About** (na barra de ferramentas) que as versões de **frontend** e **backend** **coincidem**.

**7. Se as versões não baterem — limpe o cache**
Apague os arquivos de cache em:
```
%AppData%\GeneXus Next\Cache\Cache_Data
```
e reabra o GeneXus Next.

🔗 Procedimento oficial: [WorkWithPlus Next Install](https://docs.workwithplus.com/wiki?5501,WorkWithPlus+Next+Install,) · [Update version using Desktop](https://docs.workwithplus.com/wiki?5525,WorkWithPlus+Next+Update+Desktop,)

> 🐳 Está rodando o Next via **Docker**? Siga o guia específico: [Update version using Docker](https://docs.workwithplus.com/wiki?5506,WorkWithPlus+Next+Update+Docker,).

---

## 🟦 Licenciamento

| Situação | O que fazer |
|----------|-------------|
| **Primeira instalação** (sem licença ainda) | Contate seu **distribuidor local** para obter a licença. |
| **Licença com manutenção vigente** | Não precisa atualizar a licença — basta instalar e usar. |
| **Licença com manutenção vencida** | Contate o distribuidor para atualizar/renovar. |

---

## 🟦 Aplicar o pattern (primeiro uso)

O Work With Plus é aplicado **por objeto**, gerando uma _instância_ a partir de templates.

**Em uma Transaction:**
1. Crie (ou abra) a Transaction e **salve**.
2. Aplique o **pattern WorkWithPlus** — a instância é gerada a partir dos templates (telas de listagem/seleção e de cadastro).

**Em um Web Panel:**
1. Crie o **Web Panel** e **salve**.
2. Clique no link **"Create WorkWithPlus Pattern Instance..."**.
3. Configure a instância conforme a tela.

🔗 Referência: [Apply all WorkWithPlus pattern instances](https://docs.workwithplus.com/servlet/com.wiki.wiki?1107,Apply+all+WorkWithPlus+pattern+instances,)

### Gerar os objetos após mudanças

Ao editar uma instância (ou um template), o **objeto GeneXus não muda sozinho**. Para regenerar:

- Use **"Apply all WorkWithPlus pattern instances"** para reaplicar todas as instâncias e atualizar os objetos GeneXus.

💡 Faça isso sempre após alterar o **Design System** ou os **templates**. Depois, rode o **build** da KB (F5 / Run) e valide as telas.

---

## Limitações conhecidas (BETA)

Recursos **ainda não disponíveis** nesta edição do WWP para GeneXus Next:

- Preview do **Web Design System Wizard** após customizações.
- Editor customizado de **Settings** (criar/modificar templates).
- Editores do **Instance editor**, como o **Magic IDE**.
- Acesso ao **editor de código-fonte** do WorkWithPlus.
- Editores de **tipos de dados customizados**.
- Inicialização de **Native Mobile** e o **Design System Wizard** completo para mobile.

🔗 Lista oficial: [WorkWithPlus Next known limitations](https://docs.workwithplus.com/wiki?5350,WorkWithPlus+Next+known+limitations,)

---

## Compatibilidade (GeneXus Next)

✅ O Work With Plus tem **plugin dedicado para o GeneXus Next** (linha **v16**), distribuído como `.zip`.

- Disponível a partir do **GeneXus Next 2025.2**.
- Cada build é homologada para uma versão do Next (ex.: **16.1.0.8078 → Next 2026.01**).
- ⚠️ Sempre baixe a build correspondente à **sua** versão do Next em [developer.workwithplus.com/downloads](https://developer.workwithplus.com/downloads).

---

## Solução de problemas

| Sintoma | Possível causa / solução |
|---------|--------------------------|
| WWP não aparece no **Plugin Explorer** | Versão do GeneXus Next abaixo de **2025.2**. Atualize o Next. |
| Plugin Explorer instala uma versão **antiga** | Use o **Caminho B** para instalar o `.zip` mais recente. |
| Versões de **frontend e backend não batem** (About) | Limpe o cache: apague `%AppData%\GeneXus Next\Cache\Cache_Data` e reabra. |
| `PluginsCatalogPath` não existe no `settings.json` | Crie `settings-overrides.json` em `\bl\` (veja o Passo 2 do Caminho B). |
| Ao abrir o Next o **Docker** inicia | Você está na versão Docker — use o [guia de Docker](https://docs.workwithplus.com/wiki?5506,WorkWithPlus+Next+Update+Docker,). |
| WWP "para de funcionar" | Limite da **BETA (60 dias)**. Baixe e instale a build mais recente. |
| Erro de licença ao aplicar o pattern | Licença ausente/vencida — veja [Licenciamento](#-licenciamento). |
| Telas não atualizam após mudar o Design System | Faltou rodar **"Apply all WorkWithPlus pattern instances"**. |

---

## Referências oficiais

- 🔗 [WorkWithPlus - GeneXus Next Edition (índice)](https://docs.workwithplus.com/wiki?5348,Toc%3AWorkWithPlus+-+GeneXus+Next+Edition,)
- 🔗 [Downloads — selecione GeneXus Next](https://developer.workwithplus.com/downloads) ← **fonte da versão mais recente**
- 🔗 [WorkWithPlus Next Install](https://docs.workwithplus.com/wiki?5501,WorkWithPlus+Next+Install,)
- 🔗 [Update version using Desktop](https://docs.workwithplus.com/wiki?5525,WorkWithPlus+Next+Update+Desktop,)
- 🔗 [Update version using Docker](https://docs.workwithplus.com/wiki?5506,WorkWithPlus+Next+Update+Docker,)
- 🔗 [Known limitations](https://docs.workwithplus.com/wiki?5350,WorkWithPlus+Next+known+limitations,)
- 🔗 [Update logs](https://docs.workwithplus.com/wiki?5352,WorkWithPlus+Next+Update+Logs,)
- 🔗 [Apply all WorkWithPlus pattern instances](https://docs.workwithplus.com/servlet/com.wiki.wiki?1107,Apply+all+WorkWithPlus+pattern+instances,)
- 🔗 [GeneXus for Agents – Installation guide for Windows Native](https://docs.genexus.com/en/wiki?61635,GeneXus+for+Agents+-+Installation+guide+for+Windows+Native) — mecanismo do `settings-overrides.json`

---

⬅️ [Voltar ao índice](../README.md) · ➡️ Próximo: _02 — Configurar o SQL Server_ (em breve)
