# 📋 Plano de Ação: Integração Frontend HTML com API ASP.NET Core

## **🎯 Objetivo**
Integrar os arquivos HTML/CSS/JS do `pim4-main` com a API backend em `http://localhost:5246`, criando um frontend web funcional conectado ao sistema de IA + Handoff.

---

## **📊 FASE 1: Preparação e Estrutura** (Estimativa: 30min)

### **1.1 Mover Frontend para o Projeto**
```
✓ Criar pasta Frontend/ no workspace
✓ Copiar arquivos do pim4-main para estrutura organizada
✓ Decidir qual versão usar como base (Web ou Desktop)
  → Recomendação: Web (mais completa)
```

**Estrutura proposta:**
```
sistema-chamados-faculdade/
├── Backend/ (existente - API)
├── SistemaChamados.Mobile/ (existente - MAUI)
└── Frontend/ (NOVO)
    ├── assets/
    │   ├── css/
    │   │   └── style.css
    │   ├── js/
    │   │   ├── api.js (NOVO - client API)
    │   │   ├── auth.js (NOVO - autenticação)
    │   │   └── app.js (lógica principal)
    │   └── images/
    ├── pages/
    │   ├── login.html
    │   ├── cadastro.html
    │   ├── dashboard.html
    │   ├── admin-dashboard.html
    │   ├── novo-ticket.html
    │   ├── ticket-detalhes.html
    │   └── config.html
    └── index.html
```

---

## **📊 FASE 2: Configuração da API** (Estimativa: 15min)

### **2.1 Habilitar CORS no Backend**
```csharp
// program.cs - Adicionar após builder.Services...
builder.Services.AddCors(options =>
{
    options.AddPolicy("FrontendLocal", policy =>
    {
        policy.WithOrigins("http://localhost:3000", "http://127.0.0.1:5500", "http://localhost:5500")
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials();
    });
});

// Antes de app.Run()
app.UseCors("FrontendLocal");
```

### **2.2 Configurar Servir Arquivos Estáticos (Opcional)**
```csharp
// Para servir frontend pelo próprio backend
app.UseStaticFiles();
app.UseDefaultFiles();
```

---

## **📊 FASE 3: Criar Camada de API Client** (Estimativa: 45min)

### **3.1 Criar `api.js` - Cliente HTTP**
**Funcionalidades:**
- ✓ Configuração base da API (`http://localhost:5246`)
- ✓ Interceptor para adicionar JWT automaticamente
- ✓ Tratamento de erros HTTP
- ✓ Métodos genéricos (GET, POST, PUT, DELETE)

**Estrutura:**
```javascript
class ApiClient {
    constructor() {
        this.baseURL = 'http://localhost:5246/api';
        this.token = localStorage.getItem('token');
    }
    
    async request(endpoint, options = {}) {
        // Headers padrão + JWT
        // Tratamento de erros
        // Parse JSON
    }
    
    get(endpoint) { ... }
    post(endpoint, data) { ... }
    put(endpoint, data) { ... }
    delete(endpoint) { ... }
}
```

### **3.2 Criar `auth.js` - Gerenciamento de Autenticação**
**Funcionalidades:**
- ✓ Login: `POST /api/Usuarios/login`
- ✓ Cadastro: `POST /api/Usuarios/register`
- ✓ Armazenar token JWT no localStorage
- ✓ Decodificar JWT para pegar role (Admin/Tecnico/Usuario)
- ✓ Logout (limpar localStorage)
- ✓ Verificar se está autenticado
- ✓ Redirecionamento automático

**Métodos:**
```javascript
class AuthService {
    async login(email, senha)
    async register(userData)
    logout()
    isAuthenticated()
    getUserRole()
    getUserInfo()
}
```

---

## **📊 FASE 4: Integração de Páginas** (Estimativa: 2-3h)

### **4.1 Login (`login.html` + `login.js`)**
**Tarefas:**
- ✓ Capturar formulário (email, senha)
- ✓ Chamar `POST /api/Usuarios/login`
- ✓ Armazenar token recebido
- ✓ Redirecionar baseado em role:
  - Admin → `admin-dashboard.html`
  - Tecnico → `dashboard.html`
  - Usuario → `dashboard.html`
- ✓ Exibir erros de autenticação

### **4.2 Cadastro (`cadastro.html` + `cadastro.js`)**
**Tarefas:**
- ✓ Formulário completo (nome, email, senha, CPF, telefone)
- ✓ Validação client-side
- ✓ Chamar `POST /api/Usuarios/register`
- ✓ Redirecionar para login após sucesso

### **4.3 Dashboard Usuário (`dashboard.html` + `dashboard.js`)**
**Tarefas:**
- ✓ Verificar autenticação (redirecionar se não logado)
- ✓ Exibir nome do usuário (do token)
- ✓ Listar chamados do usuário: `GET /api/Chamados/meus-chamados`
- ✓ Cards com: Título, Status, Prioridade, Técnico, Data
- ✓ Botão "Novo Chamado" → `novo-ticket.html`
- ✓ Click no chamado → `ticket-detalhes.html?id={id}`

