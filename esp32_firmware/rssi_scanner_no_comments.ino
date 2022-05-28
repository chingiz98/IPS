#include <WiFi.h>
#include "src/dependencies/WiFiClientSecure/WiFiClientSecure.h"
#include <time.h>
#include <PubSubClient.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>

#ifndef SECRET
const char ssid[] = "WIFI_SSID";
const char pass[] = "WIFI_PASSWORD";

#define HOSTNAME "mqtt_test"

const char* yandexIoTCoredeviceId = "core_device_id";
const char *MQTT_HOST = "mqtt.cloud.yandex.net";
const int MQTT_PORT = 8883;
const char *registryId = "registry_id";
const char *MQTT_PASS = "mqtt_passowrd*";

const char *STATION_X = "0";
const char *STATION_Y = "500";

#define WHITE_LIST_SIZE 3
String whiteList[WHITE_LIST_SIZE] = { "c1:80:fe:59:19:68", "f1:22:1e:1e:23:61", "f2:6a:1a:d3:47:8a" };


const char* local_root_ca = \
                            "-----BEGIN CERTIFICATE-----\n\
MIIFGTCCAwGgAwIBAgIQJMM7ZIy2SYxCBgK7WcFwnjANBgkqhkiG9w0BAQ0FADAf\
MR0wGwYDVQQDExRZYW5kZXhJbnRlcm5hbFJvb3RDQTAeFw0xMzAyMTExMzQxNDNa\
Fw0zMzAyMTExMzUxNDJaMB8xHTAbBgNVBAMTFFlhbmRleEludGVybmFsUm9vdENB\
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAgb4xoQjBQ7oEFk8EHVGy\
1pDEmPWw0Wgw5nX9RM7LL2xQWyUuEq+Lf9Dgh+O725aZ9+SO2oEs47DHHt81/fne\
5N6xOftRrCpy8hGtUR/A3bvjnQgjs+zdXvcO9cTuuzzPTFSts/iZATZsAruiepMx\
SGj9S1fGwvYws/yiXWNoNBz4Tu1Tlp0g+5fp/ADjnxc6DqNk6w01mJRDbx+6rlBO\
aIH2tQmJXDVoFdrhmBK9qOfjxWlIYGy83TnrvdXwi5mKTMtpEREMgyNLX75UjpvO\
NkZgBvEXPQq+g91wBGsWIE2sYlguXiBniQgAJOyRuSdTxcJoG8tZkLDPRi5RouWY\
gxXr13edn1TRDGco2hkdtSUBlajBMSvAq+H0hkslzWD/R+BXkn9dh0/DFnxVt4XU\
5JbFyd/sKV/rF4Vygfw9ssh1ZIWdqkfZ2QXOZ2gH4AEeoN/9vEfUPwqPVzL0XEZK\
r4s2WjU9mE5tHrVsQOZ80wnvYHYi2JHbl0hr5ghs4RIyJwx6LEEnj2tzMFec4f7o\
dQeSsZpgRJmpvpAfRTxhIRjZBrKxnMytedAkUPguBQwjVCn7+EaKiJfpu42JG8Mm\
+/dHi+Q9Tc+0tX5pKOIpQMlMxMHw8MfPmUjC3AAd9lsmCtuybYoeN2IRdbzzchJ8\
l1ZuoI3gH7pcIeElfVSqSBkCAwEAAaNRME8wCwYDVR0PBAQDAgGGMA8GA1UdEwEB\
/wQFMAMBAf8wHQYDVR0OBBYEFKu5xf+h7+ZTHTM5IoTRdtQ3Ti1qMBAGCSsGAQQB\
gjcVAQQDAgEAMA0GCSqGSIb3DQEBDQUAA4ICAQAVpyJ1qLjqRLC34F1UXkC3vxpO\
nV6WgzpzA+DUNog4Y6RhTnh0Bsir+I+FTl0zFCm7JpT/3NP9VjfEitMkHehmHhQK\
c7cIBZSF62K477OTvLz+9ku2O/bGTtYv9fAvR4BmzFfyPDoAKOjJSghD1p/7El+1\
eSjvcUBzLnBUtxO/iYXRNo7B3+1qo4F5Hz7rPRLI0UWW/0UAfVCO2fFtyF6C1iEY\
/q0Ldbf3YIaMkf2WgGhnX9yH/8OiIij2r0LVNHS811apyycjep8y/NkG4q1Z9jEi\
VEX3P6NEL8dWtXQlvlNGMcfDT3lmB+tS32CPEUwce/Ble646rukbERRwFfxXojpf\
C6ium+LtJc7qnK6ygnYF4D6mz4H+3WaxJd1S1hGQxOb/3WVw63tZFnN62F6/nc5g\
6T44Yb7ND6y3nVcygLpbQsws6HsjX65CoSjrrPn0YhKxNBscF7M7tLTW/5LK9uhk\
yjRCkJ0YagpeLxfV1l1ZJZaTPZvY9+ylHnWHhzlq0FzcrooSSsp4i44DB2K7O2ID\
87leymZkKUY6PMDa4GkDJx0dG4UXDhRETMf+NkYgtLJ+UIzMNskwVDcxO4kVL+Hi\
Pj78bnC5yCw8P5YylR45LdxLzLO68unoXOyFz1etGXzszw8lJI9LNubYxk77mK8H\
LpuQKbSbIERsmR+QqQ==\n\
-----END CERTIFICATE-----\n";

