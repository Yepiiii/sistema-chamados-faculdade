# 🚨 Problemas Atuais de UX

## 📋 Lista Completa de Problemas Identificados

### 🧭 **1. NAVEGAÇÃO**

#### **1.1 Ausência de Bottom Navigation** ❌ CRÍTICO
**Problema:** Não há navegação por tabs/abas na parte inferior  
**Impacto:** Usuário precisa usar botão voltar constantemente  
**Afeta:** Todas as personas  
**Solução:** Implementar TabBar com 4 tabs principais

#### **1.2 Sem Drawer/Hamburger Menu** ❌ ALTO
**Problema:** Não há menu lateral para funções secundárias  
**Impacto:** Sem acesso fácil a perfil, configurações, logout  
**Afeta:** Todas as personas  
**Solução:** Implementar Shell.FlyoutHeader com opções

#### **1.3 Logout Não Visível** ❌ ALTO
**Problema:** Usuário não sabe como sair da conta  
**Impacto:** Confusão, frustração, fechar app forçado  
**Afeta:** Principalmente alunos  
**Solução:** Botão de logout no perfil ou drawer

#### **1.4 Navegação Linear Demais** ⚠️ MÉDIO
**Problema:** Sempre Login → Lista → Detalhes (push/pop apenas)  
**Impacto:** Sem atalhos, sempre volta para mesma tela  
**Afeta:** Técnicos (produtividade)  
**Solução:** Shell Navigation com rotas diretas

#### **1.5 Sem Estado de Navegação Persistente** ⚠️ MÉDIO
**Problema:** App sempre abre na mesma tela (login ou lista)  
**Impacto:** Não lembra última posição, scroll perdido  
**Afeta:** Usuários frequentes  
**Solução:** Salvar estado de navegação em Preferences

---

### 📱 **2. LISTAGEM DE CHAMADOS (ChamadosListPage)**

#### **2.1 Filtros Ocupam Muito Espaço** ❌ CRÍTICO
**Problema:** 4 filtros + SearchBar ocupam 40% da tela  
**Impacto:** Pouco espaço para ver chamados, scroll excessivo  
**Afeta:** Todas as personas  
**Exemplo:**
```
┌─────────────────┐
│ 🔍 Search       │ ← 1
│ [Categoria ▼]   │ ← 2
│ [Status ▼]      │ ← 3
│ [Prioridade ▼]  │ ← 4
│ [Limpar]        │ ← 5
├─────────────────┤ ← 40% da tela!
│ Cards (60%)     │
└─────────────────┘
```
**Solução:** Chip buttons + filtro colapsável

#### **2.2 Cards Muito Grandes (Baixa Densidade)** ❌ CRÍTICO
**Problema:** Cards ocupam muito espaço vertical  
**Impacto:** Vê apenas 2-3 chamados por vez  
**Afeta:** Técnicos (precisam escanear muitos)  
**Medida:** Card atual: ~180px de altura  
**Solução:** Reduzir para ~120px, informações mais compactas

#### **2.3 Sem Distinção Visual de Prioridade** ❌ ALTO
**Problema:** Badge de prioridade não é óbvio  
**Impacto:** Difícil identificar urgência rapidamente  
**Afeta:** Técnicos  
**Atual:** Apenas texto "Alta", "Média", etc.  
**Solução:** Border-left colorido (4px) + cores fortes

#### **2.4 Sem Pull-to-Refresh** ❌ ALTO
**Problema:** Não há como atualizar lista manualmente  
**Impacto:** Dados ficam desatualizados  
**Afeta:** Todas as personas  
**Solução:** Implementar RefreshView

#### **2.5 Sem Paginação/Scroll Infinito** ⚠️ MÉDIO
**Problema:** Carrega todos os chamados de uma vez  
**Impacto:** Performance ruim com muitos chamados (100+)  
**Afeta:** Admins, técnicos  
**Solução:** Lazy loading ou paginação

#### **2.6 Sem Indicador de "Não Lido"** ⚠️ MÉDIO
**Problema:** Não há como saber quais chamados têm atualizações  
**Impacto:** Usuário precisa abrir cada um para verificar  
**Afeta:** Alunos, técnicos  
**Solução:** Badge com número ou bolinha verde

