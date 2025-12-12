// New Ticket Page Controller
// Controla a lógica da página de criação de chamado

import { $, $$ } from '../../utils/dom.js';
import { toast, isValidEmail } from '../../utils/helpers.js';
import { ticketService } from '../../services/TicketService.js';
import { categoryService } from '../../services/CategoryService.js';
import { priorityService } from '../../services/PriorityService.js';
import { authService } from '../../services/AuthService.js';
import { themeManager } from '../../components/ThemeManager.js';
import { ROUTES } from '../../config/constants.js';

/**
 * Controller da página de novo chamado
 */
export class NewTicket {
  constructor() {
    this.categorias = [];
    this.prioridades = [];
    this.useAI = false;
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

    await this.loadData();
    this.setupEventListeners();
    this.setupFormValidation();
  }

  /**
   * Carrega dados necessários
   */
  async loadData() {
    try {
      [this.categorias, this.prioridades] = await Promise.all([
        categoryService.getAll(),
        priorityService.getAll()
      ]);

      this.renderCategoriaOptions();
      this.renderPrioridadeOptions();
    } catch (error) {
      console.error('Erro ao carregar dados:', error);
      toast('Erro ao carregar dados do formulário', 'error');
    }
  }

  /**
   * Renderiza opções de categoria
   */
  renderCategoriaOptions() {
    const select = $('#categoria-id');
    if (!select) return;

    select.innerHTML = `
      <option value="">Selecione uma categoria</option>
      ${this.categorias.map(cat => `
        <option value="${cat.id}">${cat.nome}</option>
      `).join('')}
    `;
  }

  /**
   * Renderiza opções de prioridade
   */
  renderPrioridadeOptions() {
    const select = $('#prioridade-id');
    if (!select) return;

    select.innerHTML = `
      <option value="">Selecione uma prioridade</option>
      ${this.prioridades.map(pr => `
        <option value="${pr.id}" ${pr.id === 2 ? 'selected' : ''}>
          ${pr.nome}
        </option>
      `).join('')}
    `;
  }

  /**
   * Configura event listeners
   */
  setupEventListeners() {
    // Formulário principal
    const form = $('#form-new-ticket');
    if (form) {
      form.addEventListener('submit', async (e) => {
        e.preventDefault();
        await this.handleSubmit();
      });
    }

    // Checkbox de IA
    const aiCheckbox = $('#use-ai');
    if (aiCheckbox) {
      aiCheckbox.addEventListener('change', (e) => {
        this.useAI = e.target.checked;
        this.toggleAIInfo();
      });
    }

    // Contador de caracteres
    const descricaoTextarea = $('#descricao');
    if (descricaoTextarea) {
      descricaoTextarea.addEventListener('input', () => {
        this.updateCharacterCount();
      });
    }

    // Botão cancelar
    const cancelBtn = $('#btn-cancel');
    if (cancelBtn) {
      cancelBtn.addEventListener('click', () => {
        if (confirm('Tem certeza que deseja cancelar? Todas as alterações serão perdidas.')) {
          window.history.back();
        }
      });
    }

    // Validação em tempo real
    const titulo = $('#titulo');
    if (titulo) {
      titulo.addEventListener('blur', () => {
        this.validateTitulo();
      });
    }

    if (descricaoTextarea) {
      descricaoTextarea.addEventListener('blur', () => {
        this.validateDescricao();
      });
    }

    const categoriaSelect = $('#categoria-id');
    if (categoriaSelect) {
      categoriaSelect.addEventListener('change', () => {
        this.validateCategoria();
      });
    }
  }

  /**
   * Configura validação do formulário
   */
  setupFormValidation() {
    const form = $('#form-new-ticket');
    if (!form) return;

    // Adiciona classes de validação do Bootstrap
    form.classList.add('needs-validation');
    form.noValidate = true;
  }

  /**
   * Valida título
   */
  validateTitulo() {
    const titulo = $('#titulo');
    if (!titulo) return true;

    const value = titulo.value.trim();
    const feedback = titulo.nextElementSibling;

    if (value.length < 5) {
      titulo.classList.add('is-invalid');
      titulo.classList.remove('is-valid');
      if (feedback) {
        feedback.textContent = 'O título deve ter pelo menos 5 caracteres';
      }
      return false;
    }

    if (value.length > 200) {
      titulo.classList.add('is-invalid');
      titulo.classList.remove('is-valid');
      if (feedback) {
        feedback.textContent = 'O título não pode ter mais de 200 caracteres';
      }
      return false;
    }

    titulo.classList.remove('is-invalid');
    titulo.classList.add('is-valid');
    return true;
  }

