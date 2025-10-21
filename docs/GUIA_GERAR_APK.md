# 📱 Guia Completo: Gerar APK Android

**Data:** 20 de outubro de 2025  
**Versão:** 1.0  
**Plataforma:** Android (API 21+)

---

## 🎯 Pré-requisitos

### Software Necessário
- ✅ .NET 8 SDK instalado
- ✅ Workload MAUI Android instalado
- ✅ Visual Studio 2022 OU VS Code com extensões

### Verificar Instalação
```powershell
# Verificar .NET
dotnet --version

# Verificar workloads MAUI
dotnet workload list

# Se não tiver, instalar:
dotnet workload install maui-android
```

---

## 🔧 Configuração Antes de Gerar APK

### 1. **Configurar IP da API**

**Importante:** O APK precisa acessar a API via rede local!

**Arquivo:** `SistemaChamados.Mobile/Helpers/Constants.cs`

```csharp
public static class Constants
{
    // Para dispositivo Android físico, use o IP da sua máquina na rede local
    public const string BaseUrl = "http://192.168.0.18:5246/api/";
    
    // Alternativa: use ngrok ou similar para expor a API
    // public const string BaseUrl = "https://seu-ngrok-url.ngrok.io/api/";
}
```

**Como descobrir seu IP:**
```powershell
# No PowerShell
ipconfig

# Procure por "Adaptador de Rede sem Fio Wi-Fi"
# Use o IPv4 Address (ex: 192.168.0.18)
```

**⚠️ ATENÇÃO:**
- `localhost` NÃO funciona em dispositivo Android físico
- `10.0.2.2` funciona APENAS no emulador Android
- Use o IP real da sua máquina na rede (ex: `192.168.0.18`)

---

### 2. **Configurar AndroidManifest.xml**

**Arquivo:** `Platforms/Android/AndroidManifest.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android" 
          package="com.sistemachamados.mobile" 
          android:versionCode="1" 
          android:versionName="1.0">
  <application 
    android:allowBackup="true" 
    android:supportsRtl="true" 
    android:label="Sistema de Chamados" 
    android:icon="@mipmap/appicon"
    android:usesCleartextTraffic="true">
  </application>
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-sdk android:minSdkVersion="21" android:targetSdkVersion="33" />
</manifest>
```

**Nota:** `usesCleartextTraffic="true"` permite HTTP (necessário para desenvolvimento).

---

### 3. **Atualizar .csproj (Já Configurado)**

**Arquivo:** `SistemaChamados.Mobile.csproj`

Configurações Android já adicionadas:
```xml
<PropertyGroup Condition="'$(TargetFramework)' == 'net8.0-android'">
  <AndroidPackageFormat>apk</AndroidPackageFormat>
  <AndroidUseAapt2>true</AndroidUseAapt2>
</PropertyGroup>
```

---

## 🚀 Gerar APK

### Método 1: Script PowerShell (Recomendado)

```powershell
# No diretório do projeto backend
cd c:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade

# Executar script
.\GerarAPK.ps1
```

**O script faz:**
1. ✅ Limpa build anterior
2. ✅ Restaura pacotes
3. ✅ Compila APK Release
4. ✅ Copia para pasta `APK/`
5. ✅ Abre pasta automaticamente

---

### Método 2: Linha de Comando Manual

```powershell
# Navegar para pasta mobile
cd c:\Users\opera\sistema-chamados-faculdade\SistemaChamados.Mobile

# Limpar
dotnet clean -c Release -f net8.0-android

# Restaurar
dotnet restore

# Build APK
dotnet build -c Release -f net8.0-android

# APK estará em:
# bin\Release\net8.0-android\com.sistemachamados.mobile-Signed.apk
```

---

### Método 3: Visual Studio

1. Abrir solução no Visual Studio 2022
2. Clicar com direito no projeto Mobile
3. Selecionar **Publicar**
4. Escolher **Android** → **Ad Hoc**
5. Configurar assinatura (ou usar sem assinatura para testes)
6. Clicar em **Publicar**

---

## 📦 Localização do APK

