// DOM Utilities
// Helpers para simplificar seleção de elementos

/**
 * Seleciona um elemento do DOM
 * @param {string} sel - Seletor CSS
 * @param {Element} p - Elemento pai (padrão: document)
 * @returns {Element|null}
 */
export const $ = (sel, p = document) => p.querySelector(sel);

/**
 * Seleciona múltiplos elementos do DOM
 * @param {string} sel - Seletor CSS
 * @param {Element} p - Elemento pai (padrão: document)
 * @returns {Array<Element>}
 */
export const $$ = (sel, p = document) => [...p.querySelectorAll(sel)];
