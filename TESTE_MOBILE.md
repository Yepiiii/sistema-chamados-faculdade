# 🚀 Guia de Teste - Sistema de Chamados Mobile

## 📋 Pré-requisitos

✅ .NET 8 SDK instalado (você já tem!)
✅ API rodando em `http://localhost:5246`
✅ Projeto mobile compilando sem erros (✓ Verificado!)

---

## 🎯 OPÇÃO 1: Teste no Windows (MAIS RÁPIDO) ⚡

### Passo 1: Garantir que a API está rodando

```powershell
# Na pasta raiz do projeto
cd c:/Users/opera/sistema-chamados-faculdade/sistema-chamados-faculdade

# Rodar a API
dotnet run --project SistemaChamados.csproj
```

A API deve estar acessível em: `http://localhost:5246`

### Passo 2: Rodar o app Windows

```powershell
# Em outro terminal
cd SistemaChamados.Mobile

# Opção A: Build e Run
dotnet build -t:Run -f net8.0-windows10.0.19041.0

# Opção B: Apenas Run (se já buildou)
dotnet run -f net8.0-windows10.0.19041.0
```

**✅ O app vai abrir como aplicativo desktop Windows!**

---

## 📱 OPÇÃO 2: Teste no Android Emulator

### Pré-requisitos Android

1. **Instalar Android SDK** (via Visual Studio Installer):
   - Abra "Visual Studio Installer"
   - Modifique sua instalação
   - Marque "Desenvolvimento móvel com .NET"
   - Instale

2. **Criar um emulador** (se não tiver):
   
```powershell
# Listar emuladores disponíveis
"%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe" -list-avds

# Criar emulador Pixel 5 (se necessário)
"%LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest\bin\avdmanager.bat" create avd -n pixel_5 -k "system-images;android-33;google_apis;x86_64"
```

### Passo 1: Iniciar emulador

```powershell
# Iniciar emulador em background
"%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe" -avd pixel_5 -no-snapshot-load
```

**Aguarde o emulador inicializar completamente (tela home aparecer)**

### Passo 2: Garantir que a API está rodando

```powershell
cd c:/Users/opera/sistema-chamados-faculdade/sistema-chamados-faculdade
dotnet run --project SistemaChamados.csproj
```

### Passo 3: Instalar e executar o app

```powershell
cd SistemaChamados.Mobile

# Build e deploy no emulador
dotnet build -t:Run -f net8.0-android
```

**🔴 IMPORTANTE:** 
- O emulador Android usa `10.0.2.2` para acessar o `localhost` do host
- Já configuramos isso no `Constants.cs`!

---

## 📲 OPÇÃO 3: Teste em Dispositivo Android Físico

### Passo 1: Preparar o celular

1. **Ativar modo desenvolvedor:**
   - Configurações → Sobre o telefone
   - Toque 7x em "Número da versão" ou "Número de compilação"

2. **Ativar depuração USB:**
   - Configurações → Sistema → Opções do desenvolvedor
   - Ative "Depuração USB"

3. **Conectar via USB ao PC**

4. **Aceitar a permissão de depuração** que aparece no celular

### Passo 2: Verificar se o dispositivo foi detectado

```powershell
# Listar dispositivos conectados
"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" devices
```

Você deve ver algo como:
```
List of devices attached
XXXXXXXX    device
```

### Passo 3: Descobrir seu IP local

```powershell
# Descobrir seu IP na rede local
ipconfig | Select-String "IPv4"
```

Anote o IP (ex: `192.168.1.100`)

### Passo 4: Atualizar a URL da API

Edite `SistemaChamados.Mobile/Helpers/Constants.cs`:

```csharp
public static string BaseUrlPhysicalDevice => "http://SEU_IP_AQUI:5246/api/";
```

E na propriedade `BaseUrl`, mude para:
```csharp
#if ANDROID
    return BaseUrlPhysicalDevice; // <-- Mude aqui!
#elif WINDOWS
```

