// ── Núcleo de navegação e estado global da aplicação ──

/**
 * Objeto central da aplicação.
 * Mantém o estado compartilhado entre as telas (App.session) e
 * controla qual tela está visível no momento.
 */
const App = {
  /** Dados acumulados durante o fluxo de cadastro (passo1 → passo2 → passo3). */
  session: {},

  /** Nome da tela atualmente exibida (ex.: "menu", "passo1"). */
  telaAtual: null,

  /** Registro de telas. Cada view se registra aqui via App.registrarTela(). */
  telas: {},

  /**
   * Inicializa a aplicação, renderizando a tela de menu.
   */
  init() {
    this.navegarPara("menu");
  },

  /**
   * Registra uma tela para que possa ser controlada pela navegação.
   * @param {string} nome - Identificador da tela (usado em id="screen-[nome]").
   * @param {{ onShow?: Function }} tela - Objeto da view, com onShow opcional.
   */
  registrarTela(nome, tela) {
    this.telas[nome] = tela;
  },

  /**
   * Troca a tela visível, ocultando as demais.
   * @param {string} nomeTela - Identificador da tela a ser exibida.
   */
  navegarPara(nomeTela) {
    document.querySelectorAll(".screen").forEach((el) => {
      el.classList.remove("active");
    });

    const elementoTela = document.getElementById(`screen-${nomeTela}`);
    if (elementoTela) {
      elementoTela.classList.add("active");
    }

    const tela = this.telas[nomeTela];
    if (tela && typeof tela.onShow === "function") {
      tela.onShow();
    }

    this.telaAtual = nomeTela;
  },

  /**
   * Limpa os dados acumulados do fluxo de cadastro.
   */
  limparSession() {
    this.session = {};
  },
};

document.addEventListener("DOMContentLoaded", () => App.init());
