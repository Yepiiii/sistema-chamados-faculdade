# 🏗️ ARQUITETURA DO SISTEMA - GuiNRB

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          CAMADA MOBILE (MAUI)                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────────┐          │
│  │ LoginPage.xaml │  │ ListPage.xaml  │  │ DetailPage.xaml  │          │
│  │     (View)     │  │    (View)      │  │     (View)       │          │
│  └───────┬────────┘  └───────┬────────┘  └─────────┬────────┘          │
│          │                   │                      │                    │
│          │ Bindings          │ Bindings             │ Bindings          │
│          ↓                   ↓                      ↓                    │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────────┐          │
│  │ LoginViewModel │  │  ListViewModel │  │  DetailViewModel │          │
│  │    Commands    │  │    Commands    │  │    Commands      │          │
│  │   Properties   │  │   Properties   │  │   Properties     │          │
│  └───────┬────────┘  └───────┬────────┘  └─────────┬────────┘          │
│          │                   │                      │                    │
│          └───────────────────┴──────────────────────┘                    │
│                              │                                            │
│                              ↓                                            │
│              ┌───────────────────────────────┐                          │
│              │   Services Layer              │                          │
│              ├───────────────────────────────┤                          │
│              │ • AuthService                 │                          │
│              │ • ChamadoService              │                          │
│              │ • CategoriaService            │                          │
│              │ • StatusService               │                          │
│              │ • PrioridadeService           │                          │
│              └──────────────┬────────────────┘                          │
│                             │                                            │
│                             ↓                                            │
│              ┌───────────────────────────────┐                          │
│              │    ApiService (HTTP Client)   │                          │
│              ├───────────────────────────────┤                          │
│              │ • AddAuthorizationHeader()    │                          │
│              │ • GetAsync<T>()               │                          │
│              │ • PostAsync<T>()              │                          │
│              │ • Exception Handling ✅       │                          │
│              └──────────────┬────────────────┘                          │
│                             │                                            │
└─────────────────────────────┼────────────────────────────────────────────┘
                              │
                              │ HTTP/HTTPS
                              │ Authorization: Bearer {JWT}
                              │
┌─────────────────────────────┼────────────────────────────────────────────┐
│                             ↓                                            │
│              ┌───────────────────────────────┐                          │
│              │     ASP.NET Core API          │                          │
│              │   (Backend - Port 5246)       │                          │
│              └──────────────┬────────────────┘                          │
│                             │                                            │
│                  ┌──────────┴──────────┐                                │
│                  ↓                     ↓                                 │
│      ┌──────────────────┐   ┌──────────────────┐                       │
│      │  Authentication  │   │   Controllers    │                       │
│      │   Middleware     │   ├──────────────────┤                       │
│      ├──────────────────┤   │ • AuthController │                       │
│      │ JWT Validation   │   │ • ChamadosCtrl   │                       │
│      │ Extract Claims   │   │ • CategoriasCtrl │                       │
│      │ (TipoUsuario)    │   │ • StatusCtrl     │                       │
│      └──────────┬───────┘   │ • PrioridadesCtrl│                       │
│                 │            └─────────┬────────┘                       │
│                 └──────────────────────┘                                │
│                             │                                            │
│                             ↓                                            │
│              ┌───────────────────────────────┐                          │
│              │   Business Logic Layer        │                          │
│              ├───────────────────────────────┤                          │
│              │ • TokenService                │                          │
│              │ • GeminiService (AI)          │                          │
│              │ • EmailService                │                          │
│              │ • HandoffService              │                          │
│              └──────────────┬────────────────┘                          │
│                             │                                            │
│                             ↓                                            │
│              ┌───────────────────────────────┐                          │
│              │  Entity Framework Core        │                          │
│              │   (ApplicationDbContext)      │                          │
│              ├───────────────────────────────┤                          │
│              │ DbSet<Usuario>                │                          │
│              │ DbSet<Chamado>                │                          │
│              │ DbSet<Categoria>              │                          │
│              │ DbSet<Prioridade>             │                          │
│              │ DbSet<Status>                 │                          │
│              └──────────────┬────────────────┘                          │
│                             │                                            │
└─────────────────────────────┼────────────────────────────────────────────┘
                              │
                              │ SQL Connection
                              │ (localdb)\mssqllocaldb
                              │
