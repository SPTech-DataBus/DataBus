const serialport = require('serialport');
const express = require('express');
const mysql = require('mysql2');


const SERIAL_BAUD_RATE = 9600;
const SERVIDOR_PORTA = 3300;
const HABILITAR_OPERACAO_INSERIR = true;
const FK_SENSOR = 1;
const FK_ONIBUS = 1;

const serial = async (
    valoresSensorAnalogico,
    valoresSensorDigital
) => {

    let poolBancoDados = mysql.createPool({
        host: 'localhost',
        user: 'DataBus',
        password: 'sua_senha',
        database: 'DataBus',
        port: 3306
    }).promise();

    const portas = await serialport.SerialPort.list();

    const portaArduino = portas.find(
        (porta) => porta.vendorId == 2341 && porta.productId == 43
    );

    if (!portaArduino) {
        throw new Error('O arduino não foi encontrado em nenhuma porta serial');
    }

    const arduino = new serialport.SerialPort({
        path: portaArduino.path,
        baudRate: SERIAL_BAUD_RATE
    });

    arduino.on('open', () => {
        console.log(
            `A leitura do arduino foi iniciada na porta ${portaArduino.path} utilizando Baud Rate de ${SERIAL_BAUD_RATE}`
        );
    });

    arduino
        .pipe(new serialport.ReadlineParser({ delimiter: '\r\n' }))
        .on('data', async (data) => {

            const valores = data.split(';');
            const movimento = parseInt(valores[0]);

            console.log("Recebido do Arduino:", movimento);

            if (movimento !== 1) {
                console.log("Ignorado:", movimento);
                return;
            }

            console.log("VOU INSERIR:", movimento);

            if (HABILITAR_OPERACAO_INSERIR) {

                await poolBancoDados.execute(
                    'INSERT INTO registro_sensor (tipo_movimento, fk_sensor, fk_onibus) VALUES (?, ?, ?)',
                    [movimento, FK_SENSOR, FK_ONIBUS]
                );

                console.log("INSERIDO:", movimento);
                console.log("Pessoa detectada! Registro inserido no banco.");
            }

            console.log("Pessoa detectada! Registro inserido no banco.");
        });

    arduino.on('error', (mensagem) => {
        console.error(`Erro no arduino (Mensagem: ${mensagem})`);
    });
};


const servidor = (
    valoresSensorAnalogico,
    valoresSensorDigital
) => {

    const app = express();

    app.use((request, response, next) => {
        response.header('Access-Control-Allow-Origin', '*');
        response.header(
            'Access-Control-Allow-Headers',
            'Origin, Content-Type, Accept'
        );
        next();
    });

    app.listen(SERVIDOR_PORTA, () => {
        console.log(
            `API executada com sucesso na porta ${SERVIDOR_PORTA}`
        );
    });

    app.get('/sensores/analogico', (_, response) => {
        return response.json(valoresSensorAnalogico);
    });

    app.get('/sensores/digital', (_, response) => {
        return response.json(valoresSensorDigital);
    });
};

(async () => {

    const valoresSensorAnalogico = [];
    const valoresSensorDigital = [];

    await serial(
        valoresSensorAnalogico,
        valoresSensorDigital
    );

    servidor(
        valoresSensorAnalogico,
        valoresSensorDigital
    );

})();