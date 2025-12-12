// Theme Manager
// Gerenciador de tema dark/light mode

import { load, save } from '../utils/storage.js';
import { STORAGE_KEYS } from '../config/constants.js';

/**
 * Gerenciador de temas da aplicação
 */
export class ThemeManager {
  constructor() {
    this.currentTheme = load(STORAGE_KEYS.THEME, 'light');
    this.themeToggleButtons = [];
  }

  /**
   * Aplica o tema ao documento
   * @param {string} theme - Nome do tema ('light' ou 'dark')
   */
  applyTheme(theme = this.currentTheme) {
    if (theme === 'dark') {
      document.body.classList.add('dark-mode');
      document.documentElement.setAttribute('data-theme', 'dark');
    } else {
      document.body.classList.remove('dark-mode');
      document.documentElement.setAttribute('data-theme', 'light');
    }
    
    this.currentTheme = theme;
    save(STORAGE_KEYS.THEME, theme);
    
    // Atualiza ícones dos botões
    this.updateToggleButtons();
  }

  /**
   * Alterna entre temas light e dark
   * @returns {string} Novo tema aplicado
   */
  toggle() {
    const newTheme = this.currentTheme === 'light' ? 'dark' : 'light';
    this.applyTheme(newTheme);
    return newTheme;
  }

  /**
   * Obtém o tema atual
   * @returns {string}
   */
  getCurrentTheme() {
    return this.currentTheme;
  }

  /**
   * Registra botões de toggle de tema
   * @param {string|Element} selector - Seletor CSS ou elemento DOM
   */
  registerToggleButton(selector) {
    const buttons = typeof selector === 'string' 
      ? document.querySelectorAll(selector)
      : [selector];

    buttons.forEach(button => {
      if (!button) return;
      
      this.themeToggleButtons.push(button);
      
      button.addEventListener('click', (e) => {
        e.preventDefault();
        this.toggle();
      });
    });

    this.updateToggleButtons();
  }

  /**
   * Atualiza ícones/texto dos botões de toggle
   */
  updateToggleButtons() {
    this.themeToggleButtons.forEach(button => {
      const isDark = this.currentTheme === 'dark';
      
      // Atualiza ícone se houver
      const icon = button.querySelector('i');
      if (icon) {
        icon.className = isDark ? 'fas fa-sun' : 'fas fa-moon';
      }
      
      // Atualiza texto se for apenas texto
      if (button.textContent && !icon) {
        button.textContent = isDark ? '☀️ Modo Claro' : '🌙 Modo Escuro';
      }

      // Atualiza aria-label para acessibilidade
      button.setAttribute('aria-label', 
        isDark ? 'Ativar modo claro' : 'Ativar modo escuro'
      );
    });
  }

  /**
   * Inicializa o gerenciador de temas
   * Aplica o tema salvo e detecta preferência do sistema se não houver
   */
  init() {
    // Se não houver tema salvo, detecta preferência do sistema
    if (!localStorage.getItem(STORAGE_KEYS.THEME)) {
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      this.currentTheme = prefersDark ? 'dark' : 'light';
    }

    this.applyTheme();

    // Registra botões de toggle que já existem na página
    const toggleButtons = document.querySelectorAll('[data-theme-toggle]');
    if (toggleButtons.length > 0) {
      this.registerToggleButton('[data-theme-toggle]');
    }

    // Escuta mudanças na preferência do sistema
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
      // Só aplica se não houver preferência salva explicitamente
      if (!localStorage.getItem(STORAGE_KEYS.THEME)) {
        this.applyTheme(e.matches ? 'dark' : 'light');
      }
    });
  }
}

// Export singleton instance
export const themeManager = new ThemeManager();
