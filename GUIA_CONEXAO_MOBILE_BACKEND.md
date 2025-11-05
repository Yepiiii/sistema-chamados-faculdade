# 📱 Guia Completo: Como o Mobile Visualiza o Backend

## 🎯 Visão Geral

O aplicativo mobile **SistemaChamados.Mobile** se comunica com a API backend através de requisições HTTP REST. Este guia explica **como funciona todo o processo** desde o clique na tela até os dados aparecerem.

---

## 🔧 1. CONFIGURAÇÃO DA CONEXÃO

### 1.1 URLs de Conexão

O mobile precisa saber **onde encontrar o backend**. Existem **3 cenários**:

```csharp
// Arquivo: SistemaChamados.Mobile/Helpers/Constants.cs

public static class Constants
{
    // 🖥️ CENÁRIO 1: Rodando no Windows (ou emulador iOS)
    public static string BaseUrlWindows => "http://localhost:5246/api/";
    
    // 📱 CENÁRIO 2: Emulador Android
    // 10.0.2.2 = "localhost" do computador host
    public static string BaseUrlAndroidEmulator => "http://10.0.2.2:5246/api/";
    
    // 📲 CENÁRIO 3: Celular físico Android
    // IP real da sua máquina na rede Wi-Fi
    public static string BaseUrlPhysicalDevice => "http://192.168.1.132:5246/api/";
    
    // ⚙️ Seleciona automaticamente baseado na plataforma
    public static string BaseUrl
    {
        get
        {
#if ANDROID
            return BaseUrlPhysicalDevice; // ← Configurado para dispositivo físico
#elif WINDOWS
            return BaseUrlWindows;
#else
            return BaseUrlWindows;
#endif
        }
    }
}
```

### 📝 **Como Descobrir Seu IP Local:**

```powershell
# No Windows PowerShell:
ipconfig

# Procure por "IPv4 Address" na seção da sua rede Wi-Fi
# Exemplo: 192.168.1.132
```

**⚠️ IMPORTANTE:** Se você mudar de rede Wi-Fi, precisa atualizar o IP em `Constants.cs`!

---

## 🌐 2. ARQUITETURA DE COMUNICAÇÃO

```
┌────────────────────────────────────────────────────────────────┐
│                    FLUXO COMPLETO DE DADOS                     │
└────────────────────────────────────────────────────────────────┘

[1] USUÁRIO ABRE APP
    👆 Toque na tela
    ↓
[2] VIEW (ChamadosListPage.xaml)
    📄 Interface visual
    ↓ OnAppearing()
    
[3] VIEWMODEL (ChamadosListViewModel.cs)
    🧠 Lógica de apresentação
    ↓ await Load()
    
[4] SERVICE (ChamadoService.cs)
    🔧 Lógica de negócio
    ↓ await GetAllAsync()
    
[5] API SERVICE (ApiService.cs)
    🌐 Cliente HTTP
    ↓ GET http://192.168.1.132:5246/api/chamados
    
[6] BACKEND (.NET API)
    ⚙️ Servidor
    ↓ ChamadosController.cs
    
[7] BANCO DE DADOS
    🗄️ SQL Server
    ↓ SELECT * FROM Chamados
    
[8] RESPOSTA JSON
    📦 { "$values": [...] }
    ↓
[9] DESERIALIZAÇÃO
    🔄 JSON → ChamadoDto (objeto C#)
    ↓
[10] ATUALIZAÇÃO DA TELA
    ✨ Lista de chamados aparece!
```

---

## 📂 3. ESTRUTURA DE CÓDIGO (Camadas)

### Camada 1️⃣: **VIEW** (Interface Visual)

**Arquivo:** `Views/ChamadosListPage.xaml`

