# 📂 Estrutura de Pastas do Frontend

## ⚠️ IMPORTANTE - Duplicação de Arquivos

O projeto possui **DUAS pastas** com os mesmos arquivos HTML/JS/CSS:

### 1. `Frontend/Desktop/` ✏️
- **Pasta de DESENVOLVIMENTO**
- ✅ **EDITE AQUI** quando fizer mudanças no código
- Todos os arquivos `.html`, `.js`, `.css` do Desktop
- Esta é a pasta rastreada pelo Git

### 2. `Frontend/wwwroot/` 🌐
- **Pasta de PRODUÇÃO/SERVIDOR**
- ❌ **NÃO EDITE DIRETAMENTE**
- O servidor web (`start-frontend.ps1`) roda a partir DESTA pasta
- Arquivos devem ser copiados de `Desktop/` para cá

## 🔄 Workflow Correto

```
1. Editar arquivo em Frontend/Desktop/
   ↓
2. Executar: .\Scripts\sync-frontend.ps1
   ↓
3. Atualizar navegador (Ctrl+F5)
```

## 📝 Scripts Disponíveis

### `sync-frontend.ps1`
```powershell
.\Scripts\sync-frontend.ps1
```
- Copia todos os arquivos de `Desktop/` para `wwwroot/`
- **Execute SEMPRE** após editar arquivos

### `start-frontend.ps1`
```powershell
.\Scripts\start-frontend.ps1
```
- Inicia servidor web na porta 8080
- Serve arquivos de `Frontend/wwwroot/`
- Abre navegador automaticamente

## 🎯 Estrutura de Roteamento

### Login e Autenticação
- **Login:** `index.html` ou `/`
- **Cadastro:** `cadastro-desktop.html`
- **Esqueci Senha:** `esqueci-senha-desktop.html`
- **Resetar Senha:** `resetar-senha-desktop.html?token=XXX`

### Dashboards (após login)
| Tipo Usuário | TipoUsuario | Rota                           |
|--------------|-------------|--------------------------------|
| Admin        | 3           | `/admin-dashboard-desktop.html` |
| Técnico      | 2           | `/tecnico-dashboard.html`       |
| Usuário      | 1           | `/user-dashboard-desktop.html`  |

### Páginas Internas

#### Admin
- Dashboard: `/admin-dashboard-desktop.html`
- Todos Chamados: `/admin-tickets-desktop.html`
- Cadastrar Técnico: `/admin-cadastrar-tecnico.html`
- Configurações: `/config-desktop.html`

#### Técnico
- Dashboard: `/tecnico-dashboard.html`
- Detalhes do Chamado: `/tecnico-detalhes-desktop.html?id=X`
- Configurações: `/tecnico-config-desktop.html`

#### Usuário Comum
- Dashboard: `/user-dashboard-desktop.html`
- Novo Chamado: `/novo-ticket-desktop.html`
- Detalhes do Chamado: `/ticket-detalhes-desktop.html?id=X`
- Configurações: `/config-desktop.html`

## 🔐 Autenticação

### Token JWT
- Armazenado em: `sessionStorage.getItem('authToken')`
- Claims principais:
  - `nameidentifier`: ID do usuário
  - `emailaddress`: Email
  - `name`: Nome completo
  - `TipoUsuario`: 1 (Comum), 2 (Técnico), 3 (Admin)

### Lógica de Redirecionamento (Login)
```javascript
if (data.tipoUsuario === 3) {
  window.location.href = "/admin-dashboard-desktop.html";
} else if (data.tipoUsuario === 2) {
  window.location.href = "/tecnico-dashboard.html";
} else {
  window.location.href = "/user-dashboard-desktop.html";
}
```

## 🐛 Problemas Comuns

### "Mudanças não aparecem no navegador"
**Causa:** Editou em `Desktop/` mas servidor usa `wwwroot/`  
**Solução:** Execute `.\Scripts\sync-frontend.ps1`

### "Login funciona mas não redireciona"
**Causa:** Arquivos desatualizados em `wwwroot/`  
**Solução:** Sincronize e limpe cache (Ctrl+F5)

### "404 ao acessar dashboard"
**Causa:** Caminho relativo incorreto  
**Solução:** Todos os redirecionamentos usam `/` no início

## 📊 Endpoints da API

Base URL: `http://localhost:5246/api`

### Autenticação
- `POST /usuarios/login` - Login
- `POST /usuarios/registrar` - Cadastro usuário comum
- `POST /usuarios/registrar-tecnico` - Cadastro técnico (Admin only)
- `POST /usuarios/esqueci-senha` - Recuperação de senha
- `POST /usuarios/resetar-senha` - Reset com token

### Chamados
- `GET /chamados` - Todos (Admin) ou filtrados
- `GET /chamados?solicitanteId=X` - Por solicitante
- `GET /chamados?tecnicoId=X` - Por técnico
- `GET /chamados?tecnicoId=0&statusId=1` - Fila (não atribuídos + abertos)
- `POST /chamados` - Criar chamado
- `PUT /chamados/{id}` - Atualizar chamado
- `POST /chamados/analisar` - Análise IA

### Dados de Referência
- `GET /categorias` - Todas categorias
- `GET /prioridades` - Todas prioridades
- `GET /status` - Todos status
- `GET /usuarios/tecnicos` - Listar técnicos

## ✅ Checklist de Deploy

- [ ] Editou arquivos em `Frontend/Desktop/`
- [ ] Executou `.\Scripts\sync-frontend.ps1`
- [ ] Testou no navegador (http://localhost:8080)
- [ ] Fez commit das mudanças
- [ ] Verificou que backend está rodando (porta 5246)
