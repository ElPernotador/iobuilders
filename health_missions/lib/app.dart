import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class HealthMissionsApp extends StatelessWidget {
  const HealthMissionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodayProvider()),
        ChangeNotifierProvider(create: (_) => MealsProvider()),
        ChangeNotifierProvider(create: (_) => TrainingProvider()),
        ChangeNotifierProvider(create: (_) => ShoppingProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Misiones de Salud',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF121212),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          navigationBarTheme: const NavigationBarThemeData(
            backgroundColor: Color(0xFF1E1E1E),
            indicatorColor: Color(0xFF2A3A5A),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1E1E1E),
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.white38,
          ),
        ),
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
  int _index = 0;

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
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Hoy'),
          NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Comidas'),
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Entreno'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Compras'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Progreso'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
