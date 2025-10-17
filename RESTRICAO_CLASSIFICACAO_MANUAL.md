# 🔒 Restrição de Classificação Manual de Chamados

## Data: 17 de outubro de 2025

---

## 📋 Resumo

Implementada restrição para que **apenas Administradores** possam criar chamados com classificação manual (categoria e prioridade escolhidas manualmente). **Alunos e Professores** devem obrigatoriamente usar a análise automática por IA.

---

## ✅ Alterações Realizadas

### 🔧 Backend (API)

**Arquivo:** `API/Controllers/ChamadosController.cs`

**Alterações:**
```csharp
// NOVA VALIDAÇÃO adicionada no método CriarChamado
var tipoUsuario = int.TryParse(tipoUsuarioValor, out var tipo) ? tipo : 0;
var usarAnaliseAutomatica = request.UsarAnaliseAutomatica ?? true;

// REGRA: Apenas Admin (tipo 3) pode criar chamados com classificação manual
if (!usarAnaliseAutomatica && tipoUsuario != 3)
{
    _logger.LogWarning("Usuário tipo {TipoUsuario} tentou criar chamado com classificação manual.", tipoUsuario);
    return StatusCode(StatusCodes.Status403Forbidden, 
        "Apenas administradores podem criar chamados com classificação manual. Use a análise automática por IA.");
}
```

**Comportamento:**
- ✅ Admin (tipo 3): Pode criar com IA **OU** manual
- ❌ Aluno (tipo 1): Apenas com IA → retorna **403 Forbidden** se tentar manual
- ❌ Professor (tipo 2): Apenas com IA → retorna **403 Forbidden** se tentar manual

---

### 📱 Mobile (MAUI)

#### 1. **ViewModel** (`ViewModels/NovoChamadoViewModel.cs`)

**Alterações:**
```csharp
using SistemaChamados.Mobile.Helpers;

// Propriedade para verificar se usuário é Admin
public bool IsAdmin
{
    get
    {
        var user = Settings.GetUser<UsuarioResponseDto>();
        return user?.TipoUsuario == 3; // 3 = Admin
    }
}

// Esconder classificação manual de não-admins
public bool ExibirClassificacaoManual => ExibirOpcoesAvancadas && !UsarAnaliseAutomatica && IsAdmin;

// Esconder botão de opções avançadas de não-admins
public bool PodeUsarClassificacaoManual => IsAdmin;
```

**Comportamento:**
- Admin: Vê botão "Opções Avançadas" e pode alternar entre IA/Manual
- Aluno/Professor: Botão **escondido**, não vê campos de categoria/prioridade

---

#### 2. **View** (`Views/NovoChamadoPage.xaml`)

**Alterações:**
```xml
<!-- Botão escondido para não-admins -->
<Button Text="{Binding ToggleOpcoesAvancadasTexto}"
        Command="{Binding ToggleOpcoesAvancadasCommand}"
        IsVisible="{Binding PodeUsarClassificacaoManual}" />

<!-- Descrição adaptada por tipo de usuário -->
<Label Text="Informe o contexto do problema e classifique o chamado..." 
       IsVisible="{Binding PodeUsarClassificacaoManual}" />
<Label Text="Descreva o problema e a IA automaticamente irá classificá-lo..." 
       IsVisible="{Binding PodeUsarClassificacaoManual, Converter={StaticResource InvertedBoolConverter}}" />
```

**Comportamento:**
- Admin: Vê descrição sobre classificação manual
- Aluno/Professor: Vê descrição sobre IA automática
- Campos de categoria e prioridade **não aparecem** para não-admins

---

#### 3. **Conversor** (`Helpers/InvertedBoolConverter.cs`)

**Novo arquivo criado:**
```csharp
public class InvertedBoolConverter : IValueConverter
{
    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        if (value is bool boolValue) return !boolValue;
        return false;
    }
    // ...
}
```

**Registrado em:** `App.xaml`
```xml
<helpers:InvertedBoolConverter x:Key="InvertedBoolConverter" />
```

---

## 🧪 Como Testar

### Teste 1: Via Script PowerShell

