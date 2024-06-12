const request = require('request');
const express = require('express');
const app = express();

app.get('/', (req, res) => {
    const response = `
        HELLO WORLD \n
        RABBITMQ_USER: ${process.env.RABBITMQ_USER}
        RABBITMQ_NAME: ${process.env.RABBITMQ_NAME}
        RABBITMQ_HOST: ${process.env.RABBITMQ_HOST}
        RABBITMQ_PASSWORD: ${process.env.RABBITMQ_PASSWORD}
        RABBITMQ_CONF: ${process.env.RABBITMQ_CONF}
    `;

    res.send(response);
});

app.get('/rabbit', (req, res) => {
    const data = {
        uri: `http://${process.env.RABBITMQ_HOST}:15672/api/overview`,
        headers: {
            'Authorization': 'Basic ' + btoa(process.env.RABBITMQ_USER + ':' + process.env.RABBITMQ_PASSWORD),
        },
    };

    request(data).pipe(res);
})

app.get('/rabbit/info', (req, res) => {
    const data = {
        uri: `http://${process.env.RABBITMQ_HOST}:15672/api/overview`,
        headers: {
            'Authorization': 'Basic ' + btoa(process.env.RABBITMQ_USER + ':' + process.env.RABBITMQ_PASSWORD),
        },
    };

    res.send(JSON.stringify(data));
})

app.listen(80, () => {
    console.log('Example worker listening on port 3000');

    console.info('RABBITMQ_USER: ', process.env.RABBITMQ_USER);
    console.info('RABBITMQ_NAME: ', process.env.RABBITMQ_NAME);
});