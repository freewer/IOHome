gulp = require('gulp')
gutil = require('gulp-util')
bower = require('bower')
concat = require('gulp-concat')
sass = require('gulp-sass')
minifyCss = require('gulp-minify-css')
rename = require('gulp-rename')
sh = require('shelljs')
jade = require('gulp-jade')
coffee = require ('gulp-coffee')

paths =
    sass: ['./src/scss/**/*.scss']
    jade: ['./src/jade/**/*.jade']
    coffee: ['./src/coffee/**/*.coffee']

gulp.task 'default', [
    'sass'
    'jade'
    'coffee'
]

gulp.task 'sass', (done) ->
    gulp.src('./src/scss/ionic.app.scss')
        .pipe(sass()).on('error',sass.logError)
        .pipe(gulp.dest('./www/css/'))
        .pipe(minifyCss(keepSpecialComments: 0))
        .pipe(rename(extname: '.min.css'))
        .pipe(gulp.dest('./www/css/')).on 'end', done
    return

gulp.task 'jade', (done) ->
    gulp.src(paths.jade)
        .pipe(jade())
        .pipe(gulp.dest('./www/templates')).on 'end', done
    return

gulp.task 'coffee', ->
    gulp.src('./src/coffee/*.coffee')
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('./www/js/'))

gulp.task 'watch', ->
    gulp.watch paths.sass, ['sass']
    gulp.watch paths.jade, ['jade']
    gulp.watch paths.coffee, ['coffee']
    return

gulp.task 'install', ['git-check'], ->
    bower.commands.install().on 'log', (data) ->
        gutil.log 'bower', gutil.colors.cyan(data.id), data.message
        return

gulp.task 'git-check', (done) ->
    if !sh.which('git')
        console.log '  ' + gutil.colors.red('Git is not installed.'), '\n  Git, the version control system, is required to download Ionic.', '\n  Download git here:', gutil.colors.cyan('http://git-scm.com/downloads') + '.', '\n  Once git is installed, run \'' + gutil.colors.cyan('gulp install') + '\' again.'
        process.exit 1
    done()
    return
