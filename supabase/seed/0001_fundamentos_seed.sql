-- CNC MASTER LAB — Seed de contenido real del Ciclo 1
-- Nomenclatura base: Vectric (VCarve/Aspire), confirmado en
-- CNC_MASTER_LAB_DOCUMENTATION_INTELLIGENCE_REPORT.md sección 6.
-- Todo el texto es contenido original de Master Lab, NO copiado de manuales.

-- ============================================================
-- MÁQUINA DE REFERENCIA (router 3 ejes — Blueprint sección 7)
-- ============================================================
insert into machines (nombre, tipo, ejes)
values ('Router CNC 3 ejes (referencia HETNA)', 'router', 3)
on conflict do nothing;

-- ============================================================
-- SKILLS — rama Fundamentos
-- ============================================================
insert into skills (codigo, nombre, rama, requisito_previo)
values ('fundamentos.coordenadas', 'Coordenadas X/Y/Z', 'fundamentos', null)
on conflict (codigo) do nothing;

insert into skills (codigo, nombre, rama, requisito_previo)
select 'fundamentos.origen_pieza', 'Origen de pieza vs. origen de máquina', 'fundamentos', id
from skills where codigo = 'fundamentos.coordenadas'
on conflict (codigo) do nothing;

-- ============================================================
-- BIBLIOTECA DE ERRORES (Error Engine — Blueprint sección 10)
-- ============================================================
insert into errors_catalog (codigo, causa, consecuencia, explicacion, correccion)
values (
  'origen_z_incorrecto',
  'Se dejó el cero de Z en el punto anterior de la mesa en vez de tocar la superficie real del material nuevo.',
  'La herramienta baja más o menos de lo esperado: puede clavarse en el material o cortar en el aire sin remover nada.',
  'En Vectric, el "Job Setup" define X0/Y0/Z0 desde donde se calculan TODOS los toolpaths. Si Z0 no coincide con la superficie real del material que está en la máquina en este momento, cada profundidad de corte queda desplazada — el software no tiene forma de saber que cambiaste de material si tú no le avisas.',
  'Antes de iniciar cualquier trabajo, vuelve a establecer Z0 tocando la superficie real del material actual (no confíes en la posición de un trabajo anterior). En router 3 ejes esto se hace físicamente en la máquina, no solo en el software.'
)
on conflict (codigo) do nothing;

insert into errors_catalog (codigo, causa, consecuencia, explicacion, correccion)
values (
  'herramienta_incompatible_material',
  'Se seleccionó una herramienta (ej. V-Bit) para una operación que requiere remoción de material plano (ej. Pocket), en vez de un End Mill.',
  'El acabado sale con paredes en ángulo donde deberían ser rectas, o la herramienta no logra la profundidad plana esperada.',
  'Cada herramienta tiene una geometría de corte distinta: End Mill (paredes rectas, desbaste y perfiles), Ball Nose (superficies curvas/3D), V-Bit (v-carving y detalle en ángulo). Elegir la herramienta según la geometría del corte deseado — no la más disponible — es lo que separa un corte limpio de uno que hay que repetir.',
  'Revisa qué tipo de pared necesitas antes de asignar la herramienta al toolpath: paredes rectas → End Mill; superficie curva → Ball Nose; detalle en V → V-Bit.'
)
on conflict (codigo) do nothing;

-- ============================================================
-- MISIONES — generadas desde mission_templates.contenido (jsonb)
-- ============================================================

-- Misión tipo "seleccion" para fundamentos.coordenadas
insert into mission_templates (tipo, skill_id, dificultad, contenido)
select
  'seleccion',
  id,
  'principiante',
  jsonb_build_object(
    'pregunta', '¿Qué eje controla el movimiento de la herramienta hacia arriba y hacia abajo (profundidad de corte) en un router CNC de 3 ejes?',
    'opciones', jsonb_build_array(
      jsonb_build_object('id', 'x', 'texto', 'Eje X'),
      jsonb_build_object('id', 'y', 'texto', 'Eje Y'),
      jsonb_build_object('id', 'z', 'texto', 'Eje Z')
    ),
    'respuesta_correcta_id', 'z',
    'xp_recompensa', 50
  )
from skills where codigo = 'fundamentos.coordenadas'
on conflict do nothing;

-- Misión tipo "detectar_error" para fundamentos.origen_pieza
insert into mission_templates (tipo, skill_id, dificultad, contenido)
select
  'detectar_error',
  id,
  'principiante',
  jsonb_build_object(
    'pregunta', 'Terminaste un trabajo y colocaste una pieza de MDF nueva en la mesa. Antes de iniciar el siguiente corte, ¿qué debes verificar primero?',
    'opciones', jsonb_build_array(
      jsonb_build_object('id', 'a', 'texto', 'Que el cero Z esté establecido en la superficie del material NUEVO'),
      jsonb_build_object('id', 'b', 'texto', 'Que el color del material coincida con la vista previa del software'),
      jsonb_build_object('id', 'c', 'texto', 'Nada, el cero del trabajo anterior sigue siendo válido')
    ),
    'respuesta_correcta_id', 'a',
    'error_codigo_si_falla', 'origen_z_incorrecto',
    'xp_recompensa', 75
  )
from skills where codigo = 'fundamentos.origen_pieza'
on conflict do nothing;