```xml
<!-- Quando a página aparece, chama o ViewModel -->
<ContentPage>
    <RefreshView IsRefreshing="{Binding IsRefreshing}"
                 Command="{Binding RefreshCommand}">
        
        <!-- Lista de chamados -->
        <CollectionView ItemsSource="{Binding Chamados}">
            <CollectionView.ItemTemplate>
                <DataTemplate>
                    <!-- Card de cada chamado -->
                    <Border>
                        <Label Text="{Binding Titulo}" />
                        <Label Text="{Binding Status.Nome}" />
                    </Border>
                </DataTemplate>
            </CollectionView.ItemTemplate>
        </CollectionView>
        
    </RefreshView>
</ContentPage>
```

**Code-behind:** `Views/ChamadosListPage.xaml.cs`

```csharp
public partial class ChamadosListPage : ContentPage
{
    private readonly ChamadosListViewModel _vm;

    public ChamadosListPage(ChamadosListViewModel vm)
    {
        InitializeComponent();
        _vm = vm;
        BindingContext = _vm; // Conecta View ao ViewModel
    }

    protected override void OnAppearing()
    {
        base.OnAppearing();
        _ = _vm.Load(); // ← INICIA O PROCESSO DE BUSCAR DADOS!
    }
}
```

---

### Camada 2️⃣: **VIEWMODEL** (Lógica de Apresentação)

**Arquivo:** `ViewModels/ChamadosListViewModel.cs`

```csharp
public class ChamadosListViewModel : BaseViewModel
{
    private readonly IChamadoService _chamadoService; // ← Injeta o serviço
    
    // Lista que aparece na tela (Observable = notifica mudanças)
    public ObservableCollection<ChamadoDto> Chamados { get; } = new();
    
    public ChamadosListViewModel(IChamadoService chamadoService)
    {
        _chamadoService = chamadoService;
    }
    
    // Método chamado quando a página aparece
    public async Task Load()
    {
        if (IsBusy) return; // Evita múltiplas chamadas
        
        IsBusy = true; // Mostra loading
        
        try
        {
            // 🌐 AQUI É ONDE CHAMA A API!
            var chamados = await _chamadoService.GetAllAsync();
            
            // Limpa e adiciona na lista
            _allChamados.Clear();
            foreach (var chamado in chamados ?? Enumerable.Empty<ChamadoDto>())
            {
                _allChamados.Add(chamado);
            }
            
            // Aplica filtros e atualiza a tela
            ApplyFilters();
        }
        catch (ApiException ex)
        {
            // Mostra erro na tela
            await Application.Current.MainPage.DisplayAlert("Erro", ex.Message, "OK");
        }
        finally
        {
            IsBusy = false; // Esconde loading
        }
    }
}
```

---

### Camada 3️⃣: **SERVICE** (Lógica de Negócio)

**Arquivo:** `Services/Chamados/ChamadoService.cs`

```csharp
public class ChamadoService : IChamadoService
{
    private readonly IApiService _api; // ← Cliente HTTP
    
    public ChamadoService(IApiService api)
    {
        _api = api;
    }
    
    // Busca todos os chamados
    public Task<IEnumerable<ChamadoDto>?> GetAllAsync(
        int? statusId = null,
        int? prioridadeId = null,
        int? categoriaId = null)
    {
        // Monta a URL com query params
        var queryParams = new List<string>();
        
        if (statusId.HasValue)
            queryParams.Add($"statusId={statusId.Value}");
            
        if (prioridadeId.HasValue)
            queryParams.Add($"prioridadeId={prioridadeId.Value}");
            
        if (categoriaId.HasValue)
            queryParams.Add($"categoriaId={categoriaId.Value}");
        
        var query = queryParams.Any() ? "?" + string.Join("&", queryParams) : "";
        var endpoint = $"chamados{query}";
        
        // 🌐 FAZ A REQUISIÇÃO HTTP!
        return _api.GetAsync<IEnumerable<ChamadoDto>>(endpoint);
    }
    
    // Busca um chamado específico por ID
    public Task<ChamadoDto?> GetByIdAsync(int id)
    {
        return _api.GetAsync<ChamadoDto>($"chamados/{id}");
    }
}
```

---

### Camada 4️⃣: **API SERVICE** (Cliente HTTP)

