# 📋 PLANO DE AÇÃO BALANCEADO: Mobile + Backend

**Estratégia:** Priorizar correções no mobile, mas implementar no backend quando necessário  
**Princípio:** Mobile se adapta, mas backend deve fornecer dados completos  
**Data:** 10/11/2025

---

## 🎯 CATEGORIA A: CORREÇÕES MOBILE-ONLY (Prioridade Máxima)

> **Execução:** IMEDIATA  
> **Risco:** 🟢 BAIXO  
> **Tempo:** ~45 minutos  
> **Bloqueadores:** NENHUM

---

### ✅ **A1. Corrigir StatusId no método Close()** [CRÍTICO]

**Problema:** Usa StatusId=5 (Violado) em vez de 4 (Fechado)  
**Solução:** Mudança de 1 linha no mobile

**Arquivo:** `backend-guinrb/Mobile/Services/Chamados/ChamadoService.cs`

```csharp
// LINHA 77 - TROCAR:
StatusId = 5

// POR:
StatusId = 4  // 4 = Fechado (não 5 que é Violado)
```

**Validação:**
```bash
grep -n "StatusId = 4" backend-guinrb/Mobile/Services/Chamados/ChamadoService.cs
```

**Tempo:** 2 minutos  
**Impacto:** ✅ Chamados fecham corretamente

---

### ✅ **A2. Criar Constantes de Status e TipoUsuario** [IMPORTANTE]

**Problema:** Magic numbers espalhados (1, 2, 3, 4, 5)  
**Solução:** Criar classe de constantes

**Arquivo:** `backend-guinrb/Mobile/Helpers/Constants.cs`

```csharp
// ADICIONAR ao final:

/// <summary>
/// IDs de Status (sincronizado com banco de dados)
/// </summary>
public static class StatusChamado
{
    public const int Aberto = 1;
    public const int EmAndamento = 2;
    public const int AguardandoResposta = 3;
    public const int Fechado = 4;
    public const int Violado = 5; // SLA excedido
}

/// <summary>
/// Tipos de Usuário (sincronizado com banco de dados)
/// </summary>
public static class TipoUsuario
{
    public const int UsuarioComum = 1;
    public const int Tecnico = 2;
    public const int Administrador = 3;
}
```

**Tempo:** 5 minutos  
**Impacto:** ✅ Código mais legível e manutenível

---

### ✅ **A3. Atualizar ChamadoService para usar constantes**

**Arquivo:** `backend-guinrb/Mobile/Services/Chamados/ChamadoService.cs`

```csharp
// NO TOPO:
using SistemaChamados.Mobile.Helpers;

// MÉTODO Close:
public Task<ChamadoDto?> Close(int id)
{
    var atualizacao = new AtualizarChamadoDto
    {
        StatusId = StatusChamado.Fechado  // ✅ Constante
    };
    return _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", atualizacao);
}
```

**Tempo:** 3 minutos  
**Impacto:** ✅ Código mais semântico

---

### ✅ **A4. Atualizar AuthService para usar constantes**

**Arquivo:** `backend-guinrb/Mobile/Services/Auth/AuthService.cs`

```csharp
// NO TOPO:
using SistemaChamados.Mobile.Helpers;

// MÉTODO Login (linha ~54):
// TROCAR:
if (resp.TipoUsuario != 1)

// POR:
if (resp.TipoUsuario != TipoUsuario.UsuarioComum)
```

**Tempo:** 2 minutos  
**Impacto:** ✅ Consistência no código

---

### ✅ **A5. Unificar DataHora e DataCriacao em ComentarioDto**

**Problema:** Mobile tem dois campos, backend envia apenas `DataCriacao`  
**Solução:** Converter `DataHora` em propriedade calculada

**Arquivo:** `backend-guinrb/Mobile/Models/DTOs/ComentarioDto.cs`

```csharp
// LOCALIZAR (linhas 9-10):
public DateTime DataCriacao { get; set; }
public DateTime DataHora { get; set; }

// SUBSTITUIR POR:
[JsonProperty("DataCriacao")]
public DateTime DataCriacao { get; set; }

/// <summary>
/// Alias para DataCriacao (compatibilidade com UI).
/// Backend envia apenas DataCriacao.
/// </summary>
[JsonIgnore]
public DateTime DataHora => DataCriacao;
```

