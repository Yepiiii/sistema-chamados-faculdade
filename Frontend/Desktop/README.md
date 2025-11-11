# Frontend Desktop - Sistema de Chamados

## Deploy no Vercel

### Pré-requisitos
- Conta no [Vercel](https://vercel.com)
- Vercel CLI instalado (opcional): `npm i -g vercel`

### Opção 1: Deploy via Interface Web (Recomendado)

1. Acesse https://vercel.com
2. Faça login com sua conta GitHub
3. Clique em "Add New" → "Project"
4. Importe o repositório `sistema-chamados-faculdade`
5. Configure o projeto:
   - **Framework Preset**: Other
   - **Root Directory**: `Frontend/Desktop`
   - **Build Command**: (deixe vazio)
   - **Output Directory**: (deixe vazio ou use `.`)
6. Clique em "Deploy"

### Opção 2: Deploy via CLI

```bash
# Navegar para o diretório
cd Frontend/Desktop

# Fazer login no Vercel (primeira vez)
vercel login

# Deploy de produção
vercel --prod
```

### Configuração da API Backend

Após o deploy, você precisa atualizar a URL da API no arquivo `script-desktop.js`:

1. Localize a linha com `const API_URL`
2. Altere para a URL do seu backend (exemplo: https://seu-backend.azurewebsites.net)

**IMPORTANTE**: Configure as variáveis de ambiente no Vercel:
- Vá em Settings → Environment Variables
- Adicione a URL da API backend se necessário

### CORS no Backend

Certifique-se de que seu backend permite requisições do domínio do Vercel:

```csharp
// No program.cs do backend
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowVercel", policy =>
    {
        policy.WithOrigins(
            "http://localhost:8080",
            "https://seu-app.vercel.app" // Adicione sua URL do Vercel aqui
        )
        .AllowAnyHeader()
        .AllowAnyMethod()
        .AllowCredentials();
    });
});
```

### Estrutura de Arquivos

```
Frontend/Desktop/
├── index.html                      # Página de login
├── script-desktop.js               # Lógica principal
├── style-desktop.css               # Estilos
├── vercel.json                     # Configuração do Vercel
├── admin-*.html                    # Páginas de admin
├── tecnico-*.html                  # Páginas de técnico
├── user-*.html                     # Páginas de usuário
└── img/                            # Imagens e logos
```

### URLs de Produção

Após o deploy, você receberá URLs como:
- **Produção**: https://seu-app.vercel.app
- **Preview**: URLs únicas para cada commit

### Troubleshooting

**Erro de CORS:**
- Verifique se o backend está configurado para aceitar requisições do domínio Vercel
- Adicione o domínio nas configurações de CORS

**Páginas não carregam:**
- Verifique se o `vercel.json` está configurado corretamente
- Confirme que todos os arquivos HTML estão presentes

**API não responde:**
- Verifique a URL da API no `script-desktop.js`
- Teste a API diretamente no navegador
- Verifique os logs do backend

### Atualizações

O Vercel automaticamente faz deploy de:
- **Push na branch master**: Deploy de produção
- **Pull Requests**: Deploy de preview

### Domínio Personalizado

Para usar um domínio próprio:
1. Vá em Settings → Domains no painel do Vercel
2. Adicione seu domínio
3. Configure os registros DNS conforme instruído
