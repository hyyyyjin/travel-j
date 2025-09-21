import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'models/plan.dart';
import 'providers/plan_list_provider.dart';
import 'screens/home_screen.dart';
import 'screens/plan_detail_screen.dart';
import 'screens/day_schedule_screen.dart';
import 'screens/edit_place_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: TripFlowApp()));
}

class TripFlowApp extends StatelessWidget {
  const TripFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
        useMaterial3: true,
      ),
      initialRoute: HomeScreen.routeName,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case HomeScreen.routeName:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case PlanDetailScreen.routeName:
            final planId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => PlanDetailScreen(planId: planId),
            );
          case DayScheduleScreen.routeName:
            final args = settings.arguments as DayScheduleArgs;
            return MaterialPageRoute(
              builder: (_) => DayScheduleScreen(args: args),
            );
          case EditPlaceScreen.routeName:
            final args = settings.arguments as EditPlaceArgs;
            return MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => EditPlaceScreen(args: args),
            );
        }
        return null;
      },
    );
  }
}
