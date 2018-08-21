var express = require('express');
var app = express();

app.use(express.static(__dirname + '/views'));

app.get('/', function(req, res) {
    res.sendFile('index.html');
});

app.listen(3000, "0.0.0.0",function() {
    
    console.log('Example app listening on port 3000!');
});
