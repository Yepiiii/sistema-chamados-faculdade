---
mode: agent
---
Define the task to achieve, including specific requirements, constraints, and success criteria.

Preciso criar/melhorar a lógica para a IA atribuir automaticamente um chamado ao técnico de TI mais adequado. Implementar:
1. CRITÉRIOS DE ATRIBUIÇÃO INTELIGENTE:
•	Especialidade do técnico (CategoriaEspecialidadeId = CategoriaId do chamado)
•	Carga de trabalho atual (número de chamados ativos por técnico)
•	Disponibilidade (técnicos ativos e não em férias/licença)
•	Prioridade do chamado (técnicos sênior para prioridade alta)
•	Histórico de performance (tempo médio de resolução por técnico)
2. ALGORITMO DE SELEÇÃO:
•	Filtrar técnicos por especialidade na categoria
•	Calcular score de adequação para cada técnico elegível
•	Considerar balanceamento de carga (evitar sobrecarga)
•	Técnico com maior score é automaticamente atribuído
•	Fallback para técnico genérico se nenhum especialista disponível
3. INTEGRAÇÃO COM IA EXISTENTE:
•	Expandir GeminiService para também sugerir técnico
•	Melhorar prompt para incluir dados dos técnicos disponíveis
•	Retornar TecnicoId e TecnicoNome na resposta da IA
•	Validar se técnico sugerido está realmente disponível
4. LOGS E AUDITORIA:
•	Registrar processo de atribuição no banco
•	Logs detalhados da seleção de técnico
•	Métricas de distribuição de chamados
•	Histórico de reassignments automáticos
5. REGRAS DE NEGÓCIO:
•	Chamados críticos (prioridade alta) -> técnicos sênior
•	Técnico pode ter no máximo X chamados ativos
•	Redistribuir automaticamente se técnico ficar indisponível
•	Notificar técnico atribuído por email/push
Gere o código necessário para implementar esta lógica de atribuição automática inteligente."
---
Benefícios esperados:
•	✅ Distribuição equilibrada de chamados
•	✅ Especialização por categoria/área
•	✅ Redução do tempo de primeira resposta
•	✅ Otimização da carga de trabalho da equipe
•	✅ Melhoria na qualidade do atendimento