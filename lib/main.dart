import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pomodoro/settingScreen.dart';

void main() {
  runApp(PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pomodoro Timer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade500,
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25,),
        ),
      ),
      home: const PomodoroScreen(),
    );
  }
}

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  int _pomodoroDuration =25;
  int _shortBreakDuration = 5;
  int _longBreakDuration = 10;
  late int _duration = _pomodoroDuration * 60;
  late int _remainingTime = _duration;
  bool _isWorking = false;
  int _completedCycles = 0;
  int _cyclesUntilLongBreak = 4;
  final List<bool> _isSelected = [true, false, false];
  Timer? _timer;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeNotifications() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = const AndroidInitializationSettings('shot');
    final settings = InitializationSettings(android: initializationSettingsAndroid);
    _flutterLocalNotificationsPlugin.initialize(settings);
  }

  void _startTimer() {
    setState(() {
      _isWorking = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          timer.cancel();
          if (_isSelected[0] == true) {
            _showNotification('Pomodoro Timer', 'Time is up!');
            if (_completedCycles < _cyclesUntilLongBreak-1) {
              _buttonChange(1);
              _completedCycles++;
              _startTimer();
            }
            else{
              _completedCycles=0;
              _buttonChange(2);
              _startTimer();
            }
          }
          else if (_isSelected[1]==true ) {
            _showNotification('short break Timer', 'Time is up!');
            _buttonChange(0);
            _startTimer();
          }
          else{
            _showNotification('long break Timer', 'Time is up!');
            _buttonChange(0);
            _startTimer();
          }
        }
      });
    });
  }

  void _resetTimer() {
    setState(() {
      _remainingTime = _duration;
      _isWorking = false;
      _completedCycles=0;
    });
    _timer?.cancel();
  }
  void _pauseTimer() {
    setState(() {
      _isWorking = false;
    });
    _timer?.cancel();
  }

  void _buttonChange(int index) {
    setState(() {
      for (int i = 0; i < _isSelected.length; i++) {
        _isSelected[i] = i == index;
        _isWorking = false;
        _pauseTimer();
      }
      if (index == 0) {
        _duration = _pomodoroDuration * 60;
      } else if (index == 1) {
        _duration = _shortBreakDuration * 60;
      } else {
        _duration = _longBreakDuration * 60;
      }
      _remainingTime = _duration;
    });
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _configureDurations(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => SettingScreen(
            onSettingsChanged: (int pomodoro, int shortBreak, int longBreak,int cycles) {
              setState(() {
                _pomodoroDuration = pomodoro;
                _shortBreakDuration = shortBreak;
                _longBreakDuration = longBreak;
                _cyclesUntilLongBreak = cycles;
                _duration = _pomodoroDuration * 60;
                _remainingTime = _duration;
              });
            },_pomodoroDuration,_shortBreakDuration,_longBreakDuration,_cyclesUntilLongBreak
        ),
      ),
    );
  }

  void _showNotification(String title, String body) {
    var androidChannelSpecifics = const AndroidNotificationDetails(
      'pomodoro',
      'test',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var platformChannelSpecifics = NotificationDetails(android: androidChannelSpecifics);
    _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.blue.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildButton('pomodoro', 0),
                  const SizedBox(width: 10),
                  _buildButton('Short Break', 1),
                  const SizedBox(width: 10),
                  _buildButton('Long Break', 2),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _formatDuration(_remainingTime),
                style: const TextStyle(
                  fontSize: 80,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isWorking ? _pauseTimer : _startTimer,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  _isWorking ? 'Pause' : 'Start',
                  style: const TextStyle(
                      fontSize: 20
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.refresh),
                    color: Colors.white,
                    iconSize: 30,
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () => _configureDurations(context),
                    icon: const Icon(Icons.settings),
                    iconSize: 30,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, int index) {
    return ElevatedButton(
      onPressed: () {
        _buttonChange(index);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _isSelected[index] ? Colors.red : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: _isSelected[index] ? Colors.white : Colors.black,
            fontSize: 15
        ),
      ),
    );
  }
}