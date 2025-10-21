# 📱 APK do Sistema de Chamados - Guia Completo

**Data de Geração:** 20 de outubro de 2025  
**Versão:** 1.0  
**Localização:** `c:\Users\opera\sistema-chamados-faculdade\APK\SistemaChamados-v1.0.apk`  
**Tamanho:** 64.99 MB  
**Package ID:** com.sistemachamados.mobile

---

## ✅ APK Gerado Com Sucesso!

O APK foi compilado com todas as correções aplicadas:
- ✅ Navegação Shell corrigida (rotas absolutas ///)
- ✅ Fuso horário corrigido (UTC → Local)
- ✅ Settings.TipoUsuario persistindo corretamente
- ✅ Permissões de Admin funcionando
- ✅ Comentários mock removidos
- ✅ Todos os 9 bugs corrigidos

---

## 📲 Como Instalar no Android

### Opção 1: Via Cabo USB (ADB)

**Pré-requisitos:**
- Android Debug Bridge (ADB) instalado
- Celular com "Depuração USB" ativada

**Passos:**
```powershell
# 1. Conecte o celular ao PC via USB

# 2. Verifique se o dispositivo foi detectado
adb devices

# 3. Instale o APK
adb install "c:\Users\opera\sistema-chamados-faculdade\APK\SistemaChamados-v1.0.apk"
```

---

### Opção 2: Transferência Direta (Recomendado para Testes)

1. **Copie o APK para o celular:**
   - Via cabo USB (copiar arquivo)
   - Via Bluetooth
   - Via compartilhamento de arquivos (Nearby Share, Shareit, etc.)
   - Via WhatsApp (enviar para você mesmo)

2. **No celular:**
   - Abra o gerenciador de arquivos
   - Localize o arquivo `SistemaChamados-v1.0.apk`
   - Toque no arquivo

3. **Permissões:**
   - Android vai pedir para "Permitir de fontes desconhecidas"
   - Ative essa opção temporariamente
   - Confirme a instalação

4. **Após instalar:**
   - Ícone "Sistema de Chamados" aparecerá no menu de apps
   - Desative "Fontes desconhecidas" novamente (segurança)

---

### Opção 3: Via QR Code (Mais Rápido)

Se você tiver um servidor web local ou Google Drive:

1. **Upload do APK:**
   - Faça upload do APK para Google Drive, Dropbox, ou servidor web
   - Gere um link público

2. **No celular:**
   - Escaneie QR code com o link
   - Ou abra o link diretamente
   - Baixe o APK
   - Instale normalmente

---

## ⚙️ Configuração Inicial Importante

### ⚠️ ATENÇÃO: Configurar IP da API

O APK foi compilado com a configuração atual do `appsettings.json`. 

**Se a API estiver rodando no seu PC:**

1. **Descubra o IP local do seu PC:**
   ```powershell
   ipconfig
   # Procure por "IPv4 Address" na rede ativa
   # Exemplo: 192.168.1.100
   ```

2. **ANTES de usar o app, você precisa recompilar com o IP correto:**
   
   Edite: `SistemaChamados.Mobile/appsettings.json`
   ```json
   {
     "ApiSettings": {
       "BaseUrl": "http://192.168.1.100:5118"
     }
   }
   ```
   
   Depois recompile o APK:
   ```powershell
   .\GerarAPK.ps1
   ```

3. **Importante:**
   - Celular e PC devem estar na **mesma rede Wi-Fi**
   - Firewall do Windows deve permitir conexões na porta 5118
   - API deve estar rodando (`.\IniciarAmbiente.ps1`)

---

### 🌐 Configurar Firewall do Windows

Para permitir que o celular acesse a API no PC:

```powershell
# Executar como Administrador
New-NetFirewallRule -DisplayName "Sistema Chamados API" -Direction Inbound -LocalPort 5118 -Protocol TCP -Action Allow
```

Ou manualmente:
1. Painel de Controle → Firewall do Windows
2. Configurações avançadas
3. Regras de entrada → Nova regra
4. Porta → TCP → 5118
5. Permitir conexão

---

## 📋 Requisitos do Dispositivo Android

### Mínimos:
- **Android:** 5.0 (Lollipop, API 21) ou superior
- **Espaço:** ~100 MB (50 MB APK + 50 MB dados)
- **RAM:** 1 GB mínimo, 2 GB recomendado
- **Internet:** Wi-Fi ou dados móveis para acessar API

### Recomendados:
- **Android:** 8.0 (Oreo, API 26) ou superior
- **Espaço:** 200 MB livre
- **RAM:** 4 GB
- **Tela:** 5" ou maior (app responsivo)

---

## 🧪 Teste Rápido Após Instalação

### 1. Verificar se o app abre
```
✅ Abre tela de login
✅ Logo do Sistema de Chamados aparece
✅ Campos de email e senha visíveis
```

### 2. Teste de conexão com API
```
Credenciais: admin@sistema.com / Admin@123

❌ Se der erro "Não foi possível conectar":
   → Verifique IP da API no appsettings.json
   → Verifique se API está rodando
   → Verifique se celular está na mesma rede

✅ Se logar com sucesso:
   → Dashboard aparece
   → Chamados são carregados
   → Navegação funciona
```

### 3. Teste de funcionalidades
```
✅ Criar novo chamado
✅ Ver detalhes de chamado
✅ Adicionar comentário
✅ Navegação entre abas
✅ Botão "+" em Meus Chamados
✅ Horários exibidos corretamente (local, não UTC)
```

---

## 🔧 Recompilar APK com Novas Configurações

Se você precisar mudar alguma configuração (IP da API, etc.):

### Passo a Passo:

1. **Editar `appsettings.json`:**
   ```json
   {
     "ApiSettings": {
       "BaseUrl": "http://SEU_IP_AQUI:5118"
     }
   }
   ```

2. **Recompilar APK:**
   ```powershell
   cd c:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade
   .\GerarAPK.ps1
   ```

3. **Desinstalar versão antiga no celular:**
   - Configurações → Apps → Sistema de Chamados → Desinstalar

4. **Instalar nova versão:**
   - Transfira novo APK
   - Instale normalmente

---

## 🚀 Gerar APK Assinado (Para Produção)

O APK atual **NÃO está assinado**. Para publicar na Google Play Store ou distribuir profissionalmente:

### 1. Criar Keystore

```powershell
keytool -genkey -v -keystore sistemachamados.keystore -alias sistemachamados -keyalg RSA -keysize 2048 -validity 10000
```

### 2. Configurar no `.csproj`

Edite `SistemaChamados.Mobile.csproj`:
```xml
<PropertyGroup Condition="'$(Configuration)|$(TargetFramework)|$(Platform)'=='Release|net8.0-android|AnyCPU'">
  <AndroidKeyStore>true</AndroidKeyStore>
  <AndroidSigningKeyStore>sistemachamados.keystore</AndroidSigningKeyStore>
  <AndroidSigningKeyAlias>sistemachamados</AndroidSigningKeyAlias>
  <AndroidSigningKeyPass>SUA_SENHA</AndroidSigningKeyPass>
  <AndroidSigningStorePass>SUA_SENHA</AndroidSigningStorePass>
</PropertyGroup>
```

### 3. Gerar APK Assinado

```powershell
.\GerarAPK.ps1
```

---

## 📦 Gerar AAB (Android App Bundle) para Google Play

Se você quiser publicar na Play Store, prefira AAB:

```powershell
dotnet build -c Release -f net8.0-android /p:AndroidPackageFormat=aab
```

O arquivo `.aab` será gerado em:
```
SistemaChamados.Mobile\bin\Release\net8.0-android\com.sistemachamados.mobile-Signed.aab
```

---

## 🐛 Solução de Problemas

### Problema: "App não foi instalado"

**Causas:**
- APK corrompido → Recompilar
- Versão já instalada com assinatura diferente → Desinstalar antiga
- Espaço insuficiente → Liberar espaço

---

### Problema: "Não foi possível conectar à API"

**Soluções:**
1. Verificar IP no `appsettings.json`
2. Verificar se API está rodando:
   ```powershell
   # No PC
   curl http://localhost:5118/api/health
   ```
3. Verificar firewall do Windows
4. Certificar que celular e PC estão na mesma rede
5. Pingar o PC do celular (app de terminal Android)

---

### Problema: "Horários errados"

**Verificar:**
- Fuso horário do celular configurado corretamente
- Se recompilou após correção de fuso horário (20/10/2025)
- Logs no app (se houver)

---

### Problema: "Crash ao navegar"

**Se crashar em alguma tela:**
1. Verifique se está usando a versão mais recente (com correções de navegação)
2. Recompile o APK
3. Desinstale versão antiga completamente antes de instalar nova

---

## 📊 Informações Técnicas do APK

### Estrutura:
```
SistemaChamados-v1.0.apk (64.99 MB)
├── AndroidManifest.xml
├── assemblies/ (DLLs .NET)
├── lib/
│   └── arm64-v8a/ (arquitetura 64-bit)
├── res/ (recursos, imagens, layouts)
└── META-INF/ (assinaturas, se houver)
```

### Permissões Solicitadas:
- `INTERNET` - Para conectar à API
- `ACCESS_NETWORK_STATE` - Para verificar conectividade
- (Outras permissões padrão do MAUI)

### Arquitetura Suportada:
- ARM64 (arm64-v8a) - Dispositivos modernos 64-bit
- ARMv7 (armeabi-v7a) - Dispositivos 32-bit (se compilado)

---

## 🔄 Atualizar APK no Futuro

Quando houver novas versões:

1. **Incrementar versão no `.csproj`:**
   ```xml
   <ApplicationDisplayVersion>1.1</ApplicationDisplayVersion>
   <ApplicationVersion>2</ApplicationVersion>
   ```

2. **Recompilar:**
   ```powershell
   .\GerarAPK.ps1
   ```

3. **Distribuir novo APK**

4. **No celular:**
   - Instalar novo APK por cima (atualização)
   - Ou desinstalar e instalar novo (instalação limpa)

---

## 📝 Checklist Antes de Distribuir

Antes de enviar o APK para outros usuários:

- [ ] Testado em pelo menos 1 dispositivo físico
- [ ] API rodando e acessível
- [ ] IP correto configurado no appsettings.json
- [ ] Firewall configurado
- [ ] Todas as funcionalidades testadas
- [ ] Credenciais de teste funcionando
- [ ] Documentação atualizada

---

## 🎯 Próximos Passos

### Para Desenvolvimento:
1. Continuar testando no dispositivo físico
2. Corrigir bugs encontrados
3. Adicionar novas funcionalidades
4. Recompilar APK periodicamente

### Para Produção:
1. Assinar APK com keystore
2. Gerar AAB para Google Play
3. Preparar materiais de marketing (ícone, screenshots)
4. Criar conta de desenvolvedor Google Play
5. Publicar app

---

## 📞 Suporte e Logs

### Logs do App (quando disponível):
```
%LOCALAPPDATA%\SistemaChamados.Mobile-app-log.txt
```

### Logs do Android (via ADB):
```powershell
adb logcat | Select-String "SistemaChamados"
```

---

**Documentação criada em:** 20/10/2025  
**APK gerado em:** 20/10/2025  
**Versão do App:** 1.0  
**Status:** ✅ Pronto para testes internos

---

## 📚 Documentos Relacionados

- `CREDENCIAIS_TESTE.md` - Usuários de teste
- `CORRECAO_FUSO_HORARIO.md` - Correção de horários
- `CORRECOES_MEUS_CHAMADOS.md` - Correções de navegação
- `CORRECOES_NOVO_CHAMADO.md` - Fluxo de criação de chamado
- `README_MOBILE.md` - Documentação geral do mobile
