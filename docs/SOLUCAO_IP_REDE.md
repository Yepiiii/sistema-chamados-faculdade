# 🔧 Solução de Problemas - IP e Conexão

## ❌ Problema: Swagger não abre no celular

### Sintoma
Ao acessar `http://192.168.56.1:5246/swagger` no navegador do celular, a página não carrega.

### Causa Provável
O IP `192.168.56.1` é um **IP de rede virtual** (VirtualBox, VMware, Hyper-V) e não é acessível por dispositivos físicos na rede Wi-Fi.

### ✅ Solução

#### Opção 1: Usar IP correto da rede Wi-Fi (RECOMENDADO)

1. **Desconecte adaptadores virtuais** (se possível):
   ```powershell
   # Ver todos os adaptadores de rede
   Get-NetAdapter | Select-Object Name, Status, InterfaceDescription
   
   # Desabilitar adaptador virtual (exemplo: VirtualBox)
   Disable-NetAdapter -Name "VirtualBox Host-Only Network" -Confirm:$false
   ```

2. **Obter IP correto da rede Wi-Fi**:
   ```powershell
   # Ver IP da rede Wi-Fi
   ipconfig
   
   # Procurar por "Adaptador de Rede sem Fio Wi-Fi"
   # O IP deve ser algo como: 192.168.0.x ou 192.168.1.x
   ```

3. **Reconfigurar IP no projeto**:
   ```powershell
   cd Scripts
   
   # O script agora vai detectar o IP correto
   .\ConfigurarIP.ps1
   
   # Verificar se o IP mudou (deve ser 192.168.0.x ou similar)
   # Se ainda mostrar 192.168.56.x, insira manualmente
   ```

#### Opção 2: Forçar IP manualmente

Se o script detectar o IP errado, force manualmente:

```powershell
cd Scripts
.\ConfigurarIP.ps1

# Quando perguntar, digite o IP correto da sua rede Wi-Fi
# Exemplo: 192.168.0.105
```

**Como descobrir o IP correto:**

1. No PC, abra PowerShell:
   ```powershell
   ipconfig
   ```

2. Procure por **"Adaptador de Rede sem Fio Wi-Fi"**:
   ```
   Adaptador de Rede sem Fio Wi-Fi:
   
      Endereço IPv4. . . . . . . . : 192.168.0.105   <-- ESTE É O IP CORRETO
      Máscara de Sub-rede . . . . : 255.255.255.0
      Gateway Padrão. . . . . . . : 192.168.0.1
   ```

3. No celular, abra Configurações → Wi-Fi → Nome da rede conectada
   - IP deve começar com o mesmo: `192.168.0.xxx`

#### Opção 3: Usar emulador Android em vez de celular físico

Se você não precisa testar em celular físico agora:

```powershell
cd Scripts
.\IniciarAmbiente.ps1

# Isso iniciará:
# - API em localhost:5246
# - Emulador Android (que usa 10.0.2.2 para localhost)
```

### 🔍 Verificar qual IP está configurado

```powershell
# Ver IP atual em Constants.cs
Get-Content "Mobile\Helpers\Constants.cs" | Select-String "BaseUrlPhysicalDevice"

# Deve mostrar algo como:
# public static string BaseUrlPhysicalDevice => "http://192.168.0.105:5246/api/";
#                                                       ^^^^^^^^^^^^^^
#                                                       IP CORRETO da rede Wi-Fi
```

### ✅ Checklist para Celular Físico

- [ ] PC e celular na **mesma rede Wi-Fi**
- [ ] IP do PC começa com `192.168.0.` ou `192.168.1.` (não `192.168.56.`)
- [ ] IP do celular começa com o **mesmo** prefixo
- [ ] Firewall liberado (porta 5246)
- [ ] API rodando em `0.0.0.0:5246` (não apenas localhost)

### 🧪 Teste Rápido

```powershell
# 1. Ver seu IP correto
ipconfig | findstr "IPv4"

# 2. Reconfigurar
cd Scripts
.\ConfigurarIP.ps1

# 3. Gerar APK
.\GerarAPK.ps1

# 4. Iniciar API para rede
.\IniciarAPIMobile.ps1

# 5. No celular, testar no navegador:
# http://SEU_IP_CORRETO:5246/swagger
```

### 📱 IPs por Tipo de Rede

| Tipo de Rede | Formato de IP | Exemplo | Funciona com Celular? |
|--------------|---------------|---------|----------------------|
| **Wi-Fi doméstica** | `192.168.0.x` ou `192.168.1.x` | `192.168.0.105` | ✅ SIM |
| **Rede virtual (VirtualBox)** | `192.168.56.x` | `192.168.56.1` | ❌ NÃO |
| **Rede virtual (VMware)** | `192.168.xxx.x` | `192.168.137.1` | ❌ NÃO |
| **Localhost** | `127.0.0.1` | `127.0.0.1` | ❌ NÃO |
| **Emulador Android** | `10.0.2.2` | `10.0.2.2` | ⚠️ Só emulador |

### 🎯 Resumo da Solução

```powershell
# Passo 1: Descobrir IP correto
ipconfig

# Passo 2: Desabilitar redes virtuais (opcional)
Disable-NetAdapter -Name "VirtualBox*" -Confirm:$false

# Passo 3: Reconfigurar projeto
cd c:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade\Scripts
.\ConfigurarIP.ps1
# Digite o IP correto manualmente se necessário

# Passo 4: Gerar APK
.\GerarAPK.ps1

# Passo 5: Iniciar API
.\IniciarAPIMobile.ps1

# Passo 6: Testar no celular
# Abrir navegador: http://IP_CORRETO:5246/swagger
```

### 💡 Dica Importante

O IP **192.168.56.1** é típico de:
- VirtualBox Host-Only Adapter
- VMware Virtual Ethernet Adapter

Esses IPs **não são acessíveis** por dispositivos na rede Wi-Fi real. Você precisa do IP da sua placa Wi-Fi física.

---

**Se mesmo assim não funcionar:**

1. Verifique o firewall do Windows (porta 5246 deve estar liberada)
2. Verifique se o celular está realmente na mesma rede
3. Tente pingar o PC do celular (apps como "Network Analyzer")
4. Use `netstat -ano | findstr :5246` para confirmar que a API está escutando

---

**Última atualização:** 21/10/2025
