# AutoSom Diagnóstico

## Sobre o projeto

O AutoSom Diagnóstico é o projeto que desenvolvi para demonstrar, de forma prática,
como a análise de áudio e o aprendizado de máquina podem auxiliar na triagem inicial
de problemas automotivos.

A ideia é simples: o usuário informa o veículo, seleciona uma gravação do motor e o
sistema compara as características acústicas do arquivo com um modelo treinado. Ao
final, a aplicação apresenta um ranking de classificações, a qualidade da gravação e
salva todo o resultado em um histórico local.

O projeto é uma prova de conceito acadêmica. Ele não substitui a avaliação de um
mecânico, um scanner automotivo ou outros procedimentos técnicos. Nesta versão, o
modelo demonstra a separação entre som normal e anomalia acústica em um domínio
limitado.

## Objetivo

O objetivo principal foi construir um sistema completo, e não somente um notebook de
Machine Learning. Por isso, o projeto possui:

- aplicação desktop em Delphi 12;
- API local em Python com FastAPI;
- modelo de Machine Learning treinado e carregado pela API;
- banco SQLite para cadastros e histórico;
- processamento e validação dos arquivos de áudio;
- comparação experimental entre classe majoritária, Random Forest e regressão logística;
- integração opcional com dados públicos da NHTSA;
- scripts para preparação de dataset, treinamento e testes;
- áudios prontos para uma demonstração acadêmica.

## Como o sistema funciona

O fluxo de uma análise é o seguinte:

1. O usuário seleciona um veículo cadastrado no Delphi.
2. O usuário escolhe um áudio do motor.
3. O Delphi envia o arquivo e os dados do veículo para a API Python usando
   `multipart/form-data`.
4. A API valida e padroniza o áudio.
5. São extraídas características acústicas, como MFCC, energia, espectro, chroma e
   cruzamentos por zero.
6. O modelo calcula as probabilidades das classes disponíveis.
7. A API devolve o ranking, a qualidade do áudio, a duração, o tempo de processamento
   e a versão do modelo.
8. O Delphi apresenta o resultado e grava a análise no SQLite.
9. Uma cópia do áudio é armazenada em `audios/analisados` para permitir a consulta no
   histórico.

Durante a requisição, a tela de análise continua respondendo. Uma barra verde animada
indica que o processamento está em andamento e os controles que poderiam iniciar uma
segunda operação ficam temporariamente bloqueados.

## Arquitetura

```text
Usuário
  |
  v
Delphi 12 / VCL
  |-- cadastros e histórico --------> SQLite
  |
  |-- áudio + dados do veículo -----> FastAPI / Python
                                         |
                                         |-- pré-processamento do áudio
                                         |-- extração de características
                                         |-- modelo Random Forest
                                         |-- contexto NHTSA opcional
                                         v
                                  resposta com probabilidades
```

O Delphi é responsável pela experiência do usuário e pela persistência. O Python é
responsável pelo processamento acústico e pela inferência. Essa divisão facilita a
troca do modelo no futuro sem precisar reconstruir todas as telas.

## Tecnologias utilizadas

- Delphi 12 Community Edition e VCL;
- FireDAC para acesso ao banco;
- SQLite em modo WAL;
- Python 3.13;
- FastAPI e Uvicorn;
- Librosa e SoundFile;
- NumPy e Pandas;
- Scikit-learn e Joblib;
- Pytest para os testes automatizados;
- FFmpeg opcional para formatos diferentes de WAV.

## Funcionalidades disponíveis

### Tela principal

A tela principal concentra o acesso a:

- Nova análise;
- Veículos;
- Defeitos;
- Histórico;
- Configurações.

O rodapé informa se o SQLite está conectado, se a API está online e qual versão do
modelo está carregada.

### Cadastro de veículos

Permite cadastrar e editar:

- marca e modelo;
- ano inicial e final;
- código e família do motor;
- cilindrada e quantidade de cilindros;
- combustível e aspiração;
- número de válvulas;
- tipo de injeção.

Esses dados acompanham o áudio enviado à API e deixam a estrutura preparada para
modelos mais específicos por família de motor.

### Cadastro de defeitos

Mantém a lista de classes utilizadas pelo histórico. O banco inicial possui:

- funcionamento normal;
- falha de ignição ou marcha irregular;
- correia, polia ou rolamento;
- ruído metálico do motor;
- anomalia acústica não especificada.

O modelo atualmente instalado utiliza somente `NORMAL` e
`ANOMALIA_NAO_ESPECIFICADA`. As demais classes fazem parte da estrutura planejada para
uma base brasileira futura.

### Análise de áudio

Na tela de análise é possível:

- escolher a marca e o veículo;
- selecionar um arquivo de áudio;
- ouvir o arquivo antes do envio;
- iniciar a análise sem travar a interface;
- visualizar o indicador de duração e o tempo de processamento;
- consultar as probabilidades de áudio, histórico e resultado final;
- identificar claramente o resultado principal;
- salvar automaticamente o resultado no histórico.

### Como interpretar o resultado

