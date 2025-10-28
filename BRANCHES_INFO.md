# 🌳 Estrutura de Branches do Repositório

## Branches Principais

### 📌 `master` (Branch Principal)
**Estado Atual:** Versão completa com todas as melhorias implementadas

**Características:**
- ✅ Interface Web completa (8 páginas HTML)
- ✅ Sistema de Handoff Inteligente (IA Gemini)
- ✅ Banco de dados migrado para SQL Server 2022/2025
- ✅ Scripts 100% portáteis
- ✅ Sistema de Níveis de Técnicos (Nível 2 e 3)
- ✅ 4 usuários padrão criados
- ✅ Documentação completa

**Commits Importantes:**
- `1661569` - feat: Implementa interface web completa (106 arquivos)
- `4dca137` - feat: Migra banco de dados para SQL Server
- `471444a` - refactor: Torna scripts PowerShell portáteis
- `e3b0927` - security: Melhora proteção de .gitignore
- `9168cb5` - docs: Documentação de portabilidade
- `d09826e` - fix: Corrige $PSScriptRoot em scriptblocks

**Último Commit:** 27/10/2025

---

### 🔄 `guinrb-develop` (Branch de Referência)
**Origem:** https://github.com/GuiNRB/sistema-chamados-faculdade.git (branch `develop`)

**Características:**
- Estado original do projeto do GuiNRB
- Versão Desktop em desenvolvimento
- Reset de senha implementado
- Frontend desktop com integração ao backend

**Último Commit:** `928f285` - Versão Desktop teste

**Propósito:**
- Referência do estado original do projeto
- Comparação de diferenças entre versões
- Base para merge de funcionalidades específicas

---

## Remotes Configurados

### `origin` (Seu Repositório)
**URL:** https://github.com/Yepiiii/sistema-chamados-faculdade.git
- Branch `master` - Versão atual com todas as melhorias
- Branch `guinrb-develop` - Cópia da develop do GuiNRB

### `guinrb` (Repositório Original)
**URL:** https://github.com/GuiNRB/sistema-chamados-faculdade.git
- Branch `develop` - Versão Desktop em desenvolvimento
- Branch `master` - Versão principal do GuiNRB
- Outras branches de features

### `upstream` (Outro Remote)
**URL:** https://github.com/yepersnnnn/sistema-chamados-faculdade.git

---

## Comparação de Versões

| Característica | `master` (Sua Versão) | `guinrb-develop` |
|----------------|----------------------|------------------|
| **Interface** | Web (HTML/CSS/JS) | Desktop (C#/WPF?) |
| **Banco de Dados** | SQL Server 2022 | LocalDB |
| **IA/Handoff** | ✅ Gemini AI | ❓ |
| **Níveis Técnicos** | ✅ 2 níveis | ❓ |
| **Portabilidade** | ✅ 95% | ❓ |
| **Documentação** | ✅ Extensa | ❓ |
| **Reset Senha** | ✅ | ✅ |

---

## Como Trabalhar com as Branches

### Ver diferenças entre versões:
```bash
# Comparar master com guinrb-develop
git diff master..guinrb-develop

# Ver apenas arquivos diferentes
git diff --name-status master..guinrb-develop

# Ver commits únicos em master
git log guinrb-develop..master --oneline
```

### Trazer funcionalidades específicas do guinrb-develop:
```bash
# Cherry-pick de um commit específico
git checkout master
git cherry-pick <commit-hash>

# Ou fazer merge de arquivos específicos
git checkout guinrb-develop -- path/to/file
```

### Atualizar guinrb-develop com mudanças do repositório original:
```bash
git checkout guinrb-develop
git pull guinrb develop
git push origin guinrb-develop
```

---

## Estrutura de Trabalho Recomendada

```
master (produção)
  ├─ guinrb-develop (referência)
  └─ feature/* (novas funcionalidades)
      └─ merge para master quando pronto
```

---

## Comandos Úteis

### Listar todas as branches:
```bash
git branch -a
```

### Mudar de branch:
```bash
git checkout master
git checkout guinrb-develop
```

### Ver histórico de uma branch:
```bash
git log guinrb-develop --oneline -10
```

### Comparar arquivos entre branches:
```bash
git diff master:Backend/program.cs guinrb-develop:Backend/program.cs
```

---

## ⚠️ Importante

- **NÃO** faça merge direto de `guinrb-develop` em `master` sem revisar
- A branch `guinrb-develop` é para **REFERÊNCIA** apenas
- Sempre teste em branch separada antes de mergear em `master`
- A versão `master` está muito à frente em funcionalidades

---

**Criado em:** 27/10/2025  
**Última Atualização:** 27/10/2025
