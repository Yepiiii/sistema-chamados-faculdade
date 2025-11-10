# 🎯 PLANO DE AÇÃO SEQUENCIAL - Correções Mobile

**Objetivo:** Corrigir incompatibilidades entre mobile e backend  
**Estratégia:** Passos ordenados logicamente, do mais simples ao mais complexo  
**Tempo Total:** ~75 minutos  
**Data:** 10/11/2025

---

## 📋 ORDEM DE EXECUÇÃO (20 passos)

---

## 🔧 ETAPA 1: PREPARAÇÃO (5 min)

### **PASSO 1: Fazer backup do código atual**

```powershell
# Criar branch de backup
cd backend-guinrb
git checkout -b backup-antes-correcoes
git add .
git commit -m "Backup antes das correções mobile"

# Voltar para branch android
git checkout android
```

**Tempo:** 2 min  
**Por quê:** Segurança - permite reverter se algo der errado

---

### **PASSO 2: Validar que o projeto compila**

```powershell
cd Mobile
dotnet clean
dotnet build SistemaChamados.Mobile.csproj -c Release
```

**Validação:** Exit code deve ser 0  
**Tempo:** 3 min  
**Por quê:** Garantir que estamos partindo de um estado funcional

---

## 🎨 ETAPA 2: CRIAR CONSTANTES (8 min)

### **PASSO 3: Adicionar constantes de Status e TipoUsuario**

**Arquivo:** `Mobile/Helpers/Constants.cs`

**Localizar o final do arquivo e adicionar:**

```csharp
    /// <summary>
    /// IDs de Status de Chamados (sincronizado com banco de dados)
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
}
```

**Tempo:** 3 min  
**Por quê:** Eliminar magic numbers antes de usá-los

---

### **PASSO 4: Atualizar ChamadoService para usar constantes**

**Arquivo:** `Mobile/Services/Chamados/ChamadoService.cs`

**Adicionar using no topo:**
```csharp
using SistemaChamados.Mobile.Helpers;
```

**Localizar método Close (linha ~77):**
```csharp
    public Task<ChamadoDto?> Close(int id)
    {
        // ⚠️ FIX: Backend não tem endpoint /fechar
        // Usa PUT /chamados/{id} com StatusId = 5 (Fechado)
        var atualizacao = new AtualizarChamadoDto
        {
            StatusId = 5 // ID do status "Fechado" no banco
        };
        return _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", atualizacao);
    }
```

**Substituir por:**
```csharp
    public Task<ChamadoDto?> Close(int id)
    {
        // ✅ Corrigido: StatusId 4 = Fechado (não 5 que é Violado/SLA)
        var atualizacao = new AtualizarChamadoDto
        {
            StatusId = StatusChamado.Fechado
        };
        return _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", atualizacao);
    }
```

**Tempo:** 3 min  
**Por quê:** Corrige bug CRÍTICO - chamados estavam sendo fechados com status errado

---

### **PASSO 5: Atualizar AuthService para usar constantes**

**Arquivo:** `Mobile/Services/Auth/AuthService.cs`

**Adicionar using no topo:**
```csharp
using SistemaChamados.Mobile.Helpers;
```

**Localizar (linha ~53):**
```csharp
            // Verifica se o usuário é do tipo 1 (Colaborador/Usuário comum)
            if (resp.TipoUsuario != 1)
            {
```

**Substituir por:**
```csharp
            // ⚠️ LIMITAÇÃO: Validação apenas client-side (UX).
            // Segurança real deve estar no backend (não implementada).
            // Técnico/Admin pode fazer requests HTTP diretos à API.
            if (resp.TipoUsuario != TipoUsuario.UsuarioComum)
            {
```

**Tempo:** 2 min  
**Por quê:** Código mais legível + documentação de limitação de segurança

---

## 📦 ETAPA 3: CORRIGIR DTOs DE COMENTÁRIOS (15 min)

### **PASSO 6: Simplificar CriarComentarioRequestDto**

**Arquivo:** `Mobile/Models/DTOs/CriarComentarioRequestDto.cs`

**Substituir TODO o conteúdo por:**
```csharp
using System.ComponentModel.DataAnnotations;

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

**Tempo:** 2 min  
**Por quê:** Backend ignora IsInterno, melhor remover para evitar confusão

---

### **PASSO 7: Ajustar ComentarioDto - Parte 1 (DataHora)**

**Arquivo:** `Mobile/Models/DTOs/ComentarioDto.cs`

**Localizar (linhas ~9-10):**
```csharp
    public DateTime DataCriacao { get; set; }
    public DateTime DataHora { get; set; }
