# BBQ + RICE 발주 시스템 — 개발부터 배포까지

Rails 8.1 + SQLite + Hotwire 기반 프랜차이즈 발주 시스템의  
**로컬 개발 → GitHub → CI → Raspberry Pi Docker → Caddy HTTPS** 전 과정을 정리한 문서입니다.

---

## 1. 프로젝트 개요

| 항목 | 내용 |
|------|------|
| 저장소 | https://github.com/dataworkman/bbq-rice-order-system |
| 스택 | Rails 8.1, SQLite, Puma, Hotwire (Turbo/Stimulus) |
| 역할 | 점주(주문), 본사(품목·재고·가맹점·주문·계정 관리) |
| 운영 URL | https://bbq.dataworkman.dedyn.io |
| Pi IP (LAN) | 192.168.4.140 |

---

## 2. 로컬 개발 환경

### 2.1 최초 설정

```bash
cd "/path/to/bbq-rice-order-system"
bin/setup          # gem 설치 + DB 생성 + 시드
bin/rails server   # http://localhost:3000
```

### 2.2 자주 쓰는 명령

```bash
bin/rails db:seed              # 데모 데이터 (주의: 기존 데이터 초기화)
bin/rails test                 # 단위·통합 테스트
bin/rails test:system          # 시스템 테스트 (Chrome 필요)
bin/rubocop                    # 린트
bin/dev                        # 개발 서버 (설정된 경우)
```

### 2.3 테스트 계정 (seed 후)

| 역할 | 이메일 | 비밀번호 |
|------|--------|----------|
| 본사 | admin@hq.com | password123 |
| 점주 | owner1@example.com ~ owner10@example.com | password123 |

### 2.4 중요 파일

| 파일 | 용도 |
|------|------|
| `config/master.key` | credentials 복호화 키 (**Git에 올리지 않음**) |
| `.env.production` | Pi 운영 환경 변수 (Git에 올리지 않음) |
| `deploy/env.example` | `.env.production` 템플릿 |
| `docker-compose.yml` | Pi Docker 운영 스택 |
| `Dockerfile` | 프로덕션 이미지 빌드 |

---

## 3. Git / GitHub 워크플로

### 3.1 기본 흐름

```
로컬 개발 → git commit → git push origin main → GitHub Actions CI → Pi에서 git pull + docker rebuild
```

### 3.2 커밋 전 확인 (로컬)

```bash
bin/rubocop
bin/rails test
bin/rails test:system
```

### 3.3 GitHub Actions CI

`main` 브랜치 push 시 자동 실행:

| Job | 내용 |
|-----|------|
| lint | RuboCop |
| test | `bin/rails test` |
| system-test | `bin/rails test:system` |
| scan_ruby | Brakeman, bundler-audit |
| scan_js | importmap audit |

CI green 확인: https://github.com/dataworkman/bbq-rice-order-system/actions

### 3.4 Private 저장소 clone (Pi)

HTTPS는 토큰 필요. **SSH 권장:**

```bash
ssh-keygen -t ed25519 -C "pi-server" -f ~/.ssh/id_ed25519 -N ""
cat ~/.ssh/id_ed25519.pub   # GitHub → Settings → SSH keys 에 등록

git clone git@github.com:dataworkman/bbq-rice-order-system.git
```

### 3.5 code-server 터미널 주의

code-server는 Git credential helper를 주입합니다. clone/pull 시:

```bash
env -u GIT_ASKPASS -u VSCODE_GIT_IPC_HANDLE git pull
```

또는 `~/.bashrc`에:

```bash
unset GIT_ASKPASS VSCODE_GIT_ASKPASS_NODE VSCODE_GIT_ASKPASS_MAIN VSCODE_GIT_ASKPASS_EXTRA_ARGS VSCODE_GIT_IPC_HANDLE
```

---

## 4. Docker 아키텍처 (Pi)

### 4.1 구조

```
브라우저
   ↓ HTTPS :443
Caddy (bbq.dataworkman.dedyn.io)
   ↓ reverse_proxy localhost:3000
Docker (bbq-rice-order-system-web-1)
   ↓ Puma :3000
Rails 앱 + SQLite (/rails/storage/production.sqlite3)
   ↓ named volume: sqlite_data
```

