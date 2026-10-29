<p align="center">
  <img src="algoritmos/calculadora-financeira/logo.png" alt="Logo DataBus" width="96">
</p>

<h1 align="center">DataBus</h1>

<p align="center">
  Monitoramento da ocupação de ônibus por linha e horário
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Arduino-00878F?style=flat&logo=arduino&logoColor=white" alt="Arduino">
  <img src="https://img.shields.io/badge/Node.js-339933?style=flat&logo=nodedotjs&logoColor=white" alt="Node.js">
  <img src="https://img.shields.io/badge/MySQL-4479A1?style=flat&logo=mysql&logoColor=white" alt="MySQL">
  <img src="https://img.shields.io/badge/HTML5-E34F26?style=flat&logo=html5&logoColor=white" alt="HTML5">
  <img src="https://img.shields.io/badge/CSS3-1572B6?style=flat&logo=css3&logoColor=white" alt="CSS3">
  <img src="https://img.shields.io/badge/JavaScript-F7DF1E?style=flat&logo=javascript&logoColor=black" alt="JavaScript">
  <img src="https://img.shields.io/badge/Chart.js-FF6384?style=flat&logo=chartdotjs&logoColor=white" alt="Chart.js">
</p>

## Sobre o projeto

O DataBus é uma solução de IoT voltada para empresas de transporte coletivo. Sensores instalados nas portas dos ônibus registram a passagem dos passageiros, e esses dados são armazenados em banco e apresentados em uma dashboard para o gestor da frota.

Com essas informações, a empresa consegue identificar quais linhas estão operando com baixa ocupação e quais estão superlotadas, e remanejar os veículos de acordo com a demanda real, sem precisar aumentar a frota.

Projeto desenvolvido no curso de Análise e Desenvolvimento de Sistemas da SPTech, na disciplina de Pesquisa e Inovação.

## Contexto

O ônibus é o principal meio de transporte coletivo do país. São cerca de 15 milhões de passageiros por dia no trajeto casa-trabalho (IBGE, 2022) e uma frota de 107 mil veículos (NTU, 2024).

A demanda varia conforme a linha e o horário, mas a catraca registra apenas quem entra no ônibus, e não quem desce. Sem saber a ocupação real, a empresa mantém veículos rodando quase vazios em algumas linhas enquanto outras operam acima da capacidade. Isso aumenta o gasto com combustível, leva passageiros a migrarem para outros meios de transporte e expõe a operadora a multas por qualidade do serviço.

## Como funciona

```
Sensor HC-SR04  →  Arduino Uno  →  API Node.js  →  MySQL  →  Site e Dashboard
```

1. O sensor ultrassônico, instalado acima da porta, detecta a passagem de uma pessoa.
2. O Arduino envia a leitura pela porta serial.
3. A API recebe os dados, grava cada passagem no banco com data e hora e disponibiliza as leituras para o gráfico em tempo real.
4. O banco, hospedado em uma máquina virtual Linux, calcula a ocupação de cada linha.
5. A dashboard apresenta os indicadores e as sugestões de remanejamento.

## Funcionalidades

- Leitura do sensor e gráfico de passagens em tempo real
- Site institucional com apresentação da solução
- Simulador financeiro que estima a economia com a frota ideal de uma linha
- Cadastro e login com validação de campos e perfis de Administrador e Operador
- Dashboard com alertas de baixa e alta ocupação, comparativo histórico e sugestões de remanejamento
- Tela de monitoramento da frota com status de cada ônibus e sensor

## Faixas de ocupação

| Ocupação | Classificação | Ação |
|---|---|---|
| Abaixo de 35% | Baixa | Linha pode ceder um ônibus |
| 35% a 60% | Adequada | Nenhuma |
| 60% a 85% | Atenção | Acompanhar |
| Acima de 85% | Alta | Linha pode receber um ônibus |

Uma troca só é sugerida quando a linha de origem continua abaixo de 70% depois de ceder o veículo, a linha de destino cai pelo menos 10 pontos percentuais e os horários das duas linhas são compatíveis.

## Tecnologias

| Camada | Tecnologias |
|---|---|
| Hardware | Arduino Uno, sensor ultrassônico HC-SR04 |
| API | Node.js, Express, SerialPort, mysql2 |
| Banco de dados | MySQL em máquina virtual Linux |
| Front-end | HTML, CSS, JavaScript, Chart.js |
| Gestão | Trello, GitHub |

## Estrutura do repositório

```
DataBus/
├── algoritmos/
│   └── calculadora-financeira/   Simulador financeiro
├── banco-de-dados/               Script SQL e modelo lógico (DER)
├── sensor/
│   ├── api/                      API de leitura e gráfico em tempo real
│   └── script/                   Código do Arduino
└── site/
    └── login-cadastro/           Site institucional, login, cadastro e dashboard
```

## Equipe

| Integrante | GitHub |
|---|---|
| Adrian Patrício | [@adrianpatricio-dev](https://github.com/adrianpatricio-dev) |
| Camily Moreira | [@CamilyMoreiraTech](https://github.com/CamilyMoreiraTech) |
| Ernani Pimenta | [@Ernani-Carvalho](https://github.com/Ernani-Carvalho) |
| Ezequiel Imídio | [@Ezequiel-Eleuterio](https://github.com/Ezequiel-Eleuterio) |
| Gustavo Jacob | [@GustavoJacob1](https://github.com/GustavoJacob1) |
| Thais Medeiros | [@thaisnmedeiros](https://github.com/thaisnmedeiros) |

<p align="center">
  SPTech · Grupo 10 · 2026
</p>
