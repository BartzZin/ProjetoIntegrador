from __future__ import annotations

from pathlib import Path
from typing import Any, Mapping

import librosa
import numpy as np


TAXA_AMOSTRAGEM = 22_050
DURACAO_MAXIMA_SEGUNDOS = 30.0
N_MFCC = 20


def _resumir_matriz(
    destino: dict[str, float], prefixo: str, valores: np.ndarray
) -> None:
    matriz = np.atleast_2d(valores)
    for indice, linha in enumerate(matriz):
        destino[f"{prefixo}_{indice:02d}_media"] = float(np.mean(linha))
        destino[f"{prefixo}_{indice:02d}_desvio"] = float(np.std(linha))


def extrair_caracteristicas_audio(caminho_audio: Path) -> dict[str, float]:
    """Extrai um vetor fixo e reproduzível de características acústicas."""
    sinal, taxa = librosa.load(
        caminho_audio,
        sr=TAXA_AMOSTRAGEM,
        mono=True,
        duration=DURACAO_MAXIMA_SEGUNDOS,
    )
    if sinal.size < TAXA_AMOSTRAGEM:
        raise ValueError("A amostra precisa conter ao menos um segundo de audio.")
    if not np.isfinite(sinal).all():
        raise ValueError("A amostra contem valores de audio invalidos.")

    sinal_sem_silencio, _ = librosa.effects.trim(sinal, top_db=35)
    if sinal_sem_silencio.size >= TAXA_AMOSTRAGEM:
        sinal = sinal_sem_silencio
    sinal = librosa.util.normalize(sinal)

    caracteristicas: dict[str, float] = {
        "duracao_segundos": float(sinal.size / taxa),
    }
    mfcc = librosa.feature.mfcc(y=sinal, sr=taxa, n_mfcc=N_MFCC)
    _resumir_matriz(caracteristicas, "mfcc", mfcc)
    _resumir_matriz(caracteristicas, "delta_mfcc", librosa.feature.delta(mfcc))
    _resumir_matriz(
        caracteristicas,
        "contraste",
        librosa.feature.spectral_contrast(y=sinal, sr=taxa),
    )
    _resumir_matriz(
        caracteristicas, "chroma", librosa.feature.chroma_stft(y=sinal, sr=taxa)
    )
    _resumir_matriz(
        caracteristicas,
        "centroide",
        librosa.feature.spectral_centroid(y=sinal, sr=taxa),
    )
    _resumir_matriz(
        caracteristicas,
        "largura_banda",
        librosa.feature.spectral_bandwidth(y=sinal, sr=taxa),
    )
    _resumir_matriz(
        caracteristicas,
        "rolloff",
        librosa.feature.spectral_rolloff(y=sinal, sr=taxa, roll_percent=0.85),
    )
    _resumir_matriz(
        caracteristicas, "cruzamentos_zero", librosa.feature.zero_crossing_rate(sinal)
    )
    _resumir_matriz(caracteristicas, "rms", librosa.feature.rms(y=sinal))
    _resumir_matriz(
        caracteristicas, "planicidade", librosa.feature.spectral_flatness(y=sinal)
    )
    return caracteristicas


def construir_registro_modelo(
    caminho_audio: Path, contexto_mecanico: Mapping[str, Any]
) -> dict[str, Any]:
    registro: dict[str, Any] = extrair_caracteristicas_audio(caminho_audio)
    for campo in (
        "codigo_motor",
        "familia_motor",
        "cilindrada_cc",
        "cilindros",
        "combustivel",
        "aspiracao",
        "valvulas",
        "tipo_injecao",
    ):
        registro[campo] = contexto_mecanico.get(campo)
    return registro
