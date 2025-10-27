# 🧪 Como Testar o Admin Dashboard

## ✅ **FASE 4.4 - Dashboard Admin Completo!**

---

## 📋 **O que foi implementado:**

### **1. admin-dashboard.html**
- ✅ Interface moderna com 6 KPIs (estatísticas)
- ✅ 3 gráficos interativos com Chart.js
- ✅ Tabela de chamados recentes
- ✅ Botões de ações rápidas
- ✅ Verificação de role Admin

### **2. admin-dashboard.js**
- ✅ Verificação de role Admin (redireciona se não for) ✅
- ✅ Estatísticas completas:
  - Total de chamados: `GET /api/Chamados` ✅
  - Chamados abertos ✅
  - Chamados em andamento ✅
  - Chamados pendentes ✅
  - Chamados resolvidos ✅
  - Chamados fechados ✅
- ✅ Gráficos com Chart.js:
  - Chamados por status (gráfico de rosca) ✅
  - Chamados por categoria (gráfico de barras) ✅
  - Chamados por prioridade (gráfico de pizza) ✅
- ✅ Link para gerenciar chamados → `admin-chamados.html` ✅
- ✅ Auto-refresh a cada 60 segundos
- ✅ Tabela com 10 chamados mais recentes

### **3. Estilos CSS**
- ✅ KPIs com bordas coloridas
- ✅ Gráficos responsivos
- ✅ Tabela interativa
- ✅ Grid adaptável para mobile

---

## 🔐 **Pré-requisitos:**

### **Você precisa de uma conta Admin!**

#### **Opção 1: Criar Admin via Swagger**
1. Acesse: http://localhost:5246/swagger
2. Vá em `POST /api/Usuarios/register`
3. Clique em "Try it out"
4. Use este JSON:
```json
{
  "nome": "Admin Sistema",
  "email": "admin@sistema.com",
  "senha": "Admin@123",
  "cpf": "12345678900",
  "telefone": "11987654321",
  "role": "Admin"
}
```
5. Execute
6. Verifique se retornou sucesso (201)

#### **Opção 2: Alterar role de usuário existente no banco**
Se você já tem um usuário, pode alterar a role direto no SQL Server:
```sql
UPDATE Usuarios 
SET Role = 'Admin' 
WHERE Email = 'seu@email.com';
```

---

## 🧪 **Passos para Testar:**

### **1️⃣ Backend rodando**
✅ Confirmado: `http://localhost:5246`

### **2️⃣ Fazer login como Admin**
1. Acesse: http://localhost:5246/pages/login.html
2. Email: `admin@sistema.com`
3. Senha: `Admin@123`
4. Clique em "Entrar"

### **3️⃣ Será redirecionado automaticamente para:**
**URL:** http://localhost:5246/pages/admin-dashboard.html

---

## 🎨 **O que você verá no Admin Dashboard:**

### **Header:**
```
Admin: Admin Sistema  👑 Administrador
[ Dashboard ] [ Gerenciar Chamados ] [ Ver como Usuário ] [ Configurações ] [ Sair ]
```

### **Estatísticas (6 KPIs):**
```
┌────────────┬───────────┬───────────┬───────────┬───────────┬───────────┐
│ 📊 Total   │ 🔓 Abertos│ ⚙️ Andamento│⏸️ Pendentes│ ✅ Resolvidos│🔒 Fechados│
│    25      │     8     │     10    │     3     │      3    │     1     │
└────────────┴───────────┴───────────┴───────────┴───────────┴───────────┘
```

### **Gráficos (3 Charts):**

#### **1. Chamados por Status (Doughnut Chart)**
- Mostra distribuição de chamados por status
- Cores diferentes para cada status
- Tooltip com quantidade e percentual
- Legenda abaixo do gráfico

#### **2. Chamados por Categoria (Bar Chart)**
- Gráfico de barras vertical
- Mostra quantidade de chamados por categoria
- Útil para identificar áreas com mais demanda

