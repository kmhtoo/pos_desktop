import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'data/app_database.dart';
import 'data/pos_repository.dart';
import 'providers/pos_provider.dart';
import 'screens/login_screen.dart';
import 'services/receipt_printer.dart';
import 'services/network_printer_driver.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_isDesktopPlatform) {
    await windowManager.ensureInitialized();
  }

  // Initialise DB and load persisted state before showing UI
  final db = AppDatabase();
  final repository = PosRepository(db);
  
  // Initialize printer manager with network printer driver
  final networkDriver = NetworkPrinterDriver();
  const noOpDriver = NoOpPrinterDriver();
  
  // Create a static discovery with your Epson TM-M30 printer
  final printerDiscovery = StaticPrinterDiscovery([
    const PrinterDevice(
      id: 'epson-tm-m30',
      name: 'Epson TM-M30 Series III',
      connectionType: PrinterConnectionType.tcpIp,
      address: '192.168.1.156',
      port: 9100,
      supportsEscPos: true,
    ),
  ]);
  
  final printerManager = PrinterManager(
    discovery: printerDiscovery,
    drivers: [networkDriver, noOpDriver],
  );
  
  final provider = PosProvider(
    repository: repository,
    printerManager: printerManager,
  );
  await provider.init();
  
  // Auto-assign the printer to receipt role
  printerManager.assignPrinter(
    PrinterRole.receipt,
    const PrinterDevice(
      id: 'epson-tm-m30',
      name: 'Epson TM-M30 Series III',
      connectionType: PrinterConnectionType.tcpIp,
      address: '192.168.1.156',
      port: 9100,
      supportsEscPos: true,
    ),
  );

  if (_isDesktopPlatform) {
    const windowOptions = WindowOptions(
      minimumSize: Size(1024, 700),
      center: true,
      title: 'FlutterPOS',
      backgroundColor: Color(0xFF0F172A),
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setFullScreen(true);
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const POSApp(),
    ),
  );
}

class POSApp extends StatelessWidget {
  const POSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterPOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: false).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF14B8A6),
          secondary: Color(0xFF06B6D4),
          surface: Color(0xFF1E293B),
          error: Color(0xFFEF4444),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

bool get _isDesktopPlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux);
