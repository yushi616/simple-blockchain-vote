const express = require('express');
const bodyParser = require('body-parser');

const app = express();

// 解析 application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: false }));

// 解析 application/json
app.use(bodyParser.json());
app.set('view engine', 'ejs');
app.get('/', (req, res) => {
    res.render('home')
});

app.post('/vote', (req, res) => {
    const votingId = req.body.votingId;
    const optionId = req.body.optionId;

    // 在这里处理投票逻辑
    // ...

    res.send('Vote received!');
});

app.listen(3000, () => {
    console.log('App is listening on port 3000');
});