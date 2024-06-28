import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wear/wear.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CronometroWatch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.compact,
      ),
      home: const WatchScreen(),
    );
  }
}

class WatchScreen extends StatelessWidget {
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return TimerScreen(mode);
          },
        );
      },
    );
  }
}

class TimerScreen extends StatefulWidget {
  final WearMode mode;

  const TimerScreen(this.mode, {super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  int _count = 0;
  String _strCount = "00:00:00";
  String _status = "Start";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.mode == WearMode.active ? Color.fromARGB(255, 0, 34, 88) : Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Image.asset(
                widget.mode == WearMode.active
                    ? 'assets/img/loboActive.png'
                    : 'assets/img/loboAmbient.png',
                width: 130,
                height: 130,
              ),
            ),
            const SizedBox(height: 2.0),
            Center(
              child: Text(
                _strCount,
                style: TextStyle(
                  color: widget.mode == WearMode.active ? Color.fromARGB(255, 182, 3, 15) : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _buildWidgetButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetButton() {
    if (widget.mode == WearMode.active) {
      if (_status == "Start" || _status == "Continue") {
        return Container(
          key: const ValueKey("StartButton"),
          padding: const EdgeInsets.all(0.1), 
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 7, 161, 140),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: _handleStartStopContinue,
            icon: const Icon(Icons.play_arrow, color: Color.fromARGB(255, 182, 3, 15)), 
          ),
        );
      } else {
        return Row(
          key: const ValueKey("ControlButtons"),
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(0.1),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 7, 161, 140),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _handleStartStopContinue,
                icon: const Icon(Icons.pause, color: Color.fromARGB(255, 182, 3, 15)), 
              ),
            ),
            Container(
              padding: const EdgeInsets.all(0.1), 
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 7, 161, 140),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _handleReset,
                icon: const Icon(Icons.refresh, color: Color.fromARGB(255, 182, 3, 15)), 
              ),
            ),
          ],
        );
      }
    } else {
      return Container();
    }
  }

  void _handleStartStopContinue() {
    if (_status == "Start" || _status == "Continue") {
      _startTimer();
    } else if (_status == "Stop") {
      _timer?.cancel();
      setState(() {
        _status = "Continue";
      });
    }
  }

  void _handleReset() {
    _timer?.cancel();
    setState(() {
      _count = 0;
      _strCount = "00:00:00";
      _status = "Start";
    });
  }

  void _startTimer() {
    setState(() {
      _status = "Stop";
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _count += 1;
        _strCount = _formatTime(_count);
      });
    });
  }

  String _formatTime(int count) {
    int hour = count ~/ 3600;
    int minute = (count % 3600) ~/ 60;
    int second = (count % 3600) % 60;
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