┌─────────────────────────────┼────────────────────────────────────────────┐
│                             ↓                                            │
│              ┌───────────────────────────────┐                          │
│              │   SQL Server LocalDB          │                          │
│              │   Database: SistemaChamados   │                          │
│              ├───────────────────────────────┤                          │
│              │                                │                          │
│              │  ┌──────────────────────────┐ │                          │
│              │  │ Usuarios                  │ │                          │
│              │  ├──────────────────────────┤ │                          │
│              │  │ Id (PK)                   │ │                          │
│              │  │ NomeCompleto              │ │                          │
│              │  │ Email (unique)            │ │                          │
│              │  │ SenhaHash                 │ │                          │
│              │  │ TipoUsuario (1|2|3) ⭐   │ │                          │
│              │  │ Ativo                     │ │                          │
│              │  └──────────────────────────┘ │                          │
│              │                                │                          │
│              │  ┌──────────────────────────┐ │                          │
│              │  │ Chamados                  │ │                          │
│              │  ├──────────────────────────┤ │                          │
│              │  │ Id (PK)                   │ │                          │
│              │  │ Titulo                    │ │                          │
│              │  │ Descricao                 │ │                          │
│              │  │ SolicitanteId (FK)        │ │                          │
│              │  │ TecnicoId (FK)            │ │                          │
│              │  │ CategoriaId (FK)          │ │                          │
│              │  │ PrioridadeId (FK)         │ │                          │
│              │  │ StatusId (FK) ⭐          │ │                          │
│              │  │ DataAbertura              │ │                          │
│              │  │ DataFechamento            │ │                          │
│              │  └──────────────────────────┘ │                          │
│              │                                │                          │
│              │  ┌──────────────────────────┐ │                          │
│              │  │ Status                    │ │                          │
│              │  ├──────────────────────────┤ │                          │
│              │  │ 1 - Aberto                │ │                          │
│              │  │ 2 - Em andamento          │ │                          │
│              │  │ 3 - Resolvido             │ │                          │
│              │  │ 4 - Fechado ⭐✅         │ │                          │
│              │  └──────────────────────────┘ │                          │
│              │                                │                          │
│              │  ┌──────────────────────────┐ │                          │
│              │  │ Categorias                │ │                          │
│              │  │ Prioridades               │ │                          │
│              │  │ AlunoPerfis               │ │                          │
│              │  │ ProfessorPerfis           │ │                          │
│              │  └──────────────────────────┘ │                          │
│              └───────────────────────────────┘                          │
└─────────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════
                        FLUXO: ENCERRAR CHAMADO
