USE [master]
GO
/****** Object:  Database [SistemaChamados]    Script Date: 11/11/2025 16:00:09 ******/
CREATE DATABASE [SistemaChamados]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'SistemaChamadosDb', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\SistemaChamadosDb.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'SistemaChamadosDb_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\SistemaChamadosDb_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [SistemaChamados] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [SistemaChamados].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [SistemaChamados] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [SistemaChamados] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [SistemaChamados] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [SistemaChamados] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [SistemaChamados] SET ARITHABORT OFF 
GO
ALTER DATABASE [SistemaChamados] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [SistemaChamados] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [SistemaChamados] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [SistemaChamados] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [SistemaChamados] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [SistemaChamados] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [SistemaChamados] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [SistemaChamados] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [SistemaChamados] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [SistemaChamados] SET  ENABLE_BROKER 
GO
ALTER DATABASE [SistemaChamados] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [SistemaChamados] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [SistemaChamados] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [SistemaChamados] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [SistemaChamados] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [SistemaChamados] SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE [SistemaChamados] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [SistemaChamados] SET RECOVERY FULL 
GO
ALTER DATABASE [SistemaChamados] SET  MULTI_USER 
GO
ALTER DATABASE [SistemaChamados] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [SistemaChamados] SET DB_CHAINING OFF 
GO
ALTER DATABASE [SistemaChamados] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [SistemaChamados] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [SistemaChamados] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [SistemaChamados] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'SistemaChamados', N'ON'
GO
ALTER DATABASE [SistemaChamados] SET QUERY_STORE = ON
GO
ALTER DATABASE [SistemaChamados] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [SistemaChamados]
GO
/****** Object:  Table [dbo].[__EFMigrationsHistory]    Script Date: 11/11/2025 16:00:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__EFMigrationsHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Anexos]    Script Date: 11/11/2025 16:00:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Anexos](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[NomeArquivo] [nvarchar](255) NOT NULL,
	[CaminhoArquivo] [nvarchar](500) NOT NULL,
	[TamanhoBytes] [bigint] NOT NULL,
	[TipoMime] [nvarchar](100) NOT NULL,
	[DataUpload] [datetime2](7) NOT NULL,
	[ChamadoId] [int] NOT NULL,
	[UsuarioId] [int] NOT NULL,
 CONSTRAINT [PK_Anexos] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Categorias]    Script Date: 11/11/2025 16:00:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Categorias](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Nome] [nvarchar](100) NOT NULL,
	[Descricao] [nvarchar](500) NULL,
	[Ativo] [bit] NOT NULL,
	[DataCadastro] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Categorias] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Chamados]    Script Date: 11/11/2025 16:00:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Chamados](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Titulo] [nvarchar](200) NOT NULL,
	[Descricao] [nvarchar](max) NOT NULL,
	[DataAbertura] [datetime2](7) NOT NULL,
	[DataFechamento] [datetime2](7) NULL,
	[DataUltimaAtualizacao] [datetime2](7) NULL,
	[SlaDataExpiracao] [datetime2](7) NULL,
	[SolicitanteId] [int] NOT NULL,
	[TecnicoId] [int] NULL,
	[CategoriaId] [int] NOT NULL,
	[PrioridadeId] [int] NOT NULL,
	[StatusId] [int] NOT NULL,
	[FechadoPorId] [int] NULL,
 CONSTRAINT [PK_Chamados] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Comentarios]    Script Date: 11/11/2025 16:00:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Comentarios](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Texto] [nvarchar](max) NOT NULL,
	[DataCriacao] [datetime2](7) NOT NULL,
	[IsInterno] [bit] NOT NULL,
	[ChamadoId] [int] NOT NULL,
	[UsuarioId] [int] NOT NULL,
 CONSTRAINT [PK_Comentarios] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Prioridades]    Script Date: 11/11/2025 16:00:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Prioridades](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Nome] [nvarchar](50) NOT NULL,
	[Nivel] [int] NOT NULL,
	[Descricao] [nvarchar](500) NULL,
	[TempoRespostaHoras] [int] NOT NULL,
	[Ativo] [bit] NOT NULL,
	[DataCadastro] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Prioridades] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Status]    Script Date: 11/11/2025 16:00:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Status](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Nome] [nvarchar](50) NOT NULL,
	[Descricao] [nvarchar](500) NULL,
	[Ativo] [bit] NOT NULL,
	[DataCadastro] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Status] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Usuarios]    Script Date: 11/11/2025 16:00:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Usuarios](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[NomeCompleto] [nvarchar](150) NOT NULL,
	[Email] [nvarchar](150) NOT NULL,
	[SenhaHash] [nvarchar](255) NOT NULL,
	[TipoUsuario] [int] NOT NULL,
	[IsInterno] [bit] NOT NULL,
	[Especialidade] [nvarchar](100) NULL,
	[EspecialidadeCategoriaId] [int] NULL,
	[Ativo] [bit] NOT NULL,
	[PasswordResetToken] [nvarchar](255) NULL,
	[ResetTokenExpires] [datetime2](7) NULL,
	[DataCadastro] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Usuarios] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_Anexos_ChamadoId]    Script Date: 11/11/2025 16:00:09 ******/
