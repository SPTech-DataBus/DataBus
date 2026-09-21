CREATE DATABASE DataBus;

USE DataBus;

-- Criação das tabelas, simbolizam personas e processos do sistema
CREATE TABLE empresa (
id_empresa INT PRIMARY KEY AUTO_INCREMENT,
razao_social VARCHAR(100) NOT NULL,
nome_fantasia VARCHAR(60) NOT NULL,
cnpj CHAR(18) NOT NULL UNIQUE,
abrangencia_local VARCHAR(40) 
CONSTRAINT chLocal CHECK(abrangencia_local IN('Intermunicipal', 'Municipal')),
email VARCHAR(100) NOT NULL UNIQUE,
telefone CHAR(15) NOT NULL UNIQUE
);

CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(100) NOT NULL,
    tipo_perfil VARCHAR(40) NOT NULL,
    CONSTRAINT chTipo CHECK(tipo_perfil IN('Administrador','Operador')),
    id_empresa INT, 
    FOREIGN KEY (id_empresa) REFERENCES empresa(id_empresa)
);

CREATE TABLE linha( -- Representa dados de todos os ônibus de uma linha
id_linha INT PRIMARY KEY AUTO_INCREMENT,
codigo CHAR(7) NOT NULL,
nome VARCHAR(100) NOT NULL,
passageiros_total INT DEFAULT 0,
passageiros_manha INT DEFAULT 0,
passageiros_tarde INT DEFAULT 0,
passageiros_noite INT DEFAULT 0,
tarifa DECIMAL(4,2),
valor_total DECIMAL(10,2)
        AS (passageiros_total * tarifa),
fk_empresa INT NOT NULL, FOREIGN KEY (fk_empresa)
REFERENCES empresa(id_empresa)
);

CREATE TABLE onibus_tempo_real( -- Para monitoramento constante
id_onibus_tempo_real INT PRIMARY KEY AUTO_INCREMENT ,
placa CHAR(7) NOT NULL UNIQUE,
codigo_linha VARCHAR(35) NOT NULL,
nome_linha VARCHAR(30),
passageiros INT DEFAULT 0 NOT NULL,
capacidade_maxima INT NOT NULL,
tarifa DECIMAL(4,2),
fk_linha INT NOT NULL, FOREIGN KEY (fk_linha)
REFERENCES linha(id_linha)
);

CREATE TABLE onibus_relatorio_diario( -- Para monitoramento temporizado (p/ dia)
id_onibus_relat_diario INT PRIMARY KEY AUTO_INCREMENT,
placa CHAR(7) NOT NULL UNIQUE,
codigo_linha CHAR(7) NOT NULL,
nome_linha VARCHAR(35) NOT NULL,
viagens INT NOT NULL,
horario_rodando CHAR(13) NOT NULL,
total_passageiros INT DEFAULT 0 NOT NULL,
tarifa DECIMAL(4,2),
valor_total DECIMAL(10,2)
	AS (total_passageiros * tarifa),
fk_linha INT NOT NULL, FOREIGN KEY(fk_linha)
REFERENCES linha(id_linha)
 );

CREATE TABLE registro_sensor ( -- Trata do dado de entrada ou saída de um ônibus
id_regis_sensor INT PRIMARY KEY AUTO_INCREMENT,
tipo_dado TINYINT NOT NULL, -- 0 para saídas e 1 para entradas
horario_data DATETIME DEFAULT CURRENT_TIMESTAMP,
CONSTRAINT chTipoDado CHECK(tipo_dado IN(0, 1)),
fk_placa CHAR(7) NOT NULL, FOREIGN KEY(fk_placa)
REFERENCES onibus_tempo_real(placa)
); 



-- Inserção de dados fictícios nas tabelas
INSERT INTO empresa 
(cnpj, razao_social, nome_fantasia, email, abrangencia_local, telefone) VALUES
('00.000.000/0001-91', 'Mobi Brasil Mobilidade Urbana Ltda.', 'Mobi Brasil', 'mobi@email.com', 'Intermunicipal', '(11) 98765-4321'),
('00.121.011/0041-31', 'São Paulo Transporte S/A', 'SPTrans', 'sptrans@email.com', 'Municipal', '(11) 98765-4320'),
('00.011.011/0011-11', 'Viação Mobi Rios S.A.', 'MobiRio', 'mobirio@email.com', 'Municipal', '(21) 98765-1520'),
('12.713.901/1021-51', 'Transcon Transportes e Concessões S.A.', 'Transcon', 'transcon@email.com', 'Intermunicipal', '(31) 98325-4320');

-- 2. Linhas (adicionado o campo fk_empresa apontando para os IDs das empresas acima: 1, 2, 3, 4)
INSERT INTO linha
(codigo, nome, passageiros_total, passageiros_manha, passageiros_tarde, passageiros_noite, tarifa, fk_empresa) VALUES
('607C-10', 'Jardim Miriam - Itaim Bibi', 8000, 3000, 3200, 1800, 5.30, 1),
('5106-10', 'Mar Paulista - São Francisco', 6000, 2200, 2500, 1300, 5.30, 2),
('483', 'Penha - Ipanema', 3500, 1300, 1400, 800, 5.00, 3),
('8150', 'União - Serra', 4000, 1500, 1600, 900, 6.25, 4);