#### **3. Chamados por Prioridade (Pie Chart)**
- Gráfico de pizza
- Mostra distribuição por prioridade
- Ordenado: Crítica → Alta → Média → Baixa
- Tooltip com quantidade e percentual

### **Ações Rápidas:**
```
┌────────────────────────────────────────────────────────────┐
│ [📋 Gerenciar Todos os Chamados]                          │
│ [🔧 Visualizar Técnicos]  [👥 Visualizar Usuários]        │
│ [🔄 Atualizar Estatísticas]                                │
└────────────────────────────────────────────────────────────┘
```

### **Chamados Recentes (Tabela):**
```
┌────┬─────────────────┬──────────┬────────────┬───────────┬──────────┬────────────┐
│ #  │ Título          │ Status   │ Prioridade │ Categoria │ Técnico  │ Data       │
├────┼─────────────────┼──────────┼────────────┼───────────┼──────────┼────────────┤
│ 25 │ Erro no sistema │ Aberto   │ Alta       │ Software  │ Carlos   │ 27/10/2025 │
│ 24 │ Senha bloqueada │ Resolvido│ Média      │ Acesso    │ Ana      │ 26/10/2025 │
└────┴─────────────────┴──────────┴────────────┴───────────┴──────────┴────────────┘
```

---

## 🎯 **Funcionalidades para testar:**

### **✅ 1. Verificação de Role Admin**
- Tente acessar diretamente: http://localhost:5246/pages/admin-dashboard.html
- Se não for Admin, será redirecionado para dashboard normal
- Aparecerá alerta: "Acesso negado. Você não tem permissão..."

### **✅ 2. Estatísticas em Tempo Real**
- Todos os 6 KPIs devem mostrar números corretos
- Total = soma de todos os status
- Clique em "🔄 Atualizar Estatísticas" → números atualizam

### **✅ 3. Gráficos Interativos**
- **Hover** sobre fatias/barras → mostra tooltip com detalhes
- **Responsivo** → redimensione a janela, gráficos se adaptam
- **Animação** → gráficos animam ao carregar

### **✅ 4. Tabela de Chamados Recentes**
- Mostra os 10 chamados mais recentes
- Click em qualquer linha → redireciona para detalhes (FASE 4.7)
- Ordena por data de criação (mais novo primeiro)

### **✅ 5. Navegação**
- **"Gerenciar Todos os Chamados"** → redireciona para `admin-chamados.html` (FASE 4.5)
- **"Ver como Usuário"** → redireciona para dashboard normal
- **"Visualizar Técnicos"** → alerta (em desenvolvimento)
- **"Visualizar Usuários"** → alerta (em desenvolvimento)
- **"Sair"** → confirma e faz logout

### **✅ 6. Auto-refresh**
- A cada 60 segundos, estatísticas são recarregadas
- Acompanhe no console: "Auto-refresh: recarregando estatísticas admin..."

---

## 📊 **Endpoints da API usados:**

```http
# Buscar TODOS os chamados (Admin tem acesso total)
GET /api/Chamados
Authorization: Bearer {token}

Resposta (200 OK):
[
  {
    "id": 1,
    "titulo": "Problema X",
    "descricao": "...",
    "status": { "id": 1, "nome": "Aberto" },
    "prioridade": { "id": 2, "nome": "Média" },
    "categoria": { "id": 3, "nome": "Hardware" },
    "tecnicoResponsavel": { "id": 5, "nome": "Carlos" },
    "dataCriacao": "2025-10-27T10:00:00"
  },
  ...
]
```

**Nota:** Usuários normais veem apenas seus chamados (`/api/Chamados/meus-chamados`), mas Admin vê TODOS via `/api/Chamados`.

---

## 🐛 **Troubleshooting:**

### **❌ "Acesso negado. Você não tem permissão..."**
**Causa:** Usuário não tem role Admin

**Solução:**
1. Verifique a role no token JWT
2. Crie uma conta Admin (veja Pré-requisitos)
3. Ou altere role no banco de dados

### **❌ Gráficos não aparecem**
**Causa:** Chart.js não carregou do CDN

