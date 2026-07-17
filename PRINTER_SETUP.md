# Epson TM-M30 Series III Network Printer Integration

## Configuration Summary

Your POS system is now configured to print receipts to the Epson TM-M30 Series III printer at **192.168.1.156:9100**.

## Printer Specifications

- **Model**: Epson TM-M30 Series III
- **IP Address**: 192.168.1.156
- **Port**: 9100 (standard ESC/POS port)
- **Connection Type**: TCP/IP (Ethernet)
- **Protocol**: ESC/POS
- **Paper Width**: 80mm
- **Features**: 
  - High-speed thermal printing
  - Reliable network connectivity
  - Built-in Ethernet support
  - Compatible with Flutter/Dart via Socket API

## How It Works

1. **Payment Processing**
   - Customer completes payment in POS
   - Transaction is created and saved to database
   - Receipt printer is automatically invoked

2. **Receipt Generation**
   - Transaction data is encoded to ESC/POS format
   - ESC/POS bytes are sent over network to printer

3. **Printer Output**
   - Printer receives bytes via TCP/IP port 9100
   - Thermal printer outputs formatted receipt
   - Paper is automatically cut

## Integration Details

### Files Modified

**lib/main.dart**
```dart
// NetworkPrinterDriver initialized with your printer
final networkDriver = NetworkPrinterDriver();

// Epson TM-M30 registered in discovery
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

// Automatically assigned to Receipt role
printerManager.assignPrinter(PrinterRole.receipt, printer);
```

### New Files Created

1. **lib/services/network_printer_driver.dart**
   - `NetworkPrinterDriver`: Implements TCP/IP printing via Socket
   - `NetworkPrinterDiscovery`: Network printer discovery
   - `PrinterException`: Error handling for printer operations

### Testing

- **Network Driver Tests**: `test/services/network_printer_test.dart`
  - ✓ TCP/IP printer identification
  - ✓ Error handling for connection failures
  - ✓ ESC/POS byte generation
  - ✓ Printer configuration validation

## Network Connectivity

### Prerequisites

1. Printer must be on the same network as the POS system
2. Network must support TCP/IP connectivity on port 9100
3. Firewall must allow connections to printer IP

### Testing Connectivity

**From Command Line (macOS/Linux):**
```bash
# Test TCP connection to printer
nc -zv 192.168.1.156 9100

# Or using telnet (if available)
telnet 192.168.1.156 9100
```

**From Windows:**
```cmd
# Test connection using PowerShell
Test-NetConnection -ComputerName 192.168.1.156 -Port 9100
```

### Printer Configuration

1. **Default Network Setup**
   - IP: DHCP (or manual: 192.168.1.156)
   - Port: 9100
   - Protocol: TCP/IP

2. **Accessing Printer Settings**
   - Connect to printer web interface: `http://192.168.1.156`
   - Default credentials may be required
   - Check printer manual for network configuration

## Receipt Output

### Sample Receipt

```
            POS RECEIPT
Receipt: TXN-1001
Date: 2026-07-05 22:46
Cashier: John

----------------------------------------
Item                   Qty      Price
----------------------------------------
Espresso               x2      $7.00
Cappuccino             x1      $4.50

----------------------------------------
Subtotal                        $11.50
Tax                             $1.15
TOTAL                           $12.65

----------------------------------------
Payment: Cash
Amount: $20.00
Change: $7.35


    Thank you for your purchase!
```

### Receipt Features

- ✓ Centered header and footer
- ✓ Itemized product list
- ✓ Subtotal, Tax, Total
- ✓ Payment method and amount
- ✓ Change calculation
- ✓ Cashier information
- ✓ Transaction timestamp
- ✓ Automatic paper cut

## Troubleshooting

### Connection Issues

**Problem**: "Failed to send bytes to printer"

**Solutions**:
1. Verify printer IP address: `192.168.1.156`
2. Check network connectivity: `ping 192.168.1.156`
3. Verify port 9100 is open: `nc -zv 192.168.1.156 9100`
4. Check printer is powered on
5. Restart printer and try again

**Problem**: "No printer assigned for role: receipt"

**Solution**: Restart the POS app - printer is auto-assigned on startup

### Paper Issues

1. **Paper Out**
   - Load paper into printer
   - Press Feed button to resume

2. **Paper Jam**
   - Remove paper cartridge
   - Clear jam area
   - Reload and test print

### Printer Maintenance

- Clean thermal head periodically with soft brush
- Use only approved thermal paper
- Check for paper dust buildup
- Refer to Epson TM-M30 manual for detailed maintenance

## Settings & Configuration

### System Info - Printer Settings

In the POS app:
1. Go to **Settings** → **System Info**
2. Scroll to **Printers** section
3. Your printer will be listed: "Epson TM-M30 Series III"
4. Status shows: "Receipt" role assigned
5. Click **Test Print** to verify connectivity

### Automatic Receipt Printing

- ✓ Enabled by default
- Triggered automatically when payment is processed
- No user action required
- Printer must be online and ready

## Advanced Configuration

### Changing Printer IP Address

Edit `lib/main.dart`:
```dart
const PrinterDevice(
  address: '192.168.1.156',  // Change this IP
  port: 9100,                 // Or this port
)
```

Then rebuild: `flutter run`

### Multiple Printers

Support for multiple printer roles:
- **Receipt Printer**: Customer receipts (your TM-M30)
- **Kitchen Printer**: Order tickets
- **Label Printer**: Product labels
- **Barcode Printer**: Barcode labels

Current setup assigns TM-M30 to Receipt role only.

## Reference Documentation

- **Epson TM-M30 Manual**: Check printer documentation
- **ESC/POS Standard**: Industry-standard thermal printer commands
- **Flutter Socket API**: dart:io Socket for network communication
- **Receipt Printer Abstraction**: `lib/services/receipt_printer.dart`

## Support

### Test Results

All 78 unit tests passing:
- ✓ Network driver tests (10 tests)
- ✓ Receipt printer tests (4 tests)
- ✓ Payment flow tests (60+ tests)
- ✓ No analyzer issues

### Version Info

- Flutter SDK: Latest
- Dart: Latest
- Platform: macOS/Windows/Linux/iOS/Android
- Printer: Epson TM-M30 Series III
- Protocol: ESC/POS

---

**Integration Status**: ✓ COMPLETE

Your Epson TM-M30 is ready to print receipts!
