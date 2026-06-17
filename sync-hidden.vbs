' sync-hidden.vbs - launch sync.ps1 without showing a console window

Option Explicit

Dim shell, fso, scriptDir, syncScript, command
Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
syncScript = fso.BuildPath(scriptDir, "sync.ps1")

command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File " & Chr(34) & syncScript & Chr(34)
shell.CurrentDirectory = scriptDir
shell.Run command, 0, False
