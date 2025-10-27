# 🔐 Credenciais de Acesso - Sistema de Chamados

## Usuários Padrão do Sistema

Este documento lista as credenciais de acesso para teste do sistema.

---

## 👨‍💼 Admin (Administrador)

**Email:** `admin@sistema.com`  
**Senha:** `Admin@123`  
**Tipo:** Administrador  
**Permissões:**
- Acesso total ao sistema
- Gerenciar usuários
- Gerenciar categorias, prioridades e status
- Visualizar todos os chamados
- Atribuir técnicos manualmente
- Fechar chamados
- Acessar dashboards e relatórios

---

## 🔧 Técnico Intermediário (Nível 2)

**Email:** `tecnico@empresa.com`  
**Senha:** `Admin@123`  
**Tipo:** Técnico TI - Nível 2  
**Área de Atuação:** Suporte Intermediário  
**Responsabilidade:**
- Chamados de **BAIXA** complexidade
- Chamados de **MÉDIA** complexidade (média-baixa)
- Problemas básicos e intermediários

**Exemplos de Chamados:**
- Problemas de login
- Configuração de email
- Instalação de software básico
- Problemas de rede simples
- Reset de senha

---

## 🚀 Técnico Sênior (Nível 3)

**Email:** `senior@empresa.com`  
**Senha:** `Admin@123`  
**Tipo:** Técnico TI - Nível 3  
**Área de Atuação:** Especialista Sênior  
**Responsabilidade:**
- Chamados de **MÉDIA-ALTA** complexidade
- Chamados de **ALTA** complexidade
- Chamados **CRÍTICOS**
- Problemas avançados e complexos

**Exemplos de Chamados:**
- Falhas de servidor
- Problemas de segurança
- Integração de sistemas
- Problemas de banco de dados
- Incidentes críticos que afetam múltiplos usuários

---

## 👤 Colaborador

**Email:** `colaborador@empresa.com`  
**Senha:** `Admin@123`  
**Tipo:** Colaborador  
**Matrícula:** COL001  
**Departamento:** Departamento Teste  
**Permissões:**
- Criar novos chamados
- Visualizar seus próprios chamados
- Acompanhar status dos chamados
- Adicionar comentários aos seus chamados

---

## 🤖 Sistema de Handoff Inteligente

O sistema utiliza **IA (Gemini)** para atribuição automática de chamados baseado em:

### Regras de Atribuição:

- **Nível 2 (Intermediário)**: Recebe automaticamente chamados de prioridade **Baixa** e **Média-Baixa**
- **Nível 3 (Sênior)**: Recebe automaticamente chamados de prioridade **Média-Alta**, **Alta** e **Crítica**

### Fatores de Score:
1. **Especialidade na Categoria** (+50 pontos)
2. **Prioridade do Chamado** (variável)
3. **Complexidade Avaliada por IA** (bônus)
4. **Carga de Trabalho** (penalidade)

---

## 🗄️ Banco de Dados

**Servidor:** `localhost` (SQL Server 2022/2025)  
**Database:** `SistemaChamados`  
**Autenticação:** Windows Authentication (Integrated Security)

### Como Popular os Usuários:

**Opção 1 - SQL Script (Recomendado):**
```powershell
sqlcmd -S localhost -d SistemaChamados -E -i "Scripts\Database\SeedUsuariosPadrao.sql"
```

**Opção 2 - PowerShell (via API):**
```powershell
.\Scripts\Database\PopularUsuariosPadrao.ps1
```
*(Requer backend rodando)*

---

## 🚀 Iniciar o Sistema

### Método 1: Script Completo (Recomendado)
```powershell
.\IniciarWeb.ps1
```
*Inicia backend + copia frontend + abre navegador*

### Método 2: Apenas Backend
```powershell
cd Backend
dotnet run
```

### Método 3: Modo Background
```powershell
.\IniciarAPIBackground.ps1
```

---

## 🌐 URLs de Acesso

- **Frontend:** http://localhost:5246/
- **API:** http://localhost:5246/api/
- **Swagger:** http://localhost:5246/swagger/

---

## 📝 Primeiro Acesso

1. Execute `.\IniciarWeb.ps1`
2. Aguarde o backend inicializar (~10 segundos)
3. O navegador abrirá automaticamente
4. Use qualquer uma das credenciais acima

---

## ⚠️ Notas Importantes

- **Todas as senhas são:** `Admin@123`
- As senhas estão hasheadas com **BCrypt** no banco de dados
- O Admin já foi criado pelo `EnsureCreated()` do backend
- Os outros 3 usuários são criados pelo script SQL
- **Não commitar** este arquivo com senhas reais em produção!

---

## 🔄 Migração do Banco

Se precisar recriar o banco de dados:

```powershell
cd Backend
dotnet ef database update
sqlcmd -S localhost -d SistemaChamados -E -i "Scripts\Database\SeedUsuariosPadrao.sql"
```

---

Última atualização: 27/10/2025
