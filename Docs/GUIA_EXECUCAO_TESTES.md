# 🚀 GUIA DE EXECUÇÃO - AMBIENTE DE TESTES

**Data:** 2025-11-10  
**IP da Máquina:** 192.168.1.6  
**Backend API:** http://localhost:5246  
**Desktop/Web:** http://localhost:8080  
**Mobile APK:** http://192.168.1.6:5246

---

## 📋 PRÉ-REQUISITOS

- ✅ .NET SDK 8.0 instalado
- ✅ Node.js instalado (para servidor HTTP do Frontend)
- ✅ Visual Studio 2022 ou VS Code
- ✅ Dispositivo Android físico com USB Debugging habilitado
- ✅ Ambos (PC e celular) conectados na MESMA rede Wi-Fi

---

## 🔧 CONFIGURAÇÕES APLICADAS

### Backend (API)
- **Porta:** 5246
- **URL:** http://localhost:5246
- **Swagger:** http://localhost:5246/swagger
- **Arquivo:** `Backend/Properties/launchSettings.json`
- **Status:** ✅ Já configurado

### Desktop/Web (Frontend)
- **Porta:** 8080
- **URL:** http://localhost:8080
- **API Base:** "" (URLs relativas - mesmo servidor)
- **Arquivo:** `Frontend/wwwroot/script-desktop.js`
- **Status:** ✅ Configurado

### Mobile (APK)
- **API URL:** http://192.168.1.6:5246/api/
- **Arquivo:** `Mobile/Helpers/Constants.cs`
- **Status:** ✅ Configurado para IP físico 192.168.1.6

---

## 🚀 PASSO A PASSO - EXECUÇÃO

### 1️⃣ INICIAR BACKEND (API) - Porta 5246

**Opção A: Visual Studio**
```powershell
# 1. Abrir Backend/SistemaChamados.csproj no Visual Studio
# 2. Definir perfil de execução como "http" (não "https")
# 3. Pressionar F5 ou clicar em "Run"
# 4. Aguardar até abrir Swagger em http://localhost:5246/swagger
```

**Opção B: Terminal (PowerShell)**
```powershell
# Navegue até a pasta do Backend
cd C:\Users\T-GAMER\sistema-chamados-faculdade\Backend

# Execute a API
dotnet run --launch-profile http

# Aguardar mensagem:
# "Now listening on: http://localhost:5246"
```

**Validação:**
- ✅ Abra o navegador: http://localhost:5246/swagger
- ✅ Deve exibir a documentação da API
- ⚠️ Deixe este terminal ABERTO (não feche)

---

### 2️⃣ INICIAR DESKTOP/WEB - Porta 8080

**Opção A: Usar http-server (Node.js - RECOMENDADO)**

```powershell
# Instalar http-server globalmente (apenas uma vez)
npm install -g http-server

# Navegue até a pasta do Frontend
cd C:\Users\T-GAMER\sistema-chamados-faculdade\Frontend\wwwroot

# Iniciar servidor na porta 8080
http-server -p 8080 --cors

# Aguardar mensagem:
# "Available on: http://127.0.0.1:8080"
```

**Opção B: Usar Live Server (VS Code)**
```powershell
# 1. Abrir Frontend/wwwroot no VS Code
# 2. Instalar extensão "Live Server"
# 3. Clicar com botão direito em index.html
# 4. Selecionar "Open with Live Server"
# 5. Configurar porta 8080 nas settings do Live Server
```

**Opção C: Python (se Node.js não disponível)**
```powershell
# Navegue até a pasta do Frontend
cd C:\Users\T-GAMER\sistema-chamados-faculdade\Frontend\wwwroot

# Python 3
python -m http.server 8080

# OU Python 2
python -m SimpleHTTPServer 8080
```

**Validação:**
- ✅ Abra o navegador: http://localhost:8080
- ✅ Deve exibir a página de login do Desktop
- ⚠️ Deixe este terminal ABERTO (não feche)

---

### 3️⃣ CONFIGURAR FIREWALL DO WINDOWS

Para que o celular acesse a API no IP 192.168.1.6, você precisa liberar a porta 5246 no Firewall:

**Opção A: PowerShell como Administrador**
```powershell
# Abrir PowerShell como ADMINISTRADOR

# Liberar porta 5246 (entrada)
New-NetFirewallRule -DisplayName "API Sistema Chamados" -Direction Inbound -LocalPort 5246 -Protocol TCP -Action Allow

# Liberar porta 8080 (entrada) - opcional, para acessar Desktop do celular
New-NetFirewallRule -DisplayName "Web Sistema Chamados" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

**Opção B: Interface Gráfica (Firewall)**
```
1. Abrir "Firewall do Windows" (Windows Defender Firewall)
2. Clicar em "Configurações Avançadas"
3. Selecionar "Regras de Entrada"
4. Clicar em "Nova Regra..."
5. Tipo: Porta
6. Protocolo: TCP
7. Porta: 5246
8. Ação: Permitir a conexão
9. Nome: "API Sistema Chamados"
10. Finalizar
```

---

### 4️⃣ VERIFICAR CONECTIVIDADE DO CELULAR

**No Celular:**
1. Conectar na MESMA rede Wi-Fi do PC
2. Abrir navegador Chrome/Firefox
3. Acessar: `http://192.168.1.6:5246/swagger`

