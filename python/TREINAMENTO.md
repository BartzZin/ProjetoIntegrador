# Treinamento do modelo acústico

O pipeline implementado usa MFCC, delta-MFCC, contraste espectral, chroma, centroide,
largura de banda, roll-off, cruzamentos por zero, RMS e planicidade. Essas medidas são
combinadas com o contexto mecânico disponível no Delphi. O classificador inicial é um
Random Forest com validação `StratifiedGroupKFold`.

O grupo de gravação é obrigatório: segmentos do mesmo áudio ou do mesmo ensaio nunca
podem aparecer simultaneamente no treino e no teste.

## 1. Instalar as dependências de ML

Na raiz do projeto:

```powershell
python\.venv\Scripts\python.exe -m pip install -r python\requirements-ml.txt
```

## 2. Organizar os áudios

Use WAV sempre que possível. A estrutura esperada é:

```text
audios/dataset_local/
  NORMAL/
  FALHA_IGNICAO_MARCHA_IRREGULAR/
  CORREIA_POLIA_ROLAMENTO/
  RUIDO_METALICO_MOTOR/
  ANOMALIA_NAO_ESPECIFICADA/
```

`ANOMALIA_NAO_ESPECIFICADA` serve para o experimento binário com bases que apenas
distinguem normal e defeituoso. Não converta um rótulo genérico em defeito específico.

## 3. Criar e revisar o manifesto

```powershell
python\.venv\Scripts\python.exe python\treinamento\preparar_dataset.py
```

O comando cria `audios/dataset_local/manifesto.csv`. Antes de treinar, preencha:

- `grupo_gravacao`: identificador do áudio/ensaio original;
- `veiculo_id`, `codigo_motor` e `familia_motor`;
- condição, RPM e posição do celular;
- `fonte` e `licenca`;
- `nivel_confirmacao` de 0 a 4.

Escala recomendada de confirmação:

- 0: rótulo desconhecido;
- 1: rótulo inferido da pasta ou descrição da internet;
- 2: falha reproduzida/controlada ou documentação técnica consistente;
- 3: diagnóstico confirmado por mecânico;
- 4: defeito confirmado antes do reparo e desaparecimento do som após o reparo.

O treino normal usa somente níveis 2 a 4. Para experimentar uma base pública com
rótulos menos fortes, reduza explicitamente `--nivel-minimo`, mas registre isso no
relatório.

## 4. Treinar

Cada classe precisa ter pelo menos dois grupos independentes. Execute:

```powershell
python\.venv\Scripts\python.exe python\treinamento\treinar_modelo.py `
  --manifesto audios\dataset_local\manifesto.csv `
  --versao 0.1.0-br
```

São gerados:

```text
python/modelos_treinados/modelo_audio.joblib
python/modelos_treinados/metadados_modelo.json
```

Ao reiniciar a API, `/api/v1/saude` passa a informar o modelo carregado e a análise
retorna probabilidades reais do `predict_proba`.

### Reproduzir o modelo de demonstração AI Mechanic

Com o arquivo `ai-mechanic.zip` em `audios/fontes_publicas/ai_mechanic`:

```powershell
python\.venv\Scripts\python.exe python\treinamento\importar_ai_mechanic.py
python\.venv\Scripts\python.exe python\treinamento\treinar_modelo.py `
  --manifesto audios\dataset_local\ai_mechanic\manifesto.csv `
  --saida python\modelos_treinados `
  --versao 0.1.0-ai-mechanic-bmw `
  --nivel-minimo 2 `
  --escopo "NORMAL x ANOMALIA em um BMW M54B25 2004; demonstracao academica, nao generaliza para motores brasileiros."
```

O importador remove segmentos duplicados pelo SHA-256 antes do treino. A execução
atual gerou 121 segmentos, 15 grupos e cinco dobras. Resultados: acurácia 0,785,
acurácia balanceada 0,611 e F1 macro 0,625. O recall de `NORMAL` foi apenas 0,296;
por isso a demonstração deve ser descrita como prova de conceito, não como validação
clínica ou mecânica.

## 5. Estratégia para motores brasileiros

Não comece treinando um classificador separado para cada modelo de carro. Primeiro:

1. valide `NORMAL` × `ANOMALIA_NAO_ESPECIFICADA` com bases públicas licenciadas;
2. colete localmente as quatro classes do MVP em FIRE, EA111 e Família I/SPE4;
3. adicione EA211 e Firefly para cobrir a frota recente;
4. meça desempenho deixando veículos físicos inteiros fora do treino;
5. só publique métrica por família quando houver amostras independentes suficientes.

Meta experimental mínima por classe: 30 gravações originais, de pelo menos 10 veículos
físicos e três famílias de motor. Para afirmar desempenho de uma família específica,
busque pelo menos 20 grupos independentes por classe nessa família. Janelas de um mesmo
arquivo aumentam o número de exemplos, mas não aumentam o número de grupos.

O catálogo [motores_brasil_prioritarios.json](dados/motores_brasil_prioritarios.json)
é uma fila de coleta, não uma tabela definitiva de aplicação de motores. Confirme a
motorização de cada automóvel no momento da gravação.

## 6. Bases públicas

O catálogo [fontes_publicas.json](dados/fontes_publicas.json) registra cobertura,
licença e uso recomendado. Em resumo:

- **AI Mechanic (Apache 2.0):** útil para validar normal × anômalo, mas contém apenas
  um BMW M54B25;
- **DCASE 2024 Task 10:** bom para ruído de domínio e sons normais de tráfego, não para
  rótulos de defeito;
- **OtoMobile:** relevante, pequeno e com acesso restrito para educação/pesquisa;
- **VAFD:** promissor, mas confirme a licença antes de copiar os áudios;
- **Car Diagnostics Dataset:** não usar no modelo enquanto a licença permanecer
  desconhecida.
- **NHTSA:** integrada apenas como contexto de reclamações e recalls americanos por
  marca/modelo/ano; os números não são prevalência de falha no Brasil;
- **MIMII/ToyADMOS2:** benchmarks grandes de anomalias em máquinas industriais ou de
  brinquedo. São úteis para estudar robustez e mudança de domínio, mas não devem ser
  misturados ao treino como se fossem motores automotivos reais;
- **Automotive Faults Dataset:** útil para sintomas e lógica de diagnóstico, mas o
  registro consultado não declara licença. Não foi incorporado ao aplicativo.

Nunca baixe vídeos e atribua um defeito apenas pelo título. Para defeitos reais, a
melhor fonte é parceria com oficinas: gravar antes do reparo, registrar o diagnóstico e
repetir a gravação após o reparo.
