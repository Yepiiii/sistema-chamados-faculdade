# 📱 GUIA DE INSTALAÇÃO - APK Sistema de Chamados

**Data:** 23/10/2025  
**Versão:** 1.0  
**APK:** com.sistemachamados.mobile-Signed.apk (64.02 MB)

---

## ✅ PROBLEMA RESOLVIDO

**Erro:** Connection Failure no APK  
**Causa:** APK tentava conectar a `localhost` ou `10.0.2.2` (emulador)  
**Solução:** Configurado IP da rede local (`192.168.1.132`)

---

## 🔧 CONFIGURAÇÕES APLICADAS

### 1. IP Detectado e Configurado
```
IP do PC (Wi-Fi): 192.168.1.132
URL da API: http://192.168.1.132:5246/api/
```

### 2. Arquivos Atualizados
- ✅ `Mobile/Helpers/Constants.cs` - BaseUrlPhysicalDevice configurado
- ✅ `Mobile/appsettings.json` - BaseUrl configurado
- ✅ Novo APK gerado com IP correto

---

## 📋 CHECKLIST DE INSTALAÇÃO

### ⚠️ ANTES DE INSTALAR O APK

#### 1️⃣ Configurar Firewall do Windows (IMPORTANTE!)

**Opção A - Manual:**
1. Abra PowerShell **como Administrador**
2. Execute:
```powershell
netsh advfirewall firewall add rule name="Sistema Chamados API" dir=in action=allow protocol=TCP localport=5246
```

**Opção B - Script Automático:**
1. Clique com botão direito no PowerShell
2. Escolha "Executar como Administrador"
3. Execute:
```powershell
.\ConfigurarFirewall.ps1
```

#### 2️⃣ Garantir que a API está rodando

Verifique se a API está rodando em uma janela separada:
```powershell
cd Backend
dotnet run --project SistemaChamados.csproj --urls "http://localhost:5246"
```

Deve aparecer:
```
✅ Now listening on: http://localhost:5246
```

#### 3️⃣ Conectar PC e Celular na MESMA rede WiFi

- PC: Wi-Fi conectado à rede (IP: 192.168.1.132)
- Celular: WiFi conectado à MESMA rede

---

## 📲 INSTALAÇÃO DO APK

### Método 1 - Via ADB (Cabo USB)

1. Conecte o celular via USB
2. Ative "Depuração USB" no celular:
   - Configurações → Sobre o telefone
   - Toque 7x em "Número da versão"
   - Configurações → Opções do desenvolvedor
   - Ative "Depuração USB"

3. Execute:
```powershell
adb install "C:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade\Mobile\bin\Release\net8.0-android\com.sistemachamados.mobile-Signed.apk"
```

### Método 2 - Manual (Sem cabo)

1. **Enviar APK para o celular:**
   - WhatsApp: Envie para si mesmo
   - Email: Anexe e abra no celular
   - Google Drive / OneDrive
   - Bluetooth

2. **No celular:**
   - Abra o APK
   - Permita "Fontes desconhecidas" se solicitado
   - Toque em "Instalar"

---

## 🧪 TESTE DE CONECTIVIDADE

### Teste 1 - API acessível do PC

No navegador do PC, acesse:
```
http://localhost:5246/api/categorias
```
✅ Deve retornar JSON com categorias

### Teste 2 - API acessível do celular (CRÍTICO!)

**No navegador do celular**, acesse:
```
http://192.168.1.132:5246/api/categorias
```

**Resultado esperado:**
```json
[
  {"id":1,"nome":"Hardware","descricao":"..."},
  {"id":2,"nome":"Software","descricao":"..."}
]
```

**Se der erro:**
- ❌ Firewall bloqueando → Execute `ConfigurarFirewall.ps1` como Admin
- ❌ PC e celular em redes diferentes → Conecte ambos na mesma rede WiFi
- ❌ IP mudou → Execute `ConfigurarIPDispositivo.ps1` e gere novo APK

---

## 🚀 USANDO O APLICATIVO

### Login
```
Email: admin@teste.com
Senha: Admin123!
```

### Funcionalidades Testadas
- ✅ Auto-refresh (a cada 10 segundos)
- ✅ Pull-to-refresh (arrastar para baixo)
- ✅ Geração de título por IA (Gemini)
- ✅ Encerrar chamado (banner verde + status "Fechado")
- ✅ Criação de novos chamados

---

## 🔄 REGENERAR APK COM NOVO IP

Se o IP do seu PC mudar (reconexão WiFi, etc.):

1. Execute:
```powershell
.\ConfigurarIPDispositivo.ps1
```

2. Verifique o IP detectado

3. Gere novo APK:
```powershell
.\GerarAPK.ps1
```

4. Reinstale no celular

---

## 📁 LOCALIZAÇÃO DOS ARQUIVOS

### APK Gerado
```
Mobile\bin\Release\net8.0-android\com.sistemachamados.mobile-Signed.apk
```

### Scripts
```
ConfigurarIPDispositivo.ps1    # Detecta IP e configura
ConfigurarFirewall.ps1         # Configura Firewall (Admin)
GerarAPK.ps1                   # Gera APK
```

---

## ❗ PROBLEMAS COMUNS

### "Connection Failure" no app

**Causas possíveis:**
1. ❌ Firewall bloqueando porta 5246
   - **Solução:** Execute `ConfigurarFirewall.ps1` como Admin

2. ❌ API não está rodando
   - **Solução:** Inicie a API em terminal separado

3. ❌ PC e celular em redes WiFi diferentes
   - **Solução:** Conecte ambos na mesma rede

4. ❌ IP do PC mudou
   - **Solução:** Execute `ConfigurarIPDispositivo.ps1` e gere novo APK

5. ❌ APK antigo instalado
   - **Solução:** Desinstale e instale o novo APK

### "Timeout" ou demora para conectar

- Verifique se o PC não está em modo de economia de energia
- Desative VPN no PC (se estiver usando)
- Reinicie o roteador WiFi

### API funciona no PC mas não no celular

- Teste no navegador do celular primeiro (Teste 2)
- Se funcionar no navegador mas não no app → Desinstale e reinstale o APK
- Se não funcionar no navegador → Problema de rede/firewall

---

## 📊 INFORMAÇÕES TÉCNICAS

### Configuração de Rede
```
Tipo: WiFi
IP do PC: 192.168.1.132
Porta: 5246
Protocolo: HTTP
URL Base: http://192.168.1.132:5246/api/
```

### APK
```
Nome: Sistema de Chamados
Package ID: com.sistemachamados.mobile
Versão: 1.0
Tamanho: 64.02 MB
SDK Mínimo: Android 5.0 (API 21)
Target Framework: net8.0-android
Build: Release
Assinado: Sim
```

### API Backend
```
Framework: ASP.NET Core 8
Porta: 5246
Database: SQL Server LocalDB
```

---

## ✅ VERIFICAÇÃO FINAL

Antes de usar o app, certifique-se:

- [ ] Firewall configurado (porta 5246 aberta)
- [ ] API rodando em terminal separado
- [ ] PC e celular na mesma rede WiFi
- [ ] Teste de conectividade OK (navegador do celular)
- [ ] APK mais recente instalado (09:02 - 23/10/2025)

---

**✨ Pronto para usar!**

Se tudo estiver correto, o app deve conectar automaticamente e você poderá fazer login com `admin@teste.com` / `Admin123!`

