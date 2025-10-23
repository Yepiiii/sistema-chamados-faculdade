# 🗂️ Estrutura do Projeto Mobile

## 📁 Árvore de Diretórios

```
SistemaChamados.Mobile/
├── 📱 App.xaml                     # Configurações globais do app
├── 📱 App.xaml.cs                  # Code-behind do App
├── 🔧 appsettings.json             # Configurações gerais
├── 🚀 AppShell.xaml                # Navegação Shell
├── 🚀 AppShell.xaml.cs             # Code-behind do Shell
├── 🏠 MainPage.xaml                # Página principal (deprecated)
├── 🏠 MainPage.xaml.cs             # Code-behind
├── ⚙️ MauiProgram.cs               # Configuração do MAUI
├── 📦 SistemaChamados.Mobile.csproj # Arquivo de projeto
│
├── 📂 Views/                       # 🎨 TELAS XAML
│   ├── 📂 Auth/
│   │   ├── LoginPage.xaml          # Tela de login
│   │   └── LoginPage.xaml.cs       # Code-behind
│   │
│   ├── ChamadosListPage.xaml       # ⭐ Lista principal de chamados
│   ├── ChamadosListPage.xaml.cs
│   ├── ChamadoDetailPage.xaml      # Detalhes do chamado
│   ├── ChamadoDetailPage.xaml.cs
│   ├── NovoChamadoPage.xaml        # Criar novo chamado
│   ├── NovoChamadoPage.xaml.cs
│   ├── MainPage.xaml               # (deprecated)
│   └── MainPage.xaml.cs
│   
│   ├── 📂 Admin/                   # (Futuras telas de admin)
│   └── 📂 Chamados/                # (Telas extras)
│
├── 📂 ViewModels/                  # 🧠 LÓGICA DE APRESENTAÇÃO (MVVM)
│   ├── BaseViewModel.cs            # ViewModel base com INotifyPropertyChanged
│   ├── LoginViewModel.cs           # Lógica de login
│   ├── ChamadosListViewModel.cs    # ⭐ Lógica da lista (filtros, busca)
│   ├── ChamadoDetailViewModel.cs   # Lógica dos detalhes
│   ├── NovoChamadoViewModel.cs     # Lógica de criação
│   └── MainViewModel.cs            # (deprecated)
│
├── 📂 Models/                      # 📊 ENTIDADES E DTOs
│   ├── 📂 Entities/
│   │   ├── Chamado.cs              # ⭐ Entidade principal
│   │   ├── Usuario.cs              # Usuário
│   │   ├── Categoria.cs            # Categoria do chamado
│   │   ├── Prioridade.cs           # Prioridade (Baixa, Alta, etc.)
│   │   └── Status.cs               # Status (Aberto, Encerrado, etc.)
│   │
│   └── 📂 DTOs/
│       ├── LoginRequestDto.cs      # Request de login
│       ├── LoginResponseDto.cs     # Response de login
│       └── ChamadoCreateDto.cs     # DTO para criar chamado
│
├── 📂 Services/                    # 🔌 COMUNICAÇÃO COM API
│   ├── 📂 Api/
│   │   ├── ApiService.cs           # ⭐ HttpClient wrapper
│   │   └── IApiService.cs          # Interface
│   │
│   ├── 📂 Auth/
│   │   ├── AuthService.cs          # Serviço de autenticação
│   │   └── IAuthService.cs
│   │
│   ├── 📂 Chamados/
│   │   ├── ChamadosService.cs      # CRUD de chamados
│   │   └── IChamadosService.cs
│   │
│   ├── 📂 Categorias/
│   │   ├── CategoriasService.cs    # Buscar categorias
│   │   └── ICategoriasService.cs
│   │
│   ├── 📂 Prioridades/
│   │   ├── PrioridadesService.cs   # Buscar prioridades
│   │   └── IPrioridadesService.cs
│   │
│   └── 📂 Status/
│       ├── StatusService.cs        # Buscar status
│       └── IStatusService.cs
│
├── 📂 Helpers/                     # 🛠️ UTILITÁRIOS
│   ├── Constants.cs                # ⭐ URLs da API, constantes
│   ├── Settings.cs                 # Preferências persistidas (token, etc.)
│   ├── ApiResponse.cs              # Wrapper de resposta da API
│   └── IsNotNullConverter.cs       # Conversor XAML (null check)
│
├── 📂 Resources/                   # 🎨 RECURSOS VISUAIS
│   ├── 📂 Styles/
│   │   ├── Colors.xaml             # ⭐ Paleta de cores
│   │   └── Styles.xaml             # ⭐ Estilos globais
│   │
│   ├── 📂 Images/
│   │   └── (ícones e imagens)
│   │
│   ├── 📂 Fonts/
│   │   ├── OpenSans-Regular.ttf    # Fonte principal
│   │   └── OpenSans-Bold.ttf
│   │
│   ├── 📂 AppIcon/
│   │   └── appicon.svg             # Ícone do app
│   │
│   ├── 📂 Splash/
│   │   └── splash.svg              # Tela de splash
│   │
│   └── 📂 Raw/
│       └── (arquivos raw)
│
├── 📂 Platforms/                   # 🤖 CÓDIGO ESPECÍFICO DE PLATAFORMA
│   ├── 📂 Android/
│   │   ├── AndroidManifest.xml     # ⭐ Configurações Android
│   │   ├── MainActivity.cs
│   │   └── MainApplication.cs
│   │
│   ├── 📂 iOS/
│   ├── 📂 MacCatalyst/
│   ├── 📂 Tizen/
│   └── 📂 Windows/
│
├── 📂 Properties/
│   └── launchSettings.json         # Configurações de execução
│
├── 📂 bin/                         # Binários compilados
│   └── 📂 Debug/
│   └── 📂 Release/
│       └── 📂 net8.0-android/
│           └── com.sistemachamados.mobile-Signed.apk
│
└── 📂 obj/                         # Arquivos intermediários
    ├── project.assets.json
    └── ...
```

