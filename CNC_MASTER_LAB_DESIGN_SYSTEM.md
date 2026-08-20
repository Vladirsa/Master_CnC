# CNC MASTER LAB — DESIGN SYSTEM (v2 — Consistencia de marca HETNACNC)
### LOOP UI/UX + Visual Design (disenador-cnc-master-lab)

> **Corrección de dirección de marca:** la primera iteración de este documento proponía una paleta "Neo-CNC" (fondo oscuro, acento verde-azulado tipo videojuego/laboratorio). El propietario la descartó explícitamente: para el mercado real de HETNA (talleres, hobbyistas de carpintería CNC en México), esa estética se siente más "app de videojuego" que "marca de taller confiable". Decisión final: **Master Lab usa exactamente la misma paleta corporativa del Cotizador HETNA** (`flutter-supabase-saas-mx/references/design_system.md`), no una paleta propia. Consistencia de marca total en vez de identidad visual diferenciada.

---

## 1. PALETA OFICIAL (idéntica al Cotizador HETNA)

```dart
class AppColors {
  static const azul            = Color(0xFF1a3a5c); // color primario de marca
  static const azulClaro       = Color(0xFFe6f1fb);
  static const verde           = Color(0xFF1d9e75); // éxito, dominado
  static const verdeClaro      = Color(0xFFe1f5ee);
  static const ambar           = Color(0xFFef9f27); // advertencia, concepto débil
  static const ambarClaro      = Color(0xFFfaeeda);
  static const rojo            = Color(0xFFe24b4a); // error
  static const rojoClaro       = Color(0xFFfcebeb);
  static const gris            = Color(0xFFf5f6fa); // fondo de pantalla
  static const grisBorde       = Color(0xFFE5E7EB);
  static const textoSecundario = Color(0xFF6B7280);
  static const textoPrincipal  = Color(0xFF111827);
}
```

**Regla de aplicación (igual que en el Cotizador):** verde = éxito/dominado, ámbar = advertencia/concepto débil, rojo = error, azul = acción primaria/marca. No mezclar — mantiene la app "legible de un vistazo".

**Color de rama del Skill Tree:** en vez de inventar tonos nuevos, cicla dentro de la misma paleta oficial — Fundamentos = azul, Herramientas = verde, CAM = ámbar, Control = azul (se repite; con solo 4 ramas y colores de marca limitados, repetir azul es mejor que introducir un quinto color fuera de marca).

**Tema base:** claro, no oscuro — `ColorScheme.fromSeed(seedColor: AppColors.azul, brightness: Brightness.light)`, fondo `gris`, tarjetas blancas — exactamente el `ThemeData` del Cotizador, copiado tal cual.

---

## 2. TIPOGRAFÍA

`fontFamily: 'Inter'` para toda la UI — la misma que usa el Cotizador, sin dependencias extra de Google Fonts. Se mantiene una tipografía monoespaciada (`monospace` del sistema) únicamente para datos técnicos (X/Y/Z, RPM, feed, G-code), porque ahí sí aporta legibilidad real sobre una fuente humanista.

---

## 3. QUÉ SE MANTIENE DE LA IDEA ORIGINAL (lo que sí sigue siendo "juego")

Aunque el color y el tema cambiaron por completo, estos elementos de la propuesta original **sí se conservan**, porque no dependían de la paleta oscura:

- **Skill Tree con ramas reales** (no un camino 100% lineal tipo Duolingo) — sigue siendo el patrón correcto para contenido con dependencias técnicas.
- **Tarjeta de misión con esquina chamfer** — el motivo "esto fue mecanizado" se mantiene, solo que ahora es una tarjeta blanca con borde de color en vez de una tarjeta oscura con glow.
- **Error Engine revelado paso a paso** (Error→Causa→Consecuencia→Explicación→Corrección) — se mantiene igual, con los colores de estado ya definidos (rojo/gris/verde).
- **XP, nivel, avisos de dificultad y concepto débil** — igual en estructura, recoloreados a la paleta oficial.

La "sensación de juego" ahora viene de la mecánica (misiones, XP, árbol de progreso), no del color — que es exactamente el balance correcto para una marca que necesita verse confiable ante talleres y clientes reales de HETNA, no solo divertida.

---

## 4. NAVEGACIÓN Y COMPONENTES

Sin cambios respecto al Cotizador: bottom nav de máximo 5 íconos + "Más" como drawer, tarjetas de estadística horizontales (ícono en círculo de color + número grande a la derecha), `AuthGate` revisando sesión real en cada arranque, marco de escritorio centrado en web con degradado azul alrededor (`Color(0xFF0f2438)` → `AppColors.azul`).

---

## PRÓXIMO PASO

Esta corrección ya está aplicada en el código (Ciclo 2, actualización de paleta) — `app_colors.dart`, `app_typography.dart` y `app_theme.dart` fueron reescritos para usar esta paleta tal cual. Los siguientes archivos de UI ya heredan el cambio automáticamente por usar los tokens de `AppColors` en vez de colores hardcodeados (confirmado por revisión completa del código), con 3 excepciones de contraste corregidas manualmente (texto sobre círculos de color que asumían fondo oscuro).
