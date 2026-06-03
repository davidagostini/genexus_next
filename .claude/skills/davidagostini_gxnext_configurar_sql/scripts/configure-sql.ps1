<#
.SYNOPSIS
  Configura a conexao do GeneXus Next com o SQL Server via settings-overrides.json.
.DESCRIPTION
  TESTA a conexao com o SQL Server ANTES de gravar. So finaliza (grava as chaves) se a conexao
  estiver OK. Se falhar, nada e gravado (use -Force para gravar mesmo assim). Use -SkipConnectionTest
  para pular o teste.
  As chaves gravadas (merge, preservando as existentes como PluginsCatalogPath):
    ProjectsFolder, ProjectsDataFolder, SqlServerDefaultInstance, SqlUserName, SqlUserPassword.
  Fonte: https://docs.genexus.com/en/wiki?61635,GeneXus+for+Agents+-+Installation+guide+for+Windows+Native
.EXAMPLE
  configure-sql.ps1 -GxNextPath "C:\Program Files\GeneXus\GeneXus Next" -ProjectsFolder "C:\modelos\next\KBNome" `
    -SqlServerDefaultInstance "PC\SQLEXPRESS" -SqlUserName usuario -SqlUserPassword senha
#>
[CmdletBinding()]
param(
  [string] $GxNextPath,
  [string] $SettingsDir,
  [Parameter(Mandatory)] [string] $ProjectsFolder,
  [string] $ProjectsDataFolder,
  [Parameter(Mandatory)] [string] $SqlServerDefaultInstance,
  [string] $SqlUserName,
  [string] $SqlUserPassword,
  [switch] $WindowsAuth,
  [switch] $SkipConnectionTest,
  [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Step($m){ Write-Host "==> $m" -ForegroundColor Cyan }
function Write-Ok($m){ Write-Host "  [ok] $m" -ForegroundColor Green }
function Write-Note($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
function Write-Err($m){ Write-Host "  [x] $m" -ForegroundColor Red }

function Test-SqlConnection {
  param([string]$Instance, [bool]$WinAuth, [string]$User, [string]$Pass)

  # Carrega um driver SqlClient disponivel
  $type = 'System.Data.SqlClient.SqlConnection' -as [type]
  if(-not $type){
    foreach($asm in 'System.Data.SqlClient','System.Data'){
      try { Add-Type -AssemblyName $asm -ErrorAction Stop } catch { }
      $type = 'System.Data.SqlClient.SqlConnection' -as [type]
      if($type){ break }
    }
  }
  if(-not $type){ $type = 'Microsoft.Data.SqlClient.SqlConnection' -as [type] }
  if(-not $type){
    return [pscustomobject]@{ Result='unavailable'; Message='Driver SqlClient nao encontrado neste ambiente.' }
  }

  if($WinAuth){
    $cs = "Server=$Instance;Integrated Security=True;Encrypt=False;TrustServerCertificate=True;Connect Timeout=5"
  } else {
    $cs = "Server=$Instance;User Id=$User;Password=$Pass;Encrypt=False;TrustServerCertificate=True;Connect Timeout=5"
  }
  try {
    $conn = $type::new($cs)
    $conn.Open()
    $ver = $conn.ServerVersion
    $conn.Close()
    return [pscustomobject]@{ Result='ok'; Message="SQL Server $ver" }
  } catch {
    return [pscustomobject]@{ Result='failed'; Message=$_.Exception.Message }
  }
}

# --- Resolver a pasta que contem o settings.json ---------------------------
if(-not $SettingsDir){
  if(-not $GxNextPath){ throw "Informe -GxNextPath (pasta de instalacao, com 'bl') ou -SettingsDir (pasta com settings.json, ex.: o 'gxbl' do Docker)." }
  $SettingsDir = Join-Path $GxNextPath 'bl'
}
if(-not (Test-Path -LiteralPath $SettingsDir)){ throw "Pasta de configuracao nao encontrada: $SettingsDir" }

if(-not $ProjectsDataFolder){ $ProjectsDataFolder = $ProjectsFolder }

# --- Validar autenticacao ---------------------------------------------------
if(-not $WindowsAuth){
  if(-not $SqlUserName -or -not $SqlUserPassword){
    throw "Para autenticacao SQL informe -SqlUserName e -SqlUserPassword (ou use -WindowsAuth)."
  }
}

# --- 1) Testar a conexao ANTES de gravar -----------------------------------
$test = [pscustomobject]@{ Result='skipped'; Message='Teste pulado (-SkipConnectionTest).' }
if(-not $SkipConnectionTest){
  Write-Step "Testando conexao com o SQL Server ($SqlServerDefaultInstance) antes de gravar"
  $test = Test-SqlConnection -Instance $SqlServerDefaultInstance -WinAuth:$WindowsAuth -User $SqlUserName -Pass $SqlUserPassword
  switch($test.Result){
    'ok'          { Write-Ok "Conexao OK — $($test.Message)" }
    'failed'      { Write-Err "Conexao FALHOU — $($test.Message)" }
    'unavailable' { Write-Note $test.Message }
  }
}

# --- Decidir se finaliza ----------------------------------------------------
if($test.Result -eq 'failed' -and -not $Force){
  Write-Host ""
  Write-Err "Nada foi gravado: a conexao com o SQL falhou."
  Write-Host "  Verifique: modo de autenticacao mista, usuario/senha, nome da instancia, TCP/IP, SQL Browser e firewall." -ForegroundColor Yellow
  Write-Host "  Corrija e rode de novo, ou use -Force para gravar mesmo assim." -ForegroundColor Yellow
  throw "Conexao SQL invalida — configuracao abortada."
}

# --- 2) Finalizar: merge no settings-overrides.json ------------------------
Write-Step "Conexao validada — gravando settings-overrides.json"
$overridesPath = Join-Path $SettingsDir 'settings-overrides.json'
$settings = @{}
if(Test-Path -LiteralPath $overridesPath){
  $raw = (Get-Content -LiteralPath $overridesPath -Raw)
  if($raw -and $raw.Trim()){
    try {
      $obj = $raw | ConvertFrom-Json
      if($obj){ foreach($p in $obj.PSObject.Properties){ $settings[$p.Name] = $p.Value } }
    }
    catch { throw "O arquivo existente '$overridesPath' nao e um JSON valido. Corrija ou remova e rode novamente. Detalhe: $($_.Exception.Message)" }
  }
}

$settings['ProjectsFolder']           = $ProjectsFolder
$settings['ProjectsDataFolder']       = $ProjectsDataFolder
$settings['SqlServerDefaultInstance'] = $SqlServerDefaultInstance
if($WindowsAuth){
  [void]$settings.Remove('SqlUserName')
  [void]$settings.Remove('SqlUserPassword')
  Write-Ok "Autenticacao: Windows (integrada)"
} else {
  $settings['SqlUserName']     = $SqlUserName
  $settings['SqlUserPassword'] = $SqlUserPassword
  Write-Ok "Autenticacao: SQL (usuario '$SqlUserName')"
}

[System.IO.File]::WriteAllText($overridesPath, ($settings | ConvertTo-Json -Depth 20), (New-Object System.Text.UTF8Encoding($false)))
Write-Ok "Gravado: $overridesPath"
Write-Ok "ProjectsFolder = $ProjectsFolder"
Write-Ok "SqlServerDefaultInstance = $SqlServerDefaultInstance"

# --- Garantir a pasta da KB -------------------------------------------------
if(-not (Test-Path -LiteralPath $ProjectsFolder)){
  New-Item -ItemType Directory -Path $ProjectsFolder -Force | Out-Null
  Write-Ok "Pasta criada: $ProjectsFolder"
}

# --- Avisos finais ----------------------------------------------------------
if($test.Result -eq 'failed' -and $Force){ Write-Note "Gravado com -Force apesar da falha de conexao — valide o SQL antes de usar." }
if($test.Result -eq 'unavailable'){ Write-Note "A conexao nao pode ser testada aqui — valide pelo SSMS antes de criar a KB." }
if($test.Result -eq 'skipped'){ Write-Note "Teste de conexao foi pulado — valide pelo SSMS antes de criar a KB." }

Write-Host ""
Write-Host "Concluido. Proximos passos:" -ForegroundColor Cyan
Write-Host "  1) Feche e reabra o GeneXus Next."
Write-Host "  2) Crie/abra uma KB — sera criada em $ProjectsFolder e no SQL configurado."
Write-Host "  3) Confirme no SSMS que os bancos apareceram."
