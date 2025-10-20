# 🔄 Correções de Navegação - MAUI Shell

## Data: 20 de outubro de 2025

---

## Problema Identificado

### 1. **Navegação com Cache Indevido**
Ao clicar em um chamado no Dashboard, depois voltar e clicar na aba "Chamados", o app redirecionava automaticamente para o último chamado visualizado.

### 2. **Detalhes Não Carregando Corretamente**
Os detalhes do chamado não eram apresentados corretamente na primeira visualização.

### 3. **Rota Absoluta vs Relativa**
O uso de `///` (rotas absolutas) causava comportamento indesejado de navegação no Shell, confundindo tabs com páginas modais.

---

## Causa Raiz

### Shell Navigation Stack
O MAUI Shell mantém uma pilha de navegação para cada `ShellContent` (tab). Quando usávamos `///chamados/detail`, o Shell interpretava como uma mudança de tab root, não como uma navegação modal push.

```
❌ ANTES (comportamento errado):
Dashboard Tab → ///chamados/detail → Muda para Chamados Tab e empilha Detail

✅ DEPOIS (comportamento correto):
Dashboard Tab → chamados/detail → Push modal sobre Dashboard
Chamados Tab → chamados/detail → Push modal sobre Chamados
```

---

## Soluções Implementadas

### ✅ 1. Remoção de Rotas Absolutas

**Arquivos Modificados:**
- `Views/DashboardPage.xaml.cs`
- `Views/ChamadosListPage.xaml.cs`
- `ViewModels/ChamadosListViewModel.cs`
- `ViewModels/ChamadoConfirmacaoViewModel.cs`
- `ViewModels/NovoChamadoViewModel.cs`

**Mudança:**
```csharp
// ANTES (causava problema de navegação)
await Shell.Current.GoToAsync($"///chamados/detail?id={chamado.Id}");

// DEPOIS (navegação modal correta)
await Shell.Current.GoToAsync($"chamados/detail?id={chamado.Id}");
```

---

### ✅ 2. Limpeza de Dados ao Sair da Página

**Arquivo Criado:**
- Método `ClearData()` em `ChamadoDetailViewModel`

**Arquivo Modificado:**
- `Views/ChamadoDetailPage.xaml.cs` - adicionado `OnDisappearing()`

**Funcionalidade:**
```csharp
protected override void OnDisappearing()
{
    base.OnDisappearing();
    _vm.ClearData(); // Limpa cache ao voltar
}
```

Agora, quando você volta da página de detalhes:
1. Os dados do chamado anterior são limpos
2. Comentários e anexos são resetados
3. A próxima visualização carrega dados frescos

---

### ✅ 3. Reorganização do Shell - Tabs vs Modais

**Arquivo Modificado:**
- `AppShell.xaml` - removida tab "Novo"
- `AppShell.xaml.cs` - rotas modais explícitas

**ANTES:**
```xml
<TabBar>
  <ShellContent Title="Início" Route="dashboard" />
  <ShellContent Title="Chamados" Route="chamados" />
  <ShellContent Title="Novo" Route="novo" />     ❌ Tab desnecessária
  <ShellContent Title="Perfil" Route="perfil" />
</TabBar>
```

**DEPOIS:**
```xml
<TabBar>
  <ShellContent Title="Início" Route="dashboard" />
  <ShellContent Title="Chamados" Route="chamados" />
  <ShellContent Title="Perfil" Route="perfil" />
</TabBar>

<!-- Rotas registradas em código para modais -->
Routing.RegisterRoute("chamados/detail", typeof(ChamadoDetailPage));
Routing.RegisterRoute("chamados/novo", typeof(NovoChamadoPage));
Routing.RegisterRoute("chamados/confirmacao", typeof(ChamadoConfirmacaoPage));
```

**Benefícios:**
- ✅ Menos tabs = interface mais limpa
- ✅ "Novo Chamado" acessível via botões nas páginas
- ✅ Navegação modal clara (push/pop stack)

---

### ✅ 4. Botões de Acesso ao "Novo Chamado"

**Dashboard:**
```xml
<Button Text="➕ Novo Chamado"
        Clicked="OnNovoChamadoClicked"
        BackgroundColor="{StaticResource Success}" />
```

**Lista de Chamados:**
- Mantido o botão FAB existente no rodapé

Agora é possível criar novo chamado de qualquer lugar!

---

## Comportamento Correto Agora

### Fluxo de Navegação

#### 1. Dashboard → Detalhe do Chamado
```
Dashboard (Tab)
  └─ chamados/detail?id=X  (Modal Push)
      └─ Voltar → Dashboard (Modal Pop)
```

#### 2. Chamados → Detalhe do Chamado
```
Chamados (Tab)
  └─ chamados/detail?id=Y  (Modal Push)
      └─ Voltar → Chamados (Modal Pop)
```

