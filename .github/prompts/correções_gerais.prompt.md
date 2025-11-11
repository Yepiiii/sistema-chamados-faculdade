---
mode: agent
---
Define the task to achieve, including specific requirements, constraints, and success criteria.
# 🎯 PLANO DE AÇÃO - CORREÇÃO MOBILE ONLY (Maximizado)

**Data:** 2025-11-10  
**Estratégia:** Maximizar mudanças no Mobile, minimizar mudanças no Backend  
**Objetivo:** Corrigir todas as incompatibilidades garantindo funcionamento completo incluindo SLA

---

## 📋 PRINCÍPIOS DA ESTRATÉGIA

1. **Mobile se adapta ao Backend** (não o contrário)
2. **Backend é a fonte da verdade** (API define o contrato)
3. **SLA é prioritário** (funcionalidade crítica de negócio)
4. **Mudanças mínimas no Backend** (apenas se absolutamente necessário)
5. **Testes após cada fase** (validação incremental)

---

## 🔄 FASES DO PLANO

### ⚡ FASE 1: CORREÇÕES CRÍTICAS BLOQUEADORAS (30 minutos)
**Objetivo:** Resolver bugs que impedem funcionalidades básicas

#### 1.1 Corrigir StatusId "Fechado" no Mobile
**Severidade:** 🔴 CRÍTICA - BLOQUEADOR  
**Tempo:** 2 minutos  
**Arquivo:** `Mobile/Services/Chamados/ChamadoService.cs`

**Problema:**
- Mobile usa `StatusId = 5` (ERRADO)
- Backend espera `StatusId = 4` (CORRETO)
- `DataFechamento` nunca é definida

**Solução Mobile Only:**
```csharp
// LINHA 79 - Mobile/Services/Chamados/ChamadoService.cs
public Task<ChamadoDto?> Close(int id)
{
    var atualizacao = new AtualizarChamadoDto
    {
        StatusId = 4 // ✅ CORRIGIR: Backend usa 4 para "Fechado"
    };
    return _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", atualizacao);
}
```

**Teste:**
```bash
# 1. Abrir Mobile e logar como técnico
# 2. Assumir um chamado
# 3. Fechar o chamado
# 4. Verificar no banco:
SELECT Id, Titulo, StatusId, DataFechamento FROM Chamados WHERE Id = {id};
# Deve retornar: StatusId = 4, DataFechamento = {data_atual}
```

**Validação SLA:**
- ✅ DataFechamento preenchida → cálculo de tempo de resolução correto
- ✅ StatusId correto → filtros de relatórios funcionam
- ✅ SLA não é violado erroneamente

---

#### 1.2 Adicionar Método "Assumir Chamado" no Mobile
**Severidade:** 🟡 ALTA  
**Tempo:** 30 minutos  
**Arquivos:** 
- `Mobile/Services/Chamados/ChamadoService.cs`
- `Mobile/Services/Chamados/IChamadoService.cs`

**Problema:**
- Desktop tem função "Assumir" (StatusId = 2 + TecnicoId)
- Mobile não tem método dedicado
- Técnicos não conseguem assumir chamados da fila

**Solução Mobile Only:**

**Passo 1:** Adicionar método na interface
```csharp
// Mobile/Services/Chamados/IChamadoService.cs
public interface IChamadoService
{
    Task<IEnumerable<ChamadoDto>?> GetChamados(ChamadoQueryParameters? parameters = null);
    Task<ChamadoDto?> GetById(int id);
    Task<ChamadoDto?> Update(int id, AtualizarChamadoDto dto);
    Task<ChamadoDto?> Close(int id);
    Task<ChamadoDto?> AnalisarChamadoAsync(AnalisarChamadoRequestDto request);
    
    // ✅ ADICIONAR:
    Task<ChamadoDto?> Assumir(int id);
}
```

**Passo 2:** Implementar método no serviço
```csharp
// Mobile/Services/Chamados/ChamadoService.cs (após método Close)
public async Task<ChamadoDto?> Assumir(int id)
{
    // Obtém ID do técnico logado
    var tecnicoId = _authService.GetCurrentUserId();
    
    if (tecnicoId == 0)
    {
        throw new InvalidOperationException("Usuário não autenticado");
    }
    
    var atualizacao = new AtualizarChamadoDto
    {
        StatusId = 2, // "Em Andamento" (padrão do Desktop)
        TecnicoId = tecnicoId
    };
    
    return await _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", atualizacao);
}
```

**Passo 3:** Atualizar ViewModel (TecnicoFilaViewModel ou similar)
```csharp
// Mobile/ViewModels/TecnicoFilaViewModel.cs (criar comando)
public ICommand AssumirChamadoCommand => new Command<ChamadoDto>(async (chamado) =>
{
    if (IsBusy) return;
    IsBusy = true;

    try
    {
        var resultado = await _chamadoService.Assumir(chamado.Id);
        
        if (resultado != null)
        {
            await Application.Current.MainPage.DisplayAlert(
                "Sucesso", 
                $"Chamado #{chamado.Id} assumido com sucesso!", 
                "OK"
            );
            
            // Recarrega lista da fila
            await CarregarChamadosFilaAsync();
        }
    }
    catch (Exception ex)
    {
        await Application.Current.MainPage.DisplayAlert(
            "Erro", 
            $"Erro ao assumir chamado: {ex.Message}", 
            "OK"
        );
    }
    finally
    {
        IsBusy = false;
    }
});
```

**Teste:**
```bash
# 1. Criar chamado como usuário comum (StatusId = 1, TecnicoId = NULL)
# 2. Logar como técnico no Mobile
# 3. Ver fila de chamados (tecnicoId=0&statusId=1)
# 4. Clicar em "Assumir" no chamado
# 5. Verificar no banco:
SELECT Id, StatusId, TecnicoId FROM Chamados WHERE Id = {id};
# Deve retornar: StatusId = 2, TecnicoId = {id_do_tecnico}
```

