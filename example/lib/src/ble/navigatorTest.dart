import 'package:flutter/cupertino.dart';

class NavTest extends StatefulWidget {
  const NavTest({Key? key}) : super(key: key);

  @override
  State<NavTest> createState() => _NavTestState();
}

class _NavTestState extends State<NavTest> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.black,
    );
  }
}
