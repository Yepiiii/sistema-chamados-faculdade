# 📁 Frontend - Sistema de Chamados

Frontend web integrado com a API ASP.NET Core do sistema de chamados.

## 🚀 Como Rodar

### **Opção 1: Servido pelo Backend (Recomendado)**

1. **Copiar frontend para wwwroot:**
   ```powershell
   .\CopiarFrontend.ps1
   ```

2. **Iniciar API:**
   ```powershell
   cd Backend
   dotnet run
   ```

3. **Acessar:**
   - Frontend: `http://localhost:5246/`
   - API Swagger: `http://localhost:5246/swagger`

---

### **Opção 2: Live Server (Desenvolvimento)**

1. **Instalar Live Server** (VS Code extension)

2. **Abrir `Frontend/index.html`** e clicar com botão direito → "Open with Live Server"

3. **Iniciar API separadamente:**
   ```powershell
   cd Backend
   dotnet run
   ```

4. **Acessar:**
   - Frontend: `http://127.0.0.1:5500/` (Live Server)
   - API: `http://localhost:5246/api`

---

## 📂 Estrutura

```
Frontend/
├── index.html              # Página inicial
├── assets/
│   ├── css/
│   │   └── style.css       # Estilos principais
│   ├── js/
│   │   ├── api.js          # Cliente HTTP para API
│   │   ├── auth.js         # Gerenciamento de autenticação
│   │   └── app.js          # Lógica principal (código original)
│   └── images/             # Imagens do sistema
└── pages/
    ├── login.html          # Página de login
    ├── cadastro.html       # Registro de usuários
    ├── dashboard.html      # Dashboard do usuário
    ├── admin-dashboard.html # Dashboard administrativo
    ├── admin-tickets.html  # Gerenciar todos os chamados (admin)
    ├── novo-ticket.html    # Criar novo chamado
    ├── ticket-detalhes.html # Detalhes do chamado
    └── config.html         # Configurações do usuário
```

---

## 🔌 Endpoints Utilizados

### **Autenticação**
- `POST /api/Usuarios/login` - Login
- `POST /api/Usuarios/register` - Cadastro

### **Chamados**
- `GET /api/Chamados` - Listar todos (admin)
- `GET /api/Chamados/meus-chamados` - Listar do usuário
- `GET /api/Chamados/{id}` - Detalhes do chamado
- `POST /api/Chamados` - Criar chamado
- `PUT /api/Chamados/{id}` - Atualizar chamado
- `POST /api/chamados/analisar-com-handoff` - Análise IA + Handoff
- `GET /api/Chamados/tecnicos/scores` - Scores do Handoff

### **Categorias e Prioridades**
- `GET /api/Categorias` - Listar categorias
- `GET /api/Prioridades` - Listar prioridades

### **Status**
- `GET /api/Status` - Listar status disponíveis

---

## 🔧 Configuração CORS

O backend está configurado para aceitar requisições de:
- `http://localhost:3000`
- `http://127.0.0.1:5500`
- `http://localhost:5500`
- `http://localhost:5173` (Vite)

Se precisar adicionar outra origem, edite `Backend/program.cs`:

```csharp
options.AddPolicy("FrontendLocal", policy =>
{
    policy.WithOrigins(
            "http://localhost:3000", 
            "http://127.0.0.1:5500",
            "SEU_NOVO_ENDERECO_AQUI"
          )
          .AllowAnyMethod()
          .AllowAnyHeader()
          .AllowCredentials();
});
```

---

## 🔑 Autenticação

O sistema usa **JWT (JSON Web Tokens)**:

1. **Login** retorna um token
2. Token é armazenado no `localStorage`
3. Todas as requisições incluem o header: `Authorization: Bearer {token}`
4. Token é decodificado para obter `role` (Admin/Tecnico/Usuario)

**Arquivo responsável:** `assets/js/auth.js`

---

## 🎨 Customização

### **Modificar API URL**

Edite `assets/js/api.js`:

```javascript
constructor() {
    this.baseURL = 'http://localhost:5246/api'; // Altere aqui
}
```

### **Adicionar novas páginas**

1. Crie arquivo em `pages/`
2. Adicione links no menu/navegação
3. Implemente lógica JavaScript
4. Execute `.\CopiarFrontend.ps1` para atualizar wwwroot

---

## 🐛 Troubleshooting

### **Erro CORS**
- Verifique se a API está rodando
- Confirme origem em `program.cs`
- Teste pelo Swagger primeiro

### **401 Unauthorized**
- Verifique se está logado
- Confira se token está no localStorage
- Token pode ter expirado (faça login novamente)

### **404 Not Found**
- Confirme endpoint correto
- Verifique se API está rodando em `localhost:5246`
- Teste endpoint no Swagger

### **Arquivos estáticos não carregam**
- Execute `.\CopiarFrontend.ps1`
- Reinicie a API
- Limpe cache do navegador (Ctrl+Shift+R)

---

## 📱 Compatibilidade

- ✅ **Navegadores modernos** (Chrome, Firefox, Edge, Safari)
- ✅ **Responsive** (mobile, tablet, desktop)
- ✅ **Não interfere** com Mobile MAUI (ambos usam mesma API)

---

## 🚧 Próximos Passos

- [ ] Implementar `api.js` e `auth.js`
- [ ] Integrar páginas com API
- [ ] Adicionar validações client-side
- [ ] Implementar sistema de notificações
- [ ] Adicionar visualização de scores Handoff
- [ ] Criar histórico de análises IA

---

**Última atualização:** 27 de outubro de 2025
