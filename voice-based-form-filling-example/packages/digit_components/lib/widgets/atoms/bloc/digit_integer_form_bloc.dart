
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_error.dart';

/*
 * BLoC States:
 */
abstract class SpeechState {}

class SpeechListeningState extends SpeechState {}

class SpeechNotListeningState extends SpeechState {}

class SpeechUpdatedState extends SpeechState {
  final String text;
  SpeechUpdatedState(this.text);
}

/*
 * BLoC Events:
 */
abstract class SpeechEvent {}

class StartListeningEvent extends SpeechEvent {
  final String fieldName;
  StartListeningEvent(this.fieldName);
}

class StopListeningEvent extends SpeechEvent {}

class SpeechResultEvent extends SpeechEvent {
  final String text;
  SpeechResultEvent(this.text);
}

/*
 * BLoC Implementation:
 * 
 * DigitIntegerFormBloc handles speech-to-text and text-to-speech functionalities.
 */
class DigitIntegerFormBloc extends Bloc<SpeechEvent, SpeechState> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isListening = false;

  DigitIntegerFormBloc() : super(SpeechNotListeningState()) {
    _initializeSpeech();

    // Event handler for StartListeningEvent
    on<StartListeningEvent>((event, emit) async {
      debugPrint("Received StartListeningEvent");

      // Provide voice prompt to the user before starting speech recognition
      await _flutterTts.speak("Please say input for ${event.fieldName} field");
      await _flutterTts.awaitSpeakCompletion(true);
      await Future.delayed(const Duration(milliseconds: 200));

      // Initialize speech recognition if not already initialized
      if (!_isInitialized) {
        _isInitialized = await _speech.initialize(onError: errorListener);
        debugPrint("Speech Recognition initialized: $_isInitialized");
      }

      // Start listening if initialized and not already listening
      if (_isInitialized && !_isListening) {
        _isListening = true;
        emit(SpeechListeningState());
        debugPrint("Emitted SpeechListeningState");

        _speech.listen(onResult: (result) {
          debugPrint("Speech recognized: ${result.recognizedWords}");
          add(SpeechResultEvent(result.recognizedWords));
        });
      }
    });

    // Event handler for StopListeningEvent
    on<StopListeningEvent>((event, emit) async {
      debugPrint("Received StopListeningEvent");
      if (_isListening) {
        await _speech.stop();
        _isListening = false;
        emit(SpeechNotListeningState());
        debugPrint("Emitted SpeechNotListeningState");
      }
    });

    // Event handler for SpeechResultEvent
    on<SpeechResultEvent>((event, emit) async {
      debugPrint("Received SpeechResultEvent with text: ${event.text}");
      emit(SpeechUpdatedState(event.text));
      await Future.delayed(const Duration(milliseconds: 500));
      // Provide voice feedback with the recognized text
      await _flutterTts.speak("You said: ${event.text}");
      await _flutterTts.awaitSpeakCompletion(true);

      await Future.delayed(const Duration(milliseconds: 1000));
      // Automatically stop listening after result
      add(StopListeningEvent());
    });
  }

  // Initialize the speech recognition service
  void _initializeSpeech() async {
    _isInitialized = await _speech.initialize(onError: errorListener);
    debugPrint("Speech recognition initialized: $_isInitialized");
  }

  // Error listener for speech recognition errors
  Future<void> errorListener(SpeechRecognitionError error) async {
    await _flutterTts.speak("Sorry, I couldn't recognize the speech");
    await _flutterTts.awaitSpeakCompletion(true);
    add(StopListeningEvent());
  }

  // Reset the listening flag if necessary
  void resetListeningState() {
    if (!_speech.isListening && _isListening) {
      _isListening = false;
      debugPrint('Reset _isListening flag to false');
    }
  }

  // Public methods to manually start and stop listening
  void startListening(String fieldName) {
    debugPrint("Starting listening...");
    add(StartListeningEvent(fieldName));
  }

  void stopListening() {
    debugPrint("Stopping listening...");
    add(StopListeningEvent());
  }
}





// old code phase 1 
// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:flutter_bloc/flutter_bloc.dart';

// /*

//  * BLoC States:
//  * 
//  * Abstract class `SpeechState` represents the different states that the `SpeechBloc` can be in.
 
