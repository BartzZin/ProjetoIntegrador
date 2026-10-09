"""Ponto de entrada da API para execução e depuração no PyCharm."""

import os

import uvicorn


if __name__ == "__main__":
    uvicorn.run(
        "app.principal:app",
        host=os.getenv("AUTOSOM_HOST", "127.0.0.1"),
        port=int(os.getenv("AUTOSOM_PORTA", "8000")),
        reload=False,
    )
