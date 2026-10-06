CREATE DATABASE DataBus;

USE DataBus;

-- CRIAÇÃO DAS TABELAS --

-- EMPRESA --

CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    cnpj CHAR(18) NOT NULL UNIQUE,
    codigo_verificacao CHAR(6) UNIQUE NOT NULL,
    razao_social VARCHAR(100) NOT NULL,
    nome_fantasia VARCHAR(60) NOT NULL,
    regiao VARCHAR(40),
    CONSTRAINT ch_local CHECK (regiao IN ('Intermunicipal', 'Municipal'))
);

SELECT * FROM empresa;

-- REPRESENTANTE DA EMPRESA --

CREATE TABLE representante_empresa (
    id_representante INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(14) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    fk_empresa INT NOT NULL,
    CONSTRAINT fk_empresa_representante FOREIGN KEY (fk_empresa) REFERENCES empresa(id_empresa)
);

SELECT * FROM representante_empresa;

-- USUÁRIO --

CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(100) NOT NULL,
    tipo_perfil VARCHAR(40) NOT NULL,
    CONSTRAINT ch_tipo CHECK (tipo_perfil IN ('Administrador', 'Operador')), -- VERIFICAR SE É NECESSÁRIO O 'tipo'
    fk_adm INT,
    fk_empresa INT NOT NULL,
    CONSTRAINT fk_empresa_usuario FOREIGN KEY (fk_empresa) REFERENCES empresa(id_empresa),
    CONSTRAINT fk_usuario_adm FOREIGN KEY (fk_adm) REFERENCES usuario(id_usuario)
);

SELECT * FROM usuario;

-- LINHA --

CREATE TABLE linha (
    id_linha INT PRIMARY KEY AUTO_INCREMENT,
    codigo CHAR(7) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    tarifa DECIMAL(5,2) NOT NULL,
    fk_empresa INT NOT NULL,
    CONSTRAINT fk_linha_empresa FOREIGN KEY (fk_empresa) REFERENCES empresa(id_empresa)
);

SELECT * FROM linha;

-- ÔNIBUS --

CREATE TABLE onibus (
    id_onibus INT PRIMARY KEY AUTO_INCREMENT,
    placa CHAR(7) NOT NULL UNIQUE,
    capacidade_maxima INT NOT NULL,
    status_onibus VARCHAR(20) NOT NULL,
    fk_empresa INT,
    CONSTRAINT fk_empresa_onibus FOREIGN KEY (fk_empresa) REFERENCES empresa (id_empresa),
    CONSTRAINT ch_status_onibus CHECK (status_onibus IN ('Ativo', 'Manutenção', 'Desativado'))
);

SELECT * FROM onibus;

-- VIAGEM --

CREATE TABLE viagem (
	id_viagem INT PRIMARY KEY AUTO_INCREMENT,
    data_hora_inicio DATETIME NOT NULL,
    data_hora_fim DATETIME NOT NULL,
    fk_onibus INT NOT NULL,
    fk_linha INT NOT NULL,
    CONSTRAINT fk_onibus_viagem FOREIGN KEY (fk_onibus) REFERENCES onibus(id_onibus),
    CONSTRAINT fk_linha_viagem FOREIGN KEY (fk_linha) REFERENCES linha(id_linha)
);

SELECT * FROM viagem;

-- SENSOR --

CREATE TABLE sensor (
    id_sensor INT PRIMARY KEY AUTO_INCREMENT,
    modelo VARCHAR(20),
    data_instalacao DATE,
    status_sensor VARCHAR(20) NOT NULL,
    fk_onibus INT NOT NULL,
    CONSTRAINT ch_status_sensor CHECK (status_sensor IN ('Ativo', 'Manutencao', 'Desativado')),
    CONSTRAINT fk_sensor_onibus FOREIGN KEY (fk_onibus) REFERENCES onibus(id_onibus)
);

SELECT * FROM sensor;

-- REGISTRO DO SENSOR --

