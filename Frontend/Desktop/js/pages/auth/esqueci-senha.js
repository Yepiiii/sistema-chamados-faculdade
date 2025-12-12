// Esqueci Senha Page Controller
// Controla a lógica da página de recuperação de senha

import { $, $$ } from '../../utils/dom.js';
import { toast, isValidEmail } from '../../utils/helpers.js';
import { authService } from '../../services/AuthService.js';
import { themeManager } from '../../components/ThemeManager.js';

/**
 * Controller da página de esqueci senha
 */
export class EsqueciSenhaPage {
  constructor() {
    this.form = null;
    this.isSubmitting = false;
  }

  /**
   * Inicializa a página
   */
  init() {
    // Inicializa tema
    themeManager.init();

    this.form = $('#esqueci-senha-form');
    if (!this.form) {
      console.error('Formulário de esqueci senha não encontrado');
      return;
    }

    this.setupEventListeners();
    this.focusEmailField();
  }

  /**
   * Configura event listeners
   */
  setupEventListeners() {
    this.form.addEventListener('submit', async (e) => {
      e.preventDefault();
      await this.handleEsqueciSenha();
    });
  }

  /**
   * Foca no campo de email
   */
  focusEmailField() {
    const emailField = $('#email');
    if (emailField) {
      emailField.focus();
    }
  }

  /**
   * Valida formulário
   */
  validateForm(email) {
    if (!email || email.trim() === '') {
      toast('Por favor, informe seu e-mail.');
      return false;
    }

    if (!isValidEmail(email)) {
      toast('Por favor, informe um e-mail válido.');
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
      submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Enviando...';
    } else {
      submitBtn.disabled = false;
      submitBtn.innerHTML = submitBtn.dataset.originalText || 'Enviar';
    }
  }

  /**
   * Exibe mensagem de sucesso
   */
  showSuccessMessage(email) {
    const formContainer = this.form.parentElement;
    if (!formContainer) return;

    formContainer.innerHTML = `
      <div class="success-message">
        <div class="icon">
          <i class="fas fa-check-circle"></i>
        </div>
        <h2>E-mail Enviado!</h2>
        <p>
          Enviamos um link de recuperação para <strong>${email}</strong>.
        </p>
        <p>
          Verifique sua caixa de entrada e também a pasta de spam.
          O link expira em 24 horas.
        </p>
        <a href="/index.html" class="btn btn-primary">
          <i class="fas fa-arrow-left"></i> Voltar para o Login
        </a>
      </div>
    `;
  }

  /**
   * Manipula o esqueci senha
   */
  async handleEsqueciSenha() {
    if (this.isSubmitting) return;

    const emailField = $('#email');
    const email = emailField.value.trim().toLowerCase();

    // Valida campos
    if (!this.validateForm(email)) {
      return;
    }

    this.isSubmitting = true;
    this.setLoading(true);

    try {
      const result = await authService.forgotPassword(email);

      if (result.success) {
        this.showSuccessMessage(email);
      } else {
        toast(result.error || 'Erro ao enviar e-mail. Tente novamente.');
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

// Auto-inicialização se estiver na página de esqueci senha
if (document.querySelector('#esqueci-senha-form')) {
  const page = new EsqueciSenhaPage();
  page.init();
}

export default EsqueciSenhaPage;