**Validação SLA:**
- ✅ SlaDataExpiracao NÃO muda (apenas status e técnico)
- ✅ Chamado sai da fila (tecnicoId preenchido)
- ✅ Backend atualiza DataUltimaAtualizacao automaticamente

---

### 📊 FASE 2: ALINHAMENTO DE DTOs COM BACKEND (2 horas)
**Objetivo:** Garantir que Mobile deserialize corretamente respostas da API

#### 2.1 Simplificar ComentarioDto
**Severidade:** 🟡 MÉDIA  
**Tempo:** 30 minutos  
**Arquivo:** `Mobile/Models/DTOs/ComentarioDto.cs`

**Problema:**
- Mobile espera objeto `Usuario` (Backend NÃO envia)
- Campos redundantes (`UsuarioNome` + `Usuario.Nome`)
- Campos extras (`IsInterno`, `DataHora` vs `DataCriacao`)

**Backend retorna (ComentarioResponseDto):**
```csharp
{
    "id": 1,
    "texto": "Comentário...",
    "dataCriacao": "2025-11-10T10:00:00Z",
    "usuarioId": 5,
    "usuarioNome": "João Silva", // ✅ String plana
    "chamadoId": 10
}
```

**Solução Mobile Only:**
```csharp
// Mobile/Models/DTOs/ComentarioDto.cs
namespace SistemaChamados.Mobile.Models.DTOs;

public class ComentarioDto
{
    public int Id { get; set; }
    public string Texto { get; set; } = string.Empty;
    
    // ✅ MANTER: Backend envia como string
    public string UsuarioNome { get; set; } = string.Empty;
    
    // ✅ MANTER: Backend envia DataCriacao
    public DateTime DataCriacao { get; set; }
    
    public int UsuarioId { get; set; }
    public int ChamadoId { get; set; }
    
    // ❌ REMOVER: Backend não envia
    // public UsuarioResumoDto? Usuario { get; set; }
    // public bool IsInterno { get; set; }
    // public DateTime DataHora { get; set; }
    
    // ✅ MANTER: UI Helpers (não afetam deserialização)
    public string DataHoraFormatada => DataCriacao.ToString("dd/MM/yyyy HH:mm");
    
    public string TempoRelativo
    {
        get
        {
            var diferenca = DateTime.UtcNow - DataCriacao;
            if (diferenca.TotalMinutes < 1) return "Agora";
            if (diferenca.TotalHours < 1) return $"{(int)diferenca.TotalMinutes}m atrás";
            if (diferenca.TotalDays < 1) return $"{(int)diferenca.TotalHours}h atrás";
            return DataCriacao.ToString("dd/MM/yyyy");
        }
    }
}
```

**Impacto nas Views:**
```xml
<!-- ANTES (ERRADO): -->
<Label Text="{Binding Usuario.NomeCompleto}" />

<!-- DEPOIS (CORRETO): -->
<Label Text="{Binding UsuarioNome}" />
```

**Teste:**
```bash
# 1. Abrir detalhes de chamado no Mobile
# 2. Adicionar comentário
# 3. Verificar se comentário aparece com nome do usuário
# 4. Verificar console/logs: sem erros de deserialização
```

---

#### 2.2 Criar ChamadoListDto para Listagens
**Severidade:** 🟡 MÉDIA  
**Tempo:** 1 hora  
**Arquivos:**
- `Mobile/Models/DTOs/ChamadoListDto.cs` (NOVO)
- `Mobile/Services/Chamados/IChamadoService.cs`
- `Mobile/Services/Chamados/ChamadoService.cs`
- `Mobile/ViewModels/ChamadosListViewModel.cs`
- `Mobile/ViewModels/DashboardViewModel.cs`

**Problema:**
- Backend retorna `ChamadoListDto` (strings planas) em GET /api/chamados
- Mobile usa `ChamadoDto` complexo (objetos navegação) para tudo
- Deserialização funciona mas é ineficiente

**Backend retorna em GET /api/chamados:**
```json
{
  "$values": [
    {
      "id": 1,
      "titulo": "Problema na rede",
      "categoriaNome": "Infraestrutura",
      "statusNome": "Aberto",
      "prioridadeNome": "Alta"
    }
  ]
}
```

**Solução Mobile Only:**

**Passo 1:** Criar DTO simplificado
```csharp
// Mobile/Models/DTOs/ChamadoListDto.cs (NOVO ARQUIVO)
namespace SistemaChamados.Mobile.Models.DTOs;

/// <summary>
/// DTO simplificado para listagem de chamados.
/// Corresponde ao ChamadoListDto do Backend (GET /api/chamados).
/// Para detalhes completos, use ChamadoDto (GET /api/chamados/{id}).
/// </summary>
public class ChamadoListDto
{
    public int Id { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string CategoriaNome { get; set; } = string.Empty;
    public string StatusNome { get; set; } = string.Empty;
    public string PrioridadeNome { get; set; } = string.Empty;
    
    // UI Helpers
    public string StatusBadgeColor => StatusNome.ToLowerInvariant() switch
    {
        "aberto" => "#3498db",
        "em andamento" => "#f39c12",
        "fechado" => "#2ecc71",
        "violado" => "#e74c3c",
        _ => "#95a5a6"
    };
}
```

