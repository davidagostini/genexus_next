<#
.SYNOPSIS
  Instala/atualiza o plugin WorkWithPlus no GeneXus Next Desktop (Windows Native).
.DESCRIPTION
  - Mescla a chave PluginsCatalogPath no <GxNextPath>\bl\settings-overrides.json (preserva as demais chaves).
  - Detecta a versao do plugin (plugin.json -> fallback nome do zip).
  - Monta a estrutura <PluginsCatalogPath>\WorkWithPlus\<versao>\ e copia os arquivos do zip.
  Fonte: https://docs.workwithplus.com/wiki?5525,WorkWithPlus+Next+Update+Desktop,
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)] [string] $GxNextPath,
  [Parameter(Mandatory)] [string] $ZipPath,
  [string] $PluginsCatalogPath = 'C:\GeneXus\pluginsCatalog',
  [string] $Version,
  [switch] $ClearCache
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Step($m){ Write-Host "==> $m" -ForegroundColor Cyan }
function Write-Ok($m){ Write-Host "  [ok] $m" -ForegroundColor Green }
function Write-Note($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }

# --- Validacoes -------------------------------------------------------------
if(-not (Test-Path -LiteralPath $ZipPath)){ throw "Zip nao encontrado: $ZipPath" }
$blPath = Join-Path $GxNextPath 'bl'
if(-not (Test-Path -LiteralPath $blPath)){
  throw "Pasta 'bl' nao encontrada em '$GxNextPath'. Confirme a pasta de instalacao do GeneXus Next (a que contem 'bl\settings.json')."
}

# --- 1) settings-overrides.json: define PluginsCatalogPath (merge) ----------
Write-Step "Configurando PluginsCatalogPath no settings-overrides.json"
$overridesPath = Join-Path $blPath 'settings-overrides.json'
$settings = @{}
if(Test-Path -LiteralPath $overridesPath){
  $raw = (Get-Content -LiteralPath $overridesPath -Raw)
  if($raw -and $raw.Trim()){
    try {
      $obj = $raw | ConvertFrom-Json
      if($obj){ foreach($p in $obj.PSObject.Properties){ $settings[$p.Name] = $p.Value } }
    }
    catch { throw "O arquivo existente '$overridesPath' nao e um JSON valido. Corrija ou remova o arquivo e rode novamente. Detalhe: $($_.Exception.Message)" }
  }
}
$settings['PluginsCatalogPath'] = $PluginsCatalogPath
[System.IO.File]::WriteAllText($overridesPath, ($settings | ConvertTo-Json -Depth 20), (New-Object System.Text.UTF8Encoding($false)))
Write-Ok "PluginsCatalogPath = $PluginsCatalogPath"

# --- 2) Extrai para temp e detecta a versao --------------------------------
Write-Step "Lendo o plugin e detectando a versao"
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ("wwp_" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temp | Out-Null
try {
  Expand-Archive -LiteralPath $ZipPath -DestinationPath $temp -Force

  $pluginJson = Get-ChildItem -LiteralPath $temp -Recurse -Filter 'plugin.json' | Select-Object -First 1
  if(-not $pluginJson){ throw "plugin.json nao encontrado no zip. O arquivo e mesmo o plugin do WorkWithPlus para GeneXus Next?" }
  $pluginRoot = $pluginJson.Directory.FullName

  if(-not $Version){
    try {
      $pj = Get-Content -LiteralPath $pluginJson.FullName -Raw | ConvertFrom-Json
      foreach($k in 'version','Version','pluginVersion'){
        if(($pj.PSObject.Properties.Name -contains $k) -and $pj.$k){ $Version = [string]$pj.$k; break }
      }
    } catch { }
  }
  if(-not $Version){
    $name = [System.IO.Path]::GetFileNameWithoutExtension($ZipPath)
    $m = [regex]::Match($name, 'v?(\d+)u(\d+)\.(\d+)[_-](\d+)')
    if($m.Success){ $Version = "$($m.Groups[1].Value).$($m.Groups[2].Value).$($m.Groups[3].Value).$($m.Groups[4].Value)" }
  }
  if(-not $Version){ throw "Nao foi possivel determinar a versao. Rode novamente informando -Version (ex.: 16.1.0.8078)." }
  Write-Ok "Versao: $Version"

  # --- 3) Monta o catalogo e copia ----------------------------------------
  Write-Step "Montando o catalogo de plugins"
  $target = Join-Path (Join-Path $PluginsCatalogPath 'WorkWithPlus') $Version
  if(Test-Path -LiteralPath $target){
    Write-Note "Pasta da versao ja existe e sera substituida: $target"
    Remove-Item -LiteralPath $target -Recurse -Force
  }
  New-Item -ItemType Directory -Path $target -Force | Out-Null
  Copy-Item -Path (Join-Path $pluginRoot '*') -Destination $target -Recurse -Force
  Write-Ok "Plugin instalado em: $target"

  if(-not (Test-Path -LiteralPath (Join-Path $target 'plugin.json'))){ Write-Note "plugin.json nao esta na raiz de $target — verifique a estrutura." }
  foreach($f in 'backend.zip','frontend.zip'){
    if(Test-Path -LiteralPath (Join-Path $target $f)){ Write-Ok "$f presente" } else { Write-Note "$f ausente em $target" }
  }
}
finally {
  Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
}

# --- 4) Cache opcional ------------------------------------------------------
if($ClearCache){
  $cache = Join-Path $env:AppData 'GeneXus Next\Cache\Cache_Data'
  if(Test-Path -LiteralPath $cache){
    Get-ChildItem -LiteralPath $cache -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Write-Ok "Cache limpo: $cache"
  } else { Write-Note "Cache nao encontrado: $cache" }
}

Write-Host ""
Write-Host "Concluido (Desktop). Proximos passos manuais:" -ForegroundColor Cyan
Write-Host "  1) Reinicie o GeneXus Next."
Write-Host "  2) View -> Other Tool Windows -> Plugin Explorer -> habilite/atualize o WorkWithPlus."
Write-Host "  3) No dialogo About, confirme que frontend e backend mostram a versao $Version."
Write-Host "  4) Se nao baterem, rode novamente com -ClearCache e reabra o GeneXus Next."
