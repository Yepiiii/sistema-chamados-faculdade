# 🔐 Credenciais de Teste - Sistema de Chamados

## Status: ✅ Todos os usuários configurados e testados com sucesso!

Data: 17 de outubro de 2025

---

## 📋 Usuários Disponíveis

### 1️⃣ ALUNO
```
Email: aluno@sistema.com
Senha: Aluno@123
Tipo: Aluno (TipoUsuario = 1)
```

**Perfil:**
- Nome Completo: João Silva Aluno
- Matrícula: 2024001
- Curso: Ciência da Computação

**Permissões:**
- ✅ Criar novos chamados
- ✅ Visualizar seus próprios chamados
- ✅ Usar análise de IA
- ❌ Não pode encerrar chamados
- ❌ Não pode gerenciar sistema

---

### 2️⃣ PROFESSOR
```
Email: professor@sistema.com
Senha: Prof@123
Tipo: Professor (TipoUsuario = 2)
```

**Perfil:**
- Nome Completo: Maria Santos Professor
- Curso Ministrado: Engenharia de Software
- Especialidade: Hardware (Categoria ID 1)

**Permissões:**
- ✅ Criar novos chamados
- ✅ Visualizar seus próprios chamados
- ✅ Usar análise de IA
- ✅ Pode ser atribuído como técnico em chamados de sua especialidade
- ❌ Não pode encerrar chamados
- ❌ Não pode gerenciar sistema

---

### 3️⃣ ADMINISTRADOR
```
Email: admin@sistema.com
Senha: Admin@123
Tipo: Administrador (TipoUsuario = 3)
```

**Perfil:**
- Nome Completo: Administrador Sistema

**Permissões:**
- ✅ TODAS as permissões do sistema
- ✅ Visualizar todos os chamados
- ✅ Atualizar status de chamados
- ✅ Atribuir técnicos
- ✅ **Encerrar chamados**
- ✅ Excluir todos os chamados
- ✅ Gerenciar categorias e prioridades
- ✅ Registrar novos administradores

---

## 🧪 Testes Realizados

### Status dos Logins
- ✅ Aluno: Login bem-sucedido
- ✅ Professor: Login bem-sucedido  
- ✅ Administrador: Login bem-sucedido

### API
- Endpoint: http://localhost:5246
- Método de autenticação: JWT Bearer Token
- Tempo de expiração do token: 24 horas

---

## 📝 Notas Técnicas

### Hashes de Senha
Todos os hashes foram gerados usando **BCrypt** com fator de custo 11:
- Formato: `$2a$11$...`
- Algoritmo: BCrypt.Net-Next
- Os hashes foram validados contra o método `BCrypt.Verify()` da API

### Banco de Dados
- Servidor: localhost
- Database: SistemaChamados
- Tabelas afetadas: `Usuarios`, `AlunoPerfis`, `ProfessorPerfis`
- Todos os chamados foram limpos para ambiente de teste limpo

---

## 🚀 Como Usar

### No App Mobile (MAUI)
1. Execute o app mobile
2. Na tela de login, use qualquer uma das credenciais acima
3. O app vai deslogar automaticamente a cada execução

### Via API (Postman/curl)
```bash
# Login
POST http://localhost:5246/api/usuarios/login
Content-Type: application/json

{
  "Email": "admin@sistema.com",
  "Senha": "Admin@123"
}

# Resposta
{
  "token": "eyJhbGci...",
  "usuario": {
    "id": 1,
    "nomeCompleto": "Administrador Sistema",
    "email": "admin@sistema.com",
    "tipoUsuario": 3,
    ...
  }
}
```

---

## 🔧 Scripts Disponíveis

### SetupUsuariosTeste.ps1
Limpa o banco e cria os 3 usuários de teste:
```powershell
.\SetupUsuariosTeste.ps1
```

### LimparTodosChamados.ps1
Remove todos os chamados (requer admin autenticado):
```powershell
.\LimparTodosChamados.ps1
```

---

## 📚 Documentação Relacionada

- `PERMISSOES.md` - Detalhamento completo de funcionalidades por tipo de usuário
- `README.md` - Documentação geral do sistema
- `README_MOBILE.md` - Documentação específica do app mobile

---

**Última atualização:** 17/10/2025  
**Status:** ✅ Sistema pronto para testes
