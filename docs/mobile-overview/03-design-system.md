# 🎨 Design System - Aplicativo Mobile

## 🎨 Paleta de Cores

### **Cores Primárias**

```xml
<!-- Primary (Azul Principal) -->
<Color x:Key="Primary">#2A5FDF</Color>
```
- **Uso**: Botões principais, headers, links, elementos interativos
- **Exemplo**: Botão "Entrar", headers com gradiente

```xml
<!-- Primary Dark (Azul Escuro) -->
<Color x:Key="PrimaryDark">#1E47BB</Color>
```
- **Uso**: Hover states, versões mais escuras de elementos primary

```xml
<!-- Primary Dark Text -->
<Color x:Key="PrimaryDarkText">#0D2348</Color>
```
- **Uso**: Títulos, textos importantes sobre fundos claros

### **Cores Secundárias**

```xml
<!-- Secondary (Azul Claro) -->
<Color x:Key="Secondary">#D4F0FF</Color>
```
- **Uso**: Backgrounds de badges, áreas de destaque suave, cards secundários

```xml
<!-- Secondary Dark Text -->
<Color x:Key="SecondaryDarkText">#123A58</Color>
```
- **Uso**: Textos sobre backgrounds secundários

```xml
<!-- Tertiary -->
<Color x:Key="Tertiary">#164A85</Color>
```
- **Uso**: Elementos terciários, variações

---

### **Cores de Status** 🚦

```xml
<!-- Success (Verde) -->
<Color x:Key="Success">#10B981</Color>
```
- **Uso**: Chamados encerrados, mensagens de sucesso, confirmações
- **Exemplo**: Badge "✅ Encerrado: dd/mm/yyyy"

```xml
<!-- Warning (Laranja) -->
<Color x:Key="Warning">#F59E0B</Color>
```
- **Uso**: Avisos, prioridade média, chamadas de atenção

```xml
<!-- Danger (Vermelho) -->
<Color x:Key="Danger">#EF4444</Color>
```
- **Uso**: Erros, exclusões, prioridade crítica, ações destrutivas

---

### **Escala de Cinzas** (Neutros)

```xml
<Color x:Key="Gray100">#F5F8FB</Color>  <!-- Muito claro -->
<Color x:Key="Gray200">#E3E9F3</Color>  <!-- Bordas suaves -->
<Color x:Key="Gray300">#C4CDDE</Color>  <!-- Bordas médias -->
<Color x:Key="Gray400">#8C9AB6</Color>  <!-- Placeholders -->
<Color x:Key="Gray500">#546687</Color>  <!-- Texto secundário -->
<Color x:Key="Gray600">#3B4B68</Color>  <!-- Texto terciário -->
<Color x:Key="Gray800">#22304A</Color>  <!-- Texto escuro -->
<Color x:Key="Gray900">#1D2939</Color>  <!-- Quase preto -->
<Color x:Key="Gray950">#0F172A</Color>  <!-- Black alt -->
```

**Mapeamento de Uso:**
- **Gray100-200**: Backgrounds, bordas suaves
- **Gray300-400**: Separadores, placeholders
- **Gray500-600**: Texto secundário, labels
- **Gray800-950**: Texto principal

---

### **Cores Base**

```xml
<Color x:Key="White">#FFFFFF</Color>
<Color x:Key="Black">#0F172A</Color>
<Color x:Key="OffBlack">#111827</Color>
```

---

## 🖌️ Brushes (Para XAML)

```xml
<!-- Sólidas -->
<SolidColorBrush x:Key="PrimaryBrush" Color="{StaticResource Primary}"/>
<SolidColorBrush x:Key="SecondaryBrush" Color="{StaticResource Secondary}"/>
<SolidColorBrush x:Key="WhiteBrush" Color="{StaticResource White}"/>

<!-- Gradientes -->
<LinearGradientBrush x:Key="HeaderGradient" StartPoint="0,0" EndPoint="1,1">
  <GradientStop Color="#2A5FDF" Offset="0" />
  <GradientStop Color="#3FA5F5" Offset="1" />
</LinearGradientBrush>
```

**Uso do Gradiente:**
- Headers de telas (Login, Lista, Detalhes)
- Elementos de destaque

---

## 📝 Tipografia

### **Fonte Principal**
- **Família**: OpenSans
- **Variantes**: Regular, Bold
- **Localização**: `Resources/Fonts/`

### **Escala de Tamanhos**

| Uso | Tamanho | Peso | Exemplo |
|-----|---------|------|---------|
| **Headlines** | 32px | Bold | Títulos principais |
| **Sub-Headlines** | 24px | Bold | Subtítulos de seção |
| **Page Title** | 28px | Bold | "Novo chamado" |
| **Section Title** | 18-22px | Bold | "Descrição do problema" |
| **Body Large** | 16px | Regular | Texto principal grande |
| **Body** | 14px | Regular | Texto padrão |
| **Caption** | 13px | Regular | Legendas |
| **Small** | 12px | Regular | Textos pequenos |

