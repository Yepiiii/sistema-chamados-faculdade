# ==============================================================================
# PLANO DE REORGANIZACAO - Scripts PowerShell
# Data: 23/10/2025
# ==============================================================================

## PROBLEMA IDENTIFICADO

Atualmente existem **48 scripts PowerShell** ocupando **281.76 KB** com muita redundancia:
- 11 scripts na raiz
- 33 scripts em /Scripts  
- 4 scripts em /Mobile

Redundancias principais:
1. **3 scripts para gerar APK** (GerarAPK.ps1 na raiz e Scripts/, ambos fazem mesma coisa)
2. **4 scripts para configurar IP** (ConfigurarIP.ps1, ConfigurarIPRemoto.ps1, ConfigurarIPDispositivo.ps1)
3. **4 scripts para iniciar API** (IniciarAPI.ps1, IniciarAPIMobile.ps1, IniciarAPIRede.ps1, IniciarAPIComNgrok.ps1)
4. **6 scripts para criar chamados demo** (CriarChamados*.ps1 com versoes duplicadas)
5. **2 scripts para iniciar sistema** (IniciarSistema.ps1, IniciarSistemaWindows.ps1)

## ESTRUTURA PROPOSTA

```
/
├── Scripts/
│   ├── Dev/                    # Scripts de desenvolvimento (raros)
│   │   ├── SetupInicial.ps1    # Setup ambiente desenvolvimento
│   │   └── ReorganizarProjeto.ps1
│   │
│   ├── Database/               # Scripts de banco de dados
│   │   ├── InicializarBanco.ps1
│   │   ├── AnalisarBanco.ps1
│   │   └── LimparChamados.ps1
│   │
│   ├── API/                    # Scripts da API
│   │   ├── IniciarAPI.ps1      # Unico script para iniciar API (unifica 4 scripts)
│   │   └── ConfigurarFirewall.ps1
│   │
│   ├── Mobile/                 # Scripts do mobile
│   │   ├── ConfigurarIP.ps1    # Unico script para IP (unifica 3 scripts)
│   │   ├── GerarAPK.ps1        # Unico script para APK
│   │   └── WorkflowCompleto.ps1 # ConfigIP + GerarAPK + IniciarAPI
│   │
│   └── Teste/                  # Scripts de teste
│       ├── TestarAPI.ps1
│       ├── TestarGemini.ps1
│       ├── CriarDadosDemo.ps1  # Unifica 6 scripts de criar chamados
│       └── TestarMobile.ps1
│
└── WORKFLOWS.md                # Documentacao dos workflows principais
```

## SCRIPTS A MANTER (UNIFICADOS)

### 1. Scripts/API/IniciarAPI.ps1 (UNIFICA 4 SCRIPTS)
Combina: IniciarAPI.ps1, IniciarAPIMobile.ps1, IniciarAPIRede.ps1, IniciarAPIComNgrok.ps1
- Detecta IP automaticamente
- Configura firewall automaticamente
- Binding em 0.0.0.0:5246 (aceita rede)
- Mostra URLs de acesso (local + rede)
- Opcao para usar ngrok (se instalado)

### 2. Scripts/API/ConfigurarFirewall.ps1 (MANTER)
- Ja esta otimizado
- Configura porta 5246

### 3. Scripts/Mobile/ConfigurarIP.ps1 (UNIFICA 3 SCRIPTS)
Combina: ConfigurarIP.ps1, ConfigurarIPRemoto.ps1, ConfigurarIPDispositivo.ps1
- Detecta IP Wi-Fi automaticamente
- Filtra IPs virtuais (VirtualBox, VMware)
- Atualiza Constants.cs
- Valida IP antes de aplicar

### 4. Scripts/Mobile/GerarAPK.ps1 (UNIFICA 2 SCRIPTS)
Combina: GerarAPK.ps1 (raiz) e Scripts/GerarAPK.ps1
- Limpa build anterior
- Compila APK Release
- Copia para pasta APK/
- Mostra tamanho e localizacao

### 5. Scripts/Mobile/WorkflowCompleto.ps1 (NOVO)
Workflow automatizado completo:
1. ConfigurarIP.ps1
2. GerarAPK.ps1
3. IniciarAPI.ps1
4. Abrir pasta do APK

### 6. Scripts/Database/InicializarBanco.ps1 (MANTER)
- Cria banco
- Aplica migrations
- Cria usuario admin padrao

### 7. Scripts/Database/AnalisarBanco.ps1 (MANTER)
- Mostra estatisticas do banco
- Lista tabelas e contagem

### 8. Scripts/Database/LimparChamados.ps1 (UNIFICA 3 SCRIPTS)
Combina: LimparChamados.ps1, LimparChamadosSimples.ps1, LimparTodosChamados.ps1
- Opcao: Limpar todos ou manter alguns
- Confirma antes de deletar