**Tempo:** 5 minutos  
**Impacto:** ✅ Datas exibidas corretamente

---

### ✅ **A6. Criar Adapter para objeto Usuario em ComentarioDto**

**Problema:** Backend envia `UsuarioId` + `UsuarioNome`, mobile espera objeto `Usuario`  
**Solução:** Criar após desserialização

**Arquivo:** `backend-guinrb/Mobile/Models/DTOs/ComentarioDto.cs`

```csharp
// NO TOPO (adicionar using):
using System.Runtime.Serialization;
using Newtonsoft.Json;

// APÓS as propriedades (linha ~60):
/// <summary>
/// Popula objeto Usuario após desserialização.
/// Backend envia apenas UsuarioId e UsuarioNome.
/// </summary>
[OnDeserialized]
internal void OnDeserializedMethod(StreamingContext context)
{
    if (Usuario == null && !string.IsNullOrEmpty(UsuarioNome))
    {
        Usuario = new UsuarioResumoDto
        {
            Id = UsuarioId,
            Nome = UsuarioNome,
            NomeCompleto = UsuarioNome,
            // TipoUsuario não disponível, propriedades de cor/badge usarão padrão
        };
    }
}
```

**Tempo:** 8 minutos  
**Impacto:** ✅ Evita NullReferenceException na UI

---

### ✅ **A7. Documentar limitação de segurança em AuthService**

**Problema:** Validação de TipoUsuario apenas client-side  
**Solução:** Adicionar comentário de alerta

**Arquivo:** `backend-guinrb/Mobile/Services/Auth/AuthService.cs`

```csharp
// ANTES da validação (linha ~53):
// ⚠️ LIMITAÇÃO DE SEGURANÇA:
// Esta validação é APENAS client-side para UX.
// A segurança real DEVE estar no backend (não implementada atualmente).
// Um usuário técnico/admin pode fazer requests HTTP diretos à API.
// RECOMENDAÇÃO FUTURA: Implementar validação no backend.
if (resp.TipoUsuario != TipoUsuario.UsuarioComum)
{
    Debug.WriteLine($"[AuthService] Login negado: TipoUsuario {resp.TipoUsuario}");
    throw new UnauthorizedAccessException("Apenas usuários comuns podem acessar o aplicativo mobile.");
}
```

**Tempo:** 3 minutos  
**Impacto:** ✅ Código documentado

---

**SUBTOTAL CATEGORIA A:** 7 ações | ~28 minutos | 🟢 Risco Baixo

---

## 🔄 CATEGORIA B: ADAPTAÇÃO MOBILE (com remoção de features não suportadas)

> **Execução:** APÓS Categoria A  
> **Risco:** 🟡 MÉDIO (altera UI)  
> **Tempo:** ~30 minutos  
> **Razão:** Backend não suporta, melhor remover do que confundir usuário

---

### ⚠️ **B1. Remover campo IsInterno de CriarComentarioRequestDto**

**Problema:** Backend não aceita/ignora este campo  
**Solução:** Remover do DTO de request

**Arquivo:** `backend-guinrb/Mobile/Models/DTOs/CriarComentarioRequestDto.cs`

```csharp
// SUBSTITUIR TODO O ARQUIVO:
namespace SistemaChamados.Mobile.Models.DTOs;

/// <summary>
/// DTO para criar comentário.
/// ATENÇÃO: Backend não suporta comentários internos (IsInterno removido).
/// </summary>
public class CriarComentarioRequestDto
{
    [Required(ErrorMessage = "O texto do comentário é obrigatório")]
    [StringLength(1000, MinimumLength = 1, ErrorMessage = "O comentário deve ter entre 1 e 1000 caracteres")]
    public string Texto { get; set; } = string.Empty;
}
```

**Tempo:** 3 minutos  
**Impacto:** ✅ DTO alinhado com backend

---

### ⚠️ **B2. Marcar IsInterno como Obsoleto em ComentarioDto**

**Problema:** Backend nunca envia este campo (sempre false)  
**Solução:** Manter para desserialização, mas marcar obsoleto

**Arquivo:** `backend-guinrb/Mobile/Models/DTOs/ComentarioDto.cs`

