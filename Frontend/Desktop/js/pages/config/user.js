// User Config Page Controller
// Controla a lógica da página de configurações do usuário

import { $, $$ } from '../../utils/dom.js';
import { toast } from '../../utils/helpers.js';
import { userService } from '../../services/UserService.js';
import { authService } from '../../services/AuthService.js';
import { themeManager } from '../../components/ThemeManager.js';
import { ROUTES } from '../../config/constants.js';

/**
 * Controller da página de configurações do usuário
 */
export class UserConfigPage {
  constructor() {
    this.currentUser = null;
  }

  /**
   * Inicializa a página
   */
  async init() {
    // Verifica autenticação
    if (!authService.isAuthenticated()) {
      window.location.href = ROUTES.LOGIN;
      return;
    }

    // Inicializa tema
    themeManager.init();
    themeManager.registerToggleButton('[data-theme-toggle]');

    await this.loadUserData();
    this.setupEventListeners();
    this.renderWelcome();
  }

  /**
   * Carrega dados do usuário
   */
  async loadUserData() {
    try {
      this.showLoading();
      this.currentUser = await userService.getProfile();
      this.populateForm();
      this.hideLoading();
    } catch (error) {
      console.error('Erro ao carregar dados:', error);
      toast('Erro ao carregar dados do usuário', 'error');
    }
  }

  /**
   * Renderiza mensagem de boas-vindas
   */
  renderWelcome() {
    const welcomeEl = $('#welcome-message');
    if (!welcomeEl) return;

    const nome = this.currentUser?.nomeCompleto || 'Usuário';
    const primeiroNome = nome.split(' ')[0];

    welcomeEl.innerHTML = `
      <h1>Configurações</h1>
      <p>Gerencie suas informações pessoais, ${primeiroNome}</p>
    `;
  }

  /**
   * Preenche formulário com dados do usuário
   */
  populateForm() {
    const nomeInput = $('#nome-completo');
    const emailInput = $('#email');
    const emailDisplay = $('#email-display');

    if (nomeInput && this.currentUser?.nomeCompleto) {
      nomeInput.value = this.currentUser.nomeCompleto;
    }

    if (emailInput && this.currentUser?.email) {
      emailInput.value = this.currentUser.email;
    }

    if (emailDisplay && this.currentUser?.email) {
      emailDisplay.textContent = this.currentUser.email;
    }

    // Exibir informações adicionais
    this.renderUserInfo();
  }

  /**
   * Renderiza informações do usuário
   */
  renderUserInfo() {
    const infoContainer = $('#user-info');
    if (!infoContainer || !this.currentUser) return;

    const cadastroDate = this.currentUser.dataCadastro 
      ? new Date(this.currentUser.dataCadastro).toLocaleDateString('pt-BR')
      : 'Não disponível';

    infoContainer.innerHTML = `
      <div class="info-card">
        <div class="info-item">
          <label>Nome Completo:</label>
          <span>${this.escapeHtml(this.currentUser.nomeCompleto || 'Não informado')}</span>
        </div>
        <div class="info-item">
          <label>Email:</label>
          <span>${this.escapeHtml(this.currentUser.email || 'Não informado')}</span>
        </div>
        <div class="info-item">
          <label>Tipo de Usuário:</label>
          <span class="badge">${this.getUserTypeName(this.currentUser.tipoUsuarioId)}</span>
        </div>
        <div class="info-item">
          <label>Membro desde:</label>
          <span>${cadastroDate}</span>
        </div>
        <div class="info-item">
          <label>Status:</label>
          <span class="badge badge-${this.currentUser.ativo ? 'success' : 'danger'}">
            ${this.currentUser.ativo ? 'Ativo' : 'Inativo'}
          </span>
        </div>
      </div>
    `;
  }

