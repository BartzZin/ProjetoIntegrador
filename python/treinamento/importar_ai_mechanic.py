from __future__ import annotations

import argparse
import csv
import hashlib
from io import BytesIO
from pathlib import Path
import re
import sys
import wave
import zipfile


RAIZ_PYTHON = Path(__file__).resolve().parents[1]
if str(RAIZ_PYTHON) not in sys.path:
    sys.path.insert(0, str(RAIZ_PYTHON))

from treinamento.preparar_dataset import COLUNAS


FONTE = "https://www.kaggle.com/datasets/eoinedge/ai-mechanic-engine-condition-audio-fault-finding"
LICENCA = "Apache-2.0"


def _rotulo(nome: str) -> str | None:
    normalizado = nome.lower()
    if normalizado.startswith(("idling.", "normal engine inside cabin.")):
        return "NORMAL"
    if normalizado.startswith(
        ("air leak.", "air leak engine inside cabin.", "oil cap off engine inside cabin.")
    ):
        return "ANOMALIA_NAO_ESPECIFICADA"
    return None


def _nome_seguro(nome: str) -> str:
    return re.sub(r"[^a-zA-Z0-9._-]+", "_", nome).strip("_")


def _segmentar_wav(conteudo: bytes, duracao_segmento: float) -> list[bytes]:
    segmentos: list[bytes] = []
    with wave.open(BytesIO(conteudo), "rb") as origem:
        parametros = origem.getparams()
        quadros_segmento = max(1, int(parametros.framerate * duracao_segmento))
        minimo_quadros = max(1, parametros.framerate)
        while dados := origem.readframes(quadros_segmento):
            tamanho_quadro = parametros.sampwidth * parametros.nchannels
            quantidade_quadros = len(dados) // tamanho_quadro
            if quantidade_quadros < minimo_quadros:
                break
            destino = BytesIO()
            with wave.open(destino, "wb") as audio:
                audio.setparams(parametros)
                audio.writeframes(dados)
            segmentos.append(destino.getvalue())
    return segmentos


def importar(arquivo_zip: Path, destino: Path, duracao_segmento: float) -> int:
    destino.mkdir(parents=True, exist_ok=True)
    linhas: list[dict[str, str]] = []
    hashes_segmentos: set[str] = set()
    with zipfile.ZipFile(arquivo_zip) as pacote:
        entradas = [
            entrada
            for entrada in pacote.infolist()
            if "/training/" in entrada.filename and entrada.filename.lower().endswith(".wav")
        ]
        for entrada in sorted(entradas, key=lambda item: item.filename):
            nome_original = Path(entrada.filename).name
            rotulo = _rotulo(nome_original)
            if rotulo is None:
                continue
            grupo = f"ai_mechanic:{Path(nome_original).stem}"
            segmentos = _segmentar_wav(pacote.read(entrada), duracao_segmento)
            pasta_classe = destino / rotulo
            pasta_classe.mkdir(parents=True, exist_ok=True)
            for indice, conteudo in enumerate(segmentos):
                digest = hashlib.sha256(conteudo).hexdigest()
                if digest in hashes_segmentos:
                    continue
                hashes_segmentos.add(digest)
                nome_saida = f"{_nome_seguro(Path(nome_original).stem)}_seg{indice:03d}.wav"
                caminho_saida = pasta_classe / nome_saida
                caminho_saida.write_bytes(conteudo)
                linhas.append(
                    {
                        "arquivo": caminho_saida.relative_to(destino).as_posix(),
                        "rotulo": rotulo,
                        "grupo_gravacao": grupo,
                        "veiculo_id": "ai_mechanic_bmw_2004",
                        "marca": "BMW",
                        "modelo": "veiculo_doador_nao_informado",
                        "ano": "2004",
                        "codigo_motor": "M54B25",
                        "familia_motor": "BMW_M54",
                        "cilindrada_cc": "2494",
                        "cilindros": "6",
                        "combustivel": "GASOLINA",
                        "aspiracao": "ASPIRADO",
                        "valvulas": "24",
                        "tipo_injecao": "ELETRONICA",
                        "condicao_motor": "MARCHA_LENTA",
                        "rpm_aproximado": "",
                        "posicao_gravacao": (
                            "INTERIOR_CABINE"
                            if "inside cabin" in nome_original.lower()
                            else "NAO_INFORMADA"
                        ),
                        "fonte": FONTE,
                        "licenca": LICENCA,
                        "nivel_confirmacao": "2",
                        "observacao": (
                            "Falha simulada conforme documentacao do dataset; "
                            "nao converter em diagnostico de componente especifico."
                        ),
                    }
                )

    manifesto = destino / "manifesto.csv"
    with manifesto.open("w", encoding="utf-8-sig", newline="") as arquivo:
        escritor = csv.DictWriter(arquivo, fieldnames=COLUNAS)
        escritor.writeheader()
        escritor.writerows(linhas)
    return len(linhas)


def main() -> None:
    raiz = Path(__file__).resolve().parents[2]
    parser = argparse.ArgumentParser(
        description="Importa o AI Mechanic mantendo origem, licenca e grupos."
    )
    parser.add_argument(
        "--zip",
        type=Path,
        default=raiz
        / "audios"
        / "fontes_publicas"
        / "ai_mechanic"
        / "ai-mechanic.zip",
    )
    parser.add_argument(
        "--saida",
        type=Path,
        default=raiz / "audios" / "dataset_local" / "ai_mechanic",
    )
    parser.add_argument("--segmento-segundos", type=float, default=5.0)
    argumentos = parser.parse_args()
    quantidade = importar(
        argumentos.zip.resolve(),
        argumentos.saida.resolve(),
        argumentos.segmento_segundos,
    )
    print(f"Importacao concluida: {quantidade} segmentos.")
    print(f"Manifesto: {(argumentos.saida.resolve() / 'manifesto.csv')}")


if __name__ == "__main__":
    main()
