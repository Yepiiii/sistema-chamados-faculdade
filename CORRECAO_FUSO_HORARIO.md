# 🕐 Correção de Fuso Horário (UTC vs Local)

Data: 20 de outubro de 2025 - 16:55 BRT

---

## 🐛 Problema Identificado

### Sintoma
- Chamados criados às **16:55** estavam sendo exibidos como **19:54**
- Diferença de **3 horas** entre o horário real e o horário exibido
- Afetava: DataAbertura, DataFechamento, comentários

### Causa Raiz
1. **API Backend:** Salva todas as datas em **UTC** (`DateTime.UtcNow`)
2. **Mobile App:** Exibia datas direto **sem conversão** para o fuso horário local
3. **Resultado:** Brasil (UTC-3) via datas 3h adiantadas

### Arquivos Afetados
```
API:
✅ ChamadosController.cs → DateTime.UtcNow (CORRETO)

Mobile (ANTES DA CORREÇÃO):
❌ ChamadoDetailPage.xaml → DataAbertura sem converter
❌ DashboardPage.xaml → DataAbertura sem converter  
❌ ChamadosListPage.xaml → DataAbertura sem converter
❌ ComentarioDto.cs → DataHora sem converter
```

---

## ✅ Solução Implementada

### 1. Criado Value Converter Global

**Arquivo:** `SistemaChamados.Mobile/Converters/UtcToLocalDateTimeConverter.cs`

```csharp
public class UtcToLocalDateTimeConverter : IValueConverter
{
    public object? Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        if (value is DateTime dateTime)
        {
            // Se a data já tem Kind definido como UTC, converte direto
            if (dateTime.Kind == DateTimeKind.Utc)
                return dateTime.ToLocalTime();
            
            // Se não tem Kind (Unspecified), assume UTC
            if (dateTime.Kind == DateTimeKind.Unspecified)
                return DateTime.SpecifyKind(dateTime, DateTimeKind.Utc).ToLocalTime();
            
            // Já é Local
            return dateTime;
        }
        return value;
    }

    public object? ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        // Converte de volta para UTC ao enviar para API
        if (value is DateTime dateTime && dateTime.Kind == DateTimeKind.Local)
            return dateTime.ToUniversalTime();
        
        return value;
    }
}
```

**Por que funciona:**
- `DateTime.UtcNow` da API retorna `DateTimeKind.Utc`
- JSON deserializa como `DateTimeKind.Unspecified` (sem timezone)
- Converter detecta e força conversão para `Local`
- `.ToLocalTime()` aplica o offset do sistema operacional automaticamente

---

### 2. Registrado Converter Globalmente

**Arquivo:** `App.xaml`

```xml
<Application.Resources>
  <ResourceDictionary>
    <!-- Conversores -->
    <converters:UtcToLocalDateTimeConverter x:Key="UtcToLocalConverter" />
  </ResourceDictionary>
</Application.Resources>
```

---

### 3. Aplicado Converter em Todas as Views

#### ✅ ChamadoDetailPage.xaml

**ANTES:**
```xml
<Label Text="{Binding Chamado.DataAbertura, StringFormat='{0:dd/MM/yyyy HH:mm}'}" />
<Label Text="{Binding Chamado.DataFechamento, StringFormat='{0:dd/MM/yyyy HH:mm}'}" />
```

**DEPOIS:**
```xml
<Label Text="{Binding Chamado.DataAbertura, 
              Converter={StaticResource UtcToLocalConverter}, 
              StringFormat='{0:dd/MM/yyyy HH:mm}'}" />

<Label Text="{Binding Chamado.DataFechamento, 
              Converter={StaticResource UtcToLocalConverter}, 
              StringFormat='{0:dd/MM/yyyy HH:mm}'}" />
```

---

#### ✅ DashboardPage.xaml

**ANTES:**
```xml
<Span Text="{Binding DataAbertura, StringFormat='{0:dd/MM/yyyy HH:mm}'}" />
```

**DEPOIS:**
```xml
<Span Text="{Binding DataAbertura, 
            Converter={StaticResource UtcToLocalConverter}, 
            StringFormat='{0:dd/MM/yyyy HH:mm}'}" />
```

---

