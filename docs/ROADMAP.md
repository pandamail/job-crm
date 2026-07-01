# job-crm ROADMAP

> 무엇을 **어떤 순서로** 만들지. PRD가 "무엇/왜"라면 이 문서는 "언제/순서".
> 우선순위가 바뀌면 여기를 갱신한다.

## 현재 위치
- [x] GitHub 레포 생성, `create-next-app`, 첫 커밋
- [ ] **← 지금 여기: 스키마 실행 + 첫 vertical slice**

## v1 — MVP (목표: 혼자 매일 쓸 수 있는 상태)

**슬라이스 순서 (한 줄씩 end-to-end로 완성):**

1. **Auth + profiles**
   - Supabase 프로젝트 생성, 스키마 SQL 실행
   - 이메일 로그인, 로그인 시 profiles 자동 생성 트리거
2. **applications CRUD** ← 첫 진짜 기능
   - 목록 / 추가 / 수정 / 삭제
   - status 파이프라인 (wishlist→applied→interviewing→offer→rejected)
   - research_notes 입력
3. **interviews 로깅**
   - applications 상세에서 면접 기록 추가/조회
4. **documents 업로드**
   - Supabase Storage 연동, 파일 업로드/목록/삭제
   - 지원 건에 선택적 연결
5. **Vercel 배포** — v1 완료 기준선

## v2 — 실사용자 초대
- feedback 수집 폼
- 자소서 버전 관리
- 기업 분석 노트 분리 (필요 시)

## v3 — 확장
- 공지사항 / admin 대시보드 / 통계
- (검토) Hermes 스타일 학습루프를 자소서 피드백에 소규모 자체구현
- (검토) 모바일

## 백로그 (아이디어 보관, 우선순위 미정)
- 증명서 유효기간 자동 알림 (issued_date + threshold)
- 지원 상태 2주 이상 정체 시 리마인더 (pipeline-review 스킬 아이디어 차용)
