// Auth Service
// Serviço de autenticação e gerenciamento de sessão

import { apiService } from './ApiService.js';
import { USER_TYPES, ROUTES, STORAGE_KEYS } from '../config/constants.js';
import { save, load } from '../utils/storage.js';

/**
 * Serviço de autenticação
 */
export class AuthService {
  /**
   * Realiza login do usuário
   * @param {string} email - Email do usuário
   * @param {string} senha - Senha do usuário
   * @returns {Promise<{success: boolean, token?: string, tipoUsuario?: number, redirectUrl?: string, error?: string}>}
   */
  async login(email, senha) {
    try {
      const data = await apiService.post('/api/usuarios/login', {
        Email: email,
        Senha: senha
      }, false); // Não precisa de auth para login

      if (data.token) {
        apiService.setToken(data.token);
        
        // Salva dados do usuário
        save(STORAGE_KEYS.USER_DATA, {
          email: data.email || email,
          tipoUsuario: data.tipoUsuario,
          nomeCompleto: data.nomeCompleto
        });

        return {
          success: true,
          token: data.token,
          tipoUsuario: data.tipoUsuario,
          redirectUrl: this.getRedirectUrl(data.tipoUsuario)
        };
      }

      return { success: false, error: 'Token não recebido' };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  /**
   * Determina URL de redirecionamento baseado no tipo de usuário
   * @param {number} tipoUsuario - Tipo do usuário
   * @returns {string}
   */
  getRedirectUrl(tipoUsuario) {
    switch (tipoUsuario) {
      case USER_TYPES.ADMIN:
        return ROUTES.ADMIN_DASHBOARD;
      case USER_TYPES.TECNICO:
        return ROUTES.TECNICO_DASHBOARD;
      case USER_TYPES.USER:
      default:
        return ROUTES.USER_DASHBOARD;
    }
  }

  /**
   * Registra novo usuário
   * @param {string} nomeCompleto - Nome completo do usuário
   * @param {string} email - Email do usuário
   * @param {string} senha - Senha do usuário
   * @returns {Promise<{success: boolean, data?: any, error?: string}>}
   */
  async register(nomeCompleto, email, senha) {
    try {
      const data = await apiService.post('/api/usuarios/registrar', {
        NomeCompleto: nomeCompleto,
        Email: email,
        Senha: senha
      }, false);

      return { success: true, data };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  /**
   * Solicita recuperação de senha
   * @param {string} email - Email do usuário
   * @returns {Promise<{success: boolean, message?: string, error?: string}>}
   */
  async forgotPassword(email) {
    try {
      const data = await apiService.post('/api/usuarios/esqueci-senha', {
        Email: email
      }, false);

      return { success: true, message: data.message || 'Email enviado com sucesso' };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  /**
   * Reseta a senha do usuário
   * @param {string} token - Token de recuperação
   * @param {string} novaSenha - Nova senha
   * @returns {Promise<{success: boolean, message?: string, error?: string}>}
   */
  async resetPassword(token, novaSenha) {
    try {
      const data = await apiService.post('/api/usuarios/resetar-senha', {
        Token: token,
        NovaSenha: novaSenha
      }, false);

      return { success: true, message: data.message || 'Senha alterada com sucesso' };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  /**
   * Realiza logout e redireciona para login
   */
  logout() {
    apiService.clearToken();
    window.location.href = ROUTES.LOGIN;
  }

  /**
   * Verifica se usuário está autenticado
   * @returns {boolean}
   */
  isAuthenticated() {
    return !!apiService.getToken();
  }

  /**
   * Obtém dados do usuário salvos
   * @returns {Object|null}
   */
  getUserData() {
    return load(STORAGE_KEYS.USER_DATA, null);
  }

  /**
   * Obtém tipo do usuário atual
   * @returns {number|null}
   */
  getUserType() {
    const userData = this.getUserData();
    return userData ? userData.tipoUsuario : null;
  }

  /**
   * Verifica se usuário é admin
   * @returns {boolean}
   */
  isAdmin() {
    return this.getUserType() === USER_TYPES.ADMIN;
  }

  /**
   * Verifica se usuário é técnico
   * @returns {boolean}
   */
  isTecnico() {
    return this.getUserType() === USER_TYPES.TECNICO;
  }

  /**
   * Verifica se usuário comum
   * @returns {boolean}
   */
  isUser() {
    return this.getUserType() === USER_TYPES.USER;
  }

  /**
   * Verifica autenticação e redireciona se necessário
   * @param {number[]} allowedUserTypes - Tipos de usuário permitidos
   */
  requireAuth(allowedUserTypes = null) {
    if (!this.isAuthenticated()) {
      window.location.href = ROUTES.LOGIN;
      return false;
    }

    if (allowedUserTypes && allowedUserTypes.length > 0) {
      const userType = this.getUserType();
      if (!allowedUserTypes.includes(userType)) {
        // Redireciona para dashboard apropriado
        window.location.href = this.getRedirectUrl(userType);
        return false;
      }
    }

    return true;
  }
}

// Export singleton instance
export const authService = new AuthService();
