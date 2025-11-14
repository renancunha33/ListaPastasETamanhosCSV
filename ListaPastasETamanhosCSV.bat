@echo off
setlocal EnableExtensions

chcp 65001 >nul 2>&1

:: Parametros
set "ROOT=%~1"
if not defined ROOT set "ROOT=%cd%"
for %%# in ("%ROOT%") do set "ROOT=%%~f#"

set "OUT=%~2"
if not defined OUT (
  for /f "tokens=1-5 delims=/:. " %%a in ("%date% %time%") do (
    set "YYYY=%%c" & set "MM=%%b" & set "DD=%%a" & set "HH=%%d" & set "MN=%%e"
  )
  set "STAMP=%YYYY%%MM%%DD%_%HH%%MN%"
  set "OUT=%cd%\pastas_tamanhos_%STAMP%.csv"
)

if not exist "%ROOT%" (
  echo [ERRO] Diretorio raiz nao existe: "%ROOT%"
  exit /b 1
)

> "%OUT%" echo Nome;Tamanho(MB);Caminho

set "FOUND=0"
for /d %%D in ("%ROOT%\*") do (
  set "FOUND=1"
  for /f "usebackq delims=" %%S in (`
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "$p = '%%~fD';" ^
      "$s = (Get-ChildItem -LiteralPath $p -Recurse -File -Force -EA SilentlyContinue | Measure-Object -Property Length -Sum).Sum;" ^
      "if (-not $s) { $s = 0 };" ^
      "[math]::Round($s/1MB, 2)"
  `) do (
    set "NAME=%%~nxD"
    setlocal EnableDelayedExpansion
    set "NAME=!NAME:"=""!"
    >> "%OUT%" echo !NAME!;%%S;%%~fD
    endlocal
  )
)

if "%FOUND%"=="0" (
  echo [AVISO] Nenhuma subpasta encontrada em "%ROOT%".
)

echo CSV gerado: "%OUT%"
endlocal