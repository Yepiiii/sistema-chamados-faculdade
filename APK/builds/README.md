# 📱 APK DO MOBILE - SISTEMA DE CHAMADOS

## 📦 Arquivo Gerado

- **APK:** `com.sistemachamados.mobile-Signed.apk`
- **Tamanho:** ~50 MB
- **Plataforma:** Android 5.0+ (API 21+)

---

## 🚀 COMO INSTALAR

### Opção 1: Transferência Manual

1. **Copie o APK para seu celular:**
   - Via cabo USB
   - Via Bluetooth
   - Via Google Drive/OneDrive
   - Via WhatsApp (envie para você mesmo)

2. **No celular:**
   - Abra o arquivo APK
   - Android vai pedir permissão para "Instalar apps desconhecidos"
   - Permita a instalação
   - Toque em "Instalar"

### Opção 2: Via ADB (Desenvolvedores)

```bash
# Com celular conectado via USB
adb install -r com.sistemachamados.mobile-Signed.apk
```

---

## ⚙️ CONFIGURAÇÃO DA API

O app está configurado para se conectar em:

```
http://192.168.1.6:5246/api/
```

### ⚠️ IMPORTANTE:

1. **Certifique-se que o Backend está rodando**
2. **Celular e PC devem estar na MESMA REDE Wi-Fi**
3. **Firewall do Windows deve permitir porta 5246**

### Para verificar conexão:

1. No celular, abra o navegador
2. Acesse: `http://192.168.1.6:5246/swagger`
3. Se abrir a página do Swagger, está OK!

---

## 🔧 SE NÃO CONECTAR

### 1. Verificar IP do PC:

```powershell
ipconfig | Select-String "IPv4"
```

### 2. Se o IP mudou:

- Edite `Mobile/Helpers/Constants.cs`
- Atualize a linha: `BaseUrlPhysicalDevice = "http://SEU_IP:5246/api/"`
- Execute novamente: `.\Scripts\build-mobile-apk.ps1`

### 3. Configurar Firewall:

```powershell
# Execute como Administrador:
.\Scripts\configure-firewall.ps1
```

---

## 📝 CREDENCIAIS DE TESTE

### Técnico:
- Email: `tecnico@teste.com`
- Senha: `Senha@123`

### Usuário:
- Email: `usuario@teste.com`
- Senha: `Senha@123`

---

## 🐛 PROBLEMAS COMUNS

### "Erro de conexão" no app:
- ✅ Backend está rodando?
- ✅ Celular na mesma rede Wi-Fi?
- ✅ Firewall configurado?

### "Instalação bloqueada":
- Habilite "Fontes desconhecidas" nas configurações
- Ou "Permitir instalação de apps desconhecidos" (Android 8+)

---

**Gerado em:** 10/11/2025  
**Versão:** 1.0  
**Framework:** .NET MAUI 8.0
