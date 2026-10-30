CREATE DATABASE DataBus;
USE DataBus;

CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    cnpj CHAR(18) NOT NULL UNIQUE,
    codigo_verificacao CHAR(6) NOT NULL UNIQUE,
    razao_social VARCHAR(100) NOT NULL,
    nome_fantasia VARCHAR(60) NOT NULL,
    regiao VARCHAR(40),
    CONSTRAINT ch_regiao CHECK (regiao IN ('Intermunicipal', 'Municipal'))
);

CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(100) NOT NULL,
    tipo_perfil VARCHAR(45) NOT NULL,
    fk_empresa INT NOT NULL,
    fk_adm INT,
    CONSTRAINT ch_tipo_perfil CHECK (tipo_perfil IN ('Administrador', 'Operador')),
    CONSTRAINT fk_usuario_empresa FOREIGN KEY (fk_empresa)
        REFERENCES empresa(id_empresa),
    CONSTRAINT fk_usuario_adm FOREIGN KEY (fk_adm)
        REFERENCES usuario(id_usuario)
);

CREATE TABLE linha (
    id_linha INT PRIMARY KEY AUTO_INCREMENT,
    codigo CHAR(7) NOT NULL UNIQUE,
    nome VARCHAR(45) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    total_passageiros INT NOT NULL,
    fk_empresa INT NOT NULL,
    CONSTRAINT fk_linha_empresa FOREIGN KEY (fk_empresa)
        REFERENCES empresa(id_empresa)
);

CREATE TABLE onibus (
    id_onibus INT PRIMARY KEY AUTO_INCREMENT,
    placa CHAR(7) NOT NULL UNIQUE,
    capacidade_maxima INT NOT NULL,
    status_onibus VARCHAR(45) NOT NULL,
    fk_empresa INT NOT NULL,
    CONSTRAINT ch_status_onibus CHECK (status_onibus IN ('Ativo', 'Manutencao', 'Desativado')),
    CONSTRAINT fk_onibus_empresa FOREIGN KEY (fk_empresa)
    REFERENCES empresa(id_empresa)
);

CREATE TABLE operacao (
    id_operacao INT PRIMARY KEY AUTO_INCREMENT,
    dt_operacao DATE NOT NULL,
    fk_linha INT NOT NULL,
    fk_onibus INT NOT NULL,
    CONSTRAINT fk_operacao_linha FOREIGN KEY (fk_linha)
        REFERENCES linha(id_linha),
    CONSTRAINT fk_operacao_onibus FOREIGN KEY (fk_onibus)
        REFERENCES onibus(id_onibus)
);

CREATE TABLE sensor (
    id_sensor INT PRIMARY KEY AUTO_INCREMENT,
    modelo VARCHAR(10),
    data_instalacao DATE,
    status_sensor VARCHAR(20) NOT NULL,
    fk_onibus INT NOT NULL,
    CONSTRAINT ch_status_sensor CHECK (status_sensor IN ('Ativo', 'Manutencao', 'Desativado')),
    CONSTRAINT fk_sensor_onibus FOREIGN KEY (fk_onibus)
        REFERENCES onibus(id_onibus)
);

CREATE TABLE registro_sensor (
    id_registro INT PRIMARY KEY AUTO_INCREMENT,
    registro_entrada TINYINT NOT NULL,
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    fk_sensor INT NOT NULL,
    CONSTRAINT ch_registro_entrada CHECK (registro_entrada = 1),
    CONSTRAINT fk_registro_sensor FOREIGN KEY (fk_sensor)
		REFERENCES sensor(id_sensor)
);

INSERT INTO empresa (cnpj, codigo_verificacao, razao_social, nome_fantasia, regiao) VALUES
('00.000.000/0001-91', 'A7K9Q2', 'Mobi Brasil Mobilidade Urbana Ltda.', 'Mobi Brasil', 'Intermunicipal'),
('00.121.011/0041-31', 'M4X8P1', 'São Paulo Transporte S/A', 'SPTrans', 'Municipal'),
('00.011.011/0011-11', 'R6T3Z9', 'Viação Mobi Rios S.A.', 'MobiRio', 'Municipal'),
('12.713.901/1021-51', 'B2N7L5', 'Transcon Transportes e Concessões S.A.', 'TransCon', 'Intermunicipal');

-- A Ana (SPTrans) é cadastrada pelo administrador da própria SPTrans
INSERT INTO usuario (nome, email, senha, tipo_perfil, fk_empresa, fk_adm) VALUES
('João Pereira', 'joao@mobibrasil.com.br', 'Admin123', 'Administrador', 1, NULL),
('Carlos Lima', 'carlos@sptrans.com.br', 'Admin456', 'Administrador', 2, NULL),
('Ana Souza', 'ana@sptrans.com.br', 'Operador789', 'Operador', 2, 2);


-- Ônibus 1 e 2: Capacidade 100
INSERT INTO onibus (placa, capacidade_maxima, status_onibus, fk_empresa) VALUES
('ABC1134', 100, 'Ativo', 1),
('CBA1234', 100, 'Ativo', 1);
-- Ônibus 3, 4 e 5: Capacidade 120
INSERT INTO onibus (placa, capacidade_maxima, status_onibus, fk_empresa) VALUES
('XYZ9876', 120, 'Ativo', 2),
('BRA4E22', 120, 'Ativo', 2),
('BRA5F33', 120, 'Ativo', 2);