```

**Substituir por:**
```csharp
    [JsonProperty("DataCriacao")]
    public DateTime DataCriacao { get; set; }
    
    /// <summary>
    /// Alias para DataCriacao (compatibilidade com UI).
    /// Backend envia apenas DataCriacao.
    /// </summary>
    [JsonIgnore]
    public DateTime DataHora => DataCriacao;
```

**Tempo:** 3 min  
**Por quê:** Backend não envia DataHora separado, evita data 01/01/0001

---

### **PASSO 8: Ajustar ComentarioDto - Parte 2 (IsInterno)**

**Arquivo:** `Mobile/Models/DTOs/ComentarioDto.cs`

**Localizar (linha ~13):**
```csharp
    public bool IsInterno { get; set; } // Comentário interno (apenas técnicos/admin)
```

**Substituir por:**
```csharp
    /// <summary>
    /// OBSOLETO: Backend não implementa comentários internos.
    /// Mantido apenas para compatibilidade de desserialização.
    /// Sempre será false.
    /// </summary>
    [Obsolete("Backend não suporta comentários internos. Sempre retorna false.")]
    [JsonProperty(DefaultValueHandling = DefaultValueHandling.Populate)]
    public bool IsInterno { get; set; } = false;
```

**Tempo:** 2 min  
**Por quê:** Documenta que campo não funciona, evita uso incorreto

---

### **PASSO 9: Ajustar ComentarioDto - Parte 3 (Adapter Usuario)**

**Arquivo:** `Mobile/Models/DTOs/ComentarioDto.cs`

**Adicionar usings no topo:**
```csharp
using System.Runtime.Serialization;
using Newtonsoft.Json;
```

**Adicionar no final da classe (após BadgeTipoUsuario):**
```csharp
    /// <summary>
    /// Popula objeto Usuario automaticamente após desserialização.
    /// Backend envia apenas UsuarioId e UsuarioNome (strings).
    /// </summary>
    [OnDeserialized]
    internal void OnDeserializedMethod(StreamingContext context)
    {
        // Se Usuario ainda é null e temos dados do usuário, criar objeto
        if (Usuario == null && !string.IsNullOrEmpty(UsuarioNome))
        {
            Usuario = new UsuarioResumoDto
            {
                Id = UsuarioId,
                Nome = UsuarioNome,
                NomeCompleto = UsuarioNome,
                // TipoUsuario não disponível - propriedades de cor/badge usarão padrão
            };
        }
    }
```

**Tempo:** 5 min  
**Por quê:** Evita NullReferenceException ao acessar Usuario.Nome na UI

---

### **PASSO 10: Atualizar ViewModel - Remover lógica de IsInterno**

**Arquivo:** `Mobile/ViewModels/ChamadoDetailViewModel.cs`

**Localizar método AdicionarComentarioAsync (linha ~415):**
```csharp
            var request = new CriarComentarioRequestDto
            {
                Texto = NovoComentarioTexto.Trim(),
                IsInterno = NovoComentarioIsInterno && PodeDefinirComentarioInterno
            };
```

**Substituir por:**
```csharp
            var request = new CriarComentarioRequestDto
            {
                Texto = NovoComentarioTexto.Trim()
                // IsInterno removido - backend não suporta
            };
```

**Localizar (linhas ~436-438):**
```csharp
            if (!PodeDefinirComentarioInterno)
            {
                NovoComentarioIsInterno = false;
            }
```

**REMOVER estas 4 linhas completamente.**

**Tempo:** 3 min  
**Por quê:** Simplifica lógica, remove código morto

---

## 🎨 ETAPA 4: LIMPAR UI (15 min)

### **PASSO 11: Remover Switch "Comentário Interno"**

**Arquivo:** `Mobile/Views/ChamadoDetailPage.xaml`

**Localizar (linhas ~490-504):**
```xml
            <HorizontalStackLayout Spacing="8"
                                    IsVisible="{Binding PodeDefinirComentarioInterno}">
              <Switch IsToggled="{Binding NovoComentarioIsInterno}" />
              <VerticalStackLayout Spacing="0">
                <Label Text="Marcar como comentário interno"
                       FontSize="13"
                       TextColor="{DynamicResource Gray700}" />
                <Label Text="Visível apenas para técnicos e administradores"
                       FontSize="11"
                       TextColor="{DynamicResource Gray500}" />
              </VerticalStackLayout>
            </HorizontalStackLayout>
