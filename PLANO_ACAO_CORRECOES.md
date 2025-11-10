# 📋 PLANO DE AÇÃO: Correção de Incompatibilidades Mobile ↔ Backend

**Data:** 10/11/2025  
**Objetivo:** Garantir funcionamento completo do app mobile com backend existente  
**Estratégia:** Maximizar correções mobile-only, minimizar mudanças no backend

---

## 🎯 PRIORIDADE 1: AÇÕES MOBILE-ONLY (Executar PRIMEIRO)

> **Premissa:** Estas ações adaptam o mobile ao backend existente, sem modificar a API.  
> **Risco:** 🟢 BAIXO - Mudanças isoladas no cliente  
> **Tempo estimado:** 70-90 minutos  
> **Bloqueadores:** NENHUM

---

### 📦 **FASE 1: Correções Críticas de Lógica de Negócio (15 min)**

#### ✅ **Ação 1.1: Corrigir StatusId no método Close()**
**Problema:** Método usa StatusId=5 (Violado) em vez de 4 (Fechado)  
**Impacto:** 🔴 CRÍTICO - Chamados sendo fechados incorretamente

**Arquivo:** `backend-guinrb/Mobile/Services/Chamados/ChamadoService.cs`

**Mudança:**
```csharp
// LOCALIZAR (linha ~60-65):
public Task<ChamadoDto?> Close(int id)
{
    var atualizacao = new AtualizarChamadoDto
    {
        StatusId = 5 // ERRADO
    };
    return _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", atualizacao);
}

// SUBSTITUIR POR:
public Task<ChamadoDto?> Close(int id)
{
    var atualizacao = new AtualizarChamadoDto
    {
        StatusId = 4 // ✅ CORRETO: 4 = Fechado
    };
    return _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", atualizacao);
}
```

**Validação:**
```bash
# Buscar para confirmar mudança
grep -n "StatusId = 4" backend-guinrb/Mobile/Services/Chamados/ChamadoService.cs
```

---

#### ✅ **Ação 1.2: Criar Constantes de Status**
**Problema:** Magic numbers espalhados pelo código (hardcoded 1, 2, 3, 4, 5)  
**Impacto:** 🟡 MÉDIO - Dificulta manutenção

**Arquivo:** `backend-guinrb/Mobile/Helpers/Constants.cs`

**Mudança:**
```csharp
// ADICIONAR ao final do arquivo Constants.cs:

/// <summary>
/// Status de chamados (sincronizado com banco de dados)
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
/// Tipos de usuário (sincronizado com banco de dados)
/// </summary>
public static class TipoUsuario
{
    public const int UsuarioComum = 1;
    public const int Tecnico = 2;
    public const int Administrador = 3;
}
```

**Validação:**
```bash
# Confirmar que arquivo foi atualizado
grep -n "StatusChamado" backend-guinrb/Mobile/Helpers/Constants.cs
```

---

#### ✅ **Ação 1.3: Atualizar ChamadoService para usar constantes**
**Problema:** Método Close ainda usa número literal  
**Impacto:** 🟢 BAIXO - Melhoria de código

**Arquivo:** `backend-guinrb/Mobile/Services/Chamados/ChamadoService.cs`

**Mudança:**
```csharp
// NO TOPO DO ARQUIVO, adicionar using:
using SistemaChamados.Mobile.Helpers;

// ATUALIZAR o método Close:
public Task<ChamadoDto?> Close(int id)
{
    var atualizacao = new AtualizarChamadoDto
    {
        StatusId = StatusChamado.Fechado  // ✅ Usa constante
    };
    return _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", atualizacao);
}
```

**Validação:**
```bash
# Confirmar uso de constante
grep -n "StatusChamado.Fechado" backend-guinrb/Mobile/Services/Chamados/ChamadoService.cs
```

---

### 📦 **FASE 2: Adaptação de DTOs - Comentários (25 min)**

