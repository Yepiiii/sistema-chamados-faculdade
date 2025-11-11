# 🚀 SCRIPTS DE EXECUÇÃO - GUIA RÁPIDO

**IP da Máquina:** 192.168.1.6  
**Data:** 2025-11-10

---

## 📋 SCRIPTS DISPONÍVEIS

### 1️⃣ `start-all.ps1` ⭐ RECOMENDADO
**Inicia Backend e Frontend automaticamente**

```powershell
.\start-all.ps1
```

**O que faz:**
- ✅ Inicia Backend na porta 5246
- ✅ Inicia Frontend na porta 8080
- ✅ Abre dois terminais separados
- ✅ Verifica se as portas estão livres

**Quando usar:** Sempre que for testar o sistema completo

---

### 2️⃣ `configure-firewall.ps1` ⚠️ EXECUTAR COMO ADMIN
**Configura o Firewall do Windows**

```powershell
# Botão direito > "Executar como Administrador"
.\configure-firewall.ps1
```

**O que faz:**
- ✅ Libera porta 5246 (Backend API)
- ✅ Libera porta 8080 (Frontend Web)
- ✅ Permite acesso do celular à API

**Quando usar:** Apenas UMA VEZ antes do primeiro teste com celular

---

### 3️⃣ `build-mobile-apk.ps1`
**Compila e gera APK do Mobile**

```powershell
.\build-mobile-apk.ps1
```

**O que faz:**
- ✅ Verifica IP da máquina
- ✅ Atualiza IP no Constants.cs (se necessário)
- ✅ Compila Mobile em modo Release
- ✅ Gera APK
- ✅ Copia APK para área de trabalho
- ✅ Opção de instalar via ADB

**Quando usar:** Quando quiser gerar um novo APK para o celular

---

### 4️⃣ `start-backend.ps1` (Opcional)
**Inicia apenas o Backend**

```powershell
.\start-backend.ps1
```

**Quando usar:** Se quiser rodar apenas a API

---

### 5️⃣ `start-frontend.ps1` (Opcional)
**Inicia apenas o Frontend**

```powershell
.\start-frontend.ps1
```

**Quando usar:** Se quiser rodar apenas o Desktop/Web

---

## 🎯 FLUXO RECOMENDADO - PRIMEIRA VEZ

### Passo 1: Configurar Firewall (UMA VEZ)
```powershell
# Botão direito > "Executar como Administrador"
.\configure-firewall.ps1
```

### Passo 2: Iniciar Backend e Frontend
```powershell
.\start-all.ps1
```

### Passo 3: Gerar APK do Mobile
```powershell
.\build-mobile-apk.ps1
```

### Passo 4: Instalar APK no Celular
- Conectar celular via USB
- Instalar via ADB (script pergunta automaticamente)
- OU transferir APK manualmente

### Passo 5: Testar!
- Abrir app no celular
- Fazer login
- Criar chamado
- Verificar no Desktop

---

## 🔧 SOLUÇÃO DE PROBLEMAS

### "Não é possível executar scripts neste sistema"
```powershell
# Executar UMA VEZ no PowerShell como Administrador:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Porta 5246 ou 8080 já em uso
```powershell
# Ver qual processo está usando a porta
netstat -ano | findstr :5246
netstat -ano | findstr :8080

# Matar processo (substituir 1234 pelo PID retornado)
taskkill /PID 1234 /F
```

### Mobile não conecta na API
1. Verificar se Firewall foi configurado (`configure-firewall.ps1`)
2. Testar no navegador do celular: http://192.168.1.6:5246/swagger
3. Verificar se celular está na mesma rede Wi-Fi do PC
4. Verificar se IP não mudou (executar `ipconfig` no PowerShell)

### http-server não encontrado
```powershell
# Instalar Node.js primeiro
# Depois instalar http-server:
npm install -g http-server
```

---

## 📱 TESTAR CONECTIVIDADE DO CELULAR

**No navegador do celular, acesse:**
```
http://192.168.1.6:5246/swagger
```

**Resultado esperado:**
- ✅ Deve carregar a página do Swagger
- ❌ Se não carregar, verificar Firewall e rede Wi-Fi

---

## 🌐 URLs DE TESTE

| Serviço | URL | Descrição |
|---------|-----|-----------|
| Backend (Swagger) | http://localhost:5246/swagger | Documentação da API |
| Backend (API) | http://localhost:5246/api/ | Endpoint base da API |
| Frontend (Web) | http://localhost:8080 | Interface Desktop/Web |
| Mobile (do celular) | http://192.168.1.6:5246/api/ | API para o celular |

---

## 💡 DICAS

1. **Mantenha os terminais abertos** durante os testes
2. **Não feche** o PowerShell do Backend ou Frontend
3. Use **Ctrl+C** para parar os servidores quando terminar
4. Se o IP mudar, execute `build-mobile-apk.ps1` novamente
5. Para parar tudo: **Ctrl+C** em cada terminal

---

## 📖 DOCUMENTAÇÃO COMPLETA

Para instruções detalhadas, consulte:
- **GUIA_EXECUCAO_TESTES.md** - Guia completo passo a passo

---

**Pronto para testes!** 🎉
