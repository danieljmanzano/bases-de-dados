"""Tela 1.2 do fluxo de cadastro — detalhes do lote (quantidade e datas)."""

from datetime import datetime
import tkinter as tk

from config import CORES, FONTES, ESPACAMENTO
from components.widgets import botao_voltar, botao_primario, entry_padrao, indicador_progresso, label_erro

PLACEHOLDER_DATA = "dd/mm/aaaa"


class Passo2Frame(tk.Frame):
    """Segundo passo do cadastro de lote: quantidade, data de colheita,
    validade e localização atual, com validação completa antes de avançar."""

    def __init__(self, parent, app):
        super().__init__(parent, bg=CORES["fundo"])
        self.app = app

        topo = tk.Frame(self, bg=CORES["fundo"])
        botao_voltar(topo, lambda: self.app.show_frame("passo1")).pack(anchor="w")

        corpo = tk.Frame(self, bg=CORES["fundo"])

        indicador_progresso(corpo, 2).pack(anchor="w")
        tk.Label(
            corpo, text="Detalhes do lote", bg=CORES["fundo"],
            fg=CORES["texto_principal"], font=FONTES["titulo"],
        ).pack(anchor="w", pady=(2, 20))

        self.var_quantidade, self.entry_quantidade = self._criar_campo(
            corpo, "Quantidade (kg)"
        )
        self.label_erro_quantidade = label_erro(corpo)
        self.label_erro_quantidade.pack(fill="x", pady=(0, 8))

        self.var_colheita, self.entry_colheita = self._criar_campo(
            corpo, "Data de colheita", placeholder=PLACEHOLDER_DATA
        )
        self.label_erro_colheita = label_erro(corpo)
        self.label_erro_colheita.pack(fill="x", pady=(0, 8))

        self.var_validade, self.entry_validade = self._criar_campo(
            corpo, "Validade", placeholder=PLACEHOLDER_DATA
        )
        self.label_erro_validade = label_erro(corpo)
        self.label_erro_validade.pack(fill="x", pady=(0, 8))

        self.var_localizacao, self.entry_localizacao = self._criar_campo(
            corpo, "Localização atual"
        )
        self.label_erro_localizacao = label_erro(corpo)
        self.label_erro_localizacao.pack(fill="x", pady=(0, 8))

        rodape = tk.Frame(self, bg=CORES["fundo"])
        botao_primario(rodape, "Continuar", self._continuar).pack(fill="x")

        lateral = ESPACAMENTO["lateral"]
        topo.pack(fill="x", padx=lateral, pady=(ESPACAMENTO["topo"], 0))
        corpo.pack(fill="x", padx=lateral, pady=10)
        rodape.pack(fill="x", padx=lateral, pady=(0, 20), side="bottom")

    def _criar_campo(self, parent, rotulo, placeholder=None):
        """Cria um label + Entry padronizado, com suporte opcional a placeholder."""
        tk.Label(
            parent, text=rotulo, bg=CORES["fundo"],
            fg=CORES["texto_principal"], font=FONTES["label"],
        ).pack(anchor="w")

        var = tk.StringVar()
        entry = entry_padrao(parent, var)
        entry.pack(fill="x", pady=(4, 2), ipady=6)

        if placeholder:
            var.set(placeholder)
            entry.config(fg=CORES["texto_secundario"])
            entry.bind("<FocusIn>", lambda e: self._limpar_placeholder(entry, var, placeholder))
            entry.bind("<FocusOut>", lambda e: self._restaurar_placeholder(entry, var, placeholder))

        return var, entry

    @staticmethod
    def _limpar_placeholder(entry, var, placeholder):
        if var.get() == placeholder:
            var.set("")
            entry.config(fg=CORES["texto_principal"])

    @staticmethod
    def _restaurar_placeholder(entry, var, placeholder):
        if not var.get():
            var.set(placeholder)
            entry.config(fg=CORES["texto_secundario"])

    @staticmethod
    def _valor_real(var, placeholder=None):
        """Retorna o valor digitado, tratando o placeholder como campo vazio."""
        valor = var.get().strip()
        if placeholder and valor == placeholder:
            return ""
        return valor

    def on_show(self):
        """Limpa todos os campos e mensagens de erro ao entrar nesta tela."""
        self.var_quantidade.set("")
        self._restaurar_placeholder(self.entry_colheita, self.var_colheita, PLACEHOLDER_DATA)
        self._restaurar_placeholder(self.entry_validade, self.var_validade, PLACEHOLDER_DATA)
        self.var_localizacao.set("")
        for label in (
            self.label_erro_quantidade, self.label_erro_colheita,
            self.label_erro_validade, self.label_erro_localizacao,
        ):
            label.config(text="")

    def _continuar(self):
        """Executa as validações dos campos, na ordem especificada, e avança
        para o passo 3 somente se todos forem válidos."""
        for label in (
            self.label_erro_quantidade, self.label_erro_colheita,
            self.label_erro_validade, self.label_erro_localizacao,
        ):
            label.config(text="")

        quantidade_texto = self._valor_real(self.var_quantidade)
        try:
            quantidade = float(quantidade_texto)
            if quantidade <= 0:
                raise ValueError
        except ValueError:
            self.label_erro_quantidade.config(text="Informe uma quantidade válida maior que zero.")
            return

        colheita_texto = self._valor_real(self.var_colheita, PLACEHOLDER_DATA)
        try:
            data_colheita = datetime.strptime(colheita_texto, "%d/%m/%Y")
        except ValueError:
            self.label_erro_colheita.config(text="Data inválida. Use o formato dd/mm/aaaa.")
            return

        validade_texto = self._valor_real(self.var_validade, PLACEHOLDER_DATA)
        try:
            data_validade = datetime.strptime(validade_texto, "%d/%m/%Y")
        except ValueError:
            self.label_erro_validade.config(text="Data inválida. Use o formato dd/mm/aaaa.")
            return

        if data_validade <= data_colheita:
            self.label_erro_validade.config(text="A validade deve ser posterior à data de colheita.")
            return

        localizacao = self._valor_real(self.var_localizacao)
        if not localizacao:
            self.label_erro_localizacao.config(text="Informe a localização atual.")
            return

        self.app.session["quantidade"] = quantidade
        self.app.session["data_colheita"] = colheita_texto
        self.app.session["validade"] = validade_texto
        self.app.session["localizacao"] = localizacao
        self.app.show_frame("passo3")
