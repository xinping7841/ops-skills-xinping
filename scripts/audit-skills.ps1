# Audit local Codex skills against the Deepseek repository source of truth.

param(
    [string]$RepoDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

if (-not (Test-Path -LiteralPath (Join-Path $RepoDir '.git'))) {
    Write-Error "not a git repository: $RepoDir"
    exit 1
}

$repoNames = New-Object System.Collections.Generic.HashSet[string]
Get-ChildItem -LiteralPath $RepoDir -Filter 'skill-*.md' -File | ForEach-Object {
    [void]$repoNames.Add(($_.BaseName -replace '^skill-', ''))
}

$repoSkillRoot = Join-Path $RepoDir 'codex-skills'
if (Test-Path -LiteralPath $repoSkillRoot) {
    Get-ChildItem -LiteralPath $repoSkillRoot -Directory | ForEach-Object {
        [void]$repoNames.Add($_.Name)
    }
}

$localNames = New-Object System.Collections.Generic.HashSet[string]
$localSkillRoot = Join-Path $env:USERPROFILE '.codex\skills'
if (Test-Path -LiteralPath $localSkillRoot) {
    Get-ChildItem -LiteralPath $localSkillRoot -Directory | Where-Object {
        Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md')
    } | ForEach-Object {
        [void]$localNames.Add($_.Name)
    }
}

$missingLocal = $repoNames | Where-Object { -not $localNames.Contains($_) } | Sort-Object
$orphanLocal = $localNames | Where-Object { -not $repoNames.Contains($_) } | Sort-Object

Write-Host ("Repository skills: {0}" -f $repoNames.Count)
Write-Host ("Local Codex skills: {0}" -f $localNames.Count)
Write-Host ''

if ($missingLocal) {
    Write-Host 'Repo skills missing locally:'
    $missingLocal | ForEach-Object { Write-Host "  - $_" }
} else {
    Write-Host 'Repo skills missing locally: none'
}

Write-Host ''

if ($orphanLocal) {
    Write-Host 'Local skills not in repo:'
    $orphanLocal | ForEach-Object { Write-Host "  - $_" }
} else {
    Write-Host 'Local skills not in repo: none'
}
