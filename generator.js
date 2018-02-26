
var Parser = require("jison").Parser;
var fs     = require('fs');
var path   = require('path');
var mkdirp = require('mkdirp');

var arg_options = {};
!function(){
  for(var index = 2; index < process.argv.length; index++){
    var arg = process.argv[index].replace(/^-{1,2}/, '').split('=');
    if(arg.length > 1 && arg[0] != 'true'){
      arg_options[arg[0]] = ((arg[1] == 'false')? false : arg[1]);
    }
    else{
      arg_options[arg[0]] = true;
    }
  }
}();

fs.readFile('./source/derivaciones.jison', 'utf8', function (err,data) {
  if (err) {
    return console.log(err);
  }
  var parser = new Parser(data);
  var parserSource = parser.generate({ moduleName: 'derivaciones' });
  console.log('parser generation successfully');
  var dest_path = './' + (arg_options.dest || 'dist/derivaciones.js');
  var dest = path.parse(dest_path);
  mkdirp(dest.dir, function(err) {
    if (err) {
      return console.log(err);
    }
    fs.writeFile(dest_path, parserSource);
  });
});