### 4.2 Dockerfile 요약

- Ruby 3.4.8 slim (ARM64 네이티브 빌드 — Pi에서 직접 build)
- non-root `rails` 사용자 (uid 1000)
- entrypoint가 root로 storage 권한 정리 후 `gosu rails` 로 실행
- Puma가 **3000번** 포트에서 직접 listen (Thruster/80번 포트 사용 안 함)

### 4.3 docker-compose.yml 요약

```yaml
ports:
  - "3000:3000"          # 호스트 3000 → 컨테이너 3000
environment:
  PORT: "3000"
  DISABLE_HOST_CHECK: "true"
  FORCE_SSL: "false"
volumes:
  - sqlite_data:/rails/storage
```

---

## 5. Raspberry Pi 배포 — 처음부터

### 5.1 Pi 사전 준비

```bash
sudo apt update
sudo apt install -y git docker.io docker-compose-v2
sudo usermod -aG docker ubuntu
# 로그아웃 후 재로그인
```

Caddy는 이미 설치·운영 중이라 가정 (`/etc/caddy/Caddyfile`).

### 5.2 코드 받기

```bash
mkdir -p ~/ruby && cd ~/ruby
git clone git@github.com:dataworkman/bbq-rice-order-system.git
cd bbq-rice-order-system
```

### 5.3 환경 변수

```bash
cp deploy/env.example .env.production
nano .env.production
```

**필수 항목:**

```bash
RAILS_MASTER_KEY=<개발 PC의 config/master.key 내용>
APP_HOST=192.168.4.140          # Pi LAN IP (hostname -I 로 확인)
APP_PROTOCOL=http
FORCE_SSL=false
ASSUME_SSL=false
DISABLE_HOST_CHECK=true
```

`RAILS_MASTER_KEY` 확인 (개발 PC에서):

```bash
cat config/master.key
```

### 5.4 빌드 & 실행

```bash
bin/pi-deploy
# 또는
docker compose up -d --build
```

Pi는 부팅이 느리므로 **90~120초** 기다린 후 확인:

```bash
docker compose ps                  # Up (healthy)
curl -I http://127.0.0.1:3000/up # HTTP 200
bin/pi-diagnose                  # 종합 진단
```

### 5.5 DB 시드 (데모용, 최초 1회)

```bash
docker compose exec web bin/rails db:seed
```

> 운영 DB에 실 데이터가 있으면 **seed 실행 금지** (전체 초기화됨).

---

## 6. Caddy (HTTPS) 설정

### 6.1 Caddyfile 블록

`/etc/caddy/Caddyfile`:

```caddy
bbq.dataworkman.dedyn.io {
        reverse_proxy localhost:3000
}
```

> 이전에 `8060`으로 되어 있으면 **502** 발생. 반드시 `3000`.

적용:

```bash
sudo caddy validate --config /etc/caddy/Caddyfile
sudo systemctl reload caddy
```

### 6.2 DNS (deSEC)

`bbq.dataworkman.dedyn.io` → Pi **공인 IP** A/AAAA 레코드 필요.  
Caddy가 Let's Encrypt 인증서를 자동 발급.

### 6.3 접속 URL

| 경로 | URL |
|------|-----|
| HTTPS (권장) | https://bbq.dataworkman.dedyn.io |
| LAN 직접 | http://192.168.4.140:3000 |
| Tailscale | http://100.97.120.11:3000 |

code-server `proxy/3000` 경로는 **사용하지 않음** — Caddy 도메인 사용.

---

## 7. 코드 업데이트 (재배포)

```bash
cd ~/ruby/bbq-rice-order-system

env -u GIT_ASKPASS -u VSCODE_GIT_IPC_HANDLE git pull

docker compose up -d --build

# DB 마이그레이션이 포함된 경우 entrypoint가 db:prepare 자동 실행
# 필요 시 수동:
docker compose exec web bin/rails db:migrate
```

---

## 8. 운영 명령 모음

```bash
# 상태
docker compose ps
docker compose logs -f web
bin/pi-diagnose

# 재시작
docker compose restart web

# Rails 콘솔
docker compose exec web bin/rails console

# Caddy
sudo systemctl status caddy
sudo systemctl reload caddy
```