-- LINHAS
-- Linha 1 (30 passageiros / ônibus 1, capacidade 100 = 30%) -> Baixa ocupação (< 35%)
INSERT INTO linha (codigo, nome, hora_inicio, hora_fim, total_passageiros, fk_empresa) VALUES
('8144-22', 'Penha - Ipanema', '07:00:00', '09:00:00', 30, 1),
-- Linha 2 (32 passageiros / ônibus 2, capacidade 100 = 32%) -> Baixa ocupação
('607C-10', 'Jardim Miriam - Itaim Bibi', '17:00:00', '19:00:00', 32, 1),
-- Linha 3 (90 passageiros / ônibus 3, capacidade 120 = 75%) -> Atenção (60% a 85%)
('1721-10', 'Parque Edu Chaves - Metro', '07:00:00', '09:00:00', 90, 2),
-- Linha 4 (105 passageiros / ônibus 4, capacidade 120 = 87.5%) -> Alta ocupação (> 85%)
('2019-AC', 'União - Serra', '07:00:00', '09:00:00', 105, 2),
-- Linha 5 (110 passageiros / ônibus 5, capacidade 120 = 91.7%) -> Alta ocupação
('3016-21', 'Guaianases - Terminal', '08:00:00', '10:00:00', 110, 2);


-- OPERAÇÕES (cada ônibus em uma linha da própria empresa)
INSERT INTO operacao (dt_operacao, fk_linha, fk_onibus) VALUES
('2026-09-28', 1, 1),
('2026-09-28', 2, 2),
('2026-09-28', 3, 3),
('2026-09-28', 4, 4),
('2026-09-28', 5, 5);


-- SENSORES
INSERT INTO sensor (modelo, data_instalacao, status_sensor, fk_onibus) VALUES
('HC-SR04', '2026-09-21', 'Ativo', 1),
('HC-SR04', '2026-09-21', 'Ativo', 2),
('HC-SR04', '2026-09-21', 'Ativo', 3),
('HC-SR04', '2026-09-21', 'Ativo', 4),
('HC-SR04', '2026-09-21', 'Ativo', 5);


-- REGISTROS DO SENSOR
INSERT INTO registro_sensor (registro_entrada, data_hora, fk_sensor) VALUES
(1, '2026-09-28 07:10:00', 1),
(1, '2026-09-28 07:15:00', 2),
(1, '2026-09-28 07:20:00', 3),
(1, '2026-09-28 07:25:00', 4);


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

-- KPI 2
SELECT
    linha.codigo AS 'Código da Linha',
    linha.nome AS 'Nome da Linha',
    linha.total_passageiros AS 'Passageiros',
    SUM(onibus.capacidade_maxima) AS 'Capacidade',      -- soma dos lugares dos ônibus da linha
    ROUND(linha.total_passageiros / SUM(onibus.capacidade_maxima) * 100, 1) AS ocupacao -- ocupação em %
FROM linha
JOIN operacao ON operacao.fk_linha = linha.id_linha     -- liga a linha com as operações dela
JOIN onibus ON onibus.id_onibus = operacao.fk_onibus    -- liga cada operação com o ônibus usado
WHERE operacao.dt_operacao = '2026-09-28'               -- só as operações do dia
GROUP BY linha.id_linha, linha.codigo, linha.nome, linha.total_passageiros
HAVING ocupacao < 35;

-- KPI 3
SELECT
    linha.codigo AS 'Código da Linha',
    linha.nome AS 'Nome da Linha',
    linha.total_passageiros AS 'Passageiros',
    SUM(onibus.capacidade_maxima) AS 'Capacidade',
    ROUND(linha.total_passageiros / SUM(onibus.capacidade_maxima) * 100, 1) AS ocupacao
FROM linha
JOIN operacao ON operacao.fk_linha = linha.id_linha
JOIN onibus ON onibus.id_onibus = operacao.fk_onibus
WHERE operacao.dt_operacao = '2026-09-28'
GROUP BY linha.id_linha, linha.codigo, linha.nome, linha.total_passageiros
HAVING ocupacao > 85;

-- KPI 4
-- Média de hoje
SELECT ROUND(AVG(linha.total_passageiros / onibus.capacidade_maxima * 100), 1) AS 'Ocupação Média do Dia'
FROM linha
JOIN operacao ON operacao.fk_linha = linha.id_linha
JOIN onibus ON onibus.id_onibus = operacao.fk_onibus
WHERE operacao.dt_operacao = '2026-09-28';

-- Média dos 7 dias anteriores
-- (fica NULL enquanto não houver operações cadastradas nesses dias)
SELECT ROUND(AVG(linha.total_passageiros / onibus.capacidade_maxima * 100), 1) AS 'Média dos 7 Dias Anteriores'
FROM linha
JOIN operacao ON operacao.fk_linha = linha.id_linha
JOIN onibus ON onibus.id_onibus = operacao.fk_onibus
WHERE operacao.dt_operacao BETWEEN '2026-09-21' AND '2026-09-27';
