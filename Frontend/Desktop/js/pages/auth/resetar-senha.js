// Resetar Senha Page Controller
// Controla a lógica da página de reset de senha

import { $, $$ } from '../../utils/dom.js';
import { toast } from '../../utils/helpers.js';
import { authService } from '../../services/AuthService.js';
import { themeManager } from '../../components/ThemeManager.js';
import { ROUTES } from '../../config/constants.js';

/**
 * Controller da página de resetar senha
 */
export class ResetarSenhaPage {
  constructor() {
    this.form = null;
    this.token = null;
    this.isSubmitting = false;
  }

  /**
   * Inicializa a página
   */
  init() {
    // Inicializa tema
    themeManager.init();

    // Obtém token da URL
    this.token = this.getTokenFromUrl();
    
    if (!this.token) {
      this.showInvalidTokenMessage();
      return;
    }

    this.form = $('#resetar-senha-form');
    if (!this.form) {
      console.error('Formulário de resetar senha não encontrado');
      return;
    }

    this.setupEventListeners();
  }

  /**
   * Obtém token da URL
   */
  getTokenFromUrl() {
    const params = new URLSearchParams(window.location.search);
    return params.get('token');
  }

  /**
   * Exibe mensagem de token inválido
   */
  showInvalidTokenMessage() {
    const container = document.querySelector('.container') || document.body;
    container.innerHTML = `
      <div class="error-message">
        <div class="icon">
          <i class="fas fa-exclamation-triangle"></i>
        </div>
        <h2>Link Inválido</h2>
        <p>
          O link de recuperação de senha é inválido ou expirou.
        </p>
        <p>
          Por favor, solicite um novo link de recuperação.
        </p>
        <a href="${ROUTES.ESQUECI_SENHA}" class="btn btn-primary">
          <i class="fas fa-redo"></i> Solicitar Novo Link
        </a>
      </div>
    `;
  }

  /**
   * Configura event listeners
   */
  setupEventListeners() {
    this.form.addEventListener('submit', async (e) => {
      e.preventDefault();
      await this.handleResetarSenha();
    });

    // Validação em tempo real
    const novaSenhaField = $('#nova-senha');
    const confirmarSenhaField = $('#confirmar-senha');

    if (novaSenhaField && confirmarSenhaField) {
      confirmarSenhaField.addEventListener('input', () => {
        this.validatePasswordMatch();
      });

      novaSenhaField.addEventListener('input', () => {
        this.showPasswordStrength();
      });
    }

    // Mostrar/ocultar senhas
    $$('[data-toggle-password]').forEach(toggle => {
      toggle.addEventListener('click', () => {
        const targetId = toggle.dataset.togglePassword;
        const field = $(`#${targetId}`);
        if (field) {
          const type = field.type === 'password' ? 'text' : 'password';
          field.type = type;
          toggle.classList.toggle('fa-eye');
          toggle.classList.toggle('fa-eye-slash');
        }
      });
    });
  }

  /**
   * Valida se as senhas correspondem
   */
  validatePasswordMatch() {
    const novaSenhaField = $('#nova-senha');
    const confirmarSenhaField = $('#confirmar-senha');
    const matchIndicator = $('#password-match-indicator');

    if (!novaSenhaField || !confirmarSenhaField) return;

    const novaSenha = novaSenhaField.value;
    const confirmar = confirmarSenhaField.value;

    if (confirmar.length > 0) {
      if (novaSenha === confirmar) {
        confirmarSenhaField.classList.remove('is-invalid');
        confirmarSenhaField.classList.add('is-valid');
        if (matchIndicator) {
          matchIndicator.textContent = '✓ Senhas correspondem';
          matchIndicator.className = 'text-success';
        }
      } else {
        confirmarSenhaField.classList.remove('is-valid');
        confirmarSenhaField.classList.add('is-invalid');
        if (matchIndicator) {
          matchIndicator.textContent = '✗ Senhas não correspondem';
          matchIndicator.className = 'text-danger';
        }
      }
    } else {
      confirmarSenhaField.classList.remove('is-valid', 'is-invalid');
      if (matchIndicator) {
        matchIndicator.textContent = '';
      }
    }
  }

