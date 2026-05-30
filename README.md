# 프랜차이즈 발주 시스템

패스트푸드 프랜차이즈 가맹점(10개)의 본사 발주 시스템입니다.  
Rails 8 + SQLite로 구현되었습니다.

## 실행 방법

```bash
bin/setup          # 최초 1회 (의존성 설치 + DB 생성 + 시드)
bin/dev            # 또는 bin/rails server
```

http://localhost:3000 에 접속합니다.

## 테스트 계정

| 역할 | 이메일 | 비밀번호 |
|------|--------|----------|
| 본사 관리자 | admin@hq.com | password123 |
| 가맹점 점주 | owner1@example.com ~ owner10@example.com | password123 |

## 주요 기능

### 점주
- 품목 조회 및 장바구니 주문
- 재고 0 품목은 UI에서 비활성화 (품절)
- 주문 완료 시 점주 이메일로 주문내역 + 인보이스 발송
- 주문 이력 조회 및 취소 (접수 대기/확인 상태)

### 본사 (`/admin`)
- 품목 CRUD 및 재고 관리
- 가맹점 10개 관리
- 전체 주문 조회 및 상태 변경 (접수 → 배송 → 완료)

## 이메일

개발 환경에서는 [letter_opener](https://github.com/ryanb/letter_opener)로 브라우저에서 메일 미리보기가 열립니다.

## 기술 스택

- Ruby on Rails 8.1
- SQLite3
- Hotwire (Turbo + Stimulus)
- bcrypt (인증)
