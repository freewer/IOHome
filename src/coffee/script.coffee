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

    #------รายการหลอด-------#
    $rootScope.lightList = [
      { text: "หลอดห้องครัว", isOn: true, isAlert: false, alertDate: ['sun','mon','fri'], alertTime: '19:00' }
      { text: "กลางบ้าน", isOn: false, isAlert: true, alertDate: ['wed','thu','fri'], alertTime: '20:24' }
      { text: "บ้าน", isOn: false, isAlert: true, alertDate: ['fri'], alertTime: '20:24' }
    ]
    $rootScope.dateList = []

    #-----[Button] ตรวจสอบคลิกหลอด-สำคัญ!!!!----#
    $rootScope.currentLight = 1

    $rootScope.chooseLight = (light) ->
      console.log('ส่ง' + light)
      $rootScope.currentLight = light

    #--------[SET DATE]--เซ็ทปุ่มแถว------#
    $scope.setDate = (id, date) ->
      currLight = $rootScope.lightList[$rootScope.currentLight].alertDate
      if currLight.indexOf(date) != -1
        #หากเจอให้ลบทิ้ง
        currLight.splice currLight.indexOf(date), 1
      else
        #หากยังเพิ่มลง
        currLight.push date
      console.log currLight

      #---apply---ปุ่มตั้งเวลา-----#
      $rootScope.switchAlarm();
      return

  #------------------------------------------------
  app.controller 'lightCtrl', ($scope, $rootScope, $ionicSideMenuDelegate) ->
    $scope.timePickerObject =
      inputEpochTime: (new Date).getHours() * 60 * 60
      step: 1
      format: 12
      titleLabel: 'กรุณาตั้งเวลา...'
      setLabel: 'ตั้ง'
      closeLabel: 'ปิด'
      setButtonType: 'button-positive'
      closeButtonType: 'button-stable'
      callback: (val) ->
        #Mandatory
        timePickerCallback val
        return

    timePickerCallback = (val) ->
      if typeof val == 'undefined'
        console.log 'Time not selected'
      else
        selectedTime = new Date(val * 1000)
        $rootScope.lightList[$rootScope.currentLight].alertTime = leadingZero(selectedTime.getUTCHours())+':'+leadingZero(selectedTime.getUTCMinutes())

        console.log('scope='+$rootScope.lightList[$rootScope.currentLight].alertTime)
        console.log 'Selected epoch is : ', val, 'and the time is ', selectedTime.getUTCHours(), ':', selectedTime.getUTCMinutes(), 'in UTC'
        #--- Apply Alarm ----#
        $rootScope.switchAlarm()
      return
    #$scope.light = $rootScope.currentLight
    $('.clockpicker').clockpicker()

    $scope.dayList = [
      {
      date : 'sun'
      date_th : 'อา'
      }
      {
      date : 'mon'
      date_th : 'จ'
      }
      {
      date : 'tue'
      date_th : 'อ'
      }
      {
      date : 'wed'
      date_th : 'พ'
      }
      {
      date : 'thu'
      date_th : 'พฤ'
      }
      {
      date : 'fri'
      date_th : 'ศ'
      }
      {
      date : 'sat'
      date_th : 'ส'
      }
    ]

    leadingZero = (num) ->
      if num <= 9 then '0' + num else num

  app.controller 'HomeTabCtrl', ($scope, $rootScope, $ionicSideMenuDelegate) ->
    #----setting----#
    txt_ON = 'on'
    txt_OFF = 'off'
    splitter = '/'
    $scope.server = 'ws://test.mosquitto.org:8080/mqtt'
    $scope.tropic = 'aW9ob21l'
    #---dinamic setting---#
    $rootScope.onConnected = false

  #app.controller 'rootCtrl', ($scope, $rootScope) ->
    #---*-*-*-*-*-*-*-*-*-*-*[SUBMIT ZONE]-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*---#
    $rootScope.switchLight = () ->
      console.log('switchLight ID ' + $rootScope.currentLight)
      if $scope.lightList[$rootScope.currentLight].isOn == false
        $scope.pubThis('light'+splitter+$rootScope.currentLight+splitter+txt_OFF)
      else
        $scope.pubThis('light'+splitter+$rootScope.currentLight+splitter+txt_ON)

    $rootScope.switchAlarm = () ->
      console.log('switchAlarm ID ' + $rootScope.currentLight)
      if $scope.lightList[$rootScope.currentLight].isAlert == false
        $scope.pubThis('alert'+splitter+$rootScope.currentLight+splitter+txt_OFF+splitter+$rootScope.lightList[$rootScope.currentLight].alertTime+splitter+$rootScope.lightList[$rootScope.currentLight].alertDate)
      else
        $scope.pubThis('alert'+splitter+$rootScope.currentLight+splitter+txt_ON+splitter+$rootScope.lightList[$rootScope.currentLight].alertTime+splitter+$rootScope.lightList[$rootScope.currentLight].alertDate)
      return
    #-------------------------[Connect script]-------------------------------------
    (->
      window.Main = {}
      Main.Page = do ->
        mosq = null

        Page = ->
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
          #------EVENT------#
          mosq.onconnect = (rc) ->
            #--ทำการ Subscribe ต่อ--#
            $scope.subPlease()

            $scope.$apply ->
              $rootScope.onConnected = true
            console.log('%cconnected' + rc + $rootScope.onConnected, 'background-color:green; color:white')
            return

          mosq.ondisconnect = (rc) ->
            $scope.$apply ->
              $rootScope.onConnected = false
            console.log('%cDisconnected', 'background-color:red; color:white')
            return

          mosq.onmessage = (topic, payload, qos) ->
            console.log('Publish: ' + topic + '>%c' + payload, 'color:blue')

            #หาก update
            #$scope.$apply ->
              #$scope.lightList[0].isOn = payload == txt_ON ? true : false
            return

          return
  #--------------- เชื่อม  server ----------------#
        Page::connect = ->
          mosq.connect $scope.server
          return

        Page::disconnect = ->
          mosq.disconnect()
          return

        Page::subscribe = ->
          topic = $('#sub-topic-text')[0].value
          mosq.subscribe topic, 0
          return

        Page::unsubscribe = ->
          topic = $('#sub-topic-text')[0].value
          mosq.unsubscribe topic
          return

        Page::publish = ->
          topic = $('#pub-topic-text')[0].value
          payload = $('#payload-text')[0].value
          mosq.publish topic, payload, 0
          return

  #------------- ส่วนเขียนเพิ่ม -------------
        $scope.subPlease = () ->
          mosq.subscribe $scope.tropic, 0

        $scope.pubThis = (val) ->
          topic = $scope.tropic
          payload = val
          mosq.publish topic, payload, 0
          return

  #------------- END ส่วนเขียนเพิ่ม -------------
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
