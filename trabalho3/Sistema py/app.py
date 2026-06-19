"""Janela principal da aplicação e gerenciamento de navegação entre telas."""

import tkinter as tk

from config import CORES, JANELA
from views.menu import MenuFrame
from views.consulta import ConsultaFrame
from views.cadastro.passo1 import Passo1Frame
from views.cadastro.passo2 import Passo2Frame
from views.cadastro.passo3 import Passo3Frame
from views.cadastro.sucesso import SucessoFrame


class App(tk.Tk):
    """Janela principal: registra todas as telas e controla qual está visível.

    Mantém também o dicionário `session`, usado para compartilhar os dados
    preenchidos entre os passos do fluxo de cadastro de lote.
    """

    def __init__(self):
        super().__init__()
        self.title(JANELA["titulo"])
        self.geometry(f"{JANELA['largura']}x{JANELA['altura']}")
        self.configure(bg=CORES["fundo"])

        self.session = {}

        faixa_superior = tk.Frame(self, bg=CORES["verde_principal"], height=4)
        faixa_superior.pack(fill="x", side="top")

        container = tk.Frame(self, bg=CORES["fundo"])
        container.pack(fill="both", expand=True)

        self.frames = {}
        classes_por_nome = {
            "menu": MenuFrame,
            "consulta": ConsultaFrame,
            "passo1": Passo1Frame,
            "passo2": Passo2Frame,
            "passo3": Passo3Frame,
            "sucesso": SucessoFrame,
        }

        for nome, classe_frame in classes_por_nome.items():
            frame = classe_frame(container, self)
            self.frames[nome] = frame
            frame.place(x=0, y=0, relwidth=1, relheight=1)

        self.show_frame("menu")

    def show_frame(self, nome):
        """Exibe a tela `nome`, trazendo-a para frente e chamando seu método
        on_show(), se existir, para que ela possa se atualizar antes de aparecer."""
        frame = self.frames[nome]
        if hasattr(frame, "on_show"):
            frame.on_show()
        frame.tkraise()

    def limpar_session(self):
        """Reseta os dados temporários compartilhados entre as telas de cadastro.

        Usa clear() em vez de reatribuir um novo dict para preservar a
        referência que as views guardam em self.app.session.
        """
        self.session.clear()
