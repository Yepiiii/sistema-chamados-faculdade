// Login Page Controller
// Controla a lógica da página de login

import { $, $$ } from '../../utils/dom.js';
import { toast } from '../../utils/helpers.js';
import { authService } from '../../services/AuthService.js';
import { themeManager } from '../../components/ThemeManager.js';

/**
 * Controller da página de login
 */
export class LoginPage {
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

    // Se já está autenticado, redireciona
    if (authService.isAuthenticated()) {
      const userType = authService.getUserType();
      window.location.href = authService.getRedirectUrl(userType);
      return;
    }

    this.form = $('#login-form');
    if (!this.form) {
      console.error('Formulário de login não encontrado');
      return;
    }

    this.setupEventListeners();
    this.focusFirstField();
  }

  /**
   * Configura event listeners
   */
  setupEventListeners() {
    // Submit do formulário
    this.form.addEventListener('submit', async (e) => {
      e.preventDefault();
      await this.handleLogin();
    });

    // Enter nos campos
    const emailField = $('#email');
    const passwordField = $('#password');

    if (emailField) {
      emailField.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
          passwordField?.focus();
        }
      });
    }

    if (passwordField) {
      passwordField.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
          this.form.requestSubmit();
        }
      });
    }

    // Mostrar/ocultar senha
    const togglePassword = $('#toggle-password');
    if (togglePassword) {
      togglePassword.addEventListener('click', () => {
        const type = passwordField.type === 'password' ? 'text' : 'password';
        passwordField.type = type;
        togglePassword.classList.toggle('fa-eye');
        togglePassword.classList.toggle('fa-eye-slash');
      });
    }
  }

  /**
   * Foca no primeiro campo
   */
  focusFirstField() {
    const emailField = $('#email');
    if (emailField) {
      emailField.focus();
    }
  }

  /**
   * Valida campos do formulário
   */
  validateForm(email, password) {
    if (!email || email.trim() === '') {
      toast('Por favor, informe seu e-mail.');
      return false;
    }

    if (!password || password.trim() === '') {
      toast('Por favor, informe sua senha.');
      return false;
    }

    // Validação básica de email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
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
      submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Entrando...';
    } else {
      submitBtn.disabled = false;
      submitBtn.innerHTML = submitBtn.dataset.originalText || 'Entrar';
    }
  }

  /**
   * Manipula o login
   */
  async handleLogin() {
    if (this.isSubmitting) return;

    const emailField = $('#email');
    const passwordField = $('#password');

    const email = emailField.value.trim().toLowerCase();
    const password = passwordField.value.trim();

    // Valida campos
    if (!this.validateForm(email, password)) {
      return;
    }

    this.isSubmitting = true;
    this.setLoading(true);

    try {
      const result = await authService.login(email, password);

      if (result.success) {
        toast('Login realizado com sucesso!');
        
        // Pequeno delay para mostrar a mensagem
        setTimeout(() => {
          window.location.href = result.redirectUrl;
        }, 500);
      } else {
        toast(result.error || 'E-mail ou senha incorretos.');
        this.setLoading(false);
        this.isSubmitting = false;
        
        // Limpa senha e foca no campo
        passwordField.value = '';
        passwordField.focus();
      }
    } catch (error) {
      console.error('Erro na autenticação:', error);
      toast('Erro de conexão. Verifique sua internet e tente novamente.');
      this.setLoading(false);
      this.isSubmitting = false;
    }
  }
}

// Auto-inicialização se estiver na página de login
if (document.querySelector('#login-form')) {
  const loginPage = new LoginPage();
  loginPage.init();
}

export default LoginPage;
