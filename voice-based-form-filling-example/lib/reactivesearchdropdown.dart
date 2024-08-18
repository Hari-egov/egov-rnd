import 'package:digit_components/widgets/atoms/bloc/reactivesearchdropdownbloc.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:digit_components/digit_components.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FormGroup form = FormGroup({
    'dropdown': FormControl<String>(validators: [Validators.required]),
  });

  String valueMapper(dynamic value) => value.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digit Reactive Dropdown Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ReactiveForm(
          formGroup: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BlocProvider(
                create: (context) => DigitReactiveSearchDropdownBloc(),
                child: DigitReactiveSearchDropdown(
                  label: 'Fruits',
                  form: form,
                  enableVoiceCommand: true,
                  menuItems: const [
                    'Apple',
                    'Banana',
                    'Cherry',
                    'Date',
                    'Elderberry',
                    'Fig',
                    'Grape',
                    'Honeydew',
                  ],
                  formControlName: 'dropdown',
                  valueMapper: valueMapper,
                  validationMessage: 'Please select a fruit',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (form.valid) {
                    final selectedFruit = form.control('dropdown').value;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected fruit: $selectedFruit')),
                    );
                  } else {
                    form.markAllAsTouched();
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