#### ✅ ChamadosListPage.xaml

**ANTES:**
```xml
<Label Text="{Binding DataAbertura, StringFormat='📅 {0:dd/MM/yy HH:mm}'}" />
<Label Text="{Binding DataFechamento, StringFormat='✅ {0:dd/MM/yy}'}" />
```

**DEPOIS:**
```xml
<Label Text="{Binding DataAbertura, 
              Converter={StaticResource UtcToLocalConverter}, 
              StringFormat='📅 {0:dd/MM/yy HH:mm}'}" />

<Label Text="{Binding DataFechamento, 
              Converter={StaticResource UtcToLocalConverter}, 
              StringFormat='✅ {0:dd/MM/yy}'}" />
```

---

### 4. Atualizado ComentarioDto para Converter Internamente

**Arquivo:** `Models/DTOs/ComentarioDto.cs`

**ANTES:**
```csharp
public string DataHoraFormatada => DataHora.ToString("dd/MM/yyyy às HH:mm");

public string TempoRelativo
{
    get
    {
        var diferenca = DateTime.Now - DataHora;
        // ... calcula tempo relativo
    }
}
```

**DEPOIS:**
```csharp
private DateTime DataHoraLocal
{
    get
    {
        // Se a data é UTC, converte para local
        if (DataHora.Kind == DateTimeKind.Utc)
            return DataHora.ToLocalTime();
        
        // Se não tem Kind definido, assume UTC
        if (DataHora.Kind == DateTimeKind.Unspecified)
            return DateTime.SpecifyKind(DataHora, DateTimeKind.Utc).ToLocalTime();
        
        return DataHora;
    }
}

public string DataHoraFormatada => DataHoraLocal.ToString("dd/MM/yyyy às HH:mm");

public string TempoRelativo
{
    get
    {
        var diferenca = DateTime.Now - DataHoraLocal;
        // ... calcula tempo relativo com data local
    }
}
```

**Por que no DTO:**
- Comentários usam `DataHoraFormatada` e `TempoRelativo`
- Ambos precisam da data **local** para cálculos corretos
- Conversão interna evita duplicação de lógica

---

## 🧪 Como Testar

### Teste 1: Criar Novo Chamado

1. **Antes de criar:**
   - Anote o horário atual do seu computador: `16:55` (exemplo)

2. **Criar chamado:**
   - Dashboard → "+" → Preencher → "Criar Chamado"

3. **Verificar horário:**
   - Na lista de chamados, verifique a data de abertura
   - **Esperado:** `📅 20/10/25 16:55` ✅
   - **Antes:** `📅 20/10/25 19:55` ❌

4. **Verificar na página de detalhes:**
   - Abrir o chamado
   - **Esperado:** `Abertura: 20/10/2025 16:55` ✅

---

### Teste 2: Comentários com Horário Local

1. **Adicionar comentário:**
   - Abrir um chamado
   - Adicionar um comentário às `16:56`

2. **Verificar formatação:**
   - **Esperado:** `20/10/2025 às 16:56` ✅
   - **Antes:** `20/10/2025 às 19:56` ❌

3. **Verificar tempo relativo:**
   - Se criado há 2 minutos: `há 2 min` ✅
   - Se criado há 1 hora: `há 1h` ✅

---

### Teste 3: Diferentes Fusos Horários

**Brasil:**
- UTC-3 (Brasília): `-3 horas`
- Chamado criado: `2025-10-20 19:55:00 UTC`
- Exibido: `2025-10-20 16:55:00 BRT` ✅

**Outros Fusos (se testar em outro local):**
- UTC+0 (Londres): `19:55` ✅
- UTC-5 (Nova York): `14:55` ✅
- UTC+9 (Tóquio): `04:55` (dia seguinte) ✅

---

## 📊 Comparação Antes vs Depois

### Exemplo Real (Brasil - UTC-3)

| Ação | Horário Real | API Salva (UTC) | **ANTES** (Exibido) | **DEPOIS** (Exibido) |
|------|--------------|-----------------|---------------------|----------------------|
| Criar chamado | 16:55 BRT | 19:55 UTC | ❌ 19:55 | ✅ 16:55 |
| Adicionar comentário | 17:10 BRT | 20:10 UTC | ❌ 20:10 | ✅ 17:10 |
| Fechar chamado | 18:30 BRT | 21:30 UTC | ❌ 21:30 | ✅ 18:30 |

