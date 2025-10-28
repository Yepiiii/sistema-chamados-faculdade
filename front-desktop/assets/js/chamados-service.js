/**
 * Chamados Service - Gerenciamento de Chamados
 * Sistema de Chamados - Faculdade
 */

class ChamadosService {
    constructor() {
        this.api = window.api;
    }

    /**
     * Busca todos os chamados
     * @returns {Promise<Array>} - Lista de chamados
     */
    async getChamados() {
        try {
            const response = await this.api.get('/chamados');
            return response;
        } catch (error) {
            console.error('Erro ao buscar chamados:', error);
            throw error;
        }
    }

    /**
     * Busca chamado por ID
     * @param {number} id - ID do chamado
     * @returns {Promise<object>} - Dados do chamado
     */
    async getChamadoPorId(id) {
        try {
            const response = await this.api.get(`/chamados/${id}`);
            return response;
        } catch (error) {
            console.error('Erro ao buscar chamado:', error);
            throw error;
        }
    }

    /**
     * Cria novo chamado
     * @param {object} chamadoData - Dados do chamado
     * @returns {Promise<object>} - Chamado criado
     */
    async criarChamado(chamadoData) {
        try {
            const response = await this.api.post('/chamados', chamadoData);
            return response;
        } catch (error) {
            console.error('Erro ao criar chamado:', error);
            throw error;
        }
    }

    /**
     * Atualiza chamado existente
     * @param {number} id - ID do chamado
     * @param {object} updateData - Dados para atualizar
     * @returns {Promise<object>} - Chamado atualizado
     */
    async atualizarChamado(id, updateData) {
        try {
            const response = await this.api.put(`/chamados/${id}`, updateData);
            return response;
        } catch (error) {
            console.error('Erro ao atualizar chamado:', error);
            throw error;
        }
    }

    /**
     * Analisa chamado com IA
     * @param {string} descricaoProblema - Descrição do problema
     * @returns {Promise<object>} - Chamado criado com análise da IA
     */
    async analisarChamado(descricaoProblema) {
        try {
            const response = await this.api.post('/chamados/analisar', {
                descricaoProblema
            });
            return response;
        } catch (error) {
            console.error('Erro ao analisar chamado:', error);
            throw error;
        }
    }

    /**
     * Busca categorias ativas
     * @returns {Promise<Array>} - Lista de categorias
     */
    async getCategorias() {
        try {
            const response = await this.api.get('/categorias');
            return response;
        } catch (error) {
            console.error('Erro ao buscar categorias:', error);
            throw error;
        }
    }

    /**
     * Busca prioridades ativas
     * @returns {Promise<Array>} - Lista de prioridades
     */
    async getPrioridades() {
        try {
            const response = await this.api.get('/prioridades');
            return response;
        } catch (error) {
            console.error('Erro ao buscar prioridades:', error);
            throw error;
        }
    }

    /**
     * Busca status ativos
     * @returns {Promise<Array>} - Lista de status
     */
    async getStatus() {
        try {
            const response = await this.api.get('/status');
            return response;
        } catch (error) {
            console.error('Erro ao buscar status:', error);
            throw error;
        }
    }

    /**
     * Cria nova categoria
     * @param {object} categoriaData - Dados da categoria
     * @returns {Promise<object>} - Categoria criada
     */
    async criarCategoria(categoriaData) {
        try {
            const response = await this.api.post('/categorias', categoriaData);
            return response;
        } catch (error) {
            console.error('Erro ao criar categoria:', error);
            throw error;
        }
    }

    /**
     * Cria nova prioridade
     * @param {object} prioridadeData - Dados da prioridade
     * @returns {Promise<object>} - Prioridade criada
     */
    async criarPrioridade(prioridadeData) {
        try {
            const response = await this.api.post('/prioridades', prioridadeData);
            return response;
        } catch (error) {
            console.error('Erro ao criar prioridade:', error);
            throw error;
        }
    }

    /**
     * Cria novo status
     * @param {object} statusData - Dados do status
     * @returns {Promise<object>} - Status criado
     */
    async criarStatus(statusData) {
        try {
            const response = await this.api.post('/status', statusData);
            return response;
        } catch (error) {
            console.error('Erro ao criar status:', error);
            throw error;
        }
    }

    /**
     * Formata data para exibição
     * @param {string} dateString - Data em string
     * @returns {string} - Data formatada
     */
    formatarData(dateString) {
        if (!dateString) return '-';
        
        const date = new Date(dateString);
        return date.toLocaleDateString('pt-BR', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    /**
     * Obtém cor da prioridade
     * @param {string} prioridade - Nome da prioridade
     * @returns {string} - Classe CSS da cor
     */
    getCorPrioridade(prioridade) {
        const cores = {
            'Baixa': 'priority-low',
            'Média': 'priority-medium',
            'Alta': 'priority-high',
            'Crítica': 'priority-critical'
        };
        return cores[prioridade] || 'priority-medium';
    }

    /**
     * Obtém cor do status
     * @param {string} status - Nome do status
     * @returns {string} - Classe CSS da cor
     */
    getCorStatus(status) {
        const cores = {
            'Aberto': 'status-open',
            'Em Andamento': 'status-progress',
            'Aguardando': 'status-waiting',
            'Fechado': 'status-closed'
        };
        return cores[status] || 'status-open';
    }
}

// Exporta instância única do serviço de chamados
const chamadosService = new ChamadosService();

// Torna disponível globalmente
window.chamadosService = chamadosService;