#endif

const char MQTT_SUB_TOPIC[] = "home/" HOSTNAME "/in";
const char MQTT_PUB_TOPIC[] = "home/" HOSTNAME "/out";



String topicEvents = String("$registries/") +  String(registryId) + String("/events");

WiFiClientSecure net;
PubSubClient client(net);

BLEScan* pBLEScan;
int beaconScanTime = 4;

time_t now;
unsigned long lastMillis = 0;


typedef struct {
  char address[17]; 
  int rssi;
  int count;
} BeaconData;

uint8_t bufferIndex = 0;  
BeaconData buffer[50];   
uint8_t message_char_buffer[MQTT_MAX_PACKET_SIZE];


void mqtt_connect()
{
  while (!client.connected()) {
    if (client.connect(HOSTNAME, yandexIoTCoredeviceId, MQTT_PASS)) {
    } else {
      delay(5000);
    }
  }

}

bool isInWhiteList(String value) {
  for (int i = 0; i < WHITE_LIST_SIZE; i++) {
    if (value.equals(whiteList[i])) {
      return true;
    }
  }
  return false;
}

class MyAdvertisedDeviceCallbacks : public BLEAdvertisedDeviceCallbacks {
  public:

    void onResult(BLEAdvertisedDevice advertisedDevice) {

      if (!isInWhiteList(String(advertisedDevice.getAddress().toString().c_str()))) {
        return;
      }

      extern uint8_t bufferIndex;
      extern BeaconData buffer[];
      if (bufferIndex >= 50) {
        return;
      }

      int index = findElementIndex(String(advertisedDevice.getAddress().toString().c_str()));
      if (advertisedDevice.haveRSSI()) {
        buffer[index].rssi = buffer[index].rssi + advertisedDevice.getRSSI();
      } else {
        buffer[index].rssi =  0;
      }

      strcpy (buffer[index].address, advertisedDevice.getAddress().toString().c_str());
      buffer[index].count = buffer[index].count + 1;
    }

    int findElementIndex(String mac) {
      for (int i = 0; i < bufferIndex; i++) {
        if (String(buffer[i].address).equals(mac)) {
          return i;
        }
      }

      bufferIndex += 1;
      return bufferIndex - 1;
    }
};

void receivedCallback(char* topic, byte* payload, unsigned int length) {
}

void setup()
{
  Serial.begin(9600);

  WiFi.setHostname(HOSTNAME);
  WiFi.mode(WIFI_AP_STA);
  WiFi.begin(ssid, pass);
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(1000);
  }
  configTime(-5 * 3600, 0, "pool.ntp.org", "time.nist.gov");
  now = time(nullptr);
  while (now < 1510592825) {
    delay(500);
    now = time(nullptr);
  }
  struct tm timeinfo;
  gmtime_r(&now, &timeinfo);

  net.setCACert(local_root_ca);
  client.setServer(MQTT_HOST, MQTT_PORT);
  client.setBufferSize(2048);
  client.setCallback(receivedCallback);
  mqtt_connect();
  BLEDevice::init("");
}

void ScanBeacons() {
  delay(1000);
  for (int i = 0; i < bufferIndex; i++) {
    buffer[i].count = 0;
    buffer[i].rssi = 0;
  }
  bufferIndex = 0;

  BLEScan* pBLEScan = BLEDevice::getScan(); 
  MyAdvertisedDeviceCallbacks cb;
  pBLEScan->setAdvertisedDeviceCallbacks(&cb);
  pBLEScan->setActiveScan(true);
  BLEScanResults foundDevices = pBLEScan->start(beaconScanTime);
  for (uint8_t i = 0; i < bufferIndex; i++) {
    buffer[i].rssi = buffer[i].rssi / buffer[i].count;
  }

  pBLEScan->stop();
  delay(1000);
}

void loop()
{
  boolean result;
  ScanBeacons();

  now = time(nullptr);
  if (WiFi.status() != WL_CONNECTED)
  {
    while (WiFi.waitForConnectResult() != WL_CONNECTED)
    {
      WiFi.begin(ssid, pass);
      delay(10);
    }
  }
  else
  {
    if (!client.connected())
    {
      esp_bt_controller_mem_release(ESP_BT_MODE_CLASSIC_BT);
      BLEDevice::deinit(false);

      mqtt_connect();
      if (!(BLEDevice::getInitialized())) {
        BLEDevice::init("");
      }
    }
    else
    {
      client.loop();
    }
  }

  String payloadString = "{\"e\":[";
  for (uint8_t i = 0; i < bufferIndex; i++) {
    payloadString += "{\"m\":\"";
    payloadString += String(buffer[i].address);
    payloadString += "\",\"r\":\"";
    payloadString += String(buffer[i].rssi);
    payloadString += "\"}";
    if (i < bufferIndex - 1) {
      payloadString += ',';
    }
  }
  
  payloadString += "],\"st\":\"";
  payloadString += String(WiFi.macAddress());
  payloadString += "\",\"coords\":{\"x\":\"";
  payloadString += String(STATION_X);
  payloadString += "\",\"y\":\"";
  payloadString += String(STATION_Y);
  payloadString += "\"}}";

  payloadString.getBytes(message_char_buffer, payloadString.length() + 1);
  result = client.publish(topicEvents.c_str(), message_char_buffer, payloadString.length(), false);
  delay(3000);
}