**Arquivo:** `Services/Api/ApiService.cs`

```csharp
public class ApiService : IApiService
{
    private readonly HttpClient _client;

    public ApiService(HttpClient client)
    {
        _client = client;
        _client.BaseAddress = new Uri(Constants.BaseUrl); // ← URL configurada!
        _client.Timeout = TimeSpan.FromSeconds(60);
    }
    
    // Adiciona token JWT no cabeçalho (após login)
    public void AddAuthorizationHeader(string token)
    {
        if (string.IsNullOrEmpty(token)) return;
        
        _client.DefaultRequestHeaders.Authorization = 
            new AuthenticationHeaderValue("Bearer", token);
    }
    
    // Faz requisição GET genérica
    public async Task<T?> GetAsync<T>(string uri)
    {
        Debug.WriteLine($"[ApiService] GET {uri}");
        
        try
        {
            // 🌐 REQUISIÇÃO HTTP!
            // URL completa: http://192.168.1.132:5246/api/chamados
            var response = await _client.GetAsync(uri);
            
            Debug.WriteLine($"[ApiService] Status: {response.StatusCode}");
            
            // Verifica se deu erro
            if (!response.IsSuccessStatusCode)
            {
                HandleError(response, content);
            }
            
            // Lê o JSON
            var content = await response.Content.ReadAsStringAsync();
            Debug.WriteLine($"[ApiService] Response: {content}");
            
            // Desembrulha $values se necessário
            if (content.Contains("\"$values\""))
            {
                var jo = JObject.Parse(content);
                var values = jo["$values"];
                if (values != null)
                {
                    content = values.ToString();
                }
            }
            
            // 🔄 CONVERTE JSON → OBJETO C#
            var settings = new JsonSerializerSettings 
            { 
                ReferenceLoopHandling = ReferenceLoopHandling.Ignore,
                MetadataPropertyHandling = MetadataPropertyHandling.Ignore
            };
            
            var result = JsonConvert.DeserializeObject<T>(content, settings);
            
            return result;
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"[ApiService] ERROR: {ex.Message}");
            throw new ApiException(HttpStatusCode.InternalServerError, ex.Message);
        }
    }
    
    // POST, PUT, DELETE seguem lógica similar...
}
```

---

## 🔐 4. AUTENTICAÇÃO (Login)

### Como o Token JWT Funciona:

```csharp
// 1. Usuário faz login
var loginRequest = new LoginRequestDto 
{ 
    Email = "usuario@email.com", 
    Senha = "senha123" 
};

// 2. Envia para API
var response = await _api.PostAsync<LoginRequestDto, LoginResponseDto>(
    "usuarios/login", 
    loginRequest
);

// 3. API retorna token
// response.Token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

// 4. Salva token localmente
Settings.AuthToken = response.Token;
Settings.NomeUsuario = response.NomeCompleto;
Settings.EmailUsuario = response.Email;

// 5. Adiciona token em TODAS as próximas requisições
_api.AddAuthorizationHeader(response.Token);

// 6. Agora TODAS as chamadas HTTP incluem o header:
// Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Arquivo de Configurações:** `Helpers/Settings.cs`

```csharp
public static class Settings
{
    // Usa Preferences (storage nativo da plataforma)
    public static string AuthToken
    {
        get => Preferences.Get(nameof(AuthToken), string.Empty);
        set => Preferences.Set(nameof(AuthToken), value);
    }
    