A grade mostra todas as classes em ordem de probabilidade. A primeira linha é o
resultado principal; as outras linhas são alternativas calculadas pelo modelo.

Por exemplo, se aparecer:

```
Funcionamento sem anomalia detectada: 99,98%
Anomalia acústica:                    00,02%
```

o resultado principal é **normal**. A presença da segunda linha não significa que o
motor foi classificado como defeituoso; ela representa apenas a probabilidade restante
da classificação binária.

As colunas significam:

- **Áudio:** probabilidade produzida pelo modelo acústico;
- **Histórico:** contexto estatístico, quando houver uma fonte compatível;
- **Final:** valor apresentado como ranking final.

Nesta versão, o contexto da NHTSA permanece separado e não altera automaticamente a
probabilidade acústica.

### Histórico

O histórico permite:

- listar as análises já realizadas;
- consultar o veículo, data, modelo de ML e qualidade;
- visualizar as probabilidades associadas a cada análise;
- abrir novamente o áudio que foi armazenado.

As gravações do cabeçalho e dos resultados são feitas em uma única transação para
evitar análises incompletas no banco.

### Configurações

A tela de configurações controla:

- endereço e porta da API;
- inicialização automática do Python;
- início e encerramento manual da API;
- teste de conexão;
- modo de desenvolvimento e porta de depuração do PyCharm.

Os valores ficam no arquivo `autosom.ini`. A configuração padrão usa
`http://127.0.0.1:8000` e inicia a API automaticamente.

## Banco de dados

O banco fica em `dados/diagnostico_automotivo.db`. Na inicialização, o Delphi abre a
conexão, habilita chaves estrangeiras, configura o tempo de espera e executa o arquivo
`dados/schema.sql`.

As principais tabelas são:

- `modelo_veiculo`: catálogo de veículos e motores;
- `defeito`: classes de normalidade e defeitos;
- `fonte_dado`: procedência e licença das informações;
- `amostra_audio`: metadados das amostras usadas em datasets;
- `ocorrencia_defeito`: estrutura para ocorrências externas;
- `analise`: cabeçalho de cada processamento;
- `analise_resultado`: probabilidades retornadas em cada análise.

O Python usa o SQLite apenas para leitura. As gravações do sistema são centralizadas
no Delphi.

## API Python

### Rotas disponíveis

- `GET /api/v1/saude`: informa se a API está funcionando e qual modelo foi carregado;
- `POST /api/v1/analises/audio`: recebe o áudio e os dados do veículo;
- `GET /api/v1/contexto/nhtsa`: consulta reclamações e recalls americanos;
- `POST /api/v1/debug/pycharm/conectar`: disponível somente no modo de
  desenvolvimento.

## Preparação do ambiente

### Requisitos

- Windows 10 ou 11;
- Delphi 12 com suporte a aplicações VCL;
- Python 3.13;
- aproximadamente 2 GB livres para dependências e dados locais;
- FFmpeg apenas se forem usados MP3, OGG, OPUS ou M4A.

## Demonstração pronta

Existe um veículo de exemplo no banco:

```
Marca: BMW
Modelo: Demonstração AI Mechanic
Ano: 2004
Motor: M54B25
Família: BMW_M54
```

Os arquivos usados na apresentação são:

- `audios/demonstracao/01_motor_normal_bmw_m54.wav`;
- `audios/demonstracao/02_motor_anomalia_bmw_m54.wav`.

O primeiro deve colocar a classe normal no topo do ranking e o segundo deve colocar a
anomalia no topo. As probabilidades podem variar caso o modelo seja treinado novamente.

## Modelo de Machine Learning atual

O modelo instalado é o `0.1.0-ai-mechanic-bmw`. Ele utiliza Random Forest combinado
com características acústicas e contexto mecânico.

O treinamento atual possui:

- 121 segmentos únicos;
- 15 grupos de gravação;
- 94 exemplos de anomalia;
- 27 exemplos normais;
- dados de um BMW M54B25 de 2004;
- validação em cinco dobras separadas por grupo de gravação.

Métricas registradas nos metadados:

- acurácia: 78,5%;
- acurácia balanceada: 61,1%;
- F1 macro: 62,5%;
- recall da classe normal: 29,6%.

A separação por grupo evita colocar trechos do mesmo áudio ao mesmo tempo no treino e
no teste. Mesmo assim, a base é pequena, estrangeira e desbalanceada. Portanto, essas
métricas não podem ser generalizadas para os motores usados na frota brasileira.

## Bases de dados pesquisadas

Durante o desenvolvimento foram avaliadas as seguintes fontes:

- **AI Mechanic:** incorporada ao protótipo; licença Apache 2.0; útil para normal x
  anomalia no BMW M54B25;
- **Car Diagnostics Dataset:** interessante, mas não incorporada porque a licença e a
  origem de parte dos arquivos não estão suficientemente claras;
- **OtoMobile/OtoMechanic:** pequena e relevante, porém exige solicitação de acesso
  para uso educacional ou de pesquisa;
- **Vehicular Acoustic Fault Dataset:** referência metodológica; licença precisa ser
  confirmada antes de copiar os áudios;
