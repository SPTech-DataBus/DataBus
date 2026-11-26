// Importa as bibliotecas necessárias
const serialport = require('serialport');
const express = require('express');
const mysql = require('mysql2');

// Constantes para configurações
const SERIAL_BAUD_RATE = 9600;
const SERVIDOR_PORTA = 3300;

// Habilita ou desabilita a inserção de dados no banco de dados
const HABILITAR_OPERACAO_INSERIR = true;

// Identificação dos sensores
const SENSOR_ADEQUADO = 1;
const SENSOR_ALTA = 2;
const SENSOR_BAIXA = 3;

// Identificação dos movimentos
const ENTRADA = 1;
const SAIDA = 2;

// Quantidade inicial de passageiros em cada cenário
let passageirosAdequado = 40;
let passageirosAlta = 80;
let passageirosBaixa = 28;

// SIMULAÇÃO 1 - BAIXA OCUPAÇÃO

async function simularBaixaOcupacao(movimento, poolBancoDados) {

    // Simula a entrada de 1 passageiro
    if (movimento == ENTRADA) {

        if (passageirosBaixa < 45) {

            await poolBancoDados.execute(
                'INSERT INTO registro_sensor (movimento_entrada, movimento_saida, fk_sensor) VALUES (?, ?, ?)',
                [1, 0, SENSOR_BAIXA]
            );

            passageirosBaixa++;
        }
    }

    // Simula a saída de até 3 passageiros
    if (movimento == SAIDA) {

        for (let i = 0; i < 3; i++) {

            if (passageirosBaixa > 25) {

                await poolBancoDados.execute(
                    'INSERT INTO registro_sensor (movimento_entrada, movimento_saida, fk_sensor) VALUES (?, ?, ?)',
                    [0, 1, SENSOR_BAIXA]
                );

                passageirosBaixa--;
            }
        }
    }

    console.log('Baixa ocupação:', passageirosBaixa);
}

// SIMULAÇÃO 2 - OCUPAÇÃO ADEQUADA

async function simularOcupacaoAdequada(movimento, poolBancoDados) {

    // Simula a entrada de até 3 passageiros
    if (movimento == ENTRADA) {

        for (let i = 0; i < 2; i++) {

            if (passageirosAdequado < 95) {

                await poolBancoDados.execute(
                    'INSERT INTO registro_sensor (movimento_entrada, movimento_saida, fk_sensor) VALUES (?, ?, ?)',
                    [1, 0, SENSOR_ADEQUADO]
                );

                passageirosAdequado++;
            }
        }
    }

    // Simula a saída de até 2 passageiros
    if (movimento == SAIDA) {

        for (let i = 0; i < 2; i++) {

            if (passageirosAdequado > 75) {

                await poolBancoDados.execute(
                    'INSERT INTO registro_sensor (movimento_entrada, movimento_saida, fk_sensor) VALUES (?, ?, ?)',
                    [0, 1, SENSOR_ADEQUADO]
                );

                passageirosAdequado--;
            }
        }
    }

    console.log('Ocupação adequada:', passageirosAdequado);
}

// SIMULAÇÃO 3 - ALTA OCUPAÇÃO

async function simularAltaOcupacao(movimento, poolBancoDados) {

    // Simula a entrada de até 5 passageiros
    if (movimento == ENTRADA) {

        for (let i = 0; i < 3; i++) {

            if (passageirosAlta < 115) {

                await poolBancoDados.execute(
                    'INSERT INTO registro_sensor (movimento_entrada, movimento_saida, fk_sensor) VALUES (?, ?, ?)',
                    [1, 0, SENSOR_ALTA]
                );

                passageirosAlta++;
            }
        }
    }

    // Simula a saída de 1 passageiro
    if (movimento == SAIDA) {

        if (passageirosAlta > 95) {

            await poolBancoDados.execute(
                'INSERT INTO registro_sensor (movimento_entrada, movimento_saida, fk_sensor) VALUES (?, ?, ?)',
                [0, 1, SENSOR_ALTA]
            );

            passageirosAlta--;
        }
    }

    console.log('Cenário de alta ocupação:', passageirosAlta);
}