═══════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────────┐
│ 1. MOBILE: Usuário clica "Encerrar Chamado"                             │
│    ChamadoDetailViewModel.CloseChamadoCommand executa                   │
└────────────┬────────────────────────────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ 2. CONFIRMAÇÃO: DisplayAlert("Deseja realmente encerrar?")             │
│    Usuário clica [Sim, Encerrar]                                        │
└────────────┬────────────────────────────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ 3. HTTP REQUEST                                                          │
│    POST https://10.0.2.2:5246/api/chamados/42/fechar                   │
│    Headers:                                                              │
│      Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6...              │
│      Content-Type: application/json                                     │
└────────────┬────────────────────────────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ 4. BACKEND: JWT Authentication Middleware                               │
│    - Valida assinatura do token                                         │
│    - Extrai claims: NameIdentifier=1, TipoUsuario=3                    │
│    - User.Identity autenticado ✅                                       │
└────────────┬────────────────────────────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ 5. CONTROLLER: ChamadosController.FecharChamado(id=42)                 │
│                                                                          │
│    var usuarioIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);     │
│    // usuarioId = 1                                                     │
│                                                                          │
│    var usuario = await _context.Usuarios.Find(1);                       │
│    // usuario.TipoUsuario = 3 ✅                                        │
│                                                                          │
│    if (usuario.TipoUsuario != 3) {                                      │
│        return StatusCode(403, "Apenas administradores...");             │
│    }                                                                     │
│    // ✅ Passa na validação                                             │
└────────────┬────────────────────────────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ 6. DATABASE: UPDATE Chamados                                            │
│                                                                          │
│    var statusFechado = _context.Status                                  │
│        .FirstOrDefault(s => s.Nome == "Fechado");                       │
│    // statusFechado.Id = 4 ✅                                           │
│                                                                          │
│    chamado.StatusId = 4;                                                │
│    chamado.DataFechamento = DateTime.UtcNow;                            │
│    chamado.DataUltimaAtualizacao = DateTime.UtcNow;                     │
│                                                                          │
│    await _context.SaveChangesAsync(); ✅                                │
└────────────┬────────────────────────────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ 7. BACKEND: Retorna ChamadoDto atualizado                              │
│    HTTP 200 OK                                                           │
│    Body: {                                                               │
│      id: 42,                                                             │
│      titulo: "Problema no servidor",                                    │
│      status: { id: 4, nome: "Fechado" },                               │
│      dataFechamento: "2025-10-22T16:45:30Z"                            │
│    }                                                                     │
└────────────┬────────────────────────────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ 8. MOBILE: ApiService.PostAsync() recebe resposta                      │
│    Desserializa JSON → ChamadoDto                                       │
│    Retorna para ChamadoService.Close()                                  │
└────────────┬────────────────────────────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ 9. VIEWMODEL: CloseChamadoAsync() continua                             │
│                                                                          │
│    await Task.Delay(500); // Anti-cache                                 │
│    await LoadChamadoAsync(42); // Reload fresh data                     │
└────────────┬────────────────────────────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ 10. HTTP REQUEST (Reload)                                               │
│     GET https://10.0.2.2:5246/api/chamados/42                          │
│     Authorization: Bearer {token}                                       │
│                                                                          │
│     Response: ChamadoDto completo com:                                  │
│       - Status.Id = 4                                                    │
│       - Status.Nome = "Fechado"                                         │
│       - DataFechamento = "2025-10-22T16:45:30Z"                        │
└────────────┬────────────────────────────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ 11. VIEWMODEL: Chamado property setter                                  │
│                                                                          │
│     Chamado = chamadoAtualizado;                                        │
│                                                                          │
│     OnPropertyChanged(nameof(Chamado));                                 │
│     OnPropertyChanged(nameof(IsChamadoEncerrado));  // → true          │
│     OnPropertyChanged(nameof(HasFechamento));       // → true          │
│     OnPropertyChanged(nameof(ShowCloseButton));     // → false         │
└────────────┬────────────────────────────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ 12. UI (XAML): Bindings atualizam                                       │
│                                                                          │
│     Banner IsVisible={IsChamadoEncerrado}                               │
│       ✅ Aparece: "✓ Chamado Encerrado" (verde)                        │
│                                                                          │
│     Status Badge Text={Chamado.Status.Nome}                             │
│       ✅ Atualiza para: "Fechado"                                       │
│                                                                          │
│     DataFechamento IsVisible={HasFechamento}                            │
│       ✅ Mostra: "22/10/2025 16:45"                                     │
│                                                                          │
│     Button IsVisible={ShowCloseButton}                                  │
│       ✅ Oculta o botão "Encerrar"                                      │
└─────────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════
                        COMPONENTES CRÍTICOS
═══════════════════════════════════════════════════════════════════════════

