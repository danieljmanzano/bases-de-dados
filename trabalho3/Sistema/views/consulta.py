"""Tela 2.1 — Consulta de lotes disponíveis, filtrados por classificação."""

import tkinter as tk
from tkinter import ttk

from config import CORES, FONTES, ESPACAMENTO
from components.widgets import botao_voltar, card_lote
from data.mock_data import LOTES

CLASSIFICACOES = ("Consumo humano", "Consumo animal", "Compostagem")


class ConsultaFrame(tk.Frame):
    """Tela de consulta: permite filtrar os lotes disponíveis por
    classificação (consumo humano, consumo animal ou compostagem) e exibe
    os resultados em uma lista com rolagem."""

    def __init__(self, parent, app):
        super().__init__(parent, bg=CORES["fundo"])
        self.app = app
        self.classificacao_atual = CLASSIFICACOES[0]
        self.botoes_filtro = {}

        topo = tk.Frame(self, bg=CORES["fundo"])
        botao_voltar(topo, lambda: self.app.show_frame("menu")).pack(anchor="w")
        tk.Label(
            topo, text="Lotes disponíveis", bg=CORES["fundo"],
            fg=CORES["texto_principal"], font=FONTES["titulo"],
        ).pack(anchor="w", pady=(2, 0))

        filtro = tk.Frame(self, bg=CORES["fundo"])
        tk.Label(
            filtro, text="Filtrar por classificação:", bg=CORES["fundo"],
            fg=CORES["texto_principal"], font=FONTES["corpo"],
        ).pack(anchor="w", pady=(0, 6))

        botoes_frame = tk.Frame(filtro, bg=CORES["fundo"])
        botoes_frame.pack(fill="x")
        for classificacao in CLASSIFICACOES:
            botao = tk.Button(
                botoes_frame, text=classificacao, font=FONTES["pequena"],
                relief="flat", bd=0, highlightthickness=1, cursor="hand2",
                padx=12, pady=6,
                command=lambda c=classificacao: self._selecionar_filtro(c),
            )
            botao.pack(side="left", padx=(0, 8))
            self.botoes_filtro[classificacao] = botao

        rodape = tk.Frame(self, bg=CORES["fundo"])
        self.label_contagem = tk.Label(
            rodape, text="", bg=CORES["fundo"],
            fg=CORES["texto_secundario"], font=FONTES["pequena"],
        )
        self.label_contagem.pack(anchor="w")

        area_resultados = tk.Frame(self, bg=CORES["fundo"])
        self.canvas = tk.Canvas(area_resultados, bg=CORES["fundo"], highlightthickness=0)
        scrollbar = ttk.Scrollbar(area_resultados, orient="vertical", command=self.canvas.yview)
        self.frame_resultados = tk.Frame(self.canvas, bg=CORES["fundo"])

        self._janela_id = self.canvas.create_window((0, 0), window=self.frame_resultados, anchor="nw")
        self.canvas.configure(yscrollcommand=scrollbar.set)
        self.frame_resultados.bind(
            "<Configure>", lambda e: self.canvas.configure(scrollregion=self.canvas.bbox("all"))
        )
        self.canvas.bind(
            "<Configure>", lambda e: self.canvas.itemconfig(self._janela_id, width=e.width)
        )
        self.canvas.bind_all("<MouseWheel>", self._rolar_mouse)
        self.canvas.bind_all("<Button-4>", lambda e: self.canvas.yview_scroll(-1, "units"))
        self.canvas.bind_all("<Button-5>", lambda e: self.canvas.yview_scroll(1, "units"))

        self.canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")

        # Empacotamento na ordem que reserva primeiro o espaço fixo
        # (topo, filtro e rodapé) para então a área de resultados
        # ocupar o restante do espaço disponível.
        lateral = ESPACAMENTO["lateral"]
        topo.pack(fill="x", padx=lateral, pady=(ESPACAMENTO["topo"], 10))
        filtro.pack(fill="x", padx=lateral)
        rodape.pack(fill="x", padx=lateral, pady=(6, 16), side="bottom")
        area_resultados.pack(fill="both", expand=True, padx=lateral, pady=(12, 0))

    def _rolar_mouse(self, event):
        self.canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")

    def on_show(self):
        """Ativa o filtro 'Consumo humano' por padrão e carrega os resultados."""
        self._selecionar_filtro(CLASSIFICACOES[0])

    def _selecionar_filtro(self, classificacao):
        """Atualiza o estilo dos botões de filtro e recarrega os resultados."""
        self.classificacao_atual = classificacao
        for nome, botao in self.botoes_filtro.items():
            if nome == classificacao:
                botao.config(bg=CORES["verde_principal"], fg=CORES["branco"], highlightbackground=CORES["verde_principal"])
            else:
                botao.config(bg=CORES["branco"], fg=CORES["texto_secundario"], highlightbackground=CORES["borda"])
        self._carregar_resultados(classificacao)

    def _carregar_resultados(self, classificacao):
        """Filtra os lotes disponíveis pela classificação selecionada (mock)
        e renderiza um card por resultado.

        TODO (integração banco):
            SELECT lp.id_lote, p.nome AS produto, pr.nome AS produtor,
                   lp.quantidade, lp.validade, lp.localizacao_atual
            FROM lote_de_produto lp
            JOIN produto p ON p.nome = lp.produto
            JOIN produtor_rural pr ON pr.cpf_cnpj = lp.cpf_cnpj_produtor
            WHERE lp.classificacao = %s
            ORDER BY lp.validade ASC
        """
        for widget in self.frame_resultados.winfo_children():
            widget.destroy()

        resultados = [lote for lote in LOTES if lote["classificacao"] == classificacao]

        if not resultados:
            tk.Label(
                self.frame_resultados, text="Nenhum lote disponível para esta classificação.",
                bg=CORES["fundo"], fg=CORES["texto_secundario"], font=FONTES["corpo"],
            ).pack(pady=30)
        else:
            for lote in resultados:
                card_lote(self.frame_resultados, lote).pack(fill="x", pady=(0, 10))

        self.canvas.yview_moveto(0)
        plural = "s" if len(resultados) != 1 else ""
        self.label_contagem.config(text=f"{len(resultados)} lote{plural} encontrado{plural}")
