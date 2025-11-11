# ⚠️ CORREÇÃO URGENTE - Erro de Migration

## Problema Detectado
A migração `AlignDbSchemaForChamado` foi gerada com **tipos SQLite** (TEXT, INTEGER) ao invés de **SQL Server** (nvarchar, int, datetime2), causando erro ao rodar o Backend:

```
Operand type clash: datetime2 is incompatible with text
```

## ✅ Solução Aplicada

### 1. Migração SQLite inválida foi **REMOVIDA**
- Deletada pasta: `Backend/Migrations/AlignDbSchemaForChamado/`

### 2. Auto-migration **DESABILITADA** temporariamente
- Arquivo: `Backend/program.cs`
- Linha comentada: `context.Database.Migrate();`

### 3. Script SQL manual criado
- Arquivo: `Backend/Scripts/align-db-schema.sql`
- Contém todas as alterações necessárias de schema

---

## 🚀 PASSOS PARA RESOLVER (2 opções)

### **OPÇÃO A: PowerShell Automatizado (Recomendado)**

Execute no terminal PowerShell:

```powershell
cd Backend\Scripts
.\apply-schema-alignment.ps1
```

O script irá:
1. Solicitar credenciais do SQL Server
2. Aplicar o schema alignment automaticamente
3. Confirmar sucesso

### **OPÇÃO B: Manual via SSMS**

1. **Abra o SSMS** e conecte ao servidor SQL Server
2. **Abra o arquivo**: `Backend\Scripts\align-db-schema.sql`
3. **Selecione o banco**: `SistemaChamadosDb`
4. **Execute o script** (F5)

---

## 📋 O que o script SQL faz:

✅ Adiciona coluna `FechadoPorId` em `Chamados`  
✅ Cria FK `FK_Chamados_Usuarios_FechadoPorId`  
✅ Adiciona coluna `TempoRespostaHoras` em `Prioridades`  
✅ Adiciona colunas `IsInterno` e `Especialidade` em `Usuarios`  
✅ Ajusta `Comentarios.Texto` para `NVARCHAR(1000)`  
✅ Ajusta `Categorias.Descricao` para `NVARCHAR(500)`  

---

## ▶️ Depois de aplicar o script:

### 1. Iniciar o Backend:
```powershell
cd Backend
dotnet run
```

### 2. Verificar se rodou sem erros:
- Deve exibir: `Now listening on: http://0.0.0.0:5246`
- Acesse: http://localhost:5246/swagger

### 3. Testar Desktop:
```powershell
cd Frontend\Desktop
python -m http.server 8080
```
- Acesse: http://localhost:8080

### 4. Instalar APK no celular:
- APK gerado em: `APK\builds\com.sistemachamados.mobile-Signed.apk`
- Transfira para o celular e instale
- **Celular e PC devem estar na mesma rede Wi-Fi**

---

## 🔍 Verificar conectividade (Mobile):

No navegador do celular, acesse:
```
http://192.168.1.132:5246/swagger
```

Se carregar o Swagger, o APK conseguirá conectar! ✅

---

## 📝 Credenciais de Teste:

- **Admin:** admin@neurohelp.com.br / Admin@123
- **Técnico:** rafael.costa@neurohelp.com.br / Tecnico@123
- **Usuário:** juliana.martins@neurohelp.com.br / User@123

---

## 🔧 Troubleshooting

### "sqlcmd não reconhecido"
Instale SQL Server Command Line Utilities:
- https://learn.microsoft.com/sql/tools/sqlcmd/sqlcmd-utility

### "Firewall bloqueando porta 5246"
```powershell
.\Scripts\configure-firewall.ps1
```

### "Mobile não conecta"
1. Verifique se PC e celular estão na mesma rede Wi-Fi
2. Confirme IP do PC: `ipconfig | Select-String -Pattern 'IPv4'`
3. Teste no navegador do celular: http://192.168.1.132:5246/swagger

---

**Status:** ✅ Correção aplicada - Pronto para testar  
**Última atualização:** 11/11/2025
