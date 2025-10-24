namespace SistemaChamados.Application.DTOs
{
    /// <summary>
    /// DTO que representa a análise completa do chamado pela IA,
    /// incluindo a decisão de atribuição baseada nos scores do handoff
    /// </summary>
    public class AnaliseChamadoComHandoffDto
    {
        /// <summary>
        /// ID do técnico escolhido pela IA
        /// </summary>
        public int TecnicoIdEscolhido { get; set; }
        
        /// <summary>
        /// Nome do técnico escolhido
        /// </summary>
        public string? TecnicoNome { get; set; }
        
        /// <summary>
        /// Categoria sugerida pela IA (Hardware, Software, Rede, Infraestrutura)
        /// </summary>
        public string? CategoriaSugerida { get; set; }
        
        /// <summary>
        /// Prioridade sugerida pela IA (Baixa, Média-Baixa, Média-Alta, Alta, Crítica)
        /// </summary>
        public string? PrioridadeSugerida { get; set; }
        
        /// <summary>
        /// Justificativa da IA para a escolha do técnico
        /// Deve referenciar os scores recebidos do handoff
        /// </summary>
        public string? JustificativaEscolha { get; set; }
        
        /// <summary>
        /// Score final do técnico escolhido (vindo do handoff)
        /// </summary>
        public double ScoreFinal { get; set; }
        
        /// <summary>
        /// Lista completa de scores que foram passados para a IA como contexto
        /// </summary>
        public List<TecnicoScoreDto>? ScoresContexto { get; set; }
        
        /// <summary>
        /// Indica se a IA concordou com o top score do handoff ou escolheu outro técnico
        /// </summary>
        public bool ConcordouComHandoff { get; set; }
        
        /// <summary>
        /// Observações adicionais da análise da IA
        /// </summary>
        public string? Observacoes { get; set; }
    }
}
