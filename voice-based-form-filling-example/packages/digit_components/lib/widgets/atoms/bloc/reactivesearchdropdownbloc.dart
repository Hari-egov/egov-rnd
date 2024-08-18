


import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// BLoC Events
abstract class DigitReactiveSearchDropdownEvent {}

class StartListening extends DigitReactiveSearchDropdownEvent {}

class StopListening extends DigitReactiveSearchDropdownEvent {}

class SpeechResult extends DigitReactiveSearchDropdownEvent {
  final String recognizedWords;

  SpeechResult(this.recognizedWords);
}

// BLoC States
abstract class DigitReactiveSearchDropdownState {}

class DigitReactiveSearchDropdownInitial extends DigitReactiveSearchDropdownState {}

class ListeningState extends DigitReactiveSearchDropdownState {}

class NotListeningState extends DigitReactiveSearchDropdownState {}

class SpeechRecognitionSuccess extends DigitReactiveSearchDropdownState {
  final String recognizedWords;

  SpeechRecognitionSuccess(this.recognizedWords);
}

class NoMatchFound extends DigitReactiveSearchDropdownState {}

// BLoC Implementation
class DigitReactiveSearchDropdownBloc
    extends Bloc<DigitReactiveSearchDropdownEvent, DigitReactiveSearchDropdownState> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  DigitReactiveSearchDropdownBloc() : super(DigitReactiveSearchDropdownInitial()) {
    on<StartListening>((event, emit) async {
      print('Event: StartListening');
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        _isListening = true;
        emit(ListeningState());
        _speech.listen(
          onResult: (val) => add(SpeechResult(val.recognizedWords)),
        );
        print('Listening started');
      } else {
        print('Speech recognition not available');
      }
    });

    on<StopListening>((event, emit) {
      print('Event: StopListening');
      _isListening = false;
      _speech.stop();
      emit(NotListeningState());
      print('Listening stopped');
    });

    on<SpeechResult>((event, emit) {
      print('Event: SpeechResult with recognized words: ${event.recognizedWords}');
      emit(SpeechRecognitionSuccess(event.recognizedWords));
    });
  }
}
