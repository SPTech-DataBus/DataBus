CREATE DATABASE DataBus;
USE DataBus;

CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    cnpj CHAR(18) NOT NULL UNIQUE,
    codigo_verificacao CHAR(6) NOT NULL UNIQUE,
    razao_social VARCHAR(100) NOT NULL,
    nome_fantasia VARCHAR(60) NOT NULL,
    regiao VARCHAR(40),

    CONSTRAINT ch_regiao CHECK (
        regiao IN ('Intermunicipal', 'Municipal')
    )
);

CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(100) NOT NULL,
    tipo_perfil VARCHAR(45) NOT NULL,

    fk_empresa INT NOT NULL,
    fk_adm INT,

    CONSTRAINT ch_tipo_perfil CHECK (
        tipo_perfil IN ('Administrador', 'Operador')
    ),

    CONSTRAINT fk_usuario_empresa
        FOREIGN KEY (fk_empresa)
        REFERENCES empresa(id_empresa),

    CONSTRAINT fk_usuario_adm
        FOREIGN KEY (fk_adm)
        REFERENCES usuario(id_usuario)
);

CREATE TABLE linha (
    id_linha INT PRIMARY KEY AUTO_INCREMENT,
    codigo CHAR(7) NOT NULL UNIQUE,
    nome VARCHAR(45) NOT NULL,
    hora_inicio DATETIME NOT NULL,
    hora_fim DATETIME NOT NULL,
    total_passageiros INT NOT NULL,
    fk_empresa INT NOT NULL,

    CONSTRAINT fk_linha_empresa
        FOREIGN KEY (fk_empresa)
        REFERENCES empresa(id_empresa)
);

CREATE TABLE onibus (
    id_onibus INT PRIMARY KEY AUTO_INCREMENT,
    placa CHAR(7) NOT NULL UNIQUE,
    capacidade_maxima INT NOT NULL,
    status_onibus VARCHAR(45) NOT NULL,

    fk_empresa INT NOT NULL,

    CONSTRAINT ch_status_onibus CHECK (
        status_onibus IN ('Ativo', 'Manutencao', 'Desativado')
    ),

    CONSTRAINT fk_onibus_empresa
        FOREIGN KEY (fk_empresa)
        REFERENCES empresa(id_empresa)
);

CREATE TABLE operacao (
    id_operacao INT PRIMARY KEY AUTO_INCREMENT,
    dt_operacao DATE NOT NULL,

    fk_linha INT NOT NULL,
    fk_onibus INT NOT NULL,

    CONSTRAINT fk_operacao_linha
        FOREIGN KEY (fk_linha)
        REFERENCES linha(id_linha),

    CONSTRAINT fk_operacao_onibus
        FOREIGN KEY (fk_onibus)
        REFERENCES onibus(id_onibus)
);

CREATE TABLE sensor (
    id_sensor INT PRIMARY KEY AUTO_INCREMENT,
    modelo VARCHAR(10),
    data_instalacao DATE,
    status_sensor VARCHAR(20) NOT NULL,

    fk_onibus INT NOT NULL,

    CONSTRAINT ch_status_sensor CHECK (
        status_sensor IN ('Ativo', 'Manutencao', 'Desativado')
    ),

    CONSTRAINT fk_sensor_onibus
        FOREIGN KEY (fk_onibus)
        REFERENCES onibus(id_onibus)
);

CREATE TABLE registro_sensor (
    id_registro INT PRIMARY KEY AUTO_INCREMENT,

    registro_entrada TINYINT NOT NULL,

    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,

    fk_sensor INT NOT NULL,

    CONSTRAINT ch_registro_entrada CHECK (
        registro_entrada = 1
    ),

    CONSTRAINT fk_registro_sensor
        FOREIGN KEY (fk_sensor)
        REFERENCES sensor(id_sensor)
);

INSERT INTO empresa (cnpj, codigo_verificacao, razao_social, nome_fantasia, regiao) VALUES 
('00.000.000/0001-91', 'A7K9Q2', 'Mobi Brasil Mobilidade Urbana Ltda.', 'Mobi Brasil', 'Intermunicipal'),
('00.121.011/0041-31', 'M4X8P1', 'São Paulo Transporte S/A', 'SPTrans', 'Municipal'),
('00.011.011/0011-11', 'R6T3Z9', 'Viação Mobi Rios S.A.', 'MobiRio', 'Municipal'),
('12.713.901/1021-51', 'B2N7L5', 'Transcon Transportes e Concessões S.A.', 'TransCon', 'Intermunicipal');

INSERT INTO usuario (nome, email, senha, tipo_perfil, fk_empresa, fk_adm) VALUES 
('João Pereira', 'joao@mobibrasil.com.br', 'Admin123', 'Administrador', 1, NULL),
('Ana Souza', 'ana@sptrans.com.br', 'Operador789', 'Operador', 2, 1);