┌────────────────────────────────────────────────────────────────────────┐
│ AUTENTICAÇÃO & AUTORIZAÇÃO                                             │
├────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  JWT Token Structure:                                                  │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │ Header:                                                           │ │
│  │   { "alg": "HS256", "typ": "JWT" }                               │ │
│  │                                                                    │ │
│  │ Payload (Claims):                                                 │ │
│  │   {                                                                │ │
│  │     "nameid": "1",                    // NameIdentifier          │ │
│  │     "email": "admin@teste.com",                                   │ │
│  │     "TipoUsuario": "3",               // ⭐ CRÍTICO!             │ │
│  │     "exp": 1729621530,                // Expiration               │ │
│  │     "iss": "SistemaChamados",         // Issuer                   │ │
│  │     "aud": "SistemaChamadosUsers"     // Audience                 │ │
│  │   }                                                                │ │
│  │                                                                    │ │
│  │ Signature:                                                         │ │
│  │   HMACSHA256(base64(header) + "." + base64(payload), secretKey) │ │
│  └──────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  Validação no Backend:                                                 │
│  • Assinatura válida? ✅                                               │
│  • Token expirado? ✅                                                  │
│  • Issuer correto? ✅                                                  │
│  • Audience correto? ✅                                                │
│  • TipoUsuario == 3? ✅ (validado no controller)                      │
│                                                                         │
└────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────┐
│ TRATAMENTO DE ERROS                                                    │
├────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ApiService.PostAsync() - ANTES vs DEPOIS:                            │
│                                                                         │
│  ❌ ANTES (Silencioso):                                                │
│     if (!response.IsSuccessStatusCode) {                               │
│         HandleError(response.StatusCode); // Apenas log                │
│         return default;                   // Retorna null             │
│     }                                                                   │
│     // ViewModel recebe null, não sabe o motivo                        │
│                                                                         │
│  ✅ DEPOIS (Informativo):                                              │
│     if (!response.IsSuccessStatusCode) {                               │
│         var error = await response.Content.ReadAsStringAsync();        │
│         var message = ExtractErrorMessage(error);                      │
│         throw new HttpRequestException($"{statusCode}: {message}");    │
│     }                                                                   │
│     // ViewModel captura exceção com mensagem clara                    │
│                                                                         │
│  ViewModel (ChamadoDetailViewModel):                                   │
│     try {                                                               │
│         await _chamadoService.Close(id);                               │
│     }                                                                   │
│     catch (HttpRequestException ex) {                                  │
│         await DisplayAlert("Erro", ex.Message, "OK");                  │
│         // Usuário vê: "Forbidden: Apenas administradores..."          │
│     }                                                                   │
│                                                                         │
└────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────┐
│ BINDING & UI UPDATE                                                    │
├────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Propriedades Calculadas (ChamadoDetailViewModel):                    │
│                                                                         │
│  public bool IsChamadoEncerrado =>                                     │
│      Chamado?.DataFechamento != null ||                                │
│      Chamado?.Status?.Id == 3 ||      // "Resolvido"                  │
│      Chamado?.Status?.Id == 4;         // "Fechado" ⭐                │
│                                                                         │
│  public bool HasFechamento =>                                          │
│      Chamado?.DataFechamento != null;                                  │
│                                                                         │
│  public bool ShowCloseButton =>                                        │
│      Chamado != null && !IsChamadoEncerrado;                           │
│                                                                         │
│  Quando Chamado muda:                                                  │
│  1. set { Chamado = value; }                                           │
│  2. OnPropertyChanged(nameof(Chamado));                                │
│  3. OnPropertyChanged(nameof(IsChamadoEncerrado));  // Recalcula      │
│  4. OnPropertyChanged(nameof(HasFechamento));       // Recalcula      │
│  5. OnPropertyChanged(nameof(ShowCloseButton));     // Recalcula      │
│  6. XAML bindings reavaliam expressões                                 │
│  7. UI atualiza elementos visíveis                                     │
│                                                                         │
└────────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════
                    STATUS FINAL DA INTEGRAÇÃO
═══════════════════════════════════════════════════════════════════════════

✅ Backend    ←─────→  ✅ Database
   (API)              (SistemaChamados)
     ↑                     ↑
     │                     │
     │  HTTP/REST          │  EF Core
     │  JWT Auth           │  SQL Queries
     │                     │
     ↓                     │
✅ Mobile     ←──────────────┘
   (MAUI)
   
Todos os componentes integrados e funcionando! 🎉
```