Após gerar com sucesso:

```
c:\Users\opera\sistema-chamados-faculdade\APK\SistemaChamados-v1.0.apk
```

**Tamanho esperado:** ~30-50 MB (não otimizado)

---

## 📲 Instalar no Dispositivo Android

### Passo 1: Preparar Dispositivo

1. **Ativar Modo Desenvolvedor**
   - Configurações → Sobre o telefone
   - Toque 7 vezes em "Número da versão"

2. **Permitir Fontes Desconhecidas**
   - Configurações → Segurança
   - Ativar "Fontes desconhecidas" ou "Instalar apps desconhecidos"

### Passo 2: Transferir APK

**Opção A: USB**
```powershell
# Conectar celular via USB
# Copiar APK para pasta Download do celular
```

**Opção B: Email**
- Enviar APK por email para você mesmo
- Abrir email no celular
- Baixar anexo

**Opção C: Google Drive / Dropbox**
- Upload do APK
- Baixar no celular

### Passo 3: Instalar

1. Abrir arquivo `SistemaChamados-v1.0.apk` no celular
2. Tocar em **Instalar**
3. Aceitar permissões:
   - ✅ Internet
   - ✅ Estado da rede
4. Aguardar instalação
5. Tocar em **Abrir**

---

## 🌐 Configurar API para Acesso Externo

### Opção 1: IP Local (Mesma Rede Wi-Fi)

**Backend:** Modificar `program.cs`

```csharp
var app = builder.Build();

// Adicionar antes de app.Run()
app.Urls.Add("http://0.0.0.0:5246"); // Escuta em todas as interfaces
```

**Firewall:**
```powershell
# Permitir porta 5246 no firewall
New-NetFirewallRule -DisplayName "Sistema Chamados API" -Direction Inbound -LocalPort 5246 -Protocol TCP -Action Allow
```

**Testar:**
- Celular e PC na mesma rede Wi-Fi
- App usa `http://192.168.0.18:5246/api/`

---

### Opção 2: ngrok (Acesso via Internet)

```powershell
# Baixar ngrok de https://ngrok.com
# Executar:
ngrok http 5246

# Usar URL fornecida (ex: https://abc123.ngrok.io)
```

**Mobile:** Alterar `Constants.BaseUrl`
```csharp
public const string BaseUrl = "https://abc123.ngrok.io/api/";
```

**⚠️ Atenção:** ngrok gratuito tem URL temporária que muda a cada execução.

---

## 🧪 Testar APK

### 1. Primeiro Teste: Emulador

```powershell
# Iniciar emulador Android (se tiver)
emulator -avd Pixel_5_API_33

# Instalar APK
adb install c:\Users\opera\sistema-chamados-faculdade\APK\SistemaChamados-v1.0.apk

# No emulador, usar IP 10.0.2.2 para localhost
```

### 2. Teste em Dispositivo Real

1. ✅ API rodando e acessível via IP local
2. ✅ Celular conectado na mesma rede
3. ✅ APK instalado
4. ✅ Abrir app e fazer login

**Credenciais de Teste:**
```
Admin:
Email: admin@sistema.com
Senha: Admin@123

Aluno:
Email: aluno@sistema.com
Senha: Aluno@123
```

---

## ⚙️ Configurações Avançadas

### Assinatura de APK (Para Produção)

```powershell
# Gerar keystore
keytool -genkey -v -keystore sistemachamados.keystore -alias sistemachamados -keyalg RSA -keysize 2048 -validity 10000

# Adicionar no .csproj
<PropertyGroup Condition="'$(Configuration)'=='Release'">
  <AndroidKeyStore>true</AndroidKeyStore>
  <AndroidSigningKeyStore>sistemachamados.keystore</AndroidSigningKeyStore>
  <AndroidSigningKeyAlias>sistemachamados</AndroidSigningKeyAlias>
  <AndroidSigningKeyPass>sua_senha</AndroidSigningKeyPass>
  <AndroidSigningStorePass>sua_senha</AndroidSigningStorePass>
</PropertyGroup>
```

