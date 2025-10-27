# 📋 Testes - FASE 4.6: Novo Chamado com Preview IA

## 🎯 Objetivo
Testar a página de criação de chamados com preview da análise da IA antes de submeter.

---

## ✅ Checklist de Validação

### 1️⃣ **Carregamento Inicial**
- [ ] Página carrega sem erros no console
- [ ] Campos do formulário aparecem corretamente
- [ ] Dropdown de Categorias é preenchido dinamicamente
- [ ] Dropdown de Prioridades é preenchido dinamicamente
- [ ] Contador de caracteres inicia em "0/1000"
- [ ] Botões estão visíveis e habilitados

### 2️⃣ **Validação de Formulário**
- [ ] Campos obrigatórios impedem submit vazio
- [ ] Título aceita até 120 caracteres
- [ ] Descrição aceita até 1000 caracteres
- [ ] Contador atualiza em tempo real
- [ ] Contador fica amarelo após 700 caracteres
- [ ] Contador fica vermelho após 900 caracteres
- [ ] Mensagem de erro aparece ao tentar submeter sem preencher

### 3️⃣ **Botão "Ver Sugestão da IA"**
- [ ] Botão está visível e clicável
- [ ] Não funciona se formulário incompleto (mostra aviso)
- [ ] Loading modal aparece com mensagem "Analisando chamado com IA..."
- [ ] API é chamada: `POST /api/Chamados/analisar-com-handoff`
- [ ] Preview card aparece após análise

### 4️⃣ **Preview da Análise IA**
- [ ] Card de preview aparece com borda azul
- [ ] Mostra técnico recomendado com nome e email
- [ ] Exibe score total do técnico
- [ ] Breakdown de scores mostra 5 métricas:
  - [ ] Especialidade (0-50 pts)
  - [ ] Disponibilidade (0-30 pts)
  - [ ] Performance (0-15 pts)
  - [ ] Prioridade (0-10 pts)
  - [ ] Complexidade (-10 a +10 pts)
- [ ] Barras de progresso refletem os scores
- [ ] Justificativa da IA aparece
- [ ] Ranking de técnicos aparece (top 5)
- [ ] Medalhas (🥇🥈🥉) nos 3 primeiros
- [ ] Botão × fecha o preview
- [ ] Alert informativo explica que é uma sugestão

### 5️⃣ **Comportamento do Preview**
- [ ] Preview fecha ao clicar no ×
- [ ] Preview é limpo ao alterar qualquer campo do formulário
- [ ] Scroll automático leva até o preview ao aparecer
- [ ] Preview não bloqueia edição do formulário

### 6️⃣ **Criação do Chamado**
- [ ] Botão "Criar Chamado" funciona sem preview
- [ ] Botão "Criar Chamado" funciona após preview
- [ ] Loading modal aparece com "Criando chamado..."
- [ ] API é chamada: `POST /api/Chamados`
- [ ] Toast de sucesso aparece
- [ ] Redireciona para `chamado-detalhes.html?id={id}` após 1 segundo
- [ ] Chamado é criado no backend (verificar no banco)

### 7️⃣ **Tratamento de Erros**
- [ ] Erro na API de categorias: fallback para categorias padrão
- [ ] Erro na API de prioridades: fallback para prioridades padrão
- [ ] Erro na análise IA: toast de erro, permite criar normalmente
- [ ] Erro ao criar chamado: toast de erro, não redireciona
- [ ] Mensagens de erro são claras e úteis

### 8️⃣ **UI/UX**
- [ ] Toast notifications aparecem no canto inferior direito
- [ ] Toasts desaparecem após 4 segundos
- [ ] Loading modal bloqueia interação durante requisições
- [ ] Campos com erro ficam com borda vermelha
- [ ] Feedback visual em todos os botões (hover)
- [ ] Transições suaves (animações)

### 9️⃣ **Navegação**
- [ ] Botão "Cancelar" volta para dashboard
- [ ] Link "Dashboard" no header funciona
- [ ] Link "Configurações" no header funciona
- [ ] Botão "Sair" faz logout e redireciona para login
- [ ] Não autenticado redireciona para login automaticamente

### 🔟 **Responsividade**
- [ ] Layout adapta em mobile (< 768px)
- [ ] Form-row empilha em mobile
- [ ] Tech-recommended empilha em mobile
- [ ] Toast ocupa largura adequada em mobile
- [ ] Botões ficam legíveis em mobile
- [ ] Preview não quebra layout em mobile

