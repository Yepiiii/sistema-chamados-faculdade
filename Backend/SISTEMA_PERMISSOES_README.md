# Sistema de Permissões - Chamados

## 📋 Visão Geral

Sistema completo de permissões implementado para controlar o acesso e ações sobre chamados com base em três perfis de usuário: **Colaborador**, **Técnico** e **Admin**.

---

## 👥 Perfis e Permissões

### 1. Colaborador (TipoUsuario = 1)

**Pode:**
- ✅ **Criar** chamados (com análise automática de IA)
- ✅ **Visualizar** apenas os chamados que ele mesmo criou
- ✅ **Ver o técnico atribuído** em seus chamados
- ✅ **Editar** seus próprios chamados (enquanto não estiverem encerrados)

**Não Pode:**
- ❌ Visualizar chamados de outros colaboradores
- ❌ Visualizar todos os chamados do sistema
- ❌ Encerrar chamados (nem os próprios)
- ❌ Atribuir ou reatribuir técnicos
- ❌ Usar classificação manual (sem IA)

---

### 2. Técnico TI (TipoUsuario = 2)

**Pode:**
- ✅ **Visualizar** apenas os chamados atribuídos a ele
- ✅ **Encerrar** os chamados atribuídos a ele
- ✅ **Ver informações** completas dos chamados atribuídos

**Não Pode:**
- ❌ Criar novos chamados
- ❌ Visualizar chamados atribuídos a outros técnicos
- ❌ Visualizar todos os chamados do sistema
- ❌ Editar chamados
- ❌ Atribuir ou reatribuir técnicos
- ❌ Visualizar chamados sem técnico atribuído

---

### 3. Administrador (TipoUsuario = 3)

**Pode:**
- ✅ **Visualização TOTAL** de todos os chamados
- ✅ **Criar** chamados (com ou sem análise de IA)
- ✅ **Editar** qualquer chamado
- ✅ **Encerrar** qualquer chamado
- ✅ **Atribuir/Reatribuir** técnicos
- ✅ **Mudar status** de qualquer chamado
- ✅ **Deletar** chamados (se implementado)
- ✅ **Usar classificação manual** (bypass da IA)

---

## 🔐 Regras de Visibilidade

### Visibilidade do Técnico Atribuído

**TODOS os usuários** (Colaborador, Técnico, Admin) podem ver:
- Nome do técnico atribuído
- Nível do técnico (1 - Básico, 2 - Intermediário, 3 - Sênior)
- Informações de contato do técnico

Isso garante transparência para o solicitante saber quem está resolvendo seu problema.

### Filtros Aplicados por Perfil

#### Colaborador
```csharp
query.Where(c => c.SolicitanteId == usuarioId)
```
Retorna apenas chamados onde ele é o solicitante.

#### Técnico
```csharp
query.Where(c => c.TecnicoId == usuarioId)
```
Retorna apenas chamados atribuídos a ele.

#### Admin
```csharp
// Sem filtro - retorna tudo
```

---

## 🛠️ Endpoints e Permissões

### POST /api/chamados
**Criar novo chamado**

| Perfil | Permitido | Observação |
|--------|-----------|------------|
| Colaborador | ✅ | Apenas com análise automática |
| Técnico | ❌ | Bloqueado |
| Admin | ✅ | Pode usar análise manual |

---

### GET /api/chamados
**Listar chamados**

| Perfil | Retorna | Observação |
|--------|---------|------------|
| Colaborador | Apenas seus | Filtrado por SolicitanteId |
| Técnico | Apenas atribuídos a ele | Filtrado por TecnicoId |
| Admin | Todos | Sem filtro |

---

### GET /api/chamados/{id}
**Detalhes de um chamado**

| Perfil | Permitido | Observação |
|--------|-----------|------------|
| Colaborador | ✅ Se for seu | Verifica SolicitanteId |
| Técnico | ✅ Se estiver atribuído | Verifica TecnicoId |
| Admin | ✅ Sempre | Sem restrição |

---

### PUT /api/chamados/{id}
**Atualizar chamado**

| Perfil | Permitido | Observação |
|--------|-----------|------------|
| Colaborador | ✅ Seus próprios | Apenas se não encerrado |
| Técnico | ❌ | Não pode editar |
| Admin | ✅ Todos | Sem restrição |

**Permissões especiais:**
- Mudar status: Admin sempre, Técnico apenas para encerrar (status 3)
- Reatribuir técnico: Apenas Admin

---

### POST /api/chamados/{id}/encerrar
**Encerrar chamado específico**

| Perfil | Permitido | Observação |
|--------|-----------|------------|
| Colaborador | ❌ | Não pode encerrar |
| Técnico | ✅ Se estiver atribuído | Verifica TecnicoId |
| Admin | ✅ Sempre | Sem restrição |

**Ações executadas:**
1. Muda status para 3 (Encerrado)
2. Define DataFechamento = DateTime.UtcNow
3. Atualiza DataUltimaAtualizacao
4. *(Futuro)* Salva solução como comentário

---

## 🏗️ Arquitetura do Sistema

### Serviço Centralizado: PermissoesService

