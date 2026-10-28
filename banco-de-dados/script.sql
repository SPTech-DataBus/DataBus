CREATE DATABASE DataBus;
USE DataBus;

-- EMPRESA --

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


-- USUÁRIO --

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


-- LINHA --

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


-- ÔNIBUS --

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


-- OPERAÇÃO --

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


-- SENSOR --

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


-- REGISTRO DO SENSOR --

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

