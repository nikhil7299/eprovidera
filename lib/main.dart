import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BreadCrumbProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Main',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
        routes: {
          '/new': (context) => const NewBreadCrumbWidget(),
          '/exp': ((context) => const ExpPage()),
        },
      ),
    );
  }
}

class BreadCrumb {
  bool isActive;
  final String name;
  final String uuid;
  BreadCrumb({
    required this.isActive,
    required this.name,
  }) : uuid = const Uuid().v4();

  void activate() {
    isActive = true;
  }

  @override
  bool operator ==(covariant BreadCrumb other) => uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  String get title => name + (isActive ? ' > ' : '');
}

class BreadCrumbProvider extends ChangeNotifier {
  final List<BreadCrumb> _items = [];
  UnmodifiableListView<BreadCrumb> get items => UnmodifiableListView(_items);

  void add(BreadCrumb breadCrumb) {
    for (final item in _items) {
      item.activate();
    }
    _items.add(breadCrumb);
    notifyListeners();
  }

  void reset() {
    _items.clear();
    notifyListeners();
  }
}

// typedef OnBreadCrumbTapped = void Function(BreadCrumb);

class BreadCrumbsWidget extends StatelessWidget {
  // final OnBreadCrumbTapped onTapped;
  final UnmodifiableListView<BreadCrumb> breadCrumbs;
  const BreadCrumbsWidget({
    super.key,
    required this.breadCrumbs,
    // required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: breadCrumbs.map(
        (breadCrumb) {
          return GestureDetector(
            onTap: () {
              // onTapped(breadCrumb);
              Navigator.of(context).pushNamed('/exp');
            },
            child: Text(
              breadCrumb.title,
              style: TextStyle(
                color: breadCrumb.isActive ? Colors.blue : Colors.black,
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Consumer<BreadCrumbProvider>(builder: (context, value, child) {
              return BreadCrumbsWidget(
                // onTapped: ((p0) {
                //   Navigator.of(context).pushNamed('/exp');
                // }),
                breadCrumbs: value.items,
              );
            }),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/new');
              },
              child: const Text("Add New Bread Crumb"),
            ),
            TextButton(
              onPressed: () {
                context.read<BreadCrumbProvider>().reset();
              },
              child: const Text("Reset"),
            ),
          ],
        ),
      ),
    );
  }
}

class NewBreadCrumbWidget extends StatefulWidget {
  const NewBreadCrumbWidget({super.key});

  @override
  State<NewBreadCrumbWidget> createState() => _NewBreadCrumbWidgetState();
}

class _NewBreadCrumbWidgetState extends State<NewBreadCrumbWidget> {
  late final TextEditingController _controller;
  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add new Bread Crumb")),
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                  hintText: 'Enter a new bread crumb here...'),
            ),
            TextButton(
              onPressed: () {
                final text = _controller.text;
                if (text.isNotEmpty) {
                  final breadCrumb = BreadCrumb(isActive: false, name: text);
                  context.read<BreadCrumbProvider>().add(
                        breadCrumb,
                      );
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpPage extends StatelessWidget {
  const ExpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Experimenting")),
      body: SafeArea(
          child: Container(
        color: Colors.teal.shade400,
        child: const Text("Exp Page"),
      )),
    );
  }
}
//! we usually use 'read' on ur provider inside a callbacks,like callback of a text button- onPressed
// read() gets a snapshot of the provider at a particular instance of time
// select,read,watch,provider.of

//select 
//-used to select and watch (pick) specific changes out of all the changes happening
//-as we are not intrested in the changes of whole provider, but only some specific changes
// and marks your widget to be rebuild, so it watches specific aspect of ur provider, if that
// changes it marks it for rebuild.
//!- only to be used inside build() function of ur widget-ie below build() line
//-changes to the selected value will mark the widget as needing to be rebuilt

//When provider emits an update, all selectors will be called
// and the widet with context.select watching specific selector will be rebuild
// only if the returned value is different from the previously returned value

//watch() listens to all the changes in the particular provider, will mark for rebuild
//if provider changes 
// whereas select() marks for rebuild if that particular change that u are looking for is chnaged

// watch() also allows to listen to opotional providers, say if this kind of provider exists
// up the chain i'm intrested in its changes, so even if that provider doesn't exist, app won't crash
// context.watch() has listen defaul to true, which is same as Provider.of<T>(context)
// so watch() uses provider.of<T> internally
//! watch() is used in build fn of stateless, and build fn of state object of stateful widget

//normally use select or watch for stateless widget

//! Use Provider.of<T> outside the build fun instead

//Consumer - Provider.of<T> - builder
//consumer creates a new widget and calls the builder with its own build context 
//it also wraps itselfaround the return widget from the builder
//Consumer will call the Provider.of with its own buildcontext, as we cannot use buildcontext of
// widget which is ancestor of the provider
//The child widget of consumer doesn't get rebuild whenever the provider values changes