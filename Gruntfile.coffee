module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # Browser version building
    noflo_browser:
      build:
        files:
          'build/browser/microflo.js': ['component.json']

    # JavaScript minification for the browser
    uglify:
      options:
        banner: '/* MicroFlo <%= pkg.version %> -
                 Flow-Based Programming runtime for microcontrollers.
                 See http://microflo.org for more information. */'
        report: 'min'
      microflo:
        files:
          './build/browser/microflo.min.js': ['./build/browser/microflo.js']

    # CoffeeScript build
    coffee:
      lib:
        options:
          bare: true
        expand: true
        cwd: 'lib'
        src: ['**.coffee']
        dest: 'build/lib'
        ext: '.js'
      spec:
        options:
          bare: true
        expand: true
        cwd: 'test'
        src: ['**.coffee']
        dest: 'test'
        ext: '.js'

    coffeelint:
      code:
        files:
          src: ['lib/*.coffee', 'test/*.coffee']
        options:
          max_line_length:
            value: 80
            level: 'warn'
          no_trailing_semicolons:
            level: 'warn'

    # BDD tests on Node.js
    mochaTest:
      nodejs:
        src: ['test/*.coffee']
        options:
          reporter: 'spec'
          require: 'coffee-script/register'

    # FBP protocol tests
    shell:
      fbp_test:
        command: 'fbp-test --colors'

    # Web server for the browser tests
    connect:
      server:
        options:
          port: 8000

    # BDD tests on browser
    mocha_phantomjs:
      all:
        options:
          output: 'test/result.xml'
          reporter: 'spec'
          urls: ['http://localhost:8000/test/runner.html']

    copy:
      browserdeps:
        flatten: true
        src: ['node_modules/node-uuid/uuid.js']
        dest: 'build/browser/uuid.js'


  # Grunt plugins used for building
  @loadNpmTasks 'grunt-zip'
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-contrib-uglify'
  @loadNpmTasks 'grunt-contrib-copy'
  @loadNpmTasks 'grunt-contrib-compress'
  @loadNpmTasks 'grunt-contrib-clean'
  @loadNpmTasks 'grunt-noflo-browser'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-coffeelint'
  @loadNpmTasks 'grunt-contrib-connect'
  @loadNpmTasks 'grunt-mocha-test'
  @loadNpmTasks 'grunt-mocha-phantomjs'
  @loadNpmTasks 'grunt-shell-spawn'

  @loadNpmTasks 'grunt-exec'

  # Our local tasks
  @registerTask 'build', 'Build MicroFlo for the chosen target platform', (target = 'all') =>
    @task.run 'coffee'
    if target is 'all' or target is 'browser'
      @task.run 'noflo_browser'
      @task.run 'copy'

  @registerTask 'test', 'Build MicroFlo and run automated tests', (target = 'all') =>
    # @task.run 'coffeelint'
    @task.run 'build'
    if target is 'all' or target is 'nodejs'
      @task.run 'mochaTest'
      # @task.run 'shell:fbp_test'
    if target is 'all' or target is 'browser'
      @task.run 'connect'
      @task.run 'mocha_phantomjs'

  @registerTask 'default', ['test']