  /**
   * Configura event listeners
   */
  setupEventListeners() {
    // Formulário de atualização de dados
    const updateForm = $('#form-update-profile');
    if (updateForm) {
      updateForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        await this.handleUpdateProfile();
      });
    }

    // Formulário de mudança de senha
    const passwordForm = $('#form-change-password');
    if (passwordForm) {
      passwordForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        await this.handleChangePassword();
      });
    }

    // Botão de logout
    const logoutBtn = $('#btn-logout');
    if (logoutBtn) {
      logoutBtn.addEventListener('click', (e) => {
        e.preventDefault();
        authService.logout();
      });
    }

    // Toggle de senha
    $$('.toggle-password').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const input = e.target.closest('.password-wrapper').querySelector('input');
        const icon = e.target;
        
        if (input.type === 'password') {
          input.type = 'text';
          icon.classList.remove('fa-eye');
          icon.classList.add('fa-eye-slash');
        } else {
          input.type = 'password';
          icon.classList.remove('fa-eye-slash');
          icon.classList.add('fa-eye');
        }
      });
    });

    // Validação em tempo real de senha
    const newPassword = $('#nova-senha');
    const confirmPassword = $('#confirmar-senha');

    if (newPassword) {
      newPassword.addEventListener('input', () => {
        this.validatePasswordStrength();
      });
    }

    if (confirmPassword) {
      confirmPassword.addEventListener('input', () => {
        this.validatePasswordMatch();
      });
    }
  }

  /**
   * Atualiza perfil do usuário
   */
  async handleUpdateProfile() {
    const nomeCompleto = $('#nome-completo')?.value.trim();

    if (!nomeCompleto || nomeCompleto.length < 3) {
      toast('Nome deve ter pelo menos 3 caracteres', 'warning');
      return;
    }

    const submitBtn = $('#btn-update-profile');
    if (submitBtn) {
      submitBtn.disabled = true;
      submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Salvando...';
    }

    try {
      await userService.update(this.currentUser.id, { nomeCompleto });
      toast('Perfil atualizado com sucesso!', 'success');
      
      // Atualizar dados no storage
      const userData = authService.getUserData();
      if (userData) {
        userData.nomeCompleto = nomeCompleto;
        localStorage.setItem('user', JSON.stringify(userData));
      }

      await this.loadUserData();
    } catch (error) {
      console.error('Erro ao atualizar perfil:', error);
      toast('Erro ao atualizar perfil: ' + error.message, 'error');
    } finally {
      if (submitBtn) {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-save"></i> Salvar Alterações';
      }
    }
  }

  /**
   * Altera senha do usuário
   */
  async handleChangePassword() {
    const senhaAtual = $('#senha-atual')?.value;
    const novaSenha = $('#nova-senha')?.value;
    const confirmarSenha = $('#confirmar-senha')?.value;

    // Validações
    if (!senhaAtual || !novaSenha || !confirmarSenha) {
      toast('Preencha todos os campos de senha', 'warning');
      return;
    }

    if (novaSenha.length < 6) {
      toast('Nova senha deve ter pelo menos 6 caracteres', 'warning');
      return;
    }

    if (novaSenha !== confirmarSenha) {
      toast('As senhas não coincidem', 'warning');
      return;
    }

    if (senhaAtual === novaSenha) {
      toast('Nova senha deve ser diferente da atual', 'warning');
      return;
    }

    const submitBtn = $('#btn-change-password');
    if (submitBtn) {
      submitBtn.disabled = true;
      submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Alterando...';
    }

    try {
      await userService.changePassword({
        senhaAtual,
        novaSenha
      });

      toast('Senha alterada com sucesso!', 'success');

      // Limpar formulário
      if ($('#senha-atual')) $('#senha-atual').value = '';
      if ($('#nova-senha')) $('#nova-senha').value = '';
      if ($('#confirmar-senha')) $('#confirmar-senha').value = '';

      // Limpar indicadores
      const strengthMeter = $('#password-strength');
      if (strengthMeter) strengthMeter.className = 'password-strength';

      const matchIndicator = $('#password-match');
      if (matchIndicator) matchIndicator.textContent = '';

    } catch (error) {
      console.error('Erro ao alterar senha:', error);
      toast('Erro ao alterar senha: ' + error.message, 'error');
    } finally {
      if (submitBtn) {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-key"></i> Alterar Senha';
      }
    }
  }

  /**
   * Valida força da senha
   */
  validatePasswordStrength() {
    const password = $('#nova-senha')?.value || '';
    const strengthMeter = $('#password-strength');
    
    if (!strengthMeter) return;

    if (password.length === 0) {
      strengthMeter.className = 'password-strength';
      strengthMeter.textContent = '';
      return;
    }

    let strength = 0;
    let feedback = '';

    // Critérios de força
    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;
    if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength++;
    if (/\d/.test(password)) strength++;
    if (/[^a-zA-Z0-9]/.test(password)) strength++;

    // Feedback visual
    if (strength <= 1) {
      strengthMeter.className = 'password-strength weak';
      feedback = 'Fraca';
    } else if (strength <= 2) {
      strengthMeter.className = 'password-strength medium';
      feedback = 'Média';
    } else if (strength <= 3) {
      strengthMeter.className = 'password-strength good';
      feedback = 'Boa';
    } else {
      strengthMeter.className = 'password-strength strong';
      feedback = 'Forte';
    }

    strengthMeter.textContent = `Força: ${feedback}`;
  }

  /**
   * Valida se senhas coincidem
   */
  validatePasswordMatch() {
    const newPassword = $('#nova-senha')?.value || '';
    const confirmPassword = $('#confirmar-senha')?.value || '';
    const matchIndicator = $('#password-match');

    if (!matchIndicator) return;

    if (confirmPassword.length === 0) {
      matchIndicator.textContent = '';
      matchIndicator.className = '';
      return;
    }

    if (newPassword === confirmPassword) {
      matchIndicator.textContent = '✓ Senhas coincidem';
      matchIndicator.className = 'text-success';
    } else {
      matchIndicator.textContent = '✗ Senhas não coincidem';
      matchIndicator.className = 'text-danger';
    }
  }

  /**
   * Obtém nome do tipo de usuário
   */
  getUserTypeName(tipoId) {
    const tipos = {
      1: 'Usuário',
      2: 'Técnico',
      3: 'Administrador'
    };
    return tipos[tipoId] || 'Desconhecido';
  }

  escapeHtml(text) {
    const map = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, m => map[m]);
  }

  showLoading() {
    const container = $('#main-content');
    if (!container) return;
    container.innerHTML = `
      <div class="loading-state">
        <i class="fas fa-spinner fa-spin"></i>
        <p>Carregando configurações...</p>
      </div>
    `;
  }

  hideLoading() {}
}

// Auto-inicialização
if (window.location.pathname.includes('config-desktop')) {
  const configPage = new UserConfigPage();
  configPage.init();
}

export default UserConfigPage;
