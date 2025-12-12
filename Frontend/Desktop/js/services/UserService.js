// User Service
// Serviço para gerenciamento de usuários

import { apiService } from './ApiService.js';

/**
 * Serviço de gerenciamento de usuários
 */
export class UserService {
  /**
   * Obtém perfil do usuário atual
   * @returns {Promise<Object>}
   */
  async getProfile() {
    return await apiService.get('/api/usuarios/perfil');
  }

  /**
   * Obtém lista de técnicos ativos
   * @returns {Promise<Array>}
   */
  async getTecnicos() {
    return await apiService.get('/api/usuarios/tecnicos');
  }

  /**
   * Obtém todos os usuários (admin)
   * @returns {Promise<Array>}
   */
  async getAll() {
    return await apiService.get('/api/usuarios');
  }

  /**
   * Obtém usuário por ID
   * @param {number} id - ID do usuário
   * @returns {Promise<Object>}
   */
  async getById(id) {
    return await apiService.get(`/api/usuarios/${id}`);
  }

  /**
   * Registra novo técnico (admin)
   * @param {Object} data - Dados do técnico
   * @param {string} data.nomeCompleto - Nome completo
   * @param {string} data.email - Email
   * @param {string} data.senha - Senha
   * @param {number} data.especialidadeCategoriaId - ID da categoria de especialidade
   * @returns {Promise<Object>}
   */
  async registerTecnico(data) {
    return await apiService.post('/api/usuarios/registrar-tecnico', {
      NomeCompleto: data.nomeCompleto,
      Email: data.email,
      Senha: data.senha,
      EspecialidadeCategoriaId: data.especialidadeCategoriaId
    });
  }

  /**
   * Atualiza perfil do usuário
   * @param {number} id - ID do usuário
   * @param {Object} data - Dados a serem atualizados
   * @returns {Promise<Object>}
   */
  async update(id, data) {
    const payload = {};
    if (data.nomeCompleto !== undefined) payload.NomeCompleto = data.nomeCompleto;
    if (data.email !== undefined) payload.Email = data.email;
    if (data.especialidadeCategoriaId !== undefined) {
      payload.EspecialidadeCategoriaId = data.especialidadeCategoriaId;
    }

    return await apiService.put(`/api/usuarios/${id}`, payload);
  }

  /**
   * Desativa usuário (admin)
   * @param {number} id - ID do usuário
   * @returns {Promise<Object>}
   */
  async deactivate(id) {
    return await apiService.put(`/api/usuarios/${id}/desativar`, {});
  }

  /**
   * Ativa usuário (admin)
   * @param {number} id - ID do usuário
   * @returns {Promise<Object>}
   */
  async activate(id) {
    return await apiService.put(`/api/usuarios/${id}/ativar`, {});
  }

  /**
   * Altera senha do usuário
   * @param {string} senhaAtual - Senha atual
   * @param {string} novaSenha - Nova senha
   * @returns {Promise<Object>}
   */
  async changePassword(senhaAtual, novaSenha) {
    return await apiService.post('/api/usuarios/alterar-senha', {
      SenhaAtual: senhaAtual,
      NovaSenha: novaSenha
    });
  }

  /**
   * Obtém estatísticas de usuários (admin)
   * @returns {Promise<Object>}
   */
  async getStats() {
    // Se API não tiver endpoint, calcula localmente
    const usuarios = await this.getAll();
    
    return {
      total: usuarios.length,
      admins: usuarios.filter(u => u.tipoUsuario === 3).length,
      tecnicos: usuarios.filter(u => u.tipoUsuario === 2).length,
      users: usuarios.filter(u => u.tipoUsuario === 1).length,
      ativos: usuarios.filter(u => u.ativo).length,
      inativos: usuarios.filter(u => !u.ativo).length
    };
  }
}

// Export singleton instance
export const userService = new UserService();
