// Tecnico Config Page Controller
// Controla a lógica da página de configurações do técnico

import { $, $$ } from '../../utils/dom.js';
import { toast } from '../../utils/helpers.js';
import { userService } from '../../services/UserService.js';
import { categoryService } from '../../services/CategoryService.js';
import { authService } from '../../services/AuthService.js';
import { themeManager } from '../../components/ThemeManager.js';
import { USER_TYPES, ROUTES } from '../../config/constants.js';

/**
 * Controller da página de configurações do técnico
 */
export class TecnicoConfigPage {
  constructor() {
    this.currentUser = null;
    this.categorias = [];
    this.categoriasEspecialidade = [];
  }

  /**
   * Inicializa a página
   */
  async init() {
    // Verifica autenticação e role
    if (!authService.requireAuth([USER_TYPES.TECNICO])) {
      return;
    }

    // Inicializa tema
    themeManager.init();
    themeManager.registerToggleButton('[data-theme-toggle]');

    await this.loadData();
    this.setupEventListeners();
    this.renderWelcome();
  }

  /**
   * Carrega dados do técnico e categorias
   */
  async loadData() {
    try {
      this.showLoading();

      // Carrega dados em paralelo
      [this.currentUser, this.categorias] = await Promise.all([
        userService.getProfile(),
        categoryService.getAll()
      ]);

      // Categorias de especialidade do técnico (se houver essa informação)
      this.categoriasEspecialidade = this.currentUser.categorias || [];

      this.populateForm();
      this.renderCategories();
      this.renderStats();
      this.hideLoading();
    } catch (error) {
      console.error('Erro ao carregar dados:', error);
      toast('Erro ao carregar configurações', 'error');
    }
  }

  /**
   * Renderiza mensagem de boas-vindas
   */
  renderWelcome() {
    const welcomeEl = $('#welcome-message');
    if (!welcomeEl) return;

    const nome = this.currentUser?.nomeCompleto || 'Técnico';
    const primeiroNome = nome.split(' ')[0];

    welcomeEl.innerHTML = `
      <h1>Configurações do Técnico</h1>
      <p>Gerencie suas preferências e especialidades, ${primeiroNome}</p>
    `;
  }

  /**
   * Preenche formulário
   */
  populateForm() {
    const nomeInput = $('#nome-completo');
    const emailDisplay = $('#email-display');

    if (nomeInput && this.currentUser?.nomeCompleto) {
      nomeInput.value = this.currentUser.nomeCompleto;
    }

    if (emailDisplay && this.currentUser?.email) {
      emailDisplay.textContent = this.currentUser.email;
    }

    // Renderizar informações do técnico
    this.renderTecnicoInfo();
  }

