import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'PeriodicTable.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(PeriodicTableApp());
}

class PeriodicTableApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Periodic Table',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'Periodic Table'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  List<Widget> _widgets = [
    PeriodicTableWidget(),
    AboutMeWidget(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_on),
            label: 'Periodic Table',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face),
            label: 'About Me',
          ),
        ],
        onTap: (index) => _onItemTapped(index),
        currentIndex: _selectedIndex,
      ),
      body: _widgets[_selectedIndex],
    );
  }
}

class AboutMeWidget extends StatelessWidget {
  final TextStyle headingStyle =
      TextStyle(fontSize: 25, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: Image.asset(
              "assets/profile_picture.png",
            ),
          ),
          Text(""),
          Text(
            "Abdiel Rodriguez Gutierrez",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          HyperLink(
            link: "mailto:abdielarg2012@gmail.com" +
                "?subject=Regarding your Periodic Table App..." +
                "&body=I would like to contact you to...",
            text: "Send me a mail",
            textStyle: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class PeriodicTableWidget extends StatefulWidget {
  @override
  _PeriodicTableWidgetState createState() => _PeriodicTableWidgetState();
}

class _PeriodicTableWidgetState extends State<PeriodicTableWidget> {
  PeriodicTable periodicTable = PeriodicTable(elements: []);
  static double sliderMin = 3;
  static double sliderMax = 6;
  static double sliderValue = sliderMin;
  double textPadding = 15;

  _PeriodicTableWidgetState() {
    getElements();
  }

  void getElements() async {
    String contenido = await rootBundle.loadString("assets/elements.json");
    setState(() {
      periodicTable = PeriodicTable.fromJson(contenido);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: textPadding),
              child: Text("Elements per row: "),
            ),
            Expanded(
              child: Slider(
                min: sliderMin,
                max: sliderMax,
                value: sliderValue,
                divisions: (sliderMax - sliderMin).toInt(),
                onChanged: (value) {
                  setState(() {
                    sliderValue = value;
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: textPadding),
              child: Text("$sliderValue"),
            ),
          ],
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: sliderValue.toInt(),
            children: [
              ...periodicTable.elements!.map((e) => ElementWidget(element: e))
            ],
            shrinkWrap: true,
          ),
        )
      ],
    );
  }
}

class ElementWidget extends StatelessWidget {
  final PeriodicTableElement element;

  const ElementWidget({required this.element});

  Future<void> showElementInformation(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text("${element.name!} (${element.symbol}) - ${element.number}"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Definition(
                    title: "Summary", text: element.summary ?? "No summary"),
                Definition(
                    title: "Appearance",
                    text: this.element.appearance ?? "Invisible"),
                Definition(title: "Category", text: this.element.category!),
                Definition(
                    title: "Color", text: this.element.color ?? "Colorless"),
                Definition(
                    title: "Phase",
                    text: element.phase
                        .toString()
                        .replaceAll("Phase.", "")
                        .toLowerCase()),
                Definition(
                    title: "Discovered by/in",
                    text: this.element.discoveredBy ?? "Unknown"),
                Definition(
                    title: "Named by", text: this.element.namedBy ?? "Unknown"),
                Definition(
                  title: "Source",
                  text: this.element.source ?? "",
                  isHyperLink: true,
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  element.number.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  element.symbol!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  element.name!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        color: Color(int.parse("80${element.cpkHex ?? "FFFFFF"}", radix: 16)),
      ),
      onTap: () => showElementInformation(context),
    );
  }
}

class Definition extends StatelessWidget {
  final String title;
  final String text;
  final bool isHyperLink;

  Definition({
    required this.title,
    required this.text,
    this.isHyperLink = false,
  });

  @override
  Widget build(BuildContext context) {
    InlineSpan span;

    if (isHyperLink) {
      span = WidgetSpan(
        child: HyperLink(link: this.text),
      );
    } else {
      span = TextSpan(text: "${this.text}\n");
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
              text: "${this.title}: ",
              style: TextStyle(fontWeight: FontWeight.bold)),
          span
        ],
      ),
    );
  }
}

class HyperLink extends StatelessWidget {
  final String link;
  final String? text;
  final TextStyle? textStyle;

  final TextStyle defaultTextStyle = const TextStyle(
    color: Colors.blueAccent,
    decoration: TextDecoration.underline,
  );

  const HyperLink({
    required this.link,
    this.text,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text(
        this.text ?? this.link,
        style: defaultTextStyle.merge(textStyle),
      ),
      onTap: () => launch(this.link),
    );
  }
}