#### **2.7 Botão "Abrir Novo" Não é FAB** ⚠️ MÉDIO
**Problema:** Botão comum no topo, não é floating  
**Impacto:** Menos acessível, não segue padrão mobile  
**Afeta:** Alunos (ação primária)  
**Solução:** Floating Action Button no canto inferior direito

#### **2.8 Sem Agrupamento por Status/Data** ℹ️ BAIXO
**Problema:** Lista plana, sem categorização visual  
**Impacto:** Difícil navegar em lista longa  
**Afeta:** Todos  
**Solução:** Headers de seção: "Hoje", "Ontem", "Esta semana"

#### **2.9 Sem Swipe Actions** ℹ️ BAIXO
**Problema:** Não há gestures nos cards  
**Impacto:** Sem ações rápidas (arquivar, marcar como lido)  
**Afeta:** Power users  
**Solução:** Swipe left para arquivar/deletar

#### **2.10 Sem Animações de Transição** ℹ️ BAIXO
**Problema:** Cards aparecem/desaparecem abruptamente  
**Impacto:** Experiência menos polida  
**Afeta:** Todos  
**Solução:** Fade in/out ao adicionar/remover

---

### ✍️ **3. CRIAÇÃO DE CHAMADOS (NovoChamadoPage)**

#### **3.1 Formulário Muito Longo** ❌ CRÍTICO
**Problema:** Muitos campos, opções escondidas em "avançadas"  
**Impacto:** Usuário confuso, tempo > 2 minutos  
**Afeta:** Alunos  
**Atual:** 
- Descrição (sempre)
- Toggle "avançadas" (confuso)
- Título opcional (desnecessário para alunos)
- Switch IA (confuso)
- Pickers (se IA OFF)

**Solução:** 2 versões:
- **Simples** (alunos): Só descrição + anexar foto
- **Completa** (técnicos): Com todas as opções

#### **3.2 Sem Upload de Imagens** ❌ ALTO
**Problema:** Não há como anexar fotos do problema  
**Impacto:** Descrição textual insuficiente  
**Afeta:** Alunos (precisam mostrar erro visualmente)  
**Solução:** ImageButton "📸 Anexar foto" + preview

#### **3.3 Validação Sem Feedback Visual** ⚠️ MÉDIO
**Problema:** Erros de validação só aparecem em Alert  
**Impacto:** Usuário não sabe qual campo está errado  
**Afeta:** Todos  
**Solução:** Labels vermelhas abaixo dos campos + borda vermelha

#### **3.4 Sem Contador de Caracteres** ℹ️ BAIXO
**Problema:** Usuário não sabe quanto pode escrever  
**Impacto:** Pode escrever demais ou de menos  
**Afeta:** Todos  
**Solução:** "125/500 caracteres" abaixo do editor

#### **3.5 Sem Preview da Classificação IA** ℹ️ BAIXO
**Problema:** Usuário não vê o que a IA sugeriu antes de criar  
**Impacto:** Sem confirmação, pode ser classificado errado  
**Afeta:** Alunos  
**Solução:** Tela de preview: "IA sugeriu: Categoria X, Prioridade Y"

#### **3.6 Sem Templates de Problemas Comuns** ℹ️ BAIXO
**Problema:** Usuário precisa escrever do zero sempre  
**Impacto:** Perda de tempo em problemas recorrentes  
**Afeta:** Alunos  
**Solução:** Botão "Problemas comuns" → Lista de templates

#### **3.7 Sem Opção de Salvar Rascunho** ℹ️ BAIXO
**Problema:** Se sair da tela, perde tudo  
**Impacto:** Frustração se interrompido  
**Afeta:** Todos  
**Solução:** Auto-save em Preferences

---

### 🔍 **4. DETALHES DO CHAMADO (ChamadoDetailPage)**

