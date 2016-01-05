(->
    app = angular.module('myApp', [
        'ionic'
        'ionic-timepicker'
    ])
    app.config ($stateProvider, $urlRouterProvider, $ionicConfigProvider) ->
        $ionicConfigProvider.tabs.position 'bottom' # other values: top
        $stateProvider.state('tabs',
#    app.config ($stateProvider, $urlRouterProvider) ->
#        $stateProvider.state('tabs',
            url: '/tab'
            controller: 'TabsCtrl'
            templateUrl: 'templates/tabs.html').state('tabs.home',
            url: '/home'
            views:
                'home-tab':
                    controller: 'HomeTabCtrl'
                    templateUrl: 'templates/home.html').state('tabs.settings',
            url: '/settings'
            views:
                'settings-tab':
                    controller: 'lightCtrl'
                    templateUrl: 'templates/settings.html').state('howto',
            url: '/howto'
            controller: 'TabsCtrl'
            templateUrl: 'templates/howto.html').state 'info',
            url: '/info'
            controller: 'TabsCtrl'
            templateUrl: 'templates/info.html'
        $urlRouterProvider.otherwise '/tab'

#    app.config '$ionicConfigProvider', ($ionicConfigProvider) ->
#        $ionicConfigProvider.tabs.position 'bottom'
#        # other values: top
#        return

    app.controller 'TabsCtrl', ($scope, $rootScope, $ionicSideMenuDelegate) ->
        $scope.openMenu = ->
            $ionicSideMenuDelegate.toggleLeft()

        #------รายการหลอด-------#
        $rootScope.lightList = [
            { text: "Switch 1", isOn: false, isAlert: false, alertDate: ['sun'], alertTime: '00:00', alertOff: false, alertTimeOff: '23:59' }
            { text: "Switch 2", isOn: false, isAlert: false, alertDate: ['sun'], alertTime: '00:00', alertOff: false, alertTimeOff: '23:59' }
        ]
        $rootScope.dateList = []

        #-----[Button] ตรวจสอบคลิกหลอด-สำคัญ!!!!----#
        $rootScope.currentLight = 0

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
            format: 24
            titleLabel: 'Set Alarm ON'
            setLabel: 'SET'
            closeLabel: 'CLOSE'
            setButtonType: 'button-positive'
            closeButtonType: 'button-dark'
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

        $scope.timePickerObjectOff =
            inputEpochTime: (new Date).getHours() * 60 * 60
            step: 1
            format: 24
            titleLabel: 'Set Alarm OFF'
            setLabel: 'SET'
            closeLabel: 'CLOSE'
            setButtonType: 'button-positive'
            closeButtonType: 'button-dark'
            callback: (val) ->
#Mandatory
                timePickerCallbackOff val
                return

        timePickerCallbackOff = (val) ->
            if typeof val == 'undefined'
                console.log 'Time not selected'
            else
                selectedTime = new Date(val * 1000)
                $rootScope.lightList[$rootScope.currentLight].alertTimeOff = leadingZero(selectedTime.getUTCHours())+':'+leadingZero(selectedTime.getUTCMinutes())

                console.log('scope='+$rootScope.lightList[$rootScope.currentLight].alertTimeOff)
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
        alert_ON = 'blank on'
        alert_OFF = 'blank off'

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
                alert_ON  = 'off'
                $scope.pubThis('alert'+splitter+$rootScope.currentLight+splitter+alert_ON+splitter+$rootScope.lightList[$rootScope.currentLight].alertTime+splitter+$rootScope.lightList[$rootScope.currentLight].alertDate+splitter+$rootScope.lightList[$rootScope.currentLight].alertOff+splitter+$rootScope.lightList[$rootScope.currentLight].alertTimeOff)
            else if $scope.lightList[$rootScope.currentLight].isAlert == true
                alert_ON  = 'on'
                $scope.pubThis('alert'+splitter+$rootScope.currentLight+splitter+alert_ON+splitter+$rootScope.lightList[$rootScope.currentLight].alertTime+splitter+$rootScope.lightList[$rootScope.currentLight].alertDate+splitter+$rootScope.lightList[$rootScope.currentLight].alertOff+splitter+$rootScope.lightList[$rootScope.currentLight].alertTimeOff)
            else if $scope.lightList[$rootScope.currentLight].alertOff == false
                alert_OFF = 'off'
                $scope.pubThis('alert'+splitter+$rootScope.currentLight+splitter+alert_ON+splitter+$rootScope.lightList[$rootScope.currentLight].alertTime+splitter+$rootScope.lightList[$rootScope.currentLight].alertDate+splitter+$rootScope.lightList[$rootScope.currentLight].alertOff+splitter+$rootScope.lightList[$rootScope.currentLight].alertTimeOff)
            else if $scope.lightList[$rootScope.currentLight].alertOff == true
                alert_OFF = 'on'
                $scope.pubThis('alert'+splitter+$rootScope.currentLight+splitter+alert_ON+splitter+$rootScope.lightList[$rootScope.currentLight].alertTime+splitter+$rootScope.lightList[$rootScope.currentLight].alertDate+splitter+$rootScope.lightList[$rootScope.currentLight].alertOff+splitter+$rootScope.lightList[$rootScope.currentLight].alertTimeOff)
            else
                $scope.pubThis('No Alert')

#        $rootScope.switchAlertOff = () ->
#            console.log('switchAlertOff ID ' + $rootScope.currentLight)
#            if $scope.lightList[$rootScope.currentLight].alertOff == false
#                $scope.pubThis(txt_OFF)
#            else
#                $scope.pubThis(txt_ON)

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
).call this
