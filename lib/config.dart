import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigDialog extends StatefulWidget {
  const ConfigDialog({super.key, required this.gamePath});
  final gamePath;
  @override
  _ConfigDialogState createState() => _ConfigDialogState(gamePath: gamePath);
}

class _ConfigDialogState extends State<ConfigDialog> {
  _ConfigDialogState({required this.gamePath});
  late TextEditingController _controller;
  String gamePath;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.text = widget.gamePath;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
            height: 200,
            width: 600,
            child: Column(
              children: [
                const Text(
                  "Config",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text("Game path"),
                // text input field
                SizedBox(
                  height: 50,
                  child: TextField(
                    controller: _controller,
                    onChanged: (value) => gamePath = value,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Game path',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('gamePath', gamePath);
                      debugPrint("Saved config: $gamePath");
                    },
                    child: const Material(
                      color: Color.fromARGB(255, 104, 168, 237),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("Save config"),
                      ),
                    ))
              ],
            )),
      ),
    );
  }
}
