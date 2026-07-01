# job-crm PRD (Product Requirements Document)

> 이 문서는 job-crm의 **총괄 목적·타겟·기능범위·기술·스키마**를 정의한다.
> 잘 바뀌지 않는 "북극성" 문서다. 세부 일정/우선순위는 `ROADMAP.md`, 일일 변경은 `CHANGELOG.md`를 본다.
> 최초 작성: 2026-07-01

---

## 1. 한 줄 정의

취업 준비자가 **목표 기업 → 기업 분석 → 지원 → 면접 → 서류**를 한 공간에서 관리하는 개인용 취업 CRM.

## 2. 목적 (Why)

- 취업 활동 중 흩어지는 자료(자소서·경력기술서·증명서·기업 분석 메모·면접 기록)를 **한 곳에서 관리**한다.
- 지원 현황을 파이프라인(위시리스트→지원→면접→합격/불합격)으로 **한눈에 추적**한다.
- 1인용 도구로 시작하되, 실사용자를 점진적으로 늘릴 수 있는 구조로 설계한다.

## 3. 타겟 사용자

- **1차 (v1):** 개발자 본인. 실제로 매일 쓰면서 불편을 직접 발견하는 dogfooding 대상.
- **2차 (v2):** 취업 준비 중인 지인 5~10명. 초대 기반, 피드백 수집 대상.
- **3차 (v3):** 국내 취업 준비자 일반. 특히 잡코리아/원티드 같은 플랫폼에 종속되지 않고 자기 자료를 직접 관리하고 싶은 사람.

## 4. 핵심 가치 제안

- **격리성:** 각 사용자의 데이터는 RLS로 완전히 분리된 자기만의 공간.
- **파일 관리:** 서류를 지원 건에 연결해 "이 회사에 뭘 냈는지" 추적 가능.
- **기록 중심:** 기업 분석·면접 회고를 남겨 다음 지원에 재활용.

## 5. 기능 범위 (Scope)

### v1 — MVP (지금 만드는 것)
- [ ] Supabase Auth (이메일 로그인)
- [ ] `profiles` 자동 생성 (role 컬럼 포함)
- [ ] applications CRUD (목표기업/지원 파이프라인 + 기업 분석 메모)
- [ ] interviews 로깅 (지원 건에 연결)
- [ ] documents 업로드 (Supabase Storage, 지원 건에 선택적 연결)

### v2 — 실사용자 초대 대비
- [ ] 사용자 피드백 수집 (`feedback` 테이블 + 의견 보내기 폼) ← 관리자 기능의 시작점
- [ ] 기업 분석 노트 별도 테이블 분리 (분석이 길어지면)
- [ ] 자소서 버전 관리

### v3 — 확장
- [ ] 공지사항 (`announcements`)
- [ ] 관리자 대시보드 (유저 수/활성도/스토리지)
- [ ] 사용 통계·분석
- [ ] (검토) 모바일 연동

## 6. 비목표 (Non-Goals) — 스코프 방어선

- ❌ v1에서 관리자 페이지 만들지 않는다. Supabase 콘솔이 그 역할을 대신한다.
- ❌ v1에서 공지사항 만들지 않는다. 공지할 사용자가 없다.
- ❌ self-improving AI 에이전트(예: Hermes) 통합은 v1~v2 범위 밖. v3 이후 별도 검토.
- ❌ 사용자 간 상호작용/소셜 기능은 이 제품의 방향이 아니다.

## 7. 기술 스택

| 영역 | 선택 | 비고 |
|------|------|------|
| 프론트 | Next.js (App Router) | 러프씨 사이트에서 검증된 스택 |
| DB/Auth/Storage | Supabase | RLS로 유저 격리 |
| 배포 | Vercel | |
| 개발 도구 | Claude Code (주 80%) | 설계 판단은 Claude.ai에서 |

## 8. 데이터 스키마 (v1 시작)

> cascade delete, nullable FK, RLS 유저 격리 적용.

```
profiles
  id            uuid  PK, FK -> auth.users(id)
  role          text  default 'user'        -- 'user' | 'admin' (미래 대비)
  created_at    timestamptz default now()

applications
  id            uuid  PK default gen_random_uuid()
  user_id       uuid  FK -> auth.users(id), not null
  company_name  text  not null
  position      text
  status        text  default 'wishlist'    -- wishlist|applied|interviewing|offer|rejected
  research_notes text                        -- 기업 분석 메모 (v2에서 분리 가능)
  applied_date  date
  created_at    timestamptz default now()
  updated_at    timestamptz default now()

interviews
  id            uuid  PK default gen_random_uuid()
  application_id uuid FK -> applications(id) ON DELETE CASCADE, not null
  scheduled_at  timestamptz
  round         text                         -- '1차'|'최종' 등
  notes         text
  result        text                         -- pending|pass|fail
  created_at    timestamptz default now()

documents
  id            uuid  PK default gen_random_uuid()
  user_id       uuid  FK -> auth.users(id), not null
  type          text  not null               -- 자소서|경력기술서|증명서|포트폴리오 등
  file_path     text  not null               -- Supabase Storage 경로
  application_id uuid FK -> applications(id) ON DELETE SET NULL  -- 재사용 위해 nullable
  issued_date   date                          -- 증명서 유효기간 추적용
  created_at    timestamptz default now()
```

### v2+ 추가 예정 테이블
```
feedback        (id, user_id, type, content, status, created_at)   -- v2
announcements   (id, title, body, published_at, is_active)         -- v3
```

## 9. 관리자/운영 전략

관리자 기능은 **사용자 수의 함수**다. 사용자가 없으면 관리 대상도 없다.

| 단계 | 관리 방식 |
|------|-----------|
| v1 (혼자) | Supabase 콘솔이 곧 관리자 도구. 별도 UI 없음. |
| v2 (지인) | 피드백 폼으로 "실제 불편"을 데이터로 수집. 상상 아닌 근거로 개발. |
| v3 (확대) | 공지사항 + admin 대시보드 + 유저 관리 페이지 |

## 10. 빌드 원칙

- **Vertical slice:** 한 기능을 DB→API→UI→배포까지 end-to-end로 끝낸 뒤 다음으로. 층별(모든 테이블 먼저, 모든 API 다음)로 쌓지 않는다. 배포 가능한 결과가 빨리 나와야 동력이 유지된다.
- **v1 첫 슬라이스:** applications CRUD 하나를 완성한다.
