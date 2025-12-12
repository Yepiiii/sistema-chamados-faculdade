// Admin Cadastrar Tecnico Page Controller
// Controla a lógica da página de cadastro de técnico (admin)

import { $, $$ } from '../../utils/dom.js';
import { toast, isValidEmail } from '../../utils/helpers.js';
import { userService } from '../../services/UserService.js';
import { categoryService } from '../../services/CategoryService.js';
import { authService } from '../../services/AuthService.js';
import { themeManager } from '../../components/ThemeManager.js';
import { USER_TYPES, ROUTES } from '../../config/constants.js';

/**
 * Controller da página de cadastro de técnico
 */
export class CadastrarTecnicoPage {
  constructor() {
    this.categorias = [];
  }

  /**
   * Inicializa a página
   */
  async init() {
    // Verifica autenticação e role de admin
    if (!authService.requireAuth([USER_TYPES.ADMIN])) {
      return;
    }

    // Inicializa tema
    themeManager.init();
    themeManager.registerToggleButton('[data-theme-toggle]');

    await this.loadCategorias();
    this.setupEventListeners();
    this.setupFormValidation();
  }

  /**
   * Carrega categorias para seleção
   */
  async loadCategorias() {
    try {
      this.categorias = await categoryService.getAll();
      this.renderCategorias();
    } catch (error) {
      console.error('Erro ao carregar categorias:', error);
      toast('Erro ao carregar categorias', 'error');
    }
  }

  /**
   * Renderiza checkboxes de categorias
   */
  renderCategorias() {
    const container = $('#categorias-container');
    if (!container) return;

    container.innerHTML = `
      <div class="categories-grid">
        ${this.categorias.map(cat => `
          <div class="category-checkbox">
            <input 
              type="checkbox" 
              id="categoria-${cat.id}" 
              name="categorias" 
              value="${cat.id}"
            />
            <label for="categoria-${cat.id}">
              <i class="fas fa-tag"></i>
              ${this.escapeHtml(cat.nome)}
            </label>
          </div>
        `).join('')}
      </div>
      <small class="form-text">Selecione as áreas de especialidade do técnico</small>
    `;
  }

  /**
   * Configura event listeners
   */
  setupEventListeners() {
    // Formulário principal
    const form = $('#form-cadastrar-tecnico');
    if (form) {
      form.addEventListener('submit', async (e) => {
        e.preventDefault();
        await this.handleSubmit();
      });
    }

    // Botão cancelar
    const cancelBtn = $('#btn-cancel');
    if (cancelBtn) {
      cancelBtn.addEventListener('click', () => {
        if (confirm('Deseja cancelar o cadastro? Os dados serão perdidos.')) {
          window.history.back();
        }
      });
    }

    // Toggle de senha
    $$('.toggle-password').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const wrapper = e.target.closest('.password-wrapper');
        const input = wrapper.querySelector('input');
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

    // Validação em tempo real
    const nomeInput = $('#nome-completo');
    if (nomeInput) {
      nomeInput.addEventListener('blur', () => this.validateNome());
    }

    const emailInput = $('#email');
    if (emailInput) {
      emailInput.addEventListener('blur', () => this.validateEmail());
    }

    const senhaInput = $('#senha');
    if (senhaInput) {
      senhaInput.addEventListener('input', () => this.validatePasswordStrength());
    }

    const confirmarSenhaInput = $('#confirmar-senha');
    if (confirmarSenhaInput) {
      confirmarSenhaInput.addEventListener('input', () => this.validatePasswordMatch());
    }
  }

  /**
   * Configura validação do formulário
   */
  setupFormValidation() {
    const form = $('#form-cadastrar-tecnico');
    if (!form) return;
    form.classList.add('needs-validation');
    form.noValidate = true;
  }

  /**
   * Valida nome
   */
  validateNome() {
    const input = $('#nome-completo');
    if (!input) return true;

    const value = input.value.trim();
    const feedback = input.nextElementSibling;

    if (value.length < 3) {
      input.classList.add('is-invalid');
      input.classList.remove('is-valid');
      if (feedback) feedback.textContent = 'Nome deve ter pelo menos 3 caracteres';
      return false;
    }

    input.classList.remove('is-invalid');
    input.classList.add('is-valid');
    return true;
  }

  /**
   * Valida email
   */
  validateEmail() {
    const input = $('#email');
    if (!input) return true;

    const value = input.value.trim();
    const feedback = input.nextElementSibling;

    if (!isValidEmail(value)) {
      input.classList.add('is-invalid');
      input.classList.remove('is-valid');
      if (feedback) feedback.textContent = 'Email inválido';
      return false;
    }

    input.classList.remove('is-invalid');
    input.classList.add('is-valid');
    return true;
  }

