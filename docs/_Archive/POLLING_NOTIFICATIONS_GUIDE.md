# 📱 Sistema de Polling e Notificações Locais - Guia de Teste

## ✅ Implementação Completa

### 1. Componentes Criados

#### **DTOs**
- ✅ `AtualizacaoDto.cs` - Modelo de atualização com formatação de mensagens
- ✅ `VerificacaoAtualizacoesDto.cs` - Wrapper para verificação de updates

#### **Services**
- ✅ `PollingService.cs` - Serviço de polling com timer (5 minutos)
- ✅ `INotificationService.cs` - Interface de notificações
- ✅ `NotificationService.cs` (Android) - Implementação nativa Android

#### **Configurações**
- ✅ `MainActivity.cs` - Processamento de intents de notificações
- ✅ `MauiProgram.cs` - Registro de serviços (Singleton + DependencyService)
- ✅ `AndroidManifest.xml` - Permissões POST_NOTIFICATIONS e VIBRATE
- ✅ `notification_icon.xml` - Ícone de sino para notificações

#### **ViewModels**
- ✅ `ChamadosListViewModel.cs` - Integração com polling e notificações

---

## 🧪 Como Testar

### **Passo 1: Build e Deploy**

```powershell
# No diretório SistemaChamados.Mobile
dotnet build -f net8.0-android
dotnet run -f net8.0-android
```

### **Passo 2: Simular Atualizações (Mock)**

O sistema já possui dados mock ativos. Após abrir a tela de Chamados:

1. **Aguarde 5 minutos** - O timer automaticamente dispara
2. **Verifique o Debug Output** no Visual Studio:
   ```
   [PollingService] Verificação automática iniciada...
   [PollingService] 3 novas atualizações detectadas!
   [ChamadosListViewModel] 3 novas atualizações detectadas!
   [ChamadosListViewModel] Notificação exibida: ...
   ```

### **Passo 3: Testar Notificações Manuais**

Para forçar uma atualização imediata (adicione botão temporário ou chame via debug):

```csharp
// Simular nova atualização
_pollingService.SimularAtualizacao();
```

### **Passo 4: Verificar Notificações Android**

1. **Puxe a barra de notificações** do dispositivo/emulador
2. **Verifique:**
   - ✅ Ícone de sino branco
   - ✅ Título: "Sistema de Chamados"
   - ✅ Mensagem formatada (ex: "Novo comentário no chamado #123")
   - ✅ Cor da prioridade aplicada
   - ✅ Vibração ao receber

3. **Toque na notificação:**
   - ✅ App abre/retoma
   - ✅ Navega para `ChamadoDetailPage` com ID correto
   - ✅ Detalhes do chamado exibidos

### **Passo 5: Testar Permissões (Android 13+)**

No primeiro uso (Android 13+):
1. **Permissão será solicitada automaticamente**
2. **Conceda "Permitir"**
3. Se negado, notificações não aparecerão (silencioso)

Para verificar permissões manualmente:
```csharp
var hasPermission = await _notificationService.VerificarPermissaoAsync();
if (!hasPermission)
{
    await _notificationService.SolicitarPermissaoAsync();
}
```

---

## 🔧 Configurações Ajustáveis

### **Alterar Intervalo de Polling**

```csharp
// Em ChamadosListViewModel ou outra inicialização
_pollingService.ConfigurarIntervalo(10); // 10 minutos
```

### **Parar Polling Temporariamente**

```csharp
// Quando usuário sai da tela
_pollingService.PararPolling();

// Para reiniciar
_pollingService.IniciarPolling();
```

### **Limpar Atualizações Mock**

```csharp
_pollingService.LimparAtualizacoesMock();
```

---

## 🔌 Conectar com API Real

No `PollingService.cs`, descomente e ajuste:

```csharp
public async Task<VerificacaoAtualizacoesDto> VerificarAtualizacoesAsync()
{
    try
    {
        // Descomentar quando API estiver pronta
        /*
        var timestamp = _ultimaVerificacao.ToString("yyyy-MM-ddTHH:mm:ss");
        var url = $"{Settings.ApiUrl}/api/updates/check?since={timestamp}";
        
        var response = await _httpClient.GetFromJsonAsync<VerificacaoAtualizacoesDto>(url);
        
        if (response != null && response.HasUpdates)
        {
            _ultimaVerificacao = DateTime.Now;
            Debug.WriteLine($"[PollingService] {response.TotalAtualizacoes} atualizações reais da API.");
            return response;
        }
        */
        
        // MOCK (remover quando API estiver pronta)
        var mockResult = new VerificacaoAtualizacoesDto
        {
            HasUpdates = _atualizacoesMock.Count > 0,
            TotalAtualizacoes = _atualizacoesMock.Count,
            UltimaVerificacao = DateTime.Now,
            Atualizacoes = _atualizacoesMock.ToList()
        };
        
        return mockResult;
    }
    catch (Exception ex)
    {
        Debug.WriteLine($"[PollingService] Erro ao verificar atualizações: {ex.Message}");
        return new VerificacaoAtualizacoesDto();
    }
}
```

