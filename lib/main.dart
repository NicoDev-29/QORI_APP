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
        initialRoute: '/',
        routes: {
          '/': (context) => const MainNavigationWrapper(),
          '/registro': (context) => const AgregarMovimientoScreen(),
          '/agregar_cuenta': (context) => const AgregarCuentaScreen(),
          '/presupuestos': (context) => const PresupuestoScreen(),
          '/escaner': (context) => const CameraScreen(),
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

class _MainNavigationWrapperState extends State<MainNavigationWrapper>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showExtraButtons = false;
  AnimationController? _animationController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HistorialScreen(),
    const CuentasScreen(),
    const ChatbotScreen(),
    const PerfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _showExtraButtons = false;
      _animationController?.reverse();
    });
  }

  void _toggleFab() {
    setState(() {
      _showExtraButtons = !_showExtraButtons;
      if (_showExtraButtons) {
        _animationController?.forward();
      } else {
        _animationController?.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],

          // Fondo oscuro al mostrar los botones extra
          if (_showExtraButtons)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleFab,
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
            ),

          // Botón billetera: VERDE con ícono blanco, redondo
          if (_showExtraButtons && _animationController != null)
            Positioned(
              bottom: 96,
              left: MediaQuery.of(context).size.width / 1.13 - 28,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _animationController!,
                  curve: Curves.easeOutBack,
                ),
                child: FloatingActionButton(
                  heroTag: 'walletBtn',
                  onPressed: () {
                    Navigator.pushNamed(context, '/registro');
                    setState(() => _showExtraButtons = false);
                  },
                  backgroundColor: Colors.green,
                  shape: const CircleBorder(), // asegura forma circular
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),

          // Botón cámara: MORADO con ícono blanco, redondo
          if (_showExtraButtons && _animationController != null)
            Positioned(
              bottom: 15, // mismo nivel que el FAB1
              left:
                  MediaQuery.of(context).size.width / 1.16 -
                  96, // 56 (FAB) + 12 (espacio) + 28 (mitad de FAB secundario)
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _animationController!,
                  curve: Curves.easeOutBack,
                ),
                child: FloatingActionButton(
                  heroTag: 'cameraBtn',
                  onPressed: () {
                    Navigator.pushNamed(context, '/escaner');
                    setState(() => _showExtraButtons = false);
                  },
                  backgroundColor: Colors.deepPurple,
                  shape: const CircleBorder(), // asegura forma circular
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
      floatingActionButton:
          (_currentIndex == 0 || _currentIndex == 1)
              ? FloatingActionButton(
                heroTag: 'mainFab',
                onPressed: _toggleFab,
                backgroundColor: AppColors.primary,
                child: Icon(
                  _showExtraButtons ? Icons.close : Icons.add,
                  size: 30,
                  color: Colors.white, // ¡ahora siempre será blanco!
                ),
              )
              : null,
    );
  }
}
