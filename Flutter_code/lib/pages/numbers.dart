import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:draw_me/dl_model/Classifier.dart';
import 'package:draw_me/utils/constants.dart';


class DrawNumPage extends StatefulWidget {
  @override
  _DrawPageState createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawNumPage> {
  Classifier _classifier = Classifier();
  List<Offset> points = [];
  final pointMode = ui.PointMode.points;
  int digit = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: Icon(Icons.close),
        onPressed: () {
          setState(() {
            points.clear();
            digit = -1;
          });
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.purpleAccent,
        title: Text("Draw Me"),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            Text(
                "Draw a digit",
                style: TextStyle(fontSize: 20)
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: canvasSize + borderSize*3,
              height: canvasSize + borderSize*3.5,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey, width: 2)),
              child: GestureDetector(
                onPanUpdate: (DragUpdateDetails details) {
                  Offset _localPosition = details.localPosition;
                  if (_localPosition.dx >= 0 &&
                      _localPosition.dx <= canvasSize &&
                      _localPosition.dy >= 0 &&
                      _localPosition.dy <= canvasSize) {
                    setState(() {
                      points.add(_localPosition);
                    });
                  }
                },
                onPanEnd: (DragEndDetails details) async {
                  points.add(null);
                  digit = await _classifier.classifyDrawingnum(points);
                  setState(() {});
                },
                child: CustomPaint(
                  painter: Painter(points: points),
                ),
              ),
            ),
            SizedBox(
              height: 45,
            ),
            Text(
                "Current Prediction:",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)
            ),
            SizedBox(
              height: 20,
            ),
            Text(
                digit == -1 ? "" : "$digit",
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.normal)
            ),
          ],
        ),
      ),
    );
  }
}

class Painter extends CustomPainter {
  final List<Offset> points;
  Painter({this.points});

  final Paint _paintDetails = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4.0 // strokeWidth 4 looks good, but strokeWidth approx. 16 looks closer to training data
    ..color = Colors.black;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], _paintDetails);
      }
    }
  }

  @override
  bool shouldRepaint(Painter oldDelegate) {
    return true;
  }
}