# 📋 Testes - FASE 4.8: Configurações

## 🎯 Objetivo
Testar a página de configurações com edição de perfil, alteração de senha e preferências de notificações.

---

## ✅ Checklist de Validação

### 1️⃣ **Carregamento Inicial**
- [ ] Página carrega sem erros no console
- [ ] API é chamada: `GET /api/Usuarios/{id}`
- [ ] Dados do perfil são preenchidos nos campos
- [ ] Loading modal aparece durante carregamento
- [ ] Tab "Perfil" está ativa por padrão

### 2️⃣ **Sistema de Tabs**
- [ ] 3 tabs aparecem: Perfil, Segurança, Notificações
- [ ] Tab ativa tem borda azul embaixo
- [ ] Clicar em tab alterna o conteúdo
- [ ] Conteúdo tem animação de fade-in
- [ ] Apenas uma tab fica ativa por vez

### 3️⃣ **Tab: Perfil**
- [ ] Campos preenchidos com dados do usuário:
  - [ ] Nome completo
  - [ ] E-mail
  - [ ] CPF (com máscara: 000.000.000-00)
  - [ ] Telefone (com máscara: (00) 00000-0000)
  - [ ] Role/Função (disabled)
- [ ] Máscara de CPF funciona ao digitar
- [ ] Máscara de telefone funciona ao digitar
- [ ] Campo "Role" não é editável
- [ ] Botões "Salvar" e "Cancelar" aparecem

### 4️⃣ **Editar Perfil**
- [ ] Alterar nome e clicar "Salvar"
- [ ] Loading: "Salvando alterações..."
- [ ] API chamada: PUT /api/Usuarios/{id}
- [ ] Toast de sucesso aparece
- [ ] Dados são recarregados
- [ ] Se nenhum campo mudou: "Nenhuma alteração foi feita"
- [ ] Clicar "Cancelar" restaura valores originais

### 5️⃣ **Validação - Perfil**
- [ ] Nome vazio: impede submit
- [ ] E-mail vazio: impede submit
- [ ] E-mail inválido: validação HTML5
- [ ] Campos obrigatórios marcados com *

### 6️⃣ **Tab: Segurança (Alterar Senha)**
- [ ] 3 campos de senha aparecem:
  - [ ] Senha Atual
  - [ ] Nova Senha
  - [ ] Confirmar Nova Senha
- [ ] Todos os campos são do tipo password
- [ ] Placeholder ajuda o usuário
- [ ] Alert com dica de senha forte
- [ ] Botões "Alterar Senha" e "Cancelar"

### 7️⃣ **Alterar Senha**
- [ ] Preencher todos os campos corretamente
- [ ] Clicar "Alterar Senha"
- [ ] Loading: "Alterando senha..."
- [ ] API chamada: PUT /api/Usuarios/{id}/senha
- [ ] Toast de sucesso aparece
- [ ] Form é resetado (campos limpos)

### 8️⃣ **Validação - Senha**
- [ ] Campos vazios: "Preencha todos os campos"
- [ ] Nova senha < 6 caracteres: "Deve ter no mínimo 6 caracteres"
- [ ] Senhas não coincidem: "As senhas não coincidem"
- [ ] Nova senha igual à atual: "Deve ser diferente da atual"
- [ ] Senha atual incorreta: API retorna erro, toast mostra

### 9️⃣ **Tab: Notificações**
- [ ] 4 configurações aparecem com switches:
  - [ ] Notificações de Novos Chamados
  - [ ] Notificações de Atualização
  - [ ] Notificações de Atribuição
  - [ ] Som de Notificação
- [ ] Cada switch tem label e descrição
- [ ] Switches animam ao clicar (slide)
- [ ] Alert amarelo: "Salvas localmente no navegador"
- [ ] Botão "Salvar Preferências"

### 🔟 **Notificações (LocalStorage)**
- [ ] Ativar/desativar switches
- [ ] Clicar "Salvar Preferências"
- [ ] Toast: "Preferências de notificações salvas!"
- [ ] Recarregar página: preferências mantidas
- [ ] Dados salvos no localStorage: `notificationSettings`
- [ ] JSON válido no localStorage

### 1️⃣1️⃣ **UI/UX**
- [ ] Tabs responsivas (scroll horizontal em mobile)
- [ ] Forms validam antes de submit
- [ ] Loading modal bloqueia interações
- [ ] Toasts aparecem e desaparecem (4s)
- [ ] Transições suaves entre tabs
- [ ] Botões têm hover effects
- [ ] Switches têm animação suave

### 1️⃣2️⃣ **Navegação**
- [ ] Links do header funcionam
- [ ] Botão "Sair" faz logout e redireciona
- [ ] Não autenticado redireciona para login
- [ ] Voltar ao dashboard funciona

