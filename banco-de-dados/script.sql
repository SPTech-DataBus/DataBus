CREATE DATABASE DataBus;

USE DataBus;

-- Criação das tabelas
CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    razao_social VARCHAR(100) NOT NULL,
    nome_fantasia VARCHAR(60) NOT NULL,
    cnpj CHAR(18) NOT NULL UNIQUE,
    abrangencia_local VARCHAR(40),
    CONSTRAINT chLocal CHECK (
        abrangencia_local IN ('Intermunicipal', 'Municipal')
    ),
    email VARCHAR(100) NOT NULL UNIQUE,
    telefone CHAR(15) NOT NULL UNIQUE
);

CREATE TABLE representante_empresa (
    id_representante INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(14) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    fk_empresa INT NOT NULL,
    FOREIGN KEY (fk_empresa)
        REFERENCES empresa(id_empresa)
);

CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(100) NOT NULL,
    tipo_perfil VARCHAR(40) NOT NULL,
    CONSTRAINT chTipo CHECK (
        tipo_perfil IN ('Administrador', 'Operador')
    ),
    fk_empresa INT NOT NULL,
    FOREIGN KEY (fk_empresa)
        REFERENCES empresa(id_empresa)
);

CREATE TABLE linha (
    id_linha INT PRIMARY KEY AUTO_INCREMENT,
    codigo CHAR(7) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    tarifa DECIMAL(5,2) NOT NULL,
    fk_empresa INT NOT NULL,
    FOREIGN KEY (fk_empresa)
        REFERENCES empresa(id_empresa)
);

CREATE TABLE onibus (
    id_onibus INT PRIMARY KEY AUTO_INCREMENT,
    placa CHAR(7) NOT NULL UNIQUE,
    capacidade_maxima INT NOT NULL,
    passageiros_atual INT DEFAULT 0,
    fk_linha INT NOT NULL,
    FOREIGN KEY (fk_linha)
        REFERENCES linha(id_linha)
);

CREATE TABLE sensor (
    id_sensor INT PRIMARY KEY AUTO_INCREMENT,
    data_instalacao DATE,
    status_sensor VARCHAR(20) NOT NULL,
    fk_onibus INT NOT NULL,
    CONSTRAINT chStatusSensor CHECK (
        status_sensor IN ('Ativo', 'Manutencao', 'Desativado')
    ),
    FOREIGN KEY (fk_onibus)
        REFERENCES onibus(id_onibus)
);

CREATE TABLE registro_sensor (
    id_registro INT PRIMARY KEY AUTO_INCREMENT,
    tipo_dado TINYINT NOT NULL,
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    fk_sensor INT NOT NULL,
    CONSTRAINT chTipoDado CHECK (
        tipo_dado IN (0,1)
    ),
    FOREIGN KEY (fk_sensor)
        REFERENCES sensor(id_sensor)
);
/* 0 = entrada e 1 = saída */

CREATE TABLE relatorio_diario (
    id_relatorio INT PRIMARY KEY AUTO_INCREMENT,
    data_relatorio DATE NOT NULL,
    horario_inicio TIME NOT NULL,
    horario_fim TIME NOT NULL,
    total_passageiros INT DEFAULT 0,
    passageiros_manha INT DEFAULT 0,
    passageiros_tarde INT DEFAULT 0,
    passageiros_noite INT DEFAULT 0,
    viagens INT DEFAULT 0,
    fk_onibus INT NOT NULL,
    FOREIGN KEY (fk_onibus)
        REFERENCES onibus(id_onibus)
);


-- Inserção de dados fictícios nas tabelas

INSERT INTO empresa
(cnpj, razao_social, nome_fantasia, email, abrangencia_local, telefone) VALUES
('00.000.000/0001-91', 'Mobi Brasil Mobilidade Urbana Ltda.', 'Mobi Brasil', 'mobi@email.com', 'Intermunicipal', '(11) 98765-4321'),
('00.121.011/0041-31', 'São Paulo Transporte S/A', 'SPTrans', 'sptrans@email.com', 'Municipal', '(11) 98765-4320'),
('00.011.011/0011-11', 'Viação Mobi Rios S.A.', 'MobiRio', 'mobirio@email.com', 'Municipal', '(21) 98765-1520'),
('12.713.901/1021-51', 'Transcon Transportes e Concessões S.A.', 'Transcon', 'transcon@email.com', 'Intermunicipal', '(31) 98325-4320');


INSERT INTO linha
(codigo, nome, tarifa, fk_empresa) VALUES
('607C-10', 'Jardim Miriam - Itaim Bibi', 5.30, 1),
('5106-10', 'Mar Paulista - São Francisco', 5.30, 2),
('483', 'Penha - Ipanema', 5.00, 3),
('8150', 'União - Serra', 6.25, 4);


INSERT INTO onibus
(placa, capacidade_maxima, passageiros_atual, fk_linha) VALUES
('ABC1134', 120, 110, 1),
('CBA1234', 120, 80, 2),
('JCC3412', 80, 33, 3),
('LEO6671', 80, 60, 4);


