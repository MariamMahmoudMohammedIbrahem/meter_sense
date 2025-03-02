import 'package:flutter_reactive_ble_example/data/sqldb.dart';

import '../../commons.dart';

part 'device_scanner_controller.dart';

class DeviceScannerScreen extends StatefulWidget {
  const DeviceScannerScreen({
    required this.scannerState,
    required this.startScan,
    required this.stopScan,
    required this.deviceConnector,
    super.key,
  });

  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;
  final BleDeviceConnector deviceConnector;

  @override
  _DeviceScannerScreen createState() => _DeviceScannerScreen();
}

class _DeviceScannerScreen extends DeviceScannerController {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final width = size.width;
    final height = size.height - padding.top - padding.bottom;
    return SafeArea(
      // resizeToAvoidBottomInset: false,
      child: Scaffold(
        body: Column(
          children: [
            // ElevatedButton(onPressed: (){getSpecifiedList("EleMeter0486", "balance");}, child: const Text("get specified list",),),
            Row(
              children: [
                IconButton(
                  onPressed: toggleLanguage,
                  icon: const Icon(
                    Icons.language_outlined,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                AutoSizeText(
                  toggle
                      ? TKeys.english.translate(context)
                      : TKeys.arabic.translate(context),
                  style: Theme.of(context).textTheme.bodyMedium,
                  minFontSize: 18,
                  maxFontSize: 20,
                )
              ],
            ),
            SizedBox(
              width: width * .6,
              height: height * .4,
              child: Image.asset("assets/images/authorize.jpg"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    barcodeScanRes = '';
                    barcodeScanning(context);
                  },
                  child: AutoSizeText(
                    TKeys.qr.translate(context),
                    minFontSize: 18,
                    maxFontSize: 20,
                  ),
                ),
                ElevatedButton(
                  onPressed: _startScanning,
                  child: AutoSizeText(
                    !widget.scannerState.scanIsInProgress
                        ? TKeys.scan.translate(context)
                        : TKeys.scanning.translate(context),
                    minFontSize: 18,
                    maxFontSize: 20,
                  ),
                ),
              ],
            ),
            Text(
              TKeys.device.translate(context),
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: width * .07,
                right: width * .07,
              ),
              child: dividerGrey,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ...widget.scannerState.discoveredDevices
                          .where((device) =>
                              (device.name == barcodeScanRes ||
                                  nameList.contains(device.name) ||
                                  device.name == "MasterStation") &&
                              (device.name.isNotEmpty))
                          .map((device) {
                        icon = getDeviceIcon(device.name);
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: width * .1),
                          child: Column(
                            children: [
                              ListTile(
                                onTap: () => handleDeviceTap(device),
                                onLongPress: (){_showOptions(context, device.name);},
                                leading: SizedBox(
                                    width: 30, child: Image.asset(icon)),
                                title: AutoSizeText(
                                  device.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  minFontSize: 20,
                                ),
                              ),
                              dividerGrey,
                            ],
                          ),
                        );
                      }),
                      ...nameList
                          .where((name) => !widget
                              .scannerState.discoveredDevices
                              .any((device) => device.name == name))
                          .map((name) {
                        icon = getDeviceIcon(name);
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * .1,
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: SizedBox(
                                  width: 25,
                                  child: Image.asset(icon),
                                ),
                                title: AutoSizeText(
                                  name,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                trailing: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                                onTap: () {
                                  handleHistoryTap(name);
                                },
                                onLongPress: (){_showOptions(context, name);},
                              ),
                              dividerGrey,
                            ],
                          ),
                        );
                      }),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
