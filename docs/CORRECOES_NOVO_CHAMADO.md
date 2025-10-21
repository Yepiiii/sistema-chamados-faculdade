# 🔧 Correções - Novo Chamado

Data: 20 de outubro de 2025

---

## 🐛 Problemas Identificados

### 1. **Crash ao criar chamado após preencher formulário**
- **Sintoma:** App crasha ao clicar em "Criar Chamado" após preencher os dados
- **Causa:** Navegação usando rota relativa de uma página do TabBar
- **Status:** ✅ RESOLVIDO

### 2. **Funcionalidade de classificação manual ausente (Admin)**
- **Sintoma:** Opções para selecionar categoria e prioridade manualmente não aparecem para Admin
- **Causa:** `Settings.TipoUsuario` não estava sendo salvo durante o login (valor sempre 0)
- **Status:** ✅ RESOLVIDO

### 3. **Crash ao clicar em "Ver detalhes" na página de confirmação**
- **Sintoma:** App crasha após criar chamado e clicar em "Ver detalhes" na tela de confirmação
- **Causa:** Navegação usando rota relativa de uma página modal do Shell
- **Status:** ✅ RESOLVIDO

---

## ✅ Correções Aplicadas

### 1. Navegação para Página de Confirmação

**Arquivo:** `ViewModels/NovoChamadoViewModel.cs` - Método `Criar()`

**Mudança:**
```csharp
// ANTES:
await shell.GoToAsync("chamados/confirmacao", parametros);

// DEPOIS:
await shell.GoToAsync("///chamados/confirmacao", parametros);
```

**Motivo:** Como a página "Novo Chamado" é aberta a partir de uma página do TabBar (Dashboard), ela é considerada um elemento do Shell. A navegação para a página de confirmação deve usar rota **absoluta** (`///`) para funcionar corretamente.

---

### 2. Salvar TipoUsuario no Login

**Arquivo:** `Services/Auth/AuthService.cs` - Método `Login()`

**Problema identificado:**
```csharp
// ANTES: Só salvava o objeto completo, mas não as propriedades individuais
Settings.Token = resp.Token;
Settings.SaveUser(resp.Usuario ?? new UsuarioResponseDto());
```

**Correção aplicada:**
```csharp
// DEPOIS: Salva tanto o objeto completo quanto as propriedades individuais
Settings.Token = resp.Token;
Settings.SaveUser(resp.Usuario ?? new UsuarioResponseDto());

// Salvar propriedades específicas do usuário para acesso rápido
if (resp.Usuario != null)
{
    Settings.UserId = resp.Usuario.Id;
    Settings.NomeUsuario = resp.Usuario.NomeCompleto;
    Settings.Email = resp.Usuario.Email;
    Settings.TipoUsuario = resp.Usuario.TipoUsuario;  // ⭐ CHAVE!
    
    App.Log($"AuthService settings saved - UserId: {Settings.UserId}, TipoUsuario: {Settings.TipoUsuario}");
}
```

**Motivo:** O `Settings.TipoUsuario` é usado em todo o app para determinar permissões:
- `TipoUsuario = 1` → Aluno
- `TipoUsuario = 2` → Professor/Técnico
- `TipoUsuario = 3` → Administrador

Sem salvar essa propriedade, o valor sempre era **0** (zero), fazendo com que todas as verificações de permissão falhassem:
```csharp
// Estas propriedades retornavam False quando TipoUsuario = 0
public bool IsTecnicoOuAdmin => TipoUsuarioAtual == 2 || TipoUsuarioAtual == 3;
public bool PodeUsarClassificacaoManual => IsTecnicoOuAdmin;
```

---

### 3. Logging Extensivo

**Arquivos modificados:**
- `ViewModels/NovoChamadoViewModel.cs`
- `Views/ChamadoConfirmacaoPage.xaml.cs`

**Logs adicionados:**
- ✅ Início e fim do método `Criar()`
- ✅ Validações do formulário
- ✅ Criação do DTO
- ✅ Chamada ao serviço
- ✅ Navegação para confirmação
- ✅ Todos os erros com stack trace
- ✅ Permissões do usuário (TipoUsuario, IsAdmin, etc.)
- ✅ Estado das opções avançadas

---

### 3. Logging Extensivo

