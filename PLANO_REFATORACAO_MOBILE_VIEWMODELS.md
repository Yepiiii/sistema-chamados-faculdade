# 🎯 Plano de Refatoração - Mobile ViewModels

**Arquivos:** Mobile ViewModels God Objects  
**Status Atual:** 🟡 **PRÓXIMO NA FILA**  
**Data:** 12/12/2025  
**Estimativa Total:** 12 horas (1.5 dias)

---

## 📊 **God Objects Identificados**

### 1️⃣ **ChamadosListViewModel.cs** (627 linhas)
**Localização:** `Mobile/ViewModels/ChamadosListViewModel.cs`

**Problemas:**
```csharp
ChamadosListViewModel (627 linhas)
├── 4 Services injetados (Chamado, Category, Status, Priority)
├── 8+ ObservableCollections
├── 15+ Commands
├── Lógica de filtros complexa
├── Carregamento de metadata
├── Gerenciamento de UI state
└── 0% testável (dependências concretas)
```

**Responsabilidades Misturadas:**
- ✅ Lista de chamados
- ✅ Filtros avançados (categoria, status, prioridade, busca)
- ✅ Carregamento de metadata (categorias, status, prioridades)
- ✅ Gerenciamento de estado de UI (loading, empty, error)
- ✅ Navegação
- ✅ Pull-to-refresh
- ✅ Ordenação
- ✅ Paginação (se implementada)

---

### 2️⃣ **ChamadoDetailViewModel.cs** (602 linhas)
**Localização:** `Mobile/ViewModels/ChamadoDetailViewModel.cs`

**Problemas:**
```csharp
ChamadoDetailViewModel (602 linhas)
├── 3 Services injetados (Chamado, Auth, IA)
├── 12+ ObservableCollections/Properties
├── 18+ Commands
├── Lógica de comentários
├── Integração com IA
├── Gerenciamento de estado complexo
└── Ações múltiplas (assumir, resolver, fechar, etc)
```

**Responsabilidades Misturadas:**
- ✅ Detalhes do chamado
- ✅ Sistema de comentários completo
- ✅ Análise com IA
- ✅ Ações de ticket (assumir, resolver, fechar, reabrir)
- ✅ Upload de anexos
- ✅ Validações
- ✅ Navegação
- ✅ Estado de UI complexo

---

## 🗺️ **Estratégia de Refatoração**

### **Princípios MVVM + Clean Architecture:**
1. ✅ **Separation of Concerns** - Um ViewModel por tela/feature
2. ✅ **Single Responsibility** - ViewModels focados
3. ✅ **Dependency Injection** - Services via interfaces
4. ✅ **Testable** - ViewModels testáveis com mocks
5. ✅ **Reusable** - Componentes compartilhados

### **Padrão de Arquitetura:**
```
MVVM + Repository Pattern + Service Layer + State Management
```

---

## 📁 **Estrutura Final Proposta**

```
Mobile/
├── ViewModels/
│   ├── Chamados/
│   │   ├── ChamadosListViewModel.cs          # 200 linhas - Lista básica
│   │   ├── ChamadosFilterViewModel.cs        # 150 linhas - Filtros
│   │   ├── ChamadoDetailViewModel.cs         # 200 linhas - Detalhes básicos
│   │   ├── ChamadoActionsViewModel.cs        # 150 linhas - Ações (assumir, resolver, etc)
│   │   └── ChamadoCommentsViewModel.cs       # 120 linhas - Sistema de comentários
│   │
│   ├── Base/
│   │   ├── BaseViewModel.cs                  # 80 linhas - Lógica base
│   │   └── BaseListViewModel.cs              # 100 linhas - Lista genérica
│   │
│   └── Shared/
│       ├── MetadataViewModel.cs              # 80 linhas - Categorias/Status/Prioridades
│       └── IAAnalysisViewModel.cs            # 100 linhas - Integração IA
│
├── Services/
│   ├── State/
│   │   └── AppStateService.cs                # 100 linhas - Estado global
│   │
│   └── Navigation/
│       └── NavigationService.cs              # 80 linhas - Navegação centralizada
│
├── Models/
│   └── ViewModels/
│       ├── ChamadoListItem.cs                # 50 linhas - Item da lista
│       ├── FilterState.cs                    # 60 linhas - Estado dos filtros
│       └── UIState.cs                        # 40 linhas - Estados de UI
│
└── Helpers/
    ├── ViewModelFactory.cs                   # 60 linhas - Factory para VMs
    └── CommandHelper.cs                      # 80 linhas - Commands reutilizáveis
```