**Solução:**
1. Abra DevTools (F12) → Console
2. Veja se há erro de carregamento
3. Verifique conexão com internet (Chart.js via CDN)
4. Se offline, baixe Chart.js localmente

### **❌ "Erro ao carregar estatísticas"**
**Causa:** Erro na API

**Solução:**
1. Verifique se backend está rodando
2. Abra DevTools → Network → veja requisição `/api/Chamados`
3. Verifique se token JWT é válido (não expirou)

### **❌ Estatísticas aparecem como "0 0 0 0 0 0"**
**Causa:** Não há chamados no sistema

**Solução:**
- É esperado se não há chamados cadastrados
- Crie alguns chamados primeiro como usuário normal
- Ou importe dados de teste

---

## 🎨 **Cores dos Gráficos:**

### **Status:**
- 🟡 **Aberto:** `#fbbf24` (amarelo)
- 🔵 **Em Andamento:** `#60a5fa` (azul)
- 🟠 **Pendente:** `#fb923c` (laranja)
- 🟢 **Resolvido:** `#34d399` (verde)
- ⚪ **Fechado:** `#9ca3af` (cinza)

### **Prioridade:**
- 🔴 **Crítica:** `#ef4444` (vermelho)
- 🟠 **Alta:** `#fb923c` (laranja)
- 🟡 **Média:** `#fbbf24` (amarelo)
- 🟢 **Baixa:** `#34d399` (verde)

---

## 📱 **Responsividade:**

### **Desktop (> 768px):**
- KPIs em 3 colunas
- Gráficos em 3 colunas

### **Tablet (480px - 768px):**
- KPIs em 2 colunas
- Gráficos em 1 coluna

### **Mobile (< 480px):**
- KPIs em 1 coluna
- Gráficos em 1 coluna
- Tabela com scroll horizontal

---

## ✅ **Checklist de Validação:**

- [ ] Backend rodando em `http://localhost:5246`
- [ ] Login como Admin realizado
- [ ] Dashboard carrega sem erros
- [ ] Nome do admin aparece no header
- [ ] 6 KPIs exibem valores corretos
- [ ] Gráfico de Status aparece e funciona
- [ ] Gráfico de Categoria aparece e funciona
- [ ] Gráfico de Prioridade aparece e funciona
- [ ] Tooltip dos gráficos funciona (hover)
- [ ] Tabela mostra chamados recentes
- [ ] Click na tabela redireciona (mesmo que página não exista)
- [ ] Botão "Gerenciar Chamados" redireciona
- [ ] Botão "Atualizar" recarrega estatísticas
- [ ] Auto-refresh funciona a cada 60s
- [ ] Logout funciona
- [ ] Responsivo em mobile

---

## 🎯 **Diferenças: Dashboard Admin vs Dashboard Usuário:**

| Aspecto | Dashboard Usuário | Dashboard Admin |
|---------|------------------|-----------------|
| **Endpoint** | `/api/Chamados/meus-chamados` | `/api/Chamados` |
| **Acesso** | Apenas seus chamados | TODOS os chamados |
| **KPIs** | 4 (Total, Abertos, Andamento, Resolvidos) | 6 (+ Pendentes, Fechados) |
| **Gráficos** | Não tem | 3 gráficos (Status, Categoria, Prioridade) |
| **Ações** | Novo Chamado | Gerenciar Todos, Ver Técnicos, Usuários |
| **Visualização** | Cards (grid) | Tabela (10 mais recentes) |
| **Auto-refresh** | 30 segundos | 60 segundos |

---

## 🚀 **Próximas Fases:**

Agora que o Admin Dashboard está funcionando, podemos implementar:

- **FASE 4.5** - Gerenciar Chamados Admin (listar todos + atribuir técnicos + usar IA)
- **FASE 4.6** - Novo Chamado (formulário de criação)
- **FASE 4.7** - Detalhes do Chamado (visualizar e atualizar)
- **FASE 4.8** - Configurações (editar perfil, alterar senha)

---

**Data:** 27 de outubro de 2025  
**Status:** ✅ FASE 4.4 CONCLUÍDA
