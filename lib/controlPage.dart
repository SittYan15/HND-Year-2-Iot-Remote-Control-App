import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

import 'package:flutter/services.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';

class ControlWidget extends StatefulWidget {
  const ControlWidget({super.key});

  @override
  State<ControlWidget> createState() => _ControlWidgetState();
}

class _ControlWidgetState extends State<ControlWidget> {

  final _bluetoothClassicPlugin = BluetoothClassic();

  Color _forwardColor = Colors.blue;
  Color _backwardColor = Colors.blue;
  Color _leftColor = Colors.blue;
  Color _rightColor = Colors.blue;
  Color _autoColor = Colors.black;

  bool _canMove = true;
  bool _isForward = false;
  bool _isAutoMove = false;
  bool _isBackward = false;
  bool _isLeft = false;
  bool _isRight = false;

  Uint8List _data = Uint8List(0);

  bool _isLoadingVisible = false;
  int _timeLeft = 0;

  Future<void> _ArdoWrite(String value) async {
    print('Direction $value');
    await _bluetoothClassicPlugin.write(value);
  }

  Future<bool> _ArdoRead() async {
    _bluetoothClassicPlugin.onDeviceDataReceived().listen((event) {
      _data = Uint8List.fromList([..._data, ...event]);
      print(_data);
    });

    return true;
  }

