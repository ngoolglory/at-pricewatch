# aT PriceWatch

> 한국농수산식품유통공사(aT) 공개 농산물 가격 데이터를 수집·저장·조회하고, 급격한 가격 변동을 탐지하는 Spring Boot 백엔드 개인 프로젝트

> **주의**: 본 프로젝트는 한국농수산식품유통공사(aT)의 공식 서비스가 아니며, 공개 Open API를 활용한 개인 학습·포트폴리오 프로젝트입니다.

---

## 1. 프로젝트 목적

이 프로젝트의 목표는 복잡한 AI 모델을 만드는 것이 아니라, **외부 Open API → 백엔드 서버 → 관계형 DB → 조회 API → 예외 처리 → 테스트 → 컨테이너 실행**으로 이어지는 서비스 개발 전 과정을 직접 구현하는 것입니다.

구체적으로 다음 역량을 증명하는 것을 목표로 합니다.

- Java/Spring Boot 기반 REST API 개발
- 외부 공공 Open API 연동
- PostgreSQL 기반 관계형 데이터 모델링 및 SQL 활용
- 데이터 중복·누락·비정상 값 검증
- 가격 변동 탐지 비즈니스 로직 구현
- 예외 처리와 로그 기록
- JUnit 기반 단위/통합 테스트
- Docker Compose 기반 재현 가능한 실행환경 구성
- Git을 활용한 단계적 개발 이력 관리

---

## 2. 한 줄 설명

**aT 농산물 가격 Open API를 주기적으로 수집해 PostgreSQL에 저장하고, 품목별 가격 조회 및 급격한 가격 변동 알림을 제공하는 Spring Boot 백엔드 서비스**

---

## 3. 데이터 출처

### 3.1 메인 데이터

**한국농수산식품유통공사_일별 도·소매 가격정보 조회**

- 제공기관: 한국농수산식품유통공사
- 관리부서: 디지털AI운영부
- 방식: REST
- 응답 형식: JSON / XML
- 비용: 무료
- 개발단계 승인: 자동승인
- 개발계정 일일 호출량: 10,000건
- Base URL: `https://apis.data.go.kr/B552845/perDay`
- Endpoint: `GET /price`
- 공식 문서: https://www.data.go.kr/data/15156057/openapi.do

주요 제공 항목:
- 조사일자
- 도매/소매 구분
- 부류
- 품목
- 품종
- 등급
- 시군구
- 시장
- 조사일 가격
- kg 환산 가격
- 원본 등록일시

> 실제 요청 파라미터명은 공공데이터포털에서 활용신청 후 제공되는 최신 API 명세서를 기준으로 구현합니다.

---

## 4. MVP 범위

### 반드시 구현

1. aT Open API 호출
2. 응답 데이터 파싱
3. PostgreSQL 저장
4. 중복 데이터 방지
5. 품목별 가격 조회 REST API
6. 이전 관측 가격 대비 급격한 가격 변동 탐지
7. 외부 API 실패/잘못된 응답 예외 처리
8. 로그 기록
9. 핵심 로직 JUnit 테스트
10. Docker Compose로 애플리케이션 + DB 실행
11. Swagger/OpenAPI 문서 확인
12. README에 실행방법, 구조, ERD, API 사용법 정리

### MVP에서 제외

- React/Vue 프론트엔드
- 로그인/회원가입
- Kafka
- Redis
- Kubernetes
- AWS/GCP 배포
- 머신러닝 이상탐지
- LLM/RAG
- Microservice Architecture

---

## 5. 기술 스택

| 구분 | 기술 | 선택 이유 |
|---|---|---|
| Language | Java 17 | 공공/기업 백엔드에서 널리 사용되는 JVM 기반 언어 |
| Framework | Spring Boot 3.x | REST API, DB, 테스트, 운영 기능 구현이 용이 |
| Build | Gradle | Spring 프로젝트 의존성/빌드 관리 |
| DB | PostgreSQL 16 | 무료·오픈소스, Docker 재현이 쉽고 표준 RDB 개념 학습에 적합 |
| ORM | Spring Data JPA | 엔티티/Repository 기반 CRUD 구현 |
| Migration | Flyway | DB 스키마 변경 이력 관리 |
| API Docs | springdoc-openapi | Swagger UI 기반 API 확인 |
| Test | JUnit 5, Spring Boot Test | 단위/통합 테스트 |
| Container | Docker, Docker Compose | 동일한 로컬 실행환경 재현 |
| VCS | Git/GitHub | 개발 과정과 변경 이력 관리 |
| Monitoring | Spring Boot Actuator | health endpoint 제공 |

---

## 6. 시스템 구조

```text
aT Open API
   │ HTTPS/JSON
   ▼
Spring Boot
 ├─ AtPriceClient
 ├─ PriceSyncService
 ├─ PriceService
 ├─ PriceAlertService
 └─ REST Controller
   │ JPA
   ▼
PostgreSQL
 ├─ price_observation
 ├─ price_alert
 └─ sync_history
```

---

## 7. 핵심 사용자 시나리오