- **Automotive Faults Dataset:** útil para sintomas e lógica de diagnóstico, mas não é
  uma base principal de áudio e não possui licença clara no registro consultado;
- **SENATRAN/RENAVAM:** útil para priorizar os veículos brasileiros mais presentes na
  frota, mas não contém áudio ou diagnóstico;
- **NHTSA:** integrada como contexto de reclamações e recalls dos Estados Unidos;
- **MIMII e ToyADMOS2:** úteis para estudar detecção de anomalias, porém contêm
  máquinas industriais ou miniaturas e não devem ser tratadas como motores reais.

## Como treinar um novo modelo

As dependências adicionais são instaladas com:

```powershell
python\.venv\Scripts\python.exe -m pip install -r python\requirements-ml.txt
```

Depois, o fluxo básico é:

1. organizar os áudios por classe em `audios/dataset_local`;
2. gerar e revisar o manifesto;
3. preencher origem, licença, grupo de gravação e nível de confirmação;
4. executar o treinamento;
5. reiniciar a API para carregar o novo arquivo Joblib.

Exemplo:

```powershell
python\.venv\Scripts\python.exe python\treinamento\preparar_dataset.py
python\.venv\Scripts\python.exe python\treinamento\treinar_modelo.py `
  --manifesto audios\dataset_local\manifesto.csv `
  --versao 0.2.0-br
```

As instruções detalhadas estão em [python/TREINAMENTO.md](python/TREINAMENTO.md).

## Estratégia para uma base brasileira

Cada coleta deveria registrar:

- veículo e família do motor;
- condição e rotação aproximada;
- posição do celular;
- diagnóstico confirmado;
- áudio antes do reparo;
- áudio após o reparo;
- origem e autorização de uso.

Trechos do mesmo áudio não devem ser contados como veículos independentes. Para uma
avaliação confiável, veículos físicos inteiros precisam permanecer fora do treino e
ser usados apenas no teste.

## Formatos de áudio e FFmpeg

WAV funciona diretamente. MP3, OGG, OPUS e M4A dependem do FFmpeg. O executável pode
estar no `PATH` do Windows ou ser informado pela variável `AUTOSOM_FFMPEG`.

Para a apresentação, os dois arquivos WAV da pasta `audios/demonstracao` não exigem
FFmpeg nem acesso à internet.

## Limitações conhecidas

- o modelo atual cobre apenas classificação binária;
- a base representa somente um conjunto de motor estrangeiro;
- há desbalanceamento entre exemplos normais e anômalos;
- a qualidade do resultado depende da posição e da qualidade da gravação;
- a NHTSA representa o mercado americano, não a prevalência de defeitos no Brasil;
- uma probabilidade alta não identifica sozinha o componente com defeito;
- o sistema deve ser tratado como apoio à triagem, nunca como diagnóstico conclusivo.

## Próximas etapas

### Reproduzir a comparação do estudo piloto

O experimento está separado do treinamento que instala o modelo. Após instalar
`python/requirements-ml.txt`, execute na raiz:

```powershell
python\.venv\Scripts\python.exe python\treinamento\comparar_modelos.py `
  --manifesto audios\dataset_local\ai_mechanic\manifesto.csv `
  --saida output\experimentos `
  --semente 42
```

A rotina usa as mesmas cinco dobras por gravação para os três classificadores.
Exporta auditoria com hashes, características, divisões, previsões por segmento e por
gravação, métricas por dobra e versões das bibliotecas. Ela não altera o modelo instalado.
Os resultados são exploratórios, sem teste externo, e o desvio entre dobras não é um
intervalo de confiança. O chamado campo `qualidade_audio` da API permanece compatível;
na interface, ele é apresentado como indicador de duração, pois não mede ruído ou
qualidade acústica. Para aplicar essa alteração visual, recompile o projeto pela IDE
Delphi 12; a Community Edition pode impedir compilação pelo terminal.

Este repositório distribui o código-fonte. Áudios, banco local, ambiente virtual,
modelo Joblib, exemplos da disciplina, artigo, apresentação e resultados gerados
ficam fora do controle de versão. O conjunto AI Mechanic deve ser obtido na sua fonte
original, citada em `python/TREINAMENTO.md`, e importado antes do treinamento.

### Evolução após o piloto

- coletar uma base brasileira com diagnóstico confirmado;
- melhorar o equilíbrio entre as classes;
- avaliar modelos de detecção de anomalia e redes neurais de áudio;
- comparar celulares e posições de gravação diferentes;
- adicionar explicações acústicas e espectrogramas na interface;
- validar o sistema com mecânicos e veículos fora da base de treinamento;
- ampliar as classes somente quando existirem dados suficientes e confiáveis.

## Consideração final

O principal resultado deste trabalho é a integração completa entre uma aplicação
desktop, uma API de processamento, um modelo de Machine Learning e um banco local. A
precisão ainda é limitada pela quantidade e pela diversidade dos dados, mas o sistema
já permite demonstrar todo o caminho entre selecionar um áudio, processá-lo, obter uma
classificação e consultar o resultado posteriormente.
