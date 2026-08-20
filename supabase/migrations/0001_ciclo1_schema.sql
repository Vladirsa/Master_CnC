-- CNC MASTER LAB — Ciclo 1
-- Esquema base: identidad compartida del ecosistema HETNACNC + Fundamentos.
-- Ver CNC_MASTER_LAB_CICLO1_KICKOFF.md sección 4 para el detalle de decisiones.

-- ============================================================
-- IDENTIDAD COMPARTIDA DEL ECOSISTEMA
-- ============================================================
create table if not exists usuarios_plataforma (
  id uuid primary key references auth.users(id) on delete cascade,
  nombre text,
  correo text,
  avatar_url text,
  created_at timestamptz default now()
);

-- ============================================================
-- PERFIL DE APRENDIZAJE DE MASTER LAB
-- ============================================================
create table if not exists players (
  user_id uuid primary key references usuarios_plataforma(id) on delete cascade,
  nivel int not null default 1,
  xp int not null default 0,
  dificultad_actual text not null default 'principiante'
    check (dificultad_actual in ('principiante','intermedio','avanzado','profesional')),
  created_at timestamptz default now()
);

-- ============================================================
-- MÁQUINAS (ejes como dato, no supuesto — Blueprint sección 7)
-- ============================================================
create table if not exists machines (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  tipo text not null default 'router' check (tipo in ('router','laser','plasma')),
  ejes int not null default 3 check (ejes in (3,4,5)),
  rotary_axis text
);

-- ============================================================
-- ÁRBOL DE HABILIDADES
-- ============================================================
create table if not exists skills (
  id uuid primary key default gen_random_uuid(),
  codigo text unique not null,
  nombre text not null,
  rama text not null,
  requisito_previo uuid references skills(id)
);

create table if not exists skill_progress (
  user_id uuid references players(user_id) on delete cascade,
  skill_id uuid references skills(id) on delete cascade,
  dominio numeric not null default 0,
  intentos int not null default 0,
  updated_at timestamptz default now(),
  primary key (user_id, skill_id)
);

-- ============================================================
-- MISIONES (plantillas generativas — nunca hardcodeadas en la app)
-- ============================================================
create table if not exists mission_templates (
  id uuid primary key default gen_random_uuid(),
  tipo text not null check (tipo in
    ('seleccion','ordenar','detectar_error','configurar','simulacion','diagnostico','reparacion','proyecto')),
  skill_id uuid references skills(id) on delete cascade,
  dificultad text not null default 'principiante',
  contenido jsonb not null
);

create table if not exists mission_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references players(user_id) on delete cascade,
  template_id uuid references mission_templates(id) on delete cascade,
  correcto boolean,
  intentos int not null default 1,
  tiempo_segundos int,
  created_at timestamptz default now()
);

-- ============================================================
-- BIBLIOTECA DE ERRORES
-- ============================================================
create table if not exists errors_catalog (
  id uuid primary key default gen_random_uuid(),
  codigo text unique not null,
  causa text not null,
  consecuencia text not null,
  explicacion text not null,
  correccion text not null
);

create table if not exists error_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references players(user_id) on delete cascade,
  error_codigo text references errors_catalog(codigo),
  mission_attempt_id uuid references mission_attempts(id) on delete cascade,
  created_at timestamptz default now()
);

-- ============================================================
-- XP
-- ============================================================
create table if not exists xp_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references players(user_id) on delete cascade,
  cantidad int not null,
  motivo text not null,
  created_at timestamptz default now()
);

-- ============================================================
-- SPONSOR ENGINE (tablas vacías desde el día 1, sin UI de admin todavía)
-- ============================================================
create table if not exists sponsors (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  contacto text,
  activo boolean default true
);

create table if not exists campaigns (
  id uuid primary key default gen_random_uuid(),
  sponsor_id uuid references sponsors(id) on delete cascade,
  nombre text not null,
  skill_id uuid references skills(id),
  mission_template_id uuid references mission_templates(id),
  activa boolean default true,
  created_at timestamptz default now()
);

create table if not exists sponsor_impressions (
  id uuid primary key default gen_random_uuid(),
  campaign_id uuid references campaigns(id) on delete cascade,
  user_id uuid references players(user_id),
  created_at timestamptz default now()
);

-- ============================================================
-- RLS
-- ============================================================
alter table usuarios_plataforma enable row level security;
alter table players enable row level security;
alter table skill_progress enable row level security;
alter table mission_attempts enable row level security;
alter table error_history enable row level security;
alter table xp_events enable row level security;

alter table skills enable row level security;
alter table machines enable row level security;
alter table mission_templates enable row level security;
alter table errors_catalog enable row level security;
alter table sponsors enable row level security;
alter table campaigns enable row level security;

-- Identidad y datos personales: el usuario solo ve/edita SUS propias filas.
create policy "usuarios_plataforma_propio" on usuarios_plataforma
  for all to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

create policy "players_propio" on players
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "skill_progress_propio" on skill_progress
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "mission_attempts_propio" on mission_attempts
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "error_history_propio" on error_history
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "xp_events_propio" on xp_events
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Catálogo: lectura pública (authenticated y anon donde tenga sentido).
create policy "skills_lectura_publica" on skills for select to authenticated, anon using (true);
create policy "machines_lectura_publica" on machines for select to authenticated, anon using (true);
create policy "mission_templates_lectura_publica" on mission_templates for select to authenticated, anon using (true);
create policy "errors_catalog_lectura_publica" on errors_catalog for select to authenticated, anon using (true);
create policy "sponsors_lectura_publica" on sponsors for select to authenticated, anon using (true);
create policy "campaigns_lectura_publica" on campaigns for select to authenticated, anon using (true);
