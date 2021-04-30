import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

import '../../models/card.dart';

final List<Color> colors = [
  Colors.blue,
  Colors.red,
  Colors.yellow,
  Colors.purple,
  Colors.lime,
  Colors.teal,
  Colors.orange,
  Colors.green,
  Colors.cyan,
];

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _firstCard;
  int _secondCard;
  bool _winner = false;
  bool _started = false;
  Timer _timer;
  int _seconds = 0;
  int _attemps = 0;
  List<GlobalKey<FlipCardState>> _cardKeys = [];

  List<CardModel> _allCards = [];

  @override
  void initState() {
    setCards();
    for (var i = 0; i < 12; i++) {
      _cardKeys.add(GlobalKey<FlipCardState>());
    }
    super.initState();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  void setCards() {
    print('SET CARDS >>>>');
    colors.shuffle(Random(1338102380));
    _allCards = [];
    _firstCard = null;
    _secondCard = null;
    _started = false;
    _seconds = 0;
    _attemps = 0;
    if (_timer != null) {
      _timer.cancel();
    }
    for (var i = 0; i < 6; i++) {
      _allCards.add(CardModel(color: colors[i], state: 0, type: 'Colors'));
    }

    _allCards.shuffle();

    for (var i = 0; i < 6; i++) {
      _allCards.add(CardModel(color: colors[i], state: 0, type: 'Colors'));
    }

    for (var i = 0; i < 12; i++) {
      if (_cardKeys.length > 0 && !_cardKeys[i].currentState.isFront) {
        _cardKeys[i].currentState.toggleCard();
      }
    }

    setState(() {});
  }

  void getMatch(int index) async {
    var tappedCard = _allCards[index];
    _attemps = _attemps + 1;
    print(
        'Tapped Card color: ${tappedCard.color} - state: ${tappedCard.state}');

    switch (tappedCard.state) {
      case 0:
        _winner = false;
        if (!_started) {
          print('START CLOCK >>>>>>');
          _started = true;
          _timer = Timer.periodic(Duration(seconds: 1), (time) {
            _seconds = time.tick;
            setState(() {});
          });
        }
        print('STATE 0 >>>>>>>>>>>');
        tappedCard.state = 1;
        _cardKeys[index].currentState.toggleCard();
        setState(() {});
        if (_firstCard == null) {
          print('FIRST CARD >>>>>>>>>>>');
          _firstCard = index;
        } else {
          print('SECOND CARD >>>>>>>>>>>');
          _secondCard = index;
        }

        if (_firstCard != null && _firstCard != index) {
          if (_allCards[_firstCard].color == tappedCard.color) {
            print('MATCH >>>>>>');
            _allCards[_firstCard].state = 3;
            tappedCard.state = 3;
            _firstCard = null;
            _secondCard = null;
            var win = _allCards.indexWhere((element) => element.state != 3);
            if (win == -1) {
              _started = false;
              _winner = true;
              _timer.cancel();
            }
            setState(() {});
          } else {
            await Future.delayed(Duration(milliseconds: 500));
            print('NO MATCH >>>>>>');
            _allCards[_firstCard].state = 0;
            tappedCard.state = 0;
            _cardKeys[index].currentState.toggleCard();
            _cardKeys[_firstCard].currentState.toggleCard();
            _firstCard = null;
            _secondCard = null;

            setState(() {});
          }
        }
        setState(() {});
        break;
      case 1:
        print('STATE 1 >>>>>>>>>>>');

        if (_firstCard == index) {
          tappedCard.state = 0;
          _firstCard = null;
        } else if (_secondCard == index) {
          tappedCard.state = 0;
          _secondCard = null;
        }
        setState(() {});
        break;
      case 3:
        print('STATE 3 >>>>>>>>>>>');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              _winner
                  ? Text('Winner!!! - Time: $_seconds - Attemps: $_attemps')
                  : Text('Ready! - Time: $_seconds - Attemps: $_attemps'),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  setCards();
                },
                child: _winner ? Text('Try Again') : Text('Start'),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  children: List.generate(
                    12,
                    (index) => GestureDetector(
                      onTap: () {
                        getMatch(index);
                      },
                      child: FlipCard(
                        key: _cardKeys[index],
                        flipOnTouch: false,
                        front: Container(
                          color: Colors.grey,
                        ),
                        back: Container(
                          color: _allCards[index].color,
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: Center(
                                child: Text(
                              '${index + 1}',
                              style: Theme.of(context).textTheme.headline2,
                            )),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