```

**REMOVER completamente e substituir por:**
```xml
            <!-- Info: Todos os comentários são públicos (backend não suporta internos) -->
            <Label Text="ℹ️ Comentários visíveis para solicitantes e técnicos"
                   FontSize="12"
                   TextColor="{DynamicResource Gray500}"
                   Margin="0,4,0,0" />
```

**Tempo:** 5 min  
**Por quê:** Remove funcionalidade que não funciona + informa usuário

---

### **PASSO 12: Remover triggers de fundo amarelo (comentário interno)**

**Arquivo:** `Mobile/Views/ChamadoDetailPage.xaml`

**Localizar (linhas ~420-426):**
```xml
                    <Frame.Triggers>
                      <DataTrigger TargetType="Frame"
                                   Binding="{Binding IsInterno}"
                                   Value="True">
                        <Setter Property="BackgroundColor" Value="#FEF3C7" />
                        <Setter Property="BorderColor" Value="#F59E0B" />
                      </DataTrigger>
                    </Frame.Triggers>
```

**REMOVER completamente (incluindo tags de abertura/fechamento).**

**Tempo:** 3 min  
**Por quê:** Visual de "interno" nunca aparecerá, código morto

---

### **PASSO 13: Remover badge "Interno"**

**Arquivo:** `Mobile/Views/ChamadoDetailPage.xaml`

**Localizar (linhas ~437-445):**
```xml
                        <Border BackgroundColor="#F59E0B"
                                StrokeThickness="0"
                                StrokeShape="RoundRectangle 8"
                                Padding="8,2"
                                IsVisible="{Binding IsInterno}"
                                HorizontalOptions="Start">
                          <Label Text="Interno"
                                 FontSize="12"
                                 TextColor="White"
                                 FontAttributes="Bold" />
                        </Border>
```

**REMOVER completamente.**

**Tempo:** 2 min  
**Por quê:** Badge nunca ficará visível (IsInterno sempre false)

---

### **PASSO 14: Remover propriedades do ViewModel**

**Arquivo:** `Mobile/ViewModels/ChamadoDetailViewModel.cs`

**Localizar e REMOVER (linha ~30):**
```csharp
    private bool _novoComentarioIsInterno;
```

**Localizar e REMOVER (linhas ~97-107):**
```csharp
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

**Tempo:** 5 min  
**Por quê:** Limpeza completa de código não utilizado

---

## 🚀 ETAPA 5: IMPLEMENTAR SLA (20 min)

### **PASSO 15: Adicionar propriedades de SLA no ChamadoDto**

**Arquivo:** `Mobile/Models/DTOs/ChamadoDto.cs`

**Adicionar using no topo:**
```csharp
using SistemaChamados.Mobile.Helpers;
```

**Localizar (após DataFechamento, linha ~15):**
```csharp
    public DateTime? DataFechamento { get; set; }
    
    // Usuário que fechou o chamado
    public FechadoPor? FechadoPor { get; set; }
```

**ADICIONAR após DataFechamento:**
```csharp
    public DateTime? DataFechamento { get; set; }
    
    /// <summary>
    /// Data de expiração do SLA (calculada pelo backend).
    /// Null se não houver SLA definido.
    /// </summary>
    public DateTime? SlaDataExpiracao { get; set; }
    
    // Usuário que fechou o chamado
```

