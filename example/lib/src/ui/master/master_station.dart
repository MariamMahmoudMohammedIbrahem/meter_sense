import 'dart:convert';

import 'package:flutter/material.dart';

import '../../ble/constants.dart';
import '../../ble/functions.dart';

class MasterStation extends StatefulWidget {
  const MasterStation({Key? key}) : super(key: key);

  @override
  State<MasterStation> createState() => _MasterStationState();
}

class _MasterStationState extends State<MasterStation> {
  @override
  Widget build(BuildContext context) => Scaffold(
      body: Column(
        children: [
          ElevatedButton(
              onPressed: ()async {
                final jsonData = await prepareDataForTransfer();
                final dataBytes = utf8.encode(jsonData);
              },
              child: const Text("get data"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: count,
              itemBuilder: (BuildContext context, int index) {
                // Check if the item is a padding item (empty string)
                if (count == 0) {
                  return const SizedBox(
                    child: Text("There is no data"),
                  );
                }
                else{
                  return const SizedBox(
                    child: Text("There is data"),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
}
