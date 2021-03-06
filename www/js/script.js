(function() {
  var app;
  app = angular.module('myApp', ['ionic', 'ionic-timepicker']);
  app.config(function($stateProvider, $urlRouterProvider, $ionicConfigProvider) {
    $ionicConfigProvider.tabs.position('bottom');
    $stateProvider.state('tabs', {
      url: '/tab',
      controller: 'TabsCtrl',
      templateUrl: 'templates/tabs.html'
    }).state('tabs.home', {
      url: '/home',
      views: {
        'home-tab': {
          controller: 'HomeTabCtrl',
          templateUrl: 'templates/home.html'
        }
      }
    }).state('tabs.settings', {
      url: '/settings',
      views: {
        'settings-tab': {
          controller: 'lightCtrl',
          templateUrl: 'templates/settings.html'
        }
      }
    }).state('howto', {
      url: '/howto',
      controller: 'DevCtrl',
      templateUrl: 'templates/howto.html'
    }).state('info', {
      url: '/info',
      controller: 'DevCtrl',
      templateUrl: 'templates/info.html'
    }).state('dev', {
      url: '/dev',
      controller: 'DevCtrl',
      templateUrl: 'templates/dev.html'
    });
    return $urlRouterProvider.otherwise('/tab');
  });
  app.controller('TabsCtrl', function($scope, $rootScope, $ionicSideMenuDelegate, $state, $ionicHistory) {
    $scope.openMenu = function() {
      return $ionicSideMenuDelegate.toggleLeft();
    };
    $rootScope.lightList = [
      {
        text: "Switch 1",
        isOn: false,
        isAlert: false,
        alertDate: ['sun'],
        alertTime: '00:00',
        alertOff: false,
        alertTimeOff: '23:59'
      }, {
        text: "Switch 2",
        isOn: false,
        isAlert: false,
        alertDate: ['sun'],
        alertTime: '00:00',
        alertOff: false,
        alertTimeOff: '23:59'
      }
    ];
    $rootScope.dateList = [];
    $rootScope.currentLight = 0;
    $rootScope.chooseLight = function(light) {
      console.log('ส่ง' + light);
      return $rootScope.currentLight = light;
    };
    return $scope.setDate = function(id, date) {
      var currLight;
      currLight = $rootScope.lightList[$rootScope.currentLight].alertDate;
      if (currLight.indexOf(date) !== -1) {
        currLight.splice(currLight.indexOf(date), 1);
      } else {
        currLight.push(date);
      }
      console.log(currLight);
      $rootScope.switchAlarm();
    };
  });
  app.controller('lightCtrl', function($scope, $rootScope, $ionicSideMenuDelegate) {
    var leadingZero, timePickerCallback, timePickerCallbackOff;
    $scope.timePickerObject = {
      inputEpochTime: (new Date).getHours() * 60 * 60,
      step: 1,
      format: 24,
      titleLabel: 'Set Time ON',
      setLabel: 'SET',
      closeLabel: 'CLOSE',
      setButtonType: 'button-positive',
      closeButtonType: 'button-dark',
      callback: function(val) {
        timePickerCallback(val);
      }
    };
    timePickerCallback = function(val) {
      var selectedTime;
      if (typeof val === 'undefined') {
        console.log('Time not selected');
      } else {
        selectedTime = new Date(val * 1000);
        $rootScope.lightList[$rootScope.currentLight].alertTime = leadingZero(selectedTime.getUTCHours()) + ':' + leadingZero(selectedTime.getUTCMinutes());
        console.log('scope=' + $rootScope.lightList[$rootScope.currentLight].alertTime);
        console.log('Selected epoch is : ', val, 'and the time is ', selectedTime.getUTCHours(), ':', selectedTime.getUTCMinutes(), 'in UTC');
        $rootScope.switchAlarm();
      }
    };
    $scope.timePickerObjectOff = {
      inputEpochTime: (new Date).getHours() * 60 * 60,
      step: 1,
      format: 24,
      titleLabel: 'Set Time OFF',
      setLabel: 'SET',
      closeLabel: 'CLOSE',
      setButtonType: 'button-positive',
      closeButtonType: 'button-dark',
      callback: function(val) {
        timePickerCallbackOff(val);
      }
    };
    timePickerCallbackOff = function(val) {
      var selectedTime;
      if (typeof val === 'undefined') {
        console.log('Time not selected');
      } else {
        selectedTime = new Date(val * 1000);
        $rootScope.lightList[$rootScope.currentLight].alertTimeOff = leadingZero(selectedTime.getUTCHours()) + ':' + leadingZero(selectedTime.getUTCMinutes());
        console.log('scope=' + $rootScope.lightList[$rootScope.currentLight].alertTimeOff);
        console.log('Selected epoch is : ', val, 'and the time is ', selectedTime.getUTCHours(), ':', selectedTime.getUTCMinutes(), 'in UTC');
        $rootScope.switchAlarm();
      }
    };
    $('.clockpicker').clockpicker();
    $scope.dayList = [
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
    return leadingZero = function(num) {
      if (num <= 9) {
        return '0' + num;
      } else {
        return num;
      }
    };
  });
  app.controller('HomeTabCtrl', function($scope, $rootScope, $ionicSideMenuDelegate) {
    var alert_OFF, alert_ON, splitter, txt_OFF, txt_ON;
    txt_ON = 'on';
    txt_OFF = 'off';
    splitter = '/';
    $scope.server = 'ws://test.mosquitto.org:8080/mqtt';
    $scope.tropic = 'aW9ob21l';
    $rootScope.onConnected = false;
    alert_ON = 'blank on';
    alert_OFF = 'blank off';
    $rootScope.switchLight = function() {
      console.log('switchLight ID ' + $rootScope.currentLight);
      if ($scope.lightList[$rootScope.currentLight].isOn === false) {
        return $scope.pubThis('light' + splitter + $rootScope.currentLight + splitter + txt_OFF);
      } else {
        return $scope.pubThis('light' + splitter + $rootScope.currentLight + splitter + txt_ON);
      }
    };
    $rootScope.switchAlarm = function() {
      console.log('switchAlarm ID ' + $rootScope.currentLight);
      if ($scope.lightList[$rootScope.currentLight].isAlert === false) {
        alert_ON = 'off';
        $scope.pubThis('alert' + splitter + $rootScope.currentLight + splitter + alert_ON + splitter + $rootScope.lightList[$rootScope.currentLight].alertTime + splitter + $rootScope.lightList[$rootScope.currentLight].alertDate + splitter + $rootScope.lightList[$rootScope.currentLight].alertOff + splitter + $rootScope.lightList[$rootScope.currentLight].alertTimeOff);
      } else if ($scope.lightList[$rootScope.currentLight].isAlert === true) {
        alert_ON = 'on';
        $scope.pubThis('alert' + splitter + $rootScope.currentLight + splitter + alert_ON + splitter + $rootScope.lightList[$rootScope.currentLight].alertTime + splitter + $rootScope.lightList[$rootScope.currentLight].alertDate + splitter + $rootScope.lightList[$rootScope.currentLight].alertOff + splitter + $rootScope.lightList[$rootScope.currentLight].alertTimeOff);
      } else if ($scope.lightList[$rootScope.currentLight].alertOff === false) {
        alert_OFF = 'off';
        $scope.pubThis('alert' + splitter + $rootScope.currentLight + splitter + alert_ON + splitter + $rootScope.lightList[$rootScope.currentLight].alertTime + splitter + $rootScope.lightList[$rootScope.currentLight].alertDate + splitter + $rootScope.lightList[$rootScope.currentLight].alertOff + splitter + $rootScope.lightList[$rootScope.currentLight].alertTimeOff);
      } else if ($scope.lightList[$rootScope.currentLight].alertOff === true) {
        alert_OFF = 'on';
        $scope.pubThis('alert' + splitter + $rootScope.currentLight + splitter + alert_ON + splitter + $rootScope.lightList[$rootScope.currentLight].alertTime + splitter + $rootScope.lightList[$rootScope.currentLight].alertDate + splitter + $rootScope.lightList[$rootScope.currentLight].alertOff + splitter + $rootScope.lightList[$rootScope.currentLight].alertTimeOff);
      } else {
        $scope.pubThis('No Alert');
      }
    };
    return (function() {
      window.Main = {};
      Main.Page = (function() {
        var Page, mosq;
        mosq = null;
        Page = function() {
          var _this;
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
          topic = $('#sub-topic-text')[0].value;
          mosq.subscribe(topic, 0);
        };
        Page.prototype.unsubscribe = function() {
          var topic;
          topic = $('#sub-topic-text')[0].value;
          mosq.unsubscribe(topic);
        };
        Page.prototype.publish = function() {
          var payload, topic;
          console.log($('#pub-led-text')[0].value + $('#pub-switch-text')[0].value);
          mosq.connect($scope.server);
          topic = $scope.tropic;
          payload = $('#pub-led-text')[0].value + $('#pub-switch-text')[0].value;
          mosq.publish(topic, payload, 0);
        };
        $scope.subPlease = function() {
          return mosq.subscribe($scope.tropic, 0);
        };
        $scope.pubThis = function(val) {
          var payload, topic;
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
  return app.controller('DevCtrl', function($scope, $rootScope, $ionicSideMenuDelegate, $state, $ionicHistory) {
    var alert_OFF, alert_ON, splitter, txt_OFF, txt_ON;
    $scope.openMenu = function() {
      return $ionicSideMenuDelegate.toggleLeft();
    };
    $rootScope.lightList = [
      {
        text: "Switch 1",
        isOn: false,
        isAlert: false,
        alertDate: ['sun'],
        alertTime: '00:00',
        alertOff: false,
        alertTimeOff: '23:59'
      }, {
        text: "Switch 2",
        isOn: false,
        isAlert: false,
        alertDate: ['sun'],
        alertTime: '00:00',
        alertOff: false,
        alertTimeOff: '23:59'
      }
    ];
    txt_ON = 'on';
    txt_OFF = 'off';
    splitter = '/';
    $scope.server = 'ws://test.mosquitto.org:8080/mqtt';
    $scope.tropic = 'aW9ob21l';
    $rootScope.onConnected = false;
    alert_ON = 'blank on';
    alert_OFF = 'blank off';
    return (function() {
      window.Main = {};
      Main.Page = (function() {
        var Page, mosq;
        mosq = null;
        Page = function() {
          var _this;
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
          topic = $('#sub-topic-text')[0].value;
          mosq.subscribe(topic, 0);
        };
        Page.prototype.unsubscribe = function() {
          var topic;
          topic = $('#sub-topic-text')[0].value;
          mosq.unsubscribe(topic);
        };
        Page.prototype.publish = function() {
          var payload, topic;
          console.log($('#pub-led-text')[0].value + $('#pub-switch-text')[0].value);
          mosq.connect($scope.server);
          topic = $scope.tropic;
          payload = $('#pub-led-text')[0].value + $('#pub-switch-text')[0].value;
          mosq.publish(topic, payload, 0);
        };
        $scope.subPlease = function() {
          return mosq.subscribe($scope.tropic, 0);
        };
        $scope.pubThis = function(val) {
          var payload, topic;
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
}).call(this);