const serial = async (valoresSensorDigital) => {

    // Conexão com o banco de dados MySQL
    let poolBancoDados = mysql.createPool(
        {
            host: 'localhost',
            user: 'userDataBus',
            password: 'Data#123',
            database: 'DataBus',
            port: 3307
        }
    ).promise();

    // Lista as portas seriais disponíveis
    const portas = await serialport.SerialPort.list();

    // Procura pelo Arduino
    const portaArduino = portas.find(
        (porta) => porta.vendorId == 2341 && porta.productId == 43
    );

    if (!portaArduino) {

        throw new Error(
            'O Arduino não foi encontrado em nenhuma porta serial'
        );
    }

    // Configura a porta serial
    const arduino = new serialport.SerialPort(
        {
            path: portaArduino.path,
            baudRate: SERIAL_BAUD_RATE
        }
    );

    // Evento quando a porta serial é aberta
    arduino.on('open', () => {

        console.log(
            `A leitura do Arduino foi iniciada na porta ${portaArduino.path} utilizando Baud Rate de ${SERIAL_BAUD_RATE}`
        );
    });

    arduino.pipe(
        new serialport.ReadlineParser({ delimiter: '\r\n' })
    ).on('data', async (data) => {

        console.log('Dado recebido:', data);

        const valores = data.split(';');
        const movimento = parseInt(valores[0]);

        // Armazena os valores recebidos
        valoresSensorDigital.push(movimento);

        // O Arduino detecta apenas entradas
        if (movimento == ENTRADA && HABILITAR_OPERACAO_INSERIR) {

            try {

                console.log('-----------------------------');
                console.log('Entrada detectada pelo Arduino!');

                await simularBaixaOcupacao(
                    ENTRADA,
                    poolBancoDados
                );

                await simularOcupacaoAdequada(
                    ENTRADA,
                    poolBancoDados
                );

                await simularAltaOcupacao(
                    ENTRADA,
                    poolBancoDados
                );

                console.log('-----------------------------');

            } catch (erro) {

                console.error(
                    'Erro ao registrar entrada:',
                    erro
                );
            }
        }
    });

    if (HABILITAR_OPERACAO_INSERIR) {

        // Baixa ocupação: saídas a cada 5 segundos
        setInterval(async () => {

            try {

                await simularBaixaOcupacao(
                    SAIDA,
                    poolBancoDados
                );

            } catch (erro) {

                console.error('Erro na saída de baixa ocupação:', erro);
            }

        }, 4000);


        // Ocupação adequada: saídas a cada 8 segundos
        setInterval(async () => {

            try {

                await simularOcupacaoAdequada(
                    SAIDA,
                    poolBancoDados
                );

            } catch (erro) {

                console.error('Erro na saída de ocupação adequada:', erro);
            }

        }, 6000);


        // Alta ocupação: saídas a cada 10 segundos
        setInterval(async () => {

            try {

                await simularAltaOcupacao(
                    SAIDA,
                    poolBancoDados
                );

            } catch (erro) {

                console.error('Erro na saída de alta ocupação:', erro);
            }

        }, 8000);

    }

    // Tratamento de erros do Arduino
    arduino.on('error', (mensagem) => {

        console.error(
            `Erro no Arduino (Mensagem: ${mensagem})`
        );
    });
}


const servidor = (
    valoresSensorAnalogico,
    valoresSensorDigital
) => {

    const app = express();

    // Configurações de requisição e resposta
    app.use((request, response, next) => {

        response.header('Access-Control-Allow-Origin', '*');

        response.header(
            'Access-Control-Allow-Headers',
            'Origin, Content-Type, Accept'
        );

        next();
    });

    // Inicia o servidor
    app.listen(SERVIDOR_PORTA, () => {

        console.log(
            `API executada com sucesso na porta ${SERVIDOR_PORTA}`
        );
    });

    // Endpoint para valores analógicos
    app.get('/sensores/analogico', (_, response) => {

        return response.json(valoresSensorAnalogico);
    });

    // Endpoint para valores digitais
    app.get('/sensores/digital', (_, response) => {

        return response.json(valoresSensorDigital);
    });
}

(async () => {

    const valoresSensorAnalogico = [];
    const valoresSensorDigital = [];

    // Inicia a comunicação serial
    await serial(valoresSensorDigital);

    // Inicia o servidor web
    servidor(
        valoresSensorAnalogico,
        valoresSensorDigital
    );
})();