**Total:** 13 arquivos (~1.500 linhas, média de 115 linhas/arquivo)

---

## 🔧 **Plano de Execução - 5 Fases**

### ✅ **FASE 1: Infraestrutura Base** (2 horas)

**Objetivo:** Criar classes base e helpers reutilizáveis

#### 1.1. BaseViewModel.cs
```csharp
public abstract class BaseViewModel : INotifyPropertyChanged
{
    // IsBusy, ErrorMessage, Title
    // ShowError(), ShowSuccess()
    // OnPropertyChanged()
    // Dispose pattern
}
```

#### 1.2. BaseListViewModel<T>.cs
```csharp
public abstract class BaseListViewModel<T> : BaseViewModel
{
    // ObservableCollection<T> Items
    // LoadItemsAsync()
    // RefreshCommand
    // IsEmpty, IsLoading
    // Search functionality
}
```

#### 1.3. UIState.cs
```csharp
public class UIState
{
    public bool IsLoading { get; set; }
    public bool HasError { get; set; }
    public string ErrorMessage { get; set; }
    public bool IsEmpty { get; set; }
}
```

#### 1.4. CommandHelper.cs
```csharp
public static class CommandHelper
{
    public static ICommand CreateCommand(Action execute, Func<bool> canExecute = null)
    public static ICommand CreateAsyncCommand(Func<Task> execute, Func<bool> canExecute = null)
    // SafeExecute with error handling
}
```

**Arquivos:** 4  
**Linhas:** ~290  
**Tempo:** 2 horas

---

### ✅ **FASE 2: Services Compartilhados** (1.5 horas)

**Objetivo:** Extrair lógica compartilhada em services

#### 2.1. MetadataService.cs (ou ViewModel)
```csharp
public class MetadataService
{
    private readonly ICategoryService _categoryService;
    private readonly IStatusService _statusService;
    private readonly IPriorityService _priorityService;
    
    public async Task<MetadataCollection> LoadAllMetadataAsync()
    {
        // Carrega categorias, status, prioridades em paralelo
        // Cache em memória
    }
}
```

#### 2.2. AppStateService.cs
```csharp
public class AppStateService
{
    // Estado global da aplicação
    // Filtros ativos
    // Usuário atual
    // Notificações
    public event EventHandler<StateChangedEventArgs> StateChanged;
}
```

#### 2.3. NavigationService.cs
```csharp
public interface INavigationService
{
    Task NavigateToAsync<TViewModel>(object parameter = null);
    Task GoBackAsync();
}
```

**Arquivos:** 3  
**Linhas:** ~260  
**Tempo:** 1.5 horas

---

### ✅ **FASE 3: Refatorar ChamadosListViewModel** (4 horas)

**Objetivo:** Dividir ViewModel de 627 linhas em 2 ViewModels focados

#### 3.1. Novo ChamadosListViewModel.cs (200 linhas)
**Responsabilidade:** Lista básica de chamados

```csharp
public class ChamadosListViewModel : BaseListViewModel<ChamadoListItem>
{
    private readonly IChamadoService _chamadoService;
    private readonly INavigationService _navigationService;
    private readonly ChamadosFilterViewModel _filterViewModel;
    
    public ChamadosListViewModel(...)
    {
        _filterViewModel = new ChamadosFilterViewModel();
        _filterViewModel.FilterChanged += OnFilterChanged;
    }
    
    // ObservableCollection<ChamadoListItem> Items - herdado
    // ICommand RefreshCommand - herdado
    // ICommand ItemTappedCommand
    // ICommand NewChamadoCommand
    
    protected override async Task LoadItemsAsync()
    {
        var filters = _filterViewModel.GetCurrentFilters();
        var chamados = await _chamadoService.GetAllAsync(filters);
        Items = new ObservableCollection<ChamadoListItem>(chamados);
    }
    
    private async Task OnItemTapped(ChamadoListItem item)
    {
        await _navigationService.NavigateToAsync<ChamadoDetailViewModel>(item.Id);
    }
}
```

**Features:**
- ✅ Lista de chamados
- ✅ Refresh
- ✅ Navegação para detalhes
- ✅ Novo chamado
- ✅ Search básico
- ✅ Pull-to-refresh

#### 3.2. ChamadosFilterViewModel.cs (150 linhas)
**Responsabilidade:** Gerenciar filtros