INSERT INTO relatorio_diario
(data_relatorio, horario_inicio, horario_fim, total_passageiros,
 passageiros_manha, passageiros_tarde, passageiros_noite,
 viagens, fk_onibus) VALUES
('2026-09-21', '08:30:00', '18:30:00', 8000, 3000, 3200, 1800, 12, 1),
('2026-09-21', '09:00:00', '19:00:00', 6000, 2200, 2500, 1300, 10, 2),
('2026-09-21', '10:00:00', '18:00:00', 3500, 1300, 1400, 800, 10, 3),
('2026-09-21', '07:30:00', '17:30:00', 4000, 1500, 1600, 900, 12, 4);

INSERT INTO sensor
(data_instalacao, status_sensor, fk_onibus) VALUES
('2026-09-21', 'Ativo', 1),
('2026-09-21', 'Ativo', 2),
('2026-09-21', 'Ativo', 3),
('2026-09-21', 'Ativo', 4);


INSERT INTO registro_sensor
(fk_sensor, tipo_dado) VALUES
(1, 0),
(2, 1),
(3, 1),
(4, 0);

SELECT 
    o.placa AS 'Placa do Ônibus',
    l.codigo AS 'Código da Linha',
    l.nome AS 'Nome da Linha',
    e.nome_fantasia AS 'Empresa Responsável',
    o.passageiros_atual AS 'Passageiros Atuais'
FROM onibus AS o
JOIN linha AS l ON o.fk_linha = l.id_linha
JOIN empresa AS e ON l.fk_empresa = e.id_empresa;

-- Apresentação de registros de empresas no sistema
SELECT * FROM empresa;

-- Apresentação dos sensores cadastrados
SELECT * FROM sensor;

-- Apresentação de registros de entrada e saída de passageiros
SELECT * FROM registro_sensor;

-- Apresentação da ocupação atual dos ônibus
SELECT * FROM onibus;

-- Apresentação dos relatórios diários
SELECT * FROM relatorio_diario;

-- Apresentação das linhas
SELECT * FROM linha;

-- Apresentação formatada das empresas no sistema
SELECT
    cnpj AS 'Cnpj',
    nome_fantasia AS 'Nome da Empresa',
    email AS 'E-mail',
    abrangencia_local AS 'Região',
    telefone AS 'Telefone para Contato'
FROM empresa;

-- Apresentação formatada dos registros de entrada e saída de passageiros
SELECT 
    rs.id_registro AS 'Identificação (ID)',
    CASE
        WHEN rs.tipo_dado = 0 THEN 'Entrada'
        ELSE 'Saída'
    END AS 'Tipo de registro',
    o.placa AS 'Placa',
    DATE_FORMAT(rs.data_hora, '%d/%m/%Y %H:%i:%s') AS 'Data e hora'
FROM registro_sensor AS rs
JOIN sensor AS s ON rs.fk_sensor = s.id_sensor
JOIN onibus AS o ON s.fk_onibus = o.id_onibus;


-- Apresentação formatada da ocupação em tempo real dos ônibus
SELECT
    o.placa AS 'Placa',
    l.codigo AS 'Cód. da Linha',
    l.nome AS 'Nome da Linha',
    o.passageiros_atual AS 'Quantidade de Passageiros',
    o.capacidade_maxima AS 'Capacidade Máxima',
    CONCAT('R$', l.tarifa) AS 'Valor da Tarifa'
FROM onibus AS o
JOIN linha AS l ON o.fk_linha = l.id_linha;


-- Apresentação formatada do relatório diário dos ônibus
SELECT
    o.placa AS 'Placa',
    l.codigo AS 'Cód. da Linha',
    rd.viagens AS 'Quantidade de Viagens',
    rd.horario_inicio AS 'Horário de Início',
    rd.horario_fim AS 'Horário de Fim',
    rd.total_passageiros AS 'Total de Passageiros',
    CONCAT('R$', l.tarifa) AS 'Valor da Tarifa',
    CONCAT('R$', rd.total_passageiros * l.tarifa) AS 'Valor Arrecadado'
FROM relatorio_diario AS rd
JOIN onibus AS o ON rd.fk_onibus = o.id_onibus
JOIN linha AS l ON o.fk_linha = l.id_linha;


-- Apresentação formatada dos dados das linhas
SELECT 
    l.codigo AS 'Código',
    l.nome AS 'Nome da Linha',
    CONCAT('R$', l.tarifa) AS 'Valor da Tarifa'
FROM linha AS l;

SELECT 
    l.codigo AS 'Código',
    l.nome AS 'Nome da Linha',
    rd.data_relatorio AS 'Data',
    rd.total_passageiros AS 'Total de Passageiros',
    rd.passageiros_manha AS 'Passageiros - Manhã',
    rd.passageiros_tarde AS 'Passageiros - Tarde',
    rd.passageiros_noite AS 'Passageiros - Noite',
    CONCAT('R$', l.tarifa) AS 'Valor da Tarifa',
    CONCAT('R$', rd.total_passageiros * l.tarifa) AS 'Valor Arrecadado'
FROM relatorio_diario AS rd
JOIN onibus AS o ON rd.fk_onibus = o.id_onibus
JOIN linha AS l ON o.fk_linha = l.id_linha;











