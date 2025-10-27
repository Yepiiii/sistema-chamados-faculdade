# 🧪 Como Testar o Dashboard Usuário

## ✅ **FASE 4.3 - Dashboard Usuário Completo!**

---

## 📋 **O que foi implementado:**

### **1. dashboard.html**
- ✅ Interface moderna com cards de estatísticas
- ✅ Filtros (Status, Prioridade, Busca)
- ✅ Grid responsivo de chamados
- ✅ Loading e empty states
- ✅ Navegação com informações do usuário

### **2. dashboard.js**
- ✅ Verificação de autenticação (redireciona se não logado)
- ✅ Exibição do nome do usuário (extraído do token JWT)
- ✅ Listagem de chamados via `GET /api/Chamados/meus-chamados`
- ✅ Cards com: Título, Status, Prioridade, Técnico, Data
- ✅ Botão "Novo Chamado" → `novo-chamado.html`
- ✅ Click no chamado → `chamado-detalhes.html?id={id}`
- ✅ Filtros dinâmicos (status, prioridade, busca)
- ✅ Estatísticas em tempo real
- ✅ Auto-refresh a cada 30 segundos
- ✅ Formatação de datas relativas (há 2h, ontem, há 3 dias)

### **3. Estilos CSS**
- ✅ Cards de estatísticas com ícones coloridos
- ✅ Grid de chamados responsivo
- ✅ Badges coloridos para status e prioridade
- ✅ Hover effects nos cards
- ✅ Loading spinner
- ✅ Empty state

---

## 🧪 **Passos para Testar:**

### **1️⃣ Certifique-se que o backend está rodando**
```bash
# Deve estar em: http://localhost:5246
# Ver no terminal: "Now listening on: http://localhost:5246"
```

### **2️⃣ Crie um usuário (se ainda não tiver)**
Acesse: http://localhost:5246/pages/cadastro.html

- Nome: `João Silva`
- Email: `joao@teste.com`
- Senha: `Teste@123`

### **3️⃣ Faça login**
Acesse: http://localhost:5246/pages/login.html

- Email: `joao@teste.com`
- Senha: `Teste@123`

### **4️⃣ Será redirecionado para o Dashboard**
URL: http://localhost:5246/pages/dashboard.html

**O que você verá:**

#### **Header:**
- ✅ "Olá, **João Silva**"
- ✅ Badge com role (👤 Usuário)
- ✅ Menu: Início | Novo Chamado | Configurações | Sair

#### **Estatísticas:**
- 📋 **Total** - Total de chamados
- 🔓 **Abertos** - Chamados com status "Aberto"
- ⚙️ **Em Andamento** - Chamados sendo resolvidos
- ✅ **Resolvidos** - Chamados finalizados

#### **Filtros:**
- Status (dropdown)
- Prioridade (dropdown)
- Busca por texto
- Botões: "Limpar Filtros" e "+ Novo Chamado"

#### **Grid de Chamados:**
Se ainda não há chamados, você verá:
```
📭
Nenhum chamado encontrado
Você ainda não possui chamados abertos.
[Criar Primeiro Chamado]
```

---

## 🎯 **Funcionalidades para testar:**

### **✅ 1. Visualização de Chamados**
- Cada card mostra:
  - 📝 Título do chamado
  - 🏷️ Badge de status (colorido)
  - 📄 Descrição (truncada em 120 caracteres)
  - 🎯 Badge de prioridade com ícone
  - 📁 Categoria
  - 🔧 Técnico responsável (ou "Aguardando atribuição")
  - 📅 Data formatada (há 2h, ontem, 27/10/2025)

### **✅ 2. Filtros Dinâmicos**
- Selecione um **Status** → lista atualiza automaticamente
- Selecione uma **Prioridade** → lista atualiza
- Digite no **Buscar** → filtra por título ou descrição
- Clique **Limpar Filtros** → remove todos os filtros

