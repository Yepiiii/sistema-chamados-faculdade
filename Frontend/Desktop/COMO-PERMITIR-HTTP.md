# Como Permitir HTTP no Site Vercel (HTTPS)

## ⚠️ Problema: Mixed Content

O Vercel serve o site via **HTTPS**, mas o backend está em **HTTP** (172.177.19.255:5000).

Navegadores modernos bloqueiam requisições HTTP de páginas HTTPS por segurança.

---

## 🔧 Soluções

### Opção 1: Permitir Conteúdo Inseguro (Mais Rápido)

**Chrome/Edge:**
1. Acesse: `https://sistema-chamados-faculdade.vercel.app`
2. Clique no ícone de **cadeado 🔒** (ou ícone de informações) na barra de endereço
3. Clique em **"Configurações do site"**
4. Em **"Conteúdo inseguro"**, selecione **"Permitir"**
5. Recarregue a página (F5)

**Firefox:**
1. Acesse: `https://sistema-chamados-faculdade.vercel.app`
2. Clique no ícone de **escudo 🛡️** na barra de endereço
3. Clique em **"Desabilitar proteção por enquanto"**
4. Recarregue a página (F5)

---

### Opção 2: Usar Ngrok (HTTPS)

Se não quiser alterar configurações do navegador, use o ngrok:

1. Inicie o ngrok apontando para sua API:
   ```bash
   ngrok http 172.177.19.255:5000
   ```

2. O site usará automaticamente o fallback do ngrok (HTTPS)

---

### Opção 3: Configurar HTTPS no Servidor (Avançado)

Configure um certificado SSL no servidor `172.177.19.255` usando:
- **Let's Encrypt** (gratuito, mas requer domínio)
- **Certificado autoassinado** (navegadores mostrarão aviso)

---

## 📱 Mobile App

O app mobile **não tem esse problema** e funciona normalmente com HTTP!

APK: `SistemaChamados-NET9-Fixed.apk`

---

## 🎯 Configuração Atual

- **Frontend (Vercel)**: `http://172.177.19.255:5000` (requer permissão do navegador)
- **Fallback**: `https://unrepudiated-unsolemnised-natalee.ngrok-free.dev` (automático se HTTP falhar)
- **Mobile**: `http://172.177.19.255:5000` (funciona sem restrições)