CREATE TABLE registro_sensor (
    id_registro INT PRIMARY KEY AUTO_INCREMENT,
    tipo_movimento TINYINT NOT NULL,
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    passageiros_atual INT DEFAULT 0,
    fk_sensor INT NOT NULL,
    CONSTRAINT ch_tipo_movimento CHECK (tipo_movimento IN (0,1)),
    CONSTRAINT fk_registro_onibus FOREIGN KEY (fk_sensor) REFERENCES sensor(id_sensor)
);

SELECT * FROM registro_sensor;


-- INSERÇÃO DE DADOS --

INSERT INTO empresa (cnpj, codigo_verificacao, razao_social, nome_fantasia, regiao) VALUES
	('00.000.000/0001-91', 'A7K9Q2', 'Mobi Brasil Mobilidade Urbana Ltda.', 'Mobi Brasil', 'Intermunicipal'),
	('00.121.011/0041-31', 'M4X8P1', 'São Paulo Transporte S/A', 'SPTrans', 'Municipal'),
	('00.011.011/0011-11', 'R6T3Z9', 'Viação Mobi Rios S.A.', 'MobiRio', 'Municipal'),
	('12.713.901/1021-51', 'B2N7L5', 'Transcon Transportes e Concessões S.A.', 'TransCon', 'Intermunicipal');
    
INSERT INTO representante_empresa (nome, cpf, email, fk_empresa) VALUES
    ('Carlos Eduardo Silva', '123.456.789-01', 'carlos.silva@mobibrasil.com.br', 1),
    ('Mariana Alves Santos', '234.567.890-12', 'mariana.santos@sptrans.com.br', 2),
    ('Rafael Oliveira Costa', '345.678.901-23', 'rafael.costa@mobirio.com.br', 3),
    ('Fernanda Martins Souza', '456.789.012-34', 'fernanda.souza@transcon.com.br', 4);

INSERT INTO usuario (nome, email, senha, tipo_perfil, fk_adm, fk_empresa) VALUES
    ('João Pereira', 'joao@mobibrasil.com.br', 'Admin123', 'Administrador', NULL, 1),
    ('Lucas Almeida', 'lucas@mobibrasil.com.br', 'Operador123', 'Operador', 1, 1),
    ('Ana Souza', 'ana@sptrans.com.br', 'Operador456', 'Operador', 1, 2),
    ('Pedro Costa', 'pedro@mobirio.com.br', 'Operador789', 'Operador', 1, 3);

INSERT INTO linha (codigo, nome, tarifa, fk_empresa) VALUES
	('607C-10', 'Jardim Miriam - Itaim Bibi', 5.30, 1),
	('5106-10', 'Mar Paulista - São Francisco', 5.30, 2),
	('8144-22', 'Penha - Ipanema', 5.00, 3),
	('2019-AC', 'União - Serra', 6.25, 4);

INSERT INTO onibus (placa, capacidade_maxima, status_onibus) VALUES
	('ABC1134', 120, 'Ativo'),
	('CBA1234', 120, 'Ativo'),
	('JCC3412', 80, 'Desativado'),
	('LEO6671', 80, 'Manutenção');
    
INSERT INTO viagem (data_hora_inicio, data_hora_fim, fk_onibus, fk_linha) VALUES
    ('2026-09-28 06:00:00', '2026-09-28 07:30:00', 1, 1),
    ('2026-09-28 08:00:00', '2026-09-28 09:30:00', 2, 2),
    ('2026-09-28 10:00:00', '2026-09-28 11:30:00', 3, 3),
    ('2026-09-28 14:00:00', '2026-09-28 15:30:00', 4, 4);

INSERT INTO sensor (modelo, data_instalacao, status_sensor, fk_onibus) VALUES
	('HC-SR04', '2026-09-21', 'Ativo', 1),
	('HC-SR04', '2026-09-21', 'Ativo', 2),
	('HC-SR04', '2026-09-21', 'Ativo', 3),
	('HC-SR04', '2026-09-21', 'Ativo', 4);