//  */
// abstract class SpeechState {}

// /*
//  * State indicating that the BLoC is currently listening for voice input.
//  */
// class SpeechListeningState extends SpeechState {}

// /*
//  * State indicating that the BLoC is not listening for voice input.
//  */
// class SpeechNotListeningState extends SpeechState {}

// /*
//  * State representing the updated speech text recognized from the voice input.
//  */
// class SpeechUpdatedState extends SpeechState {
//   final String text;

//   SpeechUpdatedState(this.text);
// }

// /*
//  * BLoC Events:
//  * 
//  * Abstract class `SpeechEvent` represents all possible events for the `SpeechBloc`.
//  * Specific event classes extend this abstract class to define various actions that can be triggered.
//  */
// abstract class SpeechEvent {}

// /*
//  * Event to start listening to voice input.
//  */
// class StartListeningEvent extends SpeechEvent {}

// /*
//  * Event to stop listening to voice input.
//  */
// class StopListeningEvent extends SpeechEvent {}

// /*
//  * Event that carries the recognized text from the speech recognition process.
//  */
// class SpeechResultEvent extends SpeechEvent {
//   final String text;

//   SpeechResultEvent(this.text);
// }

// /*
//  * BLoC Implementation:
//  * 
//  * `DigitIntegerFormBloc` handles the business logic related to speech recognition using the `speech_to_text` package.
//  * It manages state transitions based on events and interacts with the speech-to-text service.
//  */
// class DigitIntegerFormBloc extends Bloc<SpeechEvent, SpeechState> {
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   bool _isInitialized = false; // Track initialization status
//   bool _isListening = false;   // Use this flag to check listening status

//   /// Constructor initializes the BLoC with the initial state.
//   DigitIntegerFormBloc() : super(SpeechNotListeningState()) {
//     // Event handler for StartListeningEvent
//     on<StartListeningEvent>((event, emit) async {
//       debugPrint("Received StartListeningEvent");

//       // Initialize the speech-to-text service if not already initialized
//       if (!_isInitialized) {
//         bool available = await _speech.initialize();
//         _isInitialized = available;
//         debugPrint("Speech Recognition initialized: $available");
//       }

//       // Start listening if the service is initialized and not already listening
//       if (_isInitialized && !_isListening) {
//         _isListening = true; // Update the listening flag
//         emit(SpeechListeningState()); // Emit SpeechListeningState to indicate listening has started
//         debugPrint("Emitted SpeechListeningState");

//         _speech.listen(onResult: (result) {
//           debugPrint("Speech recognized: ${result.recognizedWords}");
//           add(SpeechResultEvent(result.recognizedWords)); // Add result to events
//         });
//       }
//     });

//     // Event handler for StopListeningEvent
//     on<StopListeningEvent>((event, emit) {
//       debugPrint("Received StopListeningEvent");
//       if (_isListening) {
//         _speech.stop(); // Stop the speech recognition service
//         _isListening = false; // Reset the listening flag
//         emit(SpeechNotListeningState()); // Emit SpeechNotListeningState to indicate listening has stopped
//         debugPrint("Emitted SpeechNotListeningState");
//       }
//     });

//     // Event handler for SpeechResultEvent
//     on<SpeechResultEvent>((event, emit) {
//       debugPrint("Received SpeechResultEvent with text: ${event.text}");
//       emit(SpeechUpdatedState(event.text)); // Emit SpeechUpdatedState with recognized text
//       add(StopListeningEvent()); // Automatically stop listening after result
//     });
//   }

//   /*
//    * Public method to reset the listening state.
//    */
//   void reset() {
//     _isListening = false; // Reset the listening flag
//     debugPrint("Reset _isListening flag to false");
//   }

//   /*
//    * Public method to stop listening.
//    */
//   void stopListening() {
//     debugPrint("Stopping listening...");
//     add(StopListeningEvent()); // Dispatch StopListeningEvent to stop listening
//   }

//   /*
//    * Public method to start listening.
//    */
//   void startListening() {
//     debugPrint("Starting listening...");
//     add(StartListeningEvent()); // Dispatch StartListeningEvent to start listening
//   }
// }
