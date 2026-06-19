"""Constantes visuais do sistema SOS Abobrinha.

Centraliza cores, fontes e dimensões usadas em todas as telas, evitando
valores espalhados pelo código das views.
"""

CORES = {
    "verde_principal":  "#1D9E75",
    "verde_claro":      "#EAF3DE",
    "verde_escuro":     "#3B6D11",
    "fundo":            "#F5F5F5",
    "branco":           "#FFFFFF",
    "texto_principal":  "#1A1A1A",
    "texto_secundario": "#6B6B6B",
    "erro":             "#E24B4A",
    "borda":            "#E0E0E0",
    "badge_humano_bg":  "#E6F1FB",
    "badge_humano_fg":  "#185FA5",
    "badge_animal_bg":  "#FAEEDA",
    "badge_animal_fg":  "#854F0B",
    "composto_bg":      "#EAF3DE",
    "composto_fg":      "#3B6D11",
}

FONTES = {
    "titulo":    ("Helvetica", 16, "bold"),
    "subtitulo": ("Helvetica", 11),
    "label":     ("Helvetica", 13),
    "corpo":     ("Helvetica", 11),
    "pequena":   ("Helvetica", 10),
}

JANELA = {
    "largura":  640,
    "altura":   580,
    "titulo":   "SOS Abobrinha",
}

ESPACAMENTO = {
    "lateral": 28,
    "topo": 24,
}
