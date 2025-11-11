# Instruções de Teste - Desktop e Mobile

## Configuração Atual
- **IP da Máquina:** 192.168.1.132
- **Backend API:** http://localhost:5246 ou http://192.168.1.132:5246
- **Desktop Frontend:** localhost:8080
- **Mobile APK:** Configurado para http://192.168.1.132:5246/api/

---

## 1. Iniciar o Backend (API)

Abra um terminal PowerShell na pasta `Backend` e execute:

```powershell
cd Backend
dotnet run
```

Aguarde até ver:
```
Now listening on: http://0.0.0.0:5246
```

Acesse http://localhost:5246/swagger para confirmar que a API está rodando.

---

## 2. Testar o Desktop (Frontend Web) no localhost:8080

### Opção A: Usar Live Server (VS Code)
1. Abra `Frontend/Desktop/index.html` no VS Code
2. Clique com botão direito → **Open with Live Server**
3. O navegador abrirá automaticamente em http://127.0.0.1:5500 (ou porta configurada)

### Opção B: Usar Python HTTP Server
Abra um terminal PowerShell na pasta `Frontend/Desktop`:

```powershell
cd Frontend\Desktop
python -m http.server 8080
```

Acesse: http://localhost:8080

### Opção C: Usar http-server (Node.js)
Se tiver Node.js instalado:

```powershell
cd Frontend\Desktop
npx http-server -p 8080 -c-1
```

Acesse: http://localhost:8080

### Credenciais de Teste (Desktop)
- **Admin:** admin@neurohelp.com.br / Admin@123
- **Técnico:** rafael.costa@neurohelp.com.br / Tecnico@123
- **Usuário:** juliana.martins@neurohelp.com.br / User@123

---

## 3. Gerar APK do Mobile (Configurado para IP físico: 192.168.1.132)

### Pré-requisitos
- .NET 8 SDK instalado
- Android SDK e Java JDK configurados
- Variáveis de ambiente configuradas

### Gerar o APK
Execute o script PowerShell na raiz do projeto:

```powershell
.\Scripts\build-mobile-apk.ps1
```

Ou execute manualmente:

```powershell
cd Mobile
dotnet publish -f net8.0-android -c Release
```

O APK será gerado em:
```
Mobile\bin\Release\net8.0-android\publish\sistema-chamados-mobile-Signed.apk
```

### Transferir APK para o dispositivo Android
Método 1 - Via cabo USB:
```powershell
adb install -r "Mobile\bin\Release\net8.0-android\publish\sistema-chamados-mobile-Signed.apk"
```

Método 2 - Compartilhar arquivo:
- Copie o APK para uma pasta compartilhada/Google Drive
- Baixe no celular e instale

### Testar o Mobile
1. **Certifique-se que o celular está na mesma rede Wi-Fi** (rede com IP 192.168.1.x)
2. **Backend deve estar rodando** (http://192.168.1.132:5246)
3. Instale e abra o APK no celular
4. Tente fazer login com as credenciais acima

### Credenciais de Teste (Mobile)
- **Admin:** admin@neurohelp.com.br / Admin@123
- **Técnico:** rafael.costa@neurohelp.com.br / Tecnico@123
- **Usuário:** juliana.martins@neurohelp.com.br / User@123

---

## 4. Configurar Firewall do Windows (Importante!)

Para que o celular acesse o backend, libere a porta 5246 no Firewall:

```powershell
.\Scripts\configure-firewall.ps1
```

Ou execute manualmente:

```powershell
New-NetFirewallRule -DisplayName "Backend API - Sistema Chamados" -Direction Inbound -Protocol TCP -LocalPort 5246 -Action Allow
```

---

## 5. Verificar conectividade

### Do celular, teste se o backend está acessível:
Abra o navegador do celular e acesse:
```
http://192.168.1.132:5246/swagger
```

Se carregar o Swagger, o celular consegue acessar o backend!

### Testar ping do PC:
```powershell
ping 192.168.1.132
```

---

## 6. Troubleshooting

### Desktop não conecta na API
- ✅ Verifique se o Backend está rodando (http://localhost:5246/swagger)
- ✅ Verifique console do navegador (F12) para erros de CORS
- ✅ Confirme que `script-desktop.js` tem `API_BASE = "http://localhost:5246"`

### Mobile não conecta na API
- ✅ Celular e PC estão na mesma rede Wi-Fi?
- ✅ Backend está rodando e acessível em http://192.168.1.132:5246/swagger?
- ✅ Firewall liberou a porta 5246?
- ✅ IP em `Constants.cs` está correto (192.168.1.132)?

### APK não instala no celular
- ✅ Habilite "Fontes Desconhecidas" nas configurações do Android
- ✅ Verifique se o APK foi assinado corretamente

---

## 7. Executar tudo de uma vez (Script rápido)

Crie um arquivo `start-all-dev.ps1` na raiz:

```powershell
# Terminal 1 - Backend
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd Backend; dotnet run"

# Terminal 2 - Desktop
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd Frontend\Desktop; python -m http.server 8080"

Write-Host "✅ Backend: http://localhost:5246/swagger" -ForegroundColor Green
Write-Host "✅ Desktop: http://localhost:8080" -ForegroundColor Cyan
Write-Host "✅ Mobile IP configurado: 192.168.1.132" -ForegroundColor Magenta
```

Execute:
```powershell
.\start-all-dev.ps1
```

---

## Resumo dos Endpoints

| Componente | URL | Observação |
|------------|-----|------------|
| Backend API | http://localhost:5246 | Para Desktop/desenvolvimento |
| Backend API (IP) | http://192.168.1.132:5246 | Para Mobile físico |
| Swagger | http://localhost:5246/swagger | Documentação da API |
| Desktop Web | http://localhost:8080 | Servido via HTTP server |
| Mobile APK | N/A | Configurado para IP 192.168.1.132 |

---

**Última atualização:** 11/11/2025
**IP atual configurado:** 192.168.1.132
