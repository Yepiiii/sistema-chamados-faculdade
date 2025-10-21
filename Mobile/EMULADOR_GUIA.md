# EMULADOR ANDROID - GUIA COMPLETO

## STATUS ATUAL
✅ **Visual Studio 2022 está abrindo**
✅ **Solução carregada**
✅ **Projeto compilado com sucesso**

---

## PASSOS PARA EXECUTAR NO EMULADOR

### 1️⃣ NO VISUAL STUDIO (que está abrindo):

**a) Aguarde o Visual Studio carregar completamente**
   - Pode levar 30-60 segundos
   - Aguarde até ver a solução completa no Solution Explorer

**b) Defina o projeto de inicialização:**
   - Solution Explorer (painel direito)
   - Localize **SistemaChamados.Mobile**
   - Clique direito > **"Definir como Projeto de Inicialização"**
   - O projeto ficará em **negrito**

**c) Selecione o emulador:**
   - Barra de ferramentas superior
   - Procure o dropdown de dispositivos (ao lado do botão Play verde)
   - Clique na seta para baixo

**d) Escolha uma opção:**

   **OPÇÃO A - Emulador já existe:**
   - Selecione um emulador da lista (ex: "Pixel 5 API 33")
   
   **OPÇÃO B - Criar novo emulador:**
   - Clique em **"Android Emulator"** > **"Create New Emulator..."**
   - Device: **Pixel 5** ou **Pixel 7**
   - API Level: **33 (Android 13.0)** ou superior
   - Clique **"Create"**

**e) Executar:**
   - Pressione **F5** (ou clique no botão Play verde)
   - Aguarde:
     1. Compilação do projeto (30 segundos)
     2. Inicialização do emulador (1-2 minutos na primeira vez)
     3. Instalação do APK
     4. App abre automaticamente!

---

## 2️⃣ ALTERNATIVA: ANDROID STUDIO

Se preferir usar Android Studio:

1. Abra **Android Studio**
2. Menu: **Tools** > **AVD Manager**
3. Clique no botão **▶️ Play** de um emulador
4. Aguarde inicializar (1-2 minutos)
5. Volte para este terminal
6. Execute: `.\Executar.ps1`

---

## 3️⃣ ALTERNATIVA: DISPOSITIVO FÍSICO (MAIS RÁPIDO!)

Conecte seu smartphone Android:

1. **Ative Depuração USB:**
   - Configurações > Sobre o telefone
   - Toque 7x em "Número da compilação"
   - Volte > Sistema > Opções do desenvolvedor
   - Ative "Depuração USB"

2. **Conecte via USB**

3. **No telefone:** Aceite "Permitir depuração USB"

4. **No Visual Studio:** Seu dispositivo aparecerá no dropdown

5. **Pressione F5**

---

## TESTE RÁPIDO (30 SEGUNDOS)

Quando o app abrir no emulador:

1. **Faça login**

2. **Na lista de chamados:**
   - Procure o botão **🔔** (laranja, ao lado do +)
   - **TOQUE NO BOTÃO 🔔**

3. **No emulador:**
   - Puxe a barra de notificações (arraste do topo)
   - Deve ver **3 notificações** com cores diferentes

4. **Toque em uma notificação:**
   - App navega para o detalhe do chamado
   - **SUCESSO!** ✨

---

## VERIFICAR DISPOSITIVOS CONECTADOS

```powershell
adb devices
```

**Resultado esperado:**
- `List of devices attached`
- `emulator-5554    device` (se emulador estiver rodando)
- OU nome do seu dispositivo físico

**Se aparecer vazio:** Nenhum emulador/dispositivo conectado

---

## TROUBLESHOOTING

### Emulador não aparece no Visual Studio
- Reinstale workload Android via Visual Studio Installer
- Tools > Android > Android SDK Manager > Emulador

### Emulador muito lento
- Verifique se virtualization está ativa na BIOS (Intel VT-x ou AMD-V)
- Use dispositivo físico (muito mais rápido!)

### "No device available"
- Inicie o emulador primeiro
- Ou conecte dispositivo físico via USB

---

## RESUMO RÁPIDO

**CAMINHO MAIS FÁCIL:**
1. Visual Studio está abrindo ✅
2. Aguarde carregar
3. F5 (cria emulador automaticamente se necessário)
4. Aguarde 2-3 minutos
5. App abre!

**CAMINHO MAIS RÁPIDO:**
1. Conecte smartphone Android via USB
2. F5 no Visual Studio
3. Aguarde 30 segundos
4. App abre!

---

## PRÓXIMOS PASSOS

Quando o app estiver rodando:
- Consulte **TESTE_COMPLETO.md** para roteiro de testes
- Use o botão **🔔** para testar notificações
- Teste Timeline, Comentários, Upload

**Boa sorte! 🚀**
