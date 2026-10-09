from __future__ import annotations

import argparse
import csv
import re
from pathlib import Path


ROTULOS_SUPORTADOS = {
    "NORMAL",
    "FALHA_IGNICAO_MARCHA_IRREGULAR",
    "CORREIA_POLIA_ROLAMENTO",
    "RUIDO_METALICO_MOTOR",
    "ANOMALIA_NAO_ESPECIFICADA",
}
EXTENSOES_AUDIO = {".wav", ".flac", ".ogg", ".mp3", ".m4a", ".opus"}
COLUNAS = [
    "arquivo",
    "rotulo",
    "grupo_gravacao",
    "veiculo_id",
    "marca",
    "modelo",
    "ano",
    "codigo_motor",
    "familia_motor",
    "cilindrada_cc",
    "cilindros",
    "combustivel",
    "aspiracao",
    "valvulas",
    "tipo_injecao",
    "condicao_motor",
    "rpm_aproximado",
    "posicao_gravacao",
    "fonte",
    "licenca",
    "nivel_confirmacao",
    "observacao",
]


def _grupo_sugerido(caminho: Path) -> str:
    base = re.sub(
        r"(?i)(?:[_-](?:seg|segmento|janela|window|chunk)[_-]?\d+)$", "", caminho.stem
    )
    return f"{caminho.parent.name}:{base}"


def criar_manifesto(diretorio: Path, destino: Path, sobrescrever: bool) -> int:
    if destino.exists() and not sobrescrever:
        raise FileExistsError(
            f"O manifesto ja existe: {destino}. Use --sobrescrever para substitui-lo."
        )

    linhas: list[dict[str, str]] = []
    for pasta_rotulo in sorted(diretorio.iterdir() if diretorio.exists() else []):
        if not pasta_rotulo.is_dir():
            continue
        rotulo = pasta_rotulo.name.upper()
        if rotulo not in ROTULOS_SUPORTADOS:
            continue
        for caminho in sorted(pasta_rotulo.rglob("*")):
            if not caminho.is_file() or caminho.suffix.lower() not in EXTENSOES_AUDIO:
                continue
            linhas.append(
                {
                    "arquivo": caminho.relative_to(destino.parent).as_posix(),
                    "rotulo": rotulo,
                    "grupo_gravacao": _grupo_sugerido(caminho),
                    "nivel_confirmacao": "0",
                }
            )

    destino.parent.mkdir(parents=True, exist_ok=True)
    with destino.open("w", encoding="utf-8-sig", newline="") as arquivo:
        escritor = csv.DictWriter(arquivo, fieldnames=COLUNAS)
        escritor.writeheader()
        for linha in linhas:
            escritor.writerow(linha)
    return len(linhas)


def main() -> None:
    raiz = Path(__file__).resolve().parents[2]
    padrao_dataset = raiz / "audios" / "dataset_local"
    parser = argparse.ArgumentParser(
        description="Cria o manifesto CSV a partir das pastas de classes de audio."
    )
    parser.add_argument("--dataset", type=Path, default=padrao_dataset)
    parser.add_argument("--saida", type=Path, default=padrao_dataset / "manifesto.csv")
    parser.add_argument("--sobrescrever", action="store_true")
    argumentos = parser.parse_args()
    quantidade = criar_manifesto(
        argumentos.dataset.resolve(), argumentos.saida.resolve(), argumentos.sobrescrever
    )
    print(f"Manifesto criado em {argumentos.saida.resolve()} com {quantidade} amostras.")
    print("Revise grupo_gravacao, motor, fonte, licenca e nivel_confirmacao antes do treino.")


if __name__ == "__main__":
    main()
