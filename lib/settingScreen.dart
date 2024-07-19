import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  int pomodoroCurrent;
  int shortCurrent;
  int longCurrent;
  int cyclesUntilLongBreak;
  final Function(int, int, int, int) onSettingsChanged;


  SettingScreen(this.pomodoroCurrent, this.shortCurrent, this.longCurrent,this.cyclesUntilLongBreak,
      {super.key, required this.onSettingsChanged});


  @override
  State<StatefulWidget> createState() => _SettingScreenState();

}


class _SettingScreenState extends State<SettingScreen>{
  late TextEditingController _pomodoro;
  late TextEditingController _short;
  late TextEditingController _long;
  late TextEditingController _cycles;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _pomodoro = TextEditingController(text: '${widget.pomodoroCurrent}');
    _short = TextEditingController(text: '${widget.shortCurrent}');
    _long = TextEditingController(text: '${widget.longCurrent}');
    _cycles = TextEditingController(text:'${widget.cyclesUntilLongBreak}');
  }

  @override
  void dispose() {
    _pomodoro.dispose();
    _short.dispose();
    _long.dispose();
    _cycles.dispose();
    super.dispose();
  }

  void _increment(TextEditingController controller) {
    setState(() {
      int counter = int.tryParse(controller.text) ?? 0;
      counter++;
      controller.text = counter.toString();
    });
  }

  void _decrement(TextEditingController controller) {
    setState(() {
      int counter = int.tryParse(controller.text) ?? 0;
      if (counter > 1) {
        counter--;
        controller.text = counter.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting Time'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 50.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildRowWithButtons(
                  label: 'Pomodoro Time',
                  controller: _pomodoro,
                  increment: () => _increment(_pomodoro),
                  decrement: () => _decrement(_pomodoro),
                ),
                const SizedBox(height: 10,),
                _buildRowWithButtons(
                  label: 'Short Break',
                  controller: _short,
                  increment: ()=> _increment(_short),
                  decrement: ()=> _decrement(_short),
                ),
                const SizedBox(height: 10,),
                _buildRowWithButtons(
                  label: 'Long Break',
                  controller: _long,
                  increment: ()=> _increment(_long),
                  decrement: ()=> _decrement(_long),
                ),
                const SizedBox(height: 10,),
                _buildRowWithButtons(
                  label: 'Cycles For Long Break',
                  controller: _cycles,
                  increment: ()=> _increment(_cycles),
                  decrement: ()=> _decrement(_cycles),
                ),
                const SizedBox(height: 30,),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        int pomodoroTime = int.parse(_pomodoro.text);
                        int shortTime = int.parse(_short.text);
                        int longTime = int.parse(_long.text);
                        int cycles = int.parse(_cycles.text);
                        widget.onSettingsChanged(pomodoroTime, shortTime, longTime, cycles);
                        Navigator.pop(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade500,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                      child: const Center(
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Text color
                          ),
                        ),
                      ),
                    ),
                  ),

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildRowWithButtons({
    required String label,
    required TextEditingController controller,
    required VoidCallback increment,
    required VoidCallback decrement,
  }) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:Colors.blueAccent
            ),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          ),
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            } else if (int.tryParse(value) == null) {
              return 'Please enter valid number';
            } else {
              return null;
            }
          },
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: IconButton(
                onPressed: increment,
                icon: const Icon(Icons.add),
                iconSize: 20,

              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: IconButton(
                onPressed: decrement,
                icon: const Icon(Icons.remove),
                iconSize: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

