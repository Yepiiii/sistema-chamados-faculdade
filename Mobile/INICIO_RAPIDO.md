# 🚀 GUIA RÁPIDO DE EXECUÇÃO - TESTES

## ⚡ INÍCIO RÁPIDO (3 PASSOS)

### **Passo 1: Preparar Dispositivo Android**

**Opção A - Emulador (Recomendado para testes):**
1. Abra Android Studio
2. AVD Manager > Criar/Iniciar emulador
3. Aguarde o emulador inicializar completamente

**Opção B - Dispositivo Físico:**
1. Conecte via USB
2. Ative "Depuração USB" nas Opções de Desenvolvedor
3. Verifique: `adb devices` (deve listar o dispositivo)

---

### **Passo 2: Iniciar API Backend**

```powershell
cd c:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade
.\IniciarAPIMobile.ps1
```

**Verificar:**
- API deve estar em: `http://192.168.x.x:5246`
- Teste: Abra navegador em `http://localhost:5246/swagger`

---

### **Passo 3: Executar App Mobile**

```powershell
cd c:\Users\opera\sistema-chamados-faculdade\SistemaChamados.Mobile
.\ExecutarAndroid.ps1
```

**O script irá:**
1. ✅ Verificar dispositivos conectados
2. ✅ Compilar projeto Android
3. ✅ Instalar APK no dispositivo
4. ✅ Iniciar o aplicativo automaticamente

---

## 🧪 TESTES RÁPIDOS (5 MINUTOS)

### **1️⃣ Teste de Notificações (30 segundos)**

No app:
1. Faça login
2. Na lista de chamados, procure o botão **🔔** (laranja, ao lado do +)
3. **Toque no botão 🔔**
4. Veja o alerta: "Atualizações simuladas!"
5. **Puxe a barra de notificações do Android**
6. Deve ver **3 notificações** com cores diferentes
7. **Toque em uma notificação**
8. App deve navegar para o detalhe do chamado

✅ **SUCESSO:** Notificações aparecem e navegação funciona

---

### **2️⃣ Teste de Comentários (1 minuto)**

1. Abra qualquer chamado
2. Role até a seção "Comentários"
3. Digite: `"Teste de comentário mobile 🎉"`
4. Toque em **"Enviar"**
5. Comentário deve aparecer instantaneamente na lista
6. Verifique avatar e timestamp ("há alguns segundos")

✅ **SUCESSO:** Comentário enviado e exibido

---

### **3️⃣ Teste de Upload (1 minuto)**

1. No chamado aberto, role até "Anexos"
2. Toque em **"Adicionar Anexo"**
3. Selecione uma foto da galeria ou tire uma foto
4. Verifique o **thumbnail** aparece
5. Veja o nome e tamanho do arquivo

✅ **SUCESSO:** Imagem carregada e thumbnail exibido

---

### **4️⃣ Teste de Timeline (30 segundos)**

1. Role até a seção "Histórico"
2. Verifique eventos cronológicos com:
   - ✅ Ícones diferentes por tipo
   - ✅ Cores variadas
   - ✅ Data e hora formatadas
   - ✅ Nome do usuário

✅ **SUCESSO:** Timeline renderizada corretamente

---

### **5️⃣ Teste de Polling Automático (5 minutos)**

**Opcional - Aguarde 5 minutos:**
1. Deixe o app na lista de chamados
2. Aguarde 5 minutos
3. Deve receber notificação automática
4. Lista de chamados atualiza automaticamente

**OU use o botão 🔔 para teste imediato!**

✅ **SUCESSO:** Polling dispara automaticamente

---

## 📊 MONITORAMENTO DE LOGS

### **Ver Logs em Tempo Real:**

```powershell
adb logcat | Select-String "ChamadosListViewModel|PollingService|NotificationService|MainActivity"
```

### **Logs Esperados:**

```
[ChamadosListViewModel] Polling configurado e evento subscrito.
[ChamadosListViewModel] Polling iniciado.
[PollingService] Timer iniciado com intervalo de 5 minutos
[Polling Mock] Atualização simulada: NovoComentario - Problema #42
[NotificationService] Canal de notificação criado/verificado
[NotificationService] Exibindo notificação: Novo comentário no chamado #42
[MainActivity] Intent recebido de notificação
[MainActivity] Navegando para ChamadoDetailPage?id=42
```

---

## 🔧 COMANDOS ÚTEIS

### **Reinstalar APK:**
```powershell
dotnet build -f net8.0-android -t:Install
```

### **Limpar e Recompilar:**
```powershell
dotnet clean
dotnet build -f net8.0-android
```

### **Ver Dispositivos Conectados:**
```powershell
adb devices
```

### **Desinstalar App:**
```powershell
adb uninstall com.companyname.sistemachamados.mobile
```

### **Capturar Screenshot:**
```powershell
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png .
```

---

## 🐛 SOLUÇÃO RÁPIDA DE PROBLEMAS

| Problema | Solução Rápida |
|----------|----------------|
| ❌ Nenhum dispositivo encontrado | Execute emulador ou conecte USB com depuração ativada |
| ❌ Erro ao compilar | Execute: `dotnet clean` e tente novamente |
| ❌ Notificações não aparecem | Configurações > Apps > Sistema de Chamados > Notificações > Permitir |
| ❌ Comentários não enviam | Verifique IP da API no `appsettings.json` |
| ❌ Upload falha | Conceda permissão de câmera/armazenamento |
| ❌ App não abre | Verifique logcat: `adb logcat \| Select-String "AndroidRuntime"` |

---

## ✅ CHECKLIST DE VALIDAÇÃO

Marque conforme testa:

### **Infraestrutura:**
- [ ] Emulador/dispositivo conectado
- [ ] API backend rodando (porta 5246)
- [ ] App instalado e aberto

### **Features:**
- [ ] Botão 🔔 funciona
- [ ] Notificações aparecem (3 mockadas)
- [ ] Navegação via notificação OK
- [ ] Comentários enviam e exibem
- [ ] Upload de imagem funciona
- [ ] Timeline renderiza eventos
- [ ] Polling inicia automaticamente

### **Qualidade:**
- [ ] Sem crashes
- [ ] Logs aparecem no logcat
- [ ] UI responsiva
- [ ] Navegação fluida

---

## 📸 CAPTURAS RECOMENDADAS

Para documentação, capture:

1. **Lista de Chamados** - Mostrando botão 🔔
2. **Barra de Notificações** - 3 notificações visíveis
3. **Detalhe do Chamado** - Timeline completa
4. **Thread de Comentários** - Comentário enviado
5. **Galeria de Anexos** - Thumbnail da imagem
6. **Navegação via Notificação** - Demonstrar fluxo

---

## 🎯 SUCESSO!

Se todos os testes passaram:
- ✅ **5 features implementadas e funcionando**
- ✅ **Sistema 100% operacional**
- ✅ **Pronto para demonstração**

---

## 📞 PRÓXIMOS PASSOS

1. **Demonstração para stakeholders**
2. **Coletar feedback de usuários**
3. **Ajustes finais de UX**
4. **Preparar para produção**

---

**Última atualização:** Outubro 2025  
**Versão:** 1.0.0  
**Status:** ✅ **PRODUCTION READY**
