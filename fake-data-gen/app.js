var graphite = require('graphite');
var client = graphite.createClient('plaintext://localhost:2003/');

var counter = 1000;

setInterval(function() {

	counter += Math.random() * 10 - 5;

	var metrics = { highres: { test: counter } };
	client.write(metrics, function(err) {
	  if (err) {
	  	console.log('failed to write to graphite');
	  }
	});

}, 1000);
