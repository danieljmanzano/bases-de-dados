// ── TELA 0: Menu principal ──

/**
 * Monta a estrutura HTML da tela de menu e a insere em #app.
 */
function construirTelaMenu() {
  const app = document.getElementById("app");

  const screen = document.createElement("div");
  screen.id = "screen-menu";
  screen.className = "screen";

  screen.innerHTML = `
    <div class="app-header">
      <p class="app-titulo">SOS Abobrinha</p>
      <p class="app-subtitulo">Redistribuição de excedentes agrícolas</p>
    </div>

    <button class="btn-menu" id="btn-ir-cadastro">
      <div class="icone">
        <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z"/>
          <polyline points="3.27 6.96 12 12.01 20.73 6.96"/>
          <line x1="12" y1="22.08" x2="12" y2="12"/>
        </svg>
      </div>
      <div>
        <div class="titulo-btn">Cadastrar lote de produto</div>
        <div class="desc-btn">Registrar novo excedente agrícola</div>
      </div>
      <span class="seta">›</span>
    </button>

    <button class="btn-menu" id="btn-ir-consulta">
      <div class="icone">
        <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="11" cy="11" r="8"/>
          <line x1="21" y1="21" x2="16.65" y2="16.65"/>
        </svg>
      </div>
      <div>
        <div class="titulo-btn">Consultar lotes disponíveis</div>
        <div class="desc-btn">Ver excedentes disponíveis para solicitação</div>
      </div>
      <span class="seta">›</span>
    </button>
  `;

  app.appendChild(screen);

  screen.querySelector("#btn-ir-cadastro").addEventListener("click", () => {
    App.navegarPara("passo1");
  });
  screen.querySelector("#btn-ir-consulta").addEventListener("click", () => {
    App.navegarPara("consulta");
  });
}

construirTelaMenu();

App.registrarTela("menu", {});