  /**
   * Renderiza informações do técnico
   */
  renderTecnicoInfo() {
    const infoContainer = $('#tecnico-info');
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
          <label>Técnico desde:</label>
          <span>${cadastroDate}</span>
        </div>
        <div class="info-item">
          <label>Status:</label>
          <span class="badge badge-${this.currentUser.ativo ? 'success' : 'danger'}">
            ${this.currentUser.ativo ? 'Ativo' : 'Inativo'}
          </span>
        </div>
        <div class="info-item">
          <label>Especialidades:</label>
          <span>${this.categoriasEspecialidade.length} categoria(s)</span>
        </div>
      </div>
    `;
  }

  /**
   * Renderiza estatísticas do técnico
   */
  async renderStats() {
    const statsContainer = $('#tecnico-stats');
    if (!statsContainer) return;

    try {
      const stats = await userService.getStats();

      statsContainer.innerHTML = `
        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-ticket-alt"></i></div>
            <div class="stat-info">
              <div class="stat-value">${stats.totalChamados || 0}</div>
              <div class="stat-label">Chamados Atribuídos</div>
            </div>
          </div>
          <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-check-circle"></i></div>
            <div class="stat-info">
              <div class="stat-value">${stats.chamadosResolvidos || 0}</div>
              <div class="stat-label">Resolvidos</div>
            </div>
          </div>
          <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-clock"></i></div>
            <div class="stat-info">
              <div class="stat-value">${stats.chamadosAndamento || 0}</div>
              <div class="stat-label">Em Andamento</div>
            </div>
          </div>
          <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-percentage"></i></div>
            <div class="stat-info">
              <div class="stat-value">${stats.taxaResolucao || 0}%</div>
              <div class="stat-label">Taxa de Resolução</div>
            </div>
          </div>
        </div>
      `;
    } catch (error) {
      console.error('Erro ao carregar estatísticas:', error);
      statsContainer.innerHTML = `<p class="text-muted">Estatísticas não disponíveis</p>`;
    }
  }

  /**
   * Renderiza categorias para seleção
   */
  renderCategories() {
    const container = $('#categories-list');
    if (!container) return;

    container.innerHTML = `
      <div class="categories-grid">
        ${this.categorias.map(cat => {
          const isSelected = this.categoriasEspecialidade.some(c => c.id === cat.id);
          return `
            <div class="category-item ${isSelected ? 'selected' : ''}" data-category-id="${cat.id}">
              <input 
                type="checkbox" 
                id="cat-${cat.id}" 
                value="${cat.id}"
                ${isSelected ? 'checked' : ''}
              />
              <label for="cat-${cat.id}">
                <i class="fas fa-tag"></i>
                ${this.escapeHtml(cat.nome)}
              </label>
            </div>
          `;
        }).join('')}
      </div>
      <button type="button" class="btn btn-primary" id="btn-save-categories">
        <i class="fas fa-save"></i> Salvar Especialidades
      </button>
    `;

    // Event listener para salvar categorias
    const saveBtn = $('#btn-save-categories');
    if (saveBtn) {
      saveBtn.addEventListener('click', () => this.handleSaveCategories());
    }
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
  }

  /**
   * Atualiza perfil
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
      await this.loadData();
    } catch (error) {
      toast('Erro ao atualizar perfil: ' + error.message, 'error');
    } finally {
      if (submitBtn) {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-save"></i> Salvar';
      }
    }
  }

  /**
   * Altera senha
   */
  async handleChangePassword() {
    const senhaAtual = $('#senha-atual')?.value;
    const novaSenha = $('#nova-senha')?.value;
    const confirmarSenha = $('#confirmar-senha')?.value;

    if (!senhaAtual || !novaSenha || !confirmarSenha) {
      toast('Preencha todos os campos', 'warning');
      return;
    }

    if (novaSenha !== confirmarSenha) {
      toast('As senhas não coincidem', 'warning');
      return;
    }

    if (novaSenha.length < 6) {
      toast('Senha deve ter pelo menos 6 caracteres', 'warning');
      return;
    }

    const submitBtn = $('#btn-change-password');
    if (submitBtn) {
      submitBtn.disabled = true;
      submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Alterando...';
    }

    try {
      await userService.changePassword({ senhaAtual, novaSenha });
      toast('Senha alterada com sucesso!', 'success');

      // Limpar formulário
      if ($('#senha-atual')) $('#senha-atual').value = '';
      if ($('#nova-senha')) $('#nova-senha').value = '';
      if ($('#confirmar-senha')) $('#confirmar-senha').value = '';
    } catch (error) {
      toast('Erro ao alterar senha: ' + error.message, 'error');
    } finally {
      if (submitBtn) {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-key"></i> Alterar Senha';
      }
    }
  }

  /**
   * Salva categorias de especialidade
   */
  async handleSaveCategories() {
    const checkboxes = $$('#categories-list input[type="checkbox"]:checked');
    const categoriaIds = Array.from(checkboxes).map(cb => parseInt(cb.value));

    const saveBtn = $('#btn-save-categories');
    if (saveBtn) {
      saveBtn.disabled = true;
      saveBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Salvando...';
    }

    try {
      // API endpoint para atualizar especialidades do técnico
      await userService.update(this.currentUser.id, { categoriaIds });
      toast('Especialidades atualizadas com sucesso!', 'success');
      await this.loadData();
    } catch (error) {
      toast('Erro ao salvar especialidades: ' + error.message, 'error');
    } finally {
      if (saveBtn) {
        saveBtn.disabled = false;
        saveBtn.innerHTML = '<i class="fas fa-save"></i> Salvar Especialidades';
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
if (window.location.pathname.includes('tecnico-config')) {
  const configPage = new TecnicoConfigPage();
  configPage.init();
}

export default TecnicoConfigPage;