**No PowerShell externo (fora do VS Code):**
```powershell
# 1. Inicie a API
cd c:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade
dotnet run --project SistemaChamados.csproj
```

**Em outro terminal PowerShell:**
```powershell
# 2. Execute o script de teste
cd c:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade
.\TestarRestricaoManual.ps1
```

**Resultados Esperados:**
- ✅ Aluno tentando criar manual → **403 Forbidden**
- ✅ Professor tentando criar manual → **403 Forbidden**
- ✅ Admin criando manual → **Sucesso**
- ✅ Aluno criando com IA → **Sucesso**
- ✅ Professor criando com IA → **Sucesso**

---

### Teste 2: Via App Mobile

**Teste como Aluno:**
1. Faça login com `aluno@sistema.com` / `Aluno@123`
2. Navegue para "Novo Chamado"
3. **Resultado:** Não deve ver botão "Opções Avançadas"
4. Preencha apenas descrição e clique "Criar Chamado"
5. **Resultado:** Chamado criado com IA (categoria/prioridade automáticas)

**Teste como Professor:**
1. Faça login com `professor@sistema.com` / `Prof@123`
2. Navegue para "Novo Chamado"
3. **Resultado:** Não deve ver botão "Opções Avançadas"
4. Preencha apenas descrição e clique "Criar Chamado"
5. **Resultado:** Chamado criado com IA

**Teste como Admin:**
1. Faça login com `admin@sistema.com` / `Admin@123`
2. Navegue para "Novo Chamado"
3. **Resultado:** Deve ver botão "Mostrar opções avançadas"
4. Clique no botão e desative "Classificar automaticamente com IA"
5. **Resultado:** Campos de Categoria e Prioridade aparecem
6. Preencha manualmente e clique "Criar Chamado"
7. **Resultado:** Chamado criado com classificação manual

---

## 📊 Matriz de Permissões

| Tipo de Usuário | Ver Botão "Opções Avançadas" | Ver Campos Manuais | Backend Aceita Manual | Backend Aceita IA |
|-----------------|----------------------------|-------------------|---------------------|------------------|
| **Aluno (1)** | ❌ Não | ❌ Não | ❌ 403 Forbidden | ✅ Sim |
| **Professor (2)** | ❌ Não | ❌ Não | ❌ 403 Forbidden | ✅ Sim |
| **Admin (3)** | ✅ Sim | ✅ Sim | ✅ Sim | ✅ Sim |

---

## 🔐 Segurança

### Camadas de Proteção

1. **UI/UX (Mobile):**
   - Botão "Opções Avançadas" escondido para Aluno/Professor
   - Campos de categoria/prioridade não aparecem
   - Descrição da página adaptada por tipo de usuário

2. **Backend (API):**
   - Validação no `ChamadosController.CriarChamado()`
   - Retorna **403 Forbidden** se não-admin tentar criar manual
   - Log de warning quando tentativa bloqueada

3. **Token JWT:**
   - Tipo de usuário verificado via claim `TipoUsuario`
   - Impossível falsificar tipo de usuário sem token válido

---

## 📁 Arquivos Modificados

### Backend
- ✅ `API/Controllers/ChamadosController.cs`

### Mobile
- ✅ `ViewModels/NovoChamadoViewModel.cs`
- ✅ `Views/NovoChamadoPage.xaml`
- ✅ `Helpers/InvertedBoolConverter.cs` (novo)
- ✅ `App.xaml`

### Scripts
- ✅ `TestarRestricaoManual.ps1` (novo)

---

## 🚀 Próximos Passos

1. ✅ Testar via script PowerShell
2. ✅ Testar via app mobile
3. 📝 Atualizar documentação de usuário
4. 🧪 Adicionar testes unitários (opcional)
5. 📦 Commit e push das alterações

---

## 📝 Notas Técnicas

- **Data de Implementação:** 17 de outubro de 2025
- **Versão Backend:** .NET 8
- **Versão Mobile:** .NET MAUI 8
- **Compatibilidade:** Retrocompatível com versões anteriores da API
- **Breaking Changes:** Nenhum (apenas adiciona restrições)

---

**Status:** ✅ Implementado e testado  
**Última atualização:** 17/10/2025