#### ✅ **Ação 2.1: Remover campo IsInterno do Request DTO**
**Problema:** Mobile envia `IsInterno`, backend ignora (campo não existe na API)  
**Impacto:** 🔴 ALTO - Funcionalidade não funciona, confunde usuário

**Arquivo:** `backend-guinrb/Mobile/Models/DTOs/CriarComentarioRequestDto.cs`

**Mudança:**
```csharp
// ANTES:
public class CriarComentarioRequestDto
{
    public string Texto { get; set; } = string.Empty;
    public bool IsInterno { get; set; }  // ❌ REMOVER COMPLETAMENTE
}

// DEPOIS:
public class CriarComentarioRequestDto
{
    [Required(ErrorMessage = "O texto do comentário é obrigatório")]
    [StringLength(1000, MinimumLength = 1, ErrorMessage = "O comentário deve ter entre 1 e 1000 caracteres")]
    public string Texto { get; set; } = string.Empty;
}
```

**Validação:**
```bash
# Confirmar que IsInterno foi removido
grep -i "isinterno" backend-guinrb/Mobile/Models/DTOs/CriarComentarioRequestDto.cs
# Resultado esperado: SEM MATCHES
```

---

#### ✅ **Ação 2.2: Marcar IsInterno como Obsoleto no Response DTO**
**Problema:** Mobile espera `IsInterno` na resposta, backend nunca envia  
**Impacto:** 🟡 MÉDIO - Campo sempre fica `false`, pode confundir UI

**Arquivo:** `backend-guinrb/Mobile/Models/DTOs/ComentarioDto.cs`

**Mudança:**
```csharp
// LOCALIZAR a propriedade IsInterno:
public bool IsInterno { get; set; }

// SUBSTITUIR POR:
/// <summary>
/// ATENÇÃO: Backend não suporta comentários internos.
/// Este campo sempre será false (valor padrão).
/// Mantido apenas para compatibilidade de desserialização.
/// </summary>
[Obsolete("Backend não implementa comentários internos. Sempre retorna false.")]
[JsonProperty(DefaultValueHandling = DefaultValueHandling.Populate)]
public bool IsInterno { get; set; } = false;
```

**Validação:**
```bash
# Confirmar que campo tem [Obsolete]
grep -A2 "Obsolete" backend-guinrb/Mobile/Models/DTOs/ComentarioDto.cs | grep "IsInterno"
```

---

#### ✅ **Ação 2.3: Unificar DataHora e DataCriacao**
**Problema:** Mobile tem dois campos de data, backend envia apenas `DataCriacao`  
**Impacto:** 🟡 MÉDIO - `DataHora` fica com valor padrão (01/01/0001)

**Arquivo:** `backend-guinrb/Mobile/Models/DTOs/ComentarioDto.cs`

**Mudança:**
```csharp
// LOCALIZAR:
public DateTime DataCriacao { get; set; }
public DateTime DataHora { get; set; }

// SUBSTITUIR POR:
[JsonProperty("DataCriacao")]
public DateTime DataCriacao { get; set; }

/// <summary>
/// Alias para DataCriacao (compatibilidade com UI existente).
/// Backend envia apenas DataCriacao, este campo é calculado.
/// </summary>
[JsonIgnore]
public DateTime DataHora => DataCriacao;
```

**Validação:**
```bash
# Confirmar que DataHora é propriedade calculada
grep -n "DataHora =>" backend-guinrb/Mobile/Models/DTOs/ComentarioDto.cs
```

---

#### ✅ **Ação 2.4: Criar Adapter para campo Usuario**
**Problema:** Backend envia `UsuarioNome` (string) e `UsuarioId` (int), mobile espera objeto `Usuario`  
**Impacto:** 🟡 MÉDIO - Campo `Usuario` fica `null`, UI pode quebrar se não houver fallback

**Arquivo:** `backend-guinrb/Mobile/Models/DTOs/ComentarioDto.cs`