```csharp
public class ChamadosFilterViewModel : BaseViewModel
{
    private readonly MetadataService _metadataService;
    
    // ObservableCollections
    public ObservableCollection<Category> Categories { get; }
    public ObservableCollection<Status> Statuses { get; }
    public ObservableCollection<Priority> Priorities { get; }
    
    // Selected items
    public Category SelectedCategory { get; set; }
    public Status SelectedStatus { get; set; }
    public Priority SelectedPriority { get; set; }
    public string SearchText { get; set; }
    
    // Commands
    public ICommand ApplyFiltersCommand { get; }
    public ICommand ClearFiltersCommand { get; }
    
    // Events
    public event EventHandler<FilterChangedEventArgs> FilterChanged;
    
    public FilterDto GetCurrentFilters()
    {
        return new FilterDto
        {
            CategoriaId = SelectedCategory?.Id,
            StatusId = SelectedStatus?.Id,
            PrioridadeId = SelectedPriority?.Id,
            SearchTerm = SearchText
        };
    }
}
```

**Features:**
- ✅ Carregamento de metadata
- ✅ Seleção de filtros
- ✅ Aplicar filtros
- ✅ Limpar filtros
- ✅ Busca textual
- ✅ Evento de mudança

**Arquivos:** 2  
**Linhas:** ~350  
**Tempo:** 4 horas

---

### ✅ **FASE 4: Refatorar ChamadoDetailViewModel** (4 horas)

**Objetivo:** Dividir ViewModel de 602 linhas em 3 ViewModels focados

#### 4.1. Novo ChamadoDetailViewModel.cs (200 linhas)
**Responsabilidade:** Exibir detalhes do chamado

```csharp
public class ChamadoDetailViewModel : BaseViewModel
{
    private readonly IChamadoService _chamadoService;
    private readonly ChamadoActionsViewModel _actionsViewModel;
    private readonly ChamadoCommentsViewModel _commentsViewModel;
    
    public Chamado Chamado { get; private set; }
    
    // Basic properties
    public string Titulo => Chamado?.Titulo;
    public string Descricao => Chamado?.Descricao;
    public Category Categoria => Chamado?.Categoria;
    public Status Status => Chamado?.Status;
    public Priority Prioridade => Chamado?.Prioridade;
    
    // Sub ViewModels
    public ChamadoActionsViewModel Actions => _actionsViewModel;
    public ChamadoCommentsViewModel Comments => _commentsViewModel;
    
    // Commands
    public ICommand RefreshCommand { get; }
    public ICommand ShareCommand { get; }
    
    public async Task LoadChamadoAsync(int chamadoId)
    {
        IsBusy = true;
        try
        {
            Chamado = await _chamadoService.GetByIdAsync(chamadoId);
            await _commentsViewModel.LoadCommentsAsync(chamadoId);
            _actionsViewModel.SetChamado(Chamado);
        }
        finally
        {
            IsBusy = false;
        }
    }
}
```

**Features:**
- ✅ Carregar detalhes
- ✅ Refresh
- ✅ Share
- ✅ Delegar ações para sub-VM
- ✅ Delegar comentários para sub-VM

#### 4.2. ChamadoActionsViewModel.cs (150 linhas)
**Responsabilidade:** Ações sobre o chamado

```csharp
public class ChamadoActionsViewModel : BaseViewModel
{
    private readonly IChamadoService _chamadoService;
    private readonly IAuthService _authService;
    private Chamado _chamado;
    
    // Visibility properties
    public bool CanAssume => _chamado?.TecnicoId == null && IsTecnico;
    public bool CanResolve => _chamado?.StatusId != StatusIds.Resolvido && IsOwnerOrTecnico;
    public bool CanClose => _chamado?.StatusId == StatusIds.Resolvido && IsAdmin;
    public bool CanReopen => _chamado?.StatusId == StatusIds.Fechado && IsAdmin;
    
    // Commands
    public ICommand AssumeCommand { get; }
    public ICommand ResolveCommand { get; }
    public ICommand CloseCommand { get; }
    public ICommand ReopenCommand { get; }
    public ICommand AnalyzeWithAICommand { get; }
    
    public void SetChamado(Chamado chamado)
    {
        _chamado = chamado;
        OnPropertyChanged(nameof(CanAssume));
        OnPropertyChanged(nameof(CanResolve));
        // ... etc
    }
    
    private async Task AssumeAsync()
    {
        await _chamadoService.AssumeAsync(_chamado.Id);
        OnActionCompleted?.Invoke(this, EventArgs.Empty);
    }
    
    public event EventHandler OnActionCompleted;
}
```