```csharp
// LOCALIZAR (linha ~13):
public bool IsInterno { get; set; } // Comentário interno (apenas técnicos/admin)

// SUBSTITUIR POR:
/// <summary>
/// OBSOLETO: Backend não implementa comentários internos.
/// Mantido apenas para compatibilidade de desserialização.
/// Sempre será false.
/// </summary>
[Obsolete("Backend não suporta comentários internos. Sempre retorna false.")]
[JsonProperty(DefaultValueHandling = DefaultValueHandling.Populate)]
public bool IsInterno { get; set; } = false;
```

**Tempo:** 3 minutos  
**Impacto:** ✅ Código documentado, warnings ao usar

---

### ⚠️ **B3. Remover UI de comentário interno (Switch)**

**Problema:** Switch permite marcar como interno, mas não funciona  
**Solução:** Remover controle da UI

**Arquivo:** `backend-guinrb/Mobile/Views/ChamadoDetailPage.xaml`

```xml
<!-- LOCALIZAR (linhas 490-504) e REMOVER COMPLETAMENTE: -->
<HorizontalStackLayout Spacing="8"
                        IsVisible="{Binding PodeDefinirComentarioInterno}">
  <Switch IsToggled="{Binding NovoComentarioIsInterno}" />
  <VerticalStackLayout Spacing="0">
    <Label Text="Marcar como comentário interno" ... />
    <Label Text="Visível apenas para técnicos e administradores" ... />
  </VerticalStackLayout>
</HorizontalStackLayout>

<!-- OPCIONAL: Adicionar aviso no lugar -->
<Label Text="ℹ️ Todos os comentários são visíveis para técnicos e solicitantes"
       FontSize="12"
       TextColor="{DynamicResource Gray500}"
       Margin="0,8,0,0" />
```

**Tempo:** 5 minutos  
**Impacto:** ✅ Remove funcionalidade quebrada

---

### ⚠️ **B4. Atualizar ChamadoDetailViewModel**

**Problema:** ViewModel ainda usa `NovoComentarioIsInterno`  
**Solução:** Simplificar lógica de criação

**Arquivo:** `backend-guinrb/Mobile/ViewModels/ChamadoDetailViewModel.cs`

```csharp
// LOCALIZAR (linha ~415-420):
var request = new CriarComentarioRequestDto
{
    Texto = NovoComentarioTexto.Trim(),
    IsInterno = NovoComentarioIsInterno && PodeDefinirComentarioInterno
};

// SUBSTITUIR POR:
var request = new CriarComentarioRequestDto
{
    Texto = NovoComentarioTexto.Trim()
    // IsInterno removido - backend não suporta
};

// LOCALIZAR (linha ~436-438) e REMOVER:
if (!PodeDefinirComentarioInterno)
{
    NovoComentarioIsInterno = false;
}
```

**Tempo:** 5 minutos  
**Impacto:** ✅ Lógica simplificada

---

### ⚠️ **B5. Remover visual de comentário interno (Badge/Fundo)**

**Problema:** UI mostra badge "Interno" que nunca aparecerá  
**Solução:** Simplificar template visual

**Arquivo:** `backend-guinrb/Mobile/Views/ChamadoDetailPage.xaml`

```xml
<!-- LOCALIZAR (linhas 420-426) e REMOVER DataTrigger: -->
<Frame.Triggers>
  <DataTrigger TargetType="Frame"
               Binding="{Binding IsInterno}"
               Value="True">
    <Setter Property="BackgroundColor" Value="#FEF3C7" />
    <Setter Property="BorderColor" Value="#F59E0B" />
  </DataTrigger>
</Frame.Triggers>

<!-- LOCALIZAR (linhas 437-445) e REMOVER Badge: -->
<Border BackgroundColor="#F59E0B"
        StrokeThickness="0"
        StrokeShape="RoundRectangle 8"
        Padding="8,2"
        IsVisible="{Binding IsInterno}"
        HorizontalOptions="Start">
  <Label Text="Interno" ... />
</Border>
```

**Tempo:** 5 minutos  
**Impacto:** ✅ UI limpa sem elementos não funcionais

---

### ⚠️ **B6. Remover propriedades não utilizadas do ViewModel**

**Arquivo:** `backend-guinrb/Mobile/ViewModels/ChamadoDetailViewModel.cs`