---

## 📋 Arquivos-Chave por Função

### 🎨 **UI/Design** (Arquivos para melhorias visuais)
```
Resources/Styles/Colors.xaml       ← Paleta de cores
Resources/Styles/Styles.xaml       ← Estilos globais
Views/ChamadosListPage.xaml        ← Lista de chamados
Views/ChamadoDetailPage.xaml       ← Detalhes
Views/NovoChamadoPage.xaml         ← Criar chamado
Views/Auth/LoginPage.xaml          ← Login
AppShell.xaml                      ← Navegação
```

### 🧠 **Lógica** (ViewModels)
```
ViewModels/ChamadosListViewModel.cs    ← Filtros, busca, lista
ViewModels/ChamadoDetailViewModel.cs   ← Detalhes e ações
ViewModels/NovoChamadoViewModel.cs     ← Criação com IA
ViewModels/LoginViewModel.cs           ← Autenticação
```

### 🔌 **API** (Serviços)
```
Services/Api/ApiService.cs             ← HttpClient wrapper
Services/Chamados/ChamadosService.cs   ← CRUD de chamados
Services/Auth/AuthService.cs           ← Login/logout
Helpers/Constants.cs                   ← URLs da API
```

### ⚙️ **Configuração**
```
MauiProgram.cs                     ← Registro de dependências
appsettings.json                   ← Configurações
Platforms/Android/AndroidManifest.xml  ← Permissões Android
```

---

## 🏗️ Padrão de Arquitetura: MVVM

```
┌────────────┐         ┌──────────────┐         ┌─────────┐
│    View    │ ◄────── │  ViewModel   │ ◄────── │  Model  │
│   (XAML)   │  Bind   │  (C# Logic)  │  Data   │ (Entity)│
└────────────┘         └──────┬───────┘         └─────────┘
                              │
                              │ Call
                              ▼
                       ┌─────────────┐
                       │   Service   │
                       │ (API calls) │
                       └─────────────┘
```

### **View (XAML)**
- Interface visual
- Data binding `{Binding PropertyName}`
- Command binding `{Binding CommandName}`
- Não contém lógica de negócio

