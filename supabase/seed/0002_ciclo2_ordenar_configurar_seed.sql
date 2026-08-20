-- CNC MASTER LAB — Seed adicional del Ciclo 2
-- Agrega misiones tipo 'ordenar' y 'configurar' sobre las skills de
-- Fundamentos ya existentes (Ciclo 1). Nomenclatura Vectric, confirmada
-- en CNC_MASTER_LAB_DOCUMENTATION_INTELLIGENCE_REPORT.md.

-- ============================================================
-- Misión tipo "ordenar" — flujo antes de tocar la máquina
-- (fundamentos.origen_pieza: reforzar el procedimiento correcto,
-- no solo el concepto de origen)
-- ============================================================
insert into mission_templates (tipo, skill_id, dificultad, contenido)
select
  'ordenar',
  id,
  'principiante',
  jsonb_build_object(
    'pregunta', 'Ordena correctamente los pasos antes de iniciar un corte con material nuevo en la mesa.',
    'pasos', jsonb_build_array(
      jsonb_build_object('id', 'p1', 'texto', 'Colocar y fijar el material nuevo en la mesa'),
      jsonb_build_object('id', 'p2', 'texto', 'Tocar la superficie real del material para fijar Z0'),
      jsonb_build_object('id', 'p3', 'texto', 'Cargar el archivo de toolpath/G-code del trabajo'),
      jsonb_build_object('id', 'p4', 'texto', 'Iniciar el corte y monitorear')
    ),
    'orden_correcto', jsonb_build_array('p1', 'p2', 'p3', 'p4'),
    'xp_recompensa', 60
  )
from skills where codigo = 'fundamentos.origen_pieza'
on conflict do nothing;

-- ============================================================
-- Misión tipo "configurar" — elegir la herramienta y el tipo de
-- referencia de origen correctos para una operación dada
-- (fundamentos.coordenadas)
-- ============================================================
insert into mission_templates (tipo, skill_id, dificultad, contenido)
select
  'configurar',
  id,
  'principiante',
  jsonb_build_object(
    'pregunta', 'Vas a hacer un pocket (bolsillo) con paredes rectas en MDF. Configura la herramienta y el tipo de origen correctos.',
    'parametros', jsonb_build_array(
      jsonb_build_object(
        'id', 'herramienta',
        'nombre', 'Herramienta',
        'opciones', jsonb_build_array(
          jsonb_build_object('id', 'end_mill', 'texto', 'End Mill'),
          jsonb_build_object('id', 'ball_nose', 'texto', 'Ball Nose'),
          jsonb_build_object('id', 'v_bit', 'texto', 'V-Bit')
        ),
        'valor_correcto_id', 'end_mill'
      ),
      jsonb_build_object(
        'id', 'referencia_origen',
        'nombre', 'Referencia de origen (Job Setup)',
        'opciones', jsonb_build_array(
          jsonb_build_object('id', 'origen_pieza', 'texto', 'Origen de pieza (material actual)'),
          jsonb_build_object('id', 'origen_maquina', 'texto', 'Origen de máquina (posición fija)')
        ),
        'valor_correcto_id', 'origen_pieza'
      )
    ),
    'error_codigo_si_falla', 'herramienta_incompatible_material',
    'xp_recompensa', 80
  )
from skills where codigo = 'fundamentos.coordenadas'
on conflict do nothing;