**Mudança:**
```csharp
// NO TOPO DO ARQUIVO, adicionar using:
using System.Runtime.Serialization;
using Newtonsoft.Json;

// LOCALIZAR as propriedades:
public int UsuarioId { get; set; }
public string UsuarioNome { get; set; } = string.Empty;
public UsuarioResumoDto? Usuario { get; set; }

// ADICIONAR método após as propriedades:
/// <summary>
/// Adapter: Popula automaticamente o objeto Usuario após desserialização.
/// Backend envia apenas UsuarioId e UsuarioNome, este método cria o objeto.
/// </summary>
[OnDeserialized]
internal void OnDeserializedMethod(StreamingContext context)
{
    // Se Usuario ainda está null e temos dados do usuário, criar objeto
    if (Usuario == null && !string.IsNullOrEmpty(UsuarioNome))
    {
        Usuario = new UsuarioResumoDto
        {
            Id = UsuarioId,
            Nome = UsuarioNome,
            // Outros campos do UsuarioResumoDto ficarão com valores padrão
        };
    }
}
```

**Validação:**
```bash
# Confirmar que método OnDeserialized existe
grep -n "OnDeserialized" backend-guinrb/Mobile/Models/DTOs/ComentarioDto.cs
```

---

### 📦 **FASE 3: Melhorias de UX e Segurança (20 min)**

#### ✅ **Ação 3.1: Documentar limitação de segurança em AuthService**
**Problema:** Validação de TipoUsuario está apenas no cliente (não é seguro)  
**Impacto:** 🟡 MÉDIO - Vulnerável a bypass, mas funciona para uso normal

**Arquivo:** `backend-guinrb/Mobile/Services/Auth/AuthService.cs`

**Mudança:**
```csharp
// LOCALIZAR (método Login, após validação do TipoUsuario):
if (resp.TipoUsuario != 1)
{
    Debug.WriteLine($"[AuthService] Login negado: TipoUsuario {resp.TipoUsuario} não tem acesso ao app mobile");
    throw new UnauthorizedAccessException("Apenas usuários comuns podem acessar o aplicativo mobile.");
}

// ADICIONAR COMENTÁRIO ANTES:
// ⚠️ LIMITAÇÃO DE SEGURANÇA:
// Esta validação é APENAS client-side (UX). A segurança real DEVE estar no backend.
// Um atacante técnico pode fazer requests HTTP diretos à API, ignorando esta verificação.
// RECOMENDAÇÃO: Implementar validação de TipoUsuario nos endpoints do backend.
if (resp.TipoUsuario != 1)
{
    Debug.WriteLine($"[AuthService] Login negado: TipoUsuario {resp.TipoUsuario} não tem acesso ao app mobile");
    throw new UnauthorizedAccessException("Apenas usuários comuns podem acessar o aplicativo mobile.");
}
```

**Validação:**
```bash
# Confirmar que comentário de segurança foi adicionado
grep -n "LIMITAÇÃO DE SEGURANÇA" backend-guinrb/Mobile/Services/Auth/AuthService.cs
```

---

#### ✅ **Ação 3.2: Atualizar AuthService para usar constantes**
**Problema:** Usa número literal `1` para tipo de usuário  
**Impacto:** 🟢 BAIXO - Melhoria de código

**Arquivo:** `backend-guinrb/Mobile/Services/Auth/AuthService.cs`

**Mudança:**
```csharp
// NO TOPO DO ARQUIVO, adicionar using:
using SistemaChamados.Mobile.Helpers;

// LOCALIZAR:
if (resp.TipoUsuario != 1)

// SUBSTITUIR POR:
if (resp.TipoUsuario != TipoUsuario.UsuarioComum)
```

**Validação:**
```bash
# Confirmar uso de constante
grep -n "TipoUsuario.UsuarioComum" backend-guinrb/Mobile/Services/Auth/AuthService.cs
```

---