### **✅ 3. Navegação**
- Clique em **Novo Chamado** → redireciona para `novo-chamado.html` (FASE 4.6)
- Clique em um **Card de Chamado** → redireciona para `chamado-detalhes.html?id=X` (FASE 4.7)
- Clique em **Sair** → confirma e faz logout

### **✅ 4. Auto-refresh**
- Deixe a página aberta
- A cada 30 segundos, a lista é recarregada automaticamente
- Acompanhe no console: "Auto-refresh: recarregando chamados..."

---

## 🎨 **Visual esperado:**

### **Cards de Estatísticas:**
```
┌──────────────┬──────────────┬──────────────┬──────────────┐
│  📋 Total    │  🔓 Abertos  │  ⚙️ Andamento │  ✅ Resolvidos│
│     15       │      5       │      8       │       2      │
└──────────────┴──────────────┴──────────────┴──────────────┘
```

### **Card de Chamado:**
```
┌────────────────────────────────────────────────┐
│ Problema no Login            🟡 Em Andamento   │
│                                                │
│ Não consigo acessar minha conta usando        │
│ meu email e senha...                           │
│                                                │
│ 🔴 Alta   📁 Acesso e Autenticação            │
│ ──────────────────────────────────────────── │
│ 🔧 Carlos Mendes          📅 há 2 horas       │
└────────────────────────────────────────────────┘
```

---

## 🐛 **Troubleshooting:**

### **❌ "Erro ao carregar chamados"**
**Solução:**
1. Verifique se backend está rodando
2. Abra DevTools (F12) → Console
3. Veja se há erro CORS ou 401
4. Verifique se fez login corretamente

### **❌ "Sessão expirada. Faça login novamente"**
**Solução:**
- Token JWT expirou
- Faça login novamente
- Token dura 24h por padrão

### **❌ Página em branco**
**Solução:**
1. Abra DevTools (F12) → Console
2. Veja erros JavaScript
3. Verifique se `api.js` e `auth.js` foram carregados
4. Certifique-se que rodou `.\CopiarFrontend.ps1`

### **❌ "Failed to fetch"**
**Solução:**
- Backend não está rodando
- Rode: `cd Backend; dotnet run`

---

## 📊 **Endpoints da API usados:**

```http
# Listar chamados do usuário autenticado
GET /api/Chamados/meus-chamados
Authorization: Bearer {token}

Resposta (200 OK):
[
  {
    "id": 1,
    "titulo": "Problema no Login",
    "descricao": "Não consigo acessar...",
    "status": { "id": 2, "nome": "Em Andamento" },
    "prioridade": { "id": 3, "nome": "Alta" },
    "categoria": { "id": 1, "nome": "Acesso" },
    "tecnicoResponsavel": {
      "id": 5,
      "nome": "Carlos Mendes"
    },
    "dataCriacao": "2025-10-27T10:30:00"
  }
]
```

---

## ✅ **Checklist de Validação:**

- [ ] Backend rodando em `http://localhost:5246`
- [ ] Login realizado com sucesso
- [ ] Dashboard carrega sem erros
- [ ] Nome do usuário aparece no header
- [ ] Estatísticas exibem valores corretos
- [ ] Chamados aparecem em cards
- [ ] Filtros funcionam (Status, Prioridade, Busca)
- [ ] Click no card redireciona (mesmo que página não exista)
- [ ] Botão "Novo Chamado" redireciona
- [ ] Botão "Sair" faz logout
- [ ] Auto-refresh funciona a cada 30s

---

## 🎯 **Próximas Fases:**

Agora que o dashboard está funcionando, podemos implementar:

- **FASE 4.4** - Dashboard Admin (estatísticas gerais, gráficos)
- **FASE 4.5** - Gerenciar Chamados Admin (listar todos, atribuir técnicos)
- **FASE 4.6** - Novo Chamado (formulário de criação)
- **FASE 4.7** - Detalhes do Chamado (visualizar e atualizar)
- **FASE 4.8** - Configurações (editar perfil, alterar senha)

---

**Data:** 27 de outubro de 2025  
**Status:** ✅ FASE 4.3 CONCLUÍDA