    public static string NomeUsuario
    {
        get => Preferences.Get(nameof(NomeUsuario), string.Empty);
        set => Preferences.Set(nameof(NomeUsuario), value);
    }
}
```

---

## 📦 5. EXEMPLO COMPLETO: Listagem de Chamados

### Passo a Passo com Código Real:

#### **PASSO 1:** Usuário abre app e navega para lista de chamados

```csharp
// App.xaml.cs
public partial class App : Application
{
    public App()
    {
        InitializeComponent();
        MainPage = new AppShell(); // Shell gerencia navegação
    }
}
```

#### **PASSO 2:** Página aparece na tela

```csharp
// Views/ChamadosListPage.xaml.cs
protected override void OnAppearing()
{
    base.OnAppearing();
    _ = _vm.Load(); // ← TRIGGER AQUI!
}
```

#### **PASSO 3:** ViewModel busca dados

```csharp
// ViewModels/ChamadosListViewModel.cs
public async Task Load()
{
    IsBusy = true; // Mostra spinner
    
    // 🌐 CHAMA SERVICE
    var chamados = await _chamadoService.GetAllAsync(
        statusId: SelectedStatus?.Id,
        prioridadeId: SelectedPrioridade?.Id,
        categoriaId: SelectedCategoria?.Id
    );
    
    // Atualiza lista
    _allChamados.Clear();
    foreach (var c in chamados ?? [])
    {
        _allChamados.Add(c);
    }
    
    ApplyFilters(); // Filtra e mostra na tela
    IsBusy = false; // Esconde spinner
}
```

#### **PASSO 4:** Service monta URL e chama API

```csharp
// Services/Chamados/ChamadoService.cs
public Task<IEnumerable<ChamadoDto>?> GetAllAsync(
    int? statusId = null,
    int? prioridadeId = null,
    int? categoriaId = null)
{
    // Monta query string
    var query = "";
    if (statusId.HasValue)
        query += $"?statusId={statusId}";
    
    // Endpoint final: "chamados?statusId=2"
    var endpoint = $"chamados{query}";
    
    // 🌐 REQUISIÇÃO HTTP
    return _api.GetAsync<IEnumerable<ChamadoDto>>(endpoint);
}
```

#### **PASSO 5:** ApiService faz requisição HTTP

```csharp
// Services/Api/ApiService.cs
public async Task<T?> GetAsync<T>(string uri)
{
    // URL COMPLETA:
    // http://192.168.1.132:5246/api/chamados?statusId=2
    
    Debug.WriteLine($"[ApiService] GET {_client.BaseAddress}{uri}");
    
    var response = await _client.GetAsync(uri);
    
    // Status: 200 OK
    var json = await response.Content.ReadAsStringAsync();
    
    // JSON recebido:
    // {
    //   "$id": "1",
    //   "$values": [
    //     {
    //       "id": 1,
    //       "titulo": "Impressora não funciona",
    //       "status": { "id": 2, "nome": "Em Andamento" },
    //       ...
    //     },
    //     ...
    //   ]
    // }
    
    // Desembrulha $values
    var unwrapped = JObject.Parse(json)["$values"].ToString();
    
    // Deserializa para C#
    return JsonConvert.DeserializeObject<T>(unwrapped);
}
```

#### **PASSO 6:** Backend processa

```csharp
// API/Controllers/ChamadosController.cs
[HttpGet]
public async Task<ActionResult<IEnumerable<ChamadoDto>>> GetChamados(
    [FromQuery] int? statusId = null)
{
    // Busca do banco
    var query = _context.Chamados
        .Include(c => c.Status)
        .Include(c => c.Prioridade)
        .Include(c => c.Categoria)
        .Include(c => c.Solicitante)
        .Include(c => c.Tecnico)
        .AsQueryable();
    
    if (statusId.HasValue)
        query = query.Where(c => c.StatusId == statusId);
    
    var chamados = await query.ToListAsync();
    
    // Mapeia para DTO
    var dtos = chamados.Select(MapToDto).ToList();
    
    return Ok(dtos); // Retorna JSON
}
```

#### **PASSO 7:** Dados voltam para mobile

```csharp
// ViewModels/ChamadosListViewModel.cs
private void ApplyFilters()
{
    Chamados.Clear();
    
    var filtered = _allChamados.AsEnumerable();
    
    // Filtra por busca de texto
    if (!string.IsNullOrWhiteSpace(SearchTerm))
    {
        filtered = filtered.Where(c =>
            c.Titulo.Contains(SearchTerm, StringComparison.OrdinalIgnoreCase) ||
            c.Descricao.Contains(SearchTerm, StringComparison.OrdinalIgnoreCase)
        );
    }
    
    // Adiciona na ObservableCollection
    foreach (var chamado in filtered)
    {
        Chamados.Add(chamado); // ← ATUALIZA A TELA AUTOMATICAMENTE!
    }
}
```

#### **PASSO 8:** Interface atualiza automaticamente

```xml
<!-- Views/ChamadosListPage.xaml -->
<!-- CollectionView está vinculado a Chamados via Binding -->
<CollectionView ItemsSource="{Binding Chamados}">
    <CollectionView.ItemTemplate>
        <DataTemplate>
            <Border>
                <!-- Quando Chamados.Add() é chamado, -->
                <!-- este card aparece automaticamente! -->
                <Grid>
                    <Label Text="{Binding Titulo}" FontSize="16" />
                    <Label Text="{Binding Status.Nome}" />
                </Grid>
            </Border>
        </DataTemplate>
    </CollectionView.ItemTemplate>