#### **4.1 Sem Histórico de Atualizações** ❌ ALTO
**Problema:** Não mostra timeline de mudanças  
**Impacto:** Usuário não sabe o que já foi feito  
**Afeta:** Todas as personas  
**Solução:** Timeline vertical com eventos:
```
📅 20/10 14:30 - Chamado aberto
👤 20/10 14:45 - Atribuído a Maria Santos
💬 20/10 15:00 - Maria: "A caminho"
✅ 20/10 15:30 - Encerrado
```

#### **4.2 Sem Seção de Comentários** ❌ ALTO
**Problema:** Não há comunicação técnico-aluno  
**Impacto:** Precisa usar email/telefone externamente  
**Afeta:** Técnicos (querem pedir mais info) + Alunos (querem responder)  
**Solução:** Thread de mensagens estilo chat

#### **4.3 Sem Informações do Técnico** ⚠️ MÉDIO
**Problema:** Aluno não sabe quem está atendendo  
**Impacto:** Falta de contexto, confiança  
**Afeta:** Alunos  
**Solução:** Card com foto, nome, contato do técnico

#### **4.4 Sem Upload de Anexos** ⚠️ MÉDIO
**Problema:** Não mostra/permite anexos  
**Impacto:** Técnico não pode enviar print da solução  
**Afeta:** Técnicos  
**Solução:** Galeria de imagens anexadas

#### **4.5 Sem Indicador de Tempo Decorrido** ℹ️ BAIXO
**Problema:** Não mostra "há quanto tempo" está aberto  
**Impacto:** Falta de contexto temporal  
**Afeta:** Todos  
**Solução:** "Aberto há 2 horas" (relative time)

---

### 🎨 **5. DESIGN GERAL**

#### **5.1 Sem Modo Escuro (Dark Mode)** ⚠️ MÉDIO
**Problema:** Apenas tema claro disponível  
**Impacto:** Cansaço visual à noite, gasto de bateria  
**Afeta:** Todos (especialmente usuários noturnos)  
**Solução:** Implementar AppThemeBinding para cores

#### **5.2 Sem Animações/Transições** ⚠️ MÉDIO
**Problema:** Navegação e ações sem feedback animado  
**Impacto:** App parece "travado" ou lento  
**Afeta:** Todos (percepção de qualidade)  
**Solução:** Fade in/out, slide, scale animations

#### **5.3 Loading States Inadequados** ⚠️ MÉDIO
**Problema:** Apenas ActivityIndicator genérico  
**Impacto:** Usuário não sabe o que está sendo carregado  
**Afeta:** Todos  
**Solução:** 
- Skeleton loaders (placeholders)
- Mensagens contextuais: "Carregando chamados..."
- Progress bar para uploads

#### **5.4 Feedback Tátil Ausente** ℹ️ BAIXO
**Problema:** Sem vibração em ações importantes  
**Impacto:** Menos feedback sensorial  
**Afeta:** Todos  
**Solução:** Haptic feedback em botões críticos

#### **5.5 Empty States Básicos** ℹ️ BAIXO
**Problema:** Mensagem de "Nenhum chamado" é genérica  
**Impacto:** Sem orientação do que fazer  
**Afeta:** Novos usuários  
**Atual:** "Nenhum chamado encontrado"  
**Solução:** Ilustração + call-to-action:
```
┌─────────────────┐
│       🎫        │
│  Nenhum chamado │
│  ainda!         │
│                 │
│ [Abrir o primeiro] │
└─────────────────┘
```

---

### ⚠️ **6. TRATAMENTO DE ERROS**

#### **6.1 Erros Mostrados em Alert** ❌ ALTO
**Problema:** DisplayAlert interrompe fluxo  
**Impacto:** Experiência abrupta, perde contexto  
**Afeta:** Todos  
**Solução:** Toast/Snackbar messages na parte inferior

#### **6.2 Sem Retry Automático** ⚠️ MÉDIO
**Problema:** Falha de rede não tenta novamente  
**Impacto:** Usuário precisa reabrir app  
**Afeta:** Usuários com conexão instável  
**Solução:** Retry com exponential backoff

