// ── TELA 1.4: Cadastro — Sucesso ──

/**
 * Monta a estrutura HTML da tela de sucesso e a insere em #app.
 */
function construirTelaSucesso() {
  const app = document.getElementById("app");

  const screen = document.createElement("div");
  screen.id = "screen-sucesso";
  screen.className = "screen";

  screen.innerHTML = `
    <div class="card-sucesso">
      <div class="icone-sucesso">✓</div>
      <p class="titulo-sucesso">Lote cadastrado com sucesso!</p>
      <p class="sub-sucesso">ID do lote: <span id="sucesso-id"></span></p>
    </div>

    <button class="btn-primario" id="sucesso-outro">Cadastrar outro lote</button>
    <button class="btn-secundario" id="sucesso-menu">Voltar ao menu</button>
  `;

  app.appendChild(screen);

  screen.querySelector("#sucesso-outro").addEventListener("click", () => {
    App.limparSession();
    App.navegarPara("passo1");
  });

  screen.querySelector("#sucesso-menu").addEventListener("click", () => {
    App.limparSession();
    App.navegarPara("menu");
  });
}

construirTelaSucesso();

App.registrarTela("sucesso", {
  /**
   * Exibe o ID do lote recém-criado, gerado no passo de confirmação.
   */
  onShow() {
    document.getElementById("sucesso-id").textContent = App.session.id_gerado ?? "";
  },
});
