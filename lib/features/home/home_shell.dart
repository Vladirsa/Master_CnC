import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../skills/skill_map_screen.dart';
import '../profile/profile_screen.dart';

/// Navegación del Ciclo 1: Aprender / Perfil / Más — máximo 5 tabs,
/// "Más" como drawer para lo que se agregue después (Simulador, Retos...).
/// Ver CNC_MASTER_LAB_CICLO1_KICKOFF.md sección 5 y Design System sección 4.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    SkillMapScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: DesktopFrame(child: SafeArea(child: _screens[_index])),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          if (i == 2) {
            _abrirMas(context);
            return;
          }
          setState(() => _index = i);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.account_tree_outlined), label: 'Aprender'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Más'),
        ],
      ),
    );
  }

  void _abrirMas(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.view_in_ar_outlined, color: AppColors.textSecondary),
              title: const Text('Simulador'),
              trailing: const _ProximamenteChip(),
              enabled: false,
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events_outlined, color: AppColors.textSecondary),
              title: const Text('Logros'),
              trailing: const _ProximamenteChip(),
              enabled: false,
            ),
            ListTile(
              leading: const Icon(Icons.handshake_outlined, color: AppColors.textSecondary),
              title: const Text('Patrocinadores'),
              trailing: const _ProximamenteChip(),
              enabled: false,
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                Navigator.pop(context);
                await Supabase.instance.client.auth.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip "Próximamente" — nunca se oculta la función, solo se marca como
/// no disponible todavía. Evita la queja de "candado sorpresa" detectada
/// en el Intelligence Report de mercado (sección L).
class _ProximamenteChip extends StatelessWidget {
  const _ProximamenteChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text('Próximamente', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    );
  }
}
