
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';



//  * BLoC Events:
//  * 
//  * Abstract class `DigitReactiveSearchDropdownEvent` represents all possible events
//  * for the DigitReactiveSearchDropdown BLoC. Specific event classes extend this abstract
//  * class to define various actions that can be triggered.
 

// Events
abstract class DigitReactiveSearchDropdownEvent {}

/// Event to start listening to voice input
class StartListening extends DigitReactiveSearchDropdownEvent {
  final String fieldName;
  StartListening(this.fieldName);
}

/// Event to stop listening to voice input
class StopListening extends DigitReactiveSearchDropdownEvent {}

/// Event that carries the recognized text from the speech recognition process
class SpeechResult extends DigitReactiveSearchDropdownEvent {
  final String recognizedWords;
  SpeechResult(this.recognizedWords);
}

/// Event to reset the listening state
class ResetListening extends DigitReactiveSearchDropdownEvent {}

// States
abstract class DigitReactiveSearchDropdownState {}

/// Initial state when the BLoC is created
class DigitReactiveSearchDropdownInitial extends DigitReactiveSearchDropdownState {}

/// State indicating that the BLoC is currently listening for voice input
class ListeningState extends DigitReactiveSearchDropdownState {}

/// State indicating that the BLoC is not listening for voice input
class NotListeningState extends DigitReactiveSearchDropdownState {}

/// State representing successful speech recognition with recognized words
class SpeechRecognitionSuccess extends DigitReactiveSearchDropdownState {
  final String recognizedWords;
  SpeechRecognitionSuccess(this.recognizedWords);
}

/// State indicating that no match was found for the recognized words
class NoMatchFound extends DigitReactiveSearchDropdownState {}

/// BLoC for handling speech recognition and text-to-speech in a reactive search dropdown
class DigitReactiveSearchDropdownBloc
    extends Bloc<DigitReactiveSearchDropdownEvent, DigitReactiveSearchDropdownState> {
  // Speech recognition instance
  final stt.SpeechToText _speech = stt.SpeechToText();
  // Text-to-speech instance
  final FlutterTts _flutterTts = FlutterTts();
  // Flag to track if we're currently listening
  bool _isListening = false;
  // Flag to track if speech recognition has been initialized
  bool _isInitialized = false;

  DigitReactiveSearchDropdownBloc() : super(DigitReactiveSearchDropdownInitial()) {
    // Handler for StartListening event
    on<StartListening>((event, emit) async {
      debugPrint('Event: StartListening');

      // Initialize speech recognition if not already done
      if (!_isInitialized) {
        bool available = await _initializeSpeech();
        if (!available) {
          debugPrint('Speech recognition not available');
          return;
        }
      }

      // Provide voice prompt to the user before starting speech recognition
      await _flutterTts.speak("Please say input for ${event.fieldName} field");
      await _flutterTts.awaitSpeakCompletion(true);
      await Future.delayed(const Duration(milliseconds: 200));

      // Start listening if not already listening
      if (!_isListening) {
        _isListening = true;
        emit(ListeningState());
        _speech.listen(
          onResult: (val) => add(SpeechResult(val.recognizedWords)),
        );
        debugPrint('Listening started');
      } else {
        debugPrint('Already listening');
      }
    });

    // Handler for StopListening event
    on<StopListening>((event, emit) async {
      debugPrint('Event: StopListening');
      _isListening = false;
      await _speech.stop();
      emit(NotListeningState());
      debugPrint('Listening stopped');
    });

    // Handler for SpeechResult event
    on<SpeechResult>((event, emit) async {
      debugPrint('Event: SpeechResult with recognized words: ${event.recognizedWords}');
      emit(SpeechRecognitionSuccess(event.recognizedWords));

      // Provide voice feedback with the recognized text
      await _flutterTts.speak("You said: ${event.recognizedWords}");
      await _flutterTts.awaitSpeakCompletion(true);

      // Wait a moment before stopping listening
      await Future.delayed(const Duration(milliseconds: 1000));
      add(StopListening());
    });

    // Handler for ResetListening event
    on<ResetListening>((event, emit) {
      debugPrint('Event: ResetListening');
      _isListening = false;
      emit(NotListeningState());
    });
  }

  /// Initialize the speech recognition service
  Future<bool> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (val) => debugPrint('onStatus: $val'),
      onError: (val) => debugPrint('onError: $val'),
    );
    _isInitialized = available;
    debugPrint('Speech recognition initialized: $available');
    return available;
  }

  /// Public method to reset the listening state
  void resetListening() {
    add(ResetListening());
  }

  /// Handle speech recognition errors
  Future<void> errorListener(dynamic error) async {
    await _flutterTts.speak("Sorry, I couldn't recognize the speech");
    await _flutterTts.awaitSpeakCompletion(true);
    add(StopListening());
  }
}