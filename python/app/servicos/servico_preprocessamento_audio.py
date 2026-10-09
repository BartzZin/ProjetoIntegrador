from dataclasses import dataclass
from pathlib import Path
import shutil
import uuid
import wave

from fastapi import HTTPException, UploadFile

from app.infraestrutura.configuracao import Configuracao
from app.infraestrutura.ffmpeg import converter_para_wav


EXTENSOES_ACEITAS = {".wav", ".mp3", ".ogg", ".opus", ".m4a"}


@dataclass(frozen=True)
class AudioProcessado:
    caminho_original: Path
    caminho_wav: Path
    duracao_segundos: float
    indice_qualidade: float
    classificacao_qualidade: str


class ServicoPreprocessamentoAudio:
    async def processar(self, arquivo: UploadFile) -> AudioProcessado:
        extensao = Path(arquivo.filename or "").suffix.lower()
        if extensao not in EXTENSOES_ACEITAS:
            raise HTTPException(status_code=415, detail="Formato de audio nao suportado.")

        configuracao = Configuracao()
        diretorio = configuracao.diretorio_audios_analisados
        diretorio.mkdir(parents=True, exist_ok=True)
        identificador = uuid.uuid4().hex
        caminho_original = diretorio / f"{identificador}{extensao}"

        tamanho = 0
        with caminho_original.open("wb") as destino:
            while bloco := await arquivo.read(1024 * 1024):
                tamanho += len(bloco)
                if tamanho > configuracao.limite_upload_mb * 1024 * 1024:
                    destino.close()
                    caminho_original.unlink(missing_ok=True)
                    raise HTTPException(status_code=413, detail="Arquivo excede o limite permitido.")
                destino.write(bloco)

        if tamanho == 0:
            caminho_original.unlink(missing_ok=True)
            raise HTTPException(status_code=422, detail="Arquivo de audio vazio.")

        caminho_wav = diretorio / f"{identificador}.padronizado.wav"
        try:
            if extensao == ".wav":
                shutil.copy2(caminho_original, caminho_wav)
            else:
                converter_para_wav(caminho_original, caminho_wav)
            duracao = self._obter_duracao_wav(caminho_wav)
        except (RuntimeError, OSError, wave.Error) as erro:
            caminho_wav.unlink(missing_ok=True)
            raise HTTPException(status_code=422, detail=str(erro)) from erro

        if duracao < 1:
            caminho_wav.unlink(missing_ok=True)
            raise HTTPException(status_code=422, detail="Audio muito curto; minimo de 1 segundo.")

        indice = min(1.0, duracao / 15.0)
        classificacao = "boa" if indice >= 0.8 else "aceitavel" if indice >= 0.4 else "baixa"
        return AudioProcessado(caminho_original, caminho_wav, duracao, indice, classificacao)

    @staticmethod
    def _obter_duracao_wav(caminho: Path) -> float:
        with wave.open(str(caminho), "rb") as audio:
            taxa = audio.getframerate()
            if taxa <= 0:
                raise wave.Error("Taxa de amostragem invalida.")
            return audio.getnframes() / taxa