CREATE NONCLUSTERED INDEX [IX_Anexos_ChamadoId] ON [dbo].[Anexos]
(
	[ChamadoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Anexos_UsuarioId]    Script Date: 11/11/2025 16:00:09 ******/
CREATE NONCLUSTERED INDEX [IX_Anexos_UsuarioId] ON [dbo].[Anexos]
(
	[UsuarioId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Chamados_CategoriaId]    Script Date: 11/11/2025 16:00:09 ******/
CREATE NONCLUSTERED INDEX [IX_Chamados_CategoriaId] ON [dbo].[Chamados]
(
	[CategoriaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Chamados_PrioridadeId]    Script Date: 11/11/2025 16:00:09 ******/
CREATE NONCLUSTERED INDEX [IX_Chamados_PrioridadeId] ON [dbo].[Chamados]
(
	[PrioridadeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Chamados_SolicitanteId]    Script Date: 11/11/2025 16:00:09 ******/
CREATE NONCLUSTERED INDEX [IX_Chamados_SolicitanteId] ON [dbo].[Chamados]
(
	[SolicitanteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Chamados_StatusId]    Script Date: 11/11/2025 16:00:09 ******/
CREATE NONCLUSTERED INDEX [IX_Chamados_StatusId] ON [dbo].[Chamados]
(
	[StatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Chamados_TecnicoId]    Script Date: 11/11/2025 16:00:09 ******/
CREATE NONCLUSTERED INDEX [IX_Chamados_TecnicoId] ON [dbo].[Chamados]
(
	[TecnicoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Comentarios_ChamadoId]    Script Date: 11/11/2025 16:00:09 ******/
CREATE NONCLUSTERED INDEX [IX_Comentarios_ChamadoId] ON [dbo].[Comentarios]
(
	[ChamadoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Comentarios_UsuarioId]    Script Date: 11/11/2025 16:00:09 ******/
CREATE NONCLUSTERED INDEX [IX_Comentarios_UsuarioId] ON [dbo].[Comentarios]
(
	[UsuarioId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Usuarios_Email]    Script Date: 11/11/2025 16:00:09 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Usuarios_Email] ON [dbo].[Usuarios]
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Usuarios_EspecialidadeCategoriaId]    Script Date: 11/11/2025 16:00:09 ******/
CREATE NONCLUSTERED INDEX [IX_Usuarios_EspecialidadeCategoriaId] ON [dbo].[Usuarios]
(
	[EspecialidadeCategoriaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Anexos] ADD  DEFAULT (getdate()) FOR [DataUpload]
GO
ALTER TABLE [dbo].[Categorias] ADD  DEFAULT (CONVERT([bit],(1))) FOR [Ativo]
GO
ALTER TABLE [dbo].[Categorias] ADD  DEFAULT (getdate()) FOR [DataCadastro]
GO
ALTER TABLE [dbo].[Chamados] ADD  DEFAULT (getdate()) FOR [DataAbertura]
GO
ALTER TABLE [dbo].[Comentarios] ADD  DEFAULT (getdate()) FOR [DataCriacao]
GO
ALTER TABLE [dbo].[Comentarios] ADD  DEFAULT (CONVERT([bit],(0))) FOR [IsInterno]
GO
ALTER TABLE [dbo].[Prioridades] ADD  DEFAULT (CONVERT([bit],(1))) FOR [Ativo]
GO
ALTER TABLE [dbo].[Prioridades] ADD  DEFAULT (getdate()) FOR [DataCadastro]
GO
ALTER TABLE [dbo].[Status] ADD  DEFAULT (CONVERT([bit],(1))) FOR [Ativo]
GO
ALTER TABLE [dbo].[Status] ADD  DEFAULT (getdate()) FOR [DataCadastro]
GO
ALTER TABLE [dbo].[Usuarios] ADD  DEFAULT (CONVERT([bit],(1))) FOR [IsInterno]
GO
ALTER TABLE [dbo].[Usuarios] ADD  DEFAULT (CONVERT([bit],(1))) FOR [Ativo]
GO
ALTER TABLE [dbo].[Usuarios] ADD  DEFAULT (getdate()) FOR [DataCadastro]
GO
ALTER TABLE [dbo].[Anexos]  WITH CHECK ADD  CONSTRAINT [FK_Anexos_Chamados_ChamadoId] FOREIGN KEY([ChamadoId])
REFERENCES [dbo].[Chamados] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Anexos] CHECK CONSTRAINT [FK_Anexos_Chamados_ChamadoId]
GO
ALTER TABLE [dbo].[Anexos]  WITH CHECK ADD  CONSTRAINT [FK_Anexos_Usuarios_UsuarioId] FOREIGN KEY([UsuarioId])
REFERENCES [dbo].[Usuarios] ([Id])
GO
ALTER TABLE [dbo].[Anexos] CHECK CONSTRAINT [FK_Anexos_Usuarios_UsuarioId]
GO
ALTER TABLE [dbo].[Chamados]  WITH CHECK ADD  CONSTRAINT [FK_Chamados_Categorias_CategoriaId] FOREIGN KEY([CategoriaId])
REFERENCES [dbo].[Categorias] ([Id])
GO
ALTER TABLE [dbo].[Chamados] CHECK CONSTRAINT [FK_Chamados_Categorias_CategoriaId]
GO
ALTER TABLE [dbo].[Chamados]  WITH CHECK ADD  CONSTRAINT [FK_Chamados_Prioridades_PrioridadeId] FOREIGN KEY([PrioridadeId])
REFERENCES [dbo].[Prioridades] ([Id])
GO
ALTER TABLE [dbo].[Chamados] CHECK CONSTRAINT [FK_Chamados_Prioridades_PrioridadeId]
GO
ALTER TABLE [dbo].[Chamados]  WITH CHECK ADD  CONSTRAINT [FK_Chamados_Status_StatusId] FOREIGN KEY([StatusId])
REFERENCES [dbo].[Status] ([Id])
GO
ALTER TABLE [dbo].[Chamados] CHECK CONSTRAINT [FK_Chamados_Status_StatusId]
GO
ALTER TABLE [dbo].[Chamados]  WITH CHECK ADD  CONSTRAINT [FK_Chamados_Usuarios_FechadoPorId] FOREIGN KEY([FechadoPorId])
REFERENCES [dbo].[Usuarios] ([Id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Chamados] CHECK CONSTRAINT [FK_Chamados_Usuarios_FechadoPorId]
GO
ALTER TABLE [dbo].[Chamados]  WITH CHECK ADD  CONSTRAINT [FK_Chamados_Usuarios_SolicitanteId] FOREIGN KEY([SolicitanteId])
REFERENCES [dbo].[Usuarios] ([Id])
GO
ALTER TABLE [dbo].[Chamados] CHECK CONSTRAINT [FK_Chamados_Usuarios_SolicitanteId]
GO
ALTER TABLE [dbo].[Chamados]  WITH CHECK ADD  CONSTRAINT [FK_Chamados_Usuarios_TecnicoId] FOREIGN KEY([TecnicoId])
REFERENCES [dbo].[Usuarios] ([Id])
GO
ALTER TABLE [dbo].[Chamados] CHECK CONSTRAINT [FK_Chamados_Usuarios_TecnicoId]
GO
ALTER TABLE [dbo].[Comentarios]  WITH CHECK ADD  CONSTRAINT [FK_Comentarios_Chamados_ChamadoId] FOREIGN KEY([ChamadoId])
REFERENCES [dbo].[Chamados] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Comentarios] CHECK CONSTRAINT [FK_Comentarios_Chamados_ChamadoId]
GO
ALTER TABLE [dbo].[Comentarios]  WITH CHECK ADD  CONSTRAINT [FK_Comentarios_Usuarios_UsuarioId] FOREIGN KEY([UsuarioId])
REFERENCES [dbo].[Usuarios] ([Id])
GO
ALTER TABLE [dbo].[Comentarios] CHECK CONSTRAINT [FK_Comentarios_Usuarios_UsuarioId]
GO
ALTER TABLE [dbo].[Usuarios]  WITH CHECK ADD  CONSTRAINT [FK_Usuarios_Categorias_EspecialidadeCategoriaId] FOREIGN KEY([EspecialidadeCategoriaId])
REFERENCES [dbo].[Categorias] ([Id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Usuarios] CHECK CONSTRAINT [FK_Usuarios_Categorias_EspecialidadeCategoriaId]
GO

-- ========================================
-- DADOS INICIAIS (SEED)
-- ========================================

-- Inserir Categorias
SET IDENTITY_INSERT [dbo].[Categorias] ON
GO
INSERT INTO [dbo].[Categorias] ([Id], [Nome], [Descricao], [Ativo]) VALUES
(1, 'Hardware', 'Problemas relacionados a equipamentos e componentes físicos', 1),
(2, 'Software', 'Problemas relacionados a aplicativos e sistemas operacionais', 1),
(3, 'Redes', 'Problemas de conectividade e infraestrutura de rede', 1),
(4, 'Segurança', 'Questões de segurança da informação e proteção de dados', 1)
GO
SET IDENTITY_INSERT [dbo].[Categorias] OFF
GO

-- Inserir Prioridades
SET IDENTITY_INSERT [dbo].[Prioridades] ON
GO
INSERT INTO [dbo].[Prioridades] ([Id], [Nome], [Nivel], [Descricao], [TempoRespostaHoras], [Ativo], [DataCadastro]) VALUES
(1, 'Baixa', 1, 'Assuntos que podem aguardar', 48, 1, GETDATE()),
(2, 'Média', 2, 'Assuntos com importância moderada', 24, 1, GETDATE()),
(3, 'Alta', 3, 'Assuntos urgentes que necessitam atenção imediata', 8, 1, GETDATE()),
(4, 'Crítica', 4, 'Problemas críticos que impedem operações essenciais', 2, 1, GETDATE())
GO
SET IDENTITY_INSERT [dbo].[Prioridades] OFF
GO

-- Inserir Status
SET IDENTITY_INSERT [dbo].[Status] ON
GO
INSERT INTO [dbo].[Status] ([Id], [Nome], [Descricao], [Ativo], [DataCadastro]) VALUES
(1, 'Aberto', 'Chamado recém criado, aguardando atribuição', 1, GETDATE()),
(2, 'Em Andamento', 'Chamado sendo trabalhado por um técnico', 1, GETDATE()),
(3, 'Aguardando Cliente', 'Aguardando retorno do solicitante', 1, GETDATE()),
(4, 'Resolvido', 'Chamado resolvido e aguardando confirmação', 1, GETDATE()),
(5, 'Fechado', 'Chamado finalizado e confirmado pelo solicitante', 1, GETDATE())
GO
SET IDENTITY_INSERT [dbo].[Status] OFF
GO

-- Inserir Usuário Admin Padrão
-- Email: admin@neurohelp.com.br
-- Senha: Admin@123 (hash BCrypt)
SET IDENTITY_INSERT [dbo].[Usuarios] ON
GO
INSERT INTO [dbo].[Usuarios] 
    ([Id], [NomeCompleto], [Email], [SenhaHash], [TipoUsuario], [IsInterno], [Ativo], [DataCadastro])
VALUES 
    (1, 'Administrador NeuroHelp', 'admin@neurohelp.com.br', '$2a$11$XvVyL5hKqF9lqDQ3N5h5XuZrPKxKjF3xN7tJFQxVqwGfY8J3X5.C2', 3, 1, 1, GETDATE())
GO
SET IDENTITY_INSERT [dbo].[Usuarios] OFF
GO

PRINT '========================================';
PRINT 'Banco de dados criado com sucesso!';
PRINT '';
PRINT 'Dados iniciais inseridos:';
PRINT '- 4 Categorias (Hardware, Software, Redes, Seguranca)';
PRINT '- 4 Prioridades (Baixa, Media, Alta, Critica)';
PRINT '- 5 Status (Aberto, Em Andamento, Aguardando Resposta, Resolvido, Fechado)';
PRINT '';
PRINT 'Usuario Admin criado:';
PRINT '  Email: admin@neurohelp.com.br';
PRINT '  Senha: Admin@123';
PRINT '========================================';
GO

USE [master]
GO
ALTER DATABASE [SistemaChamados] SET  READ_WRITE 
GO
