# 🚀 GUIA DO SCRIPT IniciarSistema.ps1

## ✅ SCRIPT ATUALIZADO COM NOVAS FUNCIONALIDADES

O script `IniciarSistema.ps1` foi atualizado para incluir instruções de teste das **5 novas funcionalidades** implementadas!

---

## 📋 O QUE O SCRIPT FAZ

1. ✅ **Finaliza** processos anteriores da API (se existirem)
2. ✅ **Inicia a API** em background (porta 5246)
3. ✅ **Testa** se a API está respondendo
4. ✅ **Compila e executa** o app mobile (Windows ou Android)
5. ✅ **Exibe instruções** de teste das novas funcionalidades
6. ✅ **Gerencia** a API ao finalizar

---

## 🎯 COMO USAR

### **Opção 1: Windows (PADRÃO - Mais Rápido)**

```powershell
cd C:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade
.\IniciarSistema.ps1
```

ou

```powershell
.\IniciarSistema.ps1 -Plataforma windows
```

**Executa:** App mobile Windows (net8.0-windows)

---

### **Opção 2: Android (Requer emulador/dispositivo)**

```powershell
.\IniciarSistema.ps1 -Plataforma android
```

**Executa:** App mobile Android (net8.0-android)

**NOTA:** O script irá perguntar se deseja alterar `localhost` para `10.0.2.2` (necessário para emulador Android)

---

## ⚡ VANTAGENS DO SCRIPT ATUALIZADO

### **1. Inicialização Automática Completa**
- ✅ API + Mobile em um único comando
- ✅ Verificação automática se API iniciou corretamente
- ✅ Aguarda tempo necessário para API estar pronta

### **2. Instruções de Teste Integradas**
Após iniciar, o script mostra como testar:
- 🔔 **Notificações** (com botão de teste rápido)
- 💬 **Comentários**
- 📷 **Upload de arquivos**
- 📊 **Timeline de histórico**
- ⏱️ **Polling automático**

### **3. Gestão Inteligente da API**
- API roda em **background** (não bloqueia terminal)
- Ao finalizar, pergunta se quer parar a API
- Se manter rodando, mostra comando para parar depois

---

## 🧪 FLUXO DE TESTE COMPLETO

Após executar o script:

### **1. App Abre Automaticamente**
   - Windows: Janela do app abre
   - Android: Instalado e iniciado no emulador/dispositivo

### **2. Faça Login**
   - Use suas credenciais

### **3. TESTE RÁPIDO (30 segundos):**

   **a) Botão de Notificações 🔔:**
   - Na lista de chamados
   - Procure o botão **LARANJA** (ao lado do +)
   - **CLIQUE/TOQUE** no botão 🔔
   - Veja alerta: "Atualizações simuladas!"
   
   **b) Verificar Notificações:**
   - **Windows:** Central de Ações (canto inferior direito)
   - **Android:** Puxar barra de notificações
   - Deve ver **3 notificações** com cores diferentes
   
   **c) Testar Navegação:**
   - Clique/toque em uma notificação
   - App navega para o detalhe do chamado
   - **✅ SUCESSO!**

### **4. Outros Testes (Opcionais):**

   **Comentários:**
   - Abra um chamado > Comentários
   - Digite e envie
   - Aparece instantaneamente

   **Upload:**
   - Detalhes > Anexos
   - Adicionar Anexo > Selecione imagem
   - Thumbnail aparece

   **Timeline:**
   - Role até Histórico
   - Veja eventos com ícones

   **Polling:**
   - Aguarde 5 min OU use botão 🔔

---

## 📊 EXEMPLO DE USO

```powershell
# Navegar até o diretório
cd C:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade

# Executar (Windows - padrão)
.\IniciarSistema.ps1

# Saída esperada:
# ========================================
#   Sistema de Chamados - Inicializacao
# ========================================
# 
# Verificando processos anteriores...
# Iniciando API...
# Aguardando API inicializar...
# [OK] API rodando em http://localhost:5246
# 
# Iniciando aplicativo mobile (windows)...
# Executando: dotnet build -t:Run -f net8.0-windows10.0.19041.0
# 
# ========================================
#   APP MOBILE INICIADO NO WINDOWS!
# ========================================
# 
# 🎯 TESTE AS NOVAS FUNCIONALIDADES:
# 
# 1️⃣  NOTIFICAÇÕES (TESTE RÁPIDO - 30 segundos):
#    - Faça login no app
#    - Na lista de chamados, procure o botão 🔔 (LARANJA)
#    - CLIQUE NO BOTÃO 🔔
#    ...
```

---

## 🎯 COMPARAÇÃO: IniciarSistema.ps1 vs IniciarTeste.ps1

| Característica | IniciarSistema.ps1 | IniciarTeste.ps1 |
|----------------|-------------------|------------------|
| **API** | Background (Job) | Nova janela PowerShell |
| **Plataforma** | Windows OU Android | Apenas Windows |
| **Parâmetros** | `-Plataforma` | Nenhum |
| **Config Android** | Auto-detecta e pergunta | Manual |
| **Gestão API** | Pergunta ao finalizar | API fica em janela aberta |
| **Instruções** | ✅ Incluídas | ✅ Incluídas |

**Recomendação:** Use `IniciarSistema.ps1` (mais robusto e flexível)

---

## 🔧 TROUBLESHOOTING

### **API não inicia**
```powershell
# Verifique porta 5246
Get-NetTCPConnection -LocalPort 5246

# Se ocupada, mate processo
Stop-Process -Name dotnet -Force
```

### **App não abre**
```powershell
# Compile manualmente
cd C:\Users\opera\sistema-chamados-faculdade\SistemaChamados.Mobile
dotnet build -f net8.0-windows10.0.19041.0
```

### **Android não conecta**
- Verifique emulador rodando: `adb devices`
- Use `10.0.2.2` ao invés de `localhost`
- O script pergunta automaticamente!

---

## 📚 DOCUMENTAÇÃO RELACIONADA

- **TESTE_COMPLETO.md** - Roteiro detalhado de 30 minutos
- **POLLING_NOTIFICATIONS_GUIDE.md** - Guia técnico de polling
- **STATUS_IMPLEMENTACAO.md** - Status e features implementadas
- **INICIO_RAPIDO.md** - Guia de início rápido

---

## ✅ RESUMO

**COMANDO ÚNICO:**
```powershell
.\IniciarSistema.ps1
```

**RESULTADO:**
- ✅ API iniciada e testada
- ✅ App mobile rodando
- ✅ Instruções de teste exibidas
- ✅ 5 novas features prontas para testar
- ✅ Botão 🔔 para teste instantâneo

**TUDO EM UM SÓ SCRIPT! 🚀**

---

**Última atualização:** Outubro 2025  
**Versão:** 2.0 (com novas funcionalidades)  
**Status:** ✅ **PRODUCTION READY**
