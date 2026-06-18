"""Widgets reutilizáveis usados em todas as telas do sistema SOS Abobrinha."""

import tkinter as tk
from tkinter import ttk

from config import CORES, FONTES


def _escurecer(cor_hex, fator=0.85):
    """Retorna uma versão mais escura de uma cor hexadecimal, usada no hover dos botões."""
    cor_hex = cor_hex.lstrip("#")
    r, g, b = (int(cor_hex[i:i + 2], 16) for i in (0, 2, 4))
    r, g, b = (max(0, int(c * fator)) for c in (r, g, b))
    return f"#{r:02x}{g:02x}{b:02x}"


def botao_primario(parent, texto, comando):
    """Cria o botão de destaque do fluxo (fundo verde, texto branco), com leve
    escurecimento ao passar o mouse."""
    cor_normal = CORES["verde_principal"]
    cor_hover = _escurecer(cor_normal)
    botao = tk.Button(
        parent, text=texto, command=comando,
        bg=cor_normal, fg=CORES["branco"], activebackground=cor_hover,
        activeforeground=CORES["branco"], font=FONTES["label"],
        relief="flat", bd=0, cursor="hand2", pady=11,
    )
    botao.bind("<Enter>", lambda e: botao.config(bg=cor_hover))
    botao.bind("<Leave>", lambda e: botao.config(bg=cor_normal))
    return botao


def botao_secundario(parent, texto, comando):
    """Cria um botão secundário (fundo branco, borda cinza) para ações
    alternativas, com leve destaque ao passar o mouse."""
    cor_normal = CORES["branco"]
    cor_hover = CORES["fundo"]
    botao = tk.Button(
        parent, text=texto, command=comando,
        bg=cor_normal, fg=CORES["texto_principal"],
        activebackground=cor_hover, font=FONTES["label"],
        relief="flat", bd=0, highlightthickness=1,
        highlightbackground=CORES["borda"], highlightcolor=CORES["borda"],
        cursor="hand2", pady=11,
    )
    botao.bind("<Enter>", lambda e: botao.config(bg=cor_hover))
    botao.bind("<Leave>", lambda e: botao.config(bg=cor_normal))
    return botao


def botao_voltar(parent, comando):
    """Cria o link de navegação '← Voltar', sem borda e alinhado à esquerda,
    destacado em verde ao passar o mouse."""
    botao = tk.Button(
        parent, text="← Voltar", command=comando,
        bg=parent["bg"], fg=CORES["texto_secundario"], font=FONTES["corpo"],
        relief="flat", bd=0, cursor="hand2", anchor="w", padx=0,
        activebackground=parent["bg"], activeforeground=CORES["verde_principal"],
    )
    botao.bind("<Enter>", lambda e: botao.config(fg=CORES["verde_principal"]))
    botao.bind("<Leave>", lambda e: botao.config(fg=CORES["texto_secundario"]))
    return botao


def botao_menu(parent, texto, descricao, comando):
    """Cria um item de menu (título em negrito, descrição abaixo e seta '›' à
    direita) usado na tela inicial. Destaca o fundo e a seta ao passar o mouse."""
    cor_normal = CORES["branco"]
    cor_hover = CORES["fundo"]

    # A largura e a altura NÃO são fixadas (sem pack_propagate(False)): isso
    # permitiria que o texto fosse cortado quando mais longo que o tamanho
    # congelado. A altura de ~60px vem do padding interno dos rótulos, e a
    # largura é definida naturalmente pelo conteúdo (todos os itens do menu
    # ficam com a mesma largura, igual à do item mais largo, graças ao
    # fill="x" usado por quem empacota o frame retornado).
    frame = tk.Frame(
        parent, bg=cor_normal, highlightbackground=CORES["borda"],
        highlightthickness=1, cursor="hand2",
    )

    texto_frame = tk.Frame(frame, bg=cor_normal)
    texto_frame.pack(side="left", fill="both", expand=True, padx=18, pady=14)

    label_titulo = tk.Label(
        texto_frame, text=texto, bg=cor_normal, fg=CORES["texto_principal"],
        font=(FONTES["label"][0], FONTES["label"][1], "bold"), anchor="w",
    )
    label_titulo.pack(fill="x")

    label_descricao = tk.Label(
        texto_frame, text=descricao, bg=cor_normal, fg=CORES["texto_secundario"],
        font=FONTES["pequena"], anchor="w",
    )
    label_descricao.pack(fill="x")

    label_seta = tk.Label(
        frame, text="›", bg=cor_normal, fg=CORES["texto_secundario"],
        font=(FONTES["titulo"][0], 18, "bold"),
    )
    label_seta.pack(side="right", padx=18)

    widgets_internos = [frame, texto_frame, label_titulo, label_descricao]

    def ao_clicar(_event=None):
        comando()

    def ao_entrar(_event=None):
        for w in widgets_internos:
            w.config(bg=cor_hover)
        label_seta.config(bg=cor_hover, fg=CORES["verde_principal"])

    def ao_sair(_event=None):
        for w in widgets_internos:
            w.config(bg=cor_normal)
        label_seta.config(bg=cor_normal, fg=CORES["texto_secundario"])

    for w in widgets_internos + [label_seta]:
        w.bind("<Button-1>", ao_clicar)
        w.bind("<Enter>", ao_entrar)
        w.bind("<Leave>", ao_sair)

    return frame


