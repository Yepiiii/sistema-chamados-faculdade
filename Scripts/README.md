# 🚀 SCRIPTS DE EXECUÇÃO

**IMPORTANTE:** Execute os scripts a partir DESTA pasta (Scripts)

---

## 📁 LOCALIZAÇÃO

Você está em: `C:\Users\T-GAMER\sistema-chamados-faculdade\Scripts\`

---

## ▶️ COMO EXECUTAR

### Opção 1: PowerShell (RECOMENDADO)

```powershell
# Navegue até esta pasta
cd C:\Users\T-GAMER\sistema-chamados-faculdade\Scripts

# Execute o script desejado
.\start-all.ps1
```

### Opção 2: Windows Explorer

1. Abra esta pasta no Explorer
2. Clique com botão direito no script desejado
3. Selecione "Executar com PowerShell"

---

## 📋 SCRIPTS DISPONÍVEIS

### 1️⃣ `start-all.ps1` ⭐
Inicia Backend e Frontend automaticamente
```powershell
.\start-all.ps1
```

### 2️⃣ `configure-firewall.ps1` ⚠️
Configura Firewall (EXECUTAR COMO ADMIN)
```powershell
# Botão direito > "Executar como Administrador"
.\configure-firewall.ps1
```

### 3️⃣ `build-mobile-apk.ps1`
Compila e gera APK do Mobile
```powershell
.\build-mobile-apk.ps1
```

### 4️⃣ `start-backend.ps1`
Inicia apenas Backend (porta 5246)
```powershell
.\start-backend.ps1
```

### 5️⃣ `start-frontend.ps1`
Inicia apenas Frontend (porta 8080)
```powershell
.\start-frontend.ps1
```

---

## ⚠️ SOLUÇÃO DE PROBLEMAS

### "Scripts desabilitados neste sistema"
```powershell
# Execute UMA VEZ como Administrador:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Pasta Backend não encontrada"
✅ CORRIGIDO! Os scripts agora encontram as pastas corretamente.

---

## 🎯 FLUXO RÁPIDO

1. **Configure Firewall (UMA VEZ):**
   ```powershell
   # Botão direito > "Executar como Administrador"
   .\configure-firewall.ps1
   ```

2. **Inicie Backend + Frontend:**
   ```powershell
   .\start-all.ps1
   ```

3. **Gere APK do Mobile:**
   ```powershell
   .\build-mobile-apk.ps1
   ```

---

**Pronto para testes!** 🚀