**Resultado Esperado:**
- ✅ Deve carregar a página do Swagger da API
- ❌ Se não carregar:
  - Verificar se celular está na mesma rede Wi-Fi
  - Verificar se Firewall liberou a porta 5246
  - Verificar se API está rodando no PC

---

### 5️⃣ GERAR APK DO MOBILE

**Opção A: Visual Studio 2022 (RECOMENDADO)**

```powershell
# 1. Abrir Mobile/SistemaChamados.Mobile.csproj no Visual Studio
# 2. Selecionar "Release" no topo (não Debug)
# 3. Clicar com botão direito no projeto Mobile
# 4. Selecionar "Publish" ou "Archive"
# 5. Seguir wizard para criar APK
# 6. APK será gerado em: Mobile/bin/Release/net8.0-android/publish/
```

**Opção B: Terminal (CLI - Mais rápido)**

```powershell
# Navegue até a pasta Mobile
cd C:\Users\T-GAMER\sistema-chamados-faculdade\Mobile

# Publicar APK em modo Release
dotnet publish -f net8.0-android -c Release

# Aguardar compilação...
# APK será gerado em: bin/Release/net8.0-android/publish/

# Copiar APK para área de trabalho
Copy-Item "bin\Release\net8.0-android\publish\*.apk" "$env:USERPROFILE\Desktop\" -Force
```

**Localizar APK:**
```powershell
# O APK estará em:
C:\Users\T-GAMER\Desktop\br.com.sistemachamados.mobile-Signed.apk
# OU
C:\Users\T-GAMER\sistema-chamados-faculdade\Mobile\bin\Release\net8.0-android\publish\br.com.sistemachamados.mobile-Signed.apk
```

---

### 6️⃣ INSTALAR APK NO CELULAR

**Opção A: USB (RECOMENDADO)**

```powershell
# 1. Conectar celular via USB
# 2. Habilitar "Depuração USB" no celular:
#    Configurações > Sistema > Opções de Desenvolvedor > Depuração USB

# 3. Instalar via ADB (Android Debug Bridge)
adb install -r "C:\Users\T-GAMER\Desktop\br.com.sistemachamados.mobile-Signed.apk"

# OU usar Visual Studio:
# 1. Selecionar dispositivo físico no dropdown
# 2. Clicar em "Run" (F5)
# 3. App será instalado e executado automaticamente
```

**Opção B: Transferir APK para o celular**

```
1. Copiar APK para celular (via USB, Bluetooth, Drive, etc.)
2. Abrir "Arquivos" ou "Gerenciador de Arquivos" no celular
3. Localizar o APK
4. Clicar para instalar
5. Permitir "Instalar de fontes desconhecidas" se solicitado
```

---

### 7️⃣ TESTAR O APP MOBILE

**No Celular:**

1. **Abrir o app "Sistema de Chamados"**
2. **Fazer login:**
   - Usar credenciais existentes no banco
   - OU criar nova conta

