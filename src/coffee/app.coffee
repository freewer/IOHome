# Ionic Starter App
# angular.module is a global place for creating, registering and retrieving Angular modules
# 'starter' is the name of this angular module example (also set in a <body> attribute in index.html)
# the 2nd parameter is an array of 'requires'
# 'starter.controllers' is found in controllers.js

angular.module('starter', [
    'ionic'
    'starter.controllers'
]).run(($ionicPlatform) ->
    $ionicPlatform.ready ->

# Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
# for form inputs)
        if window.cordova and window.cordova.plugins.Keyboard
            cordova.plugins.Keyboard.hideKeyboardAccessoryBar true
            cordova.plugins.Keyboard.disableScroll true
        if window.StatusBar

# org.apache.cordova.statusbar required
            StatusBar.styleDefault()
        return
    return

).config ($stateProvider, $urlRouterProvider) ->
    $stateProvider.state('app',

        url: '/app'
        abstract: true
        templateUrl: 'templates/menu.html'
        controller: 'AppCtrl').state('app.switch_1',

        url: '/switch_1'
        views:
            'menuContent':
                templateUrl: 'templates/switch_1.html').state('app.switch_2',

        url: '/switch_2'
        views:
            'menuContent':
                templateUrl: 'templates/switch_2.html').state('app.how_to',

        url: '/how_to'
        views:
            'menuContent':
                templateUrl: 'templates/how_to.html').state('app.info',

        url: '/info'
        views:
            'menuContent':
                templateUrl: 'templates/info.html').state 'app.playlists',

        url: '/playlists'
        views:
            'menuContent':
                templateUrl: 'templates/playlists.html',
                controller: 'PlaylistsCtrl'

    # if none of the above states are matched, use this as the fallback
    $urlRouterProvider.otherwise '/app/info'
    return