**Features:**
- ✅ Assumir chamado
- ✅ Resolver
- ✅ Fechar
- ✅ Reabrir
- ✅ Análise com IA
- ✅ Validações de permissão
- ✅ Evento de conclusão

#### 4.3. ChamadoCommentsViewModel.cs (120 linhas)
**Responsabilidade:** Sistema de comentários

```csharp
public class ChamadoCommentsViewModel : BaseListViewModel<Comment>
{
    private readonly IChamadoService _chamadoService;
    private int _chamadoId;
    
    public string NewCommentText { get; set; }
    
    // Commands
    public ICommand AddCommentCommand { get; }
    
    public async Task LoadCommentsAsync(int chamadoId)
    {
        _chamadoId = chamadoId;
        await LoadItemsAsync();
    }
    
    protected override async Task LoadItemsAsync()
    {
        var comments = await _chamadoService.GetCommentsAsync(_chamadoId);
        Items = new ObservableCollection<Comment>(comments);
    }
    
    private async Task AddCommentAsync()
    {
        if (string.IsNullOrWhiteSpace(NewCommentText))
            return;
            
        await _chamadoService.AddCommentAsync(_chamadoId, NewCommentText);
        NewCommentText = string.Empty;
        await LoadItemsAsync();
    }
}
```

**Features:**
- ✅ Carregar comentários
- ✅ Adicionar comentário
- ✅ Refresh
- ✅ Empty state

**Arquivos:** 3  
**Linhas:** ~470  
**Tempo:** 4 horas

---

### ✅ **FASE 5: Integração e Testes** (0.5 horas)

**Objetivo:** Integrar ViewModels e garantir funcionalidade

#### 5.1. Atualizar Views
```xml
<!-- ChamadosListPage.xaml -->
<ContentPage.BindingContext>
    <viewModels:ChamadosListViewModel />
</ContentPage.BindingContext>

<!-- Filtros em um expander ou modal -->
<ContentView BindingContext="{Binding FilterViewModel}">
    <Picker ItemsSource="{Binding Categories}" ... />
    <!-- ... -->
</ContentView>
```

#### 5.2. Atualizar Dependency Injection
```csharp
// MauiProgram.cs
services.AddTransient<ChamadosListViewModel>();
services.AddTransient<ChamadosFilterViewModel>();
services.AddTransient<ChamadoDetailViewModel>();
services.AddTransient<ChamadoActionsViewModel>();
services.AddTransient<ChamadoCommentsViewModel>();

services.AddSingleton<MetadataService>();
services.AddSingleton<AppStateService>();
services.AddSingleton<INavigationService, NavigationService>();
```

#### 5.3. Testes Unitários (opcional nesta fase)
```csharp
[Fact]
public async Task LoadItemsAsync_ShouldLoadChamados()
{
    // Arrange
    var mockService = new Mock<IChamadoService>();
    mockService.Setup(s => s.GetAllAsync(It.IsAny<FilterDto>()))
               .ReturnsAsync(new List<Chamado> { /* ... */ });
    
    var vm = new ChamadosListViewModel(mockService.Object, ...);
    
    // Act
    await vm.LoadItemsAsync();
    
    // Assert
    Assert.NotEmpty(vm.Items);
}
```

**Tempo:** 0.5 horas

---

## 📊 **Resumo da Refatoração**

### Antes vs Depois

| Métrica | Antes | Depois | Melhoria |
|---------|-------|--------|----------|
| **Arquivos** | 2 | 13 | +550% modularização |
| **Linhas/Arquivo** | ~614 | ~115 | -81% complexidade |
| **Responsabilidades/VM** | 4-8 | 1-2 | -75% |
| **Dependências/VM** | 3-4 | 1-2 | -50% |
| **Testabilidade** | 0% | 90% | +90% |
| **Reusabilidade** | Baixa | Alta | +80% |

### Arquivos Criados

**Base (4 arquivos - 290 linhas):**
- BaseViewModel.cs (80)
- BaseListViewModel.cs (100)
- UIState.cs (40)
- CommandHelper.cs (70)

**Services (3 arquivos - 260 linhas):**
- MetadataService.cs (80)
- AppStateService.cs (100)
- NavigationService.cs (80)

**ViewModels (5 arquivos - 820 linhas):**
- ChamadosListViewModel.cs (200)
- ChamadosFilterViewModel.cs (150)
- ChamadoDetailViewModel.cs (200)
- ChamadoActionsViewModel.cs (150)
- ChamadoCommentsViewModel.cs (120)

**Models (1 arquivo - 130 linhas):**
- ViewModelModels.cs (ChamadoListItem, FilterDto, etc)

