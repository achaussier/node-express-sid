#
# dependencies
#
express = require 'express'
path = require "path"
favicon = require 'serve-favicon'
logger = require 'morgan'
methodOverride = require 'method-override'
session = require 'express-session'
bodyParser = require 'body-parser'
multer = require 'multer'
errorHandler = require 'errorhandler'
erc = require 'express-route-controller'
livereload = require 'connect-livereload'
#
# app configuration
#
appDirName = "web"
app = express()
app.set 'port', 9003
app.use methodOverride()
app.use bodyParser.json()
app.use bodyParser.urlencoded
    extended: true
app.use multer()
app.use errorHandler()
switch app.get('env')
    when 'local','dev'
        app.use logger app.get('dev')
        app.use livereload(
            port: 35729
            excludeList: [
                ".woff"
                ".flv"
            ]
        )
    else
        app.use logger 'tiny'
#
# routing
#
allowCrossDomain = (req, res, next) ->
    res.header "Access-Control-Allow-Origin", "*"
    res.header "Access-Control-Allow-Headers", "X-Requested-With"
    next()
app.use allowCrossDomain
#
# static
#
app.use express.static(process.cwd() + '/web/doc/')
#
# dynmamic routes & controllers
#
erc(app,
    controllers: __dirname + '/../../web/js/controllers',
    routes: require './routes.json'
)

#
# listen
#
app.listen app.get("port"), ->
    console.log(
        'Express server listening on port [' +
            app.get('port') +
            '] in environment [' +
            app.get('env') +
        ']'
    )
