# 📱 Sistema de Chamados - Mobile App

## ✅ STATUS: FUNCIONAL - Build Limpo

```bash
cd SistemaChamados.Mobile
dotnet build -f net8.0-windows10.0.19041.0
# ✅ Resultado: 0 Erros
```

---

## ⚠️ IMPORTANTE: Sobre os "Erros"

### 1. **IntelliSense do VS Code** (51 problemas)
- ❌ **FALSOS POSITIVOS** - Pode ignorar!
- O IntelliSense não entende projetos MAUI multi-target
- O código compila perfeitamente

### 2. **Build da Solução** (sistema-chamados-faculdade.sln)
- ❌ **NÃO USE** `dotnet run` na solução
- A solução inclui API + Mobile
- O MSBuild tenta compilar ambos juntos e falha
- **SOLUÇÃO:** Compile os projetos separadamente

---

## 🚀 Como Executar (3 Métodos)

### **Método 1: Script Automático** ⭐ RECOMENDADO

```powershell
# Inicia API e Mobile automaticamente
.\IniciarSistema.ps1

# Para Android
.\IniciarSistema.ps1 -Plataforma android
```

---

### **Método 2: Manual (2 Terminais)**

**Terminal 1 - API:**
```powershell
dotnet run --project SistemaChamados.csproj --urls http://localhost:5246
```

**Terminal 2 - Mobile:**
```powershell
cd SistemaChamados.Mobile
dotnet build -t:Run -f net8.0-windows10.0.19041.0
```

---

### **Método 3: Somente Build (sem executar)**

```powershell
# Build completo de todas as plataformas
cd SistemaChamados.Mobile
dotnet build

# Build específico
dotnet build -f net8.0-windows10.0.19041.0  # Windows
dotnet build -f net8.0-android               # Android
dotnet build -f net8.0-ios                   # iOS
```

---

## 🔧 Pré-requisitos

### Já instalado ✅
- .NET 9.0 SDK
- Workloads MAUI (android, ios, maccatalyst, maui-windows)

### Necessário para Android
- Android SDK
- Emulador Android criado
- OU dispositivo físico conectado

---

## 📝 Configuração de Rede

### Windows / iOS / Mac
```json
// appsettings.json
{
  "BaseUrl": "http://localhost:5246/api/"
}
```

### Android Emulator
```json
// appsettings.json
{
  "BaseUrl": "http://10.0.2.2:5246/api/"
}
```
*`10.0.2.2` é o IP especial que aponta para `localhost` do PC*

### Android Dispositivo Físico
```json
// appsettings.json
{
  "BaseUrl": "http://192.168.X.X:5246/api/"
}
```
*Use o IP local do seu PC (descubra com `ipconfig`)*

---

## 🐛 Troubleshooting

### "Cannot connect to API"
```powershell
# 1. Verificar se API está rodando
curl http://localhost:5246/api/categorias

# 2. Verificar se está usando IP correto no appsettings.json
# 3. Verificar firewall do Windows
```

### "Build failed" ao usar dotnet run
```powershell
# ❌ NÃO FAÇA ISSO:
dotnet run  # Na raiz (compila solução inteira)

# ✅ FAÇA ISSO:
dotnet run --project SistemaChamados.csproj  # API
cd SistemaChamados.Mobile
dotnet build -t:Run -f net8.0-windows10.0.19041.0  # Mobile
```

### IntelliSense cheio de erros vermelhos
```
✅ ISSO É NORMAL!
- O build funciona (0 erros)
- IntelliSense do VS Code não entende MAUI
- Pode ignorar os erros do editor
```

---

## 📚 Estrutura do Projeto

```
SistemaChamados.Mobile/
├── MauiProgram.cs           # DI e configuração
├── App.xaml                 # App principal
├── AppShell.xaml            # Navegação
├── appsettings.json         # ⚠️ Configure o BaseUrl aqui!
├── Helpers/
├── Models/
├── Services/
│   ├── Auth/                # Login/Logout
│   └── Api/                 # HTTP Client
├── ViewModels/              # MVVM
└── Views/                   # Telas XAML
```

---

## ✅ Funcionalidades

- ✅ Login/Logout com JWT
- ✅ Listar chamados
- ✅ Ver detalhes
- ✅ Criar novo chamado
- ✅ Seleção de categoria/prioridade
- ✅ Pull-to-refresh
- ✅ Navegação Shell

---

## 🎯 Comandos Rápidos

```powershell
# Verificar build
cd SistemaChamados.Mobile
dotnet build

# Executar no Windows
dotnet build -t:Run -f net8.0-windows10.0.19041.0

# Executar no Android
dotnet build -t:Run -f net8.0-android

# Limpar build
dotnet clean
```

---

## 📖 Documentação Adicional

- [](docs/Mobile/ComoTestar.md) - Guia completo
- [](docs/Mobile/README.md) - Status do projeto
- [](Scripts/API/IniciarAPI.ps1) - Script automático

---

## 🎉 Pronto para usar!

Execute o script e teste:
```powershell
.\IniciarSistema.ps1
```
