import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/nav_controller.dart';
import 'core/selected_date_controller.dart';
import 'core/theme.dart';
import 'features/meals/meals_provider.dart';
import 'features/meals/meals_screen.dart';
import 'features/progress/progress_provider.dart';
import 'features/progress/progress_screen.dart';
import 'features/settings/settings_provider.dart';
import 'features/settings/settings_screen.dart';
import 'features/shopping/shopping_provider.dart';
import 'features/shopping/shopping_screen.dart';
import 'features/today/today_provider.dart';
import 'features/today/today_screen.dart';
import 'features/training/training_provider.dart';
import 'features/training/training_screen.dart';

class DieterApp extends StatelessWidget {
  const DieterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavController()),
        ChangeNotifierProvider(create: (_) => SelectedDateController()),
        ChangeNotifierProvider(create: (_) => TodayProvider()),
        ChangeNotifierProvider(create: (_) => MealsProvider()),
        ChangeNotifierProvider(create: (_) => TrainingProvider()),
        ChangeNotifierProvider(create: (_) => ShoppingProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Dieter',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const MainShell(),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _screens = [
    TodayScreen(),
    MealsScreen(),
    TrainingScreen(),
    ShoppingScreen(),
    ProgressScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavController>();
    return Scaffold(
      body: IndexedStack(
        index: nav.index,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.hairline)),
        ),
        child: NavigationBar(
          selectedIndex: nav.index,
          onDestinationSelected: (i) => nav.goTo(i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.wb_sunny_outlined),
                selectedIcon: Icon(Icons.wb_sunny),
                label: 'Hoy'),
            NavigationDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon: Icon(Icons.restaurant_menu),
                label: 'Comidas'),
            NavigationDestination(
                icon: Icon(Icons.fitness_center_outlined),
                selectedIcon: Icon(Icons.fitness_center),
                label: 'Entreno'),
            NavigationDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                selectedIcon: Icon(Icons.shopping_cart),
                label: 'Compras'),
            NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights),
                label: 'Progreso'),
            NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Ajustes'),
          ],
        ),
      ),
    );
  }
}
