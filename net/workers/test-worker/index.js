const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send('Hello world');
});

app.listen(80, () => {
    console.log('Example worker listening on port 3000');
});