---

## 🧪 Cenários de Teste

### **Cenário 1: Criar Chamado SEM Preview IA**
1. Acesse: http://localhost:5246/pages/novo-ticket.html
2. Faça login como usuário comum (não admin)
3. Preencha o formulário:
   - Título: "Impressora não imprime"
   - Categoria: Hardware
   - Prioridade: Média
   - Descrição: "A impressora da sala 201 não está respondendo aos comandos de impressão."
4. Clique em **"Criar Chamado"** diretamente
5. **Resultado esperado**:
   - Loading modal aparece
   - Toast de sucesso aparece
   - Redireciona para detalhes do chamado
   - Chamado criado com status "Aberto"
   - Técnico atribuído automaticamente pela IA

### **Cenário 2: Criar Chamado COM Preview IA**
1. Acesse: http://localhost:5246/pages/novo-ticket.html
2. Faça login como usuário comum
3. Preencha o formulário:
   - Título: "Sistema travando ao abrir Excel"
   - Categoria: Software
   - Prioridade: Alta
   - Descrição: "O Excel 2019 trava sempre que tento abrir planilhas grandes (>50MB). O problema começou após a última atualização do Windows."
4. Clique em **"🤖 Ver Sugestão da IA"**
5. **Resultado esperado**:
   - Loading "Analisando chamado com IA..."
   - Preview card aparece com:
     - Técnico recomendado (ex: João Silva)
     - Score total (ex: 85 pts)
     - Breakdown detalhado das 5 métricas
     - Justificativa explicando por que foi escolhido
     - Ranking com top 5 técnicos
6. Revisar a sugestão
7. Clique em **"Criar Chamado"**
8. **Resultado esperado**:
   - Chamado criado com o técnico recomendado
   - Redireciona para detalhes

### **Cenário 3: Alterar Form Após Preview**
1. Acesse: http://localhost:5246/pages/novo-ticket.html
2. Preencha formulário e clique em "Ver Sugestão da IA"
3. Preview aparece com técnico X recomendado
4. **Altere a categoria** para outra
5. **Resultado esperado**:
   - Preview desaparece automaticamente
   - Precisa clicar em "Ver Sugestão da IA" novamente para nova análise
6. Clique novamente em "Ver Sugestão da IA"
7. **Resultado esperado**:
   - Nova análise com técnico potencialmente diferente

### **Cenário 4: Validação de Campos**
1. Acesse: http://localhost:5246/pages/novo-ticket.html
2. Tente clicar em "Ver Sugestão da IA" com formulário vazio
3. **Resultado esperado**:
   - Toast: "Preencha todos os campos antes de ver a sugestão da IA"
4. Tente clicar em "Criar Chamado" com formulário vazio
5. **Resultado esperado**:
   - Campos obrigatórios ficam com borda vermelha
   - Toast com lista de erros
   - Form não submete

### **Cenário 5: Contador de Caracteres**
1. Acesse: http://localhost:5246/pages/novo-ticket.html
2. Digite na descrição até passar de 700 caracteres
3. **Resultado esperado**: Contador fica amarelo
4. Continue digitando até passar de 900 caracteres
5. **Resultado esperado**: Contador fica vermelho
6. Tente digitar mais de 1000 caracteres
7. **Resultado esperado**: Campo limita em 1000 (HTML maxlength)

---

## 🔧 Troubleshooting

### **Problema: "Erro ao carregar categorias"**
**Causa**: API `/api/Categorias` não está respondendo  
**Solução**:
- Verificar se backend está rodando: http://localhost:5246/swagger
- Testar endpoint manualmente no Swagger
- Usar fallback: categorias padrão são carregadas automaticamente

### **Problema: "Erro ao obter sugestão da IA"**
**Causa**: API `/api/Chamados/analisar-com-handoff` falhou  
**Solução**:
- Verificar se há técnicos cadastrados no sistema
- Verificar se categorias têm especialidades vinculadas
- Verificar logs do backend para detalhes do erro da IA
- Sistema permite criar chamado normalmente mesmo sem preview

### **Problema: Preview não aparece**
**Causa**: Resposta da API não tem o formato esperado  
**Solução**:
- Abrir DevTools → Network → ver resposta da API
- Verificar se `tecnicoRecomendado` existe na resposta
- Verificar estrutura: `{ tecnicoRecomendado: {...}, scores: {...}, justificativa: "..." }`