**Passo 2:** Adicionar método de listagem separado
```csharp
// Mobile/Services/Chamados/IChamadoService.cs
public interface IChamadoService
{
    // ✅ MANTER: Para detalhes completos
    Task<ChamadoDto?> GetById(int id);
    
    // ✅ ADICIONAR: Para listagens (retorna ChamadoListDto)
    Task<IEnumerable<ChamadoListDto>?> GetChamadosList(ChamadoQueryParameters? parameters = null);
    
    // ⚠️ DEPRECAR (ou manter para compatibilidade):
    // Task<IEnumerable<ChamadoDto>?> GetChamados(ChamadoQueryParameters? parameters = null);
    
    Task<ChamadoDto?> Update(int id, AtualizarChamadoDto dto);
    Task<ChamadoDto?> Close(int id);
    Task<ChamadoDto?> Assumir(int id);
    Task<ChamadoDto?> AnalisarChamadoAsync(AnalisarChamadoRequestDto request);
}
```

**Passo 3:** Implementar método
```csharp
// Mobile/Services/Chamados/ChamadoService.cs
public Task<IEnumerable<ChamadoListDto>?> GetChamadosList(ChamadoQueryParameters? parameters = null)
{
    var endpoint = "chamados";
    var query = parameters?.ToQueryString();

    if (!string.IsNullOrWhiteSpace(query))
    {
        endpoint = $"{endpoint}?{query}";
    }

    return _api.GetAsync<IEnumerable<ChamadoListDto>>(endpoint);
}
```

**Passo 4:** Atualizar ViewModels
```csharp
// Mobile/ViewModels/DashboardViewModel.cs
public partial class DashboardViewModel : BaseViewModel
{
    private ObservableCollection<ChamadoListDto> _chamados = new(); // ✅ Tipo simplificado
    public ObservableCollection<ChamadoListDto> Chamados
    {
        get => _chamados;
        set => SetProperty(ref _chamados, value);
    }
    
    private async Task CarregarChamadosAsync()
    {
        var parameters = new ChamadoQueryParameters
        {
            SolicitanteId = _authService.GetCurrentUserId()
        };
        
        var resultado = await _chamadoService.GetChamadosList(parameters); // ✅ Método correto
        
        if (resultado != null)
        {
            Chamados = new ObservableCollection<ChamadoListDto>(resultado);
            AtualizarKPIs(resultado);
        }
    }
    
    private void AtualizarKPIs(IEnumerable<ChamadoListDto> chamados)
    {
        var lista = chamados.ToList();
        TotalAbertos = lista.Count(c => NormalizeStatus(c.StatusNome) == "aberto");
        TotalEmAndamento = lista.Count(c => NormalizeStatus(c.StatusNome) == "em andamento");
        TotalEncerrados = lista.Count(c => 
            NormalizeStatus(c.StatusNome) == "fechado" || 
            NormalizeStatus(c.StatusNome) == "resolvido" // ✅ Aceita ambos
        );
        TotalViolados = lista.Count(c => NormalizeStatus(c.StatusNome) == "violado");
    }
}
```

**Passo 5:** Atualizar Views XAML
```xml
<!-- Mobile/Views/DashboardPage.xaml -->
<CollectionView ItemsSource="{Binding Chamados}">
    <CollectionView.ItemTemplate>
        <DataTemplate x:DataType="dto:ChamadoListDto">
            <Frame Padding="10" Margin="5">
                <StackLayout>
                    <Label Text="{Binding Id, StringFormat='#{0}'}" FontAttributes="Bold" />
                    <Label Text="{Binding Titulo}" FontSize="16" />
                    <Label Text="{Binding CategoriaNome}" TextColor="Gray" />
                    
                    <!-- Badge de Status -->
                    <Frame BackgroundColor="{Binding StatusBadgeColor}" 
                           CornerRadius="5" 
                           Padding="5,2" 
                           HorizontalOptions="Start">
                        <Label Text="{Binding StatusNome}" TextColor="White" FontSize="12" />
                    </Frame>
                    
                    <Label Text="{Binding PrioridadeNome}" FontAttributes="Italic" />
                </StackLayout>
            </Frame>
        </DataTemplate>
    </CollectionView.ItemTemplate>
</CollectionView>
```

**Teste:**
```bash
# 1. Abrir Mobile e logar
# 2. Ver dashboard com lista de chamados
# 3. Verificar console/logs: sem erros de deserialização
# 4. Verificar KPIs: valores corretos
# 5. Clicar em chamado para ver detalhes (deve usar ChamadoDto completo)
```

**Validação SLA:**
- ✅ SLA não aparece na lista (não é necessário)
- ✅ Performance melhorada (menos dados transferidos)
- ✅ Detalhes carregam SLA corretamente (usando GetById)

---

#### 2.3 Padronizar Lógica de KPIs
**Severidade:** 🟡 MÉDIA  
**Tempo:** 10 minutos  
**Arquivo:** `Mobile/ViewModels/DashboardViewModel.cs`

**Problema:**
- Desktop aceita "fechado" OU "resolvido"
- Mobile aceita apenas "fechado"
- Contagens diferentes entre plataformas

**Solução Mobile Only:**
```csharp
// Mobile/ViewModels/DashboardViewModel.cs (dentro do método AtualizarKPIs)
private void AtualizarKPIs(IEnumerable<ChamadoListDto> chamados)
{
    var lista = chamados.ToList();
    
    TotalAbertos = lista.Count(c => NormalizeStatus(c.StatusNome) == "aberto");
    TotalEmAndamento = lista.Count(c => NormalizeStatus(c.StatusNome) == "em andamento");
    
    // ✅ CORRIGIR: Aceitar "fechado" OU "resolvido" (como Desktop)
    TotalEncerrados = lista.Count(c => 
        NormalizeStatus(c.StatusNome) == "fechado" || 
        NormalizeStatus(c.StatusNome) == "resolvido"
    );
    
    TotalViolados = lista.Count(c => NormalizeStatus(c.StatusNome) == "violado");
    
    // ✅ ADICIONAR: KPI "Pendentes" (Desktop tem, Mobile não tinha)
    TotalPendentes = lista.Count(c => NormalizeStatus(c.StatusNome) == "aguardando resposta");
}

private string NormalizeStatus(string statusNome)
{
    return statusNome?.ToLowerInvariant()?.Trim() ?? "desconhecido";
}
```

