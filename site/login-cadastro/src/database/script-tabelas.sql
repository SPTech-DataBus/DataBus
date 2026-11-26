CREATE DATABASE DataBus;

USE DataBus;

CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    cnpj CHAR(18) NOT NULL UNIQUE,
    codigo_verificacao CHAR(6) NOT NULL UNIQUE,
    razao_social VARCHAR(100) NOT NULL,
    nome_fantasia VARCHAR(60) NOT NULL
);

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(30) NOT NULL,
    tipo_perfil VARCHAR(45) NOT NULL,
    fk_empresa INT NOT NULL,
    fk_adm INT NOT NULL,
    PRIMARY KEY (id_usuario, fk_empresa),
    CONSTRAINT ch_tipo_perfil CHECK (tipo_perfil IN ('Administrador', 'Operador')),
    CONSTRAINT fk_usuario_empresa FOREIGN KEY (fk_empresa)
        REFERENCES empresa(id_empresa),
    CONSTRAINT fk_usuario_adm FOREIGN KEY (fk_adm)
        REFERENCES usuario(id_usuario)
);

CREATE TABLE linha (
    id_linha INT AUTO_INCREMENT,
    codigo CHAR(7) NOT NULL UNIQUE,
    nome VARCHAR(45) NOT NULL,
    total_passageiros INT NOT NULL,
    regiao VARCHAR(45),
    fk_empresa INT NOT NULL,
    PRIMARY KEY (id_linha, fk_empresa),
    CONSTRAINT ch_regiao CHECK (regiao IN ('Intermunicipal', 'Municipal')),
    CONSTRAINT fk_linha_empresa FOREIGN KEY (fk_empresa)
        REFERENCES empresa(id_empresa)
);

CREATE TABLE onibus (
    id_onibus INT AUTO_INCREMENT,
    placa CHAR(7) NOT NULL UNIQUE,
    capacidade_maxima INT NOT NULL,
    status_onibus VARCHAR(45) NOT NULL,
    fk_empresa INT NOT NULL,
    PRIMARY KEY (id_onibus, fk_empresa),
    CONSTRAINT ch_status_onibus CHECK (status_onibus IN ('Ativo', 'Manutencao', 'Desativado')),
    CONSTRAINT fk_onibus_empresa FOREIGN KEY (fk_empresa)
    REFERENCES empresa(id_empresa)
);

CREATE TABLE viagem (
    id_viagem INT AUTO_INCREMENT,
    dt_viagem DATE NOT NULL,
    dt_hora_inicio DATETIME,
    dt_hora_fim DATETIME,
    operacao_atual VARCHAR(45),
    qtd_pontos INT,
    qtd_parada INT,
    fk_linha INT NOT NULL,
    fk_onibus INT NOT NULL,
    PRIMARY KEY (id_viagem, fk_linha, fk_onibus),
    CONSTRAINT fk_viagem_linha FOREIGN KEY (fk_linha)
        REFERENCES linha(id_linha),
    CONSTRAINT fk_viagem_onibus FOREIGN KEY (fk_onibus)
        REFERENCES onibus(id_onibus)
);

CREATE TABLE sensor (
    id_sensor INT AUTO_INCREMENT,
    modelo VARCHAR(10),
    tipo_sensor VARCHAR(10),
    data_instalacao DATE,
    status_sensor VARCHAR(20) NOT NULL,
    fk_onibus INT NOT NULL,
    PRIMARY KEY (id_sensor, fk_onibus),
    CONSTRAINT ch_status_sensor CHECK (status_sensor IN ('Ativo', 'Manutencao', 'Desativado')),
    CONSTRAINT fk_sensor_onibus FOREIGN KEY (fk_onibus)
        REFERENCES onibus(id_onibus)
);

CREATE TABLE registro_sensor (
    id_registro INT AUTO_INCREMENT,
    movimento_entrada TINYINT NOT NULL,
    movimento_saida TINYINT,
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    fk_sensor INT NOT NULL,
    PRIMARY KEY (id_registro, fk_sensor),
    CONSTRAINT fk_registro_sensor FOREIGN KEY (fk_sensor)
		REFERENCES sensor(id_sensor)
);

INSERT INTO empresa (cnpj, codigo_verificacao, razao_social, nome_fantasia) VALUES
('00.000.000/0001-91', 'A7K9Q2', 'Mobi Brasil Mobilidade Urbana Ltda.', 'Mobi Brasil'),
('00.121.011/0041-31', 'M4X8P1', 'São Paulo Transporte S/A', 'SPTrans'),
('00.011.011/0011-11', 'R6T3Z9', 'Viação Mobi Rios S.A.', 'MobiRio'),
('12.713.901/1021-51', 'B2N7L5', 'Transcon Transportes e Concessões S.A.', 'TransCon');

