@echo off
setlocal EnableExtensions
chcp 65001 >nul
cd /d "%~dp0"
title ProSpace Health - Painel de Gestao

echo ================================================
echo          PROSPACE HEALTH - GESTAO
echo ================================================
echo.
where python >nul 2>nul
if errorlevel 1 (
  where py >nul 2>nul
  if errorlevel 1 (
    echo ERRO: Python nao foi encontrado.
    echo Instale Python 3 em https://www.python.org/downloads/windows/
    echo Marque a opcao Add Python to PATH durante a instalacao.
    pause
    exit /b 1
  )
  set "PYTHON_CMD=py"
) else (
  set "PYTHON_CMD=python"
)
if not exist "index.html" (
  echo ERRO: index.html nao encontrado. Extraia o ZIP inteiro.
  pause
  exit /b 1
)
echo Abrindo o painel em http://localhost:8090
echo Mantenha esta janela aberta enquanto utilizar o sistema.
echo Para encerrar, pressione Ctrl+C e confirme com S.
start "" /B cmd /c "timeout /t 2 /nobreak >nul & start http://localhost:8090"
%PYTHON_CMD% -m http.server 8090
if errorlevel 1 (
  echo.
  echo Nao foi possivel iniciar o servidor local. Talvez a porta 8090 esteja ocupada.
  pause
)