**Adicionar propriedade:**
```csharp
private int _totalPendentes;
public int TotalPendentes
{
    get => _totalPendentes;
    set => SetProperty(ref _totalPendentes, value);
}
```

**Teste:**
```bash
# 1. Criar chamados de teste com diferentes status
# 2. Verificar KPIs no Mobile
# 3. Verificar KPIs no Desktop
# 4. Comparar: valores devem ser idênticos
```

---

### 🔧 FASE 3: VALIDAÇÃO DE SLA E FUNCIONALIDADES CRÍTICAS (1 hora)
**Objetivo:** Garantir que SLA funciona corretamente em todos os fluxos

#### 3.1 Verificar Cálculo de SLA no Mobile
**Severidade:** 🔴 CRÍTICA (SLA é prioritário)  
**Tempo:** 30 minutos  
**Arquivos:**
- `Mobile/Models/DTOs/ChamadoDto.cs`
- `Mobile/ViewModels/ChamadoDetalhesViewModel.cs` (se existir)

**Backend calcula SLA automaticamente:**
```csharp
// Backend/API/Controllers/ChamadosController.cs (POST /api/chamados)
SlaDataExpiracao = CalcularSla(prioridadeSla.Nivel, DateTime.UtcNow)

// Método CalcularSla
private DateTime CalcularSla(int nivelPrioridade, DateTime dataAbertura)
{
    int horasParaAdicionar = nivelPrioridade switch
    {
        1 => 4,   // Urgente: 4 horas
        2 => 8,   // Alta: 8 horas
        3 => 24,  // Média: 24 horas
        4 => 72,  // Baixa: 72 horas
        _ => 48   // Padrão: 48 horas
    };
    return dataAbertura.AddHours(horasParaAdicionar);
}
```

**Backend verifica violação automaticamente:**
```csharp
// Backend/API/Controllers/ChamadosController.cs (GET /api/chamados)
// IDs: 1=Aberto, 2=Em Andamento, 3=Aguardando Resposta, 5=Violado
var statusParaVerificar = new[] { 1, 2, 3 };

var chamadosAbertos = await _context.Chamados
    .Where(c => statusParaVerificar.Contains(c.StatusId))
    .ToListAsync();

foreach (var chamado in chamadosAbertos)
{
    if (chamado.SlaDataExpiracao.HasValue && 
        DateTime.UtcNow > chamado.SlaDataExpiracao.Value && 
        chamado.StatusId != 5)
    {
        chamado.StatusId = 5; // Violado
        _context.Chamados.Update(chamado);
    }
}
```

**Verificações Mobile Only:**

**1. ChamadoDto tem campo SLA:**
```csharp
// Mobile/Models/DTOs/ChamadoDto.cs
public class ChamadoDto
{
    // ... outros campos ...
    
    public DateTime? SlaDataExpiracao { get; set; } // ✅ CONFIRMAR que existe
    
    // UI Helper
    public bool SlaExpirado => SlaDataExpiracao.HasValue && DateTime.UtcNow > SlaDataExpiracao.Value;
    
    public string SlaStatus => SlaDataExpiracao.HasValue
        ? (SlaExpirado ? "⚠️ SLA VIOLADO" : $"⏱️ Expira em {SlaTempoRestante}")
        : "Sem SLA";
        
    public string SlaTempoRestante
    {
        get
        {
            if (!SlaDataExpiracao.HasValue) return "";
            
            var diferenca = SlaDataExpiracao.Value - DateTime.UtcNow;
            
            if (diferenca.TotalHours < 1)
                return $"{(int)diferenca.TotalMinutes} minutos";
            
            if (diferenca.TotalDays < 1)
                return $"{(int)diferenca.TotalHours} horas";
            
            return $"{(int)diferenca.TotalDays} dias";
        }
    }
}
```

**2. View exibe SLA corretamente:**
```xml
<!-- Mobile/Views/ChamadoDetalhesPage.xaml -->
<StackLayout>
    <Label Text="SLA" FontAttributes="Bold" />
    
    <!-- Data de Expiração -->
    <Label Text="{Binding Chamado.SlaDataExpiracao, StringFormat='Expira em: {0:dd/MM/yyyy HH:mm}'}" 
           IsVisible="{Binding Chamado.SlaDataExpiracao, Converter={StaticResource NotNullConverter}}" />
    
    <!-- Status do SLA -->
    <Frame BackgroundColor="{Binding Chamado.SlaExpirado, Converter={StaticResource BoolToColorConverter}}"
           Padding="5"
           CornerRadius="5">
        <Label Text="{Binding Chamado.SlaStatus}" 
               TextColor="White" 
               FontAttributes="Bold" />
    </Frame>
    
    <!-- Tempo Restante -->
    <Label Text="{Binding Chamado.SlaTempoRestante}" 
           TextColor="Gray"
           IsVisible="{Binding Chamado.SlaExpirado, Converter={StaticResource InverseBoolConverter}}" />
</StackLayout>
```

**3. Adicionar Converters necessários:**
```csharp
// Mobile/Converters/BoolToColorConverter.cs (se não existir)
public class BoolToColorConverter : IValueConverter
{
    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
        if (value is bool isExpirado)
        {
            return isExpirado ? Color.FromArgb("#e74c3c") : Color.FromArgb("#2ecc71");
        }
        return Color.FromArgb("#95a5a6");
    }

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
    {
        throw new NotImplementedException();
    }
}
```