  /**
   * Valida descrição
   */
  validateDescricao() {
    const descricao = $('#descricao');
    if (!descricao) return true;

    const value = descricao.value.trim();
    const feedback = descricao.nextElementSibling;

    if (value.length < 20) {
      descricao.classList.add('is-invalid');
      descricao.classList.remove('is-valid');
      if (feedback) {
        feedback.textContent = 'A descrição deve ter pelo menos 20 caracteres';
      }
      return false;
    }

    if (value.length > 2000) {
      descricao.classList.add('is-invalid');
      descricao.classList.remove('is-valid');
      if (feedback) {
        feedback.textContent = 'A descrição não pode ter mais de 2000 caracteres';
      }
      return false;
    }

    descricao.classList.remove('is-invalid');
    descricao.classList.add('is-valid');
    return true;
  }

  /**
   * Valida categoria
   */
  validateCategoria() {
    const categoria = $('#categoria-id');
    if (!categoria) return true;

    const value = categoria.value;
    const feedback = categoria.nextElementSibling;

    if (!value) {
      categoria.classList.add('is-invalid');
      categoria.classList.remove('is-valid');
      if (feedback) {
        feedback.textContent = 'Selecione uma categoria';
      }
      return false;
    }

    categoria.classList.remove('is-invalid');
    categoria.classList.add('is-valid');
    return true;
  }

  /**
   * Valida formulário completo
   */
  validateForm() {
    const isTituloValid = this.validateTitulo();
    const isDescricaoValid = this.validateDescricao();
    const isCategoriaValid = this.validateCategoria();

    return isTituloValid && isDescricaoValid && isCategoriaValid;
  }

  /**
   * Atualiza contador de caracteres
   */
  updateCharacterCount() {
    const descricao = $('#descricao');
    const counter = $('#char-count');
    
    if (!descricao || !counter) return;

    const length = descricao.value.length;
    const max = 2000;
    
    counter.textContent = `${length}/${max} caracteres`;
    
    if (length > max * 0.9) {
      counter.classList.add('text-warning');
    } else {
      counter.classList.remove('text-warning');
    }

    if (length > max) {
      counter.classList.add('text-danger');
      counter.classList.remove('text-warning');
    } else {
      counter.classList.remove('text-danger');
    }
  }

  /**
   * Alterna informações sobre IA
   */
  toggleAIInfo() {
    const aiInfo = $('#ai-info');
    if (!aiInfo) return;

    if (this.useAI) {
      aiInfo.classList.remove('d-none');
      aiInfo.innerHTML = `
        <div class="alert alert-info">
          <i class="fas fa-magic"></i>
          <strong>Análise com IA Ativada</strong>
          <p>
            A inteligência artificial irá analisar sua descrição e sugerir automaticamente 
            a categoria e prioridade mais adequadas para seu chamado.
          </p>
        </div>
      `;
    } else {
      aiInfo.classList.add('d-none');
    }
  }

  /**
   * Manipula envio do formulário
   */
  async handleSubmit() {
    // Valida formulário
    if (!this.validateForm()) {
      toast('Por favor, corrija os erros no formulário', 'warning');
      return;
    }

    // Coleta dados do formulário
    const titulo = $('#titulo').value.trim();
    const descricao = $('#descricao').value.trim();
    const categoriaId = parseInt($('#categoria-id').value);
    const prioridadeId = parseInt($('#prioridade-id').value);

    if (!categoriaId || !prioridadeId) {
      toast('Preencha todos os campos obrigatórios', 'warning');
      return;
    }

    // Desabilita botão de envio
    const submitBtn = $('#btn-submit');
    if (submitBtn) {
      submitBtn.disabled = true;
      submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Criando...';
    }

    try {
      let ticket;

      if (this.useAI) {
        // Cria com IA
        ticket = await ticketService.createWithAI({
          titulo,
          descricao
        });
        toast('Chamado criado com sucesso usando IA!', 'success');
      } else {
        // Cria normal
        ticket = await ticketService.create({
          titulo,
          descricao,
          categoriaId,
          prioridadeId
        });
        toast('Chamado criado com sucesso!', 'success');
      }

      // Redireciona para detalhes do chamado
      setTimeout(() => {
        window.location.href = `${ROUTES.TICKET_DETALHES}?id=${ticket.id}`;
      }, 1000);

    } catch (error) {
      console.error('Erro ao criar chamado:', error);
      toast('Erro ao criar chamado: ' + error.message, 'error');

      // Reabilita botão
      if (submitBtn) {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-paper-plane"></i> Criar Chamado';
      }
    }
  }
}

// Auto-inicialização
if (window.location.pathname.includes('ticket') && (window.location.pathname.includes('novo') || window.location.pathname.includes('new'))) {
  const newTicket = new NewTicket();
  newTicket.init();
}

export default NewTicket;
