using MediatR;
using SistemaChamados.Core.Entities;

namespace SistemaChamados.Application.UseCases.Chamados.Commands.CreateWithAI;

/// <summary>
/// Command for creating a ticket with AI analysis.
/// Represents the user's intent to create a ticket and get AI-powered categorization.
/// </summary>
/// <param name="DescricaoProblema">Description of the problem provided by the user</param>
/// <param name="UserId">ID of the authenticated user creating the ticket</param>
public record CreateTicketWithAIAnalysisCommand(
    string DescricaoProblema,
    int UserId) : IRequest<CreateTicketWithAIAnalysisResult>;

/// <summary>
/// Result of the CreateTicketWithAIAnalysis operation.
/// Follows the Result pattern to encapsulate success/failure without throwing exceptions.
/// </summary>
public record CreateTicketWithAIAnalysisResult
{
    public bool Success { get; init; }
    public string? ErrorMessage { get; init; }
    public Chamado? Ticket { get; init; }
    
    public static CreateTicketWithAIAnalysisResult Ok(Chamado ticket) => 
        new() { Success = true, Ticket = ticket };
    
    public static CreateTicketWithAIAnalysisResult Error(string message) => 
        new() { Success = false, ErrorMessage = message };
}
