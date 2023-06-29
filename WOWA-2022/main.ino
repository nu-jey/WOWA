#include <SoftwareSerial.h>
#include<Wire.h>
#define USE_ARDUINO_INTERRUPTS true
#include <PulseSensorPlayground.h>

//// 블루투스 연결 관련 변수
#define RXD 3 // 아두이노 우노의 RXD(3)와 TXD(2) 사용  
#define TXD 2
SoftwareSerial bluetooth(RXD, TXD);  // 블루투스 연결 3번, 2번 핀 사용해서 객체 생성

// 제어 변수
int main_mode = 0;
int sensor_1_mode = 0;
int sensor_2_mode = 0;
int sensor_3_mode = 0;
int input;  // 수신 받은 제어 변수 관련 값

// 시간 관련 변수
unsigned long pre_time, cur_time;
int time_interval = 10;             // 센서 정보 수집 간격 -> 샘플링 간격
unsigned long chk_time;             // 동작 확인 시 다음 동작 간의 term 제어를 위한 시간 변수
unsigned long chk_ps_time;          // 동작 정보 수집 시 제한 시간 제어를 위한 시간 변수
unsigned long chk_mg_time;          // 근육 성장치 정보 수집 시 제한 시간 제어를 위한 시간 변수
unsigned long chk_rest_time;        // 근육 성장치 정보 수집 시 제한 시간 제어를 위한 시간 변수
int chk_time_interval = 1500;       // 다음 동작 간 시간 간격
int chk_ps_time_interval = 3000;    // 다음 동작 간 시간 간격
int chk_mg_time_interval = 3000;    // 근육 성정치 확인 시간 간격
int chk_rest_time_interval = 6000;        // 근육 성장치 정보 수집 시 제한 시간 제어를 위한 시간 변수

// 가속도 센서 값 관련 변수
double pre_acc, cur_acc = 0;
double pre_spd, cur_spd = 0;
double pre_pos, cur_pos = 0;
double max_pos, min_pos = 0;
double target_displacement = 70.0;   // 목표 변위 -> 기본 값으로 70 설정 
double delta_time = time_interval / 1000.0;  // 델타 타임 -> 샘플링 간격
double err_range = 10;                        // 궤적 오차 범위
bool chk_reps = false;                      // 개수 카운팅 추가 신호 전송을 위한 변수
bool chk_max, chk_min = false;              // 자세 비교 후 값 제어 변수
const int MPU_ADDR = 0x68;    // I2C통신을 위한 MPU6050의 주소
int16_t AcX, AcY, AcZ, Tmp, GyX, GyY, GyZ;   // 가속도(Acceleration) 와
void getRawData();  // 센서값 얻는 서브함수의 프로토타입 선언
int count = 0;
bool is_chk = false; // 동작 확인 제어 변수
bool chk_ps = false;
int pre_mode = 0;

// 심박 센서 값 관련 변수
int cur_heart = 0;                  // BPM 저장 변수
int pre_cur_heart = 0;
const int PulseWire = 0;            // 연결할 아날로그 핀
int Threshold = 550;                // 한계점 설정
PulseSensorPlayground pulseSensor;  //pulseSensor 객체 생성

// emg 센서 값 관련 변수
int max_emg = 300;
int cur_emg = 300;
bool chk_muscle_growth = false;
double avg_emg = 600.0;

// LPF관련 변수
#define ANALOG_PIN_TIMER_INTERVAL 2             // -> 샘픞링 타임 결정 시 사용 
static long analogPinTimer = 0;
unsigned long thisMillis_old;
int fc = 5;                                     // 차단할 기준 주파수
double dt = ANALOG_PIN_TIMER_INTERVAL / 1000.0; // sampling time
double lambda = 2 * PI * fc * dt;               // 람다를 통해서 차단할 기준 주파수 결정
double x_f = 0.0;             // 자세 측정 시 사용
double pre_x_f = 0.0;         // 이전 측정 값 저장
double emg_f = 0.0;           // 자세 측정 시 사용
double pre_emg_f = 0.0;       // 이전 측정 값 저장

