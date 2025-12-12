// Cadastro Page Controller
// Controla a lógica da página de cadastro

import { $, $$ } from '../../utils/dom.js';
import { toast, isValidEmail } from '../../utils/helpers.js';
import { authService } from '../../services/AuthService.js';
import { themeManager } from '../../components/ThemeManager.js';
import { ROUTES } from '../../config/constants.js';

/**
 * Controller da página de cadastro
 */
export class CadastroPage {
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

    this.form = $('#cadastro-form');
    if (!this.form) {
      console.error('Formulário de cadastro não encontrado');
      return;
    }

    this.setupEventListeners();
  }

  /**
   * Configura event listeners
   */
  setupEventListeners() {
    // Submit do formulário
    this.form.addEventListener('submit', async (e) => {
      e.preventDefault();
      await this.handleCadastro();
    });

    // Validação em tempo real
    const senhaField = $('#senha');
    const confirmarSenhaField = $('#confirmar-senha');

    if (senhaField && confirmarSenhaField) {
      confirmarSenhaField.addEventListener('input', () => {
        this.validatePasswordMatch();
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
    const senhaField = $('#senha');
    const confirmarSenhaField = $('#confirmar-senha');
    const matchIndicator = $('#password-match-indicator');

    if (!senhaField || !confirmarSenhaField) return;

    const senha = senhaField.value;
    const confirmar = confirmarSenhaField.value;

    if (confirmar.length > 0) {
      if (senha === confirmar) {
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
   * Valida formulário
   */
  validateForm(nome, email, senha, confirmarSenha) {
    if (!nome || nome.trim().length < 3) {
      toast('Nome completo deve ter pelo menos 3 caracteres.');
      return false;
    }

    if (!email || !isValidEmail(email)) {
      toast('Por favor, informe um e-mail válido.');
      return false;
    }

    if (!senha || senha.length < 6) {
      toast('A senha deve ter pelo menos 6 caracteres.');
      return false;
    }

    if (senha !== confirmarSenha) {
      toast('As senhas não coincidem.');
      return false;
    }

    // Validação de força da senha
    if (!/[A-Z]/.test(senha) || !/[a-z]/.test(senha) || !/[0-9]/.test(senha)) {
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
      submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Cadastrando...';
    } else {
      submitBtn.disabled = false;
      submitBtn.innerHTML = submitBtn.dataset.originalText || 'Cadastrar';
    }
  }

  /**
   * Manipula o cadastro
   */
  async handleCadastro() {
    if (this.isSubmitting) return;

    const nome = $('#nome').value.trim();
    const email = $('#email').value.trim().toLowerCase();
    const senha = $('#senha').value.trim();
    const confirmarSenha = $('#confirmar-senha').value.trim();

    // Valida campos
    if (!this.validateForm(nome, email, senha, confirmarSenha)) {
      return;
    }

    this.isSubmitting = true;
    this.setLoading(true);

    try {
      const result = await authService.register(nome, email, senha);

      if (result.success) {
        toast('Cadastro realizado com sucesso! Redirecionando para o login...');
        
        // Redireciona para login após 1.5 segundos
        setTimeout(() => {
          window.location.href = ROUTES.LOGIN;
        }, 1500);
      } else {
        toast(result.error || 'Erro ao realizar cadastro. Tente novamente.');
        this.setLoading(false);
        this.isSubmitting = false;
      }
    } catch (error) {
      console.error('Erro no cadastro:', error);
      toast('Erro de conexão. Verifique sua internet e tente novamente.');
      this.setLoading(false);
      this.isSubmitting = false;
    }
  }
}

// Auto-inicialização se estiver na página de cadastro
if (document.querySelector('#cadastro-form')) {
  const cadastroPage = new CadastroPage();
  cadastroPage.init();
}

export default CadastroPage;
