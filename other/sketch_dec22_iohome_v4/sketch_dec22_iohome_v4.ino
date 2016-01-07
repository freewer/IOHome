#include <SPI.h>
#include <Ethernet.h>
#include <PubSubClient.h>

#include <Wire.h>
#include <DS3231.h>

DS3231 clock;
RTCDateTime dt;

#define RELAY1 8
#define RELAY2 9

char MQTT_SERVER[] = "test.mosquitto.org";
char* inTopic = "aW9ob21l";
char* clientId = "0";
byte mac[] = { 0x18, 0xfe, 0x34, 0xda, 0xbf, 0x1a };
int check = 1;

IPAddress dnServer(203, 144, 206, 49);
IPAddress gateway(192, 168, 10, 1);
IPAddress subnet(255, 255, 255, 0);
IPAddress ip(192, 168, 10, 125);

EthernetClient ethClient; // Ethernet object
PubSubClient client( MQTT_SERVER, 1883, callback, ethClient); // MQTT object

String timenow;
String today;
String _method;
String _id;
String _state;
String _time1;
String _time2;
String _day;

void setup() {
  Serial.begin(9600);
  
  pinMode(RELAY1, OUTPUT);
  pinMode(RELAY2, OUTPUT);

  clock.begin();
//  clock.setDateTime(__DATE__, __TIME__);

  Ethernet.begin(mac, ip, dnServer, gateway, subnet);
  Serial.print("IP: ");
  Serial.println(Ethernet.localIP());
  
  //-- Try to Connect Server --
  while (check) {
    if (client.connect(clientId)) {
      Serial.println("Successfully connected with MQTT");
      client.subscribe(inTopic); // Subcribe
      
      check = 0;
    } else {
      Serial.println("cant connected with MQTT");
    }
  }
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
      _time1 = "";
      checktime();
      digitalWrite(RELAY1, HIGH);
    }
    else if (_id == "0" && _state == "off"){
      _time1 = "";
      checktime();
      digitalWrite(RELAY1, LOW);
    }
    else if (_id == "1" && _state == "on"){
      _time2 = "";
      checktime();
      digitalWrite(RELAY2, HIGH);
    }
    else if (_id == "1" && _state == "off"){
      _time2 = "";
      checktime();
      digitalWrite(RELAY2, LOW);
    }
    else {
      Serial.println("No Message light On/Off");
    }
  }
  //------------Check Alert--------------------
  else if (_method == "alert"){
    if (_id == "0" && _state == "on"){
      checktime();
    }
    else if (_id == "0" && _state == "off"){
      _time1 = "";
      checktime();
    }
    else if (_id == "1" && _state == "on"){
      checktime();
    }
    else if (_id == "1" && _state == "off"){
      _time2 = "";
      checktime();
    }
    else {
      Serial.println("No Message Alert");
    }
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
  String light_time = String(array[3]);
  String light_days = String(array[4]);
  Serial.println(String("method = ") + light_method);
  Serial.println(String("ID = ") + light_id);
  Serial.println(String("Action = ") + light_state);
  Serial.println(String("time = ") + light_time);
  Serial.println(String("days = ") + light_days);
  Serial.println("***************");
  _method = light_method;
  _id = light_id;
  _state = light_state;
  if (_id == "0") {
    _time1 = light_time;
  }
  else if (_id == "1") {
    _time2 = light_time;
  }
  _day = light_days;
}

void checktime() {
  if (_time1 == timenow && _time2 == timenow){
    digitalWrite(RELAY1, HIGH);
    digitalWrite(RELAY2, HIGH);
  }
  else if (_time1 == timenow){
    digitalWrite(RELAY1, HIGH);
  }
  else if (_time2 == timenow){
    digitalWrite(RELAY2, HIGH);
  }
}

