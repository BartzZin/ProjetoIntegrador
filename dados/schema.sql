PRAGMA foreign_keys = ON;
PRAGMA busy_timeout = 5000;
PRAGMA journal_mode = WAL;

CREATE TABLE IF NOT EXISTS modelo_veiculo (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    marca TEXT NOT NULL,
    modelo TEXT NOT NULL,
    ano_inicial INTEGER,
    ano_final INTEGER,
    codigo_motor TEXT,
    familia_motor TEXT,
    cilindrada_cc INTEGER,
    cilindros INTEGER,
    combustivel TEXT,
    aspiracao TEXT,
    valvulas INTEGER,
    tipo_injecao TEXT,
    origem_dados TEXT,
    ativo INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0, 1))
);

CREATE TABLE IF NOT EXISTS defeito (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    categoria TEXT NOT NULL,
    componente TEXT,
    nome TEXT NOT NULL,
    descricao TEXT,
    ativo INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0, 1))
);

CREATE TABLE IF NOT EXISTS fonte_dado (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    tipo TEXT NOT NULL,
    endereco TEXT,
    licenca TEXT,
    data_acesso TEXT,
    observacao TEXT
);

CREATE TABLE IF NOT EXISTS amostra_audio (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    modelo_veiculo_id INTEGER,
    defeito_id INTEGER,
    fonte_dado_id INTEGER,
    arquivo_relativo TEXT NOT NULL,
    arquivo_original TEXT,
    duracao_segundos REAL,
    formato_original TEXT,
    rpm_aproximado INTEGER,
    condicao_motor TEXT,
    posicao_gravacao TEXT,
    nivel_confirmacao INTEGER NOT NULL DEFAULT 0 CHECK (nivel_confirmacao BETWEEN 0 AND 4),
    observacao TEXT,
    FOREIGN KEY (modelo_veiculo_id) REFERENCES modelo_veiculo(id),
    FOREIGN KEY (defeito_id) REFERENCES defeito(id),
    FOREIGN KEY (fonte_dado_id) REFERENCES fonte_dado(id)
);

CREATE TABLE IF NOT EXISTS ocorrencia_defeito (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    modelo_veiculo_id INTEGER,
    defeito_id INTEGER,
    fonte_dado_id INTEGER,
    periodo TEXT,
    quantidade INTEGER NOT NULL DEFAULT 1 CHECK (quantidade >= 0),
    descricao_original TEXT,
    FOREIGN KEY (modelo_veiculo_id) REFERENCES modelo_veiculo(id),
    FOREIGN KEY (defeito_id) REFERENCES defeito(id),
    FOREIGN KEY (fonte_dado_id) REFERENCES fonte_dado(id)
);

CREATE TABLE IF NOT EXISTS analise (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    modelo_veiculo_id INTEGER NOT NULL,
    data_hora TEXT NOT NULL,
    arquivo_relativo TEXT NOT NULL,
    qualidade_audio REAL CHECK (qualidade_audio BETWEEN 0 AND 1),
    classificacao_qualidade TEXT,
    versao_modelo_ml TEXT,
    tempo_processamento_ms INTEGER,
    FOREIGN KEY (modelo_veiculo_id) REFERENCES modelo_veiculo(id)
);

CREATE TABLE IF NOT EXISTS analise_resultado (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    analise_id INTEGER NOT NULL,
    defeito_id INTEGER NOT NULL,
    probabilidade_audio REAL CHECK (probabilidade_audio BETWEEN 0 AND 1),
    probabilidade_historica REAL CHECK (probabilidade_historica BETWEEN 0 AND 1),
    probabilidade_final REAL CHECK (probabilidade_final BETWEEN 0 AND 1),
    ordem_resultado INTEGER,
    FOREIGN KEY (analise_id) REFERENCES analise(id) ON DELETE CASCADE,
    FOREIGN KEY (defeito_id) REFERENCES defeito(id)
);

CREATE INDEX IF NOT EXISTS idx_modelo_veiculo_marca_modelo
    ON modelo_veiculo(marca, modelo);
CREATE INDEX IF NOT EXISTS idx_amostra_audio_modelo
    ON amostra_audio(modelo_veiculo_id);
CREATE INDEX IF NOT EXISTS idx_analise_data_hora
    ON analise(data_hora DESC);
CREATE INDEX IF NOT EXISTS idx_analise_resultado_analise
    ON analise_resultado(analise_id, ordem_resultado);

INSERT OR IGNORE INTO defeito (id, categoria, componente, nome, descricao) VALUES
    (1, 'NORMAL', 'FUNCIONAMENTO', 'Normal', 'Som de funcionamento sem anomalia rotulada'),
    (2, 'MOTOR', 'IGNICAO', 'Falha de ignicao / marcha irregular', 'Funcionamento irregular do motor'),
    (3, 'MOTOR', 'ACESSORIOS', 'Correia, polia ou rolamento', 'Ruido associado aos acessorios do motor'),
    (4, 'MOTOR', 'INTERNO', 'Ruido metalico do motor', 'Batida ou ruido metalico interno'),
    (5, 'MOTOR', 'NAO_ESPECIFICADO', 'Anomalia acustica nao especificada',
        'Som anormal detectado sem evidencia suficiente para indicar o componente');
