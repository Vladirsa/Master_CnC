# CNC MASTER LAB — CICLO 2 (alcance)

## Objetivo
Ampliar el Mission Generator con 2 tipos más de actividad (**Ordenar** y **Configurar**,
de los 8 del Blueprint) y activar el **Difficulty Engine** basado en reglas
(Blueprint sección 9) para que la dificultad del jugador se ajuste sola.

## Incluye
- Motor de dificultad basado en reglas (sin ML) — `lib/core/difficulty/difficulty_engine.dart`.
- Actualización automática de `players.dificultad_actual` tras cada intento.
- Detección de "concepto débil" (mismo error ≥3 veces) con aviso visual — no genera
  todavía una Recovery Mission completa con contenido propio (eso es Ciclo 3).
- 2 tipos de misión nuevos: **Ordenar** (arrastrar pasos a su secuencia correcta) y
  **Configurar** (elegir parámetros de corte con controles reales, no opción múltiple).
- Contenido real nuevo en el seed para estos 2 tipos, sobre las skills de Fundamentos
  ya existentes.

## Explícitamente fuera de este ciclo
Los otros 4 tipos de misión (Simulación, Diagnóstico, Reparación, Proyecto — requieren
el simulador 3D o casos más largos), repetición espaciada, logros, Recovery Missions
con contenido generado automáticamente.

## Reglas del Difficulty Engine implementadas (Blueprint sección 9, literal)
```
SI precisión > 90% Y errores < 10% Y ayudas = 0   → subir dificultad
SI precisión < 60%                                 → bajar dificultad
SI mismo error ≥ 3 veces                           → marcar concepto débil
SI habilidad > 85%                                  → marcar como dominada
```
"Ayudas" todavía no existe como sistema (Blueprint sección 11, Ciclo 4+), así que la
regla de "ayudas = 0" se aplica siempre como verdadera por ahora — se activa de verdad
cuando exista el sistema de pistas.
