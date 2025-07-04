import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:qori/ui/screens/screens_exports.dart';
import 'package:qori/themes/theme.dart';
import 'package:qori/providers/providers_export.dart';
import 'package:qori/ui/widgets/bottom_navigation_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovimientoProvider()),
        ChangeNotifierProvider(create: (_) => CuentaProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),       
        ChangeNotifierProvider(create: (_) => PresupuestoProvider()),
      ],
      child: MaterialApp(
        title: 'QORI - App Finanzas',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          MonthYearPickerLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es'), Locale('en')],
        locale: const Locale('es'),
        // Eliminamos la propiedad home
        initialRoute: '/',
        routes: {
          '/': (context) => const MainNavigationWrapper(),
          '/registro': (context) => const AgregarMovimientoScreen(),
          '/agregar_cuenta': (context) => const AgregarCuentaScreen(),
          '/presupuestos': (context) => const PresupuestoScreen(),
          // Mantén tus otras rutas si las necesitas
        },
      ),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HistorialScreen(),
    const CuentasScreen(), 
    const ChatbotScreen(),
    const PerfilScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
      floatingActionButton:
          _currentIndex == 0 || _currentIndex == 1
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/registro');
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
    );
  }
}
