# 🚀 Scripts PowerShell para APK Mobile

## 📋 Visão Geral

Este conjunto de scripts automatiza todo o processo de preparação, geração e execução da API para uso com o APK mobile Android.

---

## 📦 Scripts Disponíveis

### 1. **WorkflowAPK.ps1** ⭐ (Recomendado)
Script master que executa todo o workflow automaticamente.

**Uso:**
```powershell
# Executar workflow completo (validar + gerar + iniciar)
.\WorkflowAPK.ps1

# Ou especificar uma ação:
.\WorkflowAPK.ps1 -Acao validar    # Apenas validar
.\WorkflowAPK.ps1 -Acao gerar      # Apenas gerar APK
.\WorkflowAPK.ps1 -Acao iniciar    # Apenas iniciar API
.\WorkflowAPK.ps1 -Acao tudo       # Tudo (padrão)
```

**O que faz:**
1. ✅ Valida configuração
2. ✅ Gera APK (se necessário)
3. ✅ Inicia API para mobile

---

### 2. **ValidarConfigAPK.ps1**
Verifica se tudo está configurado corretamente.

**Uso:**
```powershell
.\ValidarConfigAPK.ps1
```

**Verifica:**
- ✅ Existência do APK
- ✅ IP da rede local
- ✅ Constants.cs com IP correto
- ✅ Regra de firewall
- ✅ Compilação da API
- ✅ Banco de dados
- ✅ Porta 5246 disponível
- ✅ Scripts de setup

**Retorna:**
- Código 0 se OK
- Código 1 se erros encontrados

---

### 3. **GerarAPK.ps1**
Compila e gera o APK Android.

**Uso:**
```powershell
.\GerarAPK.ps1
```

**Processo:**
1. ✅ Limpa build anterior
2. ✅ Restaura pacotes
3. ✅ Compila para Android (Release)
4. ✅ Copia APK para pasta `APK/`
5. ✅ Exibe informações do APK

**Saída:**
- APK em: `c:\Users\opera\sistema-chamados-faculdade\APK\SistemaChamados-v1.0.apk`

---

### 4. **IniciarAPIMobile.ps1**
Inicia a API configurada para aceitar conexões de dispositivos móveis.

**Uso:**
```powershell
.\IniciarAPIMobile.ps1
```

**O que faz:**
1. ✅ Detecta IP da rede local automaticamente
2. ✅ Configura regra de firewall (se necessário)
3. ✅ Verifica banco de dados
4. ✅ Compila API
5. ✅ Inicia API em `http://0.0.0.0:5246` (aceita conexões externas)
6. ✅ Exibe informações de conexão

**Informações exibidas:**
- URL da API
- Link do Swagger
- Credenciais de teste
- Checklist para usar APK

---

## 🎯 Fluxos de Uso

### Primeira Vez (Setup Completo)

```powershell
# 1. Executar workflow completo
.\WorkflowAPK.ps1

# O script irá:
# - Validar configuração
# - Gerar APK (se não existir)
# - Iniciar API
```

---

### Já Tenho APK, Só Quero Iniciar API

```powershell
# Opção 1: Usar workflow
.\WorkflowAPK.ps1 -Acao iniciar

# Opção 2: Direto
.\IniciarAPIMobile.ps1
```

---

### Preciso Regerar APK

```powershell
# Opção 1: Usar workflow
.\WorkflowAPK.ps1 -Acao gerar

# Opção 2: Direto
.\GerarAPK.ps1
```

---

### Só Verificar se Está Tudo OK

```powershell
.\ValidarConfigAPK.ps1
```

---

## 📊 Estrutura de Arquivos

```
sistema-chamados-faculdade/
├── WorkflowAPK.ps1                 ← Script master
├── ValidarConfigAPK.ps1           ← Validação
├── GerarAPK.ps1                    ← Geração de APK
├── IniciarAPIMobile.ps1           ← Iniciar API para mobile
├── SetupUsuariosTeste.ps1         ← Setup de usuários
└── ...

APK/
├── SistemaChamados-v1.0.apk       ← APK gerado
├── README.md                       ← Info do APK
└── INSTALACAO_RAPIDA.txt          ← Guia rápido
```

---

## 🔧 Configurações Automáticas

### Detecção de IP
Os scripts detectam automaticamente o IP da máquina na rede local:
- Procura por IPs 192.168.x.x, 10.x.x.x, 172.x.x.x
- Ignora localhost (127.x.x.x)
- Ignora IPs auto-configurados (169.x.x.x)

### Firewall
`IniciarAPIMobile.ps1` tenta criar automaticamente a regra:
```powershell
New-NetFirewallRule -DisplayName "Sistema Chamados API" `
  -Direction Inbound `
  -LocalPort 5246 `
  -Protocol TCP `
  -Action Allow
```

**Nota:** Pode requerer privilégios de Administrador.

---

## ⚙️ Parâmetros e Variáveis

### WorkflowAPK.ps1

| Parâmetro | Valores | Padrão | Descrição |
|-----------|---------|--------|-----------|
| `-Acao` | validar, gerar, iniciar, tudo | tudo | Ação a executar |

