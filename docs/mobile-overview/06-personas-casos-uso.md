# 👥 Personas e Casos de Uso

## 🎭 Personas do Sistema

### **Persona 1: Aluno (Solicitante)** 👨‍🎓

#### **Perfil**
- **Nome**: João Silva
- **Idade**: 20 anos
- **Curso**: Ciência da Computação, 3º semestre
- **Experiência com tecnologia**: Intermediária
- **Dispositivo**: Smartphone Android (tela 6")
- **Conexão**: Wi-Fi do campus (boa) / 4G (razoável)

#### **Objetivos**
1. **Primário**: Resolver problemas técnicos rapidamente
2. **Secundário**: Acompanhar status dos chamados abertos
3. **Terciário**: Evitar deslocamento físico até suporte

#### **Necessidades**
- ✅ Abrir chamados de forma rápida (< 1 minuto)
- ✅ Acompanhar progresso em tempo real
- ✅ Saber quando o problema foi resolvido
- ✅ Entender o que está acontecendo (feedback claro)
- ✅ Anexar prints/fotos para explicar melhor

#### **Frustrações Atuais**
- ❌ "Preciso de muitos cliques para abrir um chamado simples"
- ❌ "Não sei se meu chamado foi lido"
- ❌ "Não consigo ver o histórico de o que já foi feito"
- ❌ "Filtros ocupam muito espaço, é difícil ver meus chamados"
- ❌ "Não sei se posso enviar imagens do problema"

#### **Citações**
> "Eu só queria abrir um chamado rápido sem precisar preencher mil campos."

> "Às vezes nem sei qual categoria escolher, prefiro que o sistema faça isso por mim."

> "Seria ótimo receber uma notificação quando meu problema for resolvido."

---

### **Jornada do Aluno: Abrir Chamado Simples**

#### **Estado Atual (Problemático)**

```
1. Abre o app
   └─ Login (se não estava logado)
   
2. Navega para "Meus Chamados"
   └─ Vê lista com TODOS os chamados (confuso)
   
3. Clica em "Abrir novo chamado"
   └─ Tela de formulário abre
   
4. Escreve descrição do problema (OK)
   └─ Editor funciona bem
   
5. Expande "Opções avançadas" (????)
   └─ Não sabe se precisa ou não
   
6. Vê "Classificar com IA" (ON por padrão)
   └─ Não entende direito, mas deixa ligado
   
7. Clica em "Criar Chamado"
   └─ Loading... (sem feedback de progresso)
   
8. Alert: "Sucesso!" (OK)
   └─ Volta para lista
   
9. Procura seu chamado na lista
   └─ Difícil de achar entre muitos
   
⏱️ TEMPO TOTAL: ~2-3 minutos
😠 FRUSTRAÇÃO: Média-Alta
```

#### **Estado Ideal (Proposto)**

```
1. Abre o app
   └─ Já logado (sessão persistida)
   
2. Está na aba "Início"
   └─ Vê cards: "Meus Chamados (3)" + "Abrir Novo" (destaque)
   
3. Toca em "Abrir Novo" (OU tap no FAB ➕)
   └─ Modal/tela simplificada abre
   
4. Vê 3 opções rápidas:
   ├─ [📝 Descrever problema] ← Seleciona esta
   ├─ [📸 Tirar foto e descrever]
   └─ [⚡ Problema comum (templates)]
   
5. Escreve descrição curta
   └─ Contador: "32/500 caracteres"
   
6. (Opcional) Anexa foto
   └─ Preview da imagem aparece
   
7. Toca em "Enviar" (botão grande)
   └─ Loading com texto: "IA analisando..." (feedback!)
   
8. Sucesso com animação
   └─ Toast: "Chamado #1234 criado!"
   └─ Botão: "Ver chamado" ou "Voltar"
   
9. Notificação: "Seu chamado foi atribuído a um técnico"
   └─ Push notification
   
⏱️ TEMPO TOTAL: ~30 segundos
😊 SATISFAÇÃO: Alta
```

---

### **Persona 2: Técnico (Atendente)** 👨‍💻

#### **Perfil**
- **Nome**: Maria Santos
- **Idade**: 28 anos
- **Cargo**: Técnica de Suporte TI - Nível 1
- **Experiência**: 3 anos no suporte técnico
- **Dispositivo**: Smartphone Android + Desktop
- **Uso do app**: Durante atendimentos móveis (lab, salas)

#### **Objetivos**
1. **Primário**: Atender máximo de chamados possível
2. **Secundário**: Priorizar chamados urgentes
3. **Terciário**: Comunicar-se com solicitantes

#### **Necessidades**
- ✅ Ver apenas chamados atribuídos a ela
- ✅ Filtrar por prioridade rapidamente
- ✅ Adicionar comentários/updates
- ✅ Encerrar chamados facilmente
- ✅ Acessar histórico de interações
- ✅ Ver localização (lab, sala) do problema

#### **Frustrações Atuais**
- ❌ "Vejo todos os chamados do sistema, é difícil achar os meus"
- ❌ "Não consigo deixar um comentário para o aluno"
- ❌ "Tenho que ligar/mandar email para pedir mais informações"
- ❌ "Filtros são lentos e ocupam muito espaço"
- ❌ "Não sei quais chamados já foram lidos/iniciados"

#### **Citações**
> "Preciso de uma visualização clara de 'Atribuídos a mim' e 'Urgentes'."

> "Seria ótimo poder adicionar fotos quando resolvo um problema no local."

> "Quero poder dizer ao aluno: 'Pode testar agora' sem precisar ligar."

---

### **Jornada do Técnico: Atender Chamado**

#### **Estado Atual (Problemático)**

```
1. Abre o app
   └─ Vê lista de TODOS os chamados do sistema
   
2. Usa filtro de "Status: Em Andamento"
   └─ Precisa de 2-3 toques para filtrar
   
3. Rola a lista procurando os que são dela
   └─ Não há indicador visual claro
   
4. Encontra um chamado, toca para ver detalhes
   └─ Vê informações básicas
   
5. Lê descrição (às vezes insuficiente)
   └─ Gostaria de pedir mais info, mas não pode
   
6. Vai fisicamente ao local resolver
   
7. Volta ao app, toca em "Encerrar chamado"
   └─ Confirm: "Tem certeza?"
   
8. Chamado encerrado
   └─ Sem feedback ao aluno (apenas mudança de status)
   
⏱️ TEMPO PERDIDO: ~2-3 min só navegando
😠 FRUSTRAÇÃO: Média
```

#### **Estado Ideal (Proposto)**

```
1. Abre o app
   └─ Tab "Meus Chamados" (default para técnicos)
   
2. Vê dashboard:
   ├─ "Atribuídos a você (5)"
   ├─ "Urgentes (2)" ← Destaque vermelho
   └─ "Aguardando resposta (1)"
   
3. Toca em "Urgentes"
   └─ Lista filtrada automaticamente
   
4. Cards com indicadores visuais:
   ├─ Borda esquerda vermelha (prioridade)
   ├─ Badge "🔥 URGENTE"
   └─ Localização: "Lab 3 - Computador 12"
   
5. Toca em um chamado
   └─ Vê detalhes + thread de mensagens
   
6. Adiciona comentário: "A caminho, 5 minutos"
   └─ Aluno recebe notificação
   
7. Resolve o problema no local
   
8. Adiciona foto da solução + comentário final
   └─ "Problema resolvido: cabo trocado"
   
9. Toca em "Encerrar e notificar solicitante"
   └─ Chamado encerrado + aluno recebe push
   
⏱️ TEMPO GANHO: ~5 min por chamado
😊 SATISFAÇÃO: Alta
```

---

### **Persona 3: Administrador** 👨‍💼

#### **Perfil**
- **Nome**: Carlos Oliveira
- **Idade**: 35 anos
- **Cargo**: Coordenador de TI
- **Responsabilidades**: Gestão de equipe + métricas
- **Dispositivo**: Primariamente desktop, app para monitoramento

#### **Objetivos**
1. **Primário**: Monitorar performance da equipe
2. **Secundário**: Identificar gargalos/problemas recorrentes
3. **Terciário**: Gerar relatórios gerenciais

#### **Necessidades**
- ✅ Dashboard com métricas
- ✅ Visualizar todos os chamados
- ✅ Reatribuir chamados entre técnicos
- ✅ Ver tempo médio de resolução
- ✅ Exportar relatórios

#### **Frustrações Atuais**
- ❌ "Não tenho visão geral no app"
- ❌ "Preciso ir ao desktop para ver métricas"
- ❌ "Não consigo reatribuir chamados facilmente"
- ❌ "Sem gráficos ou indicadores de performance"

#### **Citações**
> "Preciso de um dashboard móvel para acompanhar a equipe em tempo real."

> "Seria útil ver um gráfico de chamados por categoria para alocar recursos."

---

## 📊 Matriz de Funcionalidades por Persona

| Funcionalidade | Aluno | Técnico | Admin |
|----------------|-------|---------|-------|
| **Criar chamado** | ⭐⭐⭐ | ⭐ | ⭐ |
| **Ver seus chamados** | ⭐⭐⭐ | ⭐⭐ | ⭐ |
| **Ver todos os chamados** | ❌ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Encerrar chamado** | ❌ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Adicionar comentários** | ⭐ (futuro) | ⭐⭐⭐ | ⭐⭐ |
| **Upload de imagens** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐ |
| **Filtros avançados** | ⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Dashboard/métricas** | ❌ | ⭐ | ⭐⭐⭐ |
| **Notificações** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Atribuir/Reatribuir** | ❌ | ⭐ | ⭐⭐⭐ |

**Legenda:** ⭐⭐⭐ Crítico | ⭐⭐ Importante | ⭐ Nice-to-have | ❌ Não precisa

---

## 🎯 Casos de Uso Detalhados

### **UC-01: Abrir Chamado Simples (Aluno)**

**Ator Primário:** Aluno  
**Objetivo:** Reportar problema técnico rapidamente  
**Precondições:** App instalado, usuário autenticado  

**Fluxo Principal:**
1. Aluno abre o app
2. Sistema exibe tela inicial (já logado)
3. Aluno toca no FAB "Novo Chamado"
4. Sistema exibe formulário simplificado
5. Aluno escreve descrição do problema
6. (Opcional) Aluno anexa foto
7. Aluno toca em "Enviar"
8. Sistema envia para backend com IA
9. IA classifica automaticamente (título, categoria, prioridade)
10. Sistema cria chamado
11. Sistema exibe mensagem de sucesso + número do chamado
12. Sistema envia notificação ao técnico responsável

**Fluxos Alternativos:**
- **5a.** Aluno escolhe template de problema comum
  - Sistema preenche descrição base
  - Aluno complementa informações
  - Retorna ao passo 7

- **8a.** IA falha na classificação
  - Sistema solicita categoria manualmente
  - Aluno seleciona categoria
  - Sistema cria com prioridade padrão (Média)

**Pós-condições:**
- Chamado criado com status "Aberto"
- Técnico notificado
- Chamado aparece na lista do aluno

---

### **UC-02: Atender Chamado Urgente (Técnico)**

**Ator Primário:** Técnico  
**Objetivo:** Resolver chamado de alta prioridade  
**Precondições:** Chamado atribuído ao técnico, autenticado  

**Fluxo Principal:**
1. Técnico abre o app
2. Sistema exibe dashboard com "Urgentes (2)" destacado
3. Técnico toca em "Urgentes"
4. Sistema exibe lista filtrada de chamados urgentes
5. Técnico seleciona chamado específico
6. Sistema exibe detalhes + timeline
7. Técnico adiciona comentário: "A caminho"
8. Sistema notifica aluno
9. Técnico resolve problema fisicamente
10. Técnico retorna ao app
11. Técnico adiciona comentário de resolução + foto (opcional)
12. Técnico toca em "Encerrar e notificar"
13. Sistema altera status para "Encerrado"
14. Sistema registra data/hora de encerramento
15. Sistema envia notificação ao aluno

**Fluxos Alternativos:**
- **7a.** Técnico precisa de mais informações
  - Técnico adiciona comentário: "Pode enviar foto do erro?"
  - Sistema notifica aluno
  - Aluno responde com foto
  - Sistema notifica técnico
  - Técnico continua atendimento

- **11a.** Técnico não consegue resolver
  - Técnico adiciona comentário explicando
  - Técnico reatribui para técnico de nível superior
  - Sistema notifica novo técnico
  - Chamado permanece "Em Andamento"

**Pós-condições:**
- Chamado encerrado com data/hora registrada
- Aluno notificado da resolução
- Histórico completo salvo

---

### **UC-03: Acompanhar Status (Aluno)**

**Ator Primário:** Aluno  
**Objetivo:** Ver progresso do chamado aberto  
**Precondições:** Chamado criado previamente  

**Fluxo Principal:**
1. Aluno abre o app (recebeu notificação)
2. Sistema exibe lista de "Meus Chamados"
3. Aluno identifica chamado com badge "Atualizado"
4. Aluno toca no chamado
5. Sistema exibe detalhes com timeline
6. Aluno visualiza:
   - Comentário do técnico: "A caminho"
   - Timestamp: "10:30"
7. Aluno vê status: "Em Andamento"
8. (Opcional) Aluno adiciona resposta no thread
9. Sistema salva comentário
10. Sistema notifica técnico

**Pós-condições:**
- Aluno informado do progresso
- Badge "Atualizado" removido após visualização

---

## 💡 Insights das Personas

### **Para Alunos:**
- 🎯 **Simplicidade é rei**: Quanto menos campos, melhor
- 📸 **Visual > Texto**: Preferem anexar foto do erro
- ⏱️ **Tempo é valioso**: Querem resolver em < 1 minuto
- 🔔 **Notificações são essenciais**: Querem saber quando algo muda
- 🤖 **Confiam na IA**: Preferem classificação automática

### **Para Técnicos:**
- 🎯 **Foco é crítico**: Precisam ver apenas o que é deles
- 🔥 **Priorização visual**: Vermelho = Urgente (óbvio)
- 💬 **Comunicação é tudo**: Thread de mensagens é essencial
- 📍 **Contexto importa**: Localização física ajuda muito
- ⚡ **Ações rápidas**: Menos taps, mais produtividade

### **Para Admins:**
- 📊 **Métricas em destaque**: Dashboard é a tela inicial
- 👁️ **Visão geral**: Gráficos > Listas
- 🔄 **Gestão de equipe**: Reatribuir deve ser fácil
- 📈 **Tendências**: Identificar problemas recorrentes
- 📄 **Relatórios**: Exportar dados para apresentações

---

**Documento**: 06 - Personas e Casos de Uso  
**Data**: 20/10/2025  
**Versão**: 1.0
