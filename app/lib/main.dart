import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // root of the application.
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',

        // app main colors
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),

        home: MyHomePage(),
      ),

    );
  }
}

class MyAppState extends ChangeNotifier { 
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favourites = <WordPair>[];

  void toggleFavourite(){
    if (favourites.contains(current)){
      favourites.remove(current);
    } else {
      favourites.add(current);
    }
    notifyListeners();
    print(favourites);
  }

  void setState(WordPair leString){
    current = leString;
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: BigCard(pair: pair),
            ),
            
        
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: (){
                    appState.toggleFavourite();
                  }, 
                  child: Text('like ' + (appState.favourites.contains(pair) == true ? "♥" : "♡"))
                  ),
                        
                SizedBox(width: 10,),

                ElevatedButton(
                onPressed: (){
                  appState.getNext();
                }, 
                child: Text('change app state')
                ),

                // make a button to test if setting manually the appState makes the heart whole
                ElevatedButton(
                onPressed: (){
                  appState.setState("broadhour");
                }, 
                child: Text('change app state')
                ),
              ],
            )
          ]
        ),
      ),
    );
  }

}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),

        // 2 random word concatenated part thing
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0, bottom: 2.0, top: 0.0, right: 5.0),
          child: Text(
            pair.asLowerCase, 
            style: style,
            semanticsLabel: "${pair.first} ${pair.second}",
            ),
        ),
      ),
    );
  }
}