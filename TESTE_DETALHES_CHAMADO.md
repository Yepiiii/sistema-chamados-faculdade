# 📋 Testes - FASE 4.7: Detalhes do Chamado

## 🎯 Objetivo
Testar a visualização completa do chamado com ações baseadas em role (Usuário/Técnico/Admin).

---

## ✅ Checklist de Validação

### 1️⃣ **Carregamento Inicial**
- [ ] Página carrega sem erros no console
- [ ] ID é extraído corretamente da URL (`?id=123`)
- [ ] Se ID não existe, mostra erro e redireciona
- [ ] Loading modal aparece durante carregamento
- [ ] API é chamada: `GET /api/Chamados/{id}`
- [ ] Dados do chamado são exibidos

### 2️⃣ **Exibição de Dados**
- [ ] **Header**: ID (#123) e Status com badge colorido
- [ ] **Título**: Aparece em destaque
- [ ] **Prioridade**: Badge colorido (Alta=vermelho, Média=amarelo, Baixa=verde)
- [ ] **Categoria**: Nome da categoria
- [ ] **Datas**: Criação e última atualização formatadas (dd/mm/yyyy hh:mm)
- [ ] **Descrição**: Aparece em card destacado com borda azul
- [ ] **Técnico Atribuído**: Avatar + nome + email (ou "Nenhum técnico atribuído")

### 3️⃣ **Scores do Handoff (Admin apenas)**
- [ ] Section aparece apenas para role Admin
- [ ] Não aparece para Usuário ou Técnico
- [ ] Exibe 5 métricas com barras de progresso:
  - [ ] Especialidade (0-50 pts)
  - [ ] Disponibilidade (0-30 pts)
  - [ ] Performance (0-15 pts)
  - [ ] Prioridade (0-10 pts)
  - [ ] Complexidade (-10 a +10 pts)
- [ ] Score total aparece em destaque
- [ ] Barras animam ao carregar

### 4️⃣ **Justificativa da IA**
- [ ] Section aparece apenas se houver justificativa no banco
- [ ] Texto é exibido corretamente
- [ ] Formatação legível

### 5️⃣ **Histórico/Timeline**
- [ ] Timeline aparece com eventos:
  - [ ] "Chamado Criado" (data + usuário)
  - [ ] "Técnico Atribuído" (nome do técnico)
  - [ ] "Última Atualização" (data)
- [ ] Dots conectados por linha vertical
- [ ] Ordem cronológica correta

### 6️⃣ **Ações - Usuário**
- [ ] Botão "Fechar Chamado" aparece
- [ ] Outros botões NÃO aparecem (Status, Reatribuir, Prioridade)
- [ ] Ao clicar "Fechar Chamado":
  - [ ] Modal de confirmação abre
  - [ ] Ao confirmar: API é chamada, toast de sucesso, página recarrega
  - [ ] Ao cancelar: Modal fecha, nada acontece
- [ ] Se chamado já está fechado: "Este chamado está fechado."

### 7️⃣ **Ações - Técnico**
- [ ] Botões aparecem:
  - [ ] "Atualizar Status"
  - [ ] "Fechar Chamado"
- [ ] Botões de Admin NÃO aparecem (Reatribuir, Alterar Prioridade)
- [ ] **Atualizar Status**:
  - [ ] Modal abre com dropdown de status
  - [ ] Campo "Nota Técnica" (opcional)
  - [ ] Ao confirmar: PUT /api/Chamados/{id}/status
  - [ ] Toast de sucesso, página recarrega
- [ ] **Fechar Chamado**: Igual ao Usuário

### 8️⃣ **Ações - Admin**
- [ ] Todos os 4 botões aparecem:
  - [ ] "Atualizar Status"
  - [ ] "Reatribuir Técnico"
  - [ ] "Alterar Prioridade"
  - [ ] "Fechar Chamado"
- [ ] **Atualizar Status**: Igual ao Técnico
- [ ] **Reatribuir Técnico**:
  - [ ] Modal abre com dropdown de técnicos
  - [ ] Lista apenas técnicos e admins
  - [ ] Ao confirmar: PUT /api/Chamados/{id}/atribuir/{tecnicoId}
  - [ ] Toast de sucesso, página recarrega
- [ ] **Alterar Prioridade**:
  - [ ] Modal abre com dropdown de prioridades
  - [ ] Ao confirmar: PUT /api/Chamados/{id}/prioridade/{prioridadeId}
  - [ ] Toast de sucesso, página recarrega
- [ ] **Fechar Chamado**: Igual aos outros roles

### 9️⃣ **Modals - Comportamento**
- [ ] Modals abrem com animação suave
- [ ] Backdrop escurece a tela
- [ ] Clicar fora do modal fecha ele
- [ ] Botão × fecha o modal
- [ ] Botão "Cancelar" fecha o modal
- [ ] Form é resetado ao fechar
- [ ] Validação impede submit vazio

### 🔟 **Navegação**
- [ ] Botão "← Voltar" volta à página anterior
- [ ] Links do header funcionam (Dashboard, Novo Chamado, Config)
- [ ] Botão "Sair" faz logout e redireciona
- [ ] Não autenticado redireciona para login

### 1️⃣1️⃣ **Responsividade**
- [ ] Layout adapta em mobile (< 768px)
- [ ] Info grid empilha verticalmente
- [ ] Botões ocupam largura total
- [ ] Timeline reduz espaçamento
- [ ] Modals se ajustam à tela

---

## 🧪 Cenários de Teste

### **Cenário 1: Usuário Visualiza Seu Chamado**
1. Faça login como usuário comum:
   - Email: `usuario@sistema.com`
   - Senha: `Usuario@123`
2. Acesse dashboard, clique em um chamado
3. **Resultado esperado**:
   - Detalhes completos aparecem
   - Scores do Handoff NÃO aparecem
   - Justificativa da IA NÃO aparece (ou aparece se backend enviar)
   - Apenas botão "Fechar Chamado" disponível
4. Clique em "Fechar Chamado"
5. Confirme no modal
6. **Resultado esperado**:
   - API chama PUT /api/Chamados/{id}/status com statusId de "Fechado"
   - Toast: "Chamado fechado com sucesso!"
   - Página recarrega
   - Status muda para "Fechado"
   - Botões de ação desaparecem
   - Texto: "Este chamado está fechado."

### **Cenário 2: Técnico Atualiza Status**
1. Faça login como técnico:
   - Email: `tecnico@sistema.com`
   - Senha: `Tecnico@123`
2. Acesse um chamado atribuído a ele
3. **Resultado esperado**:
   - Botões "Atualizar Status" e "Fechar Chamado" aparecem
   - Scores NÃO aparecem
4. Clique em "Atualizar Status"
5. Modal abre com dropdown de status
6. Selecione "Em Andamento"
7. Digite nota técnica: "Iniciando investigação do problema"
8. Clique em "Confirmar"
9. **Resultado esperado**:
   - Loading: "Atualizando status..."
   - API: PUT /api/Chamados/{id}/status
   - Payload: `{ statusId: X, nota: "..." }`
   - Toast de sucesso
   - Página recarrega
   - Status muda para "Em Andamento"
   - Nota aparece no histórico (se backend suportar)

### **Cenário 3: Admin Reatribui Técnico**
1. Faça login como admin:
   - Email: `admin@sistema.com`
   - Senha: `Admin@123`
2. Acesse qualquer chamado
3. **Resultado esperado**:
   - Todos os 4 botões aparecem
   - Scores do Handoff aparecem com barras
   - Justificativa da IA aparece (se houver)
4. Clique em "Reatribuir Técnico"
5. Modal abre com lista de técnicos
6. Selecione outro técnico
7. Clique em "Confirmar"
8. **Resultado esperado**:
   - Loading: "Reatribuindo técnico..."
   - API: PUT /api/Chamados/{id}/atribuir/{tecnicoId}
   - Toast de sucesso
   - Página recarrega
   - Técnico atribuído muda no card

### **Cenário 4: Admin Altera Prioridade**
1. Como admin, acesse um chamado
2. Clique em "Alterar Prioridade"
3. Modal abre com dropdown de prioridades
4. Selecione "Alta"
5. Clique em "Confirmar"
6. **Resultado esperado**:
   - Loading: "Alterando prioridade..."
   - API: PUT /api/Chamados/{id}/prioridade/{prioridadeId}
   - Toast de sucesso
   - Página recarrega
   - Badge de prioridade muda para vermelho (Alta)

### **Cenário 5: Acesso Sem ID**
1. Acesse diretamente: `http://localhost:5246/pages/ticket-detalhes.html`
2. **Resultado esperado**:
   - Toast: "ID do chamado não encontrado"
   - Redireciona para dashboard após 2 segundos

### **Cenário 6: ID Inválido**
1. Acesse: `http://localhost:5246/pages/ticket-detalhes.html?id=99999`
2. **Resultado esperado**:
   - API retorna 404
   - Toast: "Erro ao carregar chamado"
   - Redireciona para dashboard após 2 segundos

### **Cenário 7: Chamado Fechado**
1. Acesse um chamado com status "Fechado"
2. **Resultado esperado**:
   - Card de ações mostra: "Este chamado está fechado."
   - Nenhum botão de ação aparece
   - Informações são exibidas normalmente

---

## 🔧 Troubleshooting

### **Problema: "ID do chamado não encontrado"**
**Causa**: URL sem query string `?id=`  
**Solução**:
- Navegar via dashboard clicando em um chamado
- Ou adicionar `?id=1` manualmente na URL
- Verificar se link do dashboard está correto: `ticket-detalhes.html?id=${chamado.id}`

### **Problema: Scores do Handoff não aparecem**
**Causa**: Role não é Admin OU backend não retorna `handoffScores`  
**Solução**:
- Verificar no DevTools → Network → response da API
- Estrutura esperada: `{ ..., handoffScores: { especialidade: X, ... } }`
- Apenas Admin vê os scores (verificar role no localStorage)

### **Problema: Botões não aparecem**
**Causa**: Chamado está fechado OU role não tem permissão  
**Solução**:
- Verificar status do chamado (se "Fechado", botões não aparecem)
- Verificar role no console: `authService.getUserRole()`
- Usuário: apenas "Fechar"
- Técnico: "Atualizar Status" + "Fechar"
- Admin: todos os 4 botões

### **Problema: "Erro ao atualizar status"**
**Causa**: Endpoint não existe OU payload incorreto  
**Solução**:
- Verificar no Swagger: PUT /api/Chamados/{id}/status
- Payload esperado: `{ statusId: number, nota?: string }`
- Verificar logs do backend para detalhes do erro

### **Problema: Modal não fecha**
**Causa**: Event listeners não configurados  
**Solução**:
- Verificar console para erros de JavaScript
- Clicar no × ou no backdrop deve fechar
- Botão "Cancelar" deve fechar
- Limpar cache e recarregar (Ctrl+Shift+R)

---

## 📊 Endpoints Utilizados

| Método | Endpoint | Objetivo | Role Requerido |
|--------|----------|----------|----------------|
| GET | `/api/Chamados/{id}` | Carregar dados do chamado | Qualquer autenticado |
| GET | `/api/Status` | Lista de status | Qualquer autenticado |
| GET | `/api/Prioridades` | Lista de prioridades | Qualquer autenticado |
| GET | `/api/Usuarios` | Lista de técnicos (filtrado) | Admin |
| PUT | `/api/Chamados/{id}/status` | Atualizar status + nota | Técnico ou Admin |
| PUT | `/api/Chamados/{id}/atribuir/{tecnicoId}` | Reatribuir técnico | Admin |
| PUT | `/api/Chamados/{id}/prioridade/{prioridadeId}` | Alterar prioridade | Admin |

### **Payload: Atualizar Status**
```json
{
  "statusId": 2,
  "nota": "Opcional: descrição do que foi feito"
}
```

### **Resposta Esperada: GET Chamado**
```json
{
  "id": 1,
  "titulo": "Título do chamado",
  "descricao": "Descrição detalhada",
  "status": { "id": 1, "nome": "Aberto" },
  "prioridade": { "id": 2, "nome": "Média" },
  "categoria": { "id": 1, "nome": "Hardware" },
  "usuario": { "id": 5, "nome": "João Silva", "email": "joao@mail.com" },
  "tecnicoAtribuido": { "id": 3, "nome": "Maria Santos", "email": "maria@mail.com" },
  "dataCriacao": "2025-10-27T10:30:00",
  "dataAtualizacao": "2025-10-27T14:20:00",
  "handoffScores": {
    "especialidade": 50,
    "disponibilidade": 25,
    "performance": 12,
    "prioridade": 10,
    "complexidade": 5,
    "total": 102
  },
  "justificativaIA": "Técnico escolhido por ter especialidade na categoria Hardware e estar disponível."
}
```

---

## 🎨 Permissões por Role

| Ação | Usuário | Técnico | Admin |
|------|---------|---------|-------|
| Ver detalhes | ✅ | ✅ | ✅ |
| Ver scores Handoff | ❌ | ❌ | ✅ |
| Fechar chamado | ✅ | ✅ | ✅ |
| Atualizar status | ❌ | ✅ | ✅ |
| Adicionar nota técnica | ❌ | ✅ | ✅ |
| Reatribuir técnico | ❌ | ❌ | ✅ |
| Alterar prioridade | ❌ | ❌ | ✅ |

---

## ✅ Critérios de Aceitação

Para considerar a FASE 4.7 como **COMPLETA**, todos os itens devem funcionar:

1. ✅ ID é extraído da URL corretamente
2. ✅ Dados do chamado são exibidos completos
3. ✅ Scores do Handoff aparecem apenas para Admin
4. ✅ Histórico/Timeline aparece com eventos
5. ✅ Botões de ação variam baseado em role:
   - Usuário: 1 botão
   - Técnico: 2 botões
   - Admin: 4 botões
6. ✅ Modals funcionam (Status, Reatribuir, Prioridade, Fechar)
7. ✅ APIs são chamadas corretamente em cada ação
8. ✅ Toasts de sucesso/erro aparecem
9. ✅ Página recarrega após cada ação bem-sucedida
10. ✅ Chamados fechados não permitem mais ações
11. ✅ UI responsiva e animações suaves
12. ✅ Navegação e logout funcionam
13. ✅ Testes nos 7 cenários passam sem erros

---

## 🚀 Próximos Passos

Após validar FASE 4.7:
- **FASE 4.8**: Configurações (editar perfil e alterar senha)
- **FASE 5**: Features Avançadas (notificações, histórico detalhado)
- **FASE 6**: Melhorias de UX/UI
- **FASE 7**: Testes completos
- **FASE 8**: Deploy e documentação final

---

**Data de criação**: 27 de outubro de 2025  
**Fase**: 4.7 - Detalhes do Chamado com Ações Baseadas em Role  
**Status**: ✅ IMPLEMENTADO - PRONTO PARA TESTES