---

## 9. 트러블슈팅 (실제로 겪은 문제)

### 9.1 Git clone 인증 실패

| 증상 | 해결 |
|------|------|
| `vscode-git *.sock ECONNREFUSED` | code-server env unset 후 clone |
| `Password authentication not supported` | PAT 또는 SSH 사용 |
| `403 Write access not granted` | 토큰 `repo` 권한 또는 SSH 키 등록 |

### 9.2 HTTP 403 (앱은 떠 있음)

| 원인 | 해결 |
|------|------|
| Host authorization | `DISABLE_HOST_CHECK=true` |
| allow_browser (curl/구형 UA) | Pi 배포 시 자동 skip (`pi_deployment?`) |
| 잘못된 APP_HOST | `hostname -I` 로 IP 확인 |

### 9.3 HTTP 502

| 원인 | 해결 |
|------|------|
| Thruster → Puma 3000 race | Puma 직접 3000 listen (현재 설정) |
| non-root가 80번 bind | PORT=3000 사용 |
| Caddy가 8060 proxy | `localhost:3000` 으로 수정 |
| 컨테이너 crash loop | 로그 확인 + volume chown (아래) |

### 9.4 컨테이너 Restarting (1)

```bash
docker compose logs web --tail 100

# SQLite volume 권한
docker compose down
sudo chown -R 1000:1000 $(docker volume inspect bbq-rice-order-system_sqlite_data -f '{{.Mountpoint}}')
docker compose up -d --build
```

### 9.5 CI 실패

| Job | 흔한 원인 |
|-----|-----------|
| lint | RuboCop — `bin/rubocop -A` |
| test | `pi_deployment?` 정의 순서 등 앱 로드 오류 |
| system-test | `test/system` 없음, Chrome/타임아웃 |

---

## 10. 환경 변수 참고

| 변수 | 설명 | Pi 예시 |
|------|------|---------|
| `RAILS_MASTER_KEY` | credentials 키 | master.key 내용 |
| `APP_HOST` | 메일·호스트 | 192.168.4.140 |
| `APP_PROTOCOL` | http/https | http |
| `FORCE_SSL` | HTTPS 강제 | false |
| `ASSUME_SSL` | SSL 가정 | false |
| `DISABLE_HOST_CHECK` | Host 검사 해제 | true |
| `APP_PORT` | Docker 호스트 포트 | 3000 |
| `SMTP_*` | 메일 (선택) | Gmail 등 |

메일 미설정 시 주문 확인·비밀번호 찾기 메일은 발송되지 않음.

---

## 11. 보안 체크리스트 (운영 전)

- [ ] `db:seed` 기본 비밀번호 → **운영용 강한 비밀번호로 변경**
- [ ] `.env.production`, `master.key` Git 미포함 확인
- [ ] 본사 admin 계정만 필요한 만큼 유지
- [ ] HTTPS (Caddy) 사용
- [ ] Pi SSH 키·방화벽 설정
- [ ] 정기 `git pull` + `docker compose up -d --build` 로 보안 패치

---

## 12. 배포 흐름 다이어그램

```
[개발 PC]
  코드 작성
  bin/rails test / rubocop
  git commit && git push
        │
        ▼
[GitHub]
  Actions CI (lint, test, system-test, scan)
        │
        ▼
[Raspberry Pi]
  git pull
  docker compose up -d --build
  curl http://127.0.0.1:3000/up  → 200
        │
        ▼
[Caddy]
  bbq.dataworkman.dedyn.io → localhost:3000
  Let's Encrypt HTTPS
        │
        ▼
[사용자]
  https://bbq.dataworkman.dedyn.io
```

---

## 13. 관련 스크립트

| 스크립트 | 용도 |
|----------|------|
| `bin/pi-deploy` | .env 확인 후 docker compose up |
| `bin/pi-diagnose` | IP·Docker·curl·로그 종합 진단 |
| `bin/docker-entrypoint` | storage 권한 + db:prepare + gosu |
| `bin/github_push` | gh 로그인 후 GitHub push |

---

*마지막 업데이트: 2026-05-30 — Pi (192.168.4.140) + bbq.dataworkman.dedyn.io 배포 기준*
