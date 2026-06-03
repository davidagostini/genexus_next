<#
.SYNOPSIS
  Instala/atualiza o plugin WorkWithPlus no GeneXus Next rodando via Docker.
.DESCRIPTION
  - Descobre o container do GeneXus e o bind mount 'user-app-data' (pasta 'gxbl') via docker inspect.
  - Extrai o plugin nessa pasta e expande frontend.zip e backend.zip nas subpastas correspondentes.
  - Opcionalmente reinicia o container (-RestartContainer).
  Fonte: https://docs.workwithplus.com/wiki?5506,WorkWithPlus+Next+Update+Docker,
.NOTES
  O restart "oficial" e feito reiniciando o GeneXus Next (que recicla o container).
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)] [string] $ZipPath,
  [string] $UserAppDataPath,
  [switch] $RestartContainer
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Step($m){ Write-Host "==> $m" -ForegroundColor Cyan }
function Write-Ok($m){ Write-Host "  [ok] $m" -ForegroundColor Green }
function Write-Note($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }

if(-not (Test-Path -LiteralPath $ZipPath)){ throw "Zip nao encontrado: $ZipPath" }

$containerId = $null

# --- 1) Descobrir o bind mount 'user-app-data' (gxbl) ----------------------
if(-not $UserAppDataPath){
  Write-Step "Procurando o container do GeneXus e o bind mount 'user-app-data'"
  if(-not (Get-Command docker -ErrorAction SilentlyContinue)){
    throw "docker nao encontrado no PATH. Informe -UserAppDataPath (aba 'Bind mounts' do container no Docker Desktop)."
  }

  $candidates = @()
  $lines = docker ps --format '{{.ID}}|{{.Image}}|{{.Names}}'
  foreach($line in $lines){
    if(-not $line){ continue }
    $parts = $line.Split('|')
    $id = $parts[0]
    try { $info = docker inspect $id | ConvertFrom-Json } catch { continue }
    $mounts = @($info[0].Mounts)
    foreach($mt in $mounts){
      $src = [string]$mt.Source
      $dst = [string]$mt.Destination
      if(($src -match 'gxbl$') -or ($src -match 'GeneXus') -or ($dst -match 'user-app-data') -or ($dst -match 'app-data')){
        $candidates += [pscustomobject]@{ Id=$id; Image=$parts[1]; Name=$parts[2]; Source=$src; Destination=$dst }
      }
    }
  }

  # Preferir mounts cuja pasta termina em 'gxbl'
  $best = $candidates | Where-Object { $_.Source -match 'gxbl$' } | Select-Object -First 1
  if(-not $best){ $best = $candidates | Select-Object -First 1 }

  if(-not $best){
    throw "Nao encontrei o bind mount automaticamente. Abra o Docker Desktop -> container do GeneXus -> aba 'Bind mounts', copie o caminho do host (ex.: ...\GeneXus Next\gxbl) e rode novamente com -UserAppDataPath."
  }

  $UserAppDataPath = $best.Source
  $containerId = $best.Id
  Write-Ok "Container: $($best.Name) ($($best.Id))"
  Write-Ok "user-app-data: $UserAppDataPath"
}

if(-not (Test-Path -LiteralPath $UserAppDataPath)){
  throw "Caminho do host nao acessivel: $UserAppDataPath"
}

# --- 2) Extrair o plugin na pasta do bind mount ----------------------------
Write-Step "Extraindo o plugin em $UserAppDataPath"
Expand-Archive -LiteralPath $ZipPath -DestinationPath $UserAppDataPath -Force
Write-Ok "Plugin extraido"

# --- 3) Expandir frontend.zip e backend.zip nas subpastas ------------------
Write-Step "Expandindo frontend.zip e backend.zip"
foreach($inner in 'frontend.zip','backend.zip'){
  $found = Get-ChildItem -LiteralPath $UserAppDataPath -Recurse -Filter $inner -ErrorAction SilentlyContinue | Select-Object -First 1
  if(-not $found){ Write-Note "$inner nao encontrado (pode ja estar expandido)"; continue }
  $destName = [System.IO.Path]::GetFileNameWithoutExtension($found.Name)   # frontend / backend
  $dest = Join-Path $found.Directory.FullName $destName
  New-Item -ItemType Directory -Path $dest -Force | Out-Null
  Expand-Archive -LiteralPath $found.FullName -DestinationPath $dest -Force
  Write-Ok "$inner -> $dest"
}
Write-Note "Confira a estrutura final contra o guia oficial de Docker se algo divergir."

# --- 4) Reiniciar o container (opcional) -----------------------------------
if($RestartContainer -and $containerId){
  Write-Step "Reiniciando o container $containerId"
  docker restart $containerId | Out-Null
  Write-Ok "Container reiniciado (de volta no ar)"
}

Write-Host ""
Write-Host "Concluido (Docker). Proximos passos:" -ForegroundColor Cyan
Write-Host "  1) Reinicie o GeneXus Next (isso recicla e sobe o container de volta no ar)."
if(-not $RestartContainer){ Write-Host "     - Alternativa: rode novamente com -RestartContainer para reiniciar o container agora." }
Write-Host "  2) Plugin Explorer -> habilite/atualize o WorkWithPlus."
Write-Host "  3) No dialogo About, confirme que frontend e backend coincidem."