def entry_padrao(parent, textvariable, **kwargs):
    """Cria um Entry com visual flat e anel de foco verde (destaque nativo do
    Tk ao clicar no campo, sem necessidade de binds manuais)."""
    return tk.Entry(
        parent, textvariable=textvariable, font=FONTES["corpo"],
        relief="flat", bd=0, highlightthickness=1,
        highlightbackground=CORES["borda"], highlightcolor=CORES["verde_principal"],
        **kwargs,
    )


def combobox_padrao(parent, textvariable, valores):
    """Cria uma caixa de seleção (somente leitura) com visual flat consistente
    com os demais campos, usada para escolher um item de uma lista fixa."""
    estilo = ttk.Style()
    estilo.theme_use("clam")
    estilo.configure(
        "SOS.TCombobox", fieldbackground=CORES["branco"], background=CORES["branco"],
        foreground=CORES["texto_principal"], arrowcolor=CORES["texto_secundario"],
        bordercolor=CORES["borda"], lightcolor=CORES["branco"], darkcolor=CORES["branco"],
        padding=6,
    )
    combo = ttk.Combobox(
        parent, textvariable=textvariable, values=valores,
        state="readonly", font=FONTES["corpo"], style="SOS.TCombobox",
    )
    return combo


def badge_classificacao(parent, classificacao):
    """Cria uma etiqueta colorida indicando a classificação do lote (consumo
    humano, consumo animal ou compostagem)."""
    cores_por_classificacao = {
        "Consumo humano": (CORES["badge_humano_bg"], CORES["badge_humano_fg"]),
        "Consumo animal": (CORES["badge_animal_bg"], CORES["badge_animal_fg"]),
        "Compostagem":    (CORES["composto_bg"], CORES["composto_fg"]),
    }
    bg, fg = cores_por_classificacao.get(
        classificacao, (CORES["fundo"], CORES["texto_secundario"])
    )
    return tk.Label(
        parent, text=classificacao, bg=bg, fg=fg, font=FONTES["pequena"],
        padx=8, pady=2,
    )


def card_lote(parent, lote):
    """Cria um card branco com borda e uma faixa colorida à esquerda
    (conforme a classificação) exibindo as informações resumidas de um lote
    de produto (produto, produtor, quantidade, validade e localização)."""
    cores_faixa = {
        "Consumo humano": CORES["badge_humano_fg"],
        "Consumo animal": CORES["badge_animal_fg"],
        "Compostagem":    CORES["composto_fg"],
    }
    cor_faixa = cores_faixa.get(lote["classificacao"], CORES["borda"])

    moldura = tk.Frame(
        parent, bg=CORES["branco"], highlightbackground=CORES["borda"],
        highlightthickness=1,
    )

    tk.Frame(moldura, bg=cor_faixa, width=4).pack(side="left", fill="y")

    conteudo = tk.Frame(moldura, bg=CORES["branco"], padx=14, pady=12)
    conteudo.pack(side="left", fill="both", expand=True)

    linha1 = tk.Frame(conteudo, bg=CORES["branco"])
    linha1.pack(fill="x")
    tk.Label(
        linha1, text=f"{lote['produto']} — Lote #{lote['id']}",
        bg=CORES["branco"], fg=CORES["texto_principal"],
        font=(FONTES["label"][0], FONTES["label"][1], "bold"), anchor="w",
    ).pack(side="left")
    badge_classificacao(linha1, lote["classificacao"]).pack(side="right")

    tk.Label(
        conteudo,
        text=f"Produtor: {lote['produtor']} · {lote['quantidade']} kg · Val: {lote['validade']}",
        bg=CORES["branco"], fg=CORES["texto_secundario"], font=FONTES["pequena"], anchor="w",
    ).pack(fill="x", pady=(6, 0))

    tk.Label(
        conteudo, text=f"Local: {lote['localizacao']}",
        bg=CORES["branco"], fg=CORES["texto_secundario"], font=FONTES["pequena"], anchor="w",
    ).pack(fill="x")

    return moldura


def label_erro(parent, texto=""):
    """Cria uma label vermelha pequena para exibir mensagens de erro inline.
    Deve ser ocultada/exibida pela view com pack_forget()/pack()."""
    return tk.Label(
        parent, text=texto, bg=parent["bg"], fg=CORES["erro"], font=FONTES["pequena"], anchor="w",
    )


def indicador_progresso(parent, passo_atual, total=3):
    """Cria um indicador de progresso composto por pequenas barras (uma por
    passo, destacadas em verde até o passo atual) e o texto 'Passo X de 3'."""
    container = tk.Frame(parent, bg=parent["bg"])

    barra = tk.Frame(container, bg=parent["bg"])
    barra.pack(anchor="w")
    for indice in range(1, total + 1):
        cor = CORES["verde_principal"] if indice <= passo_atual else CORES["borda"]
        tk.Frame(barra, bg=cor, width=32, height=5).pack(side="left", padx=(0, 5))

    tk.Label(
        container, text=f"Passo {passo_atual} de {total}",
        bg=parent["bg"], fg=CORES["texto_secundario"], font=FONTES["pequena"],
    ).pack(anchor="w", pady=(5, 0))

    return container
