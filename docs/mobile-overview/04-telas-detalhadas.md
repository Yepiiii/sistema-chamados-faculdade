# 📱 Telas Detalhadas - Layouts e Elementos

## 1. 🔐 LoginPage.xaml (Tela de Autenticação)

### **Layout Visual**

```
┌─────────────────────────────────────┐
│                                     │
│   ┌─────────────────────────────┐   │
│   │  [Gradiente Azul]          │   │
│   │                             │   │
│   │  Suporte Técnico            │   │
│   │  (28px Bold White)          │   │
│   │                             │   │
│   │  Faça login para acompanhar │   │
│   │  e abrir novos chamados.    │   │
│   └─────────────────────────────┘   │
│                                     │
│   ┌─────────────────────────────┐   │
│   │  Acesse sua conta           │   │
│   │                             │   │
│   │  ┌───────────────────────┐  │   │
│   │  │ Email institucional   │  │   │
│   │  └───────────────────────┘  │   │
│   │                             │   │
│   │  ┌───────────────────────┐  │   │
│   │  │ Senha                 │  │   │
│   │  └───────────────────────┘  │   │
│   │                             │   │
│   │  [    Entrar    ]           │   │
│   │                             │   │
│   │  (loading spinner)          │   │
│   └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

### **Elementos e Propriedades**

#### Header com Gradiente
```xml
<Border Background="{StaticResource HeaderGradient}"
        StrokeShape="RoundRectangle 28"
        Padding="20">
  <VerticalStackLayout Spacing="6">
    <Label Text="Suporte Técnico"
           FontSize="28"
           FontAttributes="Bold"
           TextColor="White" />
    <Label Text="Faça login para..."
           TextColor="White" />
  </VerticalStackLayout>
</Border>
```

#### Formulário
```xml
<Frame BackgroundColor="{StaticResource Secondary}"
       CornerRadius="24"
       Padding="24">
  <!-- 2 Entry fields + Button + ActivityIndicator -->
</Frame>
```

**Entry de Email:**
- Placeholder: "Email institucional"
- Keyboard: Email
- Bound a: `{Binding Email}`

**Entry de Senha:**
- Placeholder: "Senha"
- IsPassword: True
- Bound a: `{Binding Senha}`

**Botão Entrar:**
- HeightRequest: 52px
- Command: `{Binding LoginCommand}`

### **Pontos de Melhoria Identificados**

- [ ] Adicionar logo da instituição no topo
- [ ] Link "Esqueci minha senha" abaixo do botão
- [ ] Feedback visual de erro (mensagem em vermelho)
- [ ] Validação em tempo real (email inválido, campos vazios)
- [ ] Animação de shake quando credenciais inválidas
- [ ] Opção "Lembrar-me"
- [ ] Animação de transição após login bem-sucedido

---

## 2. 📋 ChamadosListPage.xaml (Lista Principal)

### **Layout Visual**

```
┌─────────────────────────────────────┐
│ ┌─────────────────────────────────┐ │ ← Header (Gradiente)
│ │ Chamados em andamento           │ │
│ │ Acompanhe as atualizações...    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [  Abrir novo chamado  ]            │ ← Botão de ação
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🔍 Buscar por título...         │ │ ← SearchBar
│ └─────────────────────────────────┘ │
│                                     │
│ [Categoria ▼] [Status ▼]           │ ← Filtros (Linha 1)
│ [Prioridade ▼] [Limpar filtros]    │ ← Filtros (Linha 2)
│                                     │
├─────────────────────────────────────┤ ← Separador
│ ┌─────────────────────────────────┐ │
│ │ CARD CHAMADO #1                 │ │
│ │─────────────────────────────────│ │
│ │ Problema no laboratório         │ │ ← Título (Bold 18px)
│ │ [Aberto] [Alta]                 │ │ ← Badges
│ │ Laboratório de Informática      │ │ ← Categoria
│ │ Criado por: João Silva          │ │ ← Solicitante
│ │ 📅 20/10/2025 14:30             │ │ ← Data abertura
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ CARD CHAMADO #2                 │ │
│ │─────────────────────────────────│ │
│ │ Erro na matrícula online        │ │
│ │ [Encerrado] [Média]             │ │
│ │ Secretaria Acadêmica            │ │
│ │ Criado por: Maria Santos        │ │
│ │ 📅 19/10/2025 09:15             │ │
│ │ ✅ Encerrado: 20/10/2025 10:00  │ │ ← Data fechamento
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ CARD CHAMADO #3                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ...                                 │
└─────────────────────────────────────┘
```

### **Estrutura XML**

```xml
<Grid RowDefinitions="Auto,Auto,Auto,*" RowSpacing="20" Padding="24">
  <!-- Row 0: Header -->
  <Border Background="{StaticResource ListHeaderGradient}" ... />
  
  <!-- Row 1: Botão Novo -->
  <Button Text="Abrir novo chamado" ... />
  
  <!-- Row 2: Filtros -->
  <VerticalStackLayout>
    <SearchBar ... />
    <Grid ColumnDefinitions="*,*">
      <Picker Title="Categoria" ... />
      <Picker Title="Status" ... />
    </Grid>
    <Grid ColumnDefinitions="*,Auto">
      <Picker Title="Prioridade" ... />
      <Button Text="Limpar filtros" ... />
    </Grid>
  </VerticalStackLayout>
  
  <!-- Row 3: Lista -->
  <CollectionView ItemsSource="{Binding Chamados}" ... />