### 1️⃣3️⃣ **Responsividade**
- [ ] Layout adapta em mobile (< 768px)
- [ ] Tabs scrollam horizontalmente se necessário
- [ ] Setting items empilham verticalmente
- [ ] Switch vai para canto direito em mobile
- [ ] Forms ficam legíveis em telas pequenas

---

## 🧪 Cenários de Teste

### **Cenário 1: Editar Nome e Telefone**
1. Acesse: http://localhost:5246/pages/config.html
2. Faça login (qualquer role)
3. Tab "Perfil" já estará ativa
4. **Altere**:
   - Nome: "João Silva Santos" → "João Silva"
   - Telefone: "(11) 98765-4321" → "(11) 91234-5678"
5. Clique em **"Salvar Alterações"**
6. **Resultado esperado**:
   - Loading "Salvando alterações..."
   - PUT /api/Usuarios/{id}
   - Payload: `{ nome: "João Silva", email: "...", cpf: "...", telefone: "11912345678" }`
   - Toast: "Perfil atualizado com sucesso!"
   - Dados recarregados com novos valores

### **Cenário 2: Cancelar Edição**
1. Na tab "Perfil", altere o nome
2. Clique em **"Cancelar"**
3. **Resultado esperado**:
   - Nome volta ao valor original
   - Toast: "Alterações canceladas"
   - Nenhuma API chamada

### **Cenário 3: Alterar Senha**
1. Clique na tab **"Segurança"**
2. Preencha:
   - Senha Atual: `Usuario@123` (sua senha atual)
   - Nova Senha: `NovaSenh@456`
   - Confirmar: `NovaSenh@456`
3. Clique em **"Alterar Senha"**
4. **Resultado esperado**:
   - Loading "Alterando senha..."
   - PUT /api/Usuarios/{id}/senha
   - Payload: `{ senhaAtual: "...", novaSenha: "..." }`
   - Toast: "Senha alterada com sucesso!"
   - Form limpo
5. **Validar**: Fazer logout e login com nova senha

### **Cenário 4: Senha Atual Incorreta**
1. Tab "Segurança"
2. Digite senha atual errada
3. Clique em "Alterar Senha"
4. **Resultado esperado**:
   - API retorna erro (401 ou 400)
   - Toast: "Senha atual incorreta"
   - Form não é limpo (para corrigir)

### **Cenário 5: Senhas Não Coincidem**
1. Tab "Segurança"
2. Preencha:
   - Nova Senha: `Senha123`
   - Confirmar: `Senha456` (diferente)
3. Clique em "Alterar Senha"
4. **Resultado esperado**:
   - Validação client-side
   - Toast: "As senhas não coincidem"
   - Nenhuma API chamada

### **Cenário 6: Configurar Notificações**
1. Clique na tab **"Notificações"**
2. **Desative**:
   - Som de Notificação (toggle para OFF)
3. **Ative**:
   - Todas as outras (toggle para ON)
4. Clique em **"Salvar Preferências"**
5. **Resultado esperado**:
   - Toast: "Preferências de notificações salvas!"
   - localStorage atualizado
6. **Recarregue a página** (F5)
7. Vá para tab "Notificações"
8. **Resultado esperado**:
   - Configurações mantidas (3 ON, 1 OFF)

### **Cenário 7: Máscara de CPF**
1. Tab "Perfil"
2. Clique no campo CPF e digite apenas números: `12345678901`
3. **Resultado esperado**:
   - Máscara aplicada automaticamente: `123.456.789-01`

### **Cenário 8: Máscara de Telefone**
1. Tab "Perfil"
2. Digite no campo Telefone: `11987654321`
3. **Resultado esperado**:
   - Máscara aplicada: `(11) 98765-4321` (9 dígitos)
4. Delete e digite: `1137654321`
5. **Resultado esperado**:
   - Máscara aplicada: `(11) 3765-4321` (8 dígitos)

### **Cenário 9: Validação de E-mail**
1. Tab "Perfil"
2. Altere e-mail para valor inválido: `teste@`
3. Tente salvar
4. **Resultado esperado**:
   - Validação HTML5 impede submit
   - Mensagem do navegador: "Inclua um '@' no endereço..."

### **Cenário 10: Nenhuma Alteração**
1. Tab "Perfil"
2. Não altere nenhum campo
3. Clique em "Salvar Alterações"
4. **Resultado esperado**:
   - Toast: "Nenhuma alteração foi feita"
   - Nenhuma API chamada

---

## 🔧 Troubleshooting

### **Problema: Dados não aparecem nos campos**
**Causa**: API não retorna dados OU userId incorreto no token  
**Solução**:
- Verificar no DevTools → Network → resposta de GET /api/Usuarios/{id}
- Verificar userId no token: `authService.getUserInfo()`
- Testar endpoint no Swagger com ID correto

