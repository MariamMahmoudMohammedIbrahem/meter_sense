import 'package:flutter/material.dart';

import '../t_key.dart';

class BluetoothIcon extends StatelessWidget {
  const BluetoothIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 32,
        height: 32,
        child: Align(alignment: Alignment.center, child: Icon(Icons.bluetooth)),
      );
}

class StatusMessage extends StatelessWidget {
  const StatusMessage({
    required this.text,
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );
}

class MeterButton extends StatelessWidget {
  final String name;
  final String tarrif;
  final num current;
  final num total;
  final num totalCredit;
  final Color color;
  final Function onPressed;
  final bool isEnabled;
  final Color color2;
  final Function onPressed2;

  const MeterButton({required this.name, required this.tarrif, required this.current, required this.total, required this.totalCredit, required this.color, required this.onPressed, required this.isEnabled, required this.color2, required this.onPressed2, super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * .07,
          vertical: 10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: color),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
        ),
        onPressed: (){onPressed;},
        child: Column(
          children: [
            Text(
              '${TKeys.name.translate(context)}: $name',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width:width*.07),
                Text(
                  '${TKeys.currentTarrif.translate(context)}: ',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  tarrif.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 1,
                ),
                Column(
                  children: [
                    Text(
                      TKeys.today.translate(context),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 25,
                          child: Image.asset(
                              'icons/electricityToday.png'),
                        ),
                        Text(
                          current.toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 30),
                Column(
                  children: [
                    Text(
                      TKeys.month.translate(context),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 25,
                          child: Image.asset(
                              'icons/electricityMonth.png'),
                        ),
                        Text(
                          total.toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  width: 1,
                ),

              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 1,
                ),
                Row(
                  children: [
                    Text(
                      '${TKeys.balance.translate(context)}: ',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      totalCredit.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: color2,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: color2,
                  ),
                  onPressed: isEnabled?() async {
                    onPressed2();
                  }: null,
                  child: Text(
                    TKeys.recharge.translate(context),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}