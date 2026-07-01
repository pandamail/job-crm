# CLAUDE.md — job-crm 작업 지침

> Claude Code가 매 세션 자동으로 읽는 파일. 프로젝트 규칙과 문서 위치를 안내한다.

## 프로젝트 개요
취업 준비자를 위한 개인용 취업 CRM. Next.js + Supabase + Vercel.
상세는 `docs/PRD.md` 참조.

## 작업 전 반드시 읽을 문서
1. `docs/PRD.md` — 무엇을 왜 만드는가 (스키마 포함)
2. `docs/ROADMAP.md` — 지금 어느 단계이고 다음이 무엇인가
3. `docs/LESSONS.md` — 과거 실수. 같은 실수 반복 금지.

## 작업 규칙
- **Vertical slice로 개발한다.** 한 기능을 DB→API→UI까지 끝내고 다음으로. 여러 기능을 동시에 벌리지 않는다.
- **작업이 끝나면 `docs/CHANGELOG.md`에 그날 변경을 한 줄 추가한다.** (최신이 위로)
- **실수/삽질이 있었으면 `docs/LESSONS.md`에 증상·원인·해결·재발방지를 기록한다.**
- 스키마를 바꾸면 `docs/PRD.md`의 스키마 섹션도 함께 갱신한다.
- 새 기능을 제안할 때는 v1/v2/v3 중 어디에 속하는지 먼저 판단한다. v1 스코프 밖이면 ROADMAP 백로그에 적고 지금은 만들지 않는다.

## 기술 규칙
- Supabase 클라이언트는 서버/클라이언트 컴포넌트용을 분리해 사용한다.
- 모든 테이블에 RLS를 켜고 user_id 기준으로 격리한다.
- 환경변수(.env.local)는 커밋하지 않는다.

## 현재 스코프 (v1)
Auth + profiles → applications CRUD → interviews → documents → Vercel 배포.
이 밖의 것(관리자 페이지, 공지사항, AI 학습루프)은 v1에서 만들지 않는다.