-- A Ana (SPTrans) é cadastrada pelo administrador da própria SPTrans
INSERT INTO usuario (nome, email, senha, tipo_perfil, fk_empresa, fk_adm) VALUES
('João Pereira', 'joao@mobibrasil.com.br', 'Admin123', 'Administrador', 1, 1),
('Carlos Lima', 'carlos@sptrans.com.br', 'Admin456', 'Administrador', 2, 2),
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
INSERT INTO linha (codigo, nome, total_passageiros, regiao, fk_empresa) VALUES
('8144-22', 'Penha - Ipanema', 30, 'Intermunicipal', 1),
-- Linha 2 (32 passageiros / ônibus 2, capacidade 100 = 32%) -> Baixa ocupação
('607C-10', 'Jardim Miriam - Itaim Bibi', 32, 'Intermunicipal', 1),
-- Linha 3 (90 passageiros / ônibus 3, capacidade 120 = 75%) -> Atenção (60% a 85%)
('1721-10', 'Parque Edu Chaves - Metro', 90, 'Municipal', 2),
-- Linha 4 (105 passageiros / ônibus 4, capacidade 120 = 87.5%) -> Alta ocupação (> 85%)
('2019-AC', 'União - Serra', 105, 'Municipal', 2),
-- Linha 5 (110 passageiros / ônibus 5, capacidade 120 = 91.7%) -> Alta ocupação
('3016-21', 'Guaianases - Terminal', 110, 'Municipal', 2);


-- OPERAÇÕES (cada ônibus em uma linha da própria empresa)
INSERT INTO viagem (dt_viagem, fk_linha, fk_onibus) VALUES
('2026-09-28', 1, 1),
('2026-09-28', 2, 2),
('2026-09-28', 3, 3),
('2026-09-28', 4, 4),
('2026-09-28', 5, 5);

-- OPERAÇÕES DOS 7 DIAS ANTERIORES (21 a 27/09), usadas no comparativo histórico da KPI 4
-- Seg a sex (21 a 25): linhas 1, 2, 3 e 4 | Sáb e dom (26 e 27): linhas 1, 2 e 3
INSERT INTO viagem (dt_viagem, fk_linha, fk_onibus) VALUES
('2026-09-21', 1, 1), ('2026-09-21', 2, 2), ('2026-09-21', 3, 3), ('2026-09-21', 4, 4),
('2026-09-22', 1, 1), ('2026-09-22', 2, 2), ('2026-09-22', 3, 3), ('2026-09-22', 4, 4),
('2026-09-23', 1, 1), ('2026-09-23', 2, 2), ('2026-09-23', 3, 3), ('2026-09-23', 4, 4),
('2026-09-24', 1, 1), ('2026-09-24', 2, 2), ('2026-09-24', 3, 3), ('2026-09-24', 4, 4),
('2026-09-25', 1, 1), ('2026-09-25', 2, 2), ('2026-09-25', 3, 3), ('2026-09-25', 4, 4),
('2026-09-26', 1, 1), ('2026-09-26', 2, 2), ('2026-09-26', 3, 3),
('2026-09-27', 1, 1), ('2026-09-27', 2, 2), ('2026-09-27', 3, 3);


-- SENSORES
INSERT INTO sensor (modelo, data_instalacao, status_sensor, fk_onibus) VALUES
('HC-SR04', '2026-09-21', 'Ativo', 1),
('HC-SR04', '2026-09-21', 'Ativo', 2),
('HC-SR04', '2026-09-21', 'Ativo', 3),
('HC-SR04', '2026-09-21', 'Ativo', 4),
('HC-SR04', '2026-09-21', 'Ativo', 5);


-- REGISTROS DO SENSOR
INSERT INTO registro_sensor (movimento_entrada, data_hora, fk_sensor) VALUES
(1, '2026-09-28 07:10:00', 1),
(1, '2026-09-28 07:15:00', 2),
(1, '2026-09-28 07:20:00', 3),
(1, '2026-09-28 07:25:00', 4);


-- ====== VIEWs (KPI) ====== --

-- 1) Base das KPIs: ocupação de cada viagem finalizada (entradas - saídas no horário da viagem / capacidade)
--    periodo: 'atual' = últimas 4 semanas | 'anterior' = as 4 semanas antes | NULL = fora dos dois
CREATE VIEW vw_ocupacao_viagem AS
SELECT
    linha.fk_empresa,
    linha.regiao,
    linha.id_linha,
    linha.codigo AS 'linha',
    onibus.id_onibus,
    viagem.id_viagem,
    CASE
        WHEN viagem.dt_viagem BETWEEN CURDATE() - INTERVAL 28 DAY AND CURDATE() - INTERVAL 1 DAY THEN 'atual'
        WHEN viagem.dt_viagem BETWEEN CURDATE() - INTERVAL 56 DAY AND CURDATE() - INTERVAL 29 DAY THEN 'anterior'
    END AS 'periodo',
    onibus.capacidade_maxima AS 'capacidade',
    SUM(registro_sensor.movimento_entrada) - SUM(COALESCE(registro_sensor.movimento_saida, 0)) AS 'passageiros',
    ROUND((SUM(registro_sensor.movimento_entrada) - SUM(COALESCE(registro_sensor.movimento_saida, 0)))
          / onibus.capacidade_maxima * 100, 1) AS 'ocupacao'