</Grid>
```

### **Anatomia do Card de Chamado**

```xml
<Border Style="{StaticResource ChamadoCardStyle}">
  <Grid RowDefinitions="Auto,Auto,Auto,Auto" 
        ColumnDefinitions="*,Auto">
    
    <!-- Linha 0: Título (span 2 colunas) -->
    <Label Grid.Row="0" Grid.ColumnSpan="2"
           Text="{Binding Titulo}"
           FontAttributes="Bold"
           FontSize="18" />
    
    <!-- Linha 1: Badges à esquerda, Categoria à direita -->
    <StackLayout Grid.Row="1" Grid.Column="0" 
                 Orientation="Horizontal">
      <Border><!-- Badge Status --></Border>
      <Border><!-- Badge Prioridade --></Border>
    </StackLayout>
    <Label Grid.Row="1" Grid.Column="1"
           Text="{Binding Categoria.Nome}" />
    
    <!-- Linha 2: Solicitante -->
    <Label Grid.Row="2" Grid.ColumnSpan="2"
           Text="{Binding SolicitanteDisplay, 
                  StringFormat='Criado por: {0}'}" />
    
    <!-- Linha 3: Datas -->
    <HorizontalStackLayout Grid.Row="3" Grid.ColumnSpan="2">
      <Label Text="{Binding DataAbertura, 
                    StringFormat='📅 {0:dd/MM/yyyy HH:mm}'}" />
      <Label Text="{Binding DataFechamento, 
                    StringFormat='✅ Encerrado: {0:dd/MM/yyyy HH:mm}'}"
             IsVisible="{Binding DataFechamento, 
                         Converter={StaticResource IsNotNullConverter}}" />
    </HorizontalStackLayout>
  </Grid>
</Border>
```

### **Filtros - Estado Atual**

**SearchBar:**
- Placeholder: "Buscar por título ou descrição"
- Bound a: `{Binding SearchTerm}`
- Busca em tempo real

**Picker de Categoria:**
- ItemsSource: `{Binding Categorias}`
- ItemDisplayBinding: `{Binding Nome}`
- SelectedItem: `{Binding SelectedCategoria}`

**Picker de Status:**
- Similar à Categoria

**Picker de Prioridade:**
- Similar à Categoria

**Botão Limpar:**
- Command: `{Binding ClearFiltersCommand}`
- Reseta todos os filtros

### **EmptyView**

```xml
<CollectionView.EmptyView>
  <StackLayout Padding="32" HorizontalOptions="Center">
    <Label Text="Nenhum chamado encontrado"
           FontAttributes="Bold" />
    <Label Text="Quando você abrir um chamado, ele aparecerá aqui." />
  </StackLayout>