INSERT INTO registro_sensor (tipo_movimento, data_hora, passageiros_atual, fk_sensor, fk_onibus) VALUES
	(0, '2026-09-21 20:15:30', 80, 1, 1),
	(1, '2026-09-21 20:16:30', 80, 2, 2),
	(0, '2026-09-21 20:17:30', 100, 3, 3),
	(1, '2026-09-21 20:18:30', 100, 4, 4);


-- CONSULTA DE DADOS --

SELECT 
    registro_sensor.id_registro 'ID',
    CASE
        WHEN registro_sensor.tipo_movimento = 0 THEN 'Entrada'
        ELSE 'Saída'
    END 'Tipo de registro',
    onibus.placa 'Placa',
    DATE_FORMAT(registro_sensor.data_hora, '%d/%m/%Y %H:%i:%s') 'Data e hora'
FROM registro_sensor
JOIN sensor ON registro_sensor.fk_sensor = sensor.id_sensor
JOIN onibus ON sensor.fk_onibus = onibus.id_onibus;


SELECT
    linha.codigo 'Código da linha',
    linha.nome 'Linha',
    onibus.placa 'Placa',
    onibus.capacidade_maxima 'Capacidade máxima',
    registro_sensor.passageiros_atual 'Passageiros atuais',
    CASE
        WHEN registro_sensor.passageiros_atual < 40 THEN 'Baixa ocupação'
        WHEN registro_sensor.passageiros_atual < 70 THEN 'Ocupação média'
        ELSE 'Alta ocupação'
    END 'Situação'
FROM registro_sensor
JOIN onibus ON registro_sensor.fk_onibus = onibus.id_onibus
JOIN viagem ON onibus.id_onibus = viagem.fk_onibus
JOIN linha ON viagem.fk_linha = linha.id_linha;


SELECT
    CONCAT(
        empresa.nome_fantasia,
        ' - Linha ', linha.codigo,
        ' - Tarifa R$ ', linha.tarifa
    ) 'Informações da linha'
FROM empresa
JOIN linha ON empresa.id_empresa = linha.fk_empresa;


SELECT
    CONCAT(
        'Ônibus ', onibus.placa,
        ' - Linha ', linha.codigo,
        ' - ', registro_sensor.passageiros_atual,
        ' passageiros'
    ) AS 'Resumo da ocupação'
FROM registro_sensor
JOIN onibus ON registro_sensor.fk_onibus = onibus.id_onibus
JOIN viagem ON onibus.id_onibus = viagem.fk_onibus
JOIN linha ON viagem.fk_linha = linha.id_linha;


SELECT
    CONCAT(
        'Ônibus ', onibus.placa,
        ' | Linha ', linha.codigo,
        ' - ', linha.nome,
        ' | Passageiros: ', registro_sensor.passageiros_atual,
        ' de ', onibus.capacidade_maxima,
        ' | Situação: ',
        CASE
            WHEN registro_sensor.passageiros_atual < 40 THEN 'Baixa ocupação'
            WHEN registro_sensor.passageiros_atual < 70 THEN 'Ocupação média'
            ELSE 'Alta ocupação'
        END
    ) AS 'Resumo Operacional'
FROM registro_sensor
JOIN onibus ON registro_sensor.fk_onibus = onibus.id_onibus
JOIN viagem ON onibus.id_onibus = viagem.fk_onibus
JOIN linha ON viagem.fk_linha = linha.id_linha;


SELECT
    linha.codigo AS 'Linha',
    linha.nome AS 'Nome da linha',
    onibus.placa AS 'Ônibus',
    registro_sensor.passageiros_atual AS 'Passageiros atuais',
    linha.tarifa AS 'Tarifa',
    registro_sensor.passageiros_atual * linha.tarifa AS 'Valor total estimado'
FROM registro_sensor
JOIN onibus ON registro_sensor.fk_onibus = onibus.id_onibus
JOIN viagem ON onibus.id_onibus = viagem.fk_onibus
JOIN linha ON viagem.fk_linha = linha.id_linha;