#### ✅ **Ação 3.3: Adicionar confirmação no "Analisar com IA"**
**Problema:** Endpoint `/analisar` cria o chamado automaticamente, mas nome sugere apenas análise  
**Impacto:** 🟡 MÉDIO - Usuário pode criar chamados sem querer

**Arquivo:** Verificar qual ViewModel usa `CreateComAnaliseAutomatica`

**Mudança:**
```csharp
// PROCURAR por CreateComAnaliseAutomatica no código
// Provavelmente em NovoChamadoViewModel ou similar

// ANTES (método que chama a análise):
var resultado = await _chamadoService.CreateComAnaliseAutomatica(descricao);

// DEPOIS (adicionar confirmação):
bool confirma = await Application.Current.MainPage.DisplayAlert(
    "Confirmar Criação",
    "A inteligência artificial irá analisar sua descrição e criar o chamado automaticamente. Deseja continuar?",
    "Sim, criar chamado",
    "Cancelar"
);

if (!confirma) 
{
    return; // ou IsBusy = false; dependendo do contexto
}

var resultado = await _chamadoService.CreateComAnaliseAutomatica(descricao);
```

**Validação:**
```bash
# Procurar onde CreateComAnaliseAutomatica é usado
grep -rn "CreateComAnaliseAutomatica" backend-guinrb/Mobile/ViewModels/
```

---

### 📦 **FASE 4: Limpeza e Validação (10 min)**

#### ✅ **Ação 4.1: Remover código morto (se existir)**
**Problema:** Converters ou helpers relacionados a `IsInterno` que não são mais usados  
**Impacto:** 🟢 BAIXO - Limpeza de código

**Arquivos:** `backend-guinrb/Mobile/Converters/`

**Mudança:**
```bash
# Verificar se existem converters para IsInterno
grep -rn "IsInterno" backend-guinrb/Mobile/Converters/

# Se encontrar, avaliar se ainda são necessários e remover arquivos não utilizados
```

**Validação:**
```bash
# Confirmar que build ainda passa
dotnet build backend-guinrb/Mobile/SistemaChamados.Mobile.csproj
```

---

#### ✅ **Ação 4.2: Atualizar Views que usam IsInterno**
**Problema:** XAML pode ter controles (CheckBox, Switch) vinculados a `IsInterno`  
**Impacto:** 🟡 MÉDIO - UI pode ter controles quebrados ou não funcionais

**Arquivos:** `backend-guinrb/Mobile/Views/*.xaml`

**Mudança:**
```bash
# Procurar por bindings de IsInterno nas Views
grep -rn "IsInterno" backend-guinrb/Mobile/Views/

# OPÇÕES:
# 1. Remover controle completamente (CheckBox "Comentário interno")
# 2. Desabilitar controle (IsEnabled="False") com tooltip explicativo
# 3. Substituir por label informativo "Todos os comentários são públicos"
```

**Exemplo de remoção:**
```xml
<!-- ANTES -->
<CheckBox x:Name="chkInterno" 
          IsChecked="{Binding IsInterno}" 
          Text="Comentário interno" />

<!-- DEPOIS (Remover completamente OU substituir por:) -->
<Label Text="ℹ️ Todos os comentários são visíveis para técnicos e solicitantes"
       FontSize="12"
       TextColor="Gray" />
```

**Validação:**
```bash
# Confirmar que não há erros de binding
# (executar app e verificar console de debug)
```

---

#### ✅ **Ação 4.3: Rebuild Completo**
**Problema:** Garantir que todas as mudanças compilam corretamente  
**Impacto:** 🔴 CRÍTICO - Validação final

**Comandos:**
```bash
# Limpar build anterior
dotnet clean backend-guinrb/Mobile/SistemaChamados.Mobile.csproj

# Rebuild
dotnet build backend-guinrb/Mobile/SistemaChamados.Mobile.csproj -c Release

# Verificar warnings
dotnet build backend-guinrb/Mobile/SistemaChamados.Mobile.csproj -c Release --no-incremental -v minimal
```

