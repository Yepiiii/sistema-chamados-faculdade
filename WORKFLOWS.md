# 🚀 WORKFLOWS - Sistema de Chamados

**Guia rápido de execução de tarefas comuns**

---

## 📋 ÍNDICE

1. [Mobile - APK Android](#mobile---apk-android)
2. [API - Backend](#api---backend)
3. [Database - Banco de Dados](#database---banco-de-dados)
4. [Testes](#testes)
5. [Desenvolvimento](#desenvolvimento)

---

## 📱 MOBILE - APK ANDROID

### 🔧 Gerar APK para Dispositivo Físico

**Workflow Completo (3 passos):**

```powershell
# 1. Configurar IP da rede Wi-Fi
.\Scripts\Mobile\ConfigurarIP.ps1

# 2. Gerar APK
.\Scripts\Mobile\GerarAPK.ps1

# 3. Iniciar API (em terminal separado)
.\Scripts\API\IniciarAPI.ps1
```

**O que cada script faz:**

1. **ConfigurarIP.ps1**
   - Detecta automaticamente o IP da sua rede Wi-Fi
   - Filtra IPs virtuais (VirtualBox, VMware)
   - Atualiza `Mobile/Helpers/Constants.cs`
   - Valida se o IP é adequado para uso com dispositivo físico

2. **GerarAPK.ps1**
   - Limpa builds anteriores
   - Restaura pacotes NuGet
   - Compila APK em modo Release
   - Copia APK para `Mobile/bin/Release/net8.0-android/`
   - Mostra tamanho e localização do APK

3. **IniciarAPI.ps1**
   - Detecta IP da rede automaticamente
   - Configura binding em `0.0.0.0:5246` (aceita conexões externas)
   - Mostra URLs de acesso (localhost + rede)
   - Verifica e cria regra de firewall automaticamente
   - Inicia API em nova janela

### 📥 Instalar APK

**Método 1 - Via ADB (cabo USB):**
```powershell
adb install "Mobile\bin\Release\net8.0-android\com.sistemachamados.mobile-Signed.apk"
```

**Método 2 - Manual:**
1. Envie o APK para o celular (WhatsApp, email, etc.)
2. Abra o APK no celular
3. Permita instalação de fontes desconhecidas
4. Instale

### ✅ Testar Conectividade

**No navegador do celular:**
```
http://192.168.1.XXX:5246/api/categorias
```
(Substitua XXX pelo IP detectado)

Se retornar JSON = ✅ OK!  
Se der erro = ❌ Problema de rede/firewall

---

## 🔌 API - BACKEND

### 🚀 Iniciar API

```powershell
.\Scripts\API\IniciarAPI.ps1
```

**O que faz:**
- Para processos antigos da API
- Detecta IP da rede Wi-Fi automaticamente
- Configura firewall (se executado como Admin)
- Inicia API com binding em todas as interfaces (`0.0.0.0:5246`)
- Testa conectividade (localhost + rede)
- Mostra URLs de acesso

**Endpoints disponíveis:**
- **Localhost:** `http://localhost:5246`
- **Rede:** `http://192.168.1.XXX:5246`
- **Swagger:** `http://localhost:5246/swagger`

### 🔥 Configurar Firewall (Windows)

```powershell
# Execute como Administrador
.\Scripts\API\ConfigurarFirewall.ps1
```

**O que faz:**
- Remove regras antigas (se existirem)
- Cria regra de entrada (Inbound) na porta 5246
- Cria regra de saída (Outbound) na porta 5246
- Permite acesso de dispositivos na rede local

---

## 💾 DATABASE - BANCO DE DADOS

### 🏗️ Inicializar Banco

```powershell
.\Scripts\Database\InicializarBanco.ps1
```

**O que faz:**
- Verifica SQL Server LocalDB
- Deleta banco existente (se solicitado)
- Aplica migrations
- Cria dados seed (Categorias, Prioridades, Status)
- Cria usuário admin padrão

**Credenciais criadas:**
- **Email:** admin@teste.com
- **Senha:** Admin123!
- **Tipo:** Administrador (TipoUsuario=3)

### 📊 Analisar Banco

```powershell
.\Scripts\Database\AnalisarBanco.ps1
```

**O que mostra:**
- Lista de todas as tabelas
- Contagem de registros por tabela
- Total de chamados, usuários, categorias, etc.

### 🧹 Limpar Chamados

```powershell
.\Scripts\Database\LimparChamados.ps1
```

**O que faz:**
- Deleta todos os chamados e históricos
- Mantém usuários, categorias, prioridades e status
- Confirma antes de executar

---

## 🧪 TESTES

### 🔍 Testar API

```powershell
.\Scripts\Teste\TestarAPI.ps1
```

**O que testa:**
- GET /api/categorias
- GET /api/prioridades
- GET /api/status
- POST /api/auth/login
- POST /api/chamados (criar chamado)
- GET /api/chamados (listar chamados)

### 🤖 Testar Gemini AI

```powershell
.\Scripts\Teste\TestarGemini.ps1
```

**O que testa:**
- Geração de título por IA
- Geração de solução por IA
- Análise de descrição de problema
- Integração com Google Gemini API

**Pré-requisito:**
- Chave API configurada em `appsettings.json`:
```json
{
  "GeminiSettings": {
    "ApiKey": "SUA_CHAVE_AQUI"
  }
}
```

### 📱 Testar Mobile

```powershell
.\Scripts\Teste\TestarMobile.ps1
```

**O que testa:**
- Conectividade API → Mobile
- Acesso a endpoints de rede
- Configuração de IP em Constants.cs

---

## 👨‍💻 DESENVOLVIMENTO

### 🔧 Reorganizar Projeto

```powershell
.\Scripts\Dev\ReorganizarProjeto.ps1
```

**O que faz:**
- Organiza estrutura de pastas
- Move arquivos para locais corretos
- Limpa arquivos temporários
- Atualiza referências

---

## 📁 ESTRUTURA DE SCRIPTS

```
Scripts/
├── API/
│   ├── ConfigurarFirewall.ps1  # Configura firewall Windows
│   └── IniciarAPI.ps1           # Inicia API com rede habilitada
│
├── Mobile/
│   ├── ConfigurarIP.ps1         # Detecta e configura IP Wi-Fi
│   └── GerarAPK.ps1             # Compila APK Android
│
├── Database/
│   ├── InicializarBanco.ps1     # Cria e popula banco
│   ├── AnalisarBanco.ps1        # Mostra estatísticas
│   └── LimparChamados.ps1       # Remove chamados
│
├── Teste/
│   ├── TestarAPI.ps1            # Testa endpoints
│   ├── TestarGemini.ps1         # Testa IA
│   └── TestarMobile.ps1         # Testa conectividade
│
└── Dev/
    └── ReorganizarProjeto.ps1   # Organiza estrutura

_Backup/                         # Backup automático dos scripts
```

---

## 🔄 WORKFLOWS COMUNS

### 🆕 Novo Desenvolvedor - Setup Inicial

```powershell
# 1. Inicializar banco de dados
.\Scripts\Database\InicializarBanco.ps1

# 2. Testar API
.\Scripts\API\IniciarAPI.ps1

# 3. Configurar Firewall (como Admin)
.\Scripts\API\ConfigurarFirewall.ps1

# 4. Configurar IP para Mobile
.\Scripts\Mobile\ConfigurarIP.ps1

# 5. Gerar APK
.\Scripts\Mobile\GerarAPK.ps1
```

### 📱 Gerar e Testar APK Completo

```powershell
# Terminal 1 - API
.\Scripts\API\IniciarAPI.ps1

# Terminal 2 - Mobile
.\Scripts\Mobile\ConfigurarIP.ps1
.\Scripts\Mobile\GerarAPK.ps1

# No celular
# 1. Instalar APK
# 2. Abrir app
# 3. Login: admin@teste.com / Admin123!
```

### 🧪 Ciclo de Desenvolvimento

```powershell
# 1. Fazer alterações no código

# 2. Limpar dados de teste
.\Scripts\Database\LimparChamados.ps1

# 3. Testar API
.\Scripts\Teste\TestarAPI.ps1

# 4. Testar Gemini
.\Scripts\Teste\TestarGemini.ps1

# 5. Regenerar APK
.\Scripts\Mobile\GerarAPK.ps1
```

---

## ⚙️ CONFIGURAÇÕES IMPORTANTES

### 📡 IP da Rede

Os scripts detectam automaticamente, mas você pode verificar:

```powershell
ipconfig
```

Procure por **"Adaptador de Rede sem Fio Wi-Fi"** e copie o **IPv4**.

### 🔥 Porta do Firewall

- **Porta:** 5246
- **Protocolo:** TCP
- **Direção:** Entrada (Inbound)

### 📱 Credenciais de Teste

```
Admin:
  Email: admin@teste.com
  Senha: Admin123!
  Tipo: 3 (Administrador)
```

---

## 🐛 TROUBLESHOOTING

### ❌ "Connection Failure" no APK

**Causas:**
1. Firewall bloqueando porta 5246
2. PC e celular em redes WiFi diferentes
3. IP configurado incorretamente
4. API não está rodando

**Soluções:**
```powershell
# 1. Configurar Firewall (como Admin)
.\Scripts\API\ConfigurarFirewall.ps1

# 2. Reconfigurar IP
.\Scripts\Mobile\ConfigurarIP.ps1

# 3. Gerar novo APK
.\Scripts\Mobile\GerarAPK.ps1

# 4. Iniciar API
.\Scripts\API\IniciarAPI.ps1

# 5. Testar no navegador do celular
# http://192.168.1.XXX:5246/api/categorias
```

### ❌ "APK não funciona no celular"

1. Desinstale o APK antigo
2. Verifique se PC e celular estão na mesma rede
3. Teste a URL no navegador do celular primeiro
4. Se funcionar no navegador mas não no app → Regenere o APK

### ❌ "Banco de dados não inicializa"

```powershell
# Deletar banco e recriar
.\Scripts\Database\InicializarBanco.ps1

# Quando perguntar, escolha: s (para deletar)
```

---

## 📚 DOCUMENTAÇÃO ADICIONAL

- **GUIA_INSTALACAO_APK.md** - Guia detalhado de instalação do APK
- **PLANO_REORGANIZACAO_SCRIPTS.md** - Detalhes da reorganização
- **README.md** - Documentação geral do projeto

---

**✨ Dica:** Execute sempre como **Administrador** quando for configurar Firewall!

**🔄 Backup:** Todos os scripts antigos estão em `Scripts/_Backup/` para recuperação se necessário.

