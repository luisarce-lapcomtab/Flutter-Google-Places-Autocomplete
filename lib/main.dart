import 'package:autocomplete/place_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _destinationController = TextEditingController();
  PlaceApi _placeApi = PlaceApi.instance;
  bool buscando = false;
  List<Place> _predictions = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  _inputOnChanged(String query) {
    if (query.trim().length > 2) {
      setState(() {
        buscando = true;
      });
      _search(query);
    } else {
      if (buscando || _predictions.length > 0) {
        setState(() {
          buscando = false;
          _predictions = [];
        });
      }
    }
  }

  _search(String query) {
    _placeApi
        .searchPredictions(query)
        .asStream()
        .listen((List<Place> predictions) {     
        setState(() {
          buscando = false;
          _predictions = predictions ?? [];
          //  print('Resultados: ${predictions.length}');
        });      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            buscando
                ? Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                        itemCount: _predictions.length,
                        itemBuilder: (_, i) {
                          final Place item = _predictions[i];
                          return ListTile(
                            title: Text(item.description),
                            leading: Icon(Icons.location_on),
                          );
                        }))
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return AppBar(
      title: Text(
        "Enter destination",
        style: TextStyle(
            fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,
      leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {}),
      bottom: PreferredSize(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Column(
            children: [
              AddressInput(
                iconData: Icons.gps_fixed,
                hintText: "Punto de partida",
                enabled: false,
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  AddressInput(
                    controller: _destinationController,
                    iconData: Icons.place_sharp,
                    hintText: " ¿A dónde vas?",
                    onChanged: this._inputOnChanged,
                  ),
                  InkWell(
                    child: Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 28,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        preferredSize: Size.fromHeight(70),
      ),
    );
  }
}

class AddressInput extends StatelessWidget {
  final IconData iconData;
  final TextEditingController controller;
  final String hintText;
  final Function onTap;
  final bool enabled;
  final void Function(String) onChanged;

  const AddressInput({
    Key key,
    this.iconData,
    this.controller,
    this.hintText,
    this.onTap,
    this.enabled,
    this.onChanged,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          this.iconData,
          size: 18,
          color: Colors.black,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
            height: 35.0,
            width: MediaQuery.of(context).size.width / 1.4,
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.grey[100],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onTap: onTap,
              enabled: enabled,
              decoration: InputDecoration.collapsed(
                hintText: hintText,
              ),
            ),
          ),
        )
      ],
    );
  }
}