-- Ônibus 1 e 2: Capacidade 100
INSERT INTO onibus (placa, capacidade_maxima, status_onibus, fk_empresa) VALUES ('ABC1134', 100, 'Ativo', 1);
INSERT INTO onibus (placa, capacidade_maxima, status_onibus, fk_empresa) VALUES ('CBA1234', 100, 'Ativo', 1);
-- Ônibus 3 e 4: Capacidade 120
INSERT INTO onibus (placa, capacidade_maxima, status_onibus, fk_empresa) VALUES ('XYZ9876', 120, 'Ativo', 2);
INSERT INTO onibus (placa, capacidade_maxima, status_onibus, fk_empresa) VALUES ('BRA4E22', 120, 'Ativo', 2);


-- 4. LINHAS
-- Linha 1 (Baixa Ocupação: 30 passageiros / capacidade 100 = 30%) -> Entra na KPI de Baixa Ocupação (< 35%)
INSERT INTO linha (codigo, nome, hora_inicio, hora_fim, total_passageiros, fk_empresa) 
VALUES ('8144-22', 'Penha - Ipanema', '2026-09-28 07:00:00', '2026-09-28 09:00:00', 30, 1);

-- Linha 2 (Baixa Ocupação: 32 passageiros / capacidade 100 = 32%) -> Segunda linha de baixa ocupação
INSERT INTO linha (codigo, nome, hora_inicio, hora_fim, total_passageiros, fk_empresa) 
VALUES ('607C-10', 'Jardim Miriam - Itaim Bibi', '2026-09-28 17:00:00', '2026-09-28 19:00:00', 32, 1);

-- Linha 3 (Alta Ocupação: 90 passageiros / capacidade 100 = 90%) -> Entra na KPI de Alta Ocupação (> 85%)
INSERT INTO linha (codigo, nome, hora_inicio, hora_fim, total_passageiros, fk_empresa) 
VALUES ('1721-10', 'Parque Edu Chaves - Metro', '2026-09-28 07:00:00', '2026-09-28 09:00:00', 90, 2);

-- Linha 4 (Alta Ocupação: 105 passageiros / capacidade 120 = 87.5%) -> Segunda linha de alta ocupação
INSERT INTO linha (codigo, nome, hora_inicio, hora_fim, total_passageiros, fk_empresa) 
VALUES ('2019-AC', 'União - Serra', '2026-09-28 07:00:00', '2026-09-28 09:00:00', 105, 2);

-- Linha 5 (Alta Ocupação: 110 passageiros / capacidade 120 = 91.6%) -> Terceira linha de alta ocupação
INSERT INTO linha (codigo, nome, hora_inicio, hora_fim, total_passageiros, fk_empresa) 
VALUES ('3016-21', 'Guaianases - Terminal', '2026-09-28 08:00:00', '2026-09-28 10:00:00', 110, 2);


-- OPERAÇÕES 
INSERT INTO operacao (dt_operacao, fk_linha, fk_onibus) VALUES ('2026-09-28', 1, 1);
INSERT INTO operacao (dt_operacao, fk_linha, fk_onibus) VALUES ('2026-09-28', 2, 2);
INSERT INTO operacao (dt_operacao, fk_linha, fk_onibus) VALUES ('2026-09-28', 3, 3);
INSERT INTO operacao (dt_operacao, fk_linha, fk_onibus) VALUES ('2026-09-28', 4, 4);
INSERT INTO operacao (dt_operacao, fk_linha, fk_onibus) VALUES ('2026-09-28', 5, 1);


-- SENSORES 
INSERT INTO sensor (modelo, data_instalacao, status_sensor, fk_onibus) VALUES ('HC-SR04', '2026-09-21', 'Ativo', 1);
INSERT INTO sensor (modelo, data_instalacao, status_sensor, fk_onibus) VALUES ('HC-SR04', '2026-09-21', 'Ativo', 2);
INSERT INTO sensor (modelo, data_instalacao, status_sensor, fk_onibus) VALUES ('HC-SR04', '2026-09-21', 'Ativo', 3);
INSERT INTO sensor (modelo, data_instalacao, status_sensor, fk_onibus) VALUES ('HC-SR04', '2026-09-21', 'Ativo', 4);


-- REGISTROS DO SENSOR 
INSERT INTO registro_sensor (registro_entrada, data_hora, fk_sensor) VALUES (1, '2026-09-28 07:10:00', 1);
INSERT INTO registro_sensor (registro_entrada, data_hora, fk_sensor) VALUES (1, '2026-09-28 07:15:00', 2);
INSERT INTO registro_sensor (registro_entrada, data_hora, fk_sensor) VALUES (1, '2026-09-28 07:20:00', 3);
INSERT INTO registro_sensor (registro_entrada, data_hora, fk_sensor) VALUES (1, '2026-09-28 07:25:00', 4);