**Exemplos:**
```powershell
.\WorkflowAPK.ps1                      # Tudo
.\WorkflowAPK.ps1 -Acao validar       # Só validar
.\WorkflowAPK.ps1 -Acao gerar         # Só gerar APK
.\WorkflowAPK.ps1 -Acao iniciar       # Só iniciar API
```

---

## 🧪 Testes e Validação

### Verificar se API está acessível

**No PC:**
```powershell
# Abrir navegador em:
http://localhost:5246/swagger
```

**No Celular (mesmo Wi-Fi):**
```
# Abrir navegador em:
http://192.168.0.18:5246/swagger
(Substitua pelo IP exibido no script)
```

✅ Se abrir Swagger = Conexão OK!

---

### Testar Login via API

**PowerShell:**
```powershell
$ip = "192.168.0.18"  # Seu IP
$response = Invoke-RestMethod -Uri "http://$ip:5246/api/usuarios/login" `
  -Method Post `
  -ContentType "application/json" `
  -Body '{"Email":"admin@sistema.com","Senha":"Admin@123"}'

$response.token  # Deve retornar token JWT
```

---

## 🐛 Troubleshooting

### Erro: "Workload 'maui-android' not installed"

```powershell
dotnet workload install maui-android
```

---

### Erro: "Port 5246 already in use"

```powershell
# Parar processos dotnet
Get-Process dotnet | Stop-Process -Force

# Ou verificar o que está usando
netstat -ano | findstr :5246
```

---

### Aviso: "IP em Constants.cs desatualizado"

1. Abrir: `SistemaChamados.Mobile\Helpers\Constants.cs`
2. Atualizar IP na linha `BaseUrlPhysicalDevice`
3. Regerar APK: `.\GerarAPK.ps1`

---

### Erro: "Firewall bloqueando"

**Opção 1: Executar script como Admin**
```powershell
# Clicar direito em PowerShell → Executar como Administrador
.\IniciarAPIMobile.ps1
```

**Opção 2: Criar regra manualmente**
```powershell
# Como Admin:
New-NetFirewallRule -DisplayName "Sistema Chamados API" `
  -Direction Inbound `
  -LocalPort 5246 `
  -Protocol TCP `
  -Action Allow
```

**Opção 3: Desabilitar firewall temporariamente (não recomendado)**

---

### APK não conecta à API

**Checklist:**
- [ ] API rodando? (`.\IniciarAPIMobile.ps1`)
- [ ] Celular no mesmo Wi-Fi?
- [ ] IP correto no Constants.cs?
- [ ] Firewall liberado?
- [ ] Testar Swagger no navegador do celular?

---

## 📝 Logs e Debug

### Ver logs da API

A API exibe logs em tempo real quando rodando via `IniciarAPIMobile.ps1`.

**Níveis de log:**
- `[OK]` - Sucesso
- `[INFO]` - Informação
- `[AVISO]` - Aviso
- `[ERRO]` - Erro

---

### Ver logs do build APK

```powershell
# Build com logs detalhados
cd c:\Users\opera\sistema-chamados-faculdade\SistemaChamados.Mobile
dotnet build -c Release -f net8.0-android -v detailed
```

---

## 🎨 Personalização

### Mudar porta da API

**Em `IniciarAPIMobile.ps1`:**
```powershell
# Linha final, mudar 5246 para outra porta:
dotnet run --urls="http://0.0.0.0:NOVA_PORTA;http://localhost:NOVA_PORTA"
```

**Lembrar de atualizar:**
- Firewall
- Constants.cs
- Regerar APK

---

### Mudar nome do APK

**Em `GerarAPK.ps1`:**
```powershell
# Linha onde define nome do arquivo:
$apkFileName = "MeuApp-v1.0.apk"
```

---

## 📞 Credenciais de Teste

Todos os scripts exibem as credenciais automaticamente:

```
Administrador:
  Email: admin@sistema.com
  Senha: Admin@123

Aluno:
  Email: aluno@sistema.com
  Senha: Aluno@123

Professor:
  Email: professor@sistema.com
  Senha: Prof@123
```

---

## 🔄 Atualização de Scripts

Para atualizar os scripts com novas funcionalidades:

1. Editar o script desejado
2. Salvar
3. Executar novamente

**Não requer recompilação!**

---

## 📚 Documentação Relacionada

- `GUIA_GERAR_APK.md` - Guia completo de geração
- `APK/README.md` - Informações do APK
- `APK/INSTALACAO_RAPIDA.txt` - Guia de instalação
- `CREDENCIAIS_TESTE.md` - Credenciais detalhadas

---

## ✅ Checklist Rápido

Antes de usar APK no celular:

- [ ] Executar `.\WorkflowAPK.ps1`
- [ ] Verificar API iniciou sem erros
- [ ] Anotar IP exibido (ex: 192.168.0.18)
- [ ] Celular conectado no mesmo Wi-Fi
- [ ] APK instalado no celular
- [ ] Testar Swagger no navegador do celular
- [ ] Login no app mobile

---

## 🚀 Comando Mais Rápido

```powershell
# Um único comando faz tudo:
.\WorkflowAPK.ps1

# E aguardar seguir as instruções na tela!
```

---

**Versão dos Scripts:** 1.0  
**Data:** 20/10/2025  
**Compatibilidade:** Windows 10/11, PowerShell 5.1+

---

**✅ SCRIPTS PRONTOS PARA USO!**