**Teste SLA Completo:**
```bash
# Teste 1: Criação de chamado com SLA
# 1. Mobile: Criar novo chamado (prioridade Alta)
# 2. Backend: Verificar no banco que SlaDataExpiracao foi calculado
SELECT Id, Titulo, PrioridadeId, SlaDataExpiracao FROM Chamados ORDER BY Id DESC LIMIT 1;
# Deve ter SlaDataExpiracao = DataAbertura + 8 horas

# Teste 2: Exibição de SLA
# 3. Mobile: Abrir detalhes do chamado
# 4. Verificar: SLA exibido corretamente com tempo restante

# Teste 3: Violação automática de SLA
# 5. Simular violação (alterar SlaDataExpiracao no banco para data passada):
UPDATE Chamados SET SlaDataExpiracao = DATEADD(hour, -1, GETUTCDATE()) WHERE Id = {id};
# 6. Desktop/Mobile: Fazer GET /api/chamados
# 7. Verificar no banco: StatusId deve ter mudado para 5 (Violado)
SELECT Id, StatusId FROM Chamados WHERE Id = {id};

# Teste 4: Fechamento não remove SLA
# 8. Fechar chamado (Mobile ou Desktop)
# 9. Verificar: SlaDataExpiracao permanece no banco (histórico)
```

**Validação Final SLA:**
- ✅ Backend calcula SLA na criação (Mobile não precisa calcular)
- ✅ Backend verifica violação automaticamente (Mobile não precisa verificar)
- ✅ Mobile apenas EXIBE SLA corretamente
- ✅ SLA persiste após fechamento (métrica de performance)

---

#### 3.2 Verificar Endpoint "Analisar Chamado" (IA)
**Severidade:** 🟡 MÉDIA  
**Tempo:** 15 minutos  
**Arquivo:** `Mobile/Services/Chamados/ChamadoService.cs`

**Backend cria chamado automaticamente:**
```csharp
// Backend/API/Controllers/ChamadosController.cs
[HttpPost("analisar")]
public async Task<IActionResult> AnalisarChamado([FromBody] AnalisarChamadoRequestDto request)
{
    // 1. Analisa com IA
    var analise = await _openAIService.AnalisarChamadoAsync(request.DescricaoProblema);
    
    // 2. CRIA o chamado com resultado da análise
    var novoChamado = new Chamado
    {
        Titulo = analise.TituloSugerido,
        Descricao = request.DescricaoProblema,
        CategoriaId = analise.CategoriaId,
        PrioridadeId = analise.PrioridadeId,
        StatusId = 1, // Aberto
        SolicitanteId = solicitanteId,
        SlaDataExpiracao = CalcularSla(prioridadeSla.Nivel, DateTime.UtcNow)
    };
    
    _context.Chamados.Add(novoChamado);
    await _context.SaveChangesAsync();
    
    // 3. Retorna o chamado CRIADO
    return Ok(novoChamado);
}
```

**Mobile deve apenas chamar endpoint:**
```csharp
// Mobile/Services/Chamados/ChamadoService.cs
public Task<ChamadoDto?> AnalisarChamadoAsync(AnalisarChamadoRequestDto request)
{
    // ✅ CORRETO: Backend já cria o chamado, não apenas analisa
    // Retorna ChamadoDto completo (chamado criado)
    return _api.PostAsync<AnalisarChamadoRequestDto, ChamadoDto>("chamados/analisar", request);
}
```

**ViewModel deve navegar para detalhes:**
```csharp
// Mobile/ViewModels/NovoChamadoViewModel.cs
private async Task EnviarChamadoAsync()
{
    var request = new AnalisarChamadoRequestDto
    {
        DescricaoProblema = DescricaoProblema
    };
    
    // Backend retorna o chamado JÁ CRIADO
    var chamadoCriado = await _chamadoService.AnalisarChamadoAsync(request);
    
    if (chamadoCriado != null)
    {
        await Application.Current.MainPage.DisplayAlert(
            "Sucesso",
            $"Chamado #{chamadoCriado.Id} criado e classificado automaticamente!",
            "OK"
        );
        
        // Navegar para detalhes do chamado criado
        await Shell.Current.GoToAsync($"detalhes?id={chamadoCriado.Id}");
    }
}
```

**Teste:**
```bash
# 1. Mobile: Criar novo chamado com descrição
# 2. Verificar: IA analisa e classifica automaticamente
# 3. Verificar: Chamado é criado (não precisa criar depois)
# 4. Verificar: SLA calculado corretamente
# 5. Verificar: Navega para detalhes do novo chamado
```

---

#### 3.3 Verificar Atualização de Status/Técnico
**Severidade:** 🟡 MÉDIA  
**Tempo:** 15 minutos  
**Arquivo:** Backend (APENAS VALIDAÇÃO - sem mudanças)

**Comportamento atual do Backend:**
```csharp
// Backend/API/Controllers/ChamadosController.cs (PUT /api/chamados/{id})
public async Task<IActionResult> AtualizarChamado(int id, [FromBody] AtualizarChamadoDto request)
{
    // 1. Atualiza DataUltimaAtualizacao SEMPRE
    chamado.DataUltimaAtualizacao = DateTime.UtcNow;
    
    // 2. Se StatusId = 4 (Fechado), define DataFechamento
    if (request.StatusId == 4)
    {
        chamado.DataFechamento = DateTime.UtcNow;
    }
    else
    {
        chamado.DataFechamento = null; // Reabertura
    }
    
    // 3. Atualiza StatusId
    chamado.StatusId = request.StatusId;
    
    // 4. Atualiza TecnicoId (se fornecido)
    if (request.TecnicoId.HasValue)
    {
        chamado.TecnicoId = request.TecnicoId;
    }
    
    // ⚠️ IMPORTANTE: SlaDataExpiracao NÃO é alterado
    // SLA permanece fixo desde a criação
}
```