#### **6.3 Mensagens de Erro Genéricas** ⚠️ MÉDIO
**Problema:** "Erro ao carregar" sem detalhes  
**Impacto:** Usuário não sabe como resolver  
**Afeta:** Todos  
**Solução:** Mensagens específicas:
- "Sem conexão. Verifique sua internet."
- "Sessão expirada. Faça login novamente."
- "Chamado não encontrado. Pode ter sido deletado."

#### **6.4 Sem Estado Offline** ℹ️ BAIXO
**Problema:** App não funciona sem internet  
**Impacto:** Não pode visualizar chamados já carregados  
**Afeta:** Usuários em movimento  
**Solução:** Cache local com SQLite

---

### 🔔 **7. NOTIFICAÇÕES**

#### **7.1 Sem Push Notifications** ❌ CRÍTICO
**Problema:** Usuário não sabe quando há atualizações  
**Impacto:** Precisa abrir app manualmente sempre  
**Afeta:** Todas as personas  
**Solução:** Firebase Cloud Messaging (FCM)

#### **7.2 Sem Badge de Contador** ⚠️ MÉDIO
**Problema:** Ícone do app não mostra número de pendências  
**Impacto:** Usuário não sabe se há novidades sem abrir  
**Afeta:** Todos  
**Solução:** Badge count no ícone

#### **7.3 Sem Configurações de Notificação** ℹ️ BAIXO
**Problema:** Não pode escolher o que notificar  
**Impacto:** Ou tudo ou nada  
**Afeta:** Todos  
**Solução:** Tela de preferências:
- ☑️ Notificar quando atribuído
- ☑️ Notificar quando respondido
- ☑️ Notificar quando encerrado

---

## 📊 Priorização dos Problemas

### **Matriz de Impacto vs Esforço**

```
        Alto Impacto
            ↑
    🔥🔥🔥  │  ⚡⚡⚡
    (FAZER)│ (PLANEJAR)
  ──────────┼──────────→ Alto Esforço
    📋📋📋  │  ❌❌❌
  (RÁPIDO) │ (EVITAR)
            ↓
      Baixo Impacto
```

### **🔥 CRÍTICO (Fazer AGORA)**
1. Bottom Navigation (navegação básica)
2. Filtros colapsáveis (liberar espaço)
3. Cards mais compactos (ver mais chamados)
4. Pull-to-refresh (atualizar dados)
5. Push notifications (manter engajamento)

### **⚡ ALTO (Fazer LOGO)**
6. Upload de imagens (criar + detalhes)
7. Histórico de atualizações (timeline)
8. Thread de comentários (comunicação)
9. Floating Action Button (acesso rápido)
10. Distinction visual de prioridade

### **📋 MÉDIO (Backlog)**
11. Dark mode
12. Skeleton loaders
13. Animações de transição
14. Toast messages (erro)
15. Paginação/scroll infinito

### **ℹ️ BAIXO (Nice-to-have)**
16. Swipe gestures
17. Templates de problemas
18. Salvar rascunho
19. Haptic feedback
20. Configurações de notificação

---

## 🎯 Problemas por Impacto no Usuário

### **Alunos** (Maior impacto)
1. Formulário longo → Criar chamado leva muito tempo
2. Sem upload de imagens → Não consegue mostrar erro visual
3. Sem notificações → Não sabe quando foi resolvido
4. Sem thread → Não consegue responder técnico
5. Filtros grandes → Lista difícil de navegar

### **Técnicos** (Maior impacto)
1. Cards grandes → Vê poucos chamados por vez
2. Sem distinção visual → Difícil priorizar
3. Sem thread → Precisa ligar para pedir info
4. Sem filtro "Meus chamados" → Difícil achar os seus
5. Pull-to-refresh ausente → Dados desatualizados

### **Admins** (Maior impacto)
1. Sem dashboard → Sem visão geral
2. Sem métricas → Não monitora performance
3. Paginação ausente → Performance ruim com muitos chamados
4. Sem exportar → Não gera relatórios
5. Sem reatribuir fácil → Gestão manual

---

**Documento**: 09 - Problemas de UX  
**Data**: 20/10/2025  
**Versão**: 1.0  
**Total de Problemas Identificados**: 40+
