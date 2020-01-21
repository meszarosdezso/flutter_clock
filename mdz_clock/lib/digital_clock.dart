// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  final _lightTheme = {
    "color": Colors.blue.shade700,
    "background": Colors.white
  };

  final _darkTheme = {
    "color": Colors.blueAccent.shade200,
    "background": Colors.black
  };

  var _theme;

  set theme(theme) {
    _theme = theme;
  }

  final List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ]; // Thank you Jesper on StackOverflow! https://stackoverflow.com/a/1643468 😄

  final List<String> weekDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );

      // _timer = Timer(
      //   Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );

      if (_dateTime.hour > 20 || _dateTime.hour < 6)
        theme = _darkTheme;
      else
        theme = _lightTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        fontFamily: "Raleway",
        textTheme: TextTheme(
          body1: TextStyle(
            color: _theme["color"],
          ),
        ),
      ),
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(24.0),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: _theme["background"],
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AnimatedNumber(
                      numberToAnimateTo: (_dateTime.hour / 10).floor(),
                      color: _theme['color'],
                    ),
                    AnimatedNumber(
                      numberToAnimateTo: (_dateTime.hour % 10),
                      color: _theme['color'],
                    ),
                    Dots(color: _theme['color']),
                    AnimatedNumber(
                      numberToAnimateTo: (_dateTime.minute / 10).floor(),
                      color: _theme['color'],
                    ),
                    AnimatedNumber(
                      numberToAnimateTo: (_dateTime.minute % 10),
                      color: _theme['color'],
                    ),
                  ],
                ),
              ),
              Positioned(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      "${widget.model.temperature.toString().replaceAll(".0", "")}°C",
                    ),
                    Text(
                      "${widget.model.location}",
                    ),
                  ],
                ),
                bottom: 0,
                right: 0,
              ),
              Positioned(
                child: Text(
                  "${weekDays[_dateTime.weekday - 1]}\n${months[_dateTime.month - 1]} ${_dateTime.day}.",
                ),
                top: 0,
                left: 0,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedNumber extends StatelessWidget {
  final int numberToAnimateTo;

  final Color color;

  const AnimatedNumber({Key key, this.numberToAnimateTo = 0, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FlareActor(
        "assets/Clock.flr",
        animation:
            "from${numberToAnimateTo == 0 ? 9 : numberToAnimateTo - 1}to$numberToAnimateTo",
        color: color ?? Colors.blue.shade200,
      ),
    );
  }
}

class Dots extends StatelessWidget {
  final Color color;

  const Dots({Key key, @required this.color}) : super(key: key);

  Widget _buildDot() => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.0,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildDot(),
          SizedBox(height: 20.0),
          _buildDot(),
        ],
      ),
    );
  }
}