</CollectionView.EmptyView>
```

### **Pontos de Melhoria Identificados**

#### **Alta Prioridade** 🔥
- [ ] Reduzir altura dos cards (remover informações redundantes)
- [ ] Adicionar border-left colorido por prioridade (4px)
- [ ] Pull-to-refresh (RefreshView)
- [ ] FAB button para criar chamado (substituir botão atual)
- [ ] Colapsar filtros em "chip buttons"
- [ ] Adicionar contador de filtros ativos

#### **Média Prioridade** ⚡
- [ ] Skeleton loaders durante carregamento
- [ ] Paginação ou scroll infinito
- [ ] Indicador de "não lido" (badge com número)
- [ ] Swipe actions nos cards (ex: arquivar)
- [ ] Agrupar por status ou data
- [ ] Animação ao adicionar/remover cards

#### **Baixa Prioridade** 🌟
- [ ] Modo de visualização (lista/grid)
- [ ] Ordenação customizável
- [ ] Salvar filtros como preset

---

## 3. 🔍 ChamadoDetailPage.xaml (Detalhes do Chamado)

### **Layout Visual**

```
┌─────────────────────────────────────┐
│ ┌─────────────────────────────────┐ │ ← Header (Gradiente)
│ │ Detalhes do chamado             │ │
│ │                                 │ │
│ │ PROBLEMA NO LABORATÓRIO         │ │ ← Título (28px Bold)
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ │ [Aberto] [Alta]                 │ │ ← Badges
│ │                                 │ │
│ │ 📅 Abertura                     │ │
│ │ 20/10/2025 14:30                │ │
│ │                                 │ │
│ │ ✅ Encerramento                 │ │ ← (Se encerrado)
│ │ 20/10/2025 16:45                │ │
│ │                                 │ │
│ │ Solicitante                     │ │
│ │ João Silva (joao@email.com)     │ │
│ │                                 │ │
│ │ Descrição                       │ │
│ │ O computador #12 do lab 3 não   │ │
│ │ está ligando. Já tentei trocar  │ │
│ │ o cabo de energia mas não       │ │
│ │ funcionou...                    │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [    Encerrar chamado    ]          │ ← Botão (condicional)
│                                     │
└─────────────────────────────────────┘
```

### **Estrutura XML**

```xml
<ScrollView>
  <VerticalStackLayout Padding="24" Spacing="24">
    
    <!-- Header com Gradiente -->
    <Border Background="{StaticResource DetailHeaderGradient}" ...>
      <VerticalStackLayout>
        <Label Text="Detalhes do chamado" FontSize="22" />
        <Label Text="{Binding Chamado.Titulo}" FontSize="28" />
      </VerticalStackLayout>
    </Border>
    
    <!-- Frame com Informações -->
    <Frame Padding="24" CornerRadius="20">
      <VerticalStackLayout Spacing="20">
        
        <!-- Badges de Status/Prioridade -->
        <Grid ColumnDefinitions="*,*">
          <Border><!-- Status --></Border>
          <Border><!-- Prioridade --></Border>
        </Grid>
        
        <!-- Data de Abertura -->
        <HorizontalStackLayout>
          <Label Text="📅" />
          <VerticalStackLayout>
            <Label Text="Abertura" FontSize="12" Bold />
            <Label Text="{Binding Chamado.DataAbertura, 
                          StringFormat='{0:dd/MM/yyyy HH:mm}'}" />
          </VerticalStackLayout>
        </HorizontalStackLayout>
        
        <!-- Data de Encerramento (condicional) -->
        <HorizontalStackLayout IsVisible="{Binding HasFechamento}">
          <Label Text="✅" />
          <VerticalStackLayout>
            <Label Text="Encerramento" Bold TextColor="Success" />
            <Label Text="{Binding Chamado.DataFechamento, 
                          StringFormat='{0:dd/MM/yyyy HH:mm}'}" />
          </VerticalStackLayout>
        </HorizontalStackLayout>
        
        <!-- Solicitante -->
        <VerticalStackLayout IsVisible="{Binding Chamado.HasSolicitante}">
          <Label Text="Solicitante" FontAttributes="Bold" />
          <Label Text="{Binding Chamado.SolicitanteDisplay}" />
        </VerticalStackLayout>
        
        <!-- Descrição -->
        <VerticalStackLayout>
          <Label Text="Descrição" FontAttributes="Bold" />
          <Label Text="{Binding Chamado.Descricao}" />
        </VerticalStackLayout>
        
      </VerticalStackLayout>
    </Frame>
    
    <!-- Botão Encerrar (condicional) -->
    <Button Text="Encerrar chamado"
            Command="{Binding CloseChamadoCommand}"
            IsVisible="{Binding ShowCloseButton}" />
    
  </VerticalStackLayout>