```csharp
// LOCALIZAR e REMOVER (linhas ~30, 97-107):
private bool _novoComentarioIsInterno;

public bool NovoComentarioIsInterno
{
    get => _novoComentarioIsInterno;
    set
    {
        if (_novoComentarioIsInterno == value) return;
        _novoComentarioIsInterno = value;
        OnPropertyChanged();
    }
}

public bool PodeDefinirComentarioInterno => Settings.TipoUsuario == 2 || Settings.TipoUsuario == 3;
```

**Tempo:** 3 minutos  
**Impacto:** ✅ Código limpo

---

**SUBTOTAL CATEGORIA B:** 6 ações | ~24 minutos | 🟡 Risco Médio

---

## 🔧 CATEGORIA C: MELHORIAS MOBILE (Backend já suporta)

> **Execução:** APÓS Categoria B  
> **Risco:** 🟢 BAIXO  
> **Tempo:** ~20 minutos  
> **Razão:** Implementar recursos que backend já oferece mas mobile não usa

---

### ✅ **C1. Adicionar campo SlaDataExpiracao ao ChamadoDto**

**Contexto:** Backend já calcula e envia SLA, mas mobile não usa  
**Solução:** Adicionar ao DTO e exibir na UI

**Arquivo:** `backend-guinrb/Mobile/Models/DTOs/ChamadoDto.cs`

```csharp
// APÓS DataFechamento (linha ~15):
public DateTime? DataFechamento { get; set; }

// ADICIONAR:
/// <summary>
/// Data de expiração do SLA (calculada pelo backend).
/// Null se não houver SLA definido.
/// </summary>
public DateTime? SlaDataExpiracao { get; set; }

// ADICIONAR propriedades calculadas ao final da classe:
/// <summary>
/// Verifica se o SLA está violado (expirou).
/// </summary>
[JsonIgnore]
public bool SlaViolado => SlaDataExpiracao.HasValue && 
                           SlaDataExpiracao.Value < DateTime.UtcNow &&
                           Status?.Id != StatusChamado.Fechado;

/// <summary>
/// Tempo restante para o SLA em formato legível.
/// </summary>
[JsonIgnore]
public string SlaTempoRestante
{
    get
    {
        if (!SlaDataExpiracao.HasValue)
            return "Sem SLA definido";

        var diferenca = SlaDataExpiracao.Value - DateTime.UtcNow;
        
        if (diferenca.TotalSeconds < 0)
            return "⚠️ SLA Violado";
        
        if (diferenca.TotalHours < 1)
            return $"⏱️ {(int)diferenca.TotalMinutes} min restantes";
        
        if (diferenca.TotalHours < 24)
            return $"⏱️ {(int)diferenca.TotalHours}h restantes";
        
        return $"⏱️ {(int)diferenca.TotalDays}d restantes";
    }
}
```

**Tempo:** 10 minutos  
**Impacto:** ✅ Mobile exibe informação de SLA

---

### ✅ **C2. Exibir SLA na UI de detalhes do chamado**

**Arquivo:** `backend-guinrb/Mobile/Views/ChamadoDetailPage.xaml`

```xml
<!-- LOCALIZAR seção de informações do chamado e ADICIONAR: -->

<!-- Após exibição de Prioridade, adicionar: -->
<Border StrokeThickness="1"
        StrokeShape="RoundRectangle 8"
        Padding="12"
        Margin="0,8"
        IsVisible="{Binding Chamado.SlaDataExpiracao, Converter={StaticResource IsNotNullConverter}}">
  <Border.Stroke>
    <SolidColorBrush Color="{AppThemeBinding Light={StaticResource Gray300}, Dark={StaticResource Gray600}}" />
  </Border.Stroke>
  
  <VerticalStackLayout Spacing="4">
    <Label Text="📅 SLA (Tempo de Resposta)"
           FontSize="12"
           TextColor="{DynamicResource Gray500}" />
    <Label Text="{Binding Chamado.SlaTempoRestante}"
           FontSize="14"
           FontAttributes="Bold"
           TextColor="{DynamicResource PrimaryDarkText}" />
    <Label Text="{Binding Chamado.SlaDataExpiracao, StringFormat='Expira em: {0:dd/MM/yyyy HH:mm}'}"
           FontSize="12"
           TextColor="{DynamicResource Gray600}"
           IsVisible="{Binding Chamado.SlaDataExpiracao, Converter={StaticResource IsNotNullConverter}}" />
  </VerticalStackLayout>
</Border>
```