void setup() {
  Serial.begin(9600);

  // 블루투스
  bluetooth.begin(9600);  // 블루투스 연결
  pre_time = millis();    // 이전 시간 값 초기화

  // 자이로 센서
  initSensor(); // 자이로 센서 초기화


  // 심박 센서
  pulseSensor.analogInput(PulseWire);   // 아날로그 핀 연결
  pulseSensor.setThreshold(Threshold);  // 한계점 설정
  if (pulseSensor.begin()) {
    // Serial.println("We created a pulseSensor Object !");
    // pulseSensor 객체를 동작 시킨다.
  }

  // EMG 센서
  pinMode(10, INPUT);
  pinMode(11, INPUT);

  // 초기 세팅
  main_mode = 1;
  sensor_1_mode = 0;
  sensor_2_mode = 1; // 심박 센서는 항상 동작하도록 
  sensor_3_mode = 0;

  delay(200); // 초기화 세팅을 위한 잠시 대기
}

void loop() {
  cur_time = millis();                          // 현재 시간 초기화
  if (cur_time - pre_time >= time_interval) {   // 지정한 시간 간격이 지났다면
    pre_time = cur_time;                        // 이전 시간 초기화

    // 블루투스: 앱으로 부터 값을 수신
    if (bluetooth.available()) {  //
      int input_a = bluetooth.read();
      Serial.println(input_a);
      if (input_a < 60) {
        switch (input_a) {
          case 0: main_mode = 0; break;                         // 전체 아두이노 제어: on
          case 1: main_mode = 1; break;                         // 전체 아두이노 제어: off
          case 10: sensor_1_mode = 0; break;                    // 가속도 센서 off: 운동 보조 모드
          case 11: sensor_1_mode = 1; pre_mode = 1; count = 0; break;      // 가속도 센서 on: 운동 보조 모드 -> 푸쉬
          case 12: sensor_1_mode = 2; pre_mode = 2; count = 0; break;      // 가속도 센서 on: 운동 보조 모드 -> 풀
          case 13: sensor_1_mode = 3; sensor_2_mode = 1; break; // 가속도 센서 on: 자세 측정 모드 -> 푸쉬
          case 14: sensor_1_mode = 4; sensor_2_mode = 1; break; // 가속도 센서 on: 자세 측정 모드 -> 풀
          case 20: sensor_2_mode = 0; break;                    // 심박 센선 off
          case 21: sensor_2_mode = 1; break;                    // 심박 센서 on
          case 30: sensor_3_mode = 0; break;                    // emg 센서 off
          case 31: sensor_3_mode = 1; break;                    // emg 센서 on: 근육 활성화 측정 모드
          case 32: sensor_3_mode = 2; break;                    // emg 센서 on: 근육 성장치 측정 모드
          default:
            Serial.print("Unknown message: ");
            Serial.println(input_a);
            break;
        }
      }
      else {  // 휴식 시간 확인
        count = 0;
        sensor_1_mode = 0;                                      // 자이로 센서 off
        chk_rest_time = millis();                               // 현재 시각을 기준으로 휴식 시간 시작
        chk_rest_time_interval = input_a * 1000;                // 휴식시간 불러오기
        Serial.print("휴식시간: ");
        Serial.println(chk_rest_time_interval);
      }
    }

    // 휴식 타이머 확인
    if ((chk_rest_time != 0)  && (cur_time - chk_rest_time) >= chk_rest_time_interval) { //휴식 시간이 지났다면
      Serial.println("휴식시간 끝");
      sensor_1_mode = pre_mode; // 이전 운동 모드로 다시 불러와서 진행
      chk_rest_time = 0;        // 휴식 시간 변수 초기화
    }


    // ----------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------
    //                              운동 모드 - 자이로 가속도 센서 & 심박 센서 & EMG 센서
    // ----------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------
    if (main_mode == 1) {
      // ----------------------------------------------------------------------------------------
      // ----------------------------------------------------------------------------------------
      // ----------------------------------------------------------------------------------------
      //                                         자이로 가속도 센서
      // ----------------------------------------------------------------------------------------
      // ----------------------------------------------------------------------------------------
      // ----------------------------------------------------------------------------------------
      if (sensor_1_mode == 1 || sensor_1_mode == 2) {
        // 자이로 가속도 - 운동 보조 모드
        getRawData();          // 센서값 얻어오는 함수 호출 -> 가속도 값

        // push & pull 차이에 다른 센서 값 전처리 -> 센서의 방향 전환에 따른 중력 가속도 적용 방향으로 인한 ~
        if (sensor_1_mode == 1) { // push
          AcX += 15350; // 계산의 편리를 위하여 값 변환
        }
        else if (sensor_1_mode == 2) {// pull
          AcX -= 17350; // 계산의 편리를 위하여 값 변환
        }

        // 노이즈 제거를 위한 LPF 필터링
        x_f = lpf(AcX, pre_x_f);  // 필터 적용
        pre_x_f = x_f;            // 이전 값에 저장 -> 다음번 필터링 시 사용
        cur_acc = x_f;            // 현재 가속도에 초기화 시킨다.

        // 수치 적분 -> 위치 값 구하기
        if (sensor_1_mode == 1) {// ----------------------push-----------------------
          cur_spd = pre_spd + 0.5 * (cur_acc - pre_acc) * delta_time;  // 현재 속도 = 이전속도 + 0.5 *(현재 가속도 - 예전 가속도) * △t
          if (cur_spd < 0) { // 진동으로 인한
            cur_pos = pre_pos + 0.5 * (cur_spd - pre_spd) * delta_time;  // 현재 위치 = 이전 위치 + 0.5 * (현재 속도 - 이전속도) * △t
          }

          // 자세 체크 알고리즘
          // minpos와 maxpos 간의 거리 차이를 계산 -> 기준 값을 넘어서면 n초가 delay 후 minpos와 maxpos를 현재 값으로 초기화
          double tmp_pos_for_chk = cur_pos *  -1000; // 계산의 편리를 위하여 값을 변환

          if (!is_chk) {
            // 최소 위치와 최대 위치 갱신
            if (tmp_pos_for_chk < min_pos) {
              min_pos = tmp_pos_for_chk;
            }
            if (tmp_pos_for_chk > max_pos) {
              max_pos = tmp_pos_for_chk;
            }

            double tmp_displacement = max_pos - min_pos;
            // 변위 확인
            if (tmp_displacement > (target_displacement - err_range)) {
              count += 1;
              chk_time = millis(); // 현재 시간 초기화 -> 개수 카운팅 후 n초 후 다시 확인 재개
              is_chk = true;
              info_to_app(count, pre_cur_heart, avg_emg);
              Serial.println(cur_heart);
            }
          }
          else {
            min_pos = tmp_pos_for_chk;
            max_pos = tmp_pos_for_chk;
            if (cur_time - chk_time >= chk_time_interval) {
              is_chk = false;
            }
          }
        } else if (sensor_1_mode == 2) {// ---------------------pull------------------------
          cur_spd = pre_spd + 0.5 * (cur_acc - pre_acc) * delta_time;  // 현재 속도 = 이전속도 + 0.5 *(현재 가속도 - 예전 가속도) * △t
          if (cur_spd > 0) {
            cur_pos = pre_pos + 0.5 * (cur_spd - pre_spd) * delta_time;  // 현재 위치 = 이전 위치 + 0.5 * (현재 속도 - 이전속도) * △t
          }
          // 자세 체크 알고리즘
          // minpos와 maxpos 간의 거리 차이를 계산 -> 기준 값을 넘어서면 n초가 delay 후 minpos와 maxpos를 현재 값으로 초기화

          double tmp_pos_for_chk = cur_pos *  1000; // 계산의 편리를 위하여 값을 변환

          if (!is_chk) {
            // 최소 위치와 최대 위치 갱신
            if (tmp_pos_for_chk < min_pos) {
              min_pos = tmp_pos_for_chk;
            }
            if (tmp_pos_for_chk > max_pos) {
              max_pos = tmp_pos_for_chk;
            }

            double tmp_displacement = max_pos - min_pos;
            // 변위 확인
            if (tmp_displacement > (target_displacement - err_range)) {
              count += 1;
              chk_time = millis(); // 현재 시간 초기화 -> 개수 카운팅 후 n초 후 다시 확인 재개
              is_chk = true;
              info_to_app(count, pre_cur_heart, avg_emg);
              Serial.println(cur_heart);
            }
          }
          else {
            min_pos = tmp_pos_for_chk;
            max_pos = tmp_pos_for_chk;
            if (cur_time - chk_time >= chk_time_interval) {
              is_chk = false;
            }
          }
        }

        // 관련 변수 초기화
        pre_acc = cur_acc;
        pre_spd = cur_spd;
        pre_pos = cur_pos;

      } else if (sensor_1_mode == 3) {
        // 자이로 가속도 - 자세 측정 모드
        // 사용자 동작을 기반으로 운동 궤적 측정
        if (!chk_ps) {
          Serial.println("측정 시작");
          delay(3000);
          chk_ps = true;
          max_pos = 0;
          min_pos = 0;
          chk_ps_time = millis();
        }
        else {
          if ((cur_time - chk_ps_time) <= chk_ps_time_interval) {
            Serial.println("측정 중...");
            getRawData();             // 센서값 얻어오는 함수 호출 -> 가속도 값
            AcX += 15350;             // 계산의 편리를 위하여 값 변환

            // 노이즈 제거를 위한 LPF 필터링
            x_f = lpf(AcX, pre_x_f);  // 필터 적용
            pre_x_f = x_f;            // 이전 값에 저장 -> 다음번 필터링 시 사용
            cur_acc = x_f;            // 현재 가속도에 초기화 시킨다.

            cur_spd = pre_spd + 0.5 * (cur_acc - pre_acc) * delta_time;  // 현재 속도 = 이전속도 + 0.5 *(현재 가속도 - 예전 가속도) * △t
            if (cur_spd < 0) {
              cur_pos = pre_pos + 0.5 * (cur_spd - pre_spd) * delta_time;  // 현재 위치 = 이전 위치 + 0.5 * (현재 속도 - 이전속도) * △t
            }

            double tmp_pos_for_chk = cur_pos *  -1000; // 계산의 편리를 위하여 값을 변환
            if (tmp_pos_for_chk < min_pos) {
              min_pos = tmp_pos_for_chk;
            }
            if (tmp_pos_for_chk > max_pos) {
              max_pos = tmp_pos_for_chk;
            }
          }
          else {
            target_displacement = max_pos - min_pos;
            min_pos = 0;
            max_pos = 0;
            chk_ps = false;
            sensor_1_mode = 0;
            Serial.println("측정 완료...");
          }
        }
      } else if (sensor_1_mode == 4) {
        // 자이로 가속도 - 자세 측정 모드 종료
        if (!chk_ps) {
          Serial.println("측정 시작");
          delay(3000);
          chk_ps = true;
          max_pos = 0;
          min_pos = 0;
          chk_ps_time = millis();
        }
        else {
          if ((cur_time - chk_ps_time) <= chk_ps_time_interval) {
            Serial.println("측정 중...");
            getRawData();             // 센서값 얻어오는 함수 호출 -> 가속도 값
            AcX -= 17350; // 계산의 편리를 위하여 값 변환


            // 노이즈 제거를 위한 LPF 필터링
            x_f = lpf(AcX, pre_x_f);  // 필터 적용
            pre_x_f = x_f;            // 이전 값에 저장 -> 다음번 필터링 시 사용
            cur_acc = x_f;            // 현재 가속도에 초기화 시킨다.

            cur_spd = pre_spd + 0.5 * (cur_acc - pre_acc) * delta_time;  // 현재 속도 = 이전속도 + 0.5 *(현재 가속도 - 예전 가속도) * △t
            if (cur_spd > 0) {
              cur_pos = pre_pos + 0.5 * (cur_spd - pre_spd) * delta_time;  // 현재 위치 = 이전 위치 + 0.5 * (현재 속도 - 이전속도) * △t
            }
            // 자세 체크 알고리즘
            // minpos와 maxpos 간의 거리 차이를 계산 -> 기준 값을 넘어서면 n초가 delay 후 minpos와 maxpos를 현재 값으로 초기화
            double tmp_pos_for_chk = cur_pos *  1000; // 계산의 편리를 위하여 값을 변환

            if (tmp_pos_for_chk < min_pos) {
              min_pos = tmp_pos_for_chk;
            }
            if (tmp_pos_for_chk > max_pos) {
              max_pos = tmp_pos_for_chk;
            }
          }
          else {
            target_displacement = max_pos - min_pos;
            min_pos = 0;
            max_pos = 0;
            chk_ps = false;
            sensor_1_mode = 0;
            Serial.println("측정 완료...");
          }
        }

      }

      // ----------------------------------------------------------------------------------------
      // ----------------------------------------------------------------------------------------
      // ----------------------------------------------------------------------------------------
      //                                        심박 센서
      // ----------------------------------------------------------------------------------------
      // ----------------------------------------------------------------------------------------
      // ----------------------------------------------------------------------------------------
      if (sensor_2_mode == 1) {
        cur_heart = pulseSensor.getBeatsPerMinute();  // BPM 값 읽어오기
        if (pulseSensor.sawStartOfBeat()) {           // 심박수를 측정했다면 앱으로 전송
          Serial.println("♥  A HeartBeat Happened ! ");
          Serial.print("BPM: ");
          Serial.println(pre_cur_heart);
          pre_cur_heart =  cur_heart;
        }
      }

      // ----------------------------------------------------------------------------------------
      // ----------------------------------------------------------------------------------------
      // ----------------------------------------------------------------------------------------
      //                                         EMG 센서
      // ----------------------------------------------------------------------------------------
      // ----------------------------------------------------------------------------------------
      // ----------------------------------------------------------------------------------------
      if (sensor_3_mode == 1) {                     // 근육 활성화 확인
        // 센서 값 입력 받고
        if ((digitalRead(10) == 1) || (digitalRead(11) == 1)) {
          // 인식 실패
        }
        else {
          // 인식 성공
          emg_f = lpf(analogRead(A1), pre_emg_f);   // 아날로그 read를 통해서 raw 값 획득 -> 필터 적용
          pre_emg_f = emg_f;                        // 이전 값에 저장 -> 다음번 필터링 시 사용
          Serial.print("emg_f: ");
          Serial.println(emg_f);

          if (emg_f > 600) {
            Serial.print("성공: ");
            info_to_app(count, pre_cur_heart, -1);      // -1은 성공 신호 -> 타겟 근육 부위가 활성화되었다는 의미
          }
        }
      }
      else if (sensor_3_mode == 2) {                // 근육 성장치 확인
        if (!chk_muscle_growth) {
          Serial.println("3");
          delay(1000);
          Serial.println("2");
          delay(1000);
          Serial.println("1");
          delay(1000);
          chk_mg_time = millis();
          chk_muscle_growth = true;
          Serial.println("측정 시작");
        }
        else {                                      // 이전 값에 저장 -> 다음번 필터링 시 사용
          if (cur_time - chk_mg_time <= chk_mg_time_interval) {
            emg_f = lpf(analogRead(A1), pre_emg_f); // 필터 적용
            pre_emg_f = emg_f;
            if (emg_f > 600) {
              Serial.print("측정 중: ");
              Serial.println(emg_f);
              avg_emg += emg_f;
              avg_emg /= 2.0;
            }
          }
          else {
            Serial.print("측정 완료: ");
            Serial.println(avg_emg);
            sensor_3_mode = 0;
            chk_muscle_growth = false;
            info_to_app(count, pre_cur_heart, avg_emg);
          }
        }
      }
    }
  }
}

