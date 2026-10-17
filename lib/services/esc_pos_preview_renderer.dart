import 'package:flutter/widgets.dart';

class EscPosPreviewLine {
  const EscPosPreviewLine({
    required this.text,
    required this.align,
    required this.bold,
    required this.doubleSize,
  });

  final String text;
  final TextAlign align;
  final bool bold;
  final bool doubleSize;
}

class EscPosPreviewRenderer {
  const EscPosPreviewRenderer();

  static const int _esc = 0x1B;
  static const int _gs = 0x1D;
  static const int _lf = 0x0A;
  static const int _cr = 0x0D;

  List<EscPosPreviewLine> parse(List<int> bytes) {
    final lines = <EscPosPreviewLine>[];
    final buffer = StringBuffer();

    var align = TextAlign.left;
    var bold = false;
    var doubleWidth = false;
    var doubleHeight = false;
    var i = 0;

    bool isDoubleSize() => doubleWidth || doubleHeight;

    void flushLine() {
      lines.add(
        EscPosPreviewLine(
          text: buffer.toString(),
          align: align,
          bold: bold,
          doubleSize: isDoubleSize(),
        ),
      );
      buffer.clear();
    }

    while (i < bytes.length) {
      final b = bytes[i];

      if (b == _esc) {
        if (i + 1 >= bytes.length) break;
        final command = bytes[i + 1];

        if (command == 0x40) {
          // ESC @ Initialize
          align = TextAlign.left;
          bold = false;
          doubleWidth = false;
          doubleHeight = false;
          i += 2;
          continue;
        }
        if (command == 0x69 || command == 0x6D) {
          // ESC i/m Cut paper
          i += 2;
          continue;
        }
        if (command == 0x61 && i + 2 < bytes.length) {
          // ESC a n Alignment
          final mode = bytes[i + 2];
          align = switch (mode) {
            0x01 => TextAlign.center,
            0x02 => TextAlign.right,
            _ => TextAlign.left,
          };
          i += 3;
          continue;
        }
        if (command == 0x45 && i + 2 < bytes.length) {
          // ESC E n Emphasized on/off
          bold = bytes[i + 2] != 0;
          i += 3;
          continue;
        }
        if (command == 0x21 && i + 2 < bytes.length) {
          // ESC ! n Select print mode
          final mode = bytes[i + 2];
          bold = (mode & 0x08) != 0;
          doubleHeight = (mode & 0x10) != 0;
          doubleWidth = (mode & 0x20) != 0;
          i += 3;
          continue;
        }
        i += 2;
        continue;
      }

      if (b == _gs) {
        if (i + 1 >= bytes.length) break;
        final command = bytes[i + 1];

        if (command == 0x21 && i + 2 < bytes.length) {
          // GS ! n Character size
          final mode = bytes[i + 2];
          final widthMultiplier = ((mode >> 4) & 0x0F) + 1;
          final heightMultiplier = (mode & 0x0F) + 1;
          doubleWidth = widthMultiplier > 1;
          doubleHeight = heightMultiplier > 1;
          i += 3;
          continue;
        }
        if ((command == 0x56 || command == 0x6B || command == 0x76) &&
            i + 2 < bytes.length) {
          // Common print/cut/image commands in the stream that we skip for text view
          i += 2;
          continue;
        }
        i += 2;
        continue;
      }

      if (b == _lf) {
        flushLine();
        i += 1;
        continue;
      }
      if (b == _cr) {
        i += 1;
        continue;
      }
      if (b >= 0x20 && b <= 0x7E) {
        buffer.writeCharCode(b);
      }
      i += 1;
    }

    if (buffer.isNotEmpty) {
      flushLine();
    }

    return lines;
  }

  String toPlainText(List<int> bytes) {
    final lines = parse(bytes);
    return lines.map((line) => line.text).join('\n').trimRight();
  }
}
