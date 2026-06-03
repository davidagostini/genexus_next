<#
.SYNOPSIS
  Faz Claude Code e Codex/Gemini lerem a MESMA pasta de skills (fonte unica), via junctions.
.DESCRIPTION
  Cada agente procura skills em pastas diferentes:
    - Claude Code: .claude/skills           (nao permite configurar outros caminhos)
    - Codex CLI:   .codex/skills e .agents/skills
    - Gemini CLI:  .agents/skills
  Para nao duplicar arquivos, a pasta REAL fica em .claude/skills (canonica) e este script cria
  junctions de diretorio (NAO precisam de admin/developer mode) apontando para ela:
    .agents/skills -> .claude/skills
    .codex/skills  -> .claude/skills
  Assim voce edita as skills em UM lugar so e todos os agentes leem os MESMOS arquivos.
  As junctions nao sao versionadas (.gitignore). Rode este script UMA vez apos clonar o repo.
#>
[CmdletBinding()] param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot
$canonical = Join-Path $root '.claude\skills'
if(-not (Test-Path -LiteralPath $canonical)){ throw "Pasta canonica nao encontrada: $canonical" }

function New-SkillsJunction([string]$relLink, [string]$target){
  $link = Join-Path $root $relLink
  $parent = Split-Path -Parent $link
  if(-not (Test-Path -LiteralPath $parent)){ New-Item -ItemType Directory -Path $parent -Force | Out-Null }
  if(Test-Path -LiteralPath $link){
    $item = Get-Item -LiteralPath $link -Force
    $isLink = ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
    if($isLink){
      (Get-Item -LiteralPath $link -Force).Delete()   # remove apenas a junction, nunca o alvo
    } else {
      Write-Host "  [!] '$relLink' ja existe como pasta real (nao e junction) — pulei para nao apagar nada." -ForegroundColor Yellow
      return
    }
  }
  New-Item -ItemType Junction -Path $link -Target $target | Out-Null
  Write-Host "  [ok] $relLink  ->  .claude\skills" -ForegroundColor Green
}

Write-Host "Fonte unica de skills = .claude\skills" -ForegroundColor Cyan
Write-Host "Criando junctions:" -ForegroundColor Cyan
New-SkillsJunction '.agents\skills' $canonical
New-SkillsJunction '.codex\skills'  $canonical

Write-Host ""
Write-Host "Pronto. Edite as skills em .claude\skills — Claude, Codex e Gemini leem os MESMOS arquivos." -ForegroundColor Green