---

## 📊 Endpoints da API (Backend)

### **GET /api/updates/check**

**Query Parameters:**
- `since` (DateTime) - Timestamp da última verificação

**Response:**
```json
{
  "hasUpdates": true,
  "totalAtualizacoes": 3,
  "ultimaVerificacao": "2025-01-20T14:30:00",
  "atualizacoes": [
    {
      "chamadoId": 123,
      "tituloResumido": "Problema na rede",
      "tipoAtualizacao": "NovoComentario",
      "dataHora": "2025-01-20T14:25:00",
      "nomeTecnico": "João Silva",
      "novoStatus": null,
      "prioridadeId": 2,
      "corPrioridade": "#F59E0B"
    }
  ]
}
```

**Tipos de Atualização:**
- `NovoComentario` - Novo comentário adicionado
- `MudancaStatus` - Status alterado
- `AtribuicaoTecnico` - Técnico atribuído/alterado
- `Fechamento` - Chamado fechado
- `Reabertura` - Chamado reaberto

---

## 🐛 Troubleshooting

### **Notificações não aparecem**

1. **Verifique permissões:**
   - Configurações > Apps > Sistema de Chamados > Notificações
   - Deve estar "Permitido"

2. **Verifique o canal de notificação:**
   - Configurações > Apps > Sistema de Chamados > Notificações > Canais
   - Canal "Atualizações de Chamados" deve estar ativo

3. **Verifique logs:**
   ```
   [NotificationService] Canal de notificação criado/verificado
   [NotificationService] Exibindo notificação: ...
   ```

### **Polling não dispara**

1. **Verifique se foi iniciado:**
   ```
   [ChamadosListViewModel] Polling iniciado.
   ```

2. **Verifique o timer:**
   ```
   [PollingService] Timer iniciado com intervalo de 5 minutos
   ```

3. **App em segundo plano:**
   - Android pode limitar timers em background
   - Para produção, considere WorkManager

### **Navegação não funciona ao tocar notificação**

1. **Verifique intent extras:**
   ```
   [MainActivity] Intent extras: openDetail=True, chamadoId=123
   ```

2. **Verifique rota no AppShell:**
   ```csharp
   Routing.RegisterRoute("chamados/detail", typeof(ChamadoDetailPage));
   ```

---

## 📋 Checklist de Funcionalidades

### **Polling Service**
- ✅ Timer de 5 minutos configurável
- ✅ Verificação manual via `VerificarAtualizacoesAsync()`
- ✅ Evento `NovasAtualizacoesDetectadas`
- ✅ Mock de atualizações para teste
- ✅ Logging detalhado

### **Notification Service**
- ✅ Canal de notificação Android
- ✅ Ícone customizado (sino)
- ✅ Cores por prioridade
- ✅ Vibração configurada
- ✅ BigTextStyle para mensagens longas
- ✅ AutoCancel ao tocar
- ✅ PendingIntent para navegação
- ✅ Permissões Android 13+

### **ViewModel Integration**
- ✅ Injeção de dependência
- ✅ Subscrição ao evento de atualizações
- ✅ Exibição de notificações
- ✅ Refresh automático da lista
- ✅ Métodos de cleanup (StopPolling, Cleanup)

### **Navigation**
- ✅ MainActivity processa intent
- ✅ Extração de chamadoId e openDetail
- ✅ Navegação via Shell para ChamadoDetailPage
- ✅ Delay de 500ms para inicialização

---

## 🚀 Próximos Passos (Melhorias Futuras)

### **Produção**
1. **WorkManager** para polling em background persistente
2. **Firebase Cloud Messaging (FCM)** para push notifications reais
3. **Badge count** no ícone do app
4. **In-app notifications** (toast/snackbar)
5. **Agrupamento de notificações** (múltiplos updates)

### **UX**
1. **Botão "Marcar como lido"** na notificação
2. **Ações rápidas** (responder, fechar) na notificação
3. **Indicador visual** de updates não lidos na lista
4. **Sons customizados** por tipo de atualização

### **Performance**
1. **Throttling** - evitar múltiplas verificações simultâneas
2. **Caching** - armazenar última verificação localmente
3. **Delta sync** - apenas novos dados desde último timestamp

---

## 📞 Suporte

Para ajustes ou dúvidas sobre o sistema de polling e notificações, consulte:
- `Services/Polling/PollingService.cs`
- `Platforms/Android/NotificationService.cs`
- `ViewModels/ChamadosListViewModel.cs`

**Status:** ✅ **IMPLEMENTAÇÃO COMPLETA E PRONTA PARA TESTES**