</ScrollView>
```

### **Lógica de Visibilidade**

**Botão "Encerrar chamado" aparece quando:**
- Usuário é Técnico ou Admin
- Status do chamado NÃO é "Encerrado"
- Implementado em `ShowCloseButton` (ViewModel)

**Data de Encerramento aparece quando:**
- `DataFechamento` não é null
- Implementado com `IsNotNullConverter`

### **Pontos de Melhoria Identificados**

#### **Alta Prioridade** 🔥
- [ ] Adicionar seção de **Histórico de Atualizações**
  - Timeline vertical
  - Mudanças de status
  - Atribuições de técnico
  - Data/hora de cada evento

- [ ] Seção de **Comentários/Mensagens**
  - Thread de comunicação
  - Técnico pode adicionar comentários
  - Aluno pode responder

#### **Média Prioridade** ⚡
- [ ] Informações do **Técnico Responsável**
  - Nome, foto, contato
  - Quando foi atribuído

- [ ] Upload de **Anexos/Imagens**
  - Lista de arquivos anexados
  - Preview de imagens
  - Download

- [ ] **Indicador de Tempo**
  - "Aberto há 2 horas"
  - "Tempo médio de resolução: 4h"
  - Barra de progresso visual

#### **Baixa Prioridade** 🌟
- [ ] Botão de compartilhar (via email/WhatsApp)
- [ ] Exportar como PDF
- [ ] Avaliação do atendimento (estrelas)
- [ ] Tickets relacionados/similares

---

## 4. ➕ NovoChamadoPage.xaml (Criar Chamado)

### **Layout Visual**

```
┌─────────────────────────────────────┐
│ Novo chamado (28px Bold)            │
│ Descreva o problema e a IA...       │
│                                     │
│ ─────────────────────────────────── │
│                                     │
│ Descrição do problema (18px Bold)   │
│                                     │
│ Descrição                           │
│ ┌─────────────────────────────────┐ │
│ │ Conte o que está acontecendo... │ │ ← Editor (multiline)
│ │                                 │ │
│ │                                 │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Expandir opções avançadas]         │ ← Toggle
│                                     │
│ ─────────────────────────────────── │ ← (Quando expandido)
│                                     │
│ Opções avançadas (18px Bold)        │
│                                     │
│ Título (opcional)                   │
│ ┌─────────────────────────────────┐ │
│ │ Ex: Falha no acesso ao sistema  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Classificar automaticamente com IA  │
│ [Switch: ON/OFF]                    │
│                                     │
│ ─────────────────────────────────── │ ← (Se Switch OFF)
│                                     │
│ Categoria                           │
│ [Selecione uma categoria ▼]        │
│                                     │
│ Prioridade                          │
│ [Selecione a prioridade ▼]         │
│                                     │
│ ─────────────────────────────────── │
│                                     │
│ [       Criar Chamado       ]       │
│                                     │
│ (loading spinner)                   │
└─────────────────────────────────────┘
```

### **Estrutura XML Simplificada**

```xml
<ScrollView>
  <VerticalStackLayout Padding="24" Spacing="28">
    
    <!-- Cabeçalho -->
    <VerticalStackLayout>
      <Label Text="Novo chamado" Style="{StaticResource PageHeadlineStyle}" />
      <Label Text="Descreva o problema..." TextColor="Gray500" />
    </VerticalStackLayout>
    
    <!-- Descrição (sempre visível) -->
    <VerticalStackLayout>
      <Label Text="Descrição do problema" />
      <Border>
        <Editor Placeholder="Conte o que está acontecendo..."
                MinimumHeightRequest="160"
                Text="{Binding Descricao}" />
      </Border>
    </VerticalStackLayout>
    
    <!-- Toggle Opções Avançadas -->
    <Button Text="{Binding ToggleOpcoesAvancadasTexto}"
            Command="{Binding ToggleOpcoesAvancadasCommand}"
            IsVisible="{Binding PodeUsarClassificacaoManual}" />
    
    <!-- Opções Avançadas (condicional) -->
    <VerticalStackLayout IsVisible="{Binding ExibirOpcoesAvancadas}">
      
      <!-- Título Opcional -->
      <Border>
        <Entry Placeholder="Ex: Falha no acesso..."
               Text="{Binding Titulo}" />
      </Border>
      
      <!-- Switch IA -->
      <Grid ColumnDefinitions="*,Auto">
        <Label Text="Classificar automaticamente com IA" />
        <Switch IsToggled="{Binding UsarAnaliseAutomatica}" />
      </Grid>
      
      <!-- Classificação Manual (se Switch OFF) -->
      <VerticalStackLayout IsVisible="{Binding ExibirClassificacaoManual}">
        <Picker Title="Selecione uma categoria"
                ItemsSource="{Binding Categorias}" />
        <Picker Title="Selecione a prioridade"
                ItemsSource="{Binding Prioridades}" />
      </VerticalStackLayout>
      
    </VerticalStackLayout>
    
    <!-- Botão Criar -->
    <Button Text="Criar Chamado"
            Command="{Binding CriarCommand}"
            HeightRequest="52" />
    
    <ActivityIndicator IsRunning="{Binding IsBusy}" />
    
  </VerticalStackLayout>
