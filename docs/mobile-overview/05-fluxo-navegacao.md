# 🔀 Fluxo de Navegação - Mapa de Telas

## 🗺️ Diagrama de Navegação Atual

```
                    ┌──────────────┐
                    │   AppStart   │
                    └──────┬───────┘
                           │
                ┌──────────▼──────────┐
                │  Verificar Token?   │
                └──────┬──────────────┘
                       │
         ┌─────────────┴─────────────┐
         │                           │
    Token Válido               Token Inválido
         │                           │
         ▼                           ▼
┌─────────────────┐         ┌────────────────┐
│ ChamadosListPage│         │   LoginPage    │
│  (Dashboard)    │         └────────┬───────┘
└────┬────────┬───┘                  │
     │        │                Login Success
     │        │                      │
     │        │      ┌───────────────┘
     │        │      │
     │        │      ▼
     │        │  ┌──────────────────┐
     │        │  │ ChamadosListPage │
     │        │  └──────┬───────┬───┘
     │        │         │       │
     │        └─────────┘       │
     │                          │
     │ Tap "Abrir novo"         │ Tap em Card
     │                          │
     ▼                          ▼
┌──────────────────┐   ┌──────────────────┐
│ NovoChamadoPage  │   │ ChamadoDetailPage│
└────────┬─────────┘   └──────────────────┘
         │
    Criar Success
         │
         ▼
    Back to List
```

---

## 🚪 Rotas Registradas

### **AppShell.xaml**

```xml
<Shell FlyoutBehavior="Disabled">
  <ShellContent Route="dashboard"
                Title="Dashboard"
                ContentTemplate="{DataTemplate views:MainPage}" />
</Shell>
```

**Problema Atual:** Shell não está sendo utilizado adequadamente
- Apenas 1 rota registrada
- FlyoutBehavior desabilitado
- Navegação feita via NavigationPage tradicional

---

## 📱 Navegação Atual (Push/Pop Stack)

### **Fluxo de Login → Dashboard**

```csharp
// LoginViewModel.cs
private async Task LoginAsync()
{
    // ... validação ...
    
    if (loginSuccess)
    {
        Application.Current.MainPage = new NavigationPage(
            new ChamadosListPage()
        );
    }
}
```

### **Dashboard → Detalhes**

```csharp
// ChamadosListPage.xaml.cs
private void OnSelectionChanged(object sender, SelectionChangedEventArgs e)
{
    if (e.CurrentSelection.FirstOrDefault() is Chamado chamado)
    {
        Navigation.PushAsync(new ChamadoDetailPage(chamado));
    }
}
```

### **Dashboard → Novo Chamado**

```csharp
// ChamadosListPage.xaml.cs
private void OnNovoClicked(object sender, EventArgs e)
{
    Navigation.PushAsync(new NovoChamadoPage());
}
```

### **Novo Chamado → Voltar (após criar)**

```csharp
// NovoChamadoViewModel.cs
private async Task CriarChamadoAsync()
{
    // ... criar chamado ...
    
    await Application.Current.MainPage.DisplayAlert(
        "Sucesso", "Chamado criado!", "OK"
    );
    
    await Navigation.PopAsync(); // Volta para lista
}
```

---

## 🚨 Problemas de Navegação Atual

### 1. **Sem Bottom Navigation**
- Todas as navegações são push/pop (pilha)
- Usuário sempre precisa usar botão "Voltar"
- Não há navegação direta entre seções principais

### 2. **Sem Drawer/Hamburger Menu**
- Sem acesso rápido a:
  - Perfil do usuário
  - Configurações
  - Logout
  - Sobre o app

### 3. **Sem Tabs**
- Não há abas para diferentes visualizações
- Ex: "Meus Chamados", "Todos", "Arquivados"

### 4. **Navegação Linear Demais**
```
Login → Lista → Detalhes
           ↓
        Novo Chamado
```
- Sempre volta para lista
- Não há atalhos
- Não há breadcrumb

### 5. **Sem Estado de Navegação Persistente**
- App sempre abre na tela de login (se token expirou)
- Não lembra última tela visitada
- Não lembra posição do scroll na lista

---

## 🎯 Navegação Ideal Proposta

