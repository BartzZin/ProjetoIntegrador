import shutil
import subprocess
from pathlib import Path

from app.infraestrutura.configuracao import Configuracao


def ffmpeg_disponivel() -> bool:
    return shutil.which(Configuracao().executavel_ffmpeg) is not None


def converter_para_wav(origem: Path, destino: Path) -> None:
    configuracao = Configuracao()
    if not ffmpeg_disponivel():
        raise RuntimeError(
            "FFmpeg nao encontrado. Instale-o ou configure AUTOSOM_FFMPEG."
        )
    subprocess.run(
        [
            configuracao.executavel_ffmpeg,
            "-y",
            "-i",
            str(origem),
            "-ac",
            "1",
            "-ar",
            "44100",
            "-c:a",
            "pcm_s16le",
            str(destino),
        ],
        check=True,
        capture_output=True,
        timeout=120,
    )