**Tempo:** 8 minutos  
**Impacto:** ✅ Usuário vê prazo de atendimento

---

### ✅ **C3. Adicionar badge de SLA violado na lista**

**Arquivo:** `backend-guinrb/Mobile/Views/MeusChamadosPage.xaml` (ou lista principal)

```xml
<!-- No template de item da lista, adicionar: -->
<Border BackgroundColor="#FEE2E2"
        StrokeThickness="0"
        StrokeShape="RoundRectangle 8"
        Padding="6,2"
        IsVisible="{Binding SlaViolado}"
        HorizontalOptions="Start">
  <Label Text="⚠️ SLA Violado"
         FontSize="11"
         TextColor="#DC2626"
         FontAttributes="Bold" />
</Border>
```

**Tempo:** 5 minutos  
**Impacto:** ✅ Alerta visual para chamados atrasados

---

**SUBTOTAL CATEGORIA C:** 3 ações | ~23 minutos | 🟢 Risco Baixo

---

## ⚙️ CATEGORIA D: BACKEND (Opcional - Melhorias Futuras)

> **Execução:** FUTURO (não urgente)  
> **Risco:** 🟡 MÉDIO  
> **Tempo:** ~2-3 horas  
> **Razão:** Melhorias de segurança e arquitetura

---

### 🔮 **D1. Implementar validação de TipoUsuario no backend**

**Problema:** Segurança depende apenas do cliente  
**Impacto:** 🟡 Vulnerável a bypass

**Arquivo:** `backend-guinrb/Backend/API/Controllers/ChamadosController.cs`

```csharp
// Adicionar em CriarChamado, antes da lógica:
[HttpPost]
[Authorize]
public async Task<IActionResult> CriarChamado([FromBody] CriarChamadoRequestDto request)
{
    // Validação de tipo de usuário
    var tipoUsuarioStr = User.FindFirst("TipoUsuario")?.Value;
    if (string.IsNullOrEmpty(tipoUsuarioStr) || tipoUsuarioStr != "1")
    {
        return StatusCode(403, new { 
            error = "Apenas usuários comuns podem criar chamados via aplicativo mobile.",
            message = "Use o portal web para criar chamados como técnico/admin."
        });
    }
    
    // ... resto do código
}
```

**Prioridade:** ⚠️ MÉDIA (recomendado antes de produção)

---

### 🔮 **D2. Mover verificação de SLA para background job**

**Problema:** Verificação acontece em GET (side-effect)  
**Impacto:** 🟡 Performance e arquitetura

**Solução:** Implementar Hangfire ou similar

```csharp
// Criar job recorrente
RecurringJob.AddOrUpdate(
    "verificar-sla-chamados",
    () => slaService.VerificarChamadosViolados(),
    Cron.Minutely // Executa a cada minuto
);
```

**Prioridade:** 🟢 BAIXA (otimização, não funcional)

---

### 🔮 **D3. Adicionar campo IsInterno no backend (se necessário)**

**Contexto:** Se realmente precisar de comentários internos  
**Impacto:** 🟡 Feature completa

**Arquivos:**
- `Backend/Core/Entities/Comentario.cs` - Adicionar propriedade
- `Backend/Application/DTOs/CriarComentarioDto.cs` - Adicionar campo
- Migration do banco de dados
- Lógica de filtragem por tipo de usuário

**Prioridade:** 🟢 BAIXA (funcionalidade nova, não bug)

---

**SUBTOTAL CATEGORIA D:** 3 ações | ~2-3 horas | 🟡 Risco Médio | ⏰ FUTURO

---

## 📊 RESUMO EXECUTIVO

### Distribuição de Esforço:

| Categoria | Foco | Ações | Tempo | Quando | Prioridade |
|-----------|------|-------|-------|--------|------------|
| **A** | Correções Mobile | 7 | ~28 min | AGORA | 🔴 CRÍTICO |
| **B** | Adaptação Mobile | 6 | ~24 min | DEPOIS | 🟡 ALTO |
| **C** | Melhorias Mobile | 3 | ~23 min | DEPOIS | 🟢 MÉDIO |
| **D** | Backend Opcional | 3 | ~2-3h | FUTURO | ⚪ BAIXO |

