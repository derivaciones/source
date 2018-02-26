'use strict'


LIVERELOAD_PORT = 35730
lrSnippet = require('connect-livereload')(port: LIVERELOAD_PORT)
exec = require('child_process').execSync;

# var conf = require('./conf.'+process.env.NODE_ENV);
mountFolder = (connect, dir) ->
  connect.static require('path').resolve(dir)

app_name = require('./package.json').name

# # Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*}*.js'
# use this if you want to recursively match all subfolders:
# 'test/spec/**/*.js'
module.exports = (grunt) ->

  unless app_name
    throw new TypeError('must specify an application name in bower.json file')

  grunt.log.write 'application name: ' + app_name + '\n'

  require('load-grunt-tasks') grunt
  # require('time-grunt') grunt
  # configurable paths

  yeomanConfig =
    bower:   'bower_components'
    src:     'client'
    dist:    'dist'
    tmp:     'tmp'
  do ->
    (maybe_dist = grunt.option('dist')) and
    (typeof maybe_dist is 'string') and
    yeomanConfig.dist = maybe_dist
  do ->
    (maybe_tmp = grunt.option('tmp')) and
    (typeof maybe_tmp is 'string') and
    yeomanConfig.tmp = maybe_tmp

  grunt.loadNpmTasks 'grunt-bake'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-html-angular-validate'
  grunt.loadNpmTasks 'grunt-preprocess'
  grunt.loadNpmTasks 'grunt-string-replace'

  grunt.initConfig
    yeoman: yeomanConfig

    #################################################
    #                  livereload                   #
    #################################################
    # watch: cada vez que un archivo cambia
    # dentro de 'files' se ejecutan las correspodientes 'tasks'
    watch:

      coffee:
        files: ['<%= yeoman.src %>/**/*.coffee']
        tasks: ['coffee:server']
      sass:
        files: ['<%= yeoman.src %>/**/*.scss']
        tasks: ['sass:server']
      preprocess:
        files: ['<%= yeoman.src %>/**/*.{html,html,txt}']
        tasks: ['copy:text','preprocess:server','bake:server']
      generate:
        files: ['source/derivaciones.jison']
        tasks: ['generate']
      assets:
        files: ['<%= yeoman.src %>/**/*.{jpg,jpg,png}']
        tasks: ['copy:assets']

      # watch.livereload: files which demand the page reload
      livereload:
        options:
          livereload: LIVERELOAD_PORT
        files: [
          '<%= yeoman.dist %>/**/*'
        ]

    connect:
      options:
        port: 3001
        # default 'localhost'
        # Change this to '0.0.0.0' to access the server from outside.
        hostname: "0.0.0.0"
      livereload:
        options:
          middleware: (connect) ->
            [lrSnippet, mountFolder(connect, yeomanConfig.dist)]

    clean:
      dist:
        files: [
          dot: true
          src: [
            '<%= yeoman.dist %>/**/*',
            '!<%= yeoman.dist %>/.gitignore',
            '!<%= yeoman.dist %>/bower_components/**'
          ]
        ]
      tmp:
        files: [
          dot: true
          src: [
            '<%= yeoman.tmp %>/**/*',
            '!<%= yeoman.tmp %>/.gitignore'
          ]
        ]

    #################################################
    #                    styles                     #
    #################################################

    sass:
      server:
        options:
          style: 'expanded'
          sourcemap: 'none'
        files: [
          expand: true
          cwd: '<%= yeoman.src %>'
          src: '**/*.scss'
          dest: '<%= yeoman.dist %>'
          ext: '.css'
        ]

    #################################################
    #                     html                      #
    #################################################
    bake:
      server:
        files: [
          expand: true
          cwd: '<%= yeoman.tmp %>/markup/page'
          src: '**/*.{htm,html}'
          dest: '<%= yeoman.dist %>'
          ext: '.html'
        ]

    preprocess:
      options:
        inline: true
        context:
          PRODUCTION: 'PRODUCTION'
          STAGGING:   'STAGGING'
          DEVELOP:    'DEVELOP'
          ENV:        'DEVELOP'
      server:
        files: [
          expand: true
          cwd: '<%= yeoman.src %>/markup'
          src: '**/*.{htm,html}'
          dest: '<%= yeoman.tmp %>/markup'
          ext: '.html'
        ]

    #################################################
    #                  copy helper                  #
    #################################################

    copy:
      favicon:
        files: [
          expand: true
          cwd: '<%= yeoman.src %>'
          src: 'favicon.png'
          dest: '<%= yeoman.dist %>'
        ]
      assets:
        files: [
          expand: true
          cwd: '<%= yeoman.src %>/asset'
          src: '**/*.{jpg,png}'
          dest: '<%= yeoman.dist %>/asset'
        ]
      text:
        files: [
          expand: true
          cwd: '<%= yeoman.src %>/markup'
          src: '**/*.txt'
          dest: '<%= yeoman.tmp %>/markup'
        ]
      github:
        files: [
          expand: true
          cwd: '<%= yeoman.src %>/style/github'
          src: '**/*'
          dest: '<%= yeoman.dist %>/style/github'
        ]

    #################################################
    #                    scripts                    #
    #################################################

    coffee:
      server:
        options:
          bare: true
          sourceMap: false
          sourceRoot: ''
        files: [
          expand: true
          cwd: '<%= yeoman.src %>'
          src: ['**/*.coffee']
          dest: '<%= yeoman.dist %>'
          ext: '.js'
        ]

    uglify:
      dist:
        files: [
          expand: true
          cwd: '<%= yeoman.dist %>'
          src: '/**/*.js'
          dest: '<%= yeoman.dist %>'
        ]

    #################################################
    #                    exec                       #
    #################################################

  grunt.registerTask 'generate', (target) ->
    commands = [
      'node generator.js --dest=' + yeomanConfig.dist + '/script/component/elementos.js'
    ]
    for command in commands
      grunt.log.write command + '\n'
      result = exec command, cdw: __dirname
      grunt.log.write result


  grunt.registerTask 'server', (target) ->
    grunt.task.run [
      'clean:dist'
      'clean:tmp'
      'copy:favicon'
      'copy:github'
      'copy:assets'
      'copy:text'
      'preprocess:server'
      'bake:server'
      'generate'
      'coffee:server'
      'sass:server'
      'connect:livereload'
      'watch'
    ]