</CollectionView>

<!-- ✨ MÁGICA DO DATA BINDING! -->
```

---

## 🔍 6. DEBUGGING: Como Ver o Que Está Acontecendo

### Logs no Código:

```csharp
// Todo ApiService tem logs:
Debug.WriteLine($"[ApiService] GET {uri}");
Debug.WriteLine($"[ApiService] Status: {response.StatusCode}");
Debug.WriteLine($"[ApiService] Response: {content}");

// ViewModels também logam:
System.Diagnostics.Debug.WriteLine("ChamadosListViewModel.Load() - FIRED");
System.Diagnostics.Debug.WriteLine($"Loaded {chamados.Count()} chamados");
```

### Ver Logs no Visual Studio:

1. **Janela de Saída** (Output Window)
   - Menu: `View > Output`
   - Selecione: `Debug` no dropdown

2. **Breakpoints**
   - Clique na margem esquerda do código
   - Execute app em modo Debug (F5)
   - Programa pausa quando chegar no breakpoint

3. **Inspecionar Variáveis**
   - Passe o mouse sobre variáveis
   - Janela `Locals` mostra todas as variáveis
   - Janela `Watch` para monitorar específicas

---

## ⚙️ 7. CONFIGURANDO SEU AMBIENTE

### Checklist para Testar no Celular Físico:

#### ✅ **1. Backend rodando:**

```powershell
# Na pasta do backend:
cd C:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade
dotnet run

# Deve mostrar:
# Now listening on: http://localhost:5246
```

#### ✅ **2. Descubra seu IP local:**

```powershell
ipconfig

# Procure por algo como:
# IPv4 Address. . . . . . . . . . . : 192.168.1.132
```

#### ✅ **3. Atualize Constants.cs:**

```csharp
// SistemaChamados.Mobile/Helpers/Constants.cs
public static string BaseUrlPhysicalDevice => "http://192.168.1.132:5246/api/";
//                                                      ^^^ SEU IP AQUI ^^^
```

#### ✅ **4. Firewall liberado:**

```powershell
# Windows Firewall deve permitir conexões na porta 5246
# Teste no navegador do celular:
# http://192.168.1.132:5246/api/status

# Se abrir uma lista JSON, está funcionando!
```

#### ✅ **5. Compile e instale o APK:**

```powershell
cd SistemaChamados.Mobile
dotnet publish -f net8.0-android -c Release

# APK gerado em:
# bin\Release\net8.0-android\publish\com.sistemachamados.mobile-Signed.apk
```

#### ✅ **6. Instale no celular:**

```powershell
# Via ADB (Android Debug Bridge):
adb install bin\Release\net8.0-android\publish\com.sistemachamados.mobile-Signed.apk

