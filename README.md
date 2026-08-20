# CNC Master Lab

Academia gamificada de CNC — ecosistema HETNACNC. Este repo es el **Ciclo 1**: la primera vertical funcional (registro → árbol de Fundamentos → 2 misiones → XP/nivel).

Documentos de referencia (en el proyecto de Claude, no en este repo):
`CNC_MASTER_LAB_BLUEPRINT.md`, `CNC_MASTER_LAB_CICLO1_KICKOFF.md`, `CNC_MASTER_LAB_INTELLIGENCE_REPORT.md`, `CNC_MASTER_LAB_DOCUMENTATION_INTELLIGENCE_REPORT.md`, `CNC_MASTER_LAB_DESIGN_SYSTEM.md`.

## Qué hace este Ciclo 1

Un usuario nuevo puede: registrarse con correo (enlace mágico) → ver el árbol de habilidades de **Fundamentos** (Coordenadas X/Y/Z, Origen de pieza) → resolver una misión de tipo Selección y una de tipo Detectar Error → si falla, ver la explicación completa (Error → Causa → Consecuencia → Explicación → Corrección) → ganar XP y subir de nivel.

## Lo que falta para que corra de verdad (3 pasos, en orden)

### 1. Crear el proyecto de Supabase
1. Entra a [supabase.com](https://supabase.com) y crea un proyecto nuevo (o usa uno existente del ecosistema HETNACNC si ya decidiste que todas las apps comparten uno solo — ver Blueprint sección 4bis).
2. En el SQL Editor del proyecto, corre en este orden:
   - `supabase/migrations/0001_ciclo1_schema.sql` (crea las tablas y la seguridad RLS)
   - `supabase/seed/0001_fundamentos_seed.sql` (carga el contenido real de Fundamentos)
3. En **Authentication → Providers**, confirma que "Email" esté activo con "Magic Link" (así funciona el login sin contraseña).
4. Copia la **URL del proyecto** y la **anon key** (Settings → API) — se usan en el paso 3.

### 2. Subir este código a GitHub
Dime cuando quieras y lo subo yo mismo con el nombre de repo que prefieras (por defecto asumí `cnc-master-lab`, separado del Cotizador — Blueprint sección 19). Si prefieres subirlo tú:
```
git init
git add .
git commit -m "Ciclo 1: identidad compartida + Fundamentos + XP"
git remote add origin https://github.com/TU-USUARIO/cnc-master-lab.git
git push -u origin main
```

### 3. Configurar los "Secrets" del repo en GitHub
En GitHub → Settings → Secrets and variables → Actions, agrega:
- `SUPABASE_URL` → la URL del paso 1
- `SUPABASE_ANON_KEY` → la anon key del paso 1

Con eso, cada vez que subas cambios a la rama `main`, GitHub Actions compila automáticamente el APK (job `build`) y la versión web (job `build-web`) — ver `.github/workflows/build_apk.yml`.

> El deploy automático a un dominio/hosting real (ej. un subdominio de hetnacnc.com) todavía no está conectado — falta que confirmes dónde vivirá la versión web (Blueprint sección 19, pregunta 1) para agregar el paso de SFTP.

## Estructura del código

```
lib/
  core/theme/       → paleta "Neo-CNC", tipografía, tema global (Design System)
  core/services/     → conexión a Supabase
  core/auth/         → AuthGate (revisa sesión en cada arranque)
  models/            → PlayerProfile, Skill, MissionTemplate, ErrorEntry
  repositories/       → acceso a datos (Player, Skill, Mission)
  features/auth/       → login con enlace mágico
  features/home/       → navegación principal (bottom nav)
  features/skills/      → árbol de Fundamentos
  features/missions/     → pantalla de misión + resultado (Error Engine)
  features/profile/      → perfil del jugador
  features/shared/       → SkillNode, ChamferCard (componentes reutilizables)
supabase/
  migrations/         → esquema SQL + RLS
  seed/                → contenido real (Vectric como nomenclatura base)
```

## Qué NO incluye todavía este ciclo (a propósito)

Simulador 3D, motor G-code, Sponsor Engine con panel de administración (las tablas ya existen, vacías), modo historia/libre/reto, repetición espaciada, logros. Ver `CNC_MASTER_LAB_CICLO1_KICKOFF.md` sección 7 para el orden de los siguientes ciclos.

## Criterios de "terminado" de este ciclo

- [ ] Un usuario nuevo se registra, ve Fundamentos, completa las 2 misiones, falla una a propósito y ve la explicación completa del error.
- [ ] Las preguntas vienen de `mission_templates.contenido`, no de texto fijo en Dart (confirmado por diseño).
- [ ] Un segundo usuario de prueba no ve el progreso del primero (RLS).
- [ ] Corre en Android y en Web.