### **Estrutura com Bottom Navigation**

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│          CONTEÚDO DA TELA          │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  🏠      🎫      ➕      👤         │ ← Bottom Nav
│ Início  Chamados  Novo  Perfil     │
└─────────────────────────────────────┘
```

**Tabs Sugeridas:**

1. **🏠 Início** (Home/Dashboard)
   - Resumo de chamados
   - Métricas rápidas
   - Atalhos

2. **🎫 Chamados** (Lista)
   - Lista de chamados com filtros
   - Tela atual de ChamadosListPage

3. **➕ Novo** (Criar)
   - Formulário de novo chamado
   - Acesso direto, sem push

4. **👤 Perfil** (Configurações)
   - Informações do usuário
   - Configurações
   - Logout

### **Navegação Hierárquica Dentro de Tabs**

```
Tab: Chamados
├── Lista (root da tab)
│   ├── Tap em Card → Detalhes (push)
│   └── Busca/Filtros (in-place)
```

---

## 🔄 Tipos de Navegação no MAUI

### **1. Shell Navigation (Recomendado)**

```xml
<!-- AppShell.xaml -->
<Shell>
  <TabBar>
    <ShellContent Title="Início" 
                  Icon="home.png"
                  ContentTemplate="{DataTemplate views:HomePage}" />
    <ShellContent Title="Chamados"
                  Icon="ticket.png"
                  ContentTemplate="{DataTemplate views:ChamadosListPage}" />
    <ShellContent Title="Perfil"
                  Icon="user.png"
                  ContentTemplate="{DataTemplate views:PerfilPage}" />
  </TabBar>
</Shell>
```

**Navegação Programática:**
```csharp
// Navegar para rota
await Shell.Current.GoToAsync("//chamados");

// Navegar com parâmetros
await Shell.Current.GoToAsync($"detalhes?id={chamadoId}");

// Voltar
await Shell.Current.GoToAsync("..");
```

### **2. NavigationPage (Atual)**

```csharp
// Push
await Navigation.PushAsync(new DetailPage());

// Pop
await Navigation.PopAsync();

// Pop to root
await Navigation.PopToRootAsync();
```

### **3. TabbedPage**

```xml
<TabbedPage>
  <NavigationPage Title="Chamados">
    <x:Arguments>
      <views:ChamadosListPage />
    </x:Arguments>
  </NavigationPage>
  <NavigationPage Title="Perfil">
    <x:Arguments>
      <views:PerfilPage />
    </x:Arguments>
  </NavigationPage>
</TabbedPage>
```

---

## 🎨 Visualização de Navegação Proposta

### **Tela Principal com Bottom Nav**

```
┌─────────────────────────────────────┐
│  ← Sistema de Chamados              │ ← NavBar
├─────────────────────────────────────┤
│                                     │
│                                     │
│        [Lista de Chamados]          │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
├─────────────────────────────────────┤
│ ┌────────┬────────┬────────┬──────┐│
│ │   🏠   │   🎫   │   ➕   │  👤  ││ ← Bottom Nav
│ │ Início │Chamados│  Novo  │Perfil││
│ └────────┴────────┴────────┴──────┘│
└─────────────────────────────────────┘
```

### **Detalhes (Push sobre Tab)**

```
┌─────────────────────────────────────┐
│  ← Detalhes do Chamado              │ ← NavBar com Back
├─────────────────────────────────────┤
│                                     │
│      [Informações do Chamado]       │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
├─────────────────────────────────────┤
│ ┌────────┬────────┬────────┬──────┐│
│ │   🏠   │   🎫   │   ➕   │  👤  ││ ← Bottom Nav
│ │ Início │Chamados│  Novo  │Perfil││   (ainda visível)
│ └────────┴────────┴────────┴──────┘│
└─────────────────────────────────────┘
```

---

## 🚀 Ações de Navegação Rápida

### **FAB (Floating Action Button)**

```
                     ┌──────────────┐
                     │              │
                     │              │
                     │   [LISTA]    │
                     │              │
                     │              │
                     │          ┌───┤
                     │          │ ➕ │ ← FAB
                     │          └───┤
                     └──────────────┘
