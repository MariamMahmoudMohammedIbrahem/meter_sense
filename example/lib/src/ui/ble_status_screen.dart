import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleStatusScreen extends StatelessWidget {
  const BleStatusScreen({required this.status, super.key});

  final BleStatus status;

  String determineText(BleStatus status) {
    switch (status) {
      case BleStatus.unsupported:
        return "This device does not support Bluetooth";
      case BleStatus.unauthorized:
        return "Authorize the FlutterReactiveBle example app to use Bluetooth and location";
      case BleStatus.poweredOff:
        return "Bluetooth is powered off on your device turn it on";
      case BleStatus.locationServicesDisabled:
        return "Enable location services";
      case BleStatus.ready:
        return "Bluetooth is up and running";
      default:
        return "Waiting to fetch Bluetooth status $status";
    }
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedImage(status: status,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width*.1),
                child: Text(determineText(status),style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              ),
            ],
          ),
        ),
      );}
}
class AnimatedImage extends StatefulWidget {
  const AnimatedImage({required this.status,super.key});
  final BleStatus status;

  @override
  State<AnimatedImage> createState() => _AnimatedImageState();
}

class _AnimatedImageState extends State<AnimatedImage> with SingleTickerProviderStateMixin{
  late final AnimationController _controller = AnimationController(vsync: this,duration: const Duration(seconds: 3))..repeat(reverse: true);
  late final Animation<Offset> _animation = Tween(
    begin: Offset.zero,
    end: const Offset(0,0.08),
  ).animate(_controller);
  SizedBox determineImage(BleStatus status, double width) {
    switch (status) {
      case BleStatus.unsupported:
        return SizedBox(
          width: .8*width,
          child: SlideTransition(position:_animation,child: Image.asset('images/off.jpg')),
        );
      case BleStatus.unauthorized:
        return SizedBox(
          width: .8*width,
          child: SlideTransition(position:_animation,child: Image.asset('images/authorize.jpg')),
        );
      case BleStatus.poweredOff:
        return SizedBox(
          width: .8*width,
          child: SlideTransition(position:_animation,child: Image.asset('images/off.jpg')),
        );
      case BleStatus.locationServicesDisabled:
        return SizedBox(
          width: .8*width,
          child: SlideTransition(position: _animation,child: Image.asset('images/location.jpg'),),
        );
      case BleStatus.ready:
        return SizedBox(
          width: .8*width,
          child: SlideTransition(position:_animation,child: Image.asset('images/off.jpg')),
        );
      default:
        return SizedBox(
          width: .8*width,
          child: SlideTransition(position:_animation,child: Image.asset('images/off.jpg')),
        );
    }
  }
  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return determineImage(widget.status, width);
  }
}
