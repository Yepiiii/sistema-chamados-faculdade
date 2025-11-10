# 📱 APK - Sistema de Chamados Mobile (Integração GuiNRB)

**Versão:** 1.0  
**Data de Build:** 10/11/2025  
**Plataforma:** Android (net8.0-android)  
**Backend:** GuiNRB (porta 5246)

---

## 📦 Arquivo APK

**Nome:** `SistemaChamados-GuiNRB-v1.0.apk`  
**Tamanho:** ~65 MB  
**Assinado:** ✅ Sim (Debug)  
**Package ID:** com.sistemachamados.mobile

---

## 🔧 Configurações do APK

### Backend API:
```
Dispositivo Físico: http://192.168.56.1:5246/api/
Emulador Android:   http://10.0.2.2:5246/api/
Windows Desktop:    http://localhost:5246/api/
```

### Restrições:
- ✅ Apenas usuários TipoUsuario = 1 podem fazer login
- ❌ Admin (tipo 3) e Técnico (tipo 2) são bloqueados

---

## 📥 Como Instalar

### 1. Transferir APK para o Dispositivo Android

**Opção A - Via USB:**
```powershell
# Conectar dispositivo via USB
# Copiar APK para o dispositivo
adb push SistemaChamados-GuiNRB-v1.0.apk /sdcard/Download/
```

**Opção B - Via Email/Drive:**
1. Enviar APK por email ou upload para Google Drive
2. Baixar no dispositivo Android

**Opção C - Via Servidor Web Local:**
```powershell
# Na pasta APK, iniciar servidor HTTP
python -m http.server 8000
# Acessar do dispositivo: http://IP_DO_PC:8000
```

### 2. Habilitar Instalação de Fontes Desconhecidas

1. Abrir **Configurações** > **Segurança**
2. Ativar **Fontes Desconhecidas** ou **Instalar apps desconhecidos**
3. Permitir instalação do navegador/gerenciador de arquivos

### 3. Instalar o APK

1. Abrir gerenciador de arquivos
2. Navegar até a pasta **Download**
3. Tocar em `SistemaChamados-GuiNRB-v1.0.apk`
4. Confirmar instalação
5. Aguardar conclusão

---

## 🚀 Primeiro Uso

### 1. Iniciar Backend GuiNRB

**No PC (onde está o backend):**

```powershell
cd "C:\Users\opera\OneDrive\Área de Trabalho\SistemaChamados-GuiNRB-Mobile\backend-guinrb\Backend"
dotnet run --project SistemaChamados.csproj
```

**Aguardar mensagem:**
```
Now listening on: http://localhost:5246
```

### 2. Verificar Conectividade

**Confirmar IP do PC:**
```powershell
ipconfig
# Procurar IPv4 (ex: 192.168.56.1)
```

**Testar conexão do dispositivo:**
- Abrir navegador no Android
- Acessar: `http://192.168.56.1:5246/swagger`
- Deve abrir a documentação da API

### 3. Fazer Login no App

**Abrir aplicativo e fazer login:**

```
Email: usuario@teste.com
Senha: senha123
```

**Ou criar nova conta:**
1. Tocar em "Criar conta"
2. Preencher dados
3. Fazer login

---

## 👤 Usuários de Teste

### Usuário Comum (Nível 1) ✅
```
Email: usuario@teste.com
Senha: senha123
Tipo: 1 (Usuário Comum)
Status: Pode acessar o mobile
```

### Admin (Nível 3) ❌
```
Email: admin@helpdesk.com
Senha: senha123
Tipo: 3 (Admin)
Status: BLOQUEADO no mobile
```

---

## ⚠️ Troubleshooting

### Problema: "Não foi possível conectar ao servidor"

**Causas possíveis:**
1. Backend não está rodando
2. IP incorreto
3. Firewall bloqueando porta 5246
4. Dispositivo em rede diferente do PC

**Soluções:**

**1. Verificar Backend:**
```powershell
# Verificar se backend está rodando
Get-NetTCPConnection -LocalPort 5246
```

**2. Verificar IP:**
```powershell
# Confirmar IP do PC
ipconfig
# Atualizar Constants.cs se necessário
```

**3. Configurar Firewall:**
```powershell
# Permitir porta 5246 no Windows Firewall
New-NetFirewallRule -DisplayName "Sistema Chamados API" -Direction Inbound -LocalPort 5246 -Protocol TCP -Action Allow
```

**4. Verificar Rede:**
- PC e dispositivo devem estar na mesma rede Wi-Fi
- Não usar VPN ou redes corporativas que bloqueiem portas

### Problema: "Apenas usuários comuns podem acessar"

**Causa:** Tentando fazer login com admin ou técnico

**Solução:** Usar credenciais de usuário nível 1 ou criar nova conta

### Problema: APK não instala

**Causas possíveis:**
1. Fontes desconhecidas não habilitadas
2. APK corrompido
3. Versão Android incompatível

**Soluções:**
1. Habilitar fontes desconhecidas nas configurações
2. Baixar APK novamente
3. Verificar se Android é 5.0+ (API 21+)

---

## 📊 Funcionalidades Disponíveis

### ✅ Implementadas:

- **Autenticação:**
  - Login
  - Cadastro
  - Recuperação de senha
  - Logout

- **Dashboard:**
  - Total de chamados
  - Chamados abertos
  - Chamados em andamento
  - Chamados resolvidos
  - Gráficos e estatísticas

- **Chamados:**
  - Listar chamados
  - Criar novo chamado
  - Visualizar detalhes
  - Adicionar comentários
  - Filtrar por status

- **Perfil:**
  - Visualizar dados do usuário
  - Editar informações

---

## 🔄 Atualização do APK

Para atualizar para nova versão:

1. Desinstalar versão antiga (opcional)
2. Instalar novo APK
3. Fazer login novamente

**Ou:**
1. Instalar novo APK sobre o antigo
2. Aceitar atualização

---

## 📝 Notas Técnicas

### Requisitos:
- **Android:** 5.0+ (API 21+)
- **Espaço:** ~100 MB
- **Permissões:**
  - Internet
  - Armazenamento (para cache)

### Tecnologias:
- **.NET MAUI** 8.0
- **Target:** net8.0-android
- **Build:** Release
- **Signing:** Debug key

### APIs Backend Utilizadas:
- `/api/usuarios/login` - Login
- `/api/usuarios/registrar` - Cadastro
- `/api/usuarios/esqueci-senha` - Recuperação senha
- `/api/chamados` - CRUD chamados
- `/api/chamados/{id}/comentarios` - Comentários
- `/api/categorias` - Categorias
- `/api/prioridades` - Prioridades
- `/api/status` - Status

---

## 📞 Suporte

Para problemas ou dúvidas:
1. Verificar seção Troubleshooting
2. Consultar logs do backend
3. Verificar documentação em `../INTEGRACAO_MOBILE_GUINRB.md`

---

**APK gerado em:** 10/11/2025 10:53  
**Build ID:** Release-v1.0  
**Branch:** guinrb-integration
