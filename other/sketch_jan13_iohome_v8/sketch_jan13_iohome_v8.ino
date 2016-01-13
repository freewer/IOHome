#include <SPI.h>
#include <Ethernet.h>
#include <PubSubClient.h>

#include <Wire.h>
#include <DS3231.h>

DS3231 clock;
RTCDateTime dt;

#define RELAY1 4
#define RELAY2 5
#define LED1 6
#define LED2 7
#define LED3 8
int STATUS = A0;

char MQTT_SERVER[] = "test.mosquitto.org";
char* inTopic = "aW9ob21l";
char* clientId = "iohome0x0000";
byte mac[] = { 0x18, 0xfe, 0x34, 0xda, 0xbf, 0x1a };
int check = 1;

IPAddress dnServer(192, 168, 8, 1);
IPAddress gateway(192, 168, 8, 1);
IPAddress subnet(255, 255, 255, 0);
IPAddress ip(192, 168, 8, 125);

EthernetClient ethClient; // Ethernet object
PubSubClient client( MQTT_SERVER, 1883, callback, ethClient); // MQTT object

String timenow;
String today;
String _method;
String _id;
String _state;
String _timeON1;
String _timeON2;
String _day;
String _stateOFF;
String _timeOFF1;
String _timeOFF2;

void setup() {
  Serial.begin(9600);
  
  pinMode(RELAY1, OUTPUT);
  pinMode(RELAY2, OUTPUT);
  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);
  
  clock.begin();
//  clock.setDateTime(__DATE__, __TIME__);

//  Ethernet.begin(mac, ip, dnServer, gateway, subnet);
//  Serial.print("IP: ");
//  Serial.println(Ethernet.localIP());
//  
//  //-- Try to Connect Server --
//  while (check) {
//    if (client.connect(clientId)) {
//      Serial.println("Successfully connected with MQTT");
//      client.subscribe(inTopic); // Subcribe
//      
//      check = 0;
//    } else {
//      Serial.println("cant connected with MQTT");
//    }
//  }
  connect();
}

void loop() {
  client.loop();

  dt = clock.getDateTime();
  Serial.println(clock.dateFormat("H:i:s l", dt));
  timenow = clock.dateFormat("H:i", dt);
  today = clock.dateFormat("l", dt);

  //---------------Check light------------------
  if (_method == "light"){
    if (_id == "0" && _state == "on"){
      _timeON1 = "";
      _timeOFF1 = "";
      checktimeON();
      checktimeOFF();
      digitalWrite(RELAY1, HIGH);
    }
    else if (_id == "0" && _state == "off"){
      _timeON1 = "";
      _timeOFF1 = "";
      checktimeON();
      checktimeOFF();
      digitalWrite(RELAY1, LOW);
    }
    else if (_id == "1" && _state == "on"){
      _timeON2 = "";
      _timeOFF2 = "";
      checktimeON();
      checktimeOFF();
      digitalWrite(RELAY2, HIGH);
    }
    else if (_id == "1" && _state == "off"){
      _timeON2 = "";
      _timeOFF2 = "";
      checktimeON();
      checktimeOFF();
      digitalWrite(RELAY2, LOW);
    }
    else {
      Serial.println("No Message light On/Off");
    }
  }
  //------------Check Alert--------------------
  else if (_method == "alert"){
    if (_id == "0" && _state == "on" && _stateOFF == "true"){
      checktimeON();
      checktimeOFF();
    }
    else if (_id == "0" && _state == "on" && _stateOFF == "false"){
      _timeOFF1 = "";
      checktimeON();
      checktimeOFF();
    }
    else if (_id == "0" && _state == "off" && _stateOFF == "true"){
      _timeON1 = "";
      checktimeON();
      checktimeOFF();
    }
    else if (_id == "0" && _state == "off" && _stateOFF == "false"){
      _timeON1 = "";
      _timeOFF1 = "";
      checktimeON();
      checktimeOFF();
    }
    else if (_id == "1" && _state == "on" && _stateOFF == "true"){
      checktimeON();
      checktimeOFF();
    }
    else if (_id == "1" && _state == "on" && _stateOFF == "false"){
      _timeOFF2 = "";
      checktimeON();
      checktimeOFF();
    }
    else if (_id == "1" && _state == "off" && _stateOFF == "true"){
      _timeON2 = "";
      checktimeON();
      checktimeOFF();
    }
    else if (_id == "1" && _state == "off" && _stateOFF == "false"){
      _timeON2 = "";
      _timeOFF2 = "";
      checktimeON();
      checktimeOFF();
    }
    else {
      Serial.println("No Message Alert");
    }
  }
  //------------ON/OFF Model--------------------
  else if (_method == "1on") {
    digitalWrite(LED1, HIGH);
    }
  else if (_method == "1off") {
    digitalWrite(LED1, LOW);
    }
  else if (_method == "2on") {
    digitalWrite(LED2, HIGH);
    }
  else if (_method == "2off") {
    digitalWrite(LED2, LOW);
    }
  else if (_method == "3on") {
    digitalWrite(LED3, HIGH);
    }
  else if (_method == "3off") {
    digitalWrite(LED3, LOW);
    }
  else {
    Serial.println("No Message");
  }
  delay(1000);
}

