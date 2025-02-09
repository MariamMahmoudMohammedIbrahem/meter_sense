part of 'device_history_screen.dart';

abstract class DeviceHistoryController extends State<DeviceHistoryScreen> {
  Future<List<Map>> readMeterHistory() async {
    final response = await read(widget.name, widget.name.startsWith("Ele")?"Electricity":"Water");
    return response;
  }
}