### **Estilos XAML Definidos**

```xml
<!-- Headline -->
<Style TargetType="Label" x:Key="Headline">
  <Setter Property="FontSize" Value="32" />
  <Setter Property="FontAttributes" Value="Bold" />
  <Setter Property="TextColor" Value="{StaticResource PrimaryDarkText}" />
</Style>

<!-- SubHeadline -->
<Style TargetType="Label" x:Key="SubHeadline">
  <Setter Property="FontSize" Value="24" />
  <Setter Property="TextColor" Value="{StaticResource Primary}" />
</Style>
```

---

## 📏 Espaçamentos

### **Padding de Páginas**
- **Padrão**: 24px
- **Mínimo**: 16px
- **Máximo**: 32px

### **Spacing Entre Elementos**

| Contexto | Espaçamento |
|----------|-------------|
| Elementos relacionados (tight) | 8px |
| Elementos relacionados (normal) | 12px |
| Entre grupos | 16px |
| Entre seções | 20-24px |
| Entre seções principais | 28-32px |

### **Margin de Cards**
- **Bottom**: 16px (entre cards)
- **Horizontal**: 0 (full width)

---

## 🔲 Border Radius

### **Escala de Arredondamento**

| Componente | Radius | Uso |
|------------|--------|-----|
| **Pequeno** | 8-12px | Botões pequenos, badges |
| **Médio** | 16-18px | Form fields, inputs |
| **Grande** | 20-24px | Cards, frames |
| **Extra Grande** | 28px | Headers, elementos de destaque |

### **Exemplos por Componente**
- **Botões**: 8-12px
- **Entry/Editor**: 16-18px
- **Cards de Chamado**: 20px
- **Header com Gradiente**: 28px
- **Badges/Tags**: 12px

---

## 🧩 Componentes Visuais

### 1. **Gradientes**

```xml
<!-- Header Gradient (Azul Diagonal) -->
<LinearGradientBrush x:Key="ListHeaderGradient" StartPoint="0,0" EndPoint="1,1">
  <GradientStop Color="#2A5FDF" Offset="0" />
  <GradientStop Color="#3FA5F5" Offset="1" />
</LinearGradientBrush>
```

**Onde usar:**
- Headers de telas
- Botões de destaque (opcional)
- Splash screen (opcional)

---

### 2. **Cards de Chamados**

```xml
<Style x:Key="ChamadoCardStyle" TargetType="Border">
  <Setter Property="StrokeShape" Value="RoundRectangle 20" />
  <Setter Property="StrokeThickness" Value="1" />
  <Setter Property="Stroke" Value="{StaticResource Gray200Brush}" />
  <Setter Property="BackgroundColor" Value="{StaticResource White}" />
  <Setter Property="Padding" Value="18" />
  <Setter Property="Margin" Value="0,0,0,16" />
</Style>
```

**Anatomia do Card:**
- Border arredondado (20px)
- Borda sutil (Gray200, 1px)
- Padding interno: 18px
- Margin bottom: 16px
- Background: Branco

**Estrutura interna:**
```
┌──────────────────────────────┐
│ Título (Bold, 18px)          │
│ [Badge Status] [Badge Prior.] │
│ Categoria                     │
│ Criado por: Nome              │
│ 📅 dd/mm/yyyy HH:mm           │
│ ✅ Encerrado: dd/mm/yyyy      │ (se aplicável)
└──────────────────────────────┘
```

---

### 3. **Badges/Tags**

```xml
<Style x:Key="TagBorderStyle" TargetType="Border">
  <Setter Property="StrokeShape" Value="RoundRectangle 12" />
  <Setter Property="Padding" Value="10,4" />
  <Setter Property="BackgroundColor" Value="{StaticResource Secondary}" />
  <Setter Property="StrokeThickness" Value="0" />
</Style>
```

**Variantes:**

