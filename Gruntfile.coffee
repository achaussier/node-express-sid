renameCoffee = (dest, name) ->
    dest + '/' + name.replace 'coffee', 'js'

#
# GruntFile
#
module.exports = (grunt) ->
    parentcwd = process.cwd()
    grunt.initConfig

        #
        # node express instance
        #
        express:
            options:
                port: 9003
                background: true
                cmd: process.argv[0],
                script: 'app/coffee/server.coffee',
                opts: ['node_modules/coffee-script/bin/coffee'],
                args: [ ],
            local:
                options:
                    node_env: 'local'
            dev:
                options:
                    node_env: 'dev'
            preprod:
                options:
                    node_env: 'preprod'
            prod:
                options:
                    node_env: 'prod'
        open:
            server:
                path: 'http://localhost:<%= express.options.port %>'

        #
        # coffeelint
        #
        coffeelint:
            app: [
                'app/coffee/**/*.coffee'
                '!app/coffee/test/**/*'
                '!app/coffee/**/_*.coffee'
            ]
            test:
                files:
                    src: [
                        'app/coffee/test/unit/**/*.coffee'
                        '!app/coffee/test/unit/test-main.coffee'
                    ]
            options:
                'indentation' :
                    "value": 4
                    "level": "error"

                'no_trailing_whitespace' :
                    'level' : 'error'

                'max_line_length' :
                    'level' : 'warn'

        #
        # clean css / js compiled folder
        #
        clean:
            all: do ->
                folders = []
                folders.push(
                    "web/js"
                )
                folders

        #
        # compile coffee files
        #
        coffee:
            options:
                bare: true
                sourcemap: false
            all:
                files: do ->
                    folders = []
                    folders.push
                        expand: true
                        cwd: "app/coffee"
                        src: ["**/*.coffee", "!**/_*.coffee"]
                        dest: "web/js"
                        rename: renameCoffee
                    folders.push
                        expand: true
                        cwd: "./"
                        src: ["karma.config.coffee"]
                        dest: "./"
                        rename: renameCoffee
                    folders.push
                        expand: true
                        cwd: "app/coffee"
                        src: ["routes.json"]
                        dest: "web/js"
                    folders

        #
        # Watch task
        #
        watch:
            options:
                livereload: true
            coffee:
                files: do ->
                    folders = []
                    folders.push("app/coffee/**/*.coffee")
                    folders
                tasks: ["coffeelint", "coffee:all"]

        #
        # karma
        #
        karma:
            unit:
                configFile : 'karma.config.js'


        #
        # apidoc
        #
        apidoc:
            app:
                src: "app/coffee/"
                dest: "web/doc/"
                options:
                    debug : true
                    includeFilters: [ ".*\\.coffee$" ]
                    excludeFilters: [ ".*_\\.coffee$" ]
                    marked:
                        gfm: true

    #
    # Load all needed npm tasks
    #

    grunt.loadNpmTasks 'grunt-express-server'
    grunt.loadNpmTasks 'grunt-contrib-clean'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-open'
    grunt.loadNpmTasks 'grunt-karma'
    grunt.loadNpmTasks 'grunt-coffeelint'
    grunt.loadNpmTasks 'grunt-protractor-runner'
    grunt.loadNpmTasks 'grunt-apidoc'

    grunt.registerTask 'serve', (target) ->
        target = 'local' if target is undefined
        tasks = []
        tasks.push 'build:' + target
        tasks.push 'express:' + target, 'open:server', 'watch'
        grunt.task.run tasks

    grunt.registerTask 'build', (target) ->
        target = 'local' if target is undefined
        grunt.task.run([
            'coffeelint'
            'clean:all'
            'coffee:all'
            'apidoc'
        ])

    grunt.registerTask 'e2e', [
        'protractor'
    ]

    grunt.registerTask 'test', [
        'build:local'
        'karma'
    ]

    grunt.registerTask 'default', [
        'build'
        'serve'
    ]
