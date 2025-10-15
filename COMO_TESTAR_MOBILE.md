# 🚀 Como Testar o App Mobile - Sistema de Chamados

## ⚠️ IMPORTANTE SOBRE OS "ERROS" NO VS CODE

**Os erros que você vê no VS Code são FALSOS!** 

✅ O projeto **COMPILA COM SUCESSO**:
```bash
dotnet build SistemaChamados.Mobile/SistemaChamados.Mobile.csproj
# Resultado: 0 Erros
```

Os "erros" aparecem porque o IntelliSense do VS Code não reconhece projetos .NET MAUI multi-target automaticamente. **IGNORE ESSES ERROS - O CÓDIGO ESTÁ CORRETO!**

---

## 📋 Pré-requisitos

### 1. API Backend rodando
```powershell
# Na raiz do projeto
dotnet run --project SistemaChamados.csproj
# Deve rodar em: http://localhost:5246
```

### 2. Verificar workloads instalados
```powershell
dotnet workload list
```

Você deve ter instalado:
- ✅ `android` (Android)
- ✅ `ios` (iOS - apenas no Mac)
- ✅ `maccatalyst` (Mac Catalyst - apenas no Mac)
- ✅ `maui-windows` (Windows)

---

## 🪟 OPÇÃO 1: Testar no Windows (MAIS FÁCIL)

### Passo 1: Build e execução
```powershell
cd SistemaChamados.Mobile
dotnet build -t:Run -f net8.0-windows10.0.19041.0
```

**✅ Vantagens:**
- Roda direto no seu PC
- Não precisa de emulador
- Mais rápido para testar
- Fácil de debugar

### ❌ Se der erro de certificado:
```powershell
dotnet dev-certs https --trust
```

---

## 📱 OPÇÃO 2: Testar no Android (Emulador)

### Passo 1: Verificar se tem Android SDK
```powershell
# Verificar variável de ambiente
$env:ANDROID_HOME
# Ou
$env:ANDROID_SDK_ROOT
```

### Passo 2: Instalar workload Android (se necessário)
```powershell
dotnet workload install android
```

### Passo 3: Criar um emulador Android

**Usando Android Studio:**
1. Abra Android Studio
2. Tools → Device Manager
3. Create Device
4. Escolha um dispositivo (ex: Pixel 5)
5. Escolha uma imagem do sistema (Android 11+)
6. Finish

**OU via linha de comando:**
```powershell
# Listar AVDs existentes
"%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe" -list-avds

# Criar um novo (exemplo)
"%LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest\bin\avdmanager.bat" create avd -n Pixel5 -k "system-images;android-30;google_apis;x86_64"
```

### Passo 4: Iniciar o emulador
```powershell
# Listar emuladores
"%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe" -list-avds

# Iniciar emulador específico
"%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe" -avd NOME_DO_AVD
```

### Passo 5: Build e Deploy
```powershell
cd SistemaChamados.Mobile
dotnet build -t:Run -f net8.0-android
```

### 🔧 Configuração de Rede para Android Emulator

**PROBLEMA:** `localhost` no Android Emulator não aponta para seu PC!

**SOLUÇÃO:** Use o IP especial do emulador:
- `10.0.2.2` → aponta para `localhost` do seu PC

Antes de rodar no Android, edite `appsettings.json`:
```json
{
  "BaseUrl": "http://10.0.2.2:5246/api/"
}
```

---

## 📲 OPÇÃO 3: Testar em Dispositivo Android Físico

### Passo 1: Habilitar modo desenvolvedor no celular
1. Configurações → Sobre o telefone
2. Toque 7 vezes em "Número da versão"
3. Volte e entre em "Opções do desenvolvedor"
4. Ative "Depuração USB"

### Passo 2: Conectar via USB
1. Conecte o celular ao PC via USB
2. Aceite a permissão de depuração USB no celular

### Passo 3: Verificar conexão
```powershell
# Verificar se o dispositivo foi detectado
"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" devices
```

### Passo 4: Configurar IP da API
Descubra o IP local do seu PC:
```powershell
ipconfig | Select-String "IPv4"
# Exemplo: 192.168.1.100
```

Edite `appsettings.json`:
```json
{
  "BaseUrl": "http://192.168.1.100:5246/api/"
}
```

⚠️ **Certifique-se que o celular está na mesma rede Wi-Fi do PC!**

### Passo 5: Build e Deploy
```powershell
cd SistemaChamados.Mobile
dotnet build -t:Run -f net8.0-android
```

---

## 🐛 Troubleshooting

### Erro: "Android SDK not found"
```powershell
# Instalar Android SDK via Visual Studio Installer
# Ou baixar Android Studio e configurar
$env:ANDROID_HOME = "C:\Users\SEU_USUARIO\AppData\Local\Android\Sdk"
```

### Erro: "No emulator found"
```powershell
# Criar um emulador primeiro (ver Opção 2, Passo 3)
```

### Erro: "Cannot connect to API"
```powershell
# 1. Verificar se a API está rodando
curl http://localhost:5246/api/categorias

# 2. Para Android emulator, usar 10.0.2.2 ao invés de localhost
# 3. Para dispositivo físico, usar IP local (192.168.x.x)

# 4. Verificar firewall do Windows permite conexões na porta 5246
```

### App crasha ao abrir
```powershell
# Ver logs do Android
"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" logcat | Select-String "SistemaChamados"
```

---

## 📝 Testar Funcionalidades

### 1. Login
- Usar credenciais criadas no backend
- Deve salvar token e navegar para Main

### 2. Listar Chamados
- Ver lista de chamados do usuário logado
- Testar pull-to-refresh

### 3. Criar Novo Chamado
- Preencher título e descrição
- Selecionar categoria e prioridade
- Criar chamado

### 4. Ver Detalhes
- Clicar em um chamado da lista
- Ver informações completas

---

## 🎯 Comando Rápido (Windows)

```powershell
# Build completo e executar
cd SistemaChamados.Mobile
dotnet build -t:Run -f net8.0-windows10.0.19041.0
```

---

## 📚 Recursos Adicionais

- [Documentação .NET MAUI](https://learn.microsoft.com/dotnet/maui/)
- [Android Emulator](https://developer.android.com/studio/run/emulator)
- [Depuração MAUI](https://learn.microsoft.com/dotnet/maui/deployment/)
