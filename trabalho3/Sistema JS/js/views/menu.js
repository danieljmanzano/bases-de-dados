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
      <div class="icone">📦</div>
      <div>
        <div class="titulo-btn">Cadastrar lote de produto</div>
        <div class="desc-btn">Registrar novo excedente agrícola</div>
      </div>
      <span class="seta">›</span>
    </button>

    <button class="btn-menu" id="btn-ir-consulta">
      <div class="icone">🔍</div>
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
