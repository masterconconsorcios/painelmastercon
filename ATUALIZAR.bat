@echo off
chcp 65001 >nul
title Atualizar Painel da Loja - Mastercon
cd /d "%~dp0"

echo.
echo   ============================================
echo     ATUALIZANDO O PAINEL DA LOJA - MASTERCON
echo   ============================================
echo.

REM --- 1. Garante que as bibliotecas estao instaladas -------------
echo   Verificando componentes (so demora na 1a vez)...
python -m pip install --quiet --disable-pip-version-check pandas openpyxl pillow opencv-python-headless 2>nul
if errorlevel 1 (
  echo.
  echo   [!] Nao consegui preparar os componentes.
  echo       Confira se o Python foi instalado com "Add to PATH".
  echo.
  pause
  exit /b 1
)

REM --- 2. Roda o gerador ------------------------------------------
python gerar_painel.py
if errorlevel 1 (
  echo.
  echo   [!] Algo deu errado ao gerar. Leia a mensagem acima.
  pause
  exit /b 1
)

REM --- 3. Publica no GitHub Pages ---------------------------------
if not exist ".git" (
  echo.
  echo   Painel gerado. Publicacao automatica ainda nao configurada.
  echo   Rode o CONFIGURAR-GITHUB.bat uma vez para ligar isso.
  echo.
  timeout /t 10 >nul
  exit /b 0
)

echo.
echo   Publicando no GitHub...
git add -A
git diff --cached --quiet
if not errorlevel 1 (
  echo   Nada mudou desde a ultima publicacao.
  timeout /t 8 >nul
  exit /b 0
)

for /f "tokens=1-3 delims=/ " %%a in ("%date%") do set HOJE=%%a/%%b/%%c
git commit -m "atualiza painel - %HOJE% %time:~0,5%"
git push
if errorlevel 1 (
  echo.
  echo   [!] Nao consegui publicar. Confira sua conexao e o login do GitHub.
  echo       O index.html foi gerado normalmente e esta nesta pasta.
  pause
  exit /b 1
)

echo.
echo   ============================================
echo     PRONTO! Painel gerado e publicado.
echo   ============================================
echo   O site atualiza em cerca de 1 minuto.
echo.
echo   Esta janela fecha em 8 segundos...
timeout /t 8 >nul
