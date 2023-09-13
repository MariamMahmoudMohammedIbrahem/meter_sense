import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/constants.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/sqldb.dart';
import 'package:flutter_reactive_ble_example/src/ui/device_detail/device_interaction_tab.dart';

class WaterData extends StatefulWidget {
  const WaterData({Key? key,}) : super(key: key);
  @override
  State<WaterData> createState() => _WaterDataState();
}

class _WaterDataState extends State<WaterData> {
  SqlDb sqlDb = SqlDb();
  Future<List<Map>> readData() async {
    final response = await sqlDb.readData("SELECT * FROM Water");
    return response;
  }
  @override
  Widget build(BuildContext context) => Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          sqlDb.mydeleteDatabase();
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: 2,
        items: const [
          Icon(
            Icons.electric_bolt_outlined,
            size: 30,
          ),
          Icon(Icons.add_circle_outline, size: 30),
          Icon(Icons.water_drop_outlined, size: 30),
        ],
        color: Colors.deepPurple.shade50,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          if (index == 0) {

          }
          else if (index == 1) {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (context) => DeviceInteractionTab(
                device: dataStored, characteristic: QualifiedCharacteristic(
                  characteristicId: Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
                  serviceId: Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
                  //device id get from register page when connected
                  deviceId: dataStored.id),
              )),
            );

          }
          else if (index == 2) {
          }

        },
      ),
      body: ListView(
        children: [
          FutureBuilder(
              future: readData(),
              builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot){
                if(snapshot.hasData){
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context,i)=> Card(
                          child: ListTile(
                            title: Text("ClientID: ${snapshot.data![i]['data']}"),
                            subtitle: Text("Device Name: ${snapshot.data![i]['title']}"),
                            trailing: Text("${snapshot.data![i]['time']}"),
                          ),
                        )
                  );
                }
                return const Center(child: CircularProgressIndicator(),);
              }
          ),
        ],
      ),
    );
}