**Arquivos modificados:**
- `ViewModels/NovoChamadoViewModel.cs`
- `Views/ChamadoConfirmacaoPage.xaml.cs`
- `Services/Auth/AuthService.cs`

**Logs adicionados:**
- ✅ Tipo de usuário e permissões ao criar ViewModel
- ✅ Início e fim do método `Criar()`
- ✅ Validações do formulário
- ✅ Criação do DTO
- ✅ Chamada ao serviço
- ✅ Navegação para confirmação
- ✅ Todos os erros com stack trace
- ✅ Salvamento de Settings após login

---

### 4. Debug de Permissões

**Arquivo:** `ViewModels/NovoChamadoViewModel.cs` - Construtor

**Logs adicionados:**
```csharp
App.Log($"NovoChamadoViewModel constructor - UserId: {Settings.UserId}");
App.Log($"NovoChamadoViewModel constructor - NomeUsuario: {Settings.NomeUsuario}");
App.Log($"NovoChamadoViewModel constructor - Email: {Settings.Email}");
App.Log($"NovoChamadoViewModel constructor - TipoUsuario: {Settings.TipoUsuario}");
App.Log($"NovoChamadoViewModel constructor - IsAluno: {IsAluno}, IsTecnicoOuAdmin: {IsTecnicoOuAdmin}, IsAdmin: {IsAdmin}");
App.Log($"NovoChamadoViewModel constructor - PodeUsarClassificacaoManual: {PodeUsarClassificacaoManual}");
```

**Objetivo:** Verificar se o tipo de usuário está sendo detectado corretamente após a correção.

**Valores esperados após login como Admin:**
```
TipoUsuario: 3
IsAluno: False
IsTecnicoOuAdmin: True
IsAdmin: True
PodeUsarClassificacaoManual: True
```

---

### 5. Navegação na Página de Confirmação

**Arquivo:** `ViewModels/ChamadoConfirmacaoViewModel.cs` - Método `IrParaDetalhesAsync()`

**Problema identificado:**
```csharp
// ANTES: Usava rota relativa
await Shell.Current.GoToAsync($"chamados/detail?Id={Chamado.Id}");
```

**Correção aplicada:**
```csharp
// DEPOIS: Usa rota absoluta com logging extensivo
var route = $"///chamados/detail?Id={Chamado.Id}";
App.Log($"ChamadoConfirmacaoViewModel.IrParaDetalhes: navigating to {route}");
await Shell.Current.GoToAsync(route);
```

**Motivo:** A página de confirmação é aberta usando rota absoluta (`///chamados/confirmacao`), então ao navegar dela para os detalhes do chamado, também precisa usar rota **absoluta** (`///chamados/detail`).

**Logging adicionado:**
- ✅ Início do método
- ✅ Verificação de Chamado nulo
- ✅ Verificação de Shell.Current nulo
- ✅ Rota de navegação
- ✅ Sucesso da navegação
- ✅ Erros com stack trace completo

---

## 🧪 Como Testar

### Teste 1: Criar Chamado com IA (Qualquer usuário)

1. **Login:** Use qualquer credencial
   ```
   admin@sistema.com / Admin@123
   aluno@sistema.com / Aluno@123
   ```

2. **Navegação:**
   - Dashboard → Botão "Novo Chamado" (+)

3. **Preencher:**
   - Descrição: "Teste de criação de chamado"

4. **Criar:**
   - Clicar em "Criar Chamado"
   - **Esperado:** Navegar para página de confirmação ✅
   - **Antes:** App crashava ❌

5. **Verificar logs:**
   ```powershell
   Get-Content "$env:LOCALAPPDATA\SistemaChamados.Mobile-app-log.txt" -Tail 50
   ```
   - Procurar por: `NovoChamadoViewModel.Criar`
   - Verificar se não há erros

---

### Teste 2: Classificação Manual (Admin/Técnico apenas)

1. **Login:** Use credencial de admin
   ```
   admin@sistema.com / Admin@123
   ```

2. **Navegação:**
   - Dashboard → Botão "Novo Chamado" (+)

3. **Verificar visibilidade:**
   - **Botão "Mostrar opções avançadas"** deve estar visível ✅
   - Se não estiver, verificar logs para TipoUsuario

