# 🎯 APK Gerado - Sistema Chamados + Backend GuiNRB

**Data:** 10/11/2025 10:53  
**Status:** ✅ APK gerado com sucesso!

---

## 📦 Arquivos Gerados

```
APK/
├── SistemaChamados-GuiNRB-v1.0.apk    (65 MB) ✅
├── README.md                           Guia completo de instalação
├── InstalarAPK.ps1                     Script automático de instalação
└── INFORMACOES.md                      Este arquivo
```

---

## ⚡ Quick Start

### 1️⃣ Instalar APK no Dispositivo

**Método 1 - Via Script (Recomendado):**
```powershell
cd "C:\Users\opera\OneDrive\Área de Trabalho\SistemaChamados-GuiNRB-Mobile\APK"
.\InstalarAPK.ps1
```

**Método 2 - Manual:**
1. Copiar `SistemaChamados-GuiNRB-v1.0.apk` para o dispositivo
2. Habilitar fontes desconhecidas
3. Instalar APK

### 2️⃣ Iniciar Backend GuiNRB

```powershell
cd "C:\Users\opera\OneDrive\Área de Trabalho\SistemaChamados-GuiNRB-Mobile\backend-guinrb\Backend"
dotnet run --project SistemaChamados.csproj
```

Aguardar: `Now listening on: http://localhost:5246`

### 3️⃣ Fazer Login no App

```
Email: usuario@teste.com
Senha: senha123
```

---

## 🔧 Configurações do APK

### Backend URLs (já configurado):
- **Dispositivo Físico:** `http://192.168.56.1:5246/api/`
- **Emulador Android:** `http://10.0.2.2:5246/api/`
- **Windows Desktop:** `http://localhost:5246/api/`

### Restrições:
- ✅ Usuários TipoUsuario = 1 (Comum)
- ❌ Admin (tipo 3) - BLOQUEADO
- ❌ Técnico (tipo 2) - BLOQUEADO

---

## 📱 Informações Técnicas

| Propriedade | Valor |
|-------------|-------|
| **Nome** | SistemaChamados-GuiNRB-v1.0.apk |
| **Tamanho** | ~65 MB |
| **Package ID** | com.sistemachamados.mobile |
| **Versão** | 1.0 |
| **Target Framework** | net8.0-android |
| **Build Config** | Release |
| **Assinado** | ✅ Sim (Debug key) |
| **Min Android** | 5.0 (API 21) |

---

## 🚀 Funcionalidades

### ✅ Autenticação:
- Login
- Cadastro
- Recuperação de senha
- Logout

### ✅ Dashboard:
- Total de chamados
- Chamados por status
- Estatísticas
- Gráficos

### ✅ Chamados:
- Listar chamados
- Criar novo chamado
- Visualizar detalhes
- Adicionar comentários
- Filtros e busca

### ✅ Perfil:
- Dados do usuário
- Configurações

---

## 👥 Credenciais de Teste

### Usuário Comum (Acesso Permitido):
```
Email: usuario@teste.com
Senha: senha123
Tipo: 1 (Usuário Comum)
```

### Admin (Bloqueado):
```
Email: admin@helpdesk.com
Senha: senha123
Tipo: 3 (Admin)
⚠️ NÃO PODE acessar o mobile
```

---

## 📋 Checklist de Instalação

- [ ] APK copiado para dispositivo
- [ ] Fontes desconhecidas habilitadas
- [ ] APK instalado
- [ ] Backend GuiNRB rodando (porta 5246)
- [ ] IP do PC verificado (192.168.56.1)
- [ ] Dispositivo na mesma rede Wi-Fi
- [ ] Firewall permite porta 5246
- [ ] App aberto
- [ ] Login realizado

---

## ⚠️ Troubleshooting Rápido

### Erro: "Não foi possível conectar ao servidor"

**Checklist:**
1. ✅ Backend rodando? `Get-NetTCPConnection -LocalPort 5246`
2. ✅ IP correto? `ipconfig` deve mostrar 192.168.56.1
3. ✅ Mesma rede? PC e celular no mesmo Wi-Fi
4. ✅ Firewall OK? Porta 5246 liberada

**Solução rápida:**
```powershell
# Liberar porta no firewall
New-NetFirewallRule -DisplayName "API Chamados" -Direction Inbound -LocalPort 5246 -Protocol TCP -Action Allow
```

### Erro: "Apenas usuários comuns podem acessar"

**Causa:** Tentando login com admin/técnico  
**Solução:** Usar `usuario@teste.com` ou criar nova conta

---

## 📊 Comparação com Mobile GuiNRB Original

| Funcionalidade | Mobile GuiNRB | Nosso Mobile |
|----------------|---------------|--------------|
| Plataformas | Android | Android/iOS/Windows/Mac |
| Cadastro | ❌ | ✅ |
| Recuperação Senha | ❌ | ✅ |
| Comentários | ❌ | ✅ |
| Dashboard | ✅ | ✅ |
| Chamados CRUD | ✅ | ✅ |

**Vencedor:** Nosso Mobile 🏆 (83% mais completo)

---

## 🔄 Como Atualizar APK

1. Gerar novo APK:
```powershell
cd "C:\Users\opera\OneDrive\Área de Trabalho\SistemaChamados-GuiNRB-Mobile\mobile-app-nosso"
dotnet publish -f net8.0-android -c Release
```

2. Copiar novo APK:
```powershell
Copy-Item "bin\Release\net8.0-android\publish\com.sistemachamados.mobile-Signed.apk" `
    -Destination "..\APK\SistemaChamados-GuiNRB-v1.1.apk"
```

3. Instalar sobre o anterior (dados preservados)

---

## 📞 Suporte e Documentação

- **Guia Instalação:** `README.md`
- **Script Automático:** `InstalarAPK.ps1`
- **Integração Backend:** `../COMPARACAO_MOBILE_APPS.md`
- **Testes Realizados:** `../RESULTADO_TESTES.md`

---

## ✅ Status Final

| Item | Status |
|------|--------|
| APK Gerado | ✅ |
| Backend Testado | ✅ |
| Usuário Criado | ✅ |
| Documentação | ✅ |
| Script Instalação | ✅ |
| Pronto para Uso | ✅ |

---

**Build realizado em:** 10/11/2025 10:53:20  
**Branch:** guinrb-integration  
**Desenvolvido com:** .NET MAUI 8.0 + Backend GuiNRB
