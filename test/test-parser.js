

var fs = require('fs');
var elementos = require('../source/elementos.js');



fs.readFile('./example.txt', 'utf8', function (err,data) {
  if (err) {
    return console.log(err);
  }
  var ast = elementos.parser.parse(data);
});