4. **Expandir opções:**
   - Clicar em "Mostrar opções avançadas"
   - **Esperado:** Seção expandida mostrando:
     - Campo "Título (opcional)"
     - Switch "Classificar automaticamente com IA"

5. **Desligar IA:**
   - Desligar o switch de IA
   - **Esperado:** Aparecem campos:
     - Picker "Categoria"
     - Picker "Prioridade"

6. **Selecionar manualmente:**
   - Escolher uma categoria (ex: Hardware)
   - Escolher uma prioridade (ex: Alta)
   - Preencher descrição
   - Clicar em "Criar Chamado"

7. **Verificar logs:**
   ```powershell
   Get-Content "$env:LOCALAPPDATA\SistemaChamados.Mobile-app-log.txt" -Tail 80 | Select-String "NovoChamadoViewModel"
   ```
   - Procurar por: `manual classification`
   - Verificar Cat e Prior ids

---

### Teste 3: Ver Detalhes na Página de Confirmação

1. **Login:** Use credencial de admin
   ```
   admin@sistema.com / Admin@123
   ```

2. **Criar chamado:**
   - Dashboard → Botão "Novo Chamado" (+)
   - Preencher descrição: "Teste de confirmação"
   - Clicar em "Criar Chamado"

3. **Página de confirmação:**
   - **Esperado:** Navegar para página de confirmação ✅
   - **Verificar:** Protocolo do chamado aparece (ex: #25)
   - **Verificar:** Categoria, Prioridade e Status aparecem

4. **Clicar em "Ver detalhes":**
   - **Esperado:** Navegar para página de detalhes do chamado ✅
   - **Antes:** App crashava ❌

5. **Verificar página de detalhes:**
   - Título do chamado aparece
   - Descrição aparece
   - Categoria, Prioridade e Status aparecem
   - Histórico de ações aparece

6. **Voltar:**
   - Clicar em voltar
   - **Esperado:** Retornar ao dashboard (não à confirmação)

7. **Verificar logs:**
   ```powershell
   Get-Content "$env:LOCALAPPDATA\SistemaChamados.Mobile-app-log.txt" -Tail 50 | Select-String "ChamadoConfirmacao"
   ```
   - Procurar por: `IrParaDetalhes`
   - Verificar se não há erros

---

## 🔍 Diagnóstico de Problemas

### Se o app ainda crashar ao criar chamado:

1. **Ver logs completos:**
   ```powershell
   Get-Content "$env:LOCALAPPDATA\SistemaChamados.Mobile-app-log.txt" -Tail 100
   ```

2. **Procurar por:**
   - `NovoChamadoViewModel.Criar FATAL ERROR:`
   - Stack trace completo

3. **Verificar:**
   - Se a API está rodando (`http://localhost:5246`)
   - Se há erro de rede/serialização
   - Se o DTO está correto

---

### Se as opções avançadas não aparecem:

1. **Verificar tipo de usuário nos logs:**
   ```powershell
   Get-Content "$env:LOCALAPPDATA\SistemaChamados.Mobile-app-log.txt" | Select-String "TipoUsuario"
   ```

2. **Valores esperados:**
   - Admin: `TipoUsuario: 3`
   - Técnico/Professor: `TipoUsuario: 2`
   - Aluno: `TipoUsuario: 1`

3. **Propriedades esperadas (Admin/Técnico):**
   - `IsTecnicoOuAdmin: True`
   - `PodeUsarClassificacaoManual: True`

4. **Se TipoUsuario = 1 (Aluno):**
   - ✅ Comportamento correto: opções avançadas **não devem** aparecer
   - Alunos não podem classificar manualmente

---

### Se os campos de categoria/prioridade não aparecem:

1. **Verificar logs ao clicar em "Mostrar opções":**
   ```powershell
   Get-Content "$env:LOCALAPPDATA\SistemaChamados.Mobile-app-log.txt" -Tail 20
   ```

2. **Procurar por:**
   - `AlternarOpcoesAvancadas - ExibirOpcoesAvancadas:`
   - `AlternarOpcoesAvancadas - UsarAnaliseAutomatica:`
   - `AlternarOpcoesAvancadas - ExibirClassificacaoManual:`

3. **Para os campos aparecerem, precisa:**
   - `ExibirOpcoesAvancadas: True` (clicou no botão)
   - `UsarAnaliseAutomatica: False` (desligou o switch)
   - `IsTecnicoOuAdmin: True` (é admin ou técnico)

---

## 📊 Estrutura de Visibilidade

```
┌─────────────────────────────────────────┐
│ Descrição (sempre visível)              │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ Botão "Mostrar opções avançadas"        │
│ IsVisible={PodeUsarClassificacaoManual} │
│ (Apenas Admin/Técnico)                   │
└─────────────────────────────────────────┘

IF ExibirOpcoesAvancadas = True:
┌─────────────────────────────────────────┐
│ Seção "Opções avançadas"                │
│ ├─ Campo "Título" (opcional)            │
│ └─ Switch "Classificar com IA"          │
│    (Apenas Admin/Técnico)                │
└─────────────────────────────────────────┘

IF UsarAnaliseAutomatica = False:
┌─────────────────────────────────────────┐
│ Seção "Classificação Manual"            │
│ ├─ Picker "Categoria"                   │
│ └─ Picker "Prioridade"                  │
│ IsVisible={ExibirClassificacaoManual}   │
│ (Requer 3 condições!)                   │
└─────────────────────────────────────────┘
```

**Fórmula da visibilidade:**
```csharp
ExibirClassificacaoManual = 
    ExibirOpcoesAvancadas && 
    !UsarAnaliseAutomatica && 
    IsTecnicoOuAdmin
```

---

## 🎯 Checklist de Teste

### Teste Básico (Aluno)
- [ ] Login como aluno
- [ ] Abrir "Novo Chamado"
- [ ] **Não** deve ver botão "Mostrar opções avançadas"
- [ ] Preencher descrição
- [ ] Criar chamado com sucesso (IA automática)

### Teste Avançado (Admin)
- [ ] Login como admin
- [ ] Abrir "Novo Chamado"
- [ ] Ver botão "Mostrar opções avançadas"
- [ ] Clicar no botão → seção expande
- [ ] Ver campo "Título"
- [ ] Ver switch "Classificar com IA" (ligado por padrão)
- [ ] Desligar switch
- [ ] Ver picker "Categoria"
- [ ] Ver picker "Prioridade"
- [ ] Selecionar categoria e prioridade
- [ ] Criar chamado com classificação manual
- [ ] Navegar para página de confirmação sem crash

---

### 📝 Arquivos Modificados

### Com correções funcionais:
1. **`ViewModels/NovoChamadoViewModel.cs`**
   - Rota absoluta na navegação para confirmação (`///chamados/confirmacao`)
   - Logging extensivo no método Criar()
   - Logging de permissões no construtor
   - Logging ao alternar opções avançadas

2. **`Services/Auth/AuthService.cs`**
   - Salvamento de `Settings.TipoUsuario` após login
   - Salvamento de `Settings.UserId`, `Settings.NomeUsuario`, `Settings.Email`
   - Logging de confirmação dos settings

3. **`Views/ChamadoConfirmacaoPage.xaml.cs`**
   - Logging no construtor
   - Logging no ApplyQueryAttributes

4. **`ViewModels/ChamadoConfirmacaoViewModel.cs`**
   - Rota absoluta na navegação para detalhes (`///chamados/detail`)
   - Logging extensivo no método IrParaDetalhesAsync()
   - Try-catch com mensagem amigável ao usuário

### XAML (já estava correto):
- `Views/NovoChamadoPage.xaml`
  - Estrutura de visibilidade já implementada
  - Bindings corretos

---

## 🚀 Próximos Passos

1. **Executar testes acima**
2. **Verificar logs** em `%LOCALAPPDATA%\SistemaChamados.Mobile-app-log.txt`
3. **Reportar resultados:**
   - ✅ Se funcionou: documentar
   - ❌ Se crashou: copiar stack trace dos logs
   - ⚠️ Se opções não aparecem: copiar logs de permissões

---

## 📚 Documentação Relacionada

- `CORRECOES_WINDOWS.md` - Correções gerais do Windows
- `CORRECOES_NAVEGACAO.md` - Arquitetura de navegação Shell
- `CREDENCIAIS_TESTE.md` - Usuários para teste
- `PERMISSOES.md` - Permissões por tipo de usuário

---

**Última atualização:** 20/10/2025  
**Status:** ✅ Correções aplicadas, aguardando teste do usuário