**Validação Mobile Only:**
```bash
# Teste 1: Assumir chamado NÃO altera SLA
# 1. Criar chamado (SLA = DataAbertura + X horas)
# 2. Técnico assume (StatusId = 2, TecnicoId = {id})
# 3. Verificar: SlaDataExpiracao permanece igual
SELECT Id, SlaDataExpiracao FROM Chamados WHERE Id = {id};

# Teste 2: Fechar chamado NÃO altera SLA
# 4. Fechar chamado (StatusId = 4)
# 5. Verificar: SlaDataExpiracao permanece igual (histórico)
# 6. Verificar: DataFechamento preenchida

# Teste 3: Reabrir chamado limpa DataFechamento
# 7. Reabrir chamado (StatusId = 1)
# 8. Verificar: DataFechamento = NULL
# 9. Verificar: SlaDataExpiracao permanece original (não recalcula)
```

**✅ CONCLUSÃO:** Backend está correto, Mobile apenas consome.

---

### 🎨 FASE 4: MELHORIAS DE CÓDIGO E MANUTENIBILIDADE (3 horas)
**Objetivo:** Facilitar manutenção futura e prevenir bugs

#### 4.1 Criar Classe StatusConstants (Mobile)
**Severidade:** 🟢 BAIXA (melhoria)  
**Tempo:** 1 hora  
**Arquivos:**
- `Mobile/Constants/StatusConstants.cs` (NOVO)
- `Mobile/Services/Chamados/ChamadoService.cs`
- `Mobile/ViewModels/DashboardViewModel.cs`

**Problema:**
- "Magic numbers" hardcoded (StatusId = 2, 4, 5)
- Difícil manutenção
- Propenso a erros

**Solução Mobile Only:**

**Passo 1:** Criar classe de constantes
```csharp
// Mobile/Constants/StatusConstants.cs (NOVO ARQUIVO)
namespace SistemaChamados.Mobile.Constants;

/// <summary>
/// Constantes de Status de Chamados.
/// ATENÇÃO: IDs devem corresponder aos valores no banco de dados.
/// </summary>
public static class StatusConstants
{
    public const int Aberto = 1;
    public const int EmAndamento = 2;
    public const int AguardandoResposta = 3;
    public const int Fechado = 4;
    public const int Violado = 5;
    
    // Nomes padronizados
    public static class Nomes
    {
        public const string Aberto = "aberto";
        public const string EmAndamento = "em andamento";
        public const string AguardandoResposta = "aguardando resposta";
        public const string Fechado = "fechado";
        public const string Resolvido = "resolvido"; // Alias
        public const string Violado = "violado";
    }
}
```

**Passo 2:** Refatorar ChamadoService
```csharp
// Mobile/Services/Chamados/ChamadoService.cs
using SistemaChamados.Mobile.Constants;

public Task<ChamadoDto?> Close(int id)
{
    var atualizacao = new AtualizarChamadoDto
    {
        StatusId = StatusConstants.Fechado // ✅ Constante em vez de 4
    };
    return _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", atualizacao);
}

public async Task<ChamadoDto?> Assumir(int id)
{
    var tecnicoId = _authService.GetCurrentUserId();
    
    var atualizacao = new AtualizarChamadoDto
    {
        StatusId = StatusConstants.EmAndamento, // ✅ Constante em vez de 2
        TecnicoId = tecnicoId
    };
    
    return await _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", atualizacao);
}
```

**Passo 3:** Refatorar DashboardViewModel
```csharp
// Mobile/ViewModels/DashboardViewModel.cs
using SistemaChamados.Mobile.Constants;

private void AtualizarKPIs(IEnumerable<ChamadoListDto> chamados)
{
    var lista = chamados.ToList();
    
    TotalAbertos = lista.Count(c => 
        NormalizeStatus(c.StatusNome) == StatusConstants.Nomes.Aberto);
    
    TotalEmAndamento = lista.Count(c => 
        NormalizeStatus(c.StatusNome) == StatusConstants.Nomes.EmAndamento);
    
    TotalEncerrados = lista.Count(c => 
        NormalizeStatus(c.StatusNome) == StatusConstants.Nomes.Fechado || 
        NormalizeStatus(c.StatusNome) == StatusConstants.Nomes.Resolvido);
    
    TotalViolados = lista.Count(c => 
        NormalizeStatus(c.StatusNome) == StatusConstants.Nomes.Violado);
    
    TotalPendentes = lista.Count(c => 
        NormalizeStatus(c.StatusNome) == StatusConstants.Nomes.AguardandoResposta);
}
```

**Teste:**
```bash
# Compilação: sem erros
# Funcionalidade: comportamento idêntico ao anterior
# Benefício: código mais legível e manutenível
```

---

#### 4.2 Documentar Desktop/wwwroot Duplicação
**Severidade:** 🟢 BAIXA (documentação)  
**Tempo:** 30 minutos  
**Arquivo:** `README.md` ou novo `ESTRUTURA_FRONTEND.md`

**Decisão:** Manter ambas as pastas mas DOCUMENTAR propósito