  /**
   * Mostra força da senha
   */
  showPasswordStrength() {
    const novaSenhaField = $('#nova-senha');
    const strengthIndicator = $('#password-strength');
    
    if (!novaSenhaField || !strengthIndicator) return;

    const senha = novaSenhaField.value;
    let strength = 0;
    let text = '';
    let className = '';

    if (senha.length >= 6) strength++;
    if (senha.length >= 10) strength++;
    if (/[a-z]/.test(senha) && /[A-Z]/.test(senha)) strength++;
    if (/[0-9]/.test(senha)) strength++;
    if (/[^A-Za-z0-9]/.test(senha)) strength++;

    switch (strength) {
      case 0:
      case 1:
        text = 'Muito fraca';
        className = 'text-danger';
        break;
      case 2:
        text = 'Fraca';
        className = 'text-warning';
        break;
      case 3:
        text = 'Média';
        className = 'text-info';
        break;
      case 4:
        text = 'Forte';
        className = 'text-success';
        break;
      case 5:
        text = 'Muito forte';
        className = 'text-success font-weight-bold';
        break;
    }

    strengthIndicator.textContent = text;
    strengthIndicator.className = className;
  }

  /**
   * Valida formulário
   */
  validateForm(novaSenha, confirmarSenha) {
    if (!novaSenha || novaSenha.length < 6) {
      toast('A senha deve ter pelo menos 6 caracteres.');
      return false;
    }

    if (novaSenha !== confirmarSenha) {
      toast('As senhas não coincidem.');
      return false;
    }

    // Validação de força da senha
    if (!/[A-Z]/.test(novaSenha) || !/[a-z]/.test(novaSenha) || !/[0-9]/.test(novaSenha)) {
      toast('A senha deve conter letras maiúsculas, minúsculas e números.');
      return false;
    }

    return true;
  }

  /**
   * Exibe loading no botão
   */
  setLoading(isLoading) {
    const submitBtn = this.form.querySelector('button[type="submit"]');
    if (!submitBtn) return;

    if (isLoading) {
      submitBtn.disabled = true;
      submitBtn.dataset.originalText = submitBtn.innerHTML;
      submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Alterando...';
    } else {
      submitBtn.disabled = false;
      submitBtn.innerHTML = submitBtn.dataset.originalText || 'Alterar Senha';
    }
  }

  /**
   * Exibe mensagem de sucesso
   */
  showSuccessMessage() {
    const formContainer = this.form.parentElement;
    if (!formContainer) return;

    formContainer.innerHTML = `
      <div class="success-message">
        <div class="icon">
          <i class="fas fa-check-circle"></i>
        </div>
        <h2>Senha Alterada!</h2>
        <p>
          Sua senha foi alterada com sucesso.
        </p>
        <p>
          Você já pode fazer login com sua nova senha.
        </p>
        <a href="${ROUTES.LOGIN}" class="btn btn-primary">
          <i class="fas fa-sign-in-alt"></i> Fazer Login
        </a>
      </div>
    `;
  }

  /**
   * Manipula o reset de senha
   */
  async handleResetarSenha() {
    if (this.isSubmitting) return;

    const novaSenha = $('#nova-senha').value.trim();
    const confirmarSenha = $('#confirmar-senha').value.trim();

    // Valida campos
    if (!this.validateForm(novaSenha, confirmarSenha)) {
      return;
    }

    this.isSubmitting = true;
    this.setLoading(true);

    try {
      const result = await authService.resetPassword(this.token, novaSenha);

      if (result.success) {
        this.showSuccessMessage();
      } else {
        toast(result.error || 'Erro ao resetar senha. O link pode ter expirado.');
        this.setLoading(false);
        this.isSubmitting = false;
      }
    } catch (error) {
      console.error('Erro:', error);
      toast('Erro de conexão. Verifique sua internet e tente novamente.');
      this.setLoading(false);
      this.isSubmitting = false;
    }
  }
}

// Auto-inicialização se estiver na página de resetar senha
if (document.querySelector('#resetar-senha-form')) {
  const page = new ResetarSenhaPage();
  page.init();
}

export default ResetarSenhaPage;
