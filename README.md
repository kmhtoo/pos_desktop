# flutter_pos_desktop

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Added Support-Ready Capabilities

In `lib/services/receipt_printer.dart`:

### ESC/POS Support
- `EscPosEncoder` abstraction
- `BasicEscPosEncoder` default implementation

### Connection Types
`PrinterConnectionType` enum:
- `bluetooth`
- `tcpIp`
- `usb`

### Multiple Printer Roles
`PrinterRole` enum: `receipt`, `kitchen`, `barcode`, `label`
- `PrinterManager` can assign/unassign a printer per role.

### Automatic Discovery Abstraction
- `PrinterDiscovery` interface
- `discoverAvailablePrinters()` on `PrinterManager`
- `StaticPrinterDiscovery` (test/default discovery provider)

### Driver Abstraction
- `PrinterDriver` interface
- `PrinterManager` routes payload to the first compatible driver.

### Print Routing
- `printReceipt()` routes to `PrinterRole.receipt`
- `printEscPos(role, transaction)` for ESC/POS role-based prints
- `printRaw(role, bytes)` for non-receipt payloads (kitchen/barcode/label workflows)

### Existing Payment Flow
`PosProvider.processPayment()` still prints through `ReceiptPrinter` (now compatible with plugging in `PrinterManager`).

### Tests Added
`test/services/receipt_printer_test.dart` validates:
- Discovery returns devices
- Receipt print routes to assigned printer
- Multi-role routing works (receipt + kitchen)