### **ViewModel (C#)**
- `INotifyPropertyChanged` para atualizar UI
- Properties públicas (bound à View)
- Commands (ICommand) para ações
- Chama Services para buscar dados

### **Model (Entities)**
- Estrutura de dados (classes C#)
- Propriedades simples
- Sem lógica de negócio

### **Services**
- Comunicação com API (HttpClient)
- Lógica de negócio compartilhada
- Injetados via Dependency Injection

---

## 📦 Dependências (NuGet Packages)

```xml
<!-- SistemaChamados.Mobile.csproj -->
<ItemGroup>
  <!-- Serialização JSON -->
  <PackageReference Include="Newtonsoft.Json" Version="13.0.3" />
  
  <!-- MAUI Core (já incluso) -->
  <PackageReference Include="Microsoft.Maui.Controls" Version="8.0.0" />
  
  <!-- (Adicionar futuras dependências aqui) -->
</ItemGroup>
```

### Sugestões de Packages Futuros:
- **CommunityToolkit.Maui** - Helpers e controles extras
- **CommunityToolkit.Mvvm** - Source generators para MVVM
- **Refractored.MvvmHelpers** - BaseViewModel melhorado
- **Xamarin.Essentials** (incluído no MAUI) - APIs nativas

---

## 🔀 Fluxo de Dados

### **Exemplo: Carregar Lista de Chamados**

```
1. User abre ChamadosListPage
         ↓
2. Page.OnAppearing() chama ViewModel.LoadChamadosAsync()
         ↓
3. ViewModel chama ChamadosService.GetAllAsync()
         ↓
4. Service chama ApiService.GetAsync<List<Chamado>>()
         ↓
5. ApiService faz HTTP GET para /api/Chamados
         ↓
6. API retorna JSON
         ↓
7. ApiService desserializa para List<Chamado>
         ↓
8. Service retorna para ViewModel
         ↓
9. ViewModel atualiza ObservableCollection<Chamado>
         ↓
10. CollectionView na View atualiza automaticamente (binding)
```

---

## 🚀 Pontos de Entrada

### **Inicialização do App**

1. **MauiProgram.cs** `CreateMauiApp()`
   - Registra serviços (DI)
   - Configura fontes, estilos
   - Retorna MauiApp

2. **App.xaml.cs** `OnStart()`
   - Define MainPage
   - Verifica autenticação
   - Navega para Login ou Dashboard

3. **AppShell.xaml**
   - Define estrutura de navegação
   - Rotas registradas

---

## 📂 Pastas para Melhorias de UI/UX

### **Prioridade Alta** ⭐
- `Views/` - Todas as telas XAML
- `Resources/Styles/` - Colors e Styles
- `AppShell.xaml` - Navegação

### **Prioridade Média**
- `ViewModels/` - Lógica de apresentação
- `Helpers/` - Converters e utilitários

### **Prioridade Baixa**
- `Services/` - Já funcionais
- `Models/` - Estruturas de dados OK

---

## 🎯 Arquivos Mais Importantes

### Top 5 para Melhorias de UX:
1. **ChamadosListPage.xaml** - Lista principal (mais usada)
2. **NovoChamadoPage.xaml** - Formulário de criação
3. **AppShell.xaml** - Estrutura de navegação
4. **Colors.xaml** - Paleta de cores
5. **Styles.xaml** - Estilos globais

---

## 📝 Convenções de Nomenclatura

### **Arquivos XAML**
- `NomeDaTela + Page.xaml` (ex: `LoginPage.xaml`)
- Code-behind: `NomeDaTela + Page.xaml.cs`

### **ViewModels**
- `NomeDaTela + ViewModel.cs` (ex: `LoginViewModel.cs`)
- Herdam de `BaseViewModel`

### **Services**
- Interface: `I + Nome + Service.cs` (ex: `IAuthService.cs`)
- Implementação: `Nome + Service.cs` (ex: `AuthService.cs`)

### **Models**
- Entities: Nome singular (ex: `Chamado.cs`)
- DTOs: `Nome + Dto.cs` (ex: `LoginRequestDto.cs`)

---

**Documento**: 02 - Estrutura do Projeto  
**Data**: 20/10/2025  
**Versão**: 1.0
