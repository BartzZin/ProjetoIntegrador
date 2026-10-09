from io import BytesIO
import wave

from fastapi.testclient import TestClient

from app.principal import app


cliente = TestClient(app)


def criar_wav(duracao_segundos: int = 2, taxa: int = 8000) -> bytes:
    conteudo = BytesIO()
    with wave.open(conteudo, "wb") as audio:
        audio.setnchannels(1)
        audio.setsampwidth(2)
        audio.setframerate(taxa)
        audio.writeframes(b"\x00\x00" * taxa * duracao_segundos)
    return conteudo.getvalue()


def campos_validos() -> dict[str, str]:
    return {
        "id_modelo_veiculo": "1",
        "marca": "Chevrolet",
        "modelo": "Corsa",
        "ano": "2002",
        "codigo_motor": "1.0",
    }


def test_saude_indica_modelo_ainda_nao_treinado() -> None:
    resposta = cliente.get("/api/v1/saude")
    assert resposta.status_code == 200
    assert resposta.json() == {
        "situacao": "ok",
        "modelo_carregado": False,
        "versao_modelo": "baseline-nao-treinado",
    }


def test_upload_wav_valido_sem_inventar_classificacao() -> None:
    resposta = cliente.post(
        "/api/v1/analises/audio",
        data=campos_validos(),
        files={"arquivo_audio": ("motor.wav", criar_wav(), "audio/wav")},
    )
    corpo = resposta.json()
    assert resposta.status_code == 200
    assert corpo["situacao"] == "sucesso_sem_classificacao"
    assert corpo["duracao_segundos"] == 2.0
    assert corpo["resultados"] == []


def test_rejeita_arquivo_vazio() -> None:
    resposta = cliente.post(
        "/api/v1/analises/audio",
        data=campos_validos(),
        files={"arquivo_audio": ("motor.wav", b"", "audio/wav")},
    )
    assert resposta.status_code == 422
    assert resposta.json()["detail"] == "Arquivo de audio vazio."


def test_rejeita_extensao_desconhecida() -> None:
    resposta = cliente.post(
        "/api/v1/analises/audio",
        data=campos_validos(),
        files={"arquivo_audio": ("motor.txt", b"nao e audio", "text/plain")},
    )
    assert resposta.status_code == 415