-- 3. Ônibus Tempo Real (adicionado o campo fk_linha apontando para os IDs das linhas acima: 1, 2, 3, 4)
INSERT INTO onibus_tempo_real 
(placa, codigo_linha, nome_linha, passageiros, capacidade_maxima, tarifa, fk_linha) VALUES
('ABC1134', '607C-10', 'Jardim Miriam - Itaim Bibi', 110, 120, 5.30, 1),
('CBA1234', '5106-10', 'Mar Paulista - São Francisco', 80, 120, 5.30, 2),
('JCC3412', '483 - Penha', 'Penha - Ipanema', 33, 80, 5.30, 3),
('LEO6671', '8150 - União', ' União - Serra', 60, 80, 5.30, 4);

-- 4. Ônibus Relatório Diário (adicionado o campo fk_linha: 1, 2, 3, 4)
INSERT INTO onibus_relatorio_diario
(placa, codigo_linha, nome_linha, viagens, horario_rodando, total_passageiros, tarifa, fk_linha) VALUES
('ABC1134', '607C-10', 'Jardim Miriam - Itaim Bibi', 12, '08:30 - 18:30', 8000, 5.30, 1),
('CBA1234', '5106-10', 'Mar Paulista - São Francisco', 10, '09:00 - 19:00', 6000, 5.30, 2),
('JCC3412', '483', 'Penha - Ipanema', 10, '10:00 - 18:00', 3500, 5.00, 3),
('LEO6671', '8150', 'União - Serra', 12, '07:30 - 17:30', 4000, 6.25, 4);

-- 5. Registro do Sensor (Executado por último, pois as placas 'ABC1134', 'CBA1234', etc., já existem)
INSERT INTO registro_sensor (fk_placa, tipo_dado) VALUES
('ABC1134', 0),
('CBA1234', 1),
('JCC3412', 1),
('LEO6671', 0);

SELECT 
    otr.placa AS 'Placa do Ônibus',
    l.codigo AS 'Código da Linha',
    l.nome AS 'Nome da Linha',
    e.nome_fantasia AS 'Empresa Responsável',
    otr.passageiros AS 'Passageiros Atuais'
FROM onibus_tempo_real otr
JOIN linha l ON otr.fk_linha = l.id_linha
JOIN empresa e ON l.fk_empresa = e.id_empresa;


-- Apresentação de registros de empresas no sistema
SELECT * FROM empresa;
-- Apresentação de registros de entrada e saída passageiros
SELECT * FROM registro_sensor;
-- Apresentação de registros de ocupação em tempo real dos ônibus
 SELECT * from onibus_tempo_real;
-- Apresentação de registros de todas as entradas diárias no ônibus
SELECT * FROM onibus_relatorio_diario;
-- Apresentação de registros da linha
SELECT * FROM linha;


-- Apresentação formatada das empresas no sistema
SELECT
 cnpj AS 'Cnpj',
 nome_fantasia AS 'Nome da Empresa',
 email AS 'E-mail',
 abrangencia_local AS 'Região',
 telefone AS 'Telefone para Contato'
FROM empresa;

-- Apresentação formatada dos registros de entrada e saída passageiros
SELECT 
 id_regis_sensor AS 'Identificação (ID)',
 CASE
        WHEN tipo_dado = 0 THEN 'Saída'
        ELSE 'Entrada'
 END AS 'Tipo de registro',
 fk_placa AS 'Placa',
  DATE_FORMAT(horario_data, '%d/%m/%Y %H:%m:%s')AS 'Data e hora'
FROM registro_sensor;

 -- Apresentação formatada da ocupação em tempo real dos ônibus
 SELECT
  placa AS 'Placa',
  codigo_linha AS 'Cód. da Linha',
  nome_linha AS 'Nome da Linha',
  passageiros AS 'Quantidade de Passageiros',
  capacidade_maxima AS 'Capacidade Máxima',
  CONCAT('R$', tarifa) AS 'Valor da Tarifa'
 FROM onibus_tempo_real;
 
 -- Apresentação formatada de todas as entradas diárias no ônibus
SELECT
 placa AS 'Placa',
 codigo_linha AS 'Cód. da Linha',
 viagens AS 'Quantidade de Viagens',
 horario_rodando AS 'Horário de Ronda',
 total_passageiros AS 'Total de Passageiros',
 CONCAT('R$', tarifa) AS 'Valor da Tarifa',
 CONCAT('R$', valor_total) AS 'Valor Arrecadado'
FROM onibus_relatorio_diario;

-- Apresentação formatada de todas as entradas das linhas.
SELECT 
 codigo AS 'Código',
 nome AS 'Nome da Linha',
 passageiros_total AS 'Total de Passageiros',
 passageiros_manha AS 'Passageiros - 04:30 - 12:00',
 passageiros_tarde AS 'Passageiros - 12:00 - 18:00',
 passageiros_noite AS 'Passageiros - 18:00 - 00:00',
 CONCAT('R$', tarifa) AS 'Valor da Tarifa',
 CONCAT('R$', valor_total) AS 'Valor Arrecadado' 
FROM linha;