**Adicionar ao final da classe (antes do fechamento):**
```csharp
    /// <summary>
    /// Verifica se o SLA está violado (expirou e não está fechado).
    /// </summary>
    [JsonIgnore]
    public bool SlaViolado => SlaDataExpiracao.HasValue && 
                               SlaDataExpiracao.Value < DateTime.UtcNow &&
                               Status?.Id != StatusChamado.Fechado &&
                               Status?.Id != StatusChamado.Violado;

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
            
            if (diferenca.TotalMinutes < 60)
                return $"⏱️ {(int)diferenca.TotalMinutes} min restantes";
            
            if (diferenca.TotalHours < 24)
                return $"⏱️ {(int)diferenca.TotalHours}h {(int)diferenca.Minutes}min restantes";
            
            if (diferenca.TotalDays < 7)
                return $"⏱️ {(int)diferenca.TotalDays}d {diferenca.Hours}h restantes";
            
            return $"⏱️ {(int)diferenca.TotalDays} dias restantes";
        }
    }

    /// <summary>
    /// Cor de alerta do SLA (vermelho se violado, amarelo se próximo, verde se ok).
    /// </summary>
    [JsonIgnore]
    public string SlaCorAlerta
    {
        get
        {
            if (!SlaDataExpiracao.HasValue)
                return "#6B7280"; // Gray

            var diferenca = SlaDataExpiracao.Value - DateTime.UtcNow;
            
            if (diferenca.TotalSeconds < 0)
                return "#DC2626"; // Red (violado)
            
            if (diferenca.TotalHours < 2)
                return "#F59E0B"; // Amber (crítico)
            
            if (diferenca.TotalHours < 24)
                return "#FBBF24"; // Yellow (atenção)
            
            return "#10B981"; // Green (ok)
        }
    }
```

**Tempo:** 10 min  
**Por quê:** Backend já envia SlaDataExpiracao, mobile precisa usar

---

### **PASSO 16: Exibir SLA na UI de detalhes**

**Arquivo:** `Mobile/Views/ChamadoDetailPage.xaml`

**Localizar a seção de informações do chamado (após Prioridade) e adicionar:**

```xml
          <!-- SLA (Prazo de Atendimento) -->
          <Border StrokeThickness="1"
                  StrokeShape="RoundRectangle 8"
                  Padding="12"
                  Margin="0,8"
                  IsVisible="{Binding Chamado.SlaDataExpiracao, Converter={StaticResource IsNotNullConverter}}">
            <Border.Stroke>
              <SolidColorBrush Color="{Binding Chamado.SlaCorAlerta}" />
            </Border.Stroke>
            
            <VerticalStackLayout Spacing="4">
              <Label Text="📅 SLA (Prazo de Atendimento)"
                     FontSize="12"
                     TextColor="{DynamicResource Gray500}" />
              <Label Text="{Binding Chamado.SlaTempoRestante}"
                     FontSize="14"
                     FontAttributes="Bold">
                <Label.TextColor>
                  <SolidColorBrush Color="{Binding Chamado.SlaCorAlerta}" />
                </Label.TextColor>
              </Label>
              <Label Text="{Binding Chamado.SlaDataExpiracao, StringFormat='Expira em: {0:dd/MM/yyyy HH:mm}'}"
                     FontSize="11"
                     TextColor="{DynamicResource Gray600}" />
            </VerticalStackLayout>
          </Border>
```

**Tempo:** 8 min  
**Por quê:** Usuário precisa ver prazo de atendimento

---

### **PASSO 17: Adicionar badge de SLA na lista de chamados**

**Arquivo:** `Mobile/Views/MeusChamadosPage.xaml` (ou onde lista chamados)

**Procurar o template de item da lista e adicionar após o badge de status:**

```xml
              <!-- Badge SLA Violado -->
              <Border BackgroundColor="#FEE2E2"
                      StrokeThickness="0"
                      StrokeShape="RoundRectangle 8"
                      Padding="6,3"
                      IsVisible="{Binding SlaViolado}"
                      HorizontalOptions="Start"
                      Margin="0,4,0,0">
                <Label Text="⚠️ SLA Violado"
                       FontSize="10"
                       TextColor="#DC2626"
                       FontAttributes="Bold" />
              </Border>
```

**Tempo:** 5 min  
**Por quê:** Destaque visual para chamados com prazo vencido

---

## ✅ ETAPA 6: VALIDAÇÃO (12 min)

### **PASSO 18: Rebuild completo**

```powershell
cd Mobile
dotnet clean
dotnet build SistemaChamados.Mobile.csproj -c Release --no-incremental
```

**Validação:**
- Exit code deve ser 0
- Verificar warnings relacionados a IsInterno (esperado [Obsolete])
- Não deve ter erros de compilação

**Tempo:** 5 min  
**Por quê:** Garantir que todas as mudanças compilam

---

### **PASSO 19: Verificar warnings e ajustar**

```powershell
# Ver warnings detalhados
dotnet build SistemaChamados.Mobile.csproj -c Release -v minimal | Select-String "warning"
```