3. **Validações:**
   - ✅ App conecta na API (http://192.168.1.6:5246/api/)
   - ✅ Login funciona
   - ✅ Dashboard carrega
   - ✅ Lista de chamados carrega
   - ✅ Criar novo chamado funciona
   - ✅ Comentários funcionam

**Troubleshooting:**
- ❌ "Erro de conexão" → Verificar se API está rodando e Firewall liberado
- ❌ "Timeout" → Verificar se celular está na mesma rede Wi-Fi
- ❌ "401 Unauthorized" → Token expirado, fazer login novamente

---

## 🧪 TESTES INTEGRADOS - CHECKLIST

### ✅ Teste 1: Criar Chamado no Mobile
1. Mobile: Criar novo chamado
2. Desktop: Verificar se aparece na lista
3. **Validação:** Mesmo chamado visível em ambos

### ✅ Teste 2: Assumir Chamado no Desktop
1. Desktop: Técnico assume chamado não atribuído
2. Mobile: Recarregar lista de chamados
3. **Validação:** Técnico aparece atribuído no Mobile

### ✅ Teste 3: Adicionar Comentário no Mobile
1. Mobile: Abrir detalhes do chamado
2. Mobile: Adicionar comentário
3. Desktop: Abrir mesmo chamado
4. **Validação:** Comentário aparece no Desktop

### ✅ Teste 4: Fechar Chamado no Desktop
1. Desktop: Fechar chamado (Status = Fechado)
2. Mobile: Recarregar dashboard
3. **Validação:** Total de Encerrados aumentou

### ✅ Teste 5: SLA Expirado
1. Backend: Criar chamado com prioridade "Urgente" (2 horas)
2. Aguardar 2+ horas OU manipular data no banco
3. Mobile/Desktop: Recarregar lista
4. **Validação:** Status muda para "Violado" automaticamente

---

## 📊 MONITORAMENTO - LOGS

### Backend (API)
```powershell
# Logs aparecem no terminal onde você executou "dotnet run"
# Exemplo:
# info: SistemaChamados.API.Controllers.ChamadosController[0]
#       GetChamados - Recebido pedido com filtros: statusId=, tecnicoId=...
```

### Desktop/Web
```javascript
// Abrir Console do Navegador (F12)
// Logs aparecem em "Console"
// Exemplo:
// --- DEBUG: Iniciando fetch para MEUS CHAMADOS: ...
```

### Mobile
```csharp
// Usar Debug do Visual Studio
// OU conectar via USB e usar "adb logcat" no terminal
adb logcat | Select-String "SistemaChamados"
```

---

## 🔧 COMANDOS ÚTEIS

### Parar Todos os Serviços
```powershell
# Parar Backend: Ctrl+C no terminal do dotnet run
# Parar Frontend: Ctrl+C no terminal do http-server
```

### Reiniciar Tudo
```powershell
# Terminal 1 - Backend
cd C:\Users\T-GAMER\sistema-chamados-faculdade\Backend
dotnet run --launch-profile http

# Terminal 2 - Frontend (novo terminal)
cd C:\Users\T-GAMER\sistema-chamados-faculdade\Frontend\wwwroot
http-server -p 8080 --cors
```

### Verificar Portas em Uso
```powershell
# Ver se porta 5246 está ocupada
netstat -ano | findstr :5246

# Ver se porta 8080 está ocupada
netstat -ano | findstr :8080
```

### Limpar Build do Mobile
```powershell
cd C:\Users\T-GAMER\sistema-chamados-faculdade\Mobile
dotnet clean
dotnet build -c Release
```

---

## 🎯 RESUMO - CONFIGURAÇÕES FINAIS

| Componente | Porta | URL | Status |
|------------|-------|-----|--------|
| **Backend (API)** | 5246 | http://localhost:5246 | ✅ Configurado |
| **Desktop/Web** | 8080 | http://localhost:8080 | ✅ Configurado |
| **Mobile (Emulador)** | - | http://10.0.2.2:5246/api/ | ✅ Configurado |
| **Mobile (Físico)** | - | http://192.168.1.6:5246/api/ | ✅ Configurado |
| **Firewall** | 5246, 8080 | Liberado | ⚠️ Configurar |

---

## ⚠️ TROUBLESHOOTING COMUM

### Problema 1: "CORS policy error" no Desktop
**Solução:**
- Executar http-server com flag `--cors`
- OU desabilitar CORS temporariamente no navegador

### Problema 2: Mobile não conecta na API
**Solução:**
1. Verificar se celular está na mesma rede Wi-Fi
2. Testar no navegador do celular: http://192.168.1.6:5246/swagger
3. Liberar porta 5246 no Firewall (ver seção 3)
4. Verificar se IP não mudou (executar `ipconfig` novamente)

### Problema 3: "Address already in use" (porta ocupada)
**Solução:**
```powershell
# Encontrar processo usando a porta
netstat -ano | findstr :5246

# Matar processo (substituir PID pelo número retornado)
taskkill /PID <número> /F
```

### Problema 4: APK não instala no celular
**Solução:**
- Habilitar "Instalar de fontes desconhecidas" nas configurações
- Verificar se há espaço no celular
- Desinstalar versão anterior do app
- Usar `adb install -r` para forçar reinstalação

---

## 📱 INFORMAÇÕES DO APK

**Versão:** 1.0.0  
**Nome do Pacote:** br.com.sistemachamados.mobile  
**API Mínima:** Android 7.0 (API 24)  
**API Alvo:** Android 14 (API 34)  
**Permissões:**
- Internet
- Network State
- Access WiFi State

---

## ✅ CHECKLIST FINAL - ANTES DE TESTAR

- [ ] Backend rodando em http://localhost:5246
- [ ] Swagger acessível em http://localhost:5246/swagger
- [ ] Frontend rodando em http://localhost:8080
- [ ] Firewall liberou porta 5246
- [ ] Celular conectado na mesma rede Wi-Fi do PC
- [ ] Testou acesso do celular em http://192.168.1.6:5246/swagger
- [ ] APK gerado com configuração Release
- [ ] APK instalado no celular
- [ ] App abre sem erros

---

**Última Atualização:** 2025-11-10  
**IP da Máquina:** 192.168.1.6  
**Pronto para testes!** 🚀
