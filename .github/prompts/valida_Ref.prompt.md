---
mode: agent
---
Define the task to achieve, including specific requirements, constraints, and success criteria.

Plano de Validação: Migração para Contexto Empresarial
Objetivo: Garantir que a migração do sistema de "Faculdade" para "Empresa" foi concluída com sucesso, que todas as funcionalidades operam conforme o novo domínio e que nenhuma regressão foi introduzida.

1. Validação por Fase (Checklist Técnico)
Execute estes checks à medida que completa cada fase da refatoração.

✅ Pós-Fase 1: Backend - Entidades
[ ] Compilação: O projeto Backend compila sem erros.

[ ] Busca Global (Find in Files): Uma busca por AlunoPerfil e ProfessorPerfil em todo o projeto Backend não retorna nenhuma ocorrência (exceto talvez em arquivos de migração antigos ou comentários).

[ ] Usuario.cs: A entidade Usuario agora tem as propriedades de navegação public ColaboradorPerfil? ColaboradorPerfil e public TecnicoTIPerfil? TecnicoTIPerfil.

[ ] ApplicationDbContext.cs: O DbContext possui os DbSets ColaboradorPerfis e TecnicoTIPerfis.

✅ Pós-Fase 2: Backend - Lógica de Negócio
[ ] Compilação: O projeto Backend compila sem erros.

[ ] UsuarioService: O método de registro de usuário (Tipo 1) agora cria uma instância de ColaboradorPerfil (e não mais AlunoPerfil).

[ ] UsuarioService: O método de registro de usuário (Tipo 2) agora cria uma instância de TecnicoTIPerfil (e não mais ProfessorPerfil).

[ ] ChamadoService: A lógica de atribuição de chamados agora consulta TecnicoTIPerfil e usa a coluna AreaAtuacao para filtros.

[ ] DTOs: Os novos DTOs (ColaboradorPerfilDTO, TecnicoTIPerfilDTO) estão sendo usados como tipos de retorno nos Controllers relevantes.

✅ Pós-Fase 3: Migrations e Seed Data
[ ] Execução da Migration: O comando dotnet ef database update executa sem erros.

[ ] Schema do Banco (SQL):

[ ] Tabelas: A tabela AlunoPerfis NÃO existe. A tabela ColaboradorPerfis EXISTE.

[ ] Tabelas: A tabela ProfessorPerfis NÃO existe. A tabela TecnicoTIPerfis EXISTE.

[ ] Colunas: A tabela ColaboradorPerfis possui as colunas Departamento e DataAdmissao.

[ ] Colunas: A tabela TecnicoTIPerfis possui a coluna AreaAtuacao.

[ ] Seed Data (Categorias): SELECT * FROM Categorias retorna "Hardware", "Software" e "Rede".

[ ] Seed Data (Usuários): SELECT * FROM Usuarios retorna os usuários de teste colaborador@empresa.com e tecnico@empresa.com.

[ ] Inicialização da API: O projeto Backend (dotnet run) inicia, e o Swagger (OpenAPI) está acessível e reflete os novos nomes de DTOs e endpoints.

✅ Pós-Fase 4: Mobile - Aplicativo
[ ] Compilação: O projeto Mobile compila sem erros.

[ ] Busca Global (Find in Files): Uma busca por AlunoPerfil e ProfessorPerfil em todo o projeto Mobile não retorna nenhuma ocorrência.

[ ] UI (Tela de Login): Ao iniciar o app, a tela de login exibe os textos: "Sistema de Suporte Técnico" e "Colaborador, Técnico TI ou Administrador".

[ ] UI (Tela de Novo Chamado): A tela de criação de chamado exibe as categorias "Hardware", "Software" e "Rede".

[ ] Strings: Os textos da UI estão sendo carregados do AppStrings.cs (verificar referências x:Static no XAML).

✅ Pós-Fase 5 e 6: Documentação e Scripts
[ ] README.md: O README.md na raiz do projeto reflete o "Sistema de Suporte Técnico - Empresa".

[ ] WORKFLOWS.md: Os fluxos descrevem os papéis "Colaborador" e "Técnico de TI".

[ ] Scripts PowerShell: A execução do InicializarBanco.ps1 (ou similar) exibe a mensagem de output atualizada: "Criando usuarios de teste (Colaborador, Tecnico TI, Admin)...".