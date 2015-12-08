(function() {
  var app;
  app = void 0;
  app = angular.module('myApp', ['ionic', 'ionic-timepicker']);
  app.config(function($stateProvider, $urlRouterProvider) {
    $stateProvider.state('tabs', {
      url: '/tab',
      controller: 'TabsCtrl',
      templateUrl: 'templates/tabs.html'
    }).state('tabs.home', {
      url: '/home',
      views: {
        'home-tab': {
          templateUrl: 'templates/home.html',
          controller: 'HomeTabCtrl'
        }
      }
    }).state('tabs.settings', {
      url: '/settings',
      views: {
        'settings-tab': {
          controller: 'lightCtrl',
          templateUrl: 'templates/light.html'
        }
      }
    }).state('about', {
      url: '/about',
      controller: 'AboutCtrl',
      templateUrl: 'templates/about.html'
    }).state('info', {
      url: '/info',
      templateUrl: 'templates/info.html'
    });
    return $urlRouterProvider.otherwise('/tab');
  });
  app.controller('TabsCtrl', function($scope, $rootScope, $ionicSideMenuDelegate) {
    $scope.openMenu = function() {
      return $ionicSideMenuDelegate.toggleLeft();
    };
    $rootScope.lightList = [
      {
        text: 'หลอดห้องครัว',
        isOn: true,
        isAlert: false,
        alertDate: ['sun', 'mon', 'fri'],
        alertTime: '19:00'
      }, {
        text: 'กลางบ้าน',
        isOn: false,
        isAlert: true,
        alertDate: ['wed', 'thu', 'fri'],
        alertTime: '20:24'
      }, {
        text: 'บ้าน',
        isOn: false,
        isAlert: true,
        alertDate: ['fri'],
        alertTime: '20:24'
      }
    ];
    $rootScope.dateList = [];
    $rootScope.currentLight = 1;
    $rootScope.chooseLight = function(light) {
      console.log('ส่ง' + light);
      return $rootScope.currentLight = light;
    };
    return $scope.setDate = function(id, date) {
      var currLight;
      currLight = void 0;
      currLight = $rootScope.lightList[$rootScope.currentLight].alertDate;
      if (currLight.indexOf(date) !== -1) {
        currLight.splice(currLight.indexOf(date), 1);
      } else {
        currLight.push(date);
      }
      console.log(currLight);
    };
  });
  app.controller('lightCtrl', function($scope, $rootScope, $ionicSideMenuDelegate) {
    var timePickerCallback;
    timePickerCallback = void 0;
    $scope.timePickerObject = {
      inputEpochTime: (new Date).getHours() * 60 * 60,
      step: 1,
      format: 12,
      titleLabel: 'อีก ** ชม. ต่อจากนี้',
      setLabel: 'ตั้ง',
      closeLabel: 'ปิด',
      setButtonType: 'button-positive',
      closeButtonType: 'button-stable',
      callback: function(val) {
        timePickerCallback(val);
      }
    };
    timePickerCallback = function(val) {
      var selectedTime;
      selectedTime = void 0;
      if (typeof val === 'undefined') {
        console.log('Time not selected');
      } else {
        selectedTime = new Date(val * 1000);
        $rootScope.lightList[$rootScope.currentLight].alertTime = selectedTime.getUTCHours() + ':' + selectedTime.getUTCMinutes();
        console.log('scope=' + $rootScope.lightList[$rootScope.currentLight].alertTime);
        console.log('Selected epoch is : ', val, 'and the time is ', selectedTime.getUTCHours(), ':', selectedTime.getUTCMinutes(), 'in UTC');
      }
    };
    $('.clockpicker').clockpicker();
    return $scope.dayList = [
      {
        date: 'sun',
        date_th: 'อา'
      }, {
        date: 'mon',
        date_th: 'จ'
      }, {
        date: 'tue',
        date_th: 'อ'
      }, {
        date: 'wed',
        date_th: 'พ'
      }, {
        date: 'thu',
        date_th: 'พฤ'
      }, {
        date: 'fri',
        date_th: 'ศ'
      }, {
        date: 'sat',
        date_th: 'ส'
      }
    ];
  });
  app.controller('HomeTabCtrl', function($scope, $rootScope, $ionicSideMenuDelegate) {
    var txt_OFF, txt_ON;
    txt_OFF = void 0;
    txt_ON = void 0;
    txt_ON = 'on';
    txt_OFF = 'off';
    $scope.server = 'ws://test.mosquitto.org:8080/mqtt';
    $scope.tropic = 'aW9ob21l';
    $rootScope.onConnected = false;
    $rootScope.switchLight = function(lightIndex) {
      console.log('switchLight ID ' + lightIndex);
      if ($scope.lightList[lightIndex].isOn === false) {
        return $scope.pubThis('off');
      } else {
        return $scope.pubThis('on');
      }
    };
    return (function() {
      window.Main = {};
      Main.Page = (function() {
        var Page, mosq;
        Page = void 0;
        mosq = void 0;
        mosq = null;
        Page = function() {
          var _this;
          _this = void 0;
          _this = this;
          mosq = new Mosquitto;
          $('#connect-button').click(function() {
            return _this.connect();
          });
          $('#disconnect-button').click(function() {
            return _this.disconnect();
          });
          $('#subscribe-button').click(function() {
            return _this.subscribe();
          });
          $('#unsubscribe-button').click(function() {
            return _this.unsubscribe();
          });
          $('#publish-button').click(function() {
            return _this.publish();
          });
          mosq.onconnect = function(rc) {
            $scope.subPlease();
            $scope.$apply(function() {
              return $rootScope.onConnected = true;
            });
            console.log('%cconnected' + rc + $rootScope.onConnected, 'background-color:green; color:white');
          };
          mosq.ondisconnect = function(rc) {
            $scope.$apply(function() {
              return $rootScope.onConnected = false;
            });
            console.log('%cDisconnected', 'background-color:red; color:white');
          };
          mosq.onmessage = function(topic, payload, qos) {
            console.log('Publish: ' + topic + '>%c' + payload, 'color:blue');
            $scope.$apply(function() {
              var ref;
              ref = void 0;
              return $scope.lightList[0].isOn = (ref = payload === txt_ON) !== null ? ref : {
                'true': false
              };
            });
          };
        };
        Page.prototype.connect = function() {
          mosq.connect($scope.server);
        };
        Page.prototype.disconnect = function() {
          mosq.disconnect();
        };
        Page.prototype.subscribe = function() {
          var topic;
          topic = void 0;
          topic = $('#sub-topic-text')[0].value;
          mosq.subscribe(topic, 0);
        };
        Page.prototype.unsubscribe = function() {
          var topic;
          topic = void 0;
          topic = $('#sub-topic-text')[0].value;
          mosq.unsubscribe(topic);
        };
        Page.prototype.publish = function() {
          var payload, topic;
          payload = void 0;
          topic = void 0;
          topic = $('#pub-topic-text')[0].value;
          payload = $('#payload-text')[0].value;
          mosq.publish(topic, payload, 0);
        };
        $scope.subPlease = function() {
          return mosq.subscribe($scope.tropic, 0);
        };
        $scope.pubThis = function(val) {
          var payload, topic;
          payload = void 0;
          topic = void 0;
          topic = $scope.tropic;
          payload = val;
          mosq.publish(topic, payload, 0);
        };
        return Page;
      })();
      $(function() {
        return Main.controller = new Main.Page;
      });
    }).call(this);
  });
  app.controller('AboutCtrl', function($scope, $ionicSideMenuDelegate) {
    return $scope.openMenu = function() {
      return $ionicSideMenuDelegate.toggleLeft();
    };
  });
}).call(this);
