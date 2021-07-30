import 'package:flutter/material.dart';

class MyErrorWidget extends StatelessWidget {
  final IconData icon;
  final String? title;
  final String subtitle;

  const MyErrorWidget({
    Key? key,
    required this.icon,
    this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 128,
                color: Colors.grey,
              ),
              if (title != null)
                Text(
                  title!,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 28,
                  ),
                ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 22,
                ),
              )
            ],
          ),
        ),
      );
}
