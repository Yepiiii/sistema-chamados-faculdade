# 📱 TESTE DE CONECTIVIDADE - PASSO A PASSO

## ✅ Status Atual (PC)
- ✅ Firewall liberado (porta 5246)
- ✅ API iniciando...
- ✅ IPs disponíveis:
  - **192.168.0.18** (Wi-Fi) ← USE ESTE
  - 192.168.56.1 (Ethernet/VirtualBox)

---

## 🧪 TESTE 1: Do navegador do CELULAR

**IMPORTANTE:** Celular deve estar na mesma rede Wi-Fi!

1. Abra o **Chrome** ou **navegador** do celular
2. Digite na barra de endereço:
   ```
   http://192.168.0.18:5246/swagger
   ```
3. Pressione Enter

### ✅ Se funcionar:
- Você verá a página do Swagger API
- **Significa que a rede está OK!**
- O problema pode estar no APK

### ❌ Se NÃO funcionar:
- Dá timeout ou "não consegue acessar o site"
- **Problema de rede!** Veja soluções abaixo

---

## 🧪 TESTE 2: Verificar IP do celular

No celular:
1. Configurações → Wi-Fi
2. Toque na rede conectada
3. Veja o **Endereço IP**

**Deve ser algo como:** `192.168.0.XXX`

### ❌ Se for diferente (ex: 192.168.1.XXX):
- Celular e PC estão em redes diferentes!
- Conecte ambos na MESMA rede Wi-Fi

---

## 🧪 TESTE 3: Do PC (para garantir que API está OK)

No PowerShell do PC, execute:
```powershell
Invoke-WebRequest -Uri "http://192.168.0.18:5246/swagger/index.html" -TimeoutSec 5
```

### ✅ Se funcionar (Status 200):
- API está acessível pela rede
- Problema está no celular/rede

### ❌ Se NÃO funcionar:
- API não está respondendo
- Verifique se está rodando

---

## 🔧 SOLUÇÕES para problemas comuns

### Problema: Celular em rede diferente
**Solução:** Conecte na mesma rede Wi-Fi do PC

### Problema: Roteador bloqueia comunicação entre dispositivos
**Solução:** Veja configurações do roteador:
- Desabilite "Isolamento de AP" ou "Client Isolation"
- Pode estar em: Segurança → Configurações avançadas

### Problema: IP do PC mudou
**Solução:** 
1. Veja o IP atual:
   ```powershell
   ipconfig | Select-String "IPv4"
   ```
2. Atualize Constants.cs com o IP correto
3. Gere novo APK

### Problema: Windows Defender bloqueando
**Solução:** Adicione exceção para dotnet.exe

---

## 📝 Checklist antes de testar o app:

- [ ] API está rodando? (`Get-NetTCPConnection -LocalPort 5246`)
- [ ] Firewall liberado? (✅ JÁ ESTÁ!)
- [ ] Celular na mesma rede Wi-Fi?
- [ ] IP do celular começa com 192.168.0.XXX?
- [ ] Teste no navegador do celular funcionou?
- [ ] APK instalado é o mais recente? (data: 20/10/2025 09:59)

---

## 🚀 Depois que o teste no navegador funcionar:

1. **Desinstale** o app antigo do celular
2. **Instale** o APK novo (SistemaChamados-v1.0.apk)
3. **Abra o app** e faça login
4. **Deve funcionar!**

---

## 🆘 Ainda não funcionou?

Execute este comando no PC para diagnóstico completo:
```powershell
Test-NetConnection -ComputerName 192.168.0.18 -Port 5246
```

E me diga:
1. Qual o IP do celular? (Configurações → Wi-Fi)
2. O teste no navegador do celular funcionou?
3. Qual erro aparece (exatamente)?