### **Problema: "Erro ao atualizar perfil"**
**Causa**: Endpoint não existe OU payload incorreto  
**Solução**:
- Verificar no Swagger: PUT /api/Usuarios/{id}
- Payload esperado: `{ nome, email, cpf, telefone }`
- Verificar logs do backend para detalhes

### **Problema: Máscaras não funcionam**
**Causa**: Event listeners não configurados  
**Solução**:
- Verificar console para erros de JavaScript
- Testar digitando devagar (input event)
- Limpar cache (Ctrl+Shift+R)

### **Problema: Senha não altera**
**Causa**: Endpoint específico pode não existir  
**Solução**:
- Código tenta PUT /api/Usuarios/{id}/senha primeiro
- Se falhar, tenta atualizar usuário completo com senha
- Verificar qual endpoint o backend suporta
- Adicionar endpoint específico se necessário

### **Problema: Notificações não salvam**
**Causa**: LocalStorage bloqueado (modo anônimo) OU bug no código  
**Solução**:
- Verificar se localStorage está disponível: `console.log(localStorage)`
- Modo anônimo do navegador bloqueia localStorage
- Usar navegador normal ou permitir armazenamento local

### **Problema: Tabs não trocam**
**Causa**: JavaScript não carregou OU event listeners falharam  
**Solução**:
- Verificar console para erros
- Verificar se config.js está carregando (Network tab)
- Verificar se classes CSS existem (.tab-content, .active)

---

## 📊 Endpoints Utilizados

| Método | Endpoint | Objetivo | Payload |
|--------|----------|----------|---------|
| GET | `/api/Usuarios/{id}` | Carregar dados do perfil | - |
| PUT | `/api/Usuarios/{id}` | Atualizar perfil | `{ nome, email, cpf, telefone }` |
| PUT | `/api/Usuarios/{id}/senha` | Alterar senha (específico) | `{ senhaAtual, novaSenha }` |

### **Payload: Atualizar Perfil**
```json
{
  "nome": "João Silva",
  "email": "joao@mail.com",
  "cpf": "12345678901",
  "telefone": "11987654321"
}
```

### **Payload: Alterar Senha**
```json
{
  "senhaAtual": "SenhaAntiga@123",
  "novaSenha": "NovaSenha@456"
}
```

### **LocalStorage: Notificações**
```json
{
  "novosChamados": true,
  "atualizacoes": true,
  "atribuicao": true,
  "som": false
}
```

---

## 🎨 Funcionalidades por Tab

| Tab | Funcionalidades | LocalStorage | API |
|-----|----------------|--------------|-----|
| **Perfil** | Editar nome, email, CPF, telefone | ❌ | ✅ PUT |
| **Segurança** | Alterar senha | ❌ | ✅ PUT |
| **Notificações** | Toggle switches (4 opções) | ✅ | ❌ |

---

## ✅ Critérios de Aceitação

Para considerar a FASE 4.8 como **COMPLETA**, todos os itens devem funcionar:

1. ✅ Dados do perfil carregam corretamente
2. ✅ Sistema de tabs funciona (3 tabs)
3. ✅ Edição de perfil salva via API
4. ✅ Máscaras de CPF e telefone aplicam automaticamente
5. ✅ Botão "Cancelar" restaura valores originais
6. ✅ Alteração de senha funciona via API
7. ✅ Validações impedem senhas incorretas/divergentes
8. ✅ Configurações de notificações salvam no localStorage
9. ✅ Preferências mantidas após recarregar página
10. ✅ Toasts de feedback aparecem em todas as ações
11. ✅ Loading modal bloqueia durante requisições
12. ✅ UI responsiva e animações suaves
13. ✅ Testes nos 10 cenários passam sem erros

---

## 🎉 FASE 4 COMPLETA!

Com a FASE 4.8 finalizada, **TODAS as 8 páginas principais** do sistema estão implementadas:

1. ✅ **4.1**: Login
2. ✅ **4.2**: Cadastro
3. ✅ **4.3**: Dashboard Usuário
4. ✅ **4.4**: Dashboard Admin
5. ✅ **4.5**: Gerenciar Chamados Admin
6. ✅ **4.6**: Novo Chamado
7. ✅ **4.7**: Detalhes do Chamado
8. ✅ **4.8**: Configurações ← **VOCÊ ESTÁ AQUI**

---

## 🚀 Próximas Fases

- **FASE 5**: Features Avançadas (notificações em tempo real, histórico detalhado)
- **FASE 6**: Melhorias de UX/UI (loading skeletons, animações)
- **FASE 7**: Testes Completos (E2E, integração, performance)
- **FASE 8**: Deploy e Documentação Final

---

**Data de criação**: 27 de outubro de 2025  
**Fase**: 4.8 - Configurações (Perfil, Senha, Notificações)  
**Status**: ✅ IMPLEMENTADO - PRONTO PARA TESTES  
**Progresso Geral**: 🎯 **100% da FASE 4 COMPLETA!**