-- Listar os ônibus ativos e a qual empresa pertencem
SELECT 
    onibus.placa AS 'Placa do Ônibus',
    onibus.capacidade_maxima AS 'Capacidade Máxima',
    onibus.status_onibus AS 'Status',
    empresa.nome_fantasia AS 'Nome da Empresa'
FROM onibus
JOIN empresa ON onibus.fk_empresa = empresa.id_empresa
WHERE onibus.status_onibus = 'Ativo';

-- Quantidade de ônibus por status da frota (Para gráficos ou cards)
SELECT 
    status_onibus AS 'Status do Ônibus',
    COUNT(id_onibus) AS 'Total de Veículos'
FROM onibus
GROUP BY status_onibus;

-- Relatório de Operações (Qual ônibus está rodando em qual linha)
SELECT 
    operacao.dt_operacao AS 'Data da Operação',
    linha.codigo AS 'Código da Linha',
    linha.nome AS 'Nome da Linha',
    onibus.placa AS 'Placa do Ônibus'
FROM operacao
JOIN linha ON operacao.fk_linha = linha.id_linha
JOIN onibus ON operacao.fk_onibus = onibus.id_onibus;

-- Linhas de ônibus e o total de passageiros projetados/registrados
SELECT 
    linha.codigo AS 'Código da Linha',
    linha.nome AS 'Nome da Linha',
    linha.hora_inicio AS 'Início',
    linha.hora_fim AS 'Fim',
    linha.total_passageiros AS 'Total de Passageiros',
    empresa.nome_fantasia AS 'Empresa Responsável'
FROM linha
JOIN empresa ON linha.fk_empresa = empresa.id_empresa;

-- Linhas com maior demanda de passageiros 
SELECT 
    linha.codigo AS 'Código da Linha',
    linha.nome AS 'Nome da Linha',
    linha.total_passageiros AS 'Total de Passageiros'
FROM linha
ORDER BY linha.total_passageiros DESC;


SELECT 
    linha.codigo AS 'Código da Linha',
    linha.nome AS 'Nome da Linha',
    linha.total_passageiros AS 'Total de Passageiros',
    onibus.capacidade_maxima AS 'Capacidade do Ônibus',
    CONCAT(ROUND((linha.total_passageiros / onibus.capacidade_maxima) * 100, 1), '%') AS 'Taxa de Ocupação'
FROM linha
JOIN operacao ON linha.id_linha = operacao.fk_linha
JOIN onibus ON operacao.fk_onibus = onibus.id_onibus
WHERE (linha.total_passageiros / onibus.capacidade_maxima) * 100 < 35;


-- BASES EM KPI´S (Atualizado)

-- Oportunidades de Remanejamento (Linhas com baixa ocupação que podem liberar veículos)
SELECT 
    linha.codigo AS 'Código da Linha',
    linha.nome AS 'Nome da Linha',
    linha.total_passageiros AS 'Total de Passageiros',
    onibus.capacidade_maxima AS 'Capacidade do Ônibus',
    CONCAT(ROUND((linha.total_passageiros / onibus.capacidade_maxima) * 100, 1), '%') AS 'Taxa de Ocupação'
FROM linha
JOIN operacao ON linha.id_linha = operacao.fk_linha
JOIN onibus ON operacao.fk_onibus = onibus.id_onibus
WHERE (linha.total_passageiros / onibus.capacidade_maxima) * 100 < 35;

-- Alertas de Baixa Ocupação (Contagem de linhas abaixo de 35%)
SELECT 
    COUNT(linha.id_linha) AS 'Total Linhas Baixa Ocupação'
FROM linha
JOIN operacao ON linha.id_linha = operacao.fk_linha
JOIN onibus ON operacao.fk_onibus = onibus.id_onibus
WHERE (linha.total_passageiros / onibus.capacidade_maxima) * 100 < 35;

-- Alertas de Alta Ocupação (Contagem de linhas acima de 85%)
SELECT 
    COUNT(linha.id_linha) AS 'Total Linhas Alta Ocupação'
FROM linha
JOIN operacao ON linha.id_linha = operacao.fk_linha
JOIN onibus ON operacao.fk_onibus = onibus.id_onibus
WHERE (linha.total_passageiros / onibus.capacidade_maxima) * 100 > 85;

-- Comparativo Histórico / Ocupação Média do Dia
SELECT 
    operacao.dt_operacao AS 'Data da Operação',
    CONCAT(ROUND(AVG((linha.total_passageiros / onibus.capacidade_maxima) * 100), 1), '%') AS 'Ocupação Média do Dia'
FROM operacao
JOIN linha ON operacao.fk_linha = linha.id_linha
JOIN onibus ON operacao.fk_onibus = onibus.id_onibus
WHERE operacao.dt_operacao = '2026-09-28'
GROUP BY operacao.dt_operacao;

