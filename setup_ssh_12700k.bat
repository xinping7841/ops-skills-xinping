@echo off
echo ============================================
echo   12700k SSH Key Setup for wanghongyu@bogon
echo ============================================
echo.

set KEYFILE=C:\ProgramData\ssh\administrators_authorized_keys

echo Writing keys to %KEYFILE% ...
(
echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZmo5BV9FJ20YeMqFz3L5zt04gn9/5RsMQNcFuy7Epb7NJRkFa5JeE5FJfjhv2eJGlRBLW8AS86qkPwufFL7RX2W5u/6m01vsRYJFNSXhaPAllDe4McxKqyPT1eUrIdmfK6NMNWY+p0heRS9e/1rjGDCn5F538LEBPaX082otf7mFsj8C0MLkIvjCW3YZcuxvBSGABaE+Ye/6jLHOmr3XV5MlWwGimGxwvTQqD9EMkfbLppL5uK60Ji6Qg2LAtF+817mrn9AiRw4Djb2pa4Bw1NC086GEGUVnpswJNWs04NX2jNdFYTuygUnUh2hc6/ViJOzUxPTP2Y/N6D+Nz0lYPh50IT7Lqj0toh/omAxvTdmksYkTbRZE0/DkX0i/+lvfMVE5oLS5b3lJy4pAqW5cVT/aVJx07TeKFOnxklCqULKk8Dlp+/YZHNw21BKAMQDDWEeAW+T6H+QmVaoWOtEtuF/TDFPmfyFgR3PRCWm1zTDSdBvaAWFF258EP9QYrJbM= lk402-codex-to-12700k
echo ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKueONRFC7xg/6gCJW+InVq1yDCKloIIK/LD/cb07vlb gaoxi@lk402
echo ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIADSa1NydZ0L4fYpadK/mMeQoi/ccMGypVY+0u8FO1Ow wanghongyu@bogon
) > %KEYFILE%

if %ERRORLEVEL% neq 0 (
    echo [FAIL] Failed to write key file!
    pause
    exit /b 1
)
echo [OK] Keys written.

echo.
echo Fixing permissions...
icacls %KEYFILE% /inheritance:r /grant "SYSTEM:(F)" /grant "BUILTIN\Administrators:(F)" >nul 2>&1
echo [OK] Permissions set.

echo.
echo Restarting SSH service...
net stop sshd >nul 2>&1
net start sshd >nul 2>&1
echo [OK] SSHD restarted.

echo.
echo ============================================
echo   Verifying file content:
echo ============================================
type %KEYFILE%

echo.
echo ============================================
echo   Setup complete! Tell Kun to test now.
echo ============================================
pause
