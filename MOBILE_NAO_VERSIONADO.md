# ⚠️ Arquivos Mobile Não Versionados

## Status: Mobile fora do repositório Git

Os arquivos do projeto mobile (`SistemaChamados.Mobile`) **não estão versionados** no repositório atual.

---

## 📱 Arquivos Mobile Alterados (Não Commitados)

### Arquivos Modificados:
1. **ViewModels/NovoChamadoViewModel.cs**
   - Adicionada propriedade `IsAdmin`
   - Adicionada propriedade `PodeUsarClassificacaoManual`
   - Atualizada lógica `ExibirClassificacaoManual`

2. **Views/NovoChamadoPage.xaml**
   - Botão "Opções Avançadas" escondido para não-admins
   - Descrições adaptadas por tipo de usuário

3. **Helpers/InvertedBoolConverter.cs** (NOVO)
   - Conversor para inverter booleano na UI

4. **App.xaml**
   - Registrado `InvertedBoolConverter` como recurso global

---

## 🔧 Como Versionar o Mobile

Se quiser versionar o mobile também, você tem 2 opções:

### Opção 1: Adicionar Mobile ao Repositório Existente
```powershell
cd c:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade
git add ../SistemaChamados.Mobile/
git commit -m "feat(mobile): adiciona restrição de UI para classificação manual"
git push
```

### Opção 2: Criar Repositório Separado para Mobile
```powershell
cd c:\Users\opera\sistema-chamados-faculdade\SistemaChamados.Mobile
git init
git add .
git commit -m "Initial commit: MAUI app com restrições de permissão"
git remote add origin <URL_DO_SEU_REPO_MOBILE>
git push -u origin master
```

---

## ✅ O Que Foi Enviado ao GitHub

✅ **Backend:**
- `API/Controllers/ChamadosController.cs` - Restrição de classificação manual

✅ **Documentação:**
- `RESTRICAO_CLASSIFICACAO_MANUAL.md` - Documentação completa
- `TestarRestricaoManual.ps1` - Script de testes

✅ **Segurança:**
- Arquivo `.env` protegido pelo `.gitignore`
- Chave do Gemini **NÃO foi exposta**

---

## 🔐 Segurança Confirmada

```bash
# Verificar que .env não foi incluído
git log --all --full-history --source --  '*/.env'
# Resultado esperado: (vazio)
```

---

**Data:** 17/10/2025  
**Status:** Backend e documentação enviados com sucesso! Mobile pendente de versionamento.