### 9. Scripts/Teste/CriarDadosDemo.ps1 (UNIFICA 6 SCRIPTS)
Combina todos os CriarChamados*.ps1
- Opcao: Quantidade de chamados
- Opcao: Usar IA ou nao
- Cria usuarios de teste
- Cria chamados demo

### 10. Scripts/Teste/TestarAPI.ps1 (MANTER)
- Testa endpoints principais
- Valida respostas

### 11. Scripts/Teste/TestarGemini.ps1 (MANTER)
- Testa integracao Gemini AI

### 12. Scripts/Teste/TestarMobile.ps1 (MANTER)
- Testa conectividade mobile

### 13. Scripts/Dev/SetupInicial.ps1 (NOVO)
Workflow para novo desenvolvedor:
1. Verificar prerequisitos (.NET, SQL Server)
2. Inicializar banco
3. Criar usuario admin
4. Compilar projetos

## SCRIPTS A REMOVER (REDUNDANTES)

**Total: 35 scripts** (de 48)

### Raiz (remover todos da raiz, mover para Scripts/)
- [x] AnalisarBanco.ps1 → Scripts/Database/
- [x] ConfigurarFirewall.ps1 → Scripts/API/
- [x] ConfigurarIPDispositivo.ps1 → Removido (unificado)
- [x] CorrigirPermissoes.ps1 → Removido (obsoleto)
- [x] GerarAPK.ps1 → Scripts/Mobile/
- [x] InicializarBanco.ps1 → Scripts/Database/
- [x] IniciarAPIRede.ps1 → Removido (unificado)
- [x] PromoVerAdmin.ps1 → Removido (funcionalidade no InicializarBanco)
- [x] ReorganizarProjeto.ps1 → Scripts/Dev/
- [x] TestarMobileComLogs.ps1 → Removido (unificado)
- [x] VerificarPermissoes.ps1 → Removido (obsoleto)

### Scripts/ (remover redundantes)
- [x] ConfigurarIPRemoto.ps1 (redundante com ConfigurarIP.ps1)
- [x] CriarChamadosComIA.ps1 (unificar)
- [x] CriarChamadosDemo.ps1 (unificar)
- [x] CriarChamadosDemoCorrigido.ps1 (unificar)
- [x] CriarChamadosDemoV2.ps1 (unificar)
- [x] CriarChamadosDemo_API.ps1 (unificar)
- [x] CriarChamadosDemo_Final.ps1 (unificar)
- [x] GerarAPK.ps1 (redundante com raiz)
- [x] IniciarAPI.ps1 (unificar)
- [x] IniciarAPIComNgrok.ps1 (funcionalidade integrada)
- [x] IniciarAPIMobile.ps1 (redundante)
- [x] IniciarAmbiente.ps1 (substituir por SetupInicial)
- [x] IniciarApp.ps1 (redundante)
- [x] IniciarSistema.ps1 (unificar)
- [x] IniciarSistemaWindows.ps1 (redundante)
- [x] IniciarTeste.ps1 (substituir por TestarAPI)
- [x] LimparChamadosSimples.ps1 (unificar)
- [x] LimparTodosChamados.ps1 (unificar)
- [x] CriarAdmin.ps1 (funcionalidade no InicializarBanco)
- [x] ObterToken.ps1 (funcionalidade no TestarAPI)
- [x] SetupUsuariosTeste.ps1 (funcionalidade no CriarDadosDemo)
- [x] TestarChamados.ps1 (unificar com TestarAPI)
- [x] TestarConectividadeMobile.ps1 (funcionalidade no TestarMobile)
- [x] TestarPortabilidade.ps1 (obsoleto)
- [x] TestarRegrasVisualizacao.ps1 (funcionalidade no TestarAPI)
- [x] TestarRestricaoManual.ps1 (funcionalidade no TestarAPI)
- [x] ValidarConfigAPK.ps1 (funcionalidade no ConfigurarIP)
- [x] WorkflowAPK.ps1 (substituir por WorkflowCompleto)

### Mobile/ (mover para Scripts/Mobile/)
- [x] AbrirVisualStudio.ps1 → Remover (obsoleto)
- [x] Executar.ps1 → Remover (obsoleto)
- [x] IniciarEmulador.ps1 → Remover (obsoleto)
- [x] TestarImplementacoesRecentes.ps1 → Remover (obsoleto)

## RESULTADO FINAL

**De 48 scripts para 13 scripts** = Reducao de **73%**
**De 281.76 KB para ~85 KB** = Reducao de **70%**

## BENEFICIOS

1. **Menos confusao**: Cada tarefa tem UM script claro
2. **Mais facil encontrar**: Organizacao por categoria
3. **Menos duplicacao**: Codigo unificado
4. **Mais rapido**: Menos arquivos para git rastrear
5. **Mais profissional**: Estrutura limpa e organizada

## DOCUMENTACAO

Criar arquivo WORKFLOWS.md na raiz com:
- Como executar cada tarefa
- Parametros opcionais
- Exemplos de uso
- Troubleshooting comum