### **4.4 Dashboard Admin (`admin-dashboard.html` + `admin-dashboard.js`)**
**Tarefas:**
- ✓ Verificar role Admin (redirecionar se não for)
- ✓ Estatísticas:
  - Total de chamados: `GET /api/Chamados`
  - Chamados abertos: `GET /api/Chamados?status=Aberto`
  - Chamados em andamento
  - Chamados fechados
- ✓ Gráficos (Chart.js):
  - Chamados por status
  - Chamados por categoria
  - Chamados por prioridade
- ✓ Link para gerenciar chamados → `admin-tickets.html`

### **4.5 Gerenciar Chamados Admin (`admin-tickets.html` + `admin-tickets.js`)**
**Tarefas:**
- ✓ Listar TODOS os chamados: `GET /api/Chamados`
- ✓ Filtros: Status, Categoria, Prioridade, Técnico
- ✓ Busca por título/descrição
- ✓ Atribuir/Reatribuir técnico manualmente
- ✓ Usar IA para analisar: `POST /api/chamados/analisar-com-handoff`
- ✓ Visualizar scores do Handoff: `GET /api/Chamados/tecnicos/scores`

### **4.6 Novo Chamado (`novo-ticket.html` + `novo-ticket.js`)**
**Tarefas:**
- ✓ Carregar categorias: `GET /api/Categorias`
- ✓ Carregar prioridades: `GET /api/Prioridades`
- ✓ Formulário: Título, Descrição, Categoria, Prioridade
- ✓ Preview da análise IA (opcional):
  - Chamar `POST /api/chamados/analisar-com-handoff`
  - Mostrar técnico sugerido, scores, justificativa
- ✓ Criar chamado: `POST /api/Chamados`
- ✓ Redirecionar para detalhes do chamado criado

### **4.7 Detalhes do Chamado (`ticket-detalhes.html` + `ticket-detalhes.js`)**
**Tarefas:**
- ✓ Pegar ID da URL (query string)
- ✓ Carregar dados: `GET /api/Chamados/{id}`
- ✓ Exibir:
  - Título, Descrição, Status, Prioridade, Categoria
  - Técnico atribuído (nome, foto)
  - Data de criação, última atualização
  - Histórico de atualizações
  - Scores do Handoff (se admin)
  - Justificativa da IA (se disponível)
- ✓ Ações (baseado em role):
  - **Usuário**: fechar chamado
  - **Técnico**: Atualizar status, adicionar nota técnica
  - **Admin**: Reatribuir, alterar prioridade, fechar

### **4.8 Configurações (`config.html` + `config.js`)**
**Tarefas:**
- ✓ Exibir dados do usuário
- ✓ Editar perfil: `PUT /api/Usuarios/{id}`
- ✓ Alterar senha
- ✓ Configurações de notificações (frontend only)

---

## **📊 FASE 5: Features Avançadas** (Estimativa: 2h)

### **5.1 Sistema de Notificações**
- ✓ Polling a cada 30s: `GET /api/Chamados/notificacoes`
- ✓ Badge de novas notificações
- ✓ Dropdown com lista

### **5.2 Visualização de Scores do Handoff**
**Para Admin/Técnico:**
- ✓ Modal mostrando breakdown de scores:
  - Especialidade: X pts
  - Disponibilidade: Y pts
  - Performance: Z pts
  - Prioridade: W pts
  - Bonus Complexidade: ±N pts
- ✓ Gráfico de barras comparando técnicos

### **5.3 Histórico de Análises IA**
- ✓ Exibir decisões anteriores da IA
- ✓ Taxa de concordância com Handoff
- ✓ Justificativas da IA

### **5.4 Filtros e Busca Avançada**
- ✓ Busca em tempo real
- ✓ Múltiplos filtros combinados
- ✓ Salvar filtros favoritos

---

## **📊 FASE 6: Melhorias de UX/UI** (Estimativa: 1-2h)

### **6.1 Loading States**
- ✓ Spinners durante requisições
- ✓ Skeleton screens para listagens
- ✓ Desabilitar botões durante submissão

### **6.2 Feedback Visual**
- ✓ Toast notifications (sucesso/erro)
- ✓ Confirmações para ações críticas
- ✓ Badges coloridos (status, prioridade)

### **6.3 Responsividade**
- ✓ Testar em mobile, tablet, desktop
- ✓ Menu hambúrguer para mobile
- ✓ Cards adaptáveis

### **6.4 Acessibilidade**
- ✓ Labels em formulários
- ✓ ARIA attributes
- ✓ Contraste de cores (WCAG)

---

## **📊 FASE 7: Testes e Validação** (Estimativa: 1h)

### **7.1 Testes Funcionais**
- ✓ Fluxo completo: Login → Criar Chamado → Ver Detalhes → Logout
- ✓ Fluxo Admin: Login → Ver Dashboard → Gerenciar Chamados → Analisar IA
- ✓ Fluxo Técnico: Login → Ver Chamados Atribuídos → Atualizar Status

### **7.2 Testes de Integração API**
- ✓ Todos os endpoints retornando corretamente
- ✓ Autenticação JWT funcionando
- ✓ CORS configurado corretamente
- ✓ Erros tratados adequadamente

