# Architecture

## MVP

```text
aT Open API
   │
   ▼
Spring Boot
 ├─ client       외부 API 계약 격리
 ├─ service      동기화/조회/이상변동 비즈니스 로직
 ├─ repository   PostgreSQL 접근
 └─ controller   내부 REST API
   │
   ▼
PostgreSQL
```

## 설계 원칙

1. 외부 API DTO와 내부 Domain 모델을 분리한다.
2. 외부 API 오류가 Controller까지 그대로 전파되지 않도록 예외를 변환한다.
3. 데이터 중복 방지는 DB 제약조건과 애플리케이션 검증을 함께 사용한다.
4. 이상변동 기준은 설정값으로 관리한다.
5. 기능 구현 후 테스트와 Docker 실행까지 확인해야 완료로 본다.