FROM viagem
JOIN linha ON linha.id_linha = viagem.fk_linha
JOIN onibus ON onibus.id_onibus = viagem.fk_onibus
JOIN sensor ON sensor.fk_onibus = onibus.id_onibus
JOIN registro_sensor ON registro_sensor.fk_sensor = sensor.id_sensor
    AND registro_sensor.data_hora BETWEEN viagem.dt_hora_inicio AND viagem.dt_hora_fim
GROUP BY linha.fk_empresa, linha.regiao, linha.id_linha, linha.codigo, onibus.id_onibus,
         viagem.id_viagem, viagem.dt_viagem, onibus.capacidade_maxima;

-- 2) KPI 1: linhas candidatas a origem (cedem 1 ônibus) ou destino (recebem 1 ônibus), por período
CREATE VIEW vw_kpi_remanejamento AS
SELECT
    fk_empresa,
    regiao,
    periodo,
    linha,
    ROUND(SUM(passageiros) / SUM(capacidade) * 100, 1) AS 'ocupacao',
    COUNT(DISTINCT id_onibus) AS 'qtd_onibus',
    ROUND(SUM(passageiros) / SUM(capacidade) * 100 * COUNT(DISTINCT id_onibus) / (COUNT(DISTINCT id_onibus) - 1), 1) AS 'ocupacao_menos_1',
    ROUND(SUM(passageiros) / SUM(capacidade) * 100 * COUNT(DISTINCT id_onibus) / (COUNT(DISTINCT id_onibus) + 1), 1) AS 'ocupacao_mais_1',
    CASE WHEN SUM(passageiros) / SUM(capacidade) * 100 > 105 THEN 'Destino' ELSE 'Origem' END AS 'papel'
FROM vw_ocupacao_viagem
WHERE periodo IS NOT NULL
GROUP BY fk_empresa, regiao, periodo, id_linha, linha
HAVING ocupacao > 105 OR (ocupacao < 70 AND ocupacao_menos_1 <= 100);

-- 3) KPI 2: ocupação média de cada linha no período e se está fora da faixa adequada (70% a 100%)
CREATE VIEW vw_kpi_linhas_fora_faixa AS
SELECT
    fk_empresa,
    regiao,
    periodo,
    linha,
    ROUND(SUM(passageiros) / SUM(capacidade) * 100, 1) AS 'ocupacao',
    CASE
        WHEN ROUND(SUM(passageiros) / SUM(capacidade) * 100, 1) < 70
          OR ROUND(SUM(passageiros) / SUM(capacidade) * 100, 1) > 100 THEN 1
        ELSE 0
    END AS 'fora_faixa'
FROM vw_ocupacao_viagem
WHERE periodo IS NOT NULL
GROUP BY fk_empresa, regiao, periodo, id_linha, linha;

-- 4) KPI 3: cada viagem do período, marcada com 1 quando teve alerta (alta > 105% ou baixa < 70%)
CREATE VIEW vw_kpi_alertas_viagem AS
SELECT
    fk_empresa,
    regiao,
    periodo,
    linha,
    id_onibus,
    id_viagem,
    ocupacao,
    CASE WHEN ocupacao > 105 OR ocupacao < 70 THEN 1 ELSE 0 END AS 'alerta'
FROM vw_ocupacao_viagem
WHERE periodo IS NOT NULL;


-- ====== SIMULAÇÃO SENSOR ====== --

-- sensor 1: ocupação adequada
SELECT
    fk_sensor,
    SUM(movimento_entrada) AS entradas,
    SUM(movimento_saida) AS saidas,
    SUM(movimento_entrada) - SUM(movimento_saida) AS passageiros,
    ROUND(
        (SUM(movimento_entrada) - SUM(movimento_saida)) / 100 * 100, 1
    ) AS percentual_ocupacao
FROM registro_sensor
WHERE fk_sensor = 1
GROUP BY fk_sensor;

-- Sensor 2: alta ocupação
SELECT
    fk_sensor,
    SUM(movimento_entrada) AS entradas,
    SUM(movimento_saida) AS saidas,
    SUM(movimento_entrada) - SUM(movimento_saida) AS passageiros,
    ROUND(
        (SUM(movimento_entrada) - SUM(movimento_saida)) / 100 * 100, 1
    ) AS percentual_ocupacao
FROM registro_sensor
WHERE fk_sensor = 2
GROUP BY fk_sensor;

-- sensor 3: baixa ocupação
SELECT
    fk_sensor,
    SUM(movimento_entrada) AS entradas,
    SUM(movimento_saida) AS saidas,
    SUM(movimento_entrada) - SUM(movimento_saida) AS passageiros,
    ROUND(
        (SUM(movimento_entrada) - SUM(movimento_saida)) / 100 * 100, 1
    ) AS percentual_ocupacao
FROM registro_sensor
WHERE fk_sensor = 3
GROUP BY fk_sensor;