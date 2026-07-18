import 'dart:async';
import 'dart:io';
import 'receipt_printer.dart';

/// Real TCP/IP implementation for network printers (Epson TM-M30, etc.)
class NetworkPrinterDriver implements PrinterDriver {
  NetworkPrinterDriver({
    this.connectionTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 30),
  });

  final Duration connectionTimeout;
  final Duration receiveTimeout;
  static const int _dle = 0x10;
  static const int _eot = 0x04;

  @override
  bool canHandle(PrinterDevice device) =>
      device.connectionType == PrinterConnectionType.tcpIp;

  @override
  Future<void> sendBytes(PrinterDevice device, List<int> bytes) async {
    final socket = await _connect(device);
    try {
      // Send the ESC/POS bytes
      socket.add(bytes);
      await socket.flush();

      // Give printer time to process before closing
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      throw PrinterException('Error sending data to printer: $e');
    } finally {
      await socket.close();
    }
  }

  @override
  Future<void> testConnection(PrinterDevice device) async {
    final socket = await _connect(device);
    await socket.close();
    await _assertPrinterHealth(device);
  }

  Future<void> _assertPrinterHealth(PrinterDevice device) async {
    final errorStatus = await _readRealtimeStatus(
      device: device,
      statusCode: 3,
      statusName: 'error',
    );
    if ((errorStatus & 0x08) != 0) {
      throw PrinterException(
        'Printer error detected: cutter or hardware error.',
      );
    }
    if ((errorStatus & 0x40) != 0) {
      throw PrinterException(
        'Printer error detected: unrecoverable hardware error.',
      );
    }

    final paperStatus = await _readRealtimeStatus(
      device: device,
      statusCode: 4,
      statusName: 'paper',
    );
    if ((paperStatus & 0x40) != 0) {
      throw PrinterException('Printer is out of paper.');
    }
    if ((paperStatus & 0x20) != 0) {
      throw PrinterException('Printer paper is near end.');
    }
  }

  Future<int> _readRealtimeStatus({
    required PrinterDevice device,
    required int statusCode,
    required String statusName,
  }) async {
    final socket = await _connect(device);
    try {
      socket.add([_dle, _eot, statusCode]);
      await socket.flush();
      final response = await socket.first.timeout(receiveTimeout);
      if (response.isEmpty) {
        throw PrinterException(
          'Printer returned empty $statusName status response.',
        );
      }
      return response.first;
    } on TimeoutException {
      throw PrinterException(
        'Timed out while reading $statusName status from printer.',
      );
    } catch (e) {
      if (e is PrinterException) rethrow;
      throw PrinterException(
        'Failed to read $statusName status from printer: $e',
      );
    } finally {
      await socket.close();
    }
  }

  Future<Socket> _connect(PrinterDevice device) async {
    if (!canHandle(device)) {
      throw PrinterException(
        'This driver only handles TCP/IP printers. Got: ${device.connectionType}',
      );
    }

    try {
      return await Socket.connect(
        device.address,
        device.port ?? 9100,
        timeout: connectionTimeout,
      );
    } on SocketException catch (e) {
      throw PrinterException(
        'Network error connecting to printer at ${device.address}:${device.port ?? 9100}: $e',
      );
    } catch (e) {
      throw PrinterException('Error connecting to printer: $e');
    }
  }
}

/// Exception class for printer errors
class PrinterException implements Exception {
  PrinterException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Network printer discovery using broadcast (optional enhancement)
class NetworkPrinterDiscovery implements PrinterDiscovery {
  NetworkPrinterDiscovery({this.timeout = const Duration(seconds: 3)});

  final Duration timeout;

  @override
  Future<List<PrinterDevice>> discoverPrinters() async {
    // For now, return empty list - actual implementation would require
    // mDNS/Bonjour discovery or network scanning
    // This is complex and requires additional setup
    return [];
  }

  /// Manually add a known printer (for hardcoded network address)
  Future<PrinterDevice> addKnownPrinter({
    required String id,
    required String name,
    required String ipAddress,
    int port = 9100,
  }) async {
    // Verify connectivity before adding
    try {
      final socket = await Socket.connect(
        ipAddress,
        port,
        timeout: const Duration(seconds: 5),
      );
      await socket.close();

      return PrinterDevice(
        id: id,
        name: name,
        connectionType: PrinterConnectionType.tcpIp,
        address: ipAddress,
        port: port,
      );
    } catch (e) {
      throw PrinterException(
        'Failed to connect to printer at $ipAddress:$port: $e',
      );
    }
  }
}