### **7.3 Testes de Performance**
- ✓ Tempo de carregamento < 2s
- ✓ Otimizar imagens
- ✓ Minificar CSS/JS (produção)

---

## **📊 FASE 8: Deploy e Documentação** (Estimativa: 30min)

### **8.1 Preparar para Produção**
- ✓ Variáveis de ambiente (API URL)
- ✓ Build otimizado
- ✓ HTTPS (certificado SSL)

### **8.2 Documentação**
- ✓ README do Frontend
- ✓ Como rodar localmente
- ✓ Estrutura de pastas
- ✓ Endpoints utilizados

---

## **🛠️ Ferramentas e Bibliotecas Necessárias**

### **Essenciais:**
- ✅ **Nenhuma dependência NPM necessária** (vanilla JS)
- ✅ Live Server (VS Code extension) para desenvolvimento
- ✅ Browser DevTools para debug

### **Opcionais (melhorias):**
- 📊 **Chart.js** - Gráficos no dashboard admin
- 🎨 **Bootstrap 5** ou **Tailwind CSS** - UI moderna
- 🔔 **Toastify** - Notificações toast elegantes
- 📅 **Flatpickr** - Date picker para filtros
- ✨ **AOS (Animate On Scroll)** - Animações suaves

---

## **⏱️ Estimativa Total de Tempo**

| Fase | Tempo Estimado |
|------|---------------|
| FASE 1: Preparação | 30min |
| FASE 2: Configuração API | 15min |
| FASE 3: API Client | 45min |
| FASE 4: Integração Páginas | 2-3h |
| FASE 5: Features Avançadas | 2h |
| FASE 6: UX/UI | 1-2h |
| FASE 7: Testes | 1h |
| FASE 8: Deploy/Docs | 30min |
| **TOTAL** | **8-10 horas** |

---

## **🚀 Próximos Passos Imediatos**

**Posso começar agora com:**

1. ✅ Criar estrutura de pastas `Frontend/` no workspace
2. ✅ Configurar CORS no backend
3. ✅ Criar `api.js` (cliente HTTP)
4. ✅ Criar `auth.js` (autenticação)
5. ✅ Integrar página de login (primeira funcionalidade)

---

## **❓ Decisões Necessárias**

Antes de começar, preciso saber:

1. **Qual versão usar como base?**
   - `Web/` (recomendado - mais completo)
   - `Desktop/` (similar)
   - Começar do zero aproveitando só o CSS?

2. **Usar bibliotecas externas?**
   - Vanilla JS puro (mais leve, mais trabalho)
   - Bootstrap/Tailwind (UI pronta, mais rápido)
   - Chart.js para gráficos?

3. **Servir frontend como?**
   - Arquivos estáticos servidos pelo backend ASP.NET
   - Live Server separado durante desenvolvimento
   - Nginx/Apache em produção

---

## **📱 Impacto no App Mobile**

### **✅ NÃO INTERFERE** - Os sistemas são independentes

**Por quê?**

1. **Backend compartilhado**: Ambos (Web + Mobile) consomem a mesma API
2. **CORS não afeta Mobile**: CORS é uma restrição de navegador, não afeta apps nativos
3. **Endpoints iguais**: Mobile MAUI já usa a API, Web usará os mesmos endpoints
4. **Autenticação JWT**: Mesmo sistema de token para ambos

### **Benefícios da Integração:**

- ✅ **Mesma lógica de negócio**: IA + Handoff funciona igual em Web e Mobile
- ✅ **Dados sincronizados**: Chamados criados no Web aparecem no Mobile e vice-versa
- ✅ **Manutenção facilitada**: Uma API para duas interfaces
- ✅ **Experiência unificada**: Usuário pode alternar entre plataformas

### **Único cuidado:**

- 🔧 **CORS configurado corretamente**: Não atrapalha Mobile, mas precisa estar configurado para Web
- 🔧 **Endpoints retrocompatíveis**: Se modificar API, testar em ambos os clientes

---

## **🎯 Arquitetura Final**

```
┌─────────────────────────────────────┐
│         BACKEND (ASP.NET)           │
│    http://localhost:5246/api        │
│                                     │
│  - Autenticação JWT                 │
│  - Sistema IA + Handoff             │
│  - CRUD Chamados                    │
│  - Gerenciamento Usuários           │
└─────────────┬───────────────────────┘
              │
        ┌─────┴──────┐
        │            │
┌───────▼──────┐ ┌──▼─────────────┐
│   FRONTEND   │ │  MOBILE MAUI   │
│   (Web/HTML) │ │  (.NET MAUI)   │
│              │ │                │
│ - Dashboard  │ │ - Dashboard    │
│ - Chamados   │ │ - Chamados     │
│ - Admin      │ │ - Perfil       │
└──────────────┘ └────────────────┘
```

**Resultado**: 3 clientes (Web, Desktop HTML, Mobile MAUI) usando 1 API! 🚀

---

**Data de criação**: 27 de outubro de 2025
**Última atualização**: 27 de outubro de 2025
