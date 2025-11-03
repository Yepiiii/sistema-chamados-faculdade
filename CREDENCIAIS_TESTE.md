# 🔐 Credenciais de Teste - NeuroHelp

## ✅ Banco de Dados Criado com Sucesso!

**Database:** SistemaChamados  
**Server:** localhost  
**Empresa:** NeuroHelp - Suporte Técnico  
**Status:** ✅ Online e funcional

---

## 👥 Usuários Disponíveis para Teste

### 💼 CLIENTE (TipoUsuario = 1)

- **Email:** `carlos.usuario@empresa.com`
- **Senha:** `senha123`
- **Nome:** Carlos Mendes
- **Função:** Cliente que pode abrir e acompanhar chamados

---

### 🔧 TÉCNICO (TipoUsuario = 2)

- **Email:** `pedro.tecnico@neurohelp.com`
- **Senha:** `senha123`
- **Nome:** Pedro Silva - Tecnico Hardware
- **Especialidade:** Hardware (Categoria ID 1)
- **Função:** Atende chamados de Hardware

---

### 👔 ADMINISTRADOR (TipoUsuario = 3)

- **Email:** `roberto.admin@neurohelp.com`
- **Senha:** `senha123`
- **Nome:** Roberto Nascimento
- **Função:** Supervisão e gerenciamento do sistema

---

## 📊 Dados Iniciais do Banco

### Status (7 registros)
1. Aberto
2. Em Andamento
3. Aguardando Resposta
4. Resolvido
5. Fechado
6. Cancelado
7. Em Espera

### Prioridades (4 registros)
1. Baixa (Nível 1) - até 5 dias úteis
2. Normal (Nível 2) - até 48 horas
3. Alta (Nível 3) - até 8 horas
4. Urgente (Nível 4) - imediato

### Categorias (10 registros)
1. Hardware
2. Software
3. Rede
4. E-mail
5. Acesso/Senha
6. Backup
7. Telefonia
8. Infraestrutura
9. Segurança
10. Outros

---

## 🧪 Sugestões de Teste

### Teste 1: Login como Cliente
```
Email: carlos.usuario@empresa.com
Senha: senha123
```
✅ Deve fazer login com sucesso  
✅ Deve buscar perfil do usuário (2 requisições)  
✅ Deve mostrar nome "Carlos Mendes" no app  
✅ TipoUsuario deve ser 1 (Cliente)

### Teste 2: Criar Chamado com IA (como Cliente)
```
Descrição: "Meu computador não liga, a tela fica preta e o LED está piscando"
```
✅ IA deve sugerir: Categoria = Hardware, Prioridade = Alta  
✅ Deve permitir editar sugestões  
✅ Deve criar chamado com sucesso

### Teste 3: Login como Técnico
```
Email: pedro.tecnico@neurohelp.com
Senha: senha123
```
✅ Deve fazer login com sucesso  
✅ Deve mostrar nome "Pedro Silva - Tecnico Hardware"  
✅ TipoUsuario deve ser 2 (Técnico)  
✅ Deve ter acesso a funcionalidades de técnico

### Teste 4: Login como Administrador
```
Email: roberto.admin@neurohelp.com
Senha: senha123
```
✅ Deve fazer login com sucesso  
✅ Deve mostrar nome "Roberto Nascimento - Supervisor"  
✅ TipoUsuario deve ser 3 (Admin)  
✅ Deve ter acesso total ao sistema

---

## 🔍 Queries Úteis

### Ver todos os usuários por tipo
```sql
SELECT 
    Id, 
    NomeCompleto, 
    Email, 
    CASE TipoUsuario 
        WHEN 1 THEN 'Cliente'
        WHEN 2 THEN 'Técnico'
        WHEN 3 THEN 'Administrador'
    END AS TipoUsuarioNome,
    c.Nome AS Especialidade
FROM Usuarios u
LEFT JOIN Categorias c ON u.EspecialidadeCategoriaId = c.Id
ORDER BY TipoUsuario, Id;
```

### Ver todos os chamados (após criar alguns)
```sql
SELECT 
    ch.Id,
    ch.Titulo,
    cli.NomeCompleto AS Cliente,
    tec.NomeCompleto AS Tecnico,
    s.Nome AS Status,
    p.Nome AS Prioridade,
    cat.Nome AS Categoria,
    ch.DataAbertura
FROM Chamados ch
INNER JOIN Usuarios cli ON ch.SolicitanteId = cli.Id
LEFT JOIN Usuarios tec ON ch.TecnicoId = tec.Id
INNER JOIN Status s ON ch.StatusId = s.Id
INNER JOIN Prioridades p ON ch.PrioridadeId = p.Id
INNER JOIN Categorias cat ON ch.CategoriaId = cat.Id
ORDER BY ch.DataAbertura DESC;
```

---

## ⚠️ Observações Importantes

1. **Senha Padrão:** Todos os usuários têm a senha `senha123`
2. **Hash BCrypt:** O hash usado é válido mas simplificado para testes
3. **TipoUsuario:**
   - 1 = Cliente (pode criar e acompanhar seus chamados)
   - 2 = Técnico (pode atender chamados)
   - 3 = Administrador (acesso total)
4. **Especialidades:** Técnicos podem ter especialidade em uma categoria específica
5. **Backend:** Certifique-se de que o backend está rodando em `http://localhost:5246`

---

**Banco pronto para testes com cenário real da NeuroHelp!** 🎉