**Ajustes esperados:**
- Warnings de `[Obsolete]` em IsInterno → OK (esperado)
- Warnings de binding em XAML → Verificar se IsInterno foi removido corretamente

**Tempo:** 5 min  
**Por quê:** Garantir qualidade do código

---

### **PASSO 20: Gerar APK final**

```powershell
dotnet publish SistemaChamados.Mobile.csproj `
    -f net8.0-android `
    -c Release `
    -p:AndroidPackageFormat=apk `
    -p:AndroidKeyStore=true `
    -p:AndroidSigningKeyStore=myapp.keystore `
    -p:AndroidSigningKeyAlias=myapp `
    -p:AndroidSigningStorePass=senha123 `
    -p:AndroidSigningKeyPass=senha123
```

**Validação:**
```powershell
# Verificar que APK foi gerado
ls bin\Release\net8.0-android\*.apk
```

**Tempo:** 5 min  
**Por quê:** APK atualizado para instalação

---

## 📊 CHECKLIST FINAL

### ✅ Antes de considerar concluído:

- [ ] **PASSO 1:** Branch de backup criado
- [ ] **PASSO 2:** Build inicial passou
- [ ] **PASSO 3:** Constantes criadas em Constants.cs
- [ ] **PASSO 4:** ChamadoService usa StatusChamado.Fechado
- [ ] **PASSO 5:** AuthService usa TipoUsuario.UsuarioComum
- [ ] **PASSO 6:** CriarComentarioRequestDto sem IsInterno
- [ ] **PASSO 7:** DataHora é propriedade calculada
- [ ] **PASSO 8:** IsInterno marcado como [Obsolete]
- [ ] **PASSO 9:** Adapter [OnDeserialized] criado
- [ ] **PASSO 10:** ViewModel sem lógica de IsInterno
- [ ] **PASSO 11:** Switch removido do XAML
- [ ] **PASSO 12:** Triggers de fundo amarelo removidos
- [ ] **PASSO 13:** Badge "Interno" removido
- [ ] **PASSO 14:** Propriedades do ViewModel removidas
- [ ] **PASSO 15:** SlaDataExpiracao adicionado ao DTO
- [ ] **PASSO 16:** SLA exibido na UI de detalhes
- [ ] **PASSO 17:** Badge de SLA na lista
- [ ] **PASSO 18:** Rebuild passou sem erros
- [ ] **PASSO 19:** Warnings verificados e OK
- [ ] **PASSO 20:** APK gerado com sucesso

---

## 🎯 RESUMO POR ETAPA

| Etapa | Descrição | Passos | Tempo | Risco |
|-------|-----------|--------|-------|-------|
| **1** | Preparação | 1-2 | 5 min | 🟢 Baixo |
| **2** | Constantes | 3-5 | 8 min | 🟢 Baixo |
| **3** | DTOs Comentários | 6-10 | 15 min | 🟢 Baixo |
| **4** | Limpar UI | 11-14 | 15 min | 🟡 Médio |
| **5** | Implementar SLA | 15-17 | 20 min | 🟢 Baixo |
| **6** | Validação | 18-20 | 12 min | 🟢 Baixo |
| **TOTAL** | - | **20 passos** | **~75 min** | 🟢 Baixo |

---

## 🚀 COMO EXECUTAR

### Opção 1: Manual (você executa)
Siga os 20 passos acima, um por um.

### Opção 2: Automático (eu executo)
Diga "execute o plano" e farei todas as 20 ações sequencialmente.

---

## 💡 LÓGICA DA ORDENAÇÃO

**Por que esta ordem?**

1. **Preparação (1-2):** Segurança primeiro (backup)
2. **Constantes (3-5):** Base para todos os outros passos
3. **DTOs (6-10):** Corrigir contratos de dados antes da UI
4. **UI (11-14):** Remover elementos que dependem de DTOs já corrigidos
5. **SLA (15-17):** Adicionar features novas após limpeza
6. **Validação (18-20):** Testar tudo ao final

**Dependências:**
- Passo 4 depende de 3 (constantes)
- Passo 5 depende de 3 (constantes)
- Passos 11-14 dependem de 6-10 (DTOs corrigidos)
- Passo 15 depende de 3 (StatusChamado)
- Passos 18-20 dependem de todos anteriores

---

**Quer que eu execute os 20 passos agora?**