### **Problema: Redireciona para login automaticamente**
**Causa**: Não está autenticado  
**Solução**:
- Fazer login antes: http://localhost:5246/pages/login.html
- Verificar se token JWT está no localStorage
- Token pode ter expirado (fazer login novamente)

### **Problema: Toasts não aparecem**
**Causa**: CSS pode não estar carregado corretamente  
**Solução**:
- Abrir DevTools → Console → verificar erros de CSS
- Limpar cache do navegador (Ctrl+Shift+Del)
- Verificar se `style.css` está carregando (Network tab)

---

## 📊 Endpoints Utilizados

| Método | Endpoint | Objetivo | Resposta Esperada |
|--------|----------|----------|-------------------|
| GET | `/api/Categorias` | Carregar lista de categorias | `[{ id: 1, nome: "Hardware", ... }]` |
| GET | `/api/Prioridades` | Carregar lista de prioridades | `[{ id: 1, nome: "Alta", nivel: 3 }]` |
| POST | `/api/Chamados/analisar-com-handoff` | Análise IA (preview) | `{ tecnicoRecomendado: {...}, scores: {...}, justificativa: "...", ranking: [...] }` |
| POST | `/api/Chamados` | Criar novo chamado | `{ id: 123, titulo: "...", status: "Aberto", ... }` |

### **Payload de Criação:**
```json
{
  "titulo": "Título do chamado",
  "descricao": "Descrição detalhada",
  "categoriaId": 1,
  "prioridadeId": 2,
  "usuarioId": 5
}
```

### **Payload de Análise (mesmo formato):**
```json
{
  "titulo": "Título do chamado",
  "descricao": "Descrição detalhada",
  "categoriaId": 1,
  "prioridadeId": 2,
  "usuarioId": 5
}
```

---

## 🎨 Sistema de Scores do Handoff

### **Métricas (Total: até 115 pts)**
1. **Especialidade** (0-50 pts)
   - Técnico tem especialidade na categoria do chamado
   - 50 pts: Especialidade exata
   - 0 pts: Sem especialidade

2. **Disponibilidade** (0-30 pts)
   - Baseado em número de chamados ativos do técnico
   - 30 pts: 0 chamados (totalmente disponível)
   - 0 pts: Sobrecarregado (>10 chamados)

3. **Performance** (0-15 pts)
   - Taxa de resolução e tempo médio
   - 15 pts: Excelente histórico
   - 0 pts: Sem histórico

4. **Prioridade** (0-10 pts)
   - Peso da prioridade do chamado
   - 10 pts: Prioridade Alta
   - 5 pts: Prioridade Média
   - 2 pts: Prioridade Baixa

5. **Complexidade** (-10 a +10 pts)
   - Ajuste baseado em palavras-chave na descrição
   - +10 pts: Problema simples
   - 0 pts: Complexidade média
   - -10 pts: Problema muito complexo

### **Interpretação:**
- **90-115 pts**: Excelente match (🥇)
- **70-89 pts**: Bom match (🥈)
- **50-69 pts**: Match razoável (🥉)
- **< 50 pts**: Match fraco

---

## ✅ Critérios de Aceitação

Para considerar a FASE 4.6 como **COMPLETA**, todos os itens devem funcionar:

1. ✅ Formulário carrega com categorias e prioridades dinâmicas
2. ✅ Validação impede submit com campos vazios
3. ✅ Botão "Ver Sugestão da IA" chama API e mostra preview
4. ✅ Preview exibe técnico recomendado, scores e justificativa
5. ✅ Preview fecha ao alterar form
6. ✅ Botão "Criar Chamado" cria ticket e redireciona
7. ✅ Tratamento de erros adequado (fallbacks, toasts)
8. ✅ UI responsiva e animações suaves
9. ✅ Navegação e logout funcionam
10. ✅ Testes nos 5 cenários passam sem erros

---

## 🚀 Próximos Passos

Após validar FASE 4.6:
- **FASE 4.7**: Detalhes do Chamado (visualização completa)
- **FASE 4.8**: Configurações (perfil e senha)

---

**Data de criação**: 27 de outubro de 2025  
**Fase**: 4.6 - Novo Chamado com Preview IA  
**Status**: ✅ IMPLEMENTADO - PRONTO PARA TESTES