**Criar arquivo:**
```markdown
<!-- ESTRUTURA_FRONTEND.md (NOVO) -->
# 📁 Estrutura do Frontend

## Pastas Desktop e wwwroot

O projeto possui DUAS pastas com conteúdo HTML/CSS/JS:

### Frontend/Desktop/
- **Propósito:** Desenvolvimento local standalone
- **Servidor:** Pode ser servido por qualquer servidor HTTP simples
- **URL Base:** `API_BASE = "https://api.exemplo.com"` (configurável)
- **Uso:** Testes locais, desenvolvimento sem backend rodando

### Frontend/wwwroot/
- **Propósito:** Produção (servido pelo mesmo servidor do Backend)
- **Servidor:** ASP.NET Core serve arquivos estáticos
- **URL Base:** `API_BASE = ""` (URLs relativas - mesmo domínio)
- **Uso:** Deploy unificado (Backend + Frontend no mesmo servidor)

## ⚠️ ATENÇÃO: Arquivos SÃO IDÊNTICOS

Qualquer mudança em `script-desktop.js` deve ser replicada em ambas as pastas.

### Script de Sincronização

Execute após modificar arquivos:

```powershell
# PowerShell (Windows)
Copy-Item -Path "Frontend\Desktop\*" -Destination "Frontend\wwwroot\" -Recurse -Force
```

```bash
# Bash (Linux/Mac)
cp -r Frontend/Desktop/* Frontend/wwwroot/
```

## Arquivos

- `script-desktop.js` (1803 linhas) - Lógica da aplicação
- `style-desktop.css` - Estilos
- 16 páginas HTML (login, dashboard, detalhes, etc.)
- `img/` - Imagens e ícones

## Roadmap Futuro

**Opção 1:** Migrar para framework moderno (React, Vue)
**Opção 2:** Manter apenas wwwroot/ e deletar Desktop/
**Opção 3:** Automatizar sincronização com build task
```

---

#### 4.3 Adicionar Testes Unitários (Opcional)
**Severidade:** 🟢 BAIXA (melhoria)  
**Tempo:** 1.5 horas  
**Objetivo:** Prevenir regressões futuras

**Criar projeto de testes:**
```bash
# Terminal
cd Mobile
dotnet new xunit -n SistemaChamados.Mobile.Tests
dotnet add SistemaChamados.Mobile.Tests reference SistemaChamados.Mobile.csproj
dotnet add SistemaChamados.Mobile.Tests package Moq
```

**Testes críticos:**
```csharp
// Mobile.Tests/Services/ChamadoServiceTests.cs
using Xunit;
using Moq;
using SistemaChamados.Mobile.Services;
using SistemaChamados.Mobile.Constants;

public class ChamadoServiceTests
{
    [Fact]
    public void Close_DeveUsarStatusIdCorreto()
    {
        // Arrange
        var mockApi = new Mock<IApiService>();
        var mockAuth = new Mock<IAuthService>();
        var service = new ChamadoService(mockApi.Object, mockAuth.Object);
        
        // Act
        var task = service.Close(1);
        
        // Assert
        mockApi.Verify(x => x.PutAsync<AtualizarChamadoDto, ChamadoDto>(
            It.IsAny<string>(),
            It.Is<AtualizarChamadoDto>(dto => dto.StatusId == StatusConstants.Fechado)
        ), Times.Once);
    }
    
    [Fact]
    public void Assumir_DeveUsarStatusEmAndamento()
    {
        // Arrange
        var mockApi = new Mock<IApiService>();
        var mockAuth = new Mock<IAuthService>();
        mockAuth.Setup(x => x.GetCurrentUserId()).Returns(5);
        var service = new ChamadoService(mockApi.Object, mockAuth.Object);
        
        // Act
        var task = service.Assumir(1);
        
        // Assert
        mockApi.Verify(x => x.PutAsync<AtualizarChamadoDto, ChamadoDto>(
            It.IsAny<string>(),
            It.Is<AtualizarChamadoDto>(dto => 
                dto.StatusId == StatusConstants.EmAndamento &&
                dto.TecnicoId == 5
            )
        ), Times.Once);
    }
}
```

---

### ✅ FASE 5: VALIDAÇÃO FINAL E DEPLOY (1 hora)
**Objetivo:** Garantir que tudo funciona antes de produção

#### 5.1 Checklist de Testes Completo

```markdown
## 🧪 CHECKLIST DE TESTES - VALIDAÇÃO FINAL

### Funcionalidades Críticas

#### Criar Chamado (com IA)
- [ ] Mobile: Criar chamado via análise IA
- [ ] Backend: Chamado criado com Titulo, Categoria, Prioridade corretos
- [ ] Backend: SlaDataExpiracao calculado corretamente
- [ ] Mobile: Navega para detalhes do chamado criado

#### Assumir Chamado (Técnico)
- [ ] Mobile: Ver fila de chamados (tecnicoId=0)
- [ ] Mobile: Clicar "Assumir" em chamado da fila
- [ ] Backend: StatusId = 2, TecnicoId = {id_tecnico_logado}
- [ ] Mobile: Chamado sai da fila, aparece em "Meus Chamados"
- [ ] Backend: SlaDataExpiracao NÃO mudou

#### Fechar Chamado
- [ ] Mobile: Fechar chamado assumido
- [ ] Backend: StatusId = 4, DataFechamento preenchida
- [ ] Backend: SlaDataExpiracao NÃO mudou (permanece para histórico)
- [ ] Mobile: KPI "Encerrados" incrementado

#### Violação de SLA
- [ ] Backend: Chamado aberto com SLA próximo de expirar
- [ ] Esperar expiração OU alterar SlaDataExpiracao no banco
- [ ] Desktop/Mobile: Fazer GET /api/chamados
- [ ] Backend: StatusId automaticamente alterado para 5 (Violado)
- [ ] Mobile: KPI "Violados" incrementado
- [ ] Mobile: Badge vermelho de "SLA VIOLADO" exibido

#### Comentários
- [ ] Mobile: Adicionar comentário em chamado
- [ ] Backend: Comentário salvo com UsuarioNome (string)
- [ ] Mobile: Comentário exibido corretamente (sem erro deserialização)
- [ ] Desktop: Comentário visível também

#### Listagem e Filtros
- [ ] Mobile: Dashboard exibe todos os chamados do usuário
- [ ] Mobile: KPIs calculados corretamente
- [ ] Mobile: Técnico vê apenas seus chamados (tecnicoId filtrado)
- [ ] Desktop: Mesmos KPIs que Mobile

### Testes de Regressão

#### StatusId = 4 (Fechado)
- [ ] Mobile: `ChamadoService.Close()` usa `StatusId = 4` ✅
- [ ] Backend: `DataFechamento` preenchida quando `StatusId = 4` ✅
- [ ] Sem erros de "StatusId inválido"

#### DTOs Simplificados
- [ ] Mobile: `ComentarioDto` sem objeto `Usuario`
- [ ] Mobile: `ChamadoListDto` usado em listagens
- [ ] Mobile: `ChamadoDto` completo usado em detalhes
- [ ] Sem erros de deserialização em logs

#### Constantes
- [ ] Mobile: `StatusConstants.Fechado` = 4
- [ ] Mobile: `StatusConstants.EmAndamento` = 2
- [ ] Código usa constantes (não magic numbers)

### Performance

- [ ] Mobile: Listagem carrega em < 2 segundos
- [ ] Mobile: Detalhes carregam em < 1 segundo
- [ ] Backend: GET /api/chamados retorna em < 500ms
- [ ] Sem memory leaks (testar com 100+ chamados)

### Documentação

- [ ] README.md atualizado
- [ ] ESTRUTURA_FRONTEND.md criado
- [ ] Comentários de código atualizados
- [ ] ANALISE_COMPLETA_REVISADA.md arquivado
```

---

#### 5.2 Deploy Gradual

**Ambiente de Desenvolvimento:**
1. Testar todas as funcionalidades localmente
2. Executar testes unitários (se criados)
3. Verificar logs: sem erros/warnings

**Ambiente de Homologação:**
1. Deploy do Mobile (TestFlight/Google Play Internal)
2. Testar com usuários beta (2-3 técnicos)
3. Monitorar logs por 2-3 dias

**Ambiente de Produção:**
1. Deploy gradual (20% → 50% → 100% usuários)
2. Monitorar métricas de SLA
3. Verificar dashboards de erro

---

## 📊 RESUMO EXECUTIVO DO PLANO

### Tempo Total Estimado: 8 horas

| Fase | Tempo | Prioridade | Mudanças Backend | Mudanças Mobile |
|------|-------|------------|------------------|-----------------|
| 1. Correções Críticas | 30 min | 🔴 CRÍTICA | 0 | 2 arquivos |
| 2. Alinhamento DTOs | 2h | 🟡 ALTA | 0 | 5 arquivos |
| 3. Validação SLA | 1h | 🔴 CRÍTICA | 0 | 3 arquivos |
| 4. Melhorias Código | 3h | 🟢 BAIXA | 0 | 6 arquivos + doc |
| 5. Validação Final | 1.5h | 🟡 ALTA | 0 | Testes |
| **TOTAL** | **8h** | - | **0 mudanças** | **16 arquivos** |

### ✅ Vantagens da Estratégia Mobile Only

1. **Backend intocado** → Sem risco de quebrar Desktop/Web
2. **SLA funciona** → Backend já implementa tudo corretamente
3. **Mudanças isoladas** → Fácil de testar e reverter
4. **Performance melhorada** → DTOs simplificados
5. **Código limpo** → Constantes e documentação

### ⚠️ Únicas Mudanças Backend (se absolutamente necessário)

**Nenhuma mudança necessária!** Backend já está correto:
- ✅ SLA calculado automaticamente
- ✅ Violação verificada em GET /api/chamados
- ✅ DataFechamento definida quando StatusId = 4
- ✅ DTOs retornam dados corretos

**Mobile apenas precisa se adaptar ao contrato da API.**

---

## 🚀 ORDEM DE EXECUÇÃO RECOMENDADA

### Dia 1 (3 horas)
1. ✅ **FASE 1 completa** (30 min) - Correções críticas
2. ✅ **FASE 2.1** (30 min) - Simplificar ComentarioDto
3. ✅ **FASE 2.2** (1h) - Criar ChamadoListDto
4. ✅ **FASE 2.3** (10 min) - Padronizar KPIs
5. ✅ **Teste funcional** (50 min) - Validar mudanças

### Dia 2 (2.5 horas)
6. ✅ **FASE 3 completa** (1h) - Validação SLA
7. ✅ **FASE 4.1** (1h) - StatusConstants
8. ✅ **Teste de regressão** (30 min) - Garantir nada quebrou

### Dia 3 (2.5 horas)
9. ✅ **FASE 4.2** (30 min) - Documentar Desktop/wwwroot
10. ✅ **FASE 4.3** (1.5h) - Testes unitários (opcional)
11. ✅ **FASE 5** (30 min) - Checklist final

---

## 📝 NOTAS FINAIS

### SLA: Garantias de Funcionamento

✅ **Backend implementa corretamente:**
- Cálculo automático na criação (CalcularSla)
- Verificação automática de violação (GET /api/chamados)
- Persistência após fechamento (histórico)

✅ **Mobile apenas consome:**
- Exibe `SlaDataExpiracao` recebido do Backend
- Mostra tempo restante e status
- Não calcula, não valida (Backend faz tudo)

### Mudanças Backend: ZERO

**Filosofia:** Backend define o contrato, Mobile se adapta.

**Exceção:** Se Mobile identificar BUG no Backend (exemplo: SLA não sendo calculado), então sim, corrigir Backend. Mas pela análise, Backend está correto.

### Próximos Passos Após Conclusão

1. Monitorar logs de produção por 1 semana
2. Coletar feedback de técnicos sobre "Assumir Chamado"
3. Verificar métricas de SLA (violações, tempo médio de resolução)
4. Considerar migrar Desktop para framework moderno (React/Vue)
5. Implementar notificações push para SLA próximo de expirar

---

**Documento criado em:** 2025-11-10  
**Última atualização:** 2025-11-10  
**Próxima revisão:** Após conclusão da Fase 3
