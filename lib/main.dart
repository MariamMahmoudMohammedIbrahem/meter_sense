import 'commons.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MeterSense());
}

class MeterSense extends StatelessWidget {
  const MeterSense({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MeterSense',
      theme: lightTheme,
      home: const LoadingScreen(),
    );
  }
}