</ScrollView>
```

### **Lógica de Visibilidade Complexa**

**ToggleOpcoesAvancadasTexto:**
- Se `ExibirOpcoesAvancadas == false`: "Expandir opções avançadas"
- Se `ExibirOpcoesAvancadas == true`: "Recolher opções avançadas"

**ExibirOpcoesAvancadas:**
- Controlado pelo botão toggle
- Mostra/esconde bloco de opções avançadas

**ExibirClassificacaoManual:**
- `!UsarAnaliseAutomatica` (inverso do switch IA)
- Se IA está ON: esconde pickers
- Se IA está OFF: mostra pickers

**PodeUsarClassificacaoManual:**
- Baseado no tipo de usuário (Alunos não podem)
- Se false, sempre usa IA (esconde botão de toggle)

### **Fluxo de Criação**

#### **Fluxo com IA (Padrão):**
1. Usuário escreve descrição
2. Clica em "Criar Chamado"
3. Backend chama Gemini API
4. IA gera:
   - Título
   - Categoria
   - Prioridade
5. Chamado criado
6. Retorna para lista

#### **Fluxo Manual (Técnicos/Admins):**
1. Usuário escreve descrição
2. Expande opções avançadas
3. Desliga switch de IA
4. Seleciona categoria e prioridade manualmente
5. (Opcional) Define título
6. Clica em "Criar Chamado"
7. Chamado criado sem IA
8. Retorna para lista

### **Validações**

**Campos obrigatórios:**
- **Descrição**: Sempre obrigatória (não pode ser vazia)

**Se IA estiver OFF:**
- **Categoria**: Obrigatória
- **Prioridade**: Obrigatória

**Feedback de erro:**
- Atualmente: Alert/DisplayAlert
- Sugestão: Labels em vermelho abaixo dos campos

### **Pontos de Melhoria Identificados**

#### **Alta Prioridade** 🔥
- [ ] Simplificar formulário (menos cliques)
- [ ] Validação em tempo real com feedback visual
- [ ] Contador de caracteres na descrição
- [ ] Botão de "Salvar rascunho"
- [ ] Preview da classificação da IA antes de criar

#### **Média Prioridade** ⚡
- [ ] Upload de imagens/arquivos
  - Botão "Anexar imagem"
  - Preview de imagens selecionadas
  - Câmera ou galeria

- [ ] Templates de problemas comuns
  - "Acesso negado"
  - "Erro de login"
  - "Equipamento com defeito"
  - Preenche descrição automaticamente

- [ ] Sugestões baseadas no texto
  - Enquanto digita, sugere categoria
  - "Parece que você está relatando problema de acesso..."

#### **Baixa Prioridade** 🌟
- [ ] Confirmação antes de criar ("Revisar informações")
- [ ] Animação de sucesso após criação
- [ ] Opção de "Abrir outro chamado"
- [ ] Salvar preferências (categoria favorita, etc.)

---

## 📊 Comparação das Telas

| Tela | Complexidade | Elementos Principais | Prioridade UX |
|------|--------------|---------------------|---------------|
| **Login** | Baixa | 2 inputs, 1 botão | Média |
| **Lista** | Alta | Filtros, cards, busca | ⭐ ALTA |
| **Detalhes** | Média | Informações estáticas, 1 botão | Média |
| **Novo Chamado** | Alta | Formulário condicional, IA | Alta |

---

**Documento**: 04 - Telas Detalhadas  
**Data**: 20/10/2025  
**Versão**: 1.0
