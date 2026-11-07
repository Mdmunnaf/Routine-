-- PrepPilot cloud schema starter. Apply only to a dedicated Supabase project.
create extension if not exists pgcrypto;
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  timezone text not null default 'Asia/Dhaka',
  preferences jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.exams (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  name text not null, exam_date date, is_reference boolean not null default false, created_at timestamptz not null default now()
);
create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  exam_id uuid references public.exams(id) on delete cascade, name text not null, description text not null default '', priority text not null default 'Medium' check(priority in ('Low','Medium','High')), created_at timestamptz not null default now()
);
create table if not exists public.chapters (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  subject_id uuid not null references public.subjects(id) on delete cascade, name text not null, description text not null default '', status text not null default 'Not Started', created_at timestamptz not null default now()
);
create table if not exists public.topics (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  chapter_id uuid references public.chapters(id) on delete cascade, subject_id uuid references public.subjects(id) on delete cascade,
  name text not null, notes text not null default '', status text not null default 'Not Started' check(status in ('Not Started','In Progress','Completed','Needs Revision')),
  difficulty text not null default 'Medium' check(difficulty in ('Easy','Medium','Hard')), priority text not null default 'Medium' check(priority in ('Low','Medium','High')),
  completed_at timestamptz, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.study_sessions (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  task_id uuid, topic_id uuid references public.topics(id) on delete set null, subject_id uuid references public.subjects(id) on delete set null,
  title text not null, started_at timestamptz not null, ended_at timestamptz, focused_seconds integer not null default 0 check(focused_seconds >= 0),
  break_seconds integer not null default 0 check(break_seconds >= 0), notes text not null default '', focus_score integer check(focus_score between 1 and 5), created_at timestamptz not null default now()
);
create table if not exists public.study_tasks (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  exam_id uuid references public.exams(id) on delete set null, subject_id uuid references public.subjects(id) on delete set null, topic_id uuid references public.topics(id) on delete set null,
  title text not null, description text not null default '', scheduled_date date not null, start_time time, expected_minutes integer not null default 45 check(expected_minutes > 0),
  priority text not null default 'Medium' check(priority in ('Low','Medium','High')), status text not null default 'Planned' check(status in ('Planned','In Progress','Completed','Skipped','Rescheduled')),
  recurrence jsonb, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.revisions (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  topic_id uuid references public.topics(id) on delete cascade, due_date date not null, status text not null default 'Due' check(status in ('Due','Completed','Skipped')),
  outcome text check(outcome in ('Easy','Difficult','Forgotten')), occurrence integer not null default 1, created_at timestamptz not null default now(), unique(user_id, topic_id, due_date, occurrence)
);
create table if not exists public.mock_tests (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  title text not null, subject_id uuid references public.subjects(id) on delete set null, test_date date not null, total_questions integer not null check(total_questions > 0),
  correct integer not null default 0 check(correct >= 0), incorrect integer not null default 0 check(incorrect >= 0), unanswered integer not null default 0 check(unanswered >= 0),
  negative_mark numeric(8,3) not null default 0 check(negative_mark >= 0), marks numeric(10,3) not null default 0, created_at timestamptz not null default now(),
  check(correct + incorrect + unanswered <= total_questions)
);
create table if not exists public.goals (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  period text not null check(period in ('daily','weekly','subject')), target_minutes integer not null check(target_minutes > 0), subject_id uuid references public.subjects(id) on delete cascade, starts_on date not null default current_date, created_at timestamptz not null default now()
);
create table if not exists public.app_notifications (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  title text not null, body text not null default '', category text not null default 'general', scheduled_at timestamptz, read_at timestamptz, dedupe_key text, created_at timestamptz not null default now(), unique(user_id,dedupe_key)
);
create index if not exists study_sessions_user_started_idx on public.study_sessions(user_id, started_at desc);
create index if not exists study_tasks_user_date_idx on public.study_tasks(user_id, scheduled_date, status);
create index if not exists revisions_user_due_idx on public.revisions(user_id, due_date, status);
create index if not exists topics_user_subject_idx on public.topics(user_id, subject_id, status);
create index if not exists mock_tests_user_date_idx on public.mock_tests(user_id, test_date desc);

-- Private user-owned data: users can access only their own rows.
alter table public.profiles enable row level security;
drop policy if exists profile_owner_select on public.profiles;
create policy profile_owner_select on public.profiles for select using (auth.uid() = id);
drop policy if exists profile_owner_insert on public.profiles;
create policy profile_owner_insert on public.profiles for insert with check (auth.uid() = id);
drop policy if exists profile_owner_update on public.profiles;
create policy profile_owner_update on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);
drop policy if exists profile_owner_delete on public.profiles;
create policy profile_owner_delete on public.profiles for delete using (auth.uid() = id);

do $$ declare t text; begin
  foreach t in array array['exams','subjects','chapters','topics','study_sessions','study_tasks','revisions','mock_tests','goals','app_notifications'] loop
    execute format('alter table public.%I enable row level security',t);
    execute format('drop policy if exists owner_select on public.%I',t);
    execute format('create policy owner_select on public.%I for select using (auth.uid() = user_id)',t);
    execute format('drop policy if exists owner_insert on public.%I',t);
    execute format('create policy owner_insert on public.%I for insert with check (auth.uid() = user_id)',t);
    execute format('drop policy if exists owner_update on public.%I',t);
    execute format('create policy owner_update on public.%I for update using (auth.uid() = user_id) with check (auth.uid() = user_id)',t);
    execute format('drop policy if exists owner_delete on public.%I',t);
    execute format('create policy owner_delete on public.%I for delete using (auth.uid() = user_id)',t);
  end loop;
end $$;
