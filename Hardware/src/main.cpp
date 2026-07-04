#include <Arduino.h>
#include <Wire.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define TILT_PIN 15
#define LED_PIN  2

// Raw I2C address for MPU6050
const int MPU_ADDR = 0x68; 

// ==========================================
// BLUETOOTH CONFIGURATION (BLE)
// Needs to be the same with the UUID di iOS (BluetoothService.swift)
// ==========================================
#define SERVICE_UUID           "12345678-1234-1234-1234-123456789012"
#define CHARACTERISTIC_RX_UUID "87654321-4321-4321-4321-210987654321" // Menerima perintah dari iPhone
#define CHARACTERISTIC_TX_UUID "abcdef01-abcd-abcd-abcd-abcdef012345" // Mengirim data ke iPhone

BLEServer *pServer = NULL;
BLECharacteristic *pTxCharacteristic = NULL;
bool deviceConnected = false;

// MPU6050 limit (smaller = more sensitive)
const float PUNCH_THRESHOLD = 15.0; 

// ==========================================
// DEBOUNCE VARIABLES
// ==========================================
unsigned long lastPunchTime = 0;         // Record last punch time
const unsigned long debounceDelay = 300; // Safe pause between punch (ms)

unsigned long lightOnTime = 0;           // Record when the light was turned on
const unsigned long timeoutDuration = 10000; // 10 seconds timeout (ms)
bool isTensed = false;                   // Track if pillow is currently waiting for a punch

// ==========================================
// BLE Connection Control
// ==========================================
class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
        deviceConnected = true;
        Serial.println("iPhone is connected");
    }
    void onDisconnect(BLEServer* pServer) {
        deviceConnected = false;
        Serial.println("iPhone disconnected");
        digitalWrite(LED_PIN, LOW); // turn off lights
        isTensed = false;           // Reset tensed state
        BLEDevice::startAdvertising(); // re-open connection paths
    }
};

// ==========================================
// ACCEPT INPUTS (iOS -> ESP32)
// ==========================================
class MyCharacteristicCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
        std::string rxValue = pCharacteristic->getValue();
        
        if (rxValue.length() > 0) {
            uint8_t command = rxValue[0];
            
            // 0x01 Means Tensed (Lights up), 0x00 means RELAXED (Lights off)
            if (command == 0x01) {
                digitalWrite(LED_PIN, HIGH);
                isTensed = true;
                lightOnTime = millis(); // Start the 10 seconds timer
                Serial.println("💡 STATUS: TENSED-> Pillow is ready to be smashed");
            } 
            else if (command == 0x00) {
                digitalWrite(LED_PIN, LOW);
                isTensed = false;       // Cancel the timer
                Serial.println("💤 STATUS: RELAXED -> pillow back to normal");
            }
        }
    }
};

void setup() {
    Serial.begin(115200);
    
    // 1. Setup Pin
    pinMode(TILT_PIN, INPUT);
    pinMode(LED_PIN, OUTPUT);
    digitalWrite(LED_PIN, LOW);

    // 2. Setup MPU6050 (I2C: SDA=21, SCL=22) using raw I2C
    Wire.begin(21, 22);
    
    // Wake up MPU6050
    Wire.beginTransmission(MPU_ADDR);
    Wire.write(0x6B); 
    Wire.write(0x00); 
    Wire.endTransmission(true);

    // Set Accelerometer to ±16g range
    Wire.beginTransmission(MPU_ADDR);
    Wire.write(0x1C); 
    Wire.write(0x18); 
    Wire.endTransmission(true);
    
    Serial.println("✅ MPU6050 Siap!");

    // 3. Setup BLE Server
    BLEDevice::init("SmashPad_Bantal");
    pServer = BLEDevice::createServer();
    pServer->setCallbacks(new MyServerCallbacks());

    BLEService *pService = pServer->createService(SERVICE_UUID);

    // Characteristics for ESP32 to report to iPhone
    pTxCharacteristic = pService->createCharacteristic(
                            CHARACTERISTIC_TX_UUID,
                            BLECharacteristic::PROPERTY_NOTIFY
                        );
    pTxCharacteristic->addDescriptor(new BLE2902());

    // Characteristics for iPhone to give input to ESP32
    BLECharacteristic *pRxCharacteristic = pService->createCharacteristic(
                                               CHARACTERISTIC_RX_UUID,
                                               BLECharacteristic::PROPERTY_WRITE
                                           );
    pRxCharacteristic->setCallbacks(new MyCharacteristicCallbacks());

    // 4. Start emit BLE
    pService->start();
    BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(SERVICE_UUID);
    pAdvertising->setScanResponse(true);
    pAdvertising->setMinPreferred(0x06);  
    pAdvertising->setMinPreferred(0x12);
    BLEDevice::startAdvertising();
    
    Serial.println("🚀 Waiting for connection to iPhone...");
}

void loop() {
    if (deviceConnected) {
        float accel_magnitude = 0.0;
        
        // A. Read MPU6050 using raw I2C
        Wire.beginTransmission(MPU_ADDR);
        Wire.write(0x3B); 
        Wire.endTransmission(false);
        Wire.requestFrom(MPU_ADDR, 6, true);

        if (Wire.available() == 6) {
            int16_t rawX = Wire.read() << 8 | Wire.read();
            int16_t rawY = Wire.read() << 8 | Wire.read();
            int16_t rawZ = Wire.read() << 8 | Wire.read();

            float ax = (rawX / 16384.0) * 9.81;
            float ay = (rawY / 16384.0) * 9.81;
            float az = (rawZ / 16384.0) * 9.81;

            // Calculate shock intensity (Magnitudo Vektor)
            accel_magnitude = sqrt(pow(ax, 2) + pow(ay, 2) + pow(az, 2));
        }

        // B. Read tilt sensor (Position shock)
        int tiltState = digitalRead(TILT_PIN);

        unsigned long currentTime = millis();

        // C. Check for 10 seconds timeout
        if (isTensed && (currentTime - lightOnTime >= timeoutDuration)) {
            digitalWrite(LED_PIN, LOW); // Turn off lights automatically
            isTensed = false;           // Reset tensed state
            Serial.println("⏱️ TIMEOUT: 10 seconds passed without a punch. Light turned off.");
        }

        // D. Detect smash & Apply non-blocking debounce
        if ((accel_magnitude > PUNCH_THRESHOLD || tiltState == HIGH) && (currentTime - lastPunchTime >= debounceDelay)) {
            Serial.print("💥 PILLOW SMASHED! power: ");
            Serial.print(accel_magnitude);
            Serial.println(" m/s^2");

            // turn off the light
            isTensed = false;
            digitalWrite(LED_PIN, LOW); // Turn off lights automatically

            // create punch intensity data "PUNCH:32.25"
            String txMessage = "PUNCH:" + String(accel_magnitude, 2);

            // Give signal and intensity to Iphone
            pTxCharacteristic->setValue(txMessage.c_str());
            pTxCharacteristic->notify();
            
            lastPunchTime = currentTime;
        }
    }
    
    delay(10); // Small delay so the esp doesn't overheat
}