---

### Otimizar Tamanho do APK

**No .csproj:**
```xml
<PropertyGroup Condition="'$(Configuration)'=='Release'">
  <AndroidLinkMode>Full</AndroidLinkMode>
  <AndroidEnableProguard>true</AndroidEnableProguard>
  <AndroidUseSharedRuntime>false</AndroidUseSharedRuntime>
  <EmbedAssembliesIntoApk>true</EmbedAssembliesIntoApk>
</PropertyGroup>
```

---

### Gerar APK por ABI (Menor tamanho)

```xml
<AndroidCreatePackagePerAbi>true</AndroidCreatePackagePerAbi>
```

Gera APKs separados:
- `arm64-v8a` (dispositivos 64-bit)
- `armeabi-v7a` (dispositivos 32-bit)
- `x86` (emuladores Intel)

---

## 🔍 Troubleshooting

### Erro: "Workload 'maui-android' not installed"

```powershell
dotnet workload install maui-android
```

---

### Erro: "Android SDK not found"

1. Instalar Android Studio
2. Abrir SDK Manager
3. Instalar:
   - Android SDK Build-Tools
   - Android SDK Platform-Tools
   - Android SDK Platform (API 33)

---

### APK não conecta à API

**Checklist:**
- [ ] API rodando? (`http://IP:5246/swagger`)
- [ ] IP correto no `Constants.cs`?
- [ ] Celular na mesma rede Wi-Fi?
- [ ] Firewall bloqueando porta 5246?
- [ ] `usesCleartextTraffic="true"` no manifest?

**Testar conectividade:**
- No navegador do celular, acessar: `http://192.168.0.18:5246/swagger`
- Deve abrir a documentação da API

---

### APK não instala

- ✅ Verificar "Fontes desconhecidas" habilitadas
- ✅ Versão Android >= 5.0 (API 21)
- ✅ Espaço suficiente (~100MB)
- ✅ APK não corrompido (recompilar)

---

## 📝 Checklist Final

Antes de distribuir APK:

- [ ] IP da API configurado corretamente
- [ ] API acessível externamente (ngrok ou IP local)
- [ ] Testado login com usuários
- [ ] Testado criar chamado
- [ ] Testado ver lista de chamados
- [ ] Permissões de internet configuradas
- [ ] Ícone do app configurado
- [ ] Nome do app correto ("Sistema de Chamados")
- [ ] Versão atualizada no manifest

---

## 📊 Informações do APK

| Propriedade | Valor |
|-------------|-------|
| **Package Name** | com.sistemachamados.mobile |
| **Version Code** | 1 |
| **Version Name** | 1.0 |
| **Min SDK** | 21 (Android 5.0) |
| **Target SDK** | 33 (Android 13) |
| **Permissões** | Internet, Network State |
| **Tamanho** | ~30-50 MB |

---

## 🎯 Próximos Passos

### Para Distribuição Pública

1. **Google Play Store**
   - Assinar APK com keystore
   - Criar conta Google Play Developer ($25)
   - Submeter AAB (não APK)
   - Aguardar aprovação (~3 dias)

2. **Distribuição Direta**
   - Compartilhar APK via link
   - Usuários precisam permitir fontes desconhecidas
   - Manter versões atualizadas

3. **Firebase App Distribution**
   - Upload do APK
   - Convidar testadores por email
   - Rastreamento de instalações

---

## 🔗 Recursos Úteis

- [Documentação .NET MAUI](https://learn.microsoft.com/dotnet/maui/)
- [Android Developer Guide](https://developer.android.com)
- [ngrok Documentation](https://ngrok.com/docs)
- [APK Analyzer](https://developer.android.com/studio/build/apk-analyzer)

---

**Status:** ✅ Pronto para gerar APK  
**Última atualização:** 20/10/2025

---

## 🚀 Comando Rápido

```powershell
# Gerar APK em um comando
cd c:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade
.\GerarAPK.ps1
```

**✅ SUCESSO = APK em `c:\Users\opera\sistema-chamados-faculdade\APK\`**
