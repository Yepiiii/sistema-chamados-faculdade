# ⚡ Guia Rápido - APK Sistema de Chamados

**Data:** 20/10/2025  
**APK:** `c:\Users\opera\sistema-chamados-faculdade\APK\SistemaChamados-v1.0.apk`  
**Tamanho:** 64.99 MB

---

## 🚀 Instalação Rápida (3 Passos)

### 1️⃣ Transfira o APK para o Celular

**Mais fácil: WhatsApp**
- Envie o APK para você mesmo no WhatsApp
- No celular, baixe o arquivo

**Alternativa: Cabo USB**
- Conecte celular ao PC
- Copie o APK para a pasta Downloads do celular

---

### 2️⃣ Instale o APK

1. Abra o arquivo APK no celular
2. Se pedir, ative "Instalar de fontes desconhecidas"
3. Clique em "Instalar"
4. Aguarde instalação
5. Abra o app "Sistema de Chamados"

---

### 3️⃣ Configure a Conexão com a API

**IMPORTANTE:** O celular precisa se conectar ao PC onde a API está rodando.

#### ⚙️ Configuração Atual:
- **IP do PC:** `192.168.0.18` (rede principal)
- **Porta API:** `5118`
- **URL API:** `http://192.168.0.18:5118`

#### ✅ Checklist:

**No PC:**
- [ ] API está rodando? Execute: `.\IniciarAmbiente.ps1`
- [ ] Firewall permite conexões na porta 5118?

**No Celular:**
- [ ] Está conectado ao **Wi-Fi** (mesma rede do PC)
- [ ] Wi-Fi é `192.168.0.x` (mesma subnet)

---

## 🔥 Liberar Firewall (EXECUTAR NO PC)

```powershell
# Executar PowerShell como ADMINISTRADOR
New-NetFirewallRule -DisplayName "Sistema Chamados API" -Direction Inbound -LocalPort 5118 -Protocol TCP -Action Allow
```

---

## 🧪 Testar Conexão

### No PC:
```powershell
# 1. Verificar se API está rodando
curl http://localhost:5118/api/health

# 2. Verificar seu IP
ipconfig | Select-String "IPv4"
# Confirme: 192.168.0.18
```

### No Celular:
1. Abra o navegador Chrome
2. Acesse: `http://192.168.0.18:5118/api/health`
3. Deve retornar: `{"status": "healthy"}` ou similar
4. ✅ Se funcionou → API acessível
5. ❌ Se não carregou → Verificar checklist acima

---

## 🔑 Login no App

Após instalar e configurar:

**Admin:**
- Email: `admin@sistema.com`
- Senha: `Admin@123`

**Professor:**
- Email: `prof.silva@faculdade.edu`
- Senha: `Prof@123`

**Aluno:**
- Email: `joao.santos@aluno.edu`
- Senha: `Aluno@123`

---

## ❌ Problemas Comuns

### "Não foi possível conectar"

**Solução:**
1. Verificar se PC e celular estão na **mesma rede Wi-Fi**
2. Verificar se API está rodando no PC
3. Verificar firewall (executar comando acima)
4. Confirmar IP do PC: `192.168.0.18`

### "App não instala"

**Solução:**
1. Ativar "Fontes desconhecidas" nas configurações do celular
2. Certificar que tem espaço suficiente (~100 MB)
3. Desinstalar versão antiga se houver

### "Horários estão errados"

**Solução:**
- Este APK já tem correção de fuso horário
- Verifique se o fuso horário do celular está correto
- Horários devem aparecer em horário local (UTC-3 Brasil)

---

## 📱 Requisitos do Celular

- **Android:** 5.0 ou superior
- **Espaço:** 100 MB livre
- **Internet:** Wi-Fi (mesma rede do PC com API)

---

## 🎯 Funcionalidades Testadas

✅ Login e autenticação  
✅ Dashboard com chamados recentes  
✅ Criar novo chamado  
✅ Ver detalhes de chamado  
✅ Adicionar comentários  
✅ Navegação entre telas  
✅ Filtros e pesquisa  
✅ Perfil de usuário  
✅ Horários em fuso local  

---

## 🔄 Recompilar se Mudar de Rede

Se o IP do PC mudar (mudar de rede Wi-Fi):

1. **Descobrir novo IP:**
   ```powershell
   ipconfig | Select-String "IPv4"
   ```

2. **Editar configuração:**
   ```
   Arquivo: SistemaChamados.Mobile\appsettings.json
   
   Mudar "BaseUrl" para: "http://NOVO_IP:5118"
   ```

3. **Recompilar APK:**
   ```powershell
   .\GerarAPK.ps1
   ```

4. **Reinstalar no celular**

---

## 📞 Suporte

- Documentação completa: `APK_README.md`
- Credenciais de teste: `CREDENCIAIS_TESTE.md`
- Correções aplicadas: `CORRECAO_FUSO_HORARIO.md`, `CORRECOES_*.md`

---

**Status:** ✅ APK Pronto para Uso  
**Última Atualização:** 20/10/2025

---

## 📝 Resumo Visual

```
PC (192.168.0.18:5118)
         │
         │ Wi-Fi (192.168.0.x)
         │
         ↓
Celular Android
├─ App instalado ✅
├─ Mesma rede ✅
├─ Login funcionando ✅
└─ Criar chamados ✅
```

**Pronto para testar!** 🎉
