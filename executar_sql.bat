@echo off
echo ========================================
echo POPULANDO BANCO COM DADOS BASICOS
echo ========================================
echo.

REM Verificar se o arquivo do banco existe
if not exist "SistemaChamados.db" (
    echo ERRO: Arquivo SistemaChamados.db nao encontrado!
    echo Execute primeiro: dotnet ef database update
    pause
    exit /b 1
)

echo Executando script SQL...
echo.

REM Executar o script SQL usando sqlite3
sqlite3 SistemaChamados.db < popular_dados_basicos.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo SUCESSO! Dados basicos inseridos.
    echo ========================================
    echo.
    echo Agora voce pode:
    echo 1. Fazer login no sistema
    echo 2. Criar chamados usando as categorias e prioridades
    echo 3. Testar os endpoints GET implementados
    echo.
) else (
    echo.
    echo ERRO ao executar o script SQL!
    echo Verifique se o SQLite esta instalado.
)

pause