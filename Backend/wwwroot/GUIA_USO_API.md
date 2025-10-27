# 📘 Guia de Uso - API Client & Auth Service

## 🔌 API Client (`api.js`)

O `api.js` fornece um cliente HTTP completo para comunicação com a API.

### **Importar no HTML:**

```html
<script src="../assets/js/api.js"></script>
```

### **Métodos Disponíveis:**

#### **GET - Buscar Dados**
```javascript
// Simples
const categorias = await api.get('/Categorias');

// Com query params
const chamados = await api.get('/Chamados', { 
    status: 'Aberto', 
    prioridade: 'Alta' 
});
```

#### **POST - Criar Recurso**
```javascript
const novoChamado = await api.post('/Chamados', {
    titulo: 'Problema no sistema',
    descricao: 'Descrição detalhada',
    categoriaId: 1,
    prioridadeId: 2
});
```

#### **PUT - Atualizar Recurso**
```javascript
const atualizado = await api.put('/Chamados/123', {
    statusId: 2,
    observacao: 'Em andamento'
});
```

#### **DELETE - Deletar Recurso**
```javascript
await api.delete('/Chamados/123');
```

### **Tratamento de Erros:**

```javascript
try {
    const dados = await api.get('/Chamados');
    console.log(dados);
} catch (error) {
    if (error instanceof ApiError) {
        console.error('Erro na API:', error.message);
        console.error('Status:', error.status);
        console.error('Detalhes:', error.data);
    } else {
        console.error('Erro de conexão:', error);
    }
}
```

---

## 🔐 Auth Service (`auth.js`)

O `auth.js` gerencia toda autenticação e autorização.

### **Importar no HTML:**

```html
<script src="../assets/js/api.js"></script>
<script src="../assets/js/auth.js"></script>
```

### **Login:**

```javascript
try {
    const result = await auth.login('admin@sistema.com', 'Admin@123');
    
    if (result.success) {
        console.log('Usuário:', result.user);
        console.log('Token:', result.token);
        
        // Redireciona para dashboard apropriado
        auth.redirectToDashboard();
    }
} catch (error) {
    console.error('Erro no login:', error.message);
    alert('Email ou senha incorretos!');
}
```

### **Cadastro:**

```javascript
try {
    const result = await auth.register({
        nome: 'João Silva',
        email: 'joao@email.com',
        senha: 'Senha@123',
        cpf: '123.456.789-00',
        telefone: '(11) 98765-4321'
    });
    
    if (result.success) {
        alert('Cadastro realizado com sucesso!');
        window.location.href = 'login.html';
    }
} catch (error) {
    console.error('Erro no cadastro:', error);
    alert('Erro ao cadastrar: ' + error.message);
}
```

### **Logout:**

```javascript
// Simples - limpa tudo e redireciona
auth.logout();
```

### **Verificar Autenticação:**

```javascript
// Verificar se está logado
if (auth.isAuthenticated()) {
    console.log('Usuário autenticado!');
} else {
    window.location.href = 'login.html';
}
```

### **Proteger Página:**

```javascript
// No início de cada página protegida
auth.requireAuth(); // Redireciona se não logado

// Proteger com role específica
auth.requireAuth('Admin'); // Apenas Admin pode acessar
```

### **Obter Informações do Usuário:**

```javascript
// Todas as informações
const user = auth.getUserInfo();
console.log(user.nome, user.email, user.role);

// Apenas role
const role = auth.getUserRole();
console.log('Role:', role);

// Verificar roles específicas
if (auth.isAdmin()) {
    console.log('Usuário é Admin!');
}

if (auth.isTecnico()) {
    console.log('Usuário é Técnico!');
}

if (auth.isUsuario()) {
    console.log('Usuário comum!');
}
```

### **Alterar Senha:**

```javascript
try {
    await auth.changePassword('senhaAtual123', 'novaSenha@456');
    alert('Senha alterada com sucesso!');
} catch (error) {
    alert('Erro: ' + error.message);
}
```

### **Atualizar Perfil:**

```javascript
try {
    await auth.updateProfile({
        nome: 'João Silva Santos',
        telefone: '(11) 91234-5678'
    });
    alert('Perfil atualizado!');
} catch (error) {
    alert('Erro: ' + error.message);
}
```

---

## 📝 Exemplo Completo - Página de Login

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Login - Sistema de Chamados</title>
</head>
<body>
    <form id="loginForm">
        <input type="email" id="email" placeholder="Email" required>
        <input type="password" id="senha" placeholder="Senha" required>
        <button type="submit">Entrar</button>
    </form>

    <script src="../assets/js/api.js"></script>
    <script src="../assets/js/auth.js"></script>
    <script>
        document.getElementById('loginForm').addEventListener('submit', async (e) => {
            e.preventDefault();

            const email = document.getElementById('email').value;
            const senha = document.getElementById('senha').value;

            try {
                const result = await auth.login(email, senha);
                
                if (result.success) {
                    // Sucesso! Redireciona automaticamente
                    auth.redirectToDashboard();
                }
            } catch (error) {
                alert('Erro ao fazer login: ' + error.message);
            }
        });
    </script>
</body>
</html>
```

---

## 📝 Exemplo Completo - Página Dashboard

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Dashboard - Sistema de Chamados</title>
</head>
<body>
    <div id="userInfo"></div>
    <div id="chamados"></div>
    <button onclick="auth.logout()">Sair</button>

    <script src="../assets/js/api.js"></script>
    <script src="../assets/js/auth.js"></script>
    <script>
        // Protege a página
        auth.requireAuth();

        // Exibe info do usuário
        const user = auth.getUserInfo();
        document.getElementById('userInfo').innerHTML = `
            <h1>Bem-vindo, ${user.nome}!</h1>
            <p>Email: ${user.email}</p>
            <p>Role: ${user.role}</p>
        `;

        // Carrega chamados
        async function carregarChamados() {
            try {
                const chamados = await api.get('/Chamados/meus-chamados');
                
                const html = chamados.map(c => `
                    <div class="chamado">
                        <h3>${c.titulo}</h3>
                        <p>${c.descricao}</p>
                        <span>Status: ${c.status?.nome}</span>
                    </div>
                `).join('');

                document.getElementById('chamados').innerHTML = html;
            } catch (error) {
                console.error('Erro ao carregar chamados:', error);
            }
        }

        carregarChamados();
    </script>
</body>
</html>
```

---

## 🔄 Fluxo de Autenticação

```
1. Usuário acessa página protegida
   ↓
2. auth.requireAuth() verifica token
   ↓
3. Se não autenticado → redireciona para login
   ↓
4. Usuário faz login
   ↓
5. Token JWT armazenado no localStorage
   ↓
6. Todas as requisições incluem: Authorization: Bearer {token}
   ↓
7. Se token expirar (401) → logout automático
```

---

## 🛡️ Segurança

- ✅ **Token JWT** armazenado no localStorage
- ✅ **Expiração** verificada automaticamente
- ✅ **Logout automático** em caso de token inválido
- ✅ **CORS** configurado no backend
- ✅ **Headers** Authorization automáticos

---

## 🐛 Troubleshooting

### **Erro: Token não recebido**
- Verifique credenciais
- Confirme endpoint: `/api/Usuarios/login`
- Veja resposta no Network (DevTools)

### **Erro 401 Unauthorized**
- Token expirou → faça login novamente
- Token inválido → limpe localStorage
- Backend não está validando JWT

### **Erro de CORS**
- Backend não está rodando
- CORS não configurado em `program.cs`
- Origem não está na whitelist

---

**Documentação criada em:** 27 de outubro de 2025