# Ou copie o APK para o celular e instale manualmente
```

---

## 🚨 8. PROBLEMAS COMUNS E SOLUÇÕES

### ❌ "Erro ao conectar com o servidor"

**Causa:** Mobile não consegue acessar o backend.

**Soluções:**

1. **Backend está rodando?**
   ```powershell
   dotnet run
   ```

2. **IP correto em Constants.cs?**
   ```csharp
   // Confira se o IP está certo:
   public static string BaseUrlPhysicalDevice => "http://SEU_IP:5246/api/";
   ```

3. **Celular e PC na mesma rede Wi-Fi?**
   - Ambos precisam estar na mesma rede

4. **Firewall bloqueando?**
   - Teste no navegador do celular: `http://SEU_IP:5246/api/status`

---

### ❌ "Sessão expirada. Faça login novamente."

**Causa:** Token JWT expirou (geralmente após 24 horas).

**Solução:**
- Faça login novamente
- Token é salvo em `Settings.AuthToken` automaticamente

---

### ❌ "A resposta da API veio vazia"

**Causa:** API retornou JSON inválido ou vazio.

**Solução:**

1. Verifique logs do backend
2. Teste endpoint no Postman/Insomnia
3. Veja logs do `ApiService`:
   ```
   [ApiService] Response: { ... }
   ```

---

### ❌ "JSON deserialization error"

**Causa:** Estrutura do JSON não corresponde ao DTO C#.

**Solução:**

1. Compare JSON recebido com o DTO:
   ```csharp
   // DTO espera:
   public class ChamadoDto {
       public int Id { get; set; }
       public string Titulo { get; set; }
   }
   
   // JSON precisa ter:
   { "id": 1, "titulo": "..." }
   // OU
   { "Id": 1, "Titulo": "..." } // PascalCase também funciona
   ```

2. Verifique se há `$values` no JSON (auto-desembrulhado)

---

## 📚 9. RESUMO DA ARQUITETURA

```
┌─────────────────────────────────────────────────────────────┐
│                    CAMADAS DO MOBILE                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [VIEW]           ChamadosListPage.xaml                    │
│  Interface        ↕ Data Binding                           │
│                                                             │
│  [VIEWMODEL]      ChamadosListViewModel.cs                 │
│  Lógica UI        ObservableCollection<ChamadoDto>         │
│                   ↕ Dependency Injection                   │
│                                                             │
│  [SERVICE]        ChamadoService.cs                        │
│  Lógica Negócio   GetAllAsync(), GetByIdAsync()           │
│                   ↕ Abstração HTTP                         │
│                                                             │
│  [API SERVICE]    ApiService.cs                            │
│  Cliente HTTP     HttpClient, JSON Serialization           │
│                   ↕ HTTP REST                              │
│                                                             │
│  [BACKEND]        ChamadosController.cs                    │
│  API REST         Entity Framework, SQL Server             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Principais Conceitos:

1. **Injeção de Dependência:** Services são injetados via construtor
2. **Data Binding:** Views atualizam automaticamente quando dados mudam
3. **Async/Await:** Requisições HTTP não travam a interface
4. **ObservableCollection:** Lista que notifica mudanças para a View
5. **JWT:** Token de autenticação enviado em todo request

---

## 🎓 10. PRÓXIMOS PASSOS

Para entender melhor, recomendo:

1. **Adicionar breakpoints** em:
   - `ChamadosListPage.OnAppearing()`
   - `ChamadosListViewModel.Load()`
   - `ApiService.GetAsync()`

2. **Ver logs** na janela Output

3. **Testar no Postman:**
   - `GET http://192.168.1.132:5246/api/chamados`
   - Ver exatamente o JSON que a API retorna

4. **Modificar um campo:**
   - Adicione um `Debug.WriteLine()` em algum método
   - Veja aparecer no Output
   - Entenda o fluxo de dados

---

## 📞 SUPORTE

Se tiver dúvidas sobre qualquer parte, pergunte especificamente sobre:
- ✅ "Como funciona o login?"
- ✅ "Por que meu celular não conecta?"
- ✅ "Como adicionar um novo campo?"
- ✅ "Como funciona o Data Binding?"

**Este guia cobre 100% do fluxo mobile → backend!** 🚀