**Total Mobile (A+B+C):** 16 ações | ~75 minutos | Executável HOJE  
**Total Backend (D):** 3 ações | 2-3 horas | FUTURO

---

## 🎯 ESTRATÉGIA BALANCEADA

### ✅ **FOCO NO MOBILE (95% do trabalho):**
- Corrige bugs críticos (StatusId, Datas)
- Remove funcionalidades não suportadas (IsInterno)
- Implementa features que backend JÁ oferece (SLA)
- Adapta DTOs à realidade da API

### ⚠️ **BACKEND quando necessário (5% do trabalho):**
- Apenas melhorias futuras de segurança
- Otimizações de performance (não bloqueiam)
- Features completamente novas (comentários internos)

---

## 🚀 ROTEIRO DE EXECUÇÃO RECOMENDADO

### **HOJE (10/11/2025) - 75 minutos:**

```
[09:00-09:28] ✅ CATEGORIA A - Correções Mobile
  ├─ A1: StatusId 5→4 (2 min)
  ├─ A2: Criar constantes (5 min)
  ├─ A3: Usar constantes em ChamadoService (3 min)
  ├─ A4: Usar constantes em AuthService (2 min)
  ├─ A5: Unificar DataHora/DataCriacao (5 min)
  ├─ A6: Adapter para Usuario (8 min)
  └─ A7: Documentar segurança (3 min)

[09:28-09:52] ⚠️ CATEGORIA B - Adaptação Mobile
  ├─ B1: Remover IsInterno do request DTO (3 min)
  ├─ B2: Marcar IsInterno obsoleto (3 min)
  ├─ B3: Remover Switch da UI (5 min)
  ├─ B4: Simplificar ViewModel (5 min)
  ├─ B5: Remover visual de interno (5 min)
  └─ B6: Limpar propriedades (3 min)

[09:52-10:15] ✅ CATEGORIA C - Melhorias Mobile
  ├─ C1: Adicionar SlaDataExpiracao ao DTO (10 min)
  ├─ C2: Exibir SLA na UI de detalhes (8 min)
  └─ C3: Badge de SLA violado (5 min)

[10:15-10:25] 🧪 Validação Final
  ├─ dotnet clean + build
  ├─ Verificar warnings
  └─ Gerar APK

[10:25-10:45] 📱 Testes Básicos
  ├─ Instalar APK
  ├─ Login → Criar chamado → Comentar → Fechar
  └─ Verificar SLA sendo exibido
```

**Total:** ~1h15min

---

### **FUTURO (quando necessário) - 2-3 horas:**

```
[Data TBD] 🔮 CATEGORIA D - Backend Opcional
  ├─ D1: Validação TipoUsuario no backend (1h)
  ├─ D2: Background job para SLA (1h)
  └─ D3: Implementar IsInterno completo (1h)
```

---

## ✅ CRITÉRIOS DE SUCESSO

### Após Categoria A+B+C (Mobile):
- [ ] Chamados fecham com StatusId=4 ✅
- [ ] Comentários sem campo IsInterno ✅
- [ ] Datas exibidas corretamente ✅
- [ ] SLA visível na UI ✅
- [ ] Nenhum warning de [Obsolete] ✅
- [ ] UI limpa sem elementos quebrados ✅
- [ ] Build sem erros ✅
- [ ] APK instalável ✅

### Após Categoria D (Backend - Futuro):
- [ ] Validação de segurança no servidor ✅
- [ ] Performance otimizada (SLA em background) ✅
- [ ] Comentários internos funcionais (se implementado) ✅

---

## 💡 VANTAGENS DESTA ABORDAGEM

1. **95% Mobile:** Resolve imediatamente sem tocar backend
2. **Backend quando faz sentido:** Apenas melhorias futuras
3. **SLA implementado:** Aproveita que backend já envia
4. **IsInterno removido:** Evita confusão (backend não tem)
5. **Pronto para produção:** Categoria A+B+C deixa app funcional
6. **Categoria D opcional:** Melhorias incrementais depois

---

**Conclusão:** Este plano maximiza mudanças no mobile (~75 min) e deixa backend para melhorias futuras não-bloqueantes (~2-3h quando necessário).

---

**Quer que eu execute as Categorias A, B e C agora? (~75 minutos de trabalho)**