### Passo 5: Configurar a API para aceitar conexões externas

No `Program.cs` da API, adicione:

```csharp
builder.WebHost.ConfigureKestrel(options =>
{
    options.ListenAnyIP(5246); // Aceita conexões de qualquer IP
});
```

### Passo 6: Rodar a API

```powershell
cd c:/Users/opera/sistema-chamados-faculdade/sistema-chamados-faculdade
dotnet run --project SistemaChamados.csproj
```

### Passo 7: Instalar e executar no celular

```powershell
cd SistemaChamados.Mobile
dotnet build -t:Run -f net8.0-android
```

**✅ O app será instalado e executado no seu celular!**

---

## 🍎 OPÇÃO 4: iOS (Requer Mac)

Infelizmente, para testar no iOS você precisa de um Mac com Xcode instalado.

---

## 🐛 Troubleshooting

### ❌ Erro: "No Android devices found"

**Solução:**
```powershell
# Reiniciar servidor ADB
"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" kill-server
"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" start-server
"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" devices
```

### ❌ Erro: "Unable to connect to API"

**Diagnóstico:**

1. **Verificar se a API está rodando:**
   ```powershell
   curl http://localhost:5246/api/usuarios/test
   ```

2. **Testar do emulador Android:**
   ```powershell
   "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" shell curl http://10.0.2.2:5246/api/usuarios/test
   ```

3. **Testar do celular físico:**
   - Abra o navegador do celular
   - Acesse: `http://SEU_IP:5246/api/usuarios/test`

### ❌ Erro: "Build failed"

**Solução:**
```powershell
# Limpar build anterior
dotnet clean
rm -r bin,obj -Force

# Rebuild
dotnet build
```

---

## 📝 Fluxo de Teste Recomendado

### 1️⃣ **Login**
- Email: Use um usuário cadastrado na API
- Senha: Senha correspondente
- Clique em "Entrar"

### 2️⃣ **Visualizar Chamados**
- Na tela principal, clique em "Meus Chamados"
- Deve listar os chamados do usuário

### 3️⃣ **Criar Novo Chamado**
- Clique no botão "Novo Chamado"
- Preencha: Título, Descrição
- Selecione Categoria e Prioridade
- Clique em "Criar"

### 4️⃣ **Ver Detalhes**
- Toque em um chamado da lista
- Veja os detalhes completos

---

## 🎨 Hot Reload (Desenvolvimento Ágil)

Para desenvolvimento mais rápido com Hot Reload:

```powershell
# Instalar .NET MAUI CLI
dotnet workload install maui

# Rodar com Hot Reload
dotnet watch run -f net8.0-windows10.0.19041.0
```

Agora, ao salvar mudanças nos arquivos .xaml ou .cs, o app atualiza automaticamente! 🔥

---

## ✅ Checklist de Teste

- [ ] App abre sem erros
- [ ] Tela de login aparece
- [ ] Login funciona e redireciona para MainPage
- [ ] Lista de chamados carrega
- [ ] Pode criar novo chamado
- [ ] Pode ver detalhes de um chamado
- [ ] Logout funciona
- [ ] Navegação entre telas funciona
- [ ] ActivityIndicator (loading) aparece durante requisições

---

## 📊 Logs e Debug

### Ver logs do app Android:

```powershell
# Filtrar logs do app
"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" logcat | Select-String "SistemaChamados"
```

### Ver requisições HTTP:

Adicione breakpoints nos métodos do `ApiService.cs` para debugar requisições.

---

## 🚀 Próximos Passos

Depois de testar com sucesso:

1. ✅ Adicionar validações de formulário
2. ✅ Implementar cache local
3. ✅ Adicionar pull-to-refresh nas listas
4. ✅ Implementar análise com IA (botão "Analisar")
5. ✅ Melhorar UI/UX com animações
6. ✅ Adicionar tratamento de erros de rede
7. ✅ Implementar modo offline
8. ✅ Publicar na Google Play Store / App Store

---

**Boa sorte com os testes! 🎉**