**Validação:**
```bash
# Exit code deve ser 0
echo $LASTEXITCODE  # Windows PowerShell
```

---

#### ✅ **Ação 4.4: Gerar novo APK**
**Problema:** APK anterior tem bugs conhecidos  
**Impacto:** 🔴 CRÍTICO - APK atualizado para testes

**Comandos:**
```bash
# Gerar APK para dispositivo físico
dotnet publish backend-guinrb/Mobile/SistemaChamados.Mobile.csproj `
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
```bash
# Verificar que APK foi gerado
ls backend-guinrb/Mobile/bin/Release/net8.0-android/*.apk
```

---

## 🎯 PRIORIDADE 2: AÇÕES DE BACKEND (Inevitáveis)

> **Premissa:** Problemas que NÃO PODEM ser contornados no mobile  
> **Risco:** 🟡 MÉDIO - Requer mudanças no servidor  
> **Tempo estimado:** 2-3 horas (se necessário)  
> **Status:** ⚠️ OPCIONAL (app funciona sem isso)

---

### ❌ **Backend-1: NÃO OBRIGATÓRIO - Verificação de SLA em GET**

**Problema:** Backend executa update de status dentro de endpoint GET `/api/chamados`

**Por que mobile não pode corrigir?**
- É um **side-effect do backend** (GET modifica dados)
- Mobile apenas **consome** o endpoint
- Não há como desabilitar esse comportamento do lado do cliente

**Impacto ATUAL:**
- 🟢 **App mobile funciona normalmente**
- 🟡 Pode haver lentidão em listagens (backend processa TODOS os chamados)
- 🟡 Viola padrão REST (GET deveria ser idempotente)

**Solução (SE o backend for modificado no futuro):**
```csharp
// Backend: Mover verificação de SLA para background job
// Opção 1: Hangfire (recomendado)
RecurringJob.AddOrUpdate(
    "verificar-sla",
    () => slaService.VerificarChamadosViolados(),
    Cron.Minutely
);

// Opção 2: Trigger de banco de dados
// Opção 3: Endpoint dedicado POST /api/admin/verificar-sla
```

**DECISÃO:** ✅ **ACEITAR LIMITAÇÃO** (não bloqueia funcionalidade)

---

### ❌ **Backend-2: NÃO OBRIGATÓRIO - Lógica de SLA no Controller**

**Problema:** Código de cálculo de SLA está dentro do `ChamadosController` (deveria estar em service)

**Por que mobile não pode corrigir?**
- É um problema **interno de arquitetura do backend**
- Mobile não tem acesso ao código do servidor
- Refatoração de código do backend não afeta contratos da API

**Impacto ATUAL:**
- 🟢 **ZERO impacto no mobile** (transparente)
- 🟡 Dificulta manutenção do backend
- 🟡 Dificulta testes unitários do backend

**Solução (SE o backend for refatorado no futuro):**
```csharp
// Backend: Criar ISlaService
public interface ISlaService
{
    DateTime? CalcularSla(int nivelPrioridade, DateTime dataAbertura);
    Task<List<Chamado>> ObterChamadosViolados();
}

// Controller apenas delega
var sla = _slaService.CalcularSla(prioridade.Nivel, DateTime.UtcNow);
```

**DECISÃO:** ✅ **IGNORAR** (problema interno do backend)

---

### ⚠️ **Backend-3: OPCIONAL - Validação de TipoUsuario em Endpoints**

**Problema:** Validação de tipo de usuário está apenas no mobile (client-side)

**Por que mobile não pode corrigir?**
- Segurança **NUNCA** deve depender apenas do cliente
- Qualquer pessoa pode fazer HTTP requests diretos à API
- Backend precisa rejeitar chamadas inválidas

