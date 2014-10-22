module.exports =
    ###
    @api {get} /index
    @apiName
    @apiGroup
    ###
    default : (req, res, next) ->
        console.log "web/doc/index.html"
        res.sendfile 'web/doc/index.html'
        next()