---

## 🎯 Arquitetura de Data/Hora (Padronização)

### Backend (API)
```csharp
// ✅ SEMPRE usar UTC
public DateTime DataAbertura { get; set; } = DateTime.UtcNow;
public DateTime DataFechamento { get; set; } = DateTime.UtcNow;

// ❌ NUNCA usar DateTime.Now
```

### Mobile (Client)
```xml
<!-- ✅ SEMPRE usar UtcToLocalConverter -->
<Label Text="{Binding DataAbertura, 
              Converter={StaticResource UtcToLocalConverter}, 
              StringFormat='{0:dd/MM/yyyy HH:mm}'}" />

<!-- ❌ NUNCA bind direto sem converter -->
```

### Por que UTC no Backend?

1. **Consistência Global:**
   - Mesmo chamado visível de qualquer fuso horário
   - Logs comparáveis entre servidores

2. **Cálculos Corretos:**
   - Diferenças de tempo sempre precisas
   - Sem problemas com horário de verão

3. **Banco de Dados:**
   - SQL Server `DATETIME2` armazena sem timezone
   - UTC evita ambiguidades

4. **Conversão no Cliente:**
   - Sistema operacional sabe o timezone local
   - `.ToLocalTime()` aplica offset automaticamente

---

## 📝 Regra de Ouro

> **"Backend em UTC, Display em Local"**
> 
> - **Salvar:** Sempre `DateTime.UtcNow`
> - **Trafegar:** JSON sem timezone (ISO 8601)
> - **Exibir:** Sempre converter para local no cliente

---

## 🚀 Arquivos Modificados

### Criados
1. ✅ `Converters/UtcToLocalDateTimeConverter.cs` - Value converter MAUI

### Modificados
1. ✅ `App.xaml` - Registrado converter global
2. ✅ `Views/ChamadoDetailPage.xaml` - Aplicado converter (2 datas)
3. ✅ `Views/DashboardPage.xaml` - Aplicado converter (1 data)
4. ✅ `Views/ChamadosListPage.xaml` - Aplicado converter (2 datas)
5. ✅ `Models/DTOs/ComentarioDto.cs` - Conversão interna para formatações

---

## 🔍 Debugging de Data/Hora

### Verificar Logs

```powershell
# Ver log do app com horários
Get-Content "$env:LOCALAPPDATA\SistemaChamados.Mobile-app-log.txt" -Tail 50
```

### Verificar DateTime.Kind no Debugger

```csharp
// No breakpoint, inspecionar:
dateTime.Kind  // Utc, Local ou Unspecified
dateTime.ToString("o")  // ISO 8601 com timezone
```

### Testar Converter Manualmente

```csharp
var converter = new UtcToLocalDateTimeConverter();
var utcDate = new DateTime(2025, 10, 20, 19, 55, 0, DateTimeKind.Utc);
var localDate = converter.Convert(utcDate, typeof(DateTime), null, null);
// localDate = 2025-10-20 16:55:00 (se UTC-3)
```

---

## 📚 Referências

### DateTime Best Practices (.NET)
- Use `DateTime.UtcNow` no backend
- Use `.ToLocalTime()` no frontend
- Sempre especifique `DateTimeKind`
- Considere `DateTimeOffset` para APIs complexas

### MAUI Value Converters
- [Microsoft Docs - MAUI Data Binding Converters](https://learn.microsoft.com/dotnet/maui/fundamentals/data-binding/converters)
- Registrados em `Application.Resources` ficam globais
- `Convert` = View → ViewModel
- `ConvertBack` = ViewModel → View

### ISO 8601
- Formato padrão JSON: `2025-10-20T19:55:00Z`
- `Z` = Zulu Time (UTC)
- Sem `Z` = Assume local ou unspecified

---

**Status:** ✅ Correção aplicada e testada  
**Impacto:** Todos os horários agora exibidos corretamente no fuso local  
**Breaking Change:** Não (apenas correção de bug)

---

**Última atualização:** 20/10/2025 16:55 BRT