**Badge de Status (Filled):**
- Background: Secondary (#D4F0FF)
- Text: PrimaryDarkText
- Border: Nenhuma

**Badge de Prioridade (Outline):**
- Background: Transparent
- Text: Primary
- Border: Primary (1px)

**Badge de Encerramento:**
- Background: Transparent
- Text: Success (#10B981)
- Bold

---

### 4. **Botões**

```xml
<Style TargetType="Button">
  <Setter Property="BackgroundColor" Value="{StaticResource Primary}" />
  <Setter Property="TextColor" Value="{StaticResource White}" />
  <Setter Property="CornerRadius" Value="8" />
  <Setter Property="Padding" Value="14,10" />
  <Setter Property="MinimumHeightRequest" Value="44" />
  <Setter Property="FontSize" Value="14" />
</Style>
```

**Estados:**
- **Normal**: Primary background, White text
- **Disabled**: Gray200 background, Gray400 text
- **Pressed**: PrimaryDark background (hover)

**Variantes:**

**Botão Primário (Ação Principal):**
```xml
<Button Text="Entrar"
        BackgroundColor="{StaticResource Primary}"
        HeightRequest="52" />
```

**Botão Secundário:**
```xml
<Button Text="Limpar filtros"
        BackgroundColor="Transparent"
        TextColor="{StaticResource Primary}"
        BorderColor="{StaticResource Primary}"
        BorderWidth="1" />
```

---

### 5. **Form Fields**

```xml
<Style x:Key="FormBorderStyle" TargetType="Border">
  <Setter Property="StrokeShape" Value="RoundRectangle 18" />
  <Setter Property="StrokeThickness" Value="1" />
  <Setter Property="Stroke" Value="{StaticResource Gray200Brush}" />
  <Setter Property="BackgroundColor" Value="{StaticResource White}" />
  <Setter Property="Padding" Value="16,14" />
  <Setter Property="Margin" Value="0,8,0,0" />
</Style>
```

**Anatomia:**
- Border arredondado (18px)
- Borda: Gray200 (1px)
- Background: White
- Padding: 16px horizontal, 14px vertical

**Componentes Internos:**

**Entry (Input de uma linha):**
```xml
<Entry Placeholder="Email institucional"
       PlaceholderColor="{StaticResource Gray400}"
       TextColor="{StaticResource Gray900}" />
```

**Editor (Textarea):**
```xml
<Editor Placeholder="Descreva o problema"
        MinimumHeightRequest="160"
        AutoSize="TextChanges" />
```

**Picker (Dropdown):**
```xml
<Picker Title="Selecione uma categoria"
        TitleColor="{StaticResource Gray400}"
        ItemsSource="{Binding Categorias}"
        ItemDisplayBinding="{Binding Nome}" />
```

---

### 6. **Headers com Gradiente**

```xml
<Border Background="{StaticResource HeaderGradient}"
        StrokeShape="RoundRectangle 28"
        StrokeThickness="0"
        Padding="22">
  <VerticalStackLayout Spacing="4">
    <Label Text="Chamados em andamento"
           FontSize="24"
           FontAttributes="Bold"
           TextColor="{StaticResource White}" />
    <Label Text="Acompanhe as atualizações..."
           TextColor="{StaticResource White}" />
  </VerticalStackLayout>
</Border>
```

---

## 📐 Diretrizes de Uso

### **Hierarquia Visual**

1. **Headers/Titles**: Primary/PrimaryDarkText, Bold, 24-32px
2. **Section Titles**: PrimaryDarkText, Bold, 18-22px
3. **Body Text**: Gray900/Black, Regular, 14px
4. **Secondary Text**: Gray500-600, Regular, 13-14px
5. **Captions**: Gray400-500, Regular, 12px

### **Contraste**

**Textos sobre fundos claros:**
- Texto principal: Gray900 ou Black
- Texto secundário: Gray500-600

**Textos sobre Primary (azul):**
- Sempre White

**Textos sobre Secondary (azul claro):**
- PrimaryDarkText ou PrimaryDark

### **Acessibilidade**

- **Contraste mínimo**: 4.5:1 para texto normal
- **Tamanho mínimo de texto**: 14px (12px para captions)
- **Tamanho mínimo de toque**: 44x44dp

---

## 🎨 Esquema de Cores por Contexto

### **Prioridades de Chamado**

| Prioridade | Cor | Hex |
|------------|-----|-----|
| **Baixa** | Gray400 | #8C9AB6 |
| **Média** | Warning | #F59E0B |
| **Alta** | Primary | #2A5FDF |
| **Crítica** | Danger | #EF4444 |

### **Status de Chamado**

| Status | Cor | Hex |
|--------|-----|-----|
| **Aberto** | Primary | #2A5FDF |
| **Em Andamento** | Warning | #F59E0B |
| **Aguardando** | Gray500 | #546687 |
| **Encerrado** | Success | #10B981 |

---

## 📦 Como Usar no Código

### **Referenciando Cores:**

```xml
<!-- Static Resource -->
<Label TextColor="{StaticResource Primary}" />

<!-- Dynamic Resource (para theme switching) -->
<Label TextColor="{DynamicResource Primary}" />

<!-- AppThemeBinding (Light/Dark mode) -->
<Label TextColor="{AppThemeBinding 
  Light={StaticResource PrimaryDarkText}, 
  Dark={StaticResource White}}" />
```

### **Referenciando Estilos:**

```xml
<!-- Estilo global -->
<Button Text="Entrar" />  <!-- Usa estilo padrão de Button -->

<!-- Estilo customizado -->
<Label Text="Título" Style="{StaticResource Headline}" />

<!-- Estilo inline -->
<Button Text="Especial"
        BackgroundColor="{StaticResource Success}"
        CornerRadius="16" />
```

---

**Documento**: 03 - Design System  
**Data**: 20/10/2025  
**Versão**: 1.0