#### 3. Qualquer Lugar → Novo Chamado
```
Dashboard/Chamados (Tab)
  └─ chamados/novo  (Modal Push)
      └─ chamados/confirmacao  (Modal Push)
          └─ chamados/detail?id=Z  (Modal Replace)
              └─ Voltar → Dashboard/Chamados
```

### Isolamento de Pilhas

Cada tab mantém sua própria pilha de navegação:

```
📱 App Shell
├─ 📄 Dashboard Tab
│   ├─ DashboardPage (root)
│   └─ ChamadoDetailPage (modal, se aberto daqui)
├─ 📋 Chamados Tab
│   ├─ ChamadosListPage (root)
│   └─ ChamadoDetailPage (modal, se aberto daqui)
└─ 👤 Perfil Tab
    └─ PerfilPage (root)
```

---

## Tratamento de Erros

### Navegação com Try-Catch

```csharp
try
{
    await Shell.Current.GoToAsync($"chamados/detail?id={chamado.Id}");
}
catch (Exception ex)
{
    App.Log($"Navigation error: {ex}");
    await Application.Current?.MainPage?.DisplayAlert(
        "Erro", 
        "Não foi possível abrir o chamado. Tente novamente.", 
        "OK"
    );
}
```

**Benefícios:**
- ✅ App não crasha se navegação falhar
- ✅ Usuário recebe feedback visual
- ✅ Erro é logado para debug

---

## Logs de Navegação

Todos os eventos de navegação são logados:

```
2025-10-20 16:00:00 DashboardPage OnChamadoSelected start
2025-10-20 16:00:00 DashboardPage selected chamado 21
2025-10-20 16:00:00 DashboardPage navigating to chamados/detail?id=21
2025-10-20 16:00:01 ChamadoDetailPage constructor start
2025-10-20 16:00:01 ChamadoDetailPage ChamadoId setter: 21
2025-10-20 16:00:01 ChamadoDetailViewModel.Load(21) start
2025-10-20 16:00:02 ChamadoDetailViewModel.Load complete
2025-10-20 16:00:05 ChamadoDetailPage OnDisappearing - clearing data
2025-10-20 16:00:05 ChamadoDetailViewModel ClearData
```

**Arquivo de Log:**
`%LOCALAPPDATA%\SistemaChamados.Mobile-app-log.txt`

---

## Testes Realizados

### ✅ Cenário 1: Dashboard → Detalhes
1. Login no app
2. Ver dashboard com chamados recentes
3. Clicar em um chamado → Abre detalhes
4. Voltar → Retorna ao dashboard
5. Clicar em OUTRO chamado → Abre detalhes corretos (não cache)

### ✅ Cenário 2: Chamados → Detalhes
1. Ir para aba "Chamados"
2. Clicar em um chamado → Abre detalhes
3. Voltar → Retorna à lista
4. Clicar na aba "Início" → Dashboard limpo (não mantém modal)

### ✅ Cenário 3: Novo Chamado
1. Clicar em "➕ Novo Chamado" no dashboard
2. Preencher formulário
3. Criar → Vai para confirmação
4. Ver detalhes → Abre página de detalhes do novo chamado
5. Voltar múltiplas vezes → Retorna ao dashboard

### ✅ Cenário 4: Navegação Entre Tabs
1. Abrir detalhes de um chamado no Dashboard
2. Clicar na tab "Chamados" SEM voltar
3. Lista aparece normal (modal não vaza entre tabs)

---

## Comparação Antes vs Depois

| Aspecto | ❌ Antes | ✅ Depois |
|---------|---------|-----------|
| **Navegação Dashboard → Detail** | Mudava para tab Chamados | Modal sobre Dashboard |
| **Cache de Detalhes** | Mantinha dados do chamado anterior | Limpa ao sair |
| **Tab "Novo"** | Tab dedicada (4 tabs) | Botões contextuais (3 tabs) |
| **Pilha de Navegação** | Compartilhada entre tabs | Isolada por tab |
| **Erro de Navegação** | Crash do app | Alerta ao usuário |
| **Logs** | Mínimos | Completos |

---

## Referências Técnicas

### MAUI Shell Navigation
- **Rotas Absolutas (`///`)**: Mudam para uma tab específica
- **Rotas Relativas**: Push modal na pilha da tab atual
- **`..`**: Pop (volta uma página)
- **QueryProperty**: Passa parâmetros via URL

### Documentação Oficial
- [Shell Navigation (Microsoft)](https://learn.microsoft.com/en-us/dotnet/maui/fundamentals/shell/navigation)
- [Shell Routing](https://learn.microsoft.com/en-us/dotnet/maui/fundamentals/shell/pages)

---

## Próximas Melhorias

### Animações de Transição
```csharp
await Shell.Current.GoToAsync(
    "chamados/detail?id=21",
    animate: true
);
```

### Deep Linking
Preparar app para abrir diretamente em um chamado via notificação:
```
sistemasuporte://chamados/detail?id=21
```

### State Restoration
Salvar estado de navegação para restaurar após fechar/abrir app.

---

**Última atualização:** 20/10/2025  
**Status:** ✅ Navegação estável e previsível
