const express = require('express');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
  res.send('Olá, Mundo! Meu deploy via Jenkins funcionou!');
});

app.listen(PORT, () => {
  console.log(`App rodando na porta ${PORT}`);
});
