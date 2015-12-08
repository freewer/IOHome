(->
  app = undefined
  app = angular.module('myApp', [
    'ionic'
    'ionic-timepicker'
  ])
  app.config ($stateProvider, $urlRouterProvider) ->
    $stateProvider.state('tabs',
      url: '/tab'
      controller: 'TabsCtrl'
      templateUrl: 'templates/tabs.html').state('tabs.home',
      url: '/home'
      views: 'home-tab':
        templateUrl: 'templates/home.html'
        controller: 'HomeTabCtrl').state('tabs.settings',
      url: '/settings'
      views: 'settings-tab':
        controller: 'lightCtrl'
        templateUrl: 'templates/light.html').state('about',
      url: '/about'
      controller: 'AboutCtrl'
      templateUrl: 'templates/about.html').state 'info',
      url: '/info'
#      controller: 'AboutCtrl'
      templateUrl: 'templates/info.html'
    $urlRouterProvider.otherwise '/tab'
  app.controller 'TabsCtrl', ($scope, $rootScope, $ionicSideMenuDelegate) ->

    $scope.openMenu = ->
      $ionicSideMenuDelegate.toggleLeft()

    $rootScope.lightList = [
      {
        text: 'หลอดห้องครัว'
        isOn: true
        isAlert: false
        alertDate: [
          'sun'
          'mon'
          'fri'
        ]
        alertTime: '19:00'
      }
      {
        text: 'กลางบ้าน'
        isOn: false
        isAlert: true
        alertDate: [
          'wed'
          'thu'
          'fri'
        ]
        alertTime: '20:24'
      }
      {
        text: 'บ้าน'
        isOn: false
        isAlert: true
        alertDate: [ 'fri' ]
        alertTime: '20:24'
      }
    ]

    $rootScope.dateList = []
    $rootScope.currentLight = 1

    $rootScope.chooseLight = (light) ->
      console.log 'ส่ง' + light
      $rootScope.currentLight = light

    $scope.setDate = (id, date) ->
      currLight = undefined
      currLight = $rootScope.lightList[$rootScope.currentLight].alertDate
      if currLight.indexOf(date) != -1
        currLight.splice currLight.indexOf(date), 1
      else
        currLight.push date
      console.log currLight
      return

  app.controller 'lightCtrl', ($scope, $rootScope, $ionicSideMenuDelegate) ->
    timePickerCallback = undefined
    $scope.timePickerObject =
      inputEpochTime: (new Date).getHours() * 60 * 60
      step: 1
      format: 12
      titleLabel: 'อีก ** ชม. ต่อจากนี้'
      setLabel: 'ตั้ง'
      closeLabel: 'ปิด'
      setButtonType: 'button-positive'
      closeButtonType: 'button-stable'
      callback: (val) ->
        timePickerCallback val
        return

    timePickerCallback = (val) ->
      selectedTime = undefined
      if typeof val == 'undefined'
        console.log 'Time not selected'
      else
        selectedTime = new Date(val * 1000)
        $rootScope.lightList[$rootScope.currentLight].alertTime = selectedTime.getUTCHours() + ':' + selectedTime.getUTCMinutes()
        console.log 'scope=' + $rootScope.lightList[$rootScope.currentLight].alertTime
        console.log 'Selected epoch is : ', val, 'and the time is ', selectedTime.getUTCHours(), ':', selectedTime.getUTCMinutes(), 'in UTC'
      return

    $('.clockpicker').clockpicker()
    $scope.dayList = [
      {
        date: 'sun'
        date_th: 'อา'
      }
      {
        date: 'mon'
        date_th: 'จ'
      }
      {
        date: 'tue'
        date_th: 'อ'
      }
      {
        date: 'wed'
        date_th: 'พ'
      }
      {
        date: 'thu'
        date_th: 'พฤ'
      }
      {
        date: 'fri'
        date_th: 'ศ'
      }
      {
        date: 'sat'
        date_th: 'ส'
      }
    ]
  app.controller 'HomeTabCtrl', ($scope, $rootScope, $ionicSideMenuDelegate) ->
    txt_OFF = undefined
    txt_ON = undefined
    txt_ON = 'on'
    txt_OFF = 'off'
    $scope.server = 'ws://test.mosquitto.org:8080/mqtt'
    $scope.tropic = 'aW9ob21l'
    $rootScope.onConnected = false

    $rootScope.switchLight = (lightIndex) ->
      console.log 'switchLight ID ' + lightIndex
      if $scope.lightList[lightIndex].isOn == false
        $scope.pubThis 'off'
      else
        $scope.pubThis 'on'

    (->
      window.Main = {}
      Main.Page = do ->
        Page = undefined
        mosq = undefined
        mosq = null

        Page = ->
          _this = undefined
          _this = this
          mosq = new Mosquitto
          $('#connect-button').click ->
            _this.connect()
          $('#disconnect-button').click ->
            _this.disconnect()
          $('#subscribe-button').click ->
            _this.subscribe()
          $('#unsubscribe-button').click ->
            _this.unsubscribe()
          $('#publish-button').click ->
            _this.publish()

          mosq.onconnect = (rc) ->
            $scope.subPlease()
            $scope.$apply ->
              $rootScope.onConnected = true
            console.log '%cconnected' + rc + $rootScope.onConnected, 'background-color:green; color:white'
            return

          mosq.ondisconnect = (rc) ->
            $scope.$apply ->
              $rootScope.onConnected = false
            console.log '%cDisconnected', 'background-color:red; color:white'
            return

          mosq.onmessage = (topic, payload, qos) ->
            console.log 'Publish: ' + topic + '>%c' + payload, 'color:blue'
            $scope.$apply ->
              ref = undefined
              $scope.lightList[0].isOn = if (ref = payload == txt_ON) != null then ref else 'true': false
            return

          return

        Page::connect = ->
          mosq.connect $scope.server
          return

        Page::disconnect = ->
          mosq.disconnect()
          return

        Page::subscribe = ->
          topic = undefined
          topic = $('#sub-topic-text')[0].value
          mosq.subscribe topic, 0
          return

        Page::unsubscribe = ->
          topic = undefined
          topic = $('#sub-topic-text')[0].value
          mosq.unsubscribe topic
          return

        Page::publish = ->
          payload = undefined
          topic = undefined
          topic = $('#pub-topic-text')[0].value
          payload = $('#payload-text')[0].value
          mosq.publish topic, payload, 0
          return

        $scope.subPlease = ->
          mosq.subscribe $scope.tropic, 0

        $scope.pubThis = (val) ->
          payload = undefined
          topic = undefined
          topic = $scope.tropic
          payload = val
          mosq.publish topic, payload, 0
          return

        Page
      $ ->
        Main.controller = new (Main.Page)
      return
    ).call this
  app.controller 'AboutCtrl', ($scope, $ionicSideMenuDelegate) ->

    $scope.openMenu = ->
      $ionicSideMenuDelegate.toggleLeft()

  return
).call this
