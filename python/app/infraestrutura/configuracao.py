from dataclasses import dataclass
from pathlib import Path
import os


@dataclass(frozen=True)
class Configuracao:
    raiz_projeto: Path = Path(__file__).resolve().parents[3]
    limite_upload_mb: int = int(os.getenv("AUTOSOM_LIMITE_UPLOAD_MB", "30"))
    executavel_ffmpeg: str = os.getenv("AUTOSOM_FFMPEG", "ffmpeg")

    @property
    def diretorio_audios_analisados(self) -> Path:
        return self.raiz_projeto / "audios" / "analisados"

    @property
    def diretorio_modelos(self) -> Path:
        return self.raiz_projeto / "python" / "modelos_treinados"

    @property
    def diretorio_dataset_local(self) -> Path:
        return self.raiz_projeto / "audios" / "dataset_local"

    @property
    def caminho_banco(self) -> Path:
        return self.raiz_projeto / "dados" / "diagnostico_automotivo.db"