### A. 가격 데이터 수집
1. 관리자가 동기화 API를 호출합니다.
2. Spring Boot가 aT Open API를 호출합니다.
3. 응답을 DTO로 변환합니다.
4. 필수 필드 및 가격값을 검증합니다.
5. 동일 데이터가 이미 존재하는지 확인합니다.
6. 신규 데이터만 PostgreSQL에 저장합니다.
7. 동기화 결과를 `sync_history`에 기록합니다.

### B. 가격 조회
1. 사용자가 품목명 또는 품목코드로 조회합니다.
2. 날짜 범위를 함께 지정할 수 있습니다.
3. DB에서 가격 이력을 조회합니다.
4. 날짜순으로 결과를 반환합니다.

### C. 이상변동 확인
1. 신규 가격을 저장한 뒤 동일 조건의 이전 관측값을 찾습니다.
2. 가격 변화율을 계산합니다.
3. 설정한 임계값을 넘으면 alert를 생성합니다.
4. 사용자는 alert 조회 API에서 이상변동 목록을 확인합니다.

---

## 8. 이상변동 정의

```text
change_rate(%) = (current_price - previous_price) / previous_price * 100
```

기본 임계값은 `|change_rate| >= 20%` 입니다.

> 이 기준은 경제·정책적으로 정의된 공식 이상가격 기준이 아니라 개인 프로젝트용 기술적 탐지 기준입니다.

---

## 9. 프로젝트 구조

```text
at-pricewatch/
├── README.md
├── .gitignore
├── .env.example
├── docker-compose.yml
├── Dockerfile
├── build.gradle
├── settings.gradle
├── src/
│   ├── main/
│   │   ├── java/com/pricewatch/
│   │   │   ├── PriceWatchApplication.java
│   │   │   ├── client/
│   │   │   ├── config/
│   │   │   ├── controller/
│   │   │   ├── domain/
│   │   │   ├── repository/
│   │   │   ├── service/
│   │   │   └── exception/
│   │   └── resources/
│   │       ├── application.yml
│   │       └── db/migration/
│   └── test/
└── docs/
    └── architecture.md
```

---

## 10. 필수 API

- `POST /api/v1/sync/prices`
- `GET /api/v1/prices?itemName=배추&startDate=2026-10-01&endDate=2026-10-09`
- `GET /api/v1/alerts?itemName=배추`
- `GET /actuator/health`

---

## 11. 환경 변수

```env
AT_API_SERVICE_KEY=replace_with_your_service_key
AT_API_BASE_URL=https://apis.data.go.kr/B552845/perDay

DB_HOST=postgres
DB_PORT=5432
DB_NAME=pricewatch
DB_USER=pricewatch
DB_PASSWORD=pricewatch_local_password

PRICE_ALERT_THRESHOLD=20.0
```

---

## 12. 개발 순서

### Phase 0 — 저장소/환경
- [x] GitHub repository 생성
- [x] README 추가
- [x] 기본 Spring Boot 프로젝트 구조 추가
- [ ] 로컬 clone
- [ ] `docker compose up -d postgres`
- [ ] `./gradlew bootRun`
- [ ] `GET /actuator/health` 확인

### Phase 1 — 외부 API 연동
- [ ] 공공데이터포털 API Key 발급
- [ ] 실제 요청/응답 샘플 확인
- [ ] AtPriceClient 구현
- [ ] DTO 구현
- [ ] timeout/HTTP 오류 처리

### Phase 2 — DB 저장
- [ ] 실제 응답을 바탕으로 스키마 확정
- [ ] PriceObservation Entity/Repository 구현
- [ ] 중복 제약조건 확정
- [ ] SyncHistory 저장

### Phase 3 — 조회 API
- [ ] 품목별 가격 조회
- [ ] 날짜 범위 조회
- [ ] Swagger 확인
- [ ] Validation 및 오류 응답

### Phase 4 — 이상변동
- [ ] 이전 관측값 조회
- [ ] 변화율 계산
- [ ] ±20% 임계값 적용
- [ ] Alert 저장/조회

### Phase 5 — 테스트
- [ ] 변화율 계산 단위 테스트
- [ ] 중복 저장 테스트
- [ ] Repository 테스트
- [ ] 외부 API 오류 테스트
- [ ] Controller 통합 테스트

### Phase 6 — Docker/문서화
- [ ] Spring Boot 이미지 build
- [ ] Docker Compose 전체 실행
- [ ] README에 실제 실행 로그/Swagger 예시 추가
- [ ] ERD 및 architecture 문서 보완

---

## 13. Definition of Done

- [ ] 실제 aT Open API에서 데이터를 가져온다.
- [ ] PostgreSQL에 데이터가 저장된다.
- [ ] 중복 데이터가 저장되지 않는다.
- [ ] REST API로 가격을 조회할 수 있다.
- [ ] 급격한 가격 변화가 alert로 생성된다.
- [ ] 잘못된 입력은 4xx로 응답한다.
- [ ] 외부 API 장애는 적절한 오류와 로그를 남긴다.
- [ ] 핵심 로직 테스트가 통과한다.
- [ ] `docker compose up --build`로 실행 가능하다.
- [ ] API Key가 GitHub에 노출되지 않는다.
- [ ] README만 보고 다른 사람이 실행할 수 있다.
