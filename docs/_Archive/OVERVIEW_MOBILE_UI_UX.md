# 📱 OVERVIEW DO PROJETO MOBILE - UI/UX
## Sistema de Chamados Técnicos - Faculdade

---

## 🎯 **OBJETIVO ATUAL**
Melhorar a navegabilidade e experiência do usuário (UI/UX) do aplicativo mobile Android, tornando-o mais intuitivo, moderno e adequado para uso em dispositivos móveis.

---

## 📊 **RESUMO EXECUTIVO**

### Tecnologia
- **Framework**: .NET MAUI 8.0
- **Linguagem**: C# + XAML
- **Plataforma Alvo**: Android (API 21+, targeting 33)
- **Arquitetura**: MVVM (Model-View-ViewModel)
- **API Backend**: ASP.NET Core Web API (REST)

### Funcionalidades Principais
1. **Autenticação**: Login de usuários (Alunos, Técnicos, Administradores)
2. **Listagem de Chamados**: Visualização de tickets com filtros
3. **Detalhes do Chamado**: Informações completas do ticket
4. **Criar Chamado**: Formulário de abertura com IA para classificação automática
5. **Encerrar Chamado**: Ação de finalização de tickets

---

## 🗂️ **ESTRUTURA DO PROJETO**

```
SistemaChamados.Mobile/
├── Views/                          # Telas XAML
│   ├── Auth/
│   │   └── LoginPage.xaml          # Tela de login
│   ├── ChamadosListPage.xaml       # Lista de chamados (principal)
│   ├── ChamadoDetailPage.xaml      # Detalhes do chamado
│   └── NovoChamadoPage.xaml        # Criar novo chamado
│
├── ViewModels/                     # Lógica de apresentação
│   ├── LoginViewModel.cs
│   ├── ChamadosListViewModel.cs
│   ├── ChamadoDetailViewModel.cs
│   └── NovoChamadoViewModel.cs
│
├── Models/                         # Entidades e DTOs
│   ├── Entities/
│   │   ├── Chamado.cs
│   │   ├── Usuario.cs
│   │   ├── Categoria.cs
│   │   ├── Prioridade.cs
│   │   └── Status.cs
│   └── DTOs/
│
├── Services/                       # Comunicação com API
│   ├── Api/
│   │   ├── ApiService.cs           # HttpClient wrapper
│   │   └── IApiService.cs
│   ├── Auth/
│   ├── Chamados/
│   ├── Categorias/
│   ├── Prioridades/
│   └── Status/
│
├── Helpers/                        # Utilitários
│   ├── Constants.cs                # URLs e constantes
│   ├── Settings.cs                 # Configurações persistidas
│   └── IsNotNullConverter.cs       # Conversor XAML
│
├── Resources/                      # Recursos visuais
│   ├── Styles/
│   │   ├── Colors.xaml            # Paleta de cores
│   │   └── Styles.xaml            # Estilos globais
│   ├── Images/                     # Ícones e imagens
│   └── Fonts/                      # Fontes (OpenSans)
│
└── AppShell.xaml                   # Navegação shell
```

---

## 🎨 **DESIGN SYSTEM ATUAL**

### Paleta de Cores

```xml
<!-- Cores Primárias -->
Primary: #2A5FDF          (Azul principal - botões, headers)
PrimaryDark: #1E47BB      (Azul escuro - hover states)
PrimaryDarkText: #0D2348  (Texto escuro sobre fundos claros)
Secondary: #D4F0FF        (Azul claro - backgrounds, badges)
Tertiary: #164A85         (Azul terciário)

<!-- Cores de Status -->
Success: #10B981          (Verde - chamados encerrados)
Warning: #F59E0B          (Laranja - alertas)
Danger: #EF4444           (Vermelho - erros, exclusões)

<!-- Escala de Cinzas -->
Gray100: #F5F8FB          (Backgrounds suaves)
Gray200: #E3E9F3          (Bordas suaves)
Gray300: #C4CDDE          (Bordas médias)
Gray400: #8C9AB6          (Placeholders)
Gray500: #546687          (Texto secundário)
Gray600: #3B4B68          (Texto terciário)
Gray800: #22304A          (Texto escuro)
Gray900: #1D2939          (Quase preto)

<!-- Bases -->
White: #FFFFFF
Black: #0F172A
```

