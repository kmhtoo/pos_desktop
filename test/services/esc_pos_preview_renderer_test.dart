import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos_desktop/services/esc_pos_preview_renderer.dart';

void main() {
  const renderer = EscPosPreviewRenderer();

  group('EscPosPreviewRenderer', () {
    test('parses ESC alignment and font state commands', () {
      final bytes = <int>[
        0x1B, 0x40, // ESC @
        0x1B, 0x61, 0x01, // center
        0x1B, 0x21, 0x30, // double width + height
        ...'TITLE'.codeUnits,
        0x0A,
        0x1B, 0x61, 0x02, // right
        ...'TOTAL'.codeUnits,
        0x0A,
        0x1B, 0x21, 0x00, // normal
        0x1B, 0x45, 0x01, // bold on
        ...'Bold Line'.codeUnits,
        0x0A,
      ];

      final lines = renderer.parse(bytes);
      expect(lines, hasLength(3));

      expect(lines[0].text, 'TITLE');
      expect(lines[0].align, TextAlign.center);
      expect(lines[0].doubleSize, isTrue);
      expect(lines[0].bold, isFalse);

      expect(lines[1].text, 'TOTAL');
      expect(lines[1].align, TextAlign.right);
      expect(lines[1].doubleSize, isTrue);

      expect(lines[2].text, 'Bold Line');
      expect(lines[2].align, TextAlign.right);
      expect(lines[2].doubleSize, isFalse);
      expect(lines[2].bold, isTrue);
    });

    test('parses GS character size command', () {
      final bytes = <int>[
        0x1B, 0x40, // ESC @
        0x1D, 0x21, 0x11, // GS ! size 2x2
        ...'Large'.codeUnits,
        0x0A,
        0x1D, 0x21, 0x00, // normal
        ...'Normal'.codeUnits,
        0x0A,
      ];

      final lines = renderer.parse(bytes);
      expect(lines, hasLength(2));
      expect(lines[0].doubleSize, isTrue);
      expect(lines[1].doubleSize, isFalse);
    });

    test('builds plain text without control bytes', () {
      final bytes = <int>[
        0x1B,
        0x40,
        ...'Hello'.codeUnits,
        0x0A,
        0x1D,
        0x56,
        0x00,
        ...'World'.codeUnits,
      ];

      final text = renderer.toPlainText(bytes);
      expect(text, 'Hello\nWorld');
    });
  });
}
