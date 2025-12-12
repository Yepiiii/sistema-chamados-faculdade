namespace SistemaChamados.Infrastructure.Persistence.Seeders;

/// <summary>
/// Interface base para todos os seeders de dados.
/// Implementa o Single Responsibility Principle: cada seeder é responsável por popular um conjunto específico de dados.
/// </summary>
public interface IDataSeeder
{
    /// <summary>
    /// Executa o seed dos dados no banco.
    /// Cada implementação deve verificar se os dados já existem antes de popular.
    /// </summary>
    /// <returns>Task representando a operação assíncrona.</returns>
    Task SeedAsync();
    
    /// <summary>
    /// Ordem de execução do seeder.
    /// Seeders com Order menor executam primeiro (ex: MetadataSeeder deve vir antes de UserSeeder).
    /// </summary>
    int Order { get; }
}