### Tipografia
- **Fonte**: OpenSans (Regular, Bold)
- **Tamanhos**:
  - Headlines: 32px
  - SubHeadlines: 24px
  - Títulos de seção: 18-22px
  - Body text: 14px
  - Labels/Captions: 12-13px

### Espaçamentos
- **Padding padrão das páginas**: 24px
- **Spacing entre elementos**: 12-32px (variável por contexto)
- **Border radius**: 12-28px (variável por componente)

### Componentes Visuais Atuais

#### 1. **Gradientes**
```xml
<!-- Usado em headers -->
<LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
  <GradientStop Color="#2A5FDF" Offset="0" />
  <GradientStop Color="#3FA5F5" Offset="1" />
</LinearGradientBrush>
```

#### 2. **Cards de Chamados**
- Border arredondado (20px)
- Sombra sutil
- Padding interno: 18px
- Margin inferior: 16px
- Background: Branco (#FFFFFF)
- Borda: Gray200 (1px)

#### 3. **Badges/Tags**
- Border radius: 12px
- Padding: 10px horizontal, 4px vertical
- Background: Secondary para status
- Stroke para prioridades (outline style)

#### 4. **Botões**
- Altura mínima: 44-52px (acessibilidade touch)
- Border radius: 8-16px
- Padding: 14px horizontal, 10px vertical
- Background: Primary
- Text color: White

#### 5. **Form Fields**
- Border radius: 16-18px
- Border: 1px Gray200
- Background: White
- Padding: 14-16px
- Placeholder color: Gray400

---

## 📱 **TELAS DETALHADAS**

### 1. **LoginPage.xaml** (Tela de Autenticação)

**Layout Atual:**
- Header com gradiente azul
- Título: "Suporte Técnico"
- Subtítulo explicativo
- Frame com formulário:
  - Campo de email
  - Campo de senha
  - Botão "Entrar"
  - ActivityIndicator para loading

**Elementos:**
- 2 Entry fields (email, senha)
- 1 Button (login)
- 1 ActivityIndicator
- Gradiente decorativo

**Pontos de Melhoria:**
- [ ] Adicionar logo da instituição
- [ ] Link "Esqueci minha senha"
- [ ] Feedback visual de erro de login
- [ ] Animações de transição
- [ ] Validação em tempo real dos campos

---

### 2. **ChamadosListPage.xaml** (Lista Principal)

**Layout Atual:**
```
┌─────────────────────────────────┐
│  Header (Gradiente)             │
│  "Chamados em andamento"        │
└─────────────────────────────────┘
│  [Abrir novo chamado]           │
├─────────────────────────────────┤
│  🔍 SearchBar                    │
│  [Categoria ▼] [Status ▼]       │
│  [Prioridade ▼] [Limpar]        │
├─────────────────────────────────┤
│  ┌─────────────────────────┐    │
│  │ Card Chamado #1         │    │
│  │ Título bold             │    │
│  │ [Status] [Prioridade]   │    │
│  │ Categoria               │    │
│  │ Criado por: Nome        │    │
│  │ 📅 dd/mm/yyyy           │    │
│  └─────────────────────────┘    │
│  ┌─────────────────────────┐    │
│  │ Card Chamado #2         │    │
│  └─────────────────────────┘    │
│  ...                             │
└─────────────────────────────────┘
```

**Elementos:**
- Header com gradiente
- Botão de ação principal (criar chamado)
- **Filtros**:
  - SearchBar (busca por título/descrição)
  - Picker de Categoria
  - Picker de Status
  - Picker de Prioridade
  - Botão "Limpar filtros"
- **CollectionView** com cards:
  - Título do chamado (Bold, 18px)
  - Badges de Status e Prioridade
  - Nome da Categoria
  - "Criado por: Nome"
  - Data de abertura (📅)
  - Data de fechamento (✅) - se encerrado
- **EmptyView**: Mensagem quando não há chamados

**Pontos de Melhoria:**
- [ ] Filtros ocupam muito espaço vertical
- [ ] Adicionar pull-to-refresh
- [ ] Adicionar paginação/scroll infinito
- [ ] Ícones mais intuitivos
- [ ] Cores de status mais distintas
- [ ] Swipe actions nos cards (ex: arquivar, marcar como lido)
- [ ] Indicador visual de chamados não lidos
- [ ] Agrupar por status ou data
- [ ] Melhorar hierarquia visual dos cards
- [ ] Adicionar fab button para criar chamado

---

### 3. **ChamadoDetailPage.xaml** (Detalhes)

**Layout Atual:**
```
┌─────────────────────────────────┐
│  Header (Gradiente)             │
│  "Detalhes do chamado"          │
│  [TÍTULO DO CHAMADO]            │
└─────────────────────────────────┘
│  ┌─────────────────────────┐    │
│  │ Frame                    │    │
│  │ [Status] [Prioridade]    │    │
│  │                          │    │
│  │ 📅 Abertura              │    │
│  │ dd/mm/yyyy HH:mm         │    │
│  │                          │    │
│  │ ✅ Encerramento          │    │
│  │ dd/mm/yyyy HH:mm         │    │
│  │ (se encerrado)           │    │
│  │                          │    │
│  │ Solicitante              │    │
│  │ Nome completo            │    │
│  │                          │    │
│  │ Descrição                │    │
│  │ Texto completo...        │    │
│  └─────────────────────────┘    │
│                                  │
│  [Encerrar chamado]             │
│  (se aplicável)                  │
└─────────────────────────────────┘
```

**Elementos:**
- Header com gradiente + título
- Frame principal com:
  - Badges de Status/Prioridade
  - Datas de abertura/fechamento
  - Nome do solicitante
  - Descrição completa
- Botão "Encerrar chamado" (condicional)

**Pontos de Melhoria:**
- [ ] Adicionar histórico de atualizações
- [ ] Seção de comentários/mensagens
- [ ] Upload de anexos/imagens
- [ ] Indicador visual de tempo decorrido
- [ ] Informações do técnico responsável
- [ ] Timeline visual das mudanças
- [ ] Botão de compartilhar/exportar

---

### 4. **NovoChamadoPage.xaml** (Criar Chamado)

**Layout Atual:**
```
┌─────────────────────────────────┐
│  Novo chamado (Headline)        │
│  Texto explicativo              │
├─────────────────────────────────┤
│  Descrição do problema          │
│  ┌─────────────────────────┐    │
│  │ Descrição               │    │
│  │ [Editor multiline]       │    │
│  │                          │    │
│  └─────────────────────────┘    │
├─────────────────────────────────┤
│  [Expandir opções avançadas]    │
├─────────────────────────────────┤
│  (Quando expandido:)            │
│  Opções avançadas               │
│  ┌─────────────────────────┐    │
│  │ Título (opcional)        │    │
│  └─────────────────────────┘    │
│  [Switch] Classificar com IA    │
│                                  │
│  (Se Switch OFF:)                │
│  ┌─────────────────────────┐    │
│  │ Categoria ▼              │    │
│  └─────────────────────────┘    │
│  ┌─────────────────────────┐    │
│  │ Prioridade ▼             │    │
│  └─────────────────────────┘    │
├─────────────────────────────────┤
│  [Criar Chamado]                │
│  ActivityIndicator              │
└─────────────────────────────────┘
```

**Elementos:**
- Headline + texto explicativo
- Editor de descrição (multiline)
- Toggle para opções avançadas
- Campo de título (opcional)
- Switch para IA
- Pickers condicionais (categoria, prioridade)
- Botão de criar
- ActivityIndicator

**Pontos de Melhoria:**
- [ ] Adicionar upload de imagens/arquivos
- [ ] Preview da classificação da IA
- [ ] Validação visual dos campos obrigatórios
- [ ] Contador de caracteres
- [ ] Sugestões de categorias baseadas no texto
- [ ] Templates de problemas comuns
- [ ] Botão de salvar rascunho
- [ ] Confirmar antes de criar
- [ ] Feedback visual após criação

---

## 🔄 **FLUXO DE NAVEGAÇÃO ATUAL**

```
┌─────────────┐
│  LoginPage  │
└──────┬──────┘
       │ (Login bem-sucedido)
       ▼
┌──────────────────┐
│ ChamadosListPage │ ◄─────────────────┐
└────┬─────────┬───┘                   │
     │         │                        │
     │         │ (Tap em card)          │
     │         ▼                        │
     │   ┌──────────────────┐          │
     │   │ ChamadoDetailPage│          │
     │   └──────────────────┘          │
     │                                  │
     │ (Tap em "Abrir novo")           │
     ▼                                  │
┌──────────────────┐                   │
│ NovoChamadoPage  │                   │
└────────┬─────────┘                   │
         │ (Criar chamado)             │
         └─────────────────────────────┘
```

**Problemas de Navegação:**
- Sem navegação em gaveta (drawer)
- Sem tabs/bottom navigation
- Sem acesso rápido a perfil/configurações
- Sem histórico de navegação persistente

---

## 🎭 **PERSONAS E CASOS DE USO**

### Persona 1: **Aluno** (Solicitante)
**Objetivo**: Abrir e acompanhar chamados rapidamente

**Jornada atual:**
1. Login
2. Visualiza lista de seus chamados
3. Clica em "Abrir novo chamado"
4. Descreve o problema
5. (Opcionalmente) expande opções avançadas
6. Cria o chamado
7. Volta para a lista
8. Acompanha status

**Dores:**
- Muitos passos para criar chamado simples
- Difícil encontrar chamado específico na lista
- Sem notificações de atualização
- Não sabe em qual etapa o chamado está

### Persona 2: **Técnico** (Atendente)
**Objetivo**: Visualizar e encerrar chamados atribuídos

**Jornada atual:**
1. Login
2. Visualiza todos os chamados (não apenas os seus)
3. Usa filtros para encontrar chamados
4. Acessa detalhes
5. Encerra o chamado

**Dores:**
- Lista de chamados não diferencia prioridades visualmente
- Sem filtro rápido por "Atribuídos a mim"
- Não consegue adicionar comentários
- Sem modo offline

### Persona 3: **Administrador**
**Objetivo**: Gerenciar sistema e monitorar tickets

**Jornada atual:**
- Similar ao técnico
- Vê todos os chamados do sistema

**Dores:**
- Sem dashboard de métricas
- Não gerencia usuários pelo app
- Sem relatórios ou gráficos

---

## 📊 **DADOS E MODELOS**

### Modelo Principal: **Chamado**

```csharp
public class Chamado
{
    public int Id { get; set; }
    public string Titulo { get; set; }
    public string Descricao { get; set; }
    
    // Relacionamentos
    public int CategoriaId { get; set; }
    public Categoria Categoria { get; set; }
    
    public int PrioridadeId { get; set; }
    public Prioridade Prioridade { get; set; }
    
    public int StatusId { get; set; }
    public Status Status { get; set; }
    
    public int SolicitanteId { get; set; }
    public Usuario Solicitante { get; set; }
    
    public int? TecnicoId { get; set; }
    public Usuario? Tecnico { get; set; }
    
    // Datas
    public DateTime DataAbertura { get; set; }
    public DateTime? DataFechamento { get; set; }
    public DateTime DataUltimaAtualizacao { get; set; }
    
    // Propriedades computadas (para UI)
    public string SolicitanteDisplay => Solicitante?.NomeCompleto ?? "N/A";
    public bool HasSolicitante => Solicitante != null;
}
```

### Entidades Relacionadas

- **Categoria**: Nome, Descrição (ex: "Laboratório", "Matrícula", "Biblioteca")
- **Prioridade**: Nome, Nível (ex: "Baixa", "Média", "Alta", "Crítica")
- **Status**: Nome (ex: "Aberto", "Em Andamento", "Aguardando", "Encerrado")
- **Usuario**: Nome, Email, Tipo (Aluno, Técnico, Admin)

---

## 🚨 **PROBLEMAS ATUAIS DE UX**

### 1. **Navegação**
- ❌ Sem bottom navigation bar
- ❌ Sem drawer/hamburger menu
- ❌ Sem acesso rápido a perfil
- ❌ Sem logout visível

### 2. **Listagem de Chamados**
- ❌ Filtros ocupam muito espaço
- ❌ Cards muito grandes (pouca densidade)
- ❌ Sem distinção visual clara entre prioridades
- ❌ Sem indicadores de chamados não lidos
- ❌ Sem pull-to-refresh
- ❌ Sem paginação

### 3. **Criação de Chamados**
- ❌ Formulário muito longo
- ❌ Opções avançadas escondem campos importantes
- ❌ Sem upload de imagens
- ❌ Sem preview/confirmação

### 4. **Detalhes do Chamado**
- ❌ Informações muito básicas
- ❌ Sem histórico de mudanças
- ❌ Sem comunicação técnico-aluno
- ❌ Sem anexos

### 5. **Geral**
- ❌ Sem modo escuro (dark mode)
- ❌ Sem internacionalização
- ❌ Sem cache/modo offline
- ❌ Sem notificações push
- ❌ Sem animações/transições
- ❌ Sem feedback tátil (haptic)

---

## 🎯 **SUGESTÕES DE MELHORIA PRIORITÁRIAS**

### 🔥 **Alta Prioridade**

1. **Bottom Navigation Bar**
   - Tabs: 🏠 Início | 🎫 Chamados | ➕ Novo | 👤 Perfil
   - Sempre visível
   - Ícones coloridos quando ativos

2. **Melhorar Cards da Lista**
   - Reduzir altura
   - Usar cores de prioridade no border-left (4px)
   - Adicionar ícone de categoria
   - Badge de "não lido" mais visível

3. **Pull-to-Refresh**
   - Atualizar lista de chamados
   - Feedback visual

4. **FAB Button para Criar Chamado**
   - Floating Action Button no canto inferior direito
   - Ícone de ➕
   - Cor Primary

5. **Filtros Colapsáveis**
   - Chip buttons para filtros rápidos
   - Expandir para filtros avançados
   - Contadores de filtros ativos

6. **Perfil/Configurações**
   - Foto do usuário
   - Nome e email
   - Opção de logout
   - Configurações de notificação

### ⚡ **Média Prioridade**

7. **Timeline de Atualizações**
   - Histórico de mudanças de status
   - Comentários de técnicos
   - Visual de timeline vertical

8. **Upload de Imagens**
   - Ao criar chamado
   - Câmera ou galeria
   - Preview antes de enviar

9. **Melhorar Feedback Visual**
   - Toasts/Snackbars para ações
   - Skeleton loaders
   - Animações de transição

10. **Dashboard/Métricas**
    - Gráficos simples
    - Chamados por status
    - Tempo médio de resolução

### 🌟 **Baixa Prioridade (Nice-to-have)**

11. **Dark Mode**
12. **Busca avançada com sugestões**
13. **Notificações push**
14. **Modo offline com sync**
15. **Compartilhar chamado**
16. **Exportar relatórios**

---

## 🛠️ **RECURSOS TÉCNICOS DISPONÍVEIS**

### ✅ **Já Implementado**
- MVVM pattern
- Data binding (two-way)
- HttpClient com interceptors
- Converters XAML (IsNotNullConverter)
- Resource dictionaries (Colors, Styles)
- CollectionView com filtros
- ActivityIndicator para loading
- Navigation com Shell
- Settings persistence

### 🔧 **Precisa Implementar**
- Pull-to-refresh (RefreshView)
- Skeleton loaders
- Toast/Snackbar messages
- Image picker
- File upload
- Push notifications
- Offline storage (SQLite)
- Animations
- Gestures (swipe)

---

## 📐 **GUIDELINES DE DESIGN MÓVEL**

### Tamanhos Mínimos (Acessibilidade)
- **Botões/Touch targets**: 44x44 dp (mínimo)
- **Texto**: 14sp (mínimo)
- **Espaçamento entre elementos clicáveis**: 8dp

### Áreas Seguras
- **Padding lateral**: 16-24dp
- **Respeitar safe areas**: Top e Bottom (notch, gesture bars)

### Performance
- **Scroll suave**: 60fps
- **Loading states**: Sempre fornecer feedback
- **Images**: Lazy loading, cache

---

## 📝 **CHECKLIST PARA NOVA IA**

### Ao melhorar o UI/UX, considere:

- [ ] Manter a paleta de cores existente (ou propor melhor)
- [ ] Usar componentes nativos do .NET MAUI quando possível
- [ ] Manter padrão MVVM
- [ ] Adicionar animações sutis (não exageradas)
- [ ] Pensar em acessibilidade (contraste, tamanhos)
- [ ] Considerar diferentes tamanhos de tela
- [ ] Priorizar navegação com uma mão
- [ ] Reduzir número de taps necessários
- [ ] Fornecer feedback visual imediato
- [ ] Usar ícones universalmente reconhecidos
- [ ] Manter consistência visual entre telas
- [ ] Adicionar empty states informativos
- [ ] Tratar estados de erro graciosamente

---

## 🎨 **REFERÊNCIAS DE DESIGN**

### Inspirações (apps similares):
- **Jira Mobile**: Sistema de tickets
- **Zendesk**: Suporte técnico
- **Freshdesk**: Help desk
- **Trello**: Cards e organização
- **Slack**: Comunicação por threads

### Material Design 3 Guidelines:
- https://m3.material.io/
- Cards, FABs, Bottom Navigation
- Color system, Typography

### iOS Human Interface Guidelines:
- https://developer.apple.com/design/human-interface-guidelines/

---

## 📊 **MÉTRICAS DE SUCESSO**

### Como medir melhorias:
1. **Tempo médio para criar chamado**: Reduzir de 2min para 30s
2. **Número de taps para ação comum**: Máximo 3 taps
3. **Taxa de abandono no formulário**: < 10%
4. **Satisfação do usuário**: Survey interno (NPS)
5. **Taxa de uso de filtros**: Aumentar 50%

---

## 🚀 **PRÓXIMOS PASSOS SUGERIDOS**

### Fase 1: Navegação (1-2 dias)
1. Implementar Bottom Navigation
2. Adicionar página de Perfil
3. Logout visível

### Fase 2: Lista de Chamados (2-3 dias)
4. Redesenhar cards (mais compactos)
5. Pull-to-refresh
6. FAB button
7. Filtros como chips

### Fase 3: Criação (1-2 dias)
8. Simplificar formulário
9. Upload de imagens
10. Melhorar feedback

### Fase 4: Detalhes (2 dias)
11. Timeline de atualizações
12. Seção de comentários

### Fase 5: Polimento (2-3 dias)
13. Animações
14. Dark mode
15. Empty states
16. Loading states
17. Error handling

---

## 💾 **ARQUIVOS-CHAVE PARA EDITAR**

### Navegação
- `AppShell.xaml` - Estrutura principal
- `MauiProgram.cs` - Registro de rotas

### Telas
- `Views/ChamadosListPage.xaml`
- `Views/ChamadoDetailPage.xaml`
- `Views/NovoChamadoPage.xaml`
- `Views/Auth/LoginPage.xaml`

### Estilos
- `Resources/Styles/Colors.xaml`
- `Resources/Styles/Styles.xaml`

### ViewModels
- `ViewModels/ChamadosListViewModel.cs`
- `ViewModels/ChamadoDetailViewModel.cs`
- `ViewModels/NovoChamadoViewModel.cs`

---

## 🔗 **CONEXÃO COM BACKEND**

### Endpoint Base
- **Local**: `http://localhost:5246/api/`
- **Rede**: `http://192.168.0.18:5246/api/`

### Principais Endpoints
- `POST /Auth/login` - Autenticação
- `GET /Chamados` - Lista de chamados (com filtros query string)
- `GET /Chamados/{id}` - Detalhes do chamado
- `POST /Chamados` - Criar chamado (com IA ou manual)
- `PUT /Chamados/{id}/fechar` - Encerrar chamado
- `GET /Categorias` - Lista de categorias
- `GET /Prioridades` - Lista de prioridades
- `GET /Status` - Lista de status

### Headers Necessários
```
Authorization: Bearer {token}
Content-Type: application/json
Accept-Charset: utf-8
```

---

## ⚠️ **RESTRIÇÕES E CONSIDERAÇÕES**

### Técnicas
- Target Android API 33 (Android 13)
- Minimum API 21 (Android 5.0)
- .NET 8.0
- Sincronização com backend obrigatória (sem offline no MVP)

### Negócio
- **Alunos**: Apenas veem seus próprios chamados
- **Técnicos/Admins**: Veem todos os chamados
- **IA**: Gemini para classificação automática (opcional)
- **Permissões**: Baseadas no tipo de usuário

### UX
- App deve funcionar com uma mão
- Priorizar ações comuns (criar, visualizar)
- Evitar scroll horizontal
- Suportar modo retrato (portrait)
- Modo paisagem (landscape) opcional

---

## 🎯 **CONCLUSÃO**

O projeto está **funcional** mas precisa de melhorias significativas de UX para ser intuitivo e agradável em dispositivos móveis.

**Principais gaps:**
1. Navegação primitiva (sem bottom nav)
2. Cards/lista não otimizados para mobile
3. Falta de feedback visual
4. Formulários muito longos
5. Sem recursos modernos (pull-to-refresh, swipe, etc.)

**Potencial:**
- Código bem estruturado (MVVM)
- Backend robusto com IA
- Design system básico já definido
- Funcionalidades core completas

**Objetivo final:**
Transformar em um app moderno, intuitivo e eficiente que:
- Permita criar chamado em < 30 segundos
- Liste informações de forma clara e escaneável
- Forneça feedback visual constante
- Siga padrões de design mobile modernos
- Seja acessível e fácil de usar

---

## 📞 **INFORMAÇÕES ADICIONAIS**

### Estrutura do APK
- **Package**: com.sistemachamados.mobile
- **Versão**: 1.0
- **Tamanho**: ~63 MB
- **Localização**: `c:\Users\opera\sistema-chamados-faculdade\APK\SistemaChamados-v1.0.apk`

### Credenciais de Teste
- Arquivo: `CREDENCIAIS_TESTE.md`

### Scripts Úteis
- `GerarAPK.ps1` - Gera novo APK
- `IniciarAPIMobile.ps1` - Inicia API para mobile

---

**Documentação criada em**: 20/10/2025  
**Versão do app**: 1.0  
**Framework**: .NET MAUI 8.0  
**Plataforma**: Android

---

## 🤝 **PARA A IA QUE VAI MELHORAR O UI/UX**

**Use este documento como base para:**
1. Entender a estrutura atual
2. Identificar todos os arquivos que precisam ser editados
3. Manter consistência com o código existente
4. Propor melhorias alinhadas com as personas
5. Implementar usando .NET MAUI + XAML

**Boa sorte! 🚀**