  Future<void> _TestGroundFunction() async {
    _canMove = false;
    _ArdoWrite('T');
    bool result = await _ArdoRead();
    _canMove = true;
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 0,
      ),
      body: Stack(
        children: [
          Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.tealAccent.shade100,
              child: Column(
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        LiteRollingSwitch(
                          value: true,
                          width: 130,
                          textOn: 'Manual',
                          textOff: 'Auto',
                          colorOn: Colors.green,
                          colorOff: Colors.red,
                          iconOn: Icons.key,
                          iconOff: CupertinoIcons.rocket,
                          animationDuration: const Duration(milliseconds: 300),
                          onChanged: (bool state) {
                            if (state) {
                              _ArdoWrite('Q');
                            }
                            else {
                              _ArdoWrite('q');
                            }
                          },
                          onDoubleTap: () {},
                          onSwipe: () {},
                          onTap: () {},
                        ),
                        ElevatedButton(
                          child: const Text('Show Total Result'),
                          onPressed: () {
                            _ArdoWrite('o');
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _ArdoWrite('G');
                            _countDown(20);
                          },
                          child: Text('Test Ground'),
                        ),
                        LiteRollingSwitch(
                          value: true,
                          width: 130,
                          textOn: 'Turbo',
                          textOff: 'Eco',
                          colorOn: Colors.red,
                          colorOff: Colors.green,
                          iconOn: Icons.lightbulb_outline,
                          iconOff: Icons.battery_saver,
                          animationDuration: const Duration(milliseconds: 300),
                          onChanged: (bool state) {
                            if (state) {
                              _ArdoWrite('P');
                            }
                            else {
                              _ArdoWrite('p');
                            }
                          },
                          onDoubleTap: () {},
                          onSwipe: () {},
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const SizedBox(height: 30),
                              GestureDetector(
                                onTapDown: (details) {
                                  if (!_isBackward && _canMove && !_isLeft && !_isRight) {
                                    _isForward = true;
                                    setState(() {
                                      print('Moving Forward');
                                      _forwardColor = Colors.blue.shade900;
                                    });
                                    _ArdoWrite('W');
                                  }
                                },
                                onTapUp: (details) {
                                  if (!_isBackward && _canMove && !_isLeft && !_isRight) {
                                    _isForward = false;
                                    print('Forward Stopped');
                                    setState(() {
                                      _forwardColor = Colors.blue;
                                    });
                                    _ArdoWrite('w');
                                  }
                                },
                                onTapCancel: () {
                                  if (!_isBackward && _canMove && !_isLeft && !_isRight) {
                                    _isForward = false;
                                    print('Forward Stopped');
                                    setState(() {
                                      _forwardColor = Colors.blue;
                                    });
                                    _ArdoWrite('w');
                                  }
                                },
                                // onDoubleTap: () {
                                //   if (!_isBackward && _canMove && !_isAutoMove) {
                                //     _isForward = true;
                                //     _isAutoMove = true;
                                //     print('Auto Moving Forward');
                                //     setState(() {
                                //       _autoColor = Colors.orange;
                                //     });
                                //     _ArdoWrite('E');
                                //   }
                                //   else {
                                //     _isForward = false;
                                //     _isAutoMove = false;
                                //     print('Auto Moving Forward Stopped');
                                //     setState(() {
                                //       _autoColor = Colors.black;
                                //     });
                                //     _ArdoWrite('e');
                                //   }
                                // },
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      color: _forwardColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.black,
                                      )
                                  ),
                                  child: Icon(CupertinoIcons.up_arrow, size: 30, color: _autoColor,),
                                ),
                              ),
                              const SizedBox(height: 30),
                              GestureDetector(
                                onTapDown: (details) {
                                  if (!_isForward && _canMove && !_isLeft && !_isRight) {
                                    _isBackward = true;
                                    setState(() {
                                      print('Moving Backward');
                                      _backwardColor = Colors.blue.shade900;
                                    });
                                    _ArdoWrite('S');
                                  }
                                },
                                onTapUp: (details) {
                                  if (!_isForward && _canMove && !_isLeft && !_isRight) {
                                    _isBackward = false;
                                    print('Backward Stopped');
                                    setState(() {
                                      _backwardColor = Colors.blue;
                                    });
                                    _ArdoWrite('s');
                                  }
                                },
                                onTapCancel: () {
                                  if (!_isForward && _canMove && !_isLeft && !_isRight) {
                                    _isBackward = false;
                                    print('Backward Stopped');
                                    setState(() {
                                      _backwardColor = Colors.blue;
                                    });
                                    _ArdoWrite('s');
                                  }
                                },
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      color: _backwardColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.black,
                                      )
                                  ),
                                  child: Icon(CupertinoIcons.down_arrow, size: 30,),
                                ),
                              ),
                            ],
                          )
                      ),
                      Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTapDown: (details) {
                                  if (!_isRight && _canMove && !_isForward && !_isBackward) {
                                    _isLeft = true;
                                    setState(() {
                                      print('Moving Left');
                                      _leftColor = Colors.blue.shade900;
                                    });
                                    _ArdoWrite('A');
                                  }
                                },
                                onTapUp: (details) {
                                  if (!_isRight && _canMove && !_isForward && !_isBackward) {
                                    _isLeft = false;
                                    print('Left Stopped');
                                    setState(() {
                                      _leftColor = Colors.blue;
                                    });
                                    _ArdoWrite('a');
                                  }
                                },
                                onTapCancel: () {
                                  if (!_isRight && _canMove && !_isForward && !_isBackward) {
                                    _isLeft = false;
                                    print('Left Stopped');
                                    setState(() {
                                      _leftColor = Colors.blue;
                                    });
                                    _ArdoWrite('a');
                                  }
                                },
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      color: _leftColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.black,
                                      )
                                  ),
                                  child: Icon(CupertinoIcons.left_chevron, size: 30,),
                                ),
                              ),
                              GestureDetector(
                                onTapDown: (details) {
                                  if (!_isLeft && _canMove && !_isForward && !_isBackward) {
                                    _isRight = true;
                                    setState(() {
                                      print('Moving Right');
                                      _rightColor = Colors.blue.shade900;
                                    });
                                    _ArdoWrite('D');
                                  }
                                },
                                onTapUp: (details) {
                                  if (!_isLeft && _canMove && !_isForward && !_isBackward) {
                                    _isRight = false;
                                    print('Right Stopped');
                                    setState(() {
                                      _rightColor = Colors.blue;
                                    });
                                    _ArdoWrite('d');
                                  }
                                },
                                onTapCancel: () {
                                  if (!_isLeft && _canMove && !_isForward && !_isBackward) {
                                    _isRight = false;
                                    print('Right Stopped');
                                    setState(() {
                                      _rightColor = Colors.blue;
                                    });
                                    _ArdoWrite('d');
                                  }
                                },
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      color: _rightColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.black,
                                      )
                                  ),
                                  child: Icon(CupertinoIcons.right_chevron, size: 30,),
                                ),
                              ),
                            ],
                          )
                      ),
                    ],
                  ),
                ],
              )
          ),
          Align(
            alignment: Alignment.center,
            child: Visibility(
              visible: _isLoadingVisible,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.black45,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 200),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.blue),
                        const SizedBox(height: 30),
                        const Text('Measuring Ground Sensors....', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                        const SizedBox(height: 10),
                        Text('Please wait .. $_timeLeft seconds', style: TextStyle(fontSize: 20),),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      )
    );
  }

  void _countDown(int count) async {
    setState(() {
      _isLoadingVisible = true;
    });
    for (int i = count; i > 0; i--) {
      setState(() {
        _timeLeft = i;
      });
      await Future.delayed(const Duration(seconds: 1));
    }
    _ArdoWrite('w');
    _ArdoWrite('a');
    _ArdoWrite('s');
    _ArdoWrite('d');
    setState(() {
      _isLoadingVisible = false;
    });
  }
}
