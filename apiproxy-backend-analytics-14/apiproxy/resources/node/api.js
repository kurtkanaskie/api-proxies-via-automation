var application_root = __dirname;
var express = require("express");
var app = express();
var bodyParser = require('body-parser');
var xmlParser = require('express-xml-bodyparser');
var router = express.Router();

app.use(express.static(application_root));

app.use(bodyParser.json());
app.use(bodyParser.urlencoded( {extended:true} ));
app.use(xmlParser({trim: false, explicitArray: false, normalizeTags: false}));

// invoked for any requests passed to this router
router.use(function(req, res, next) {
	console.log('router.use: ' + req.path);
	next();
});

// Allows use of the same basepath when testing local "ENV=local node api.js"
var env = process.env.ENV || 'not-local';
console.log('env: ' + env );
if (env == 'local') {
	console.log('Using /backend-analytics router');
	app.use('/backend-analytics', router);
} else {
	console.log('Using / router');
	app.use('/', router);
}

router.get('/', function(req, res) {
	res.status(200).send({response:'backend-analytics API basepath'});
});

router.get('/ping', function(req, res) {
    setTimeout(function() {
	    res.status(200).send({response:'backend-analytics pong'});
    }, 1000);
});
router.get('/status', function(req, res) {
	res.status(200).send({response:'backend-analytics API is running'});
});

router.get('/server1', function(req, res) {
    res.set('X-Backend-System', 'NewBackend-1');
	res.status(200).send( {response:'Server 1'});
});

router.get('/server2', function(req, res) {
    setTimeout(function() {
        console.log('Delayed 0.5 second');
        res.set('X-Backend-System', 'NewBackend-2');
	    res.status(200).send( {response:'Server 2'});
    }, 500);
});

router.get('/server3', function(req, res) {
    setTimeout(function() {
        console.log('Delayed 1 second');
        res.set('X-Backend-System', 'NewBackend-3');
	    res.status(200).send( {response:'Server 3'});
    }, 1000);
    
});

app.all('*', function(req, res) {
	res.status(400).send( {response:'No such endpoint'});
});

app.listen(4000, function() {
	// console.log('environment variables: ' + JSON.stringify(process.env));
	console.log('backend-analytics App API is listening on  - http://localhost:4000' );
});

