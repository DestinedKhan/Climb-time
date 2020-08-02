import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';

FlutterBlue b = FlutterBlue.instance;
BluetoothDevice t;
var name = "climb-time";
var characteristics;
BluetoothCharacteristic c;
Guid UUID = new Guid("734732cb-c248-4b47-a79f-2268c78b0abc");
List<Widget> a;
List<ButtonMaker> aa = new List();
var finService;
List<BluetoothService> services;
var bCount = -20;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();



  runApp(MyApp());


}
class ButtonMaker {
  var count = 0;
  bool p = false;
  var status = "X";
  var myCount = bCount;

  Widget makeButton()  {
    print(bCount);
    bCount++;

    return Container(
      height: 20,
      width: 20,
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: Icon(Icons.add),
        tooltip: bCount.toString(),
        color: Colors.black,
        onPressed: () {
          count++;
          if(count>=5){
            //Reset it to off
            count = 0;
          }
          getLight();
        },
      ),
    );


    }
    String getStatus(){
    return status;
    }
  void getLight() async{
    print(aa.length);
    List<ButtonMaker> temp;
    String stats = "";

    switch(count){
      case 0: {
        status = "X";
      }
      break;
      case 1: {
        status = "R";
      }
      break;
      case 2: {
        status = "G";
      }
      break;
      case 3: {
        status = "B";
      }
      break;
      case 4: {
        status = "W";
      }
      break;
    }

    var anotherCounter = 0;
    for(ButtonMaker w in aa){
      anotherCounter++;

      stats = stats+w.status;

    }

    print("Data sent");
    stats = stats.substring(20);
    print(stats);


    var bCharacteristics = finService.characteristics;
    for(BluetoothCharacteristic bCharacter in bCharacteristics) {
      await bCharacter.write(utf8.encode(stats));
    }

  }

}

class MyApp extends StatelessWidget {
  var count = 0;
  var bCount = -20;
  bool p = false;
  void getLight() async{
    var bCharacteristics = finService.characteristics;
    for(BluetoothCharacteristic bCharacter in bCharacteristics) {
      await bCharacter.write([count]);
    }
  }


  Widget makeBlue(){
    return Container(
      height: 30,
      width: 30,
      child: IconButton(
          icon: Icon(Icons.bluetooth),
          color: Colors.blue,
          onPressed: (){
            if(p){
              try{
                t.disconnect();
                print("Disconnected");
                p=!p;
              }catch(NoSuchMethodError){
                print("Not Connected");
                p=!p;
              }

            }else {
              print("Touched");
              connectBlue();
              p=!p;
            }
          }
      ),

    );
  }

  Widget makeButton()  {
    print(bCount);
    bCount++;
    if(bCount>0){
      a.add(this);
    }
    return Container(
      height: 20,
      width: 20,
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: Icon(Icons.add),
        tooltip: bCount.toString(),
        color: Colors.black,
        onPressed: () {
          count++;
          if(count>=5){
            //Reset it to off
            count = 0;
          }
          getLight();
        },
      ),
    );


  }


  void connectBlue() async {
    b.startScan(timeout: Duration(seconds: 4));
    var subscription = b.scanResults.listen((results) async {
      for(ScanResult r in results){
        print('${r.device.name} found! rssi: ${r.rssi}');
        if(r.device.name == name){
          print("we got em");
          t = r.device;
          await t.connect();
          services = await t.discoverServices();
          services.forEach((service) async{
            print(service.uuid);
            if(service.uuid==UUID){
              finService=service;
            }
          });
//            var bCharacteristics = finService.characteristics;
//          for(BluetoothCharacteristic bCharacter in bCharacteristics){
//            print("Got here");
//            List<int> value = await bCharacter.read();
//            print("Value: ");
//            print(value);
//          }
        };
        b.stopScan();
      }
    });
  }


  // This widget is the root of your application.


  /*
  0 = off
  1 = red
  2 = blue
  3 = green
  4 = orange
  After it gets to four it should reset count to 0
   */

  @override
  Widget build(BuildContext context) {
    //var height = MediaQuery.of(context).size.height;
    return MaterialApp(
        title: 'Climb time',
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFF6a2c70),
              title: Text("Climb time"),
            ),
            backgroundColor: Color(0xFFb83b5e),
            body: Row(
                children: <Widget>[
                  Spacer(),
                  makeBlue(),
                  Spacer(),

                  Column(
                    children: <Widget>[
                      Spacer(),
                      Container(
                        height: 600,
                        width: 300,
                        child: GridView.count(
                          crossAxisCount: 4,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 35,
                          scrollDirection: Axis.vertical,
                          children: List.generate(20, (index) {

                            ButtonMaker w = new ButtonMaker();
                            Widget b = w.makeButton();
                            aa.add(w);


                            return b;

                          }),
                        ),
                      ),

                    ],
                  )

                  ],

                 ),

            ),
    );
  }
}


