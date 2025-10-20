# 🔥 SOLUÇÃO: Timeout ao conectar do celular

## ❌ Problema
- App no celular mostra erro: `net_http_request_timeout, 30`
- API está rodando no PC mas celular não consegue acessar

## ✅ Solução Rápida (3 passos)

### 1️⃣ Abrir PowerShell como ADMINISTRADOR
- Clique com botão direito no PowerShell
- Selecione "Executar como Administrador"

### 2️⃣ Executar comando para liberar firewall:
```powershell
New-NetFirewallRule -DisplayName "Sistema Chamados API" -Direction Inbound -LocalPort 5246 -Protocol TCP -Action Allow
```

### 3️⃣ Testar do celular:
- Abra o navegador do celular
- Acesse: `http://192.168.0.18:5246/swagger`
- Se aparecer a página do Swagger = ✅ FUNCIONOU!

## 📱 Depois de funcionar no navegador:

1. **Instale o APK atualizado** (já foi gerado com IP correto)
2. **Abra o app** e faça login
3. **Deve funcionar** sem mais timeout!

## 🆘 Se ainda não funcionar:

### Verificar se estão na mesma rede:
**No PC:**
```powershell
ipconfig | Select-String "IPv4"
```

**No celular:**
- Configurações → Wi-Fi → Toque na rede conectada
- Veja o IP (deve começar com 192.168.0.xxx)

### Se o celular tiver IP diferente:
- Exemplo: Celular em 192.168.1.10 e PC em 192.168.0.18
- **Problema:** Redes diferentes! 
- **Solução:** Conecte ambos na MESMA rede Wi-Fi

## 🔧 Comandos úteis:

### Verificar se API está rodando:
```powershell
Get-NetTCPConnection -LocalPort 5246 -State Listen
```

### Ver IP atual do PC:
```powershell
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -like "192.168.*"} | Select-Object IPAddress, InterfaceAlias
```

### Testar API localmente:
```powershell
Invoke-WebRequest -Uri "http://localhost:5246/swagger/index.html"
```

## 📊 Diagnóstico Completo

Se precisar de diagnóstico detalhado:
```powershell
cd c:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade
.\TestarConectividadeMobile.ps1
```

---

## ⚡ Resumo do que foi feito:

✅ **Constants.cs** → Configurado para `BaseUrlPhysicalDevice` (192.168.0.18)  
✅ **ApiService.cs** → Timeout aumentado para 60 segundos  
✅ **Novo APK gerado** → Com configurações corretas  
⚠️ **Firewall** → PRECISA SER LIBERADO MANUALMENTE (como Administrador)

**MAIS IMPORTANTE:** Execute o comando do firewall como Administrador!
