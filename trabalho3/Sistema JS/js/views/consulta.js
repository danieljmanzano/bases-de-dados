// ── TELA 2.1: Consulta de lotes disponíveis ──

/** Classificação atualmente selecionada nos filtros. */
let filtroAtivo = "Consumo humano";

/**
 * Monta a estrutura HTML da tela de consulta e a insere em #app.
 */
function construirTelaConsulta() {
  const app = document.getElementById("app");

  const screen = document.createElement("div");
  screen.id = "screen-consulta";
  screen.className = "screen";

  screen.innerHTML = `
    <button class="btn-voltar" id="consulta-voltar">← Voltar</button>
    <p class="titulo-tela">Lotes disponíveis</p>

    <div class="filtros">
      <button class="btn-filtro" id="filtro-humano" data-classificacao="Consumo humano">Consumo humano</button>
      <button class="btn-filtro" id="filtro-animal" data-classificacao="Consumo animal">Consumo animal</button>
      <button class="btn-filtro" id="filtro-composto" data-classificacao="Compostagem">Compostagem</button>
    </div>

    <div class="lista-resultados" id="consulta-lista"></div>
    <p class="rodape-resultados" id="consulta-rodape"></p>
  `;

  app.appendChild(screen);

  screen.querySelector("#consulta-voltar").addEventListener("click", () => {
    App.navegarPara("menu");
  });

  screen.querySelectorAll(".btn-filtro").forEach((botao) => {
    botao.addEventListener("click", () => {
      filtroAtivo = botao.dataset.classificacao;
      atualizarBotoesFiltro();
      carregarResultados();
    });
  });
}

/**
 * Retorna a classe CSS de badge correspondente a uma classificação.
 * @param {string} classificacao - "Consumo humano", "Consumo animal" ou "Compostagem".
 * @returns {string} Nome da classe CSS do badge.
 */
function badgeClass(classificacao) {
  switch (classificacao) {
    case "Consumo humano":
      return "badge-humano";
    case "Consumo animal":
      return "badge-animal";
    case "Compostagem":
      return "badge-composto";
    default:
      return "";
  }
}

/**
 * Retorna a classe CSS de destaque do botão de filtro correspondente
 * a uma classificação.
 * @param {string} classificacao - "Consumo humano", "Consumo animal" ou "Compostagem".
 * @returns {string} Nome da classe CSS do filtro ativo.
 */
function filtroClass(classificacao) {
  switch (classificacao) {
    case "Consumo humano":
      return "ativo-humano";
    case "Consumo animal":
      return "ativo-animal";
    case "Compostagem":
      return "ativo-composto";
    default:
      return "";
  }
}

/**
 * Atualiza a aparência dos botões de filtro de acordo com filtroAtivo.
 */
function atualizarBotoesFiltro() {
  const screen = document.getElementById("screen-consulta");
  screen.querySelectorAll(".btn-filtro").forEach((botao) => {
    botao.classList.remove("ativo-humano", "ativo-animal", "ativo-composto");
    if (botao.dataset.classificacao === filtroAtivo) {
      botao.classList.add(filtroClass(filtroAtivo));
    }
  });
}

/**
 * Filtra os lotes mockados pela classificação ativa e renderiza
 * a lista de resultados na tela.
 */
function carregarResultados() {
  // TODO: const res = await fetch(`/api/lotes?classificacao=${encodeURIComponent(filtroAtivo)}`)
  //       const resultados = await res.json();
  const resultados = LOTES.filter((lote) => lote.classificacao === filtroAtivo);

  const screen = document.getElementById("screen-consulta");
  const lista = screen.querySelector("#consulta-lista");
  const rodape = screen.querySelector("#consulta-rodape");

  lista.innerHTML = "";

  if (resultados.length === 0) {
    lista.innerHTML = `<p class="vazio">Nenhum lote disponível para esta classificação.</p>`;
  } else {
    resultados.forEach((lote) => {
      const card = document.createElement("div");
      card.className = "card-lote";
      card.innerHTML = `
        <div class="lote-header">
          <span class="lote-nome">${lote.produto} — Lote #${lote.id}</span>
          <span class="badge ${badgeClass(lote.classificacao)}">${lote.classificacao}</span>
        </div>
        <p class="lote-meta">Produtor: ${lote.produtor} · ${lote.quantidade} kg · Val: ${lote.validade}</p>
        <p class="lote-meta">Local: ${lote.localizacao}</p>
      `;
      lista.appendChild(card);
    });
  }

  lista.scrollTop = 0;
  rodape.textContent = `${resultados.length} lote(s) encontrado(s)`;
}

construirTelaConsulta();

App.registrarTela("consulta", {
  /**
   * Ativa o filtro "Consumo humano" por padrão e carrega os resultados.
   */
  onShow() {
    filtroAtivo = "Consumo humano";
    atualizarBotoesFiltro();
    carregarResultados();
  },
});
