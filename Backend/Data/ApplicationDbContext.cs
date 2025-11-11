using Microsoft.EntityFrameworkCore;
using SistemaChamados.Core.Entities;

namespace SistemaChamados.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }
    
    public DbSet<Usuario> Usuarios { get; set; }
    public DbSet<Chamado> Chamados { get; set; }
    public DbSet<Comentario> Comentarios { get; set; }
    public DbSet<Anexo> Anexos { get; set; }
    public DbSet<Categoria> Categorias { get; set; }
    public DbSet<Prioridade> Prioridades { get; set; }
    public DbSet<Status> Status { get; set; }
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        modelBuilder.Entity<Usuario>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.NomeCompleto).IsRequired().HasMaxLength(150);
            entity.Property(e => e.Email).IsRequired().HasMaxLength(150);
            entity.Property(e => e.SenhaHash).IsRequired().HasMaxLength(255);
            entity.Property(e => e.TipoUsuario).IsRequired();
            entity.Property(e => e.IsInterno).HasDefaultValue(true);
            entity.Property(e => e.Especialidade).HasMaxLength(100);
            entity.Property(e => e.Ativo).HasDefaultValue(true);
            entity.Property(e => e.PasswordResetToken).HasMaxLength(255);
            entity.Property(e => e.DataCadastro).HasDefaultValueSql("GETDATE()");
            
            entity.HasIndex(e => e.Email).IsUnique();
            
            entity.HasOne(e => e.EspecialidadeCategoria)
                .WithMany(c => c.TecnicosEspecializados)
                .HasForeignKey(e => e.EspecialidadeCategoriaId)
                .OnDelete(DeleteBehavior.SetNull);
        });
        
        modelBuilder.Entity<Chamado>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Titulo).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Descricao).IsRequired();
            entity.Property(e => e.DataAbertura).HasDefaultValueSql("GETDATE()");
            
            entity.HasOne(e => e.Solicitante)
                .WithMany(u => u.ChamadosSolicitados)
                .HasForeignKey(e => e.SolicitanteId)
                .OnDelete(DeleteBehavior.Restrict);
            
            entity.HasOne(e => e.Tecnico)
                .WithMany(u => u.ChamadosAtribuidos)
                .HasForeignKey(e => e.TecnicoId)
                .OnDelete(DeleteBehavior.Restrict);
            
            entity.HasOne(e => e.Categoria)
                .WithMany(c => c.Chamados)
                .HasForeignKey(e => e.CategoriaId)
                .OnDelete(DeleteBehavior.Restrict);
            
            entity.HasOne(e => e.Prioridade)
                .WithMany(p => p.Chamados)
                .HasForeignKey(e => e.PrioridadeId)
                .OnDelete(DeleteBehavior.Restrict);
            
            entity.HasOne(e => e.Status)
                .WithMany(s => s.Chamados)
                .HasForeignKey(e => e.StatusId)
                .OnDelete(DeleteBehavior.Restrict);

            // Mapeamento para o usuário que fechou o chamado (FechadoPorId)
            entity.HasOne(e => e.FechadoPor)
                .WithMany()
                .HasForeignKey(e => e.FechadoPorId)
                .OnDelete(DeleteBehavior.SetNull);
        });
        
        modelBuilder.Entity<Comentario>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Texto).IsRequired().HasMaxLength(1000);
            entity.Property(e => e.DataCriacao).HasDefaultValueSql("GETDATE()");
            entity.Property(e => e.IsInterno).HasDefaultValue(false);
            
            entity.HasOne(e => e.Chamado)
                .WithMany(c => c.Comentarios)
                .HasForeignKey(e => e.ChamadoId)
                .OnDelete(DeleteBehavior.Cascade);
            
            entity.HasOne(e => e.Usuario)
                .WithMany(u => u.Comentarios)
                .HasForeignKey(e => e.UsuarioId)
                .OnDelete(DeleteBehavior.Restrict);
        });
        
        modelBuilder.Entity<Anexo>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.NomeArquivo).IsRequired().HasMaxLength(255);
            entity.Property(e => e.CaminhoArquivo).IsRequired().HasMaxLength(500);
            entity.Property(e => e.TipoMime).IsRequired().HasMaxLength(100);
            entity.Property(e => e.DataUpload).HasDefaultValueSql("GETDATE()");
            
            entity.HasOne(e => e.Chamado)
                .WithMany(c => c.Anexos)
                .HasForeignKey(e => e.ChamadoId)
                .OnDelete(DeleteBehavior.Cascade);
            
            entity.HasOne(e => e.Usuario)
                .WithMany()
                .HasForeignKey(e => e.UsuarioId)
                .OnDelete(DeleteBehavior.Restrict);
        });
        
        modelBuilder.Entity<Categoria>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Nome).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Descricao).HasMaxLength(500);
            entity.Property(e => e.Ativo).HasDefaultValue(true);
            entity.Property(e => e.DataCadastro).HasDefaultValueSql("GETDATE()");
        });
        
        modelBuilder.Entity<Prioridade>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Nome).IsRequired().HasMaxLength(50);
            entity.Property(e => e.Nivel).IsRequired();
            entity.Property(e => e.Descricao).HasMaxLength(500);
            entity.Property(e => e.TempoRespostaHoras).IsRequired();
            entity.Property(e => e.Ativo).HasDefaultValue(true);
            entity.Property(e => e.DataCadastro).HasDefaultValueSql("GETDATE()");
        });
        
        modelBuilder.Entity<Status>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Nome).IsRequired().HasMaxLength(50);
            entity.Property(e => e.Descricao).HasMaxLength(500);
            entity.Property(e => e.Ativo).HasDefaultValue(true);
            entity.Property(e => e.DataCadastro).HasDefaultValueSql("GETDATE()");
        });
    }
}