```

**Funcionalidade:**
- Sempre visível na tela de Lista
- Tap → Abre formulário de Novo Chamado
- Animação de aparecimento/desaparecimento no scroll

### **Swipe Gestures**

```
Card de Chamado:
┌──────────────────────────────────┐
│ Problema no laboratório          │ ← Swipe Left
│ [Aberto] [Alta]                  │ → Revela ações
└──────────────────────────────────┘

Após Swipe Left:
┌────────────────────────────┬─────┐
│ Problema no laboratório    │ 🗑️  │ ← Arquivar
└────────────────────────────┴─────┘
```

---

## 📊 Tabela de Navegação por Tela

| De | Para | Método | Tipo | Volta? |
|----|------|--------|------|--------|
| App Start | Login | SetMainPage | Root | Não |
| App Start | Lista | SetMainPage | Root | Não |
| Login | Lista | SetMainPage | Root | Não |
| Lista | Detalhes | Push | Stack | Sim (Back) |
| Lista | Novo | Push | Stack | Sim (Back) |
| Novo | Lista | Pop | Stack | Automático |
| Detalhes | Lista | Pop | Stack | Sim (Back) |

### **Com Bottom Nav (Proposta):**

| De | Para | Método | Tipo | Volta? |
|----|------|--------|------|--------|
| Início | Chamados | Tab Change | Shell | Direto |
| Chamados | Perfil | Tab Change | Shell | Direto |
| Chamados | Detalhes | Push | Stack | Sim (Back) |
| Detalhes | Chamados | Pop | Stack | Sim (Back) |
| Qualquer Tab | Novo (FAB) | Modal/Push | Overlay | Sim (Dismiss) |

---

## 🎯 Melhorias de Navegação Prioritárias

### **1. Implementar Bottom Navigation** ⭐⭐⭐
- 4 tabs: Início, Chamados, Novo, Perfil
- Ícones e labels claros
- Estado ativo visualmente distinto

### **2. Adicionar FAB para Criar Chamado** ⭐⭐⭐
- Acesso rápido de qualquer tab
- Animação suave

### **3. Criar Tela de Perfil** ⭐⭐
- Foto, nome, email
- Botão de Logout visível
- Configurações básicas

### **4. Implementar Back Navigation Consistente** ⭐⭐
- Seta de voltar sempre visível
- Comportamento previsível

### **5. Adicionar Drawer/Hamburger Menu** ⭐
- Acesso a:
  - Sobre o app
  - Ajuda/FAQ
  - Configurações avançadas
  - Versão do app

---

## 📝 Exemplo de Implementação (Shell)

### **AppShell.xaml**

```xml
<?xml version="1.0" encoding="utf-8" ?>
<Shell xmlns="http://schemas.microsoft.com/dotnet/2021/maui"
       x:Class="SistemaChamados.Mobile.AppShell"
       FlyoutBehavior="Flyout">

  <!-- Menu Lateral (Drawer) -->
  <Shell.FlyoutHeader>
    <Grid BackgroundColor="{StaticResource Primary}" Padding="20">
      <Label Text="Sistema de Chamados" 
             TextColor="White" 
             FontSize="20" 
             FontAttributes="Bold" />
    </Grid>
  </Shell.FlyoutHeader>

  <!-- Bottom Navigation -->
  <TabBar>
    <ShellContent Title="Início"
                  Icon="home.png"
                  Route="home"
                  ContentTemplate="{DataTemplate views:HomePage}" />
    
    <ShellContent Title="Chamados"
                  Icon="ticket.png"
                  Route="chamados"
                  ContentTemplate="{DataTemplate views:ChamadosListPage}" />
    
    <ShellContent Title="Novo"
                  Icon="plus.png"
                  Route="novo"
                  ContentTemplate="{DataTemplate views:NovoChamadoPage}" />
    
    <ShellContent Title="Perfil"
                  Icon="user.png"
                  Route="perfil"
                  ContentTemplate="{DataTemplate views:PerfilPage}" />
  </TabBar>

  <!-- Rotas para Push Navigation -->
  <ShellContent Route="detalhes"
                ContentTemplate="{DataTemplate views:ChamadoDetailPage}"
                IsVisible="False" />

</Shell>
```

---

**Documento**: 05 - Fluxo de Navegação  
**Data**: 20/10/2025  
**Versão**: 1.0