Localização: `Backend/Application/Services/PermissoesService.cs`

Métodos disponíveis:

```csharp
// Verificação de permissões
PodeVisualizarChamado(Chamado, usuarioId, tipoUsuario) -> bool
PodeCriarChamado(tipoUsuario) -> bool
PodeEditarChamado(Chamado, usuarioId, tipoUsuario) -> bool
PodeEncerrarChamado(Chamado, usuarioId, tipoUsuario) -> bool
PodeAtribuirTecnico(tipoUsuario) -> bool
PodeComentarChamado(Chamado, usuarioId, tipoUsuario) -> bool
PodeDeletarChamado(tipoUsuario) -> bool
PodeMudarStatus(Chamado, usuarioId, tipoUsuario, novoStatusId) -> bool

// Utilitários
ObterDescricaoPermissoes(tipoUsuario) -> string
```

### Enum TipoUsuario

Localização: `Backend/Core/Enums/TipoUsuario.cs`

```csharp
public enum TipoUsuario
{
    Colaborador = 1,
    TecnicoTI = 2,
    Admin = 3
}
```

---

## 🧪 Testes

### Script de Teste Automatizado

Localização: `Backend/Scripts/TestePermissoes.ps1`

**Testes executados:**
1. ✅ Autenticação dos 3 perfis
2. ✅ Visualização de chamados por perfil
3. ✅ Técnico tentando criar chamado (deve falhar)
4. ✅ Colaborador criando chamado (deve funcionar)
5. ✅ Técnico encerrando seu chamado (deve funcionar)
6. ✅ Colaborador tentando encerrar chamado (deve falhar)

**Executar teste:**
```powershell
cd Backend
dotnet run &  # Inicia API em background
Start-Sleep -Seconds 5
.\Scripts\TestePermissoes.ps1
```

---

## 📊 Credenciais de Teste

### Colaborador
```
Email: colaborador@empresa.com
Senha: Admin@123
Tipo: 1 (Colaborador)
```

### Técnicos (Sistema com 2 níveis)
```
1. Email: tecnico@empresa.com - Nível 1 (Básico)
   Senha: Admin@123
   
2. Email: senior@empresa.com - Nível 3 (Sênior)
   Senha: Admin@123
   
NOTA: junior@empresa.com (Nível 2) foi REMOVIDO do sistema
```

### Administrador
```
Email: admin@sistema.com
Senha: Admin@123
Tipo: 3 (Admin)
```

---

## 🔄 Fluxo de Trabalho Típico

### 1. Colaborador Cria Chamado
```
Colaborador → API → IA Analisa → Atribui Técnico → Colaborador vê técnico atribuído
```

### 2. Técnico Resolve Problema
```
Técnico → Vê chamado atribuído → Trabalha no problema → Encerra chamado
```

### 3. Admin Monitora
```
Admin → Visualiza todos → Reatribui se necessário → Monitora SLA
```

---

## ⚠️ Mensagens de Erro

### 403 Forbidden - Técnico tentando criar
```json
{
  "error": "Técnicos não podem criar chamados. Apenas Colaboradores e Administradores têm essa permissão."
}
```

### 403 Forbidden - Colaborador tentando encerrar
```json
{
  "error": "Você não tem permissão para encerrar este chamado. Apenas o técnico atribuído ou administradores podem encerrá-lo."
}
```

### 403 Forbidden - Acesso negado
```json
{
  "error": "Acesso negado ao chamado solicitado."
}
```

### 403 Forbidden - Reatribuição
```json
{
  "error": "Apenas administradores podem atribuir ou reatribuir técnicos."
}
```

---

## 🚀 Próximos Passos (Melhorias Futuras)

1. **Sistema de Comentários**
   - Permitir técnicos e solicitantes comentarem em chamados
   - Histórico de interações

2. **Notificações**
   - Email quando chamado é atribuído
   - Email quando chamado é encerrado

3. **Reabertura de Chamados**
   - Colaborador pode reabrir chamado encerrado (dentro de X dias)

4. **Avaliação de Atendimento**
   - Colaborador avalia técnico após encerramento

5. **Delegação de Chamados**
   - Técnico pode delegar para outro técnico (com aprovação)

6. **Logs de Auditoria**
   - Registrar todas as ações com timestamp e usuário

---

## 📝 Notas de Implementação

- ✅ Enum `TipoUsuario` criado para type-safety
- ✅ Serviço `PermissoesService` centralizado
- ✅ Controller `ChamadosController` atualizado
- ✅ Endpoint `/encerrar` criado especificamente para técnicos
- ✅ Filtros aplicados em queries com base no perfil
- ✅ Validações de permissão em todas as ações
- ✅ Logs detalhados de tentativas de acesso negado
- ✅ Mensagens de erro claras e informativas

---

## 🔍 Status dos Chamados

| ID | Nome | Descrição |
|----|------|-----------|
| 1 | Aberto | Chamado criado, aguardando atribuição |
| 2 | Em Andamento | Técnico está trabalhando |
| 3 | Encerrado | Problema resolvido |

---

**Implementação concluída em:** 24/10/2025
**Versão:** 1.0
**Autor:** GitHub Copilot
