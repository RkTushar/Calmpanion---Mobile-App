import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

void main() async {
  // Create a picture from the SVG
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder);

  // Draw the SVG
  final ui.Paint paint = ui.Paint()..color = Colors.blue;
  canvas.drawCircle(ui.Offset(512, 512), 512, paint);

  // Convert to image
  final ui.Picture picture = recorder.endRecording();
  final ui.Image image = await picture.toImage(1024, 1024);
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

  if (byteData != null) {
    // Save the PNG file
    final File file = File('assets/icon/icon.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    print('Icon saved successfully!');
  }
}