**Total:** 13 arquivos (~1.500 linhas)  
**Original:** 2 arquivos (~1.229 linhas)  
**Crescimento:** +22% em LOC, +550% em arquivos, -81% complexidade/arquivo

---

## 🎯 **Benefícios da Refatoração**

### 1. **Testabilidade**
```csharp
// Antes: Impossível testar
public class ChamadosListViewModel
{
    private readonly ChamadoService _service = new ChamadoService(); // ❌ Dependência concreta
}

// Depois: 100% testável
public class ChamadosListViewModel
{
    private readonly IChamadoService _service; // ✅ Interface
    
    public ChamadosListViewModel(IChamadoService service)
    {
        _service = service;
    }
}
```

### 2. **Reusabilidade**
```csharp
// BaseListViewModel pode ser usado para:
- ChamadosListViewModel
- UsuariosListViewModel
- CategoriasListViewModel
// ... qualquer lista!
```

### 3. **Manutenibilidade**
- Arquivo de 200 linhas é 3x mais fácil de entender que 600 linhas
- Single Responsibility = mudanças isoladas
- Menos bugs ao modificar

### 4. **Composição**
```csharp
// DetailViewModel compõe sub-ViewModels
public class ChamadoDetailViewModel
{
    public ChamadoActionsViewModel Actions { get; }
    public ChamadoCommentsViewModel Comments { get; }
}
```

---

## 📈 **Cronograma**

| Fase | Descrição | Tempo | Acumulado |
|------|-----------|-------|-----------|
| 1 | Infraestrutura Base | 2h | 2h |
| 2 | Services Compartilhados | 1.5h | 3.5h |
| 3 | Refatorar ChamadosListVM | 4h | 7.5h |
| 4 | Refatorar ChamadoDetailVM | 4h | 11.5h |
| 5 | Integração e Testes | 0.5h | **12h** |

**Total:** 12 horas (1.5 dias full-time)

---

## ✅ **Checklist de Execução**

### Fase 1: Base
- [ ] Criar BaseViewModel.cs
- [ ] Criar BaseListViewModel.cs
- [ ] Criar UIState.cs
- [ ] Criar CommandHelper.cs
- [ ] Testar base classes

### Fase 2: Services
- [ ] Criar MetadataService.cs
- [ ] Criar AppStateService.cs
- [ ] Criar NavigationService.cs
- [ ] Registrar no DI

### Fase 3: ChamadosList
- [ ] Criar novo ChamadosListViewModel.cs
- [ ] Criar ChamadosFilterViewModel.cs
- [ ] Atualizar ChamadosListPage.xaml
- [ ] Testar lista e filtros
- [ ] Remover código antigo

### Fase 4: ChamadoDetail
- [ ] Criar novo ChamadoDetailViewModel.cs
- [ ] Criar ChamadoActionsViewModel.cs
- [ ] Criar ChamadoCommentsViewModel.cs
- [ ] Atualizar ChamadoDetailPage.xaml
- [ ] Testar todas as ações
- [ ] Remover código antigo

### Fase 5: Integração
- [ ] Atualizar todas as Views
- [ ] Atualizar DI container
- [ ] Testar fluxo completo
- [ ] Criar testes unitários básicos
- [ ] Documentar mudanças

---

## 🚀 **Próximos Passos Após Conclusão**

1. **Adicionar Testes Unitários**
   - Cada ViewModel deve ter 80%+ cobertura
   - Mock de services
   - Testes de Commands

2. **Refatorar Outros ViewModels**
   - NovoUsuarioViewModel
   - ConfiguracoesViewModel
   - etc.

3. **Implementar State Management**
   - Considerar Redux/Flux pattern
   - Ou usar ReactiveUI para programação reativa

4. **Code Review**
   - Validar arquitetura
   - Verificar performance
   - Garantir patterns consistentes

---

## 📚 **Referências**

- [MVVM Pattern](https://docs.microsoft.com/en-us/xamarin/xamarin-forms/enterprise-application-patterns/mvvm)
- [Dependency Injection in .NET MAUI](https://docs.microsoft.com/en-us/dotnet/maui/fundamentals/dependency-injection)
- [Unit Testing ViewModels](https://docs.microsoft.com/en-us/xamarin/xamarin-forms/enterprise-application-patterns/unit-testing)

---

**Status:** 🟡 AGUARDANDO EXECUÇÃO  
**Prioridade:** ALTA (após script-desktop.js)  
**Complexidade:** MÉDIA  
**Risco:** BAIXO (impacto isolado no Mobile)
