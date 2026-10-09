from io import BytesIO
import math
from pathlib import Path
import struct
import wave

import numpy as np
import pytest


librosa = pytest.importorskip("librosa")

from app.servicos.servico_caracteristicas_audio import (  # noqa: E402
    construir_registro_modelo,
    extrair_caracteristicas_audio,
)
from treinamento.treinar_modelo import carregar_manifesto  # noqa: E402


def _criar_tom(caminho: Path, frequencia: float = 220.0) -> None:
    taxa = 22_050
    conteudo = BytesIO()
    with wave.open(conteudo, "wb") as audio:
        audio.setnchannels(1)
        audio.setsampwidth(2)
        audio.setframerate(taxa)
        quadros = [
            struct.pack(
                "<h", int(math.sin(2 * math.pi * frequencia * n / taxa) * 16_000)
            )
            for n in range(taxa * 2)
        ]
        audio.writeframes(b"".join(quadros))
    caminho.write_bytes(conteudo.getvalue())


def test_extracao_audio_e_contexto_mecanico(tmp_path: Path) -> None:
    caminho = tmp_path / "motor.wav"
    _criar_tom(caminho)
    caracteristicas = extrair_caracteristicas_audio(caminho)
    assert len(caracteristicas) > 100
    assert all(np.isfinite(valor) for valor in caracteristicas.values())

    registro = construir_registro_modelo(
        caminho,
        {
            "familia_motor": "FIAT_FIRE_1.0_1.4",
            "cilindrada_cc": 1000,
            "combustivel": "FLEX",
        },
    )
    assert registro["familia_motor"] == "FIAT_FIRE_1.0_1.4"
    assert registro["cilindrada_cc"] == 1000
    assert registro["codigo_motor"] is None


def test_rejeita_audio_com_menos_de_um_segundo(tmp_path: Path) -> None:
    caminho = tmp_path / "curto.wav"
    taxa = 22_050
    with wave.open(str(caminho), "wb") as audio:
        audio.setnchannels(1)
        audio.setsampwidth(2)
        audio.setframerate(taxa)
        audio.writeframes(b"\x00\x00" * (taxa // 2))
    with pytest.raises(ValueError, match="ao menos um segundo"):
        extrair_caracteristicas_audio(caminho)


def test_manifesto_exige_proveniencia_e_licenca(tmp_path: Path) -> None:
    manifesto = tmp_path / "manifesto.csv"
    manifesto.write_text(
        "arquivo,rotulo,grupo_gravacao,fonte,licenca,nivel_confirmacao\n"
        "motor.wav,NORMAL,carro_1,COLETA_PROPRIA,,3\n",
        encoding="utf-8",
    )
    with pytest.raises(ValueError, match="fonte e licenca"):
        carregar_manifesto(manifesto, nivel_minimo=2)