**Impacto ATUAL:**
- 🟢 **App mobile funciona** (validação client-side impede acesso de técnicos/admins)
- 🔴 **Vulnerável** se alguém fizer requests diretos (curl, Postman, outro app)
- 🟡 Técnico/Admin poderia criar chamados usando Swagger ou API direta

**Solução (RECOMENDADO para produção):**
```csharp
// Backend: ChamadosController.cs
[HttpPost]
[Authorize]
public async Task<IActionResult> CriarChamado([FromBody] CriarChamadoRequestDto request)
{
    // Validação de tipo de usuário
    var tipoUsuarioStr = User.FindFirst("TipoUsuario")?.Value;
    if (tipoUsuarioStr != "1")
    {
        return StatusCode(403, new { 
            error = "Apenas usuários comuns podem criar chamados via API mobile." 
        });
    }
    
    // ... resto do código
}
```

**DECISÃO:** ⚠️ **RECOMENDAR para futuro** (não bloqueia MVP)

---

### ❌ **Backend-4: NÃO APLICÁVEL - Dados Faltantes**

**Problema:** Mobile precisa de dados que backend NÃO envia?

**Análise:**
✅ **TODOS os dados necessários estão sendo enviados:**
- `UsuarioNome` ✅ Enviado
- `DataCriacao` ✅ Enviado
- `StatusId` ✅ Enviado
- `ChamadoId` ✅ Enviado

❌ **Dados NÃO enviados pelo backend (mas não são críticos):**
- `IsInterno` - ❌ Não enviado (funcionalidade não existe no backend)
- Objeto `Usuario` completo - ❌ Apenas `UsuarioId` + `UsuarioNome` (suficiente)

**Impacto ATUAL:**
- 🟢 **Nenhum dado crítico faltando**
- 🟢 Mobile adaptou DTOs para usar dados disponíveis

**DECISÃO:** ✅ **PROBLEMA NÃO EXISTE** (backend envia tudo necessário)

---

## 📊 RESUMO EXECUTIVO

### ✅ Prioridade 1: Mobile-Only (FAZER AGORA)

| Fase | Ações | Tempo | Risco | Status |
|------|-------|-------|-------|--------|
| **Fase 1** | Correções críticas (Status, Constantes) | 15 min | 🟢 Baixo | ⏳ Pendente |
| **Fase 2** | Adaptação DTOs (Comentários) | 25 min | 🟢 Baixo | ⏳ Pendente |
| **Fase 3** | Melhorias UX/Segurança | 20 min | 🟢 Baixo | ⏳ Pendente |
| **Fase 4** | Limpeza e Validação | 10 min | 🟢 Baixo | ⏳ Pendente |
| **TOTAL** | **13 ações** | **~70 min** | 🟢 **Baixo** | - |

**Bloqueadores:** NENHUM  
**Dependências:** NENHUMA  
**Pode começar:** ✅ AGORA

---

### ⚠️ Prioridade 2: Backend (OPCIONAL)

| Item | Necessidade | Impacto no Mobile | Decisão |
|------|-------------|-------------------|---------|
| SLA em GET | ❌ Não obrigatório | 🟢 Zero (funciona) | ✅ Aceitar limitação |
| SLA no Controller | ❌ Não obrigatório | 🟢 Zero (interno) | ✅ Ignorar |
| Validação TipoUsuario | ⚠️ Recomendado | 🟡 Segurança apenas client-side | ⚠️ Documentar |
| Dados faltantes | ❌ Não aplicável | 🟢 Tudo disponível | ✅ N/A |

**Bloqueadores para MVP:** NENHUM  
**Recomendações futuras:** Implementar validação de TipoUsuario no backend

---

## 🚀 ROTEIRO DE EXECUÇÃO

### 📅 Hoje (10/11/2025) - Fase Mobile