void callback(char* topic, byte* payload, unsigned int length) {
  payload[length] = '\0';
  String strPayload = String((char*)payload);
  Serial.println(strPayload);
//  splitThis((char*)payload);
  char *buf = (char*)payload;
  int i;
  char *p;
  char *array[i];
  i = 0;
  p = strtok (buf,"/");  
  while (p != NULL)
  {
    array[i++] = p;
    p = strtok (NULL, "/");
  }
  Serial.println("***************");
  String light_method = String(array[0]);
  String light_id = String(array[1]);
  String light_state = String(array[2]);
  String light_timeON = String(array[3]);
  String light_days = String(array[4]);
  String light_stateOFF = String(array[5]);
  String light_timeOFF = String(array[6]);
  Serial.println(String("method = ") + light_method);
  Serial.println(String("ID = ") + light_id);
  Serial.println(String("Action = ") + light_state);
  Serial.println(String("timeON = ") + light_timeON);
  Serial.println(String("days = ") + light_days);
  Serial.println(String("StateOFF = ") + light_stateOFF);
  Serial.println(String("timeOFF = ") + light_timeOFF);
  Serial.println("***************");
  _method = light_method;
  _id = light_id;
  _state = light_state;
  if (_id == "0") {
    _timeON1 = light_timeON;
    _timeOFF1 = light_timeOFF;
  }
  else if (_id == "1") {
    _timeON2 = light_timeON;
    _timeOFF2 = light_timeOFF;
  }
  _day = light_days;
  _stateOFF = light_stateOFF;
}

void checktimeON() {
  if (_timeON1 == timenow && _timeON2 == timenow){
    digitalWrite(RELAY1, HIGH);
    digitalWrite(RELAY2, HIGH);
  }
  else if (_timeON1 == timenow){
    digitalWrite(RELAY1, HIGH);
  }
  else if (_timeON2 == timenow){
    digitalWrite(RELAY2, HIGH);
  }
}

void checktimeOFF() {
  if (_timeOFF1 == timenow && _timeOFF2 == timenow){
    digitalWrite(RELAY1, LOW);
    digitalWrite(RELAY2, LOW);
  }
  else if (_timeOFF1 == timenow){
    digitalWrite(RELAY1, LOW);
  }
  else if (_timeOFF2 == timenow){
    digitalWrite(RELAY2, LOW);
  }
}

void connect() {
  Ethernet.begin(mac, ip, dnServer, gateway, subnet);
  Serial.print("IP: ");
  Serial.println(Ethernet.localIP());
  
  //-- Try to Connect Server --
  while (check) {
    if (client.connect(clientId)) {
      Serial.println("Successfully connected with MQTT");
      client.subscribe(inTopic); // Subcribe
      analogWrite(STATUS, 255);
      check = 0;
    } else {
      Serial.println("cant connected with MQTT");
    }
  }
}