  /**
   * Valida força da senha
   */
  validatePasswordStrength() {
    const input = $('#senha');
    if (!input) return true;

    const password = input.value;
    const strengthMeter = $('#password-strength');

    if (!strengthMeter) return true;

    if (password.length === 0) {
      strengthMeter.className = 'password-strength';
      strengthMeter.textContent = '';
      return true;
    }

    let strength = 0;
    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;
    if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength++;
    if (/\d/.test(password)) strength++;
    if (/[^a-zA-Z0-9]/.test(password)) strength++;

    const levels = ['', 'Muito Fraca', 'Fraca', 'Média', 'Boa', 'Forte'];
    const classes = ['', 'very-weak', 'weak', 'medium', 'good', 'strong'];

    strengthMeter.className = `password-strength ${classes[strength]}`;
    strengthMeter.textContent = `Força: ${levels[strength]}`;

    return password.length >= 6;
  }

  /**
   * Valida se senhas coincidem
   */
  validatePasswordMatch() {
    const senha = $('#senha')?.value || '';
    const confirmar = $('#confirmar-senha');
    
    if (!confirmar) return true;

    const value = confirmar.value;
    const feedback = $('#password-match');

    if (value.length === 0) {
      if (feedback) {
        feedback.textContent = '';
        feedback.className = '';
      }
      return true;
    }

    if (senha !== value) {
      confirmar.classList.add('is-invalid');
      confirmar.classList.remove('is-valid');
      if (feedback) {
        feedback.textContent = '✗ Senhas não coincidem';
        feedback.className = 'text-danger';
      }
      return false;
    }

    confirmar.classList.remove('is-invalid');
    confirmar.classList.add('is-valid');
    if (feedback) {
      feedback.textContent = '✓ Senhas coincidem';
      feedback.className = 'text-success';
    }
    return true;
  }

  /**
   * Valida formulário completo
   */
  validateForm() {
    const isNomeValid = this.validateNome();
    const isEmailValid = this.validateEmail();
    const isPasswordValid = this.validatePasswordStrength();
    const isPasswordMatchValid = this.validatePasswordMatch();

    return isNomeValid && isEmailValid && isPasswordValid && isPasswordMatchValid;
  }

  /**
   * Manipula envio do formulário
   */
  async handleSubmit() {
    // Valida formulário
    if (!this.validateForm()) {
      toast('Corrija os erros no formulário', 'warning');
      return;
    }

    // Coleta dados
    const nomeCompleto = $('#nome-completo')?.value.trim();
    const email = $('#email')?.value.trim();
    const senha = $('#senha')?.value;
    const confirmarSenha = $('#confirmar-senha')?.value;

    // Validações adicionais
    if (!nomeCompleto || !email || !senha) {
      toast('Preencha todos os campos obrigatórios', 'warning');
      return;
    }

    if (senha !== confirmarSenha) {
      toast('As senhas não coincidem', 'warning');
      return;
    }

    if (senha.length < 6) {
      toast('Senha deve ter pelo menos 6 caracteres', 'warning');
      return;
    }

    // Coleta categorias selecionadas
    const categoriasCheckboxes = $$('#categorias-container input[type="checkbox"]:checked');
    const categoriaIds = Array.from(categoriasCheckboxes).map(cb => parseInt(cb.value));

    if (categoriaIds.length === 0) {
      toast('Selecione pelo menos uma especialidade', 'warning');
      return;
    }

    // Desabilita botão
    const submitBtn = $('#btn-submit');
    if (submitBtn) {
      submitBtn.disabled = true;
      submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Cadastrando...';
    }

    try {
      const tecnicoData = {
        nomeCompleto,
        email,
        senha,
        categoriaIds
      };

      await userService.registerTecnico(tecnicoData);
      
      toast('Técnico cadastrado com sucesso!', 'success');

      // Limpa formulário
      const form = $('#form-cadastrar-tecnico');
      if (form) form.reset();

      // Remove classes de validação
      $$('.is-valid, .is-invalid').forEach(el => {
        el.classList.remove('is-valid', 'is-invalid');
      });

      // Limpa indicadores
      const strengthMeter = $('#password-strength');
      if (strengthMeter) {
        strengthMeter.className = 'password-strength';
        strengthMeter.textContent = '';
      }

      const matchIndicator = $('#password-match');
      if (matchIndicator) {
        matchIndicator.textContent = '';
        matchIndicator.className = '';
      }

      // Redireciona após 2 segundos
      setTimeout(() => {
        window.location.href = ROUTES.ADMIN_DASHBOARD;
      }, 2000);

    } catch (error) {
      console.error('Erro ao cadastrar técnico:', error);
      toast('Erro ao cadastrar técnico: ' + error.message, 'error');
    } finally {
      if (submitBtn) {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-user-plus"></i> Cadastrar Técnico';
      }
    }
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
}

// Auto-inicialização
if (window.location.pathname.includes('admin-cadastrar-tecnico')) {
  const page = new CadastrarTecnicoPage();
  page.init();
}

export default CadastrarTecnicoPage;
