-- profiles: auth.users와 1:1, role 컬럼으로 미래 admin 대비
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'user',
  created_at timestamptz not null default now()
);

-- applications: 목표기업+지원 파이프라인, 기업분석 메모 포함
create table applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  company_name text not null,
  position text,
  status text not null default 'wishlist',
  research_notes text,
  applied_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- interviews: 지원 건에 연결, 지원 삭제 시 함께 삭제
create table interviews (
  id uuid primary key default gen_random_uuid(),
  application_id uuid not null references applications(id) on delete cascade,
  scheduled_at timestamptz,
  round text,
  notes text,
  result text default 'pending',
  created_at timestamptz not null default now()
);

-- documents: 재사용 위해 application_id는 nullable
create table documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null,
  file_path text not null,
  application_id uuid references applications(id) on delete set null,
  issued_date date,
  created_at timestamptz not null default now()
);

-- RLS 활성화 (체크박스와 무관하게 명시적으로 켠다 — 이미 켜져 있어도 무해)
alter table profiles enable row level security;
alter table applications enable row level security;
alter table interviews enable row level security;
alter table documents enable row level security;

-- RLS 정책: 본인 데이터만 접근
create policy "own profile" on profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);

create policy "own applications" on applications
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "own documents" on documents
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- interviews는 user_id가 없으니 부모 application의 소유자로 판단
create policy "own interviews" on interviews
  for all using (
    exists (
      select 1 from applications a
      where a.id = interviews.application_id and a.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from applications a
      where a.id = interviews.application_id and a.user_id = auth.uid()
    )
  );

-- 회원가입 시 profiles 자동 생성 트리거
create function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id) values (new.id);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- profiles.role은 본인이 직접 수정하지 못하게 방지 (자기 자신을 admin으로 승격 차단)
create function public.prevent_role_change()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.role is distinct from old.role then
    new.role := old.role;
  end if;
  return new;
end;
$$;

create trigger prevent_role_change
  before update on public.profiles
  for each row execute function public.prevent_role_change();
