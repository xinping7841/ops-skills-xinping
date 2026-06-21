# Verify Three-Machine Sync

Use this runbook before and after changing SSH, MCP, sync scripts, scheduler tasks, or machine paths.

## macair

```bash
cd /Users/xinping/Documents/Deepseek
git fetch origin
git status --short
git rev-parse HEAD
git rev-parse origin/main
launchctl list | rg 'com\.ops-skills\.sync' || true
ssh -i ~/.ssh/id_ed25519_nodes -o BatchMode=yes -o ConnectTimeout=8 gaoxi@100.94.150.23 hostname
ssh -i ~/.ssh/id_ed25519_nodes -o BatchMode=yes -o ConnectTimeout=8 gaoxi@100.89.199.122 hostname
```

## 12700K

```powershell
git -C D:\Deepseek fetch origin
git -C D:\Deepseek status --short
git -C D:\Deepseek rev-parse HEAD
git -C D:\Deepseek rev-parse origin/main
ssh -T -o BatchMode=yes -o ConnectTimeout=8 git@github.com
ssh -o BatchMode=yes -o ConnectTimeout=8 lk402 hostname
ssh -o BatchMode=yes -o ConnectTimeout=8 macair hostname
Get-ScheduledTask -TaskName 'Deepseek-Sync'
Get-ScheduledTaskInfo -TaskName 'Deepseek-Sync'
```

Expected task action: `wscript.exe D:\Deepseek\sync-hidden.vbs`, working directory `D:\Deepseek`.

## lk402

```powershell
git -C D:\Deepseek fetch origin
git -C D:\Deepseek status --short
git -C D:\Deepseek rev-parse HEAD
git -C D:\Deepseek rev-parse origin/main
ssh -T -o BatchMode=yes -o ConnectTimeout=8 git@github.com
ssh -o BatchMode=yes -o ConnectTimeout=8 12700k hostname
ssh -o BatchMode=yes -o ConnectTimeout=8 macair hostname
Get-ScheduledTask -TaskName 'Deepseek-Sync'
Get-ScheduledTaskInfo -TaskName 'Deepseek-Sync'
```

Expected task action: `wscript.exe D:\Deepseek\sync-hidden.vbs`, working directory `D:\Deepseek`.

## MCP Path Check

Search local Codex/Kun configs for stale Deepseek roots:

```powershell
Select-String -LiteralPath "$env:USERPROFILE\.codex\config.toml","$env:USERPROFILE\.kun\mcp.json","$env:USERPROFILE\.kun\data\config.json" -Pattern 'Documents\\Deepseek|D:\\Deepseek|server-filesystem'
```

On Windows, `Documents\Deepseek` should not appear for the Deepseek workspace unless explicitly documented as legacy state.

