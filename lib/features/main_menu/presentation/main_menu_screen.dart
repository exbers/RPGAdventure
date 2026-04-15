import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../shared/widgets/widgets.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GameScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const GameTitle(
            title: 'RPG Adventure',
            subtitle: 'Текстова рольова гра про вибір, ресурси і наслідки.',
          ),
          const SizedBox(height: 32),
          GamePanel(
            child: Text(
              'Сектор мовчить. Запаси обмежені. Кожен хід змінює те, '
              'що екіпаж зможе пережити завтра.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 24),
          GameActionList(
            children: [
              GameMenuButton(
                label: 'Нова гра',
                icon: Icons.play_arrow_rounded,
                isPrimary: true,
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.heroCreation),
              ),
              const GameMenuButton(
                label: 'Продовжити',
                icon: Icons.save_rounded,
                onPressed: null,
              ),
              GameMenuButton(
                label: 'Налаштування',
                icon: Icons.tune_rounded,
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.settings),
              ),
              GameMenuButton(
                label: 'Про гру',
                icon: Icons.info_outline_rounded,
                onPressed: () => _showMessage(
                  context,
                  'RPG Adventure: ранній прототип текстової рольової гри.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Версія 0.1.0',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
