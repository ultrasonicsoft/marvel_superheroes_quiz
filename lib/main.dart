import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:guess_superheroes/superhero.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Marvel Super Heroes',
        theme:
            ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
        home: HeroesPage(title: 'Marvel Super Heroes'));
  }
}

class HeroesPage extends StatefulWidget {
  HeroesPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HeroesPageState createState() => _HeroesPageState();
}

class _HeroesPageState extends State<HeroesPage> {
  List<SuperHero> heroes;
  bool answered = true;
  String img = 'assets/3d_man.jpg';
  String selected = '';
  String hero = '';
  int index = 0;
  int score = 0;
  int count = 0;
  List<String> choices;
  final GlobalKey<ScaffoldState> _sKey = new GlobalKey<ScaffoldState>();

  _next() {
    setState(() {
      answered = false;
      selected = '';
      count = heroes.length;
      if (index == count) {
        showDialog(
            context: context,
            builder: (ctxt) => new AlertDialog(
                  title: Text("Game Over! Score: $score/$count"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Restart'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                )).then((dynamic t) => score = 0);
      }
      index = index == count ? 0 : index;
      img = heroes[index].imagePath;
      hero = heroes[index].name;
      index++;
      choices = new List();
      choices.add(hero);
      choices.add(heroes[new Random().nextInt(count - 1)].name);
      choices.add(heroes[new Random().nextInt(count - 1)].name);
      choices.add(heroes[new Random().nextInt(count - 1)].name);
      choices.shuffle();
    });
  }

  _check() async {
    setState(() {
      answered = true;
      if (selected == hero) score = score + 1;
    });
    Future.delayed(Duration(seconds: 1), _next);
    _sKey.currentState.showSnackBar(SnackBar(
        content: Text(selected == hero ? 'Correct!' : 'Wrong!!!'),
        duration: Duration(seconds: 1)));
  }

  _onChange(String newValue) async {
    setState(() => this.selected = newValue);
  }

  _getData() async {
    heroes = new List();
    await Future.forEach(
        json.decode(await DefaultAssetBundle.of(context)
            .loadString("assets/superheroes.json")),
        (dynamic hero) => heroes.add(new SuperHero(
            name: hero["name"], imagePath: 'assets/' + hero["path"])));
    setState(() => _next());
  }

  @override
  initState() {
    super.initState();
    _getData();
  }

  buildOptions(int index) {
    String text = choices != null ? choices[index] : '';
    return Row(children: <Widget>[
      Radio(value: text, groupValue: selected, onChanged: _onChange),
      Text(text, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold))
    ]);
  }

  _navs() {
    return FloatingActionButton(child: Icon(Icons.done), onPressed: _check);
  }

  _question() {
    return Column(children: <Widget>[
      Container(
          padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Text(
              'Question: ' + index.toString() + '/' + heroes.length.toString(),
              style: TextStyle(fontSize: 20, color: Colors.blue))),
      Container(
          width: 250.0,
          height: 250.0,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              image:
                  DecorationImage(fit: BoxFit.fill, image: AssetImage(img)))),
      Visibility(child: Text(hero, textScaleFactor: 3), visible: answered),
      Container(
          padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
          child: Column(children: <Widget>[
            buildOptions(0),
            buildOptions(1),
            buildOptions(2),
            buildOptions(3)
          ]))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _sKey,
        appBar: AppBar(title: Text(widget.title)),
        body: Column(children: <Widget>[_question()]),
        floatingActionButton: _navs());
  }
}