// ----------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------
//                                       기타 함수
// ----------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------

// 자이로 가속도 센서 초기화 함수
void initSensor() {
  Wire.begin();
  Wire.beginTransmission(MPU_ADDR);   // I2C 통신용 어드레스(주소)
  Wire.write(0x6B);    // MPU6050과 통신을 시작하기 위해서는 0x6B번지에
  Wire.write(0);       // MPU6050을 동작 대기 모드로 변경
  Wire.endTransmission(true);
}

// 자이로 가속도 센서 값 읽어오기
void getRawData() {
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x3B);   // AcX 레지스터 위치(주소)를 지칭합니다
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 14, true);  // AcX 주소 이후의 14byte의 데이터를 요청

  AcX = Wire.read() << 8 | Wire.read(); //두 개의 나뉘어진 바이트를 하나로 이어 붙여서 각 변수에 저장
  AcY = Wire.read() << 8 | Wire.read();
  AcZ = Wire.read() << 8 | Wire.read();
  Tmp = Wire.read() << 8 | Wire.read();
  GyX = Wire.read() << 8 | Wire.read();
  GyY = Wire.read() << 8 | Wire.read();
  GyZ = Wire.read() << 8 | Wire.read();
}

// 노이즈 제거를 위한 로우 패스 필터 적용 함수
float lpf(float raw, float pre_f)
{
  float res_f;
  res_f = lambda / (1 + lambda) * raw + 1 / (1 + lambda) * pre_f;
  return res_f;
}

// 앱인벤터와 통신하기 위한 함수
void info_to_app(int count, int heart, int emg) {
  // 해당 문자열을 전송하면 앱 인벤터는 "123"을 인식하고 문자열을 콤마(,) 기준으로 나눈다.
  // 나눈 후 각 배열로 초기화되면, 각 인덱스 값을 전역변수에 저장 후 활용한다.
  bluetooth.print("123");
  bluetooth.print(", ");
  bluetooth.print(count);
  bluetooth.print(", ");
  bluetooth.print(heart);
  bluetooth.print(", ");
  bluetooth.print(emg);
  bluetooth.print(", ");
  bluetooth.println("456");
}