```
[09:00-09:15] ✅ Fase 1: Correções Críticas
  ├─ Ação 1.1: Corrigir StatusId (5→4)
  ├─ Ação 1.2: Criar constantes
  └─ Ação 1.3: Atualizar ChamadoService

[09:15-09:40] ✅ Fase 2: DTOs de Comentários  
  ├─ Ação 2.1: Remover IsInterno do request
  ├─ Ação 2.2: Marcar IsInterno obsoleto
  ├─ Ação 2.3: Unificar DataHora/DataCriacao
  └─ Ação 2.4: Adapter para Usuario

[09:40-10:00] ✅ Fase 3: UX e Segurança
  ├─ Ação 3.1: Documentar segurança
  ├─ Ação 3.2: Usar constantes em AuthService
  └─ Ação 3.3: Confirmação para IA

[10:00-10:10] ✅ Fase 4: Validação
  ├─ Ação 4.1: Limpar código morto
  ├─ Ação 4.2: Atualizar Views XAML
  ├─ Ação 4.3: Rebuild completo
  └─ Ação 4.4: Gerar APK

[10:10-10:30] 🧪 Testes Básicos
  ├─ Instalar APK em dispositivo
  ├─ Testar login
  ├─ Criar chamado
  ├─ Adicionar comentário
  └─ Fechar chamado (validar StatusId=4)
```

**Total:** ~90 minutos

---

### 📅 Futuro (quando backend for evoluído)

```
[OPCIONAL] Melhorias de Backend
  ├─ Implementar validação TipoUsuario em endpoints
  ├─ Mover verificação SLA para background job
  ├─ Refatorar lógica SLA para ISlaService
  └─ Criar endpoint POST /api/chamados/preview-analise
```

---

## ✅ CRITÉRIOS DE ACEITAÇÃO

### Deve funcionar:
- [ ] Login com usuário comum (TipoUsuario=1)
- [ ] Rejeitar login de técnico/admin
- [ ] Criar chamado manual
- [ ] Criar chamado com análise IA (com confirmação)
- [ ] Listar meus chamados
- [ ] Ver detalhes de chamado
- [ ] Adicionar comentário (sem campo IsInterno)
- [ ] Fechar chamado (StatusId=4)
- [ ] Exibir datas corretamente
- [ ] Exibir nomes de usuários em comentários

### Não deve ter:
- [ ] Erros de binding no console
- [ ] Campos IsInterno visíveis na UI
- [ ] Warnings de compilação relacionados aos DTOs
- [ ] Crashes ao desserializar respostas da API

### Limitações aceitas (documentadas):
- [ ] Comentários sempre públicos (sem opção "interno")
- [ ] Validação de tipo usuário apenas client-side
- [ ] Performance de listagem controlada pelo backend
- [ ] Verificação de SLA acontece em GET (side-effect)

---

## 📝 CHECKLIST DE VALIDAÇÃO FINAL

```
[ ] Código compila sem erros
[ ] Código compila sem warnings críticos
[ ] APK gerado com sucesso
[ ] APK instalável em dispositivo
[ ] Login funciona
[ ] CRUD de chamados funciona
[ ] Comentários funcionam sem IsInterno
[ ] Fechar chamado usa StatusId=4
[ ] Datas exibidas corretamente
[ ] Nenhum crash em operações básicas
[ ] README atualizado com limitações conhecidas
```

---

## 🎯 PRÓXIMOS PASSOS IMEDIATOS

1. ✅ **EXECUTAR** Prioridade 1 (todas as 13 ações mobile-only)
2. ✅ **TESTAR** APK em dispositivo físico
3. ✅ **DOCUMENTAR** limitações em README
4. ⚠️ **AVALIAR** se validação backend é necessária antes de produção
5. ✅ **DEPLOY** se testes passarem

---

**Status Final Esperado:**  
🟢 App mobile 100% funcional com backend existente  
🟡 Algumas limitações arquiteturais aceitas  
🔴 Nenhum bloqueador para MVP

---

**Autor:** GitHub Copilot  
**Data:** 10/11/2025  
**Versão:** 1.0
