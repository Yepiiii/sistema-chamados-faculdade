# 📱 Guia de Integração do Mobile App

## 📋 Índice
- [Visão Geral](#visão-geral)
- [Pré-requisitos](#pré-requisitos)
- [Dependências NuGet](#dependências-nuget)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Configuração](#configuração)
- [Integração com Backend](#integração-com-backend)
- [Checklist de Integração](#checklist-de-integração)

---

## 🎯 Visão Geral

O app mobile do Sistema de Chamados é desenvolvido em **.NET MAUI (Multi-platform App UI)** e atualmente está configurado apenas para **Android**.

### Tecnologias Utilizadas
- **.NET 8.0** - Framework base
- **.NET MAUI** - Framework mobile multiplataforma
- **MVVM Pattern** - Arquitetura Model-View-ViewModel
- **CommunityToolkit.Mvvm** - Biblioteca para MVVM
- **Newtonsoft.Json** - Serialização JSON
- **HttpClient** - Comunicação HTTP com API REST

---

## ⚙️ Pré-requisitos

### 1. SDK e Ferramentas
```powershell
# .NET 8 SDK
dotnet --version  # Deve retornar 8.0.x

# Workload MAUI
dotnet workload install maui

# Workload Android (se necessário)
dotnet workload install android
```

### 2. Android SDK
- **Android SDK Build-Tools** (versão 33.0.0 ou superior)
- **Android Platform 33** (Android 13)
- **Android Emulator** ou dispositivo físico

### 3. IDE Recomendada
- **Visual Studio 2022** (Windows) com:
  - Workload "Desenvolvimento de aplicativos móveis com .NET"
  - Android SDK Manager
- **Visual Studio Code** com:
  - Extensão "C# Dev Kit"
  - Extensão ".NET MAUI"

---

## 📦 Dependências NuGet

O projeto mobile requer os seguintes pacotes:

```xml
<ItemGroup>
  <!-- MVVM Toolkit -->
  <PackageReference Include="CommunityToolkit.Mvvm" Version="8.2.0" />
  
  <!-- JSON Serialization -->
  <PackageReference Include="Newtonsoft.Json" Version="13.0.3" />
  
  <!-- MAUI Controls -->
  <PackageReference Include="Microsoft.Maui.Controls" Version="8.0.3" />
  
  <!-- Configuration -->
  <PackageReference Include="Microsoft.Extensions.Configuration.Json" Version="8.0.0" />
  <PackageReference Include="Microsoft.Extensions.Configuration.EnvironmentVariables" Version="8.0.0" />
  
  <!-- HTTP Client -->
  <PackageReference Include="Microsoft.Extensions.Http" Version="8.0.0" />
</ItemGroup>
```

### Instalação Manual
```powershell
cd Mobile
dotnet add package CommunityToolkit.Mvvm --version 8.2.0
dotnet add package Newtonsoft.Json --version 13.0.3
dotnet add package Microsoft.Maui.Controls --version 8.0.3
dotnet add package Microsoft.Extensions.Configuration.Json --version 8.0.0
dotnet add package Microsoft.Extensions.Http --version 8.0.0
```

---

## 📂 Estrutura do Projeto

```
Mobile/
├── App.xaml                    # Aplicação principal (XAML)
├── App.xaml.cs                 # Código-behind da App
├── AppShell.xaml               # Shell de navegação
├── AppShell.xaml.cs            # Código-behind do Shell
├── MauiProgram.cs              # ⚠️ IMPORTANTE: Registro de serviços DI
├── MainPage.xaml               # Página inicial (redirecionamento)
├── appsettings.json            # ⚠️ IMPORTANTE: Configurações da API
│
├── Converters/                 # Conversores XAML
│   ├── BoolToTextConverter.cs
│   ├── GreaterThanZeroConverter.cs
│   ├── IsNotNullConverter.cs
│   ├── PluralSuffixConverter.cs
│   └── UtcToLocalConverter.cs
│
├── Helpers/                    # Classes auxiliares
│   ├── ApiResponse.cs          # ⚠️ Response wrapper da API
│   ├── Constants.cs            # ⚠️ IMPORTANTE: URLs e constantes
│   ├── InvertedBoolConverter.cs
│   ├── IsNotNullConverter.cs
│   └── ServiceHelper.cs
│
├── Models/                     # ⚠️ IMPORTANTE: Modelos de dados
│   ├── Categoria.cs
│   ├── Chamado.cs
│   ├── LoginRequest.cs
│   ├── LoginResponse.cs
│   ├── Prioridade.cs
│   ├── Status.cs
│   └── Usuario.cs
│
├── Services/                   # ⚠️ CRÍTICO: Serviços de API
│   ├── Api/
│   │   ├── IApiService.cs      # Interface do cliente HTTP
│   │   └── ApiService.cs       # Implementação do cliente HTTP
│   ├── Auth/
│   │   ├── IAuthService.cs     # Interface de autenticação
│   │   └── AuthService.cs      # Gerencia login/logout/token
│   ├── Chamados/
│   │   ├── IChamadoService.cs  # Interface de chamados
│   │   └── ChamadoService.cs   # CRUD de chamados
│   ├── Categorias/
│   │   ├── ICategoriaService.cs
│   │   └── CategoriaService.cs
│   ├── Prioridades/
│   │   ├── IPrioridadeService.cs
│   │   └── PrioridadeService.cs
│   └── Status/
│       ├── IStatusService.cs
│       └── StatusService.cs
│
├── ViewModels/                 # ViewModels (MVVM)
│   ├── BaseViewModel.cs        # ViewModel base
│   ├── LoginViewModel.cs
│   ├── ChamadosListViewModel.cs
│   ├── ChamadoDetailViewModel.cs
│   ├── NovoChamadoViewModel.cs
│   └── DashboardViewModel.cs
│
├── Views/                      # Views (Páginas XAML)
│   ├── Auth/
│   │   ├── LoginPage.xaml
│   │   └── LoginPage.xaml.cs
│   ├── ChamadosListPage.xaml
│   ├── ChamadosListPage.xaml.cs
│   ├── ChamadoDetailPage.xaml
│   ├── ChamadoDetailPage.xaml.cs
│   ├── NovoChamadoPage.xaml
│   └── NovoChamadoPage.xaml.cs
│
├── Platforms/                  # Código específico por plataforma
│   └── Android/
│       ├── AndroidManifest.xml # ⚠️ Permissões Android
│       └── MainActivity.cs
│
└── Resources/                  # Recursos (imagens, fontes, etc)
    ├── AppIcon/
    ├── Splash/
    ├── Fonts/
    └── Images/
```

---

## 🔧 Configuração

### 1. appsettings.json
```json
{
  "BaseUrl": "http://10.0.2.2:5246/api/",
  "BaseUrlWindows": "http://localhost:5246/api/",
  "BaseUrlPhysicalDevice": "http://SEU_IP_LOCAL:5246/api/"
}
```

**Importante:**
- `10.0.2.2` - IP especial do Android Emulator para acessar localhost do host
- Para dispositivo físico, use o IP da sua máquina na rede local
- Para Windows, use `localhost`

### 2. Constants.cs
```csharp
public static class Constants
{
    // Determina automaticamente a URL baseada na plataforma
    public static string BaseUrl =>
#if ANDROID
        DeviceInfo.DeviceType == DeviceType.Virtual 
            ? "http://10.0.2.2:5246/api/" 
            : "http://SEU_IP_LOCAL:5246/api/";
#elif WINDOWS
        "http://localhost:5246/api/";
#else
        "http://localhost:5246/api/";
#endif
}
```

### 3. MauiProgram.cs - Dependency Injection
```csharp
public static MauiApp CreateMauiApp()
{
    var builder = MauiApp.CreateBuilder();
    
    // HttpClient compartilhado
    builder.Services.AddSingleton(new HttpClient
    {
        BaseAddress = new Uri(Constants.BaseUrl),
        Timeout = TimeSpan.FromSeconds(30)
    });
    
    // Serviços
    builder.Services.AddSingleton<IApiService, ApiService>();
    builder.Services.AddSingleton<IAuthService, AuthService>();
    builder.Services.AddSingleton<IChamadoService, ChamadoService>();
    builder.Services.AddSingleton<ICategoriaService, CategoriaService>();
    builder.Services.AddSingleton<IPrioridadeService, PrioridadeService>();
    builder.Services.AddSingleton<IStatusService, StatusService>();
    
    // ViewModels
    builder.Services.AddTransient<LoginViewModel>();
    builder.Services.AddTransient<ChamadosListViewModel>();
    // ... outros ViewModels
    
    // Pages
    builder.Services.AddTransient<LoginPage>();
    builder.Services.AddTransient<ChamadosListPage>();
    // ... outras Pages
    
    return builder.Build();
}
```

### 4. AndroidManifest.xml - Permissões
```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application android:usesCleartextTraffic="true" />
    
    <!-- Permissões de Internet -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
</manifest>
```

**⚠️ CRÍTICO:** `android:usesCleartextTraffic="true"` é necessário para HTTP (desenvolvimento)

---

## 🔌 Integração com Backend

### Contratos da API

O mobile **DEVE** seguir exatamente os mesmos contratos (DTOs) do backend:

#### 1. Login
```csharp
// Request
public class LoginRequest
{
    public string Email { get; set; }
    public string Senha { get; set; }
}

// Response
public class LoginResponse
{
    public int Id { get; set; }
    public string NomeCompleto { get; set; }
    public string Email { get; set; }
    public string Token { get; set; }
    public string TipoUsuario { get; set; }
}
```

#### 2. Chamado
```csharp
public class Chamado
{
    public int Id { get; set; }
    public string Titulo { get; set; }
    public string Descricao { get; set; }
    public DateTime DataAbertura { get; set; }
    public DateTime? DataFechamento { get; set; }
    public int SolicitanteId { get; set; }
    public int? TecnicoId { get; set; }
    public int CategoriaId { get; set; }
    public Categoria Categoria { get; set; }
    public int PrioridadeId { get; set; }
    public Prioridade Prioridade { get; set; }
    public int StatusId { get; set; }
    public Status Status { get; set; }
}
```

### Endpoints Utilizados

```
POST   /api/usuarios/login          # Login
GET    /api/chamados                # Listar chamados
POST   /api/chamados                # Criar chamado
GET    /api/chamados/{id}           # Detalhes do chamado
PUT    /api/chamados/{id}           # Atualizar chamado
GET    /api/categorias              # Listar categorias
GET    /api/prioridades             # Listar prioridades
GET    /api/status                  # Listar status
```

### Autenticação

O mobile usa **JWT Bearer Token**:

```csharp
// No AuthService.cs
public async Task<LoginResponse> LoginAsync(string email, string senha)
{
    var response = await _apiService.PostAsync<LoginResponse>(
        "usuarios/login",
        new LoginRequest { Email = email, Senha = senha }
    );
    
    if (response != null)
    {
        // Salvar token no Preferences (storage seguro)
        Preferences.Set("auth_token", response.Token);
        Preferences.Set("user_id", response.Id);
        Preferences.Set("user_name", response.NomeCompleto);
    }
    
    return response;
}

// No ApiService.cs - Adicionar header em toda requisição
private async Task<T> SendAsync<T>(HttpRequestMessage request)
{
    var token = Preferences.Get("auth_token", null);
    if (!string.IsNullOrEmpty(token))
    {
        request.Headers.Authorization = 
            new AuthenticationHeaderValue("Bearer", token);
    }
    
    var response = await _httpClient.SendAsync(request);
    // ... processar resposta
}
```

---

## ✅ Checklist de Integração

### Passo 1: Copiar Pasta Mobile
```powershell
# Copiar a pasta Mobile para o novo projeto
Copy-Item -Path "sistema-chamados-faculdade\Mobile" -Destination "novo-projeto\Mobile" -Recurse
```

### Passo 2: Ajustar Referências
- [ ] Atualizar namespace no `.csproj` se necessário
- [ ] Verificar se `ApplicationId` é único: `com.sistemachamados.mobile`
- [ ] Ajustar `ApplicationTitle` para o nome do novo app

### Passo 3: Configurar Conexão com Backend
- [ ] Criar/ajustar `appsettings.json`:
  ```json
  {
    "BaseUrl": "http://10.0.2.2:PORTA/api/",
    "BaseUrlWindows": "http://localhost:PORTA/api/",
    "BaseUrlPhysicalDevice": "http://SEU_IP:PORTA/api/"
  }
  ```
- [ ] Atualizar `Constants.cs` com as URLs corretas
- [ ] Verificar que o backend está rodando e acessível

### Passo 4: Ajustar Modelos (DTOs)
- [ ] Comparar `Models/*.cs` com os DTOs do backend
- [ ] Ajustar propriedades para corresponder exatamente
- [ ] Verificar se serialização JSON funciona (nomes de propriedades)

### Passo 5: Validar Serviços
- [ ] Verificar endpoints em `Services/*/I*Service.cs`
- [ ] Confirmar que URLs dos endpoints correspondem ao backend
- [ ] Testar autenticação (login)
- [ ] Testar CRUD de chamados

### Passo 6: Configurar Android
- [ ] Verificar `AndroidManifest.xml` com permissões corretas
- [ ] Adicionar `android:usesCleartextTraffic="true"` para HTTP
- [ ] Configurar ícone do app em `Resources/AppIcon/`
- [ ] Configurar splash screen em `Resources/Splash/`

### Passo 7: Dependências
- [ ] Restaurar pacotes NuGet:
  ```powershell
  cd Mobile
  dotnet restore
  ```
- [ ] Verificar que todos os pacotes foram instalados
- [ ] Resolver conflitos de versão se houver

### Passo 8: Build e Teste
```powershell
# Build
cd Mobile
dotnet build -f net8.0-android

# Deploy em emulador
dotnet build -f net8.0-android -t:Run

# OU no Visual Studio
# Selecione Android Emulator > F5 (Debug)
```

### Passo 9: Testes Funcionais
- [ ] **Login:** Testar com credenciais válidas
- [ ] **Listar Chamados:** Verificar se lista carrega
- [ ] **Criar Chamado:** Criar novo chamado
- [ ] **Detalhes:** Ver detalhes de um chamado
- [ ] **Filtros:** Testar filtros por status/prioridade
- [ ] **Logout:** Testar logout e limpeza de token

### Passo 10: Troubleshooting Comum
- [ ] **Erro de conexão:** Verificar URL e firewall
- [ ] **401 Unauthorized:** Token expirado ou inválido
- [ ] **CORS errors:** Backend deve ter CORS configurado
- [ ] **SSL/HTTPS:** Para produção, usar HTTPS no backend

---

## 🔐 Segurança

### Armazenamento de Credenciais
```csharp
// ✅ BOM: Usar Preferences (seguro)
Preferences.Set("auth_token", token);
var token = Preferences.Get("auth_token", null);

// ❌ RUIM: Não usar variáveis estáticas ou arquivos de texto
public static string Token; // Inseguro!
```

### HTTPS em Produção
```csharp
// Para produção, SEMPRE usar HTTPS
public static string BaseUrl => "https://api.seudominio.com/api/";
```

### Validação de Certificado SSL
```csharp
// Android: Adicionar certificado em Resources/Raw/
// E configurar em MainActivity.cs
```

---

## 📱 Build para Produção

### Android APK
```powershell
cd Mobile
dotnet publish -f net8.0-android -c Release
```

O APK estará em: `Mobile/bin/Release/net8.0-android/publish/`

### Android AAB (Google Play)
```powershell
dotnet publish -f net8.0-android -c Release -p:AndroidPackageFormat=aab
```

### Assinatura do App
Antes de publicar, configure assinatura digital:

1. Gerar keystore:
```powershell
keytool -genkey -v -keystore meuapp.keystore -alias meuapp -keyalg RSA -keysize 2048 -validity 10000
```

2. Adicionar no `.csproj`:
```xml
<PropertyGroup Condition="'$(Configuration)'=='Release'">
  <AndroidKeyStore>true</AndroidKeyStore>
  <AndroidSigningKeyStore>meuapp.keystore</AndroidSigningKeyStore>
  <AndroidSigningKeyAlias>meuapp</AndroidSigningKeyAlias>
  <AndroidSigningKeyPass>SENHA</AndroidSigningKeyPass>
  <AndroidSigningStorePass>SENHA</AndroidSigningStorePass>
</PropertyGroup>
```

---

## 🆘 Suporte e Recursos

### Documentação Oficial
- [.NET MAUI Docs](https://learn.microsoft.com/dotnet/maui/)
- [CommunityToolkit.Mvvm](https://learn.microsoft.com/dotnet/communitytoolkit/mvvm/)
- [Android Developer Guide](https://developer.android.com/)

### Problemas Comuns

#### "SDK Android não encontrado"
```powershell
# Instalar Android SDK via Visual Studio Installer
# OU via linha de comando:
dotnet workload install android
```

#### "Erro ao conectar com localhost"
- **Emulador:** Use `10.0.2.2` em vez de `localhost`
- **Dispositivo Físico:** Use IP da máquina na rede local
- Verificar firewall do Windows

#### "Erro de autenticação 401"
- Token expirado - fazer login novamente
- Verificar se header `Authorization` está sendo enviado
- Verificar formato: `Bearer {token}`

---

## 📝 Resumo Rápido

**Para integrar o Mobile em outro projeto:**

1. ✅ Copie a pasta `Mobile/`
2. ✅ Instale .NET 8 + Workload MAUI
3. ✅ Configure `appsettings.json` com URL do backend
4. ✅ Ajuste `Constants.cs` com URLs corretas
5. ✅ Verifique modelos (DTOs) correspondem ao backend
6. ✅ Configure `AndroidManifest.xml` com permissões
7. ✅ Restaure pacotes: `dotnet restore`
8. ✅ Build: `dotnet build -f net8.0-android`
9. ✅ Teste no emulador ou dispositivo
10. ✅ Para produção: assine o APK e publique

**Arquivos CRÍTICOS a configurar:**
- `appsettings.json` - URLs da API
- `Helpers/Constants.cs` - URLs por plataforma
- `MauiProgram.cs` - Dependency Injection
- `Platforms/Android/AndroidManifest.xml` - Permissões
- `Models/*.cs` - Devem corresponder aos DTOs do backend

---

**Data:** 27/10/2025  
**Versão:** 1.0.0
