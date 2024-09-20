
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'dart:async';

// Define the events
abstract class DatePickerEvent {}

class StartListeningEvent extends DatePickerEvent {
  final String fieldName;
  StartListeningEvent(this.fieldName);
}

class StopListeningEvent extends DatePickerEvent {}

class UpdateDateEvent extends DatePickerEvent {
  final String recognizedWords;
  UpdateDateEvent(this.recognizedWords);
}

// DatePicker BLoC
class DatePickerBloc extends Bloc<DatePickerEvent, DatePickerState> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  bool _isInitialized = false;
  Timer? _silenceTimer;
  String _currentRecognizedWords = '';

  DatePickerBloc() : super(DatePickerInitial()) {
    on<StartListeningEvent>((event, emit) => _startListening(event.fieldName, emit));
    on<StopListeningEvent>((event, emit) => _stopListening(emit));
    on<UpdateDateEvent>((event, emit) => _updateDate(event.recognizedWords, emit));
  }

  void _startListening(String fieldName, Emitter<DatePickerState> emit) async {
    debugPrint('Starting listening for $fieldName...');

    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onError: (error) => _handleError(error.errorMsg, emit),
      );
    }

    if (_isInitialized && !_isListening) {
      await _flutterTts.speak("Please say the date for $fieldName");
      await _flutterTts.awaitSpeakCompletion(true);
      await Future.delayed(const Duration(milliseconds: 200));

      _isListening = true;
      emit(DatePickerListening());
      _speech.listen(
        onResult: (result) {
          _currentRecognizedWords = result.recognizedWords;
          _resetSilenceTimer(emit);
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 3),
        partialResults: false,
        onSoundLevelChange: (level) {
          // Reset the silence timer when sound is detected
          if (level > 0) {
            _resetSilenceTimer(emit);
          }
        },
      );
      debugPrint('Listening started for $fieldName.');
    } else if (!_isInitialized) {
      _handleError('Speech recognition not available.', emit);
    }
  }

  void _resetSilenceTimer(Emitter<DatePickerState> emit) {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(Duration(seconds: 2), () {
      if (_currentRecognizedWords.isNotEmpty) {
        add(UpdateDateEvent(_currentRecognizedWords));
      }
    });
  }

  void _stopListening(Emitter<DatePickerState> emit) async {
    debugPrint('Stopping listening...');
    if (_isListening) {
      _isListening = false;
      await _speech.stop();
      _silenceTimer?.cancel();
      emit(DatePickerNotListening());
      debugPrint('Listening stopped.');
    }
  }

  void _updateDate(String voiceInput, Emitter<DatePickerState> emit) async {
    debugPrint('Updating date with voice input: $voiceInput');
    DateTime? parsedDate = _parseDateFromText(voiceInput);
    if (parsedDate != null) {
      debugPrint('Date parsed successfully: $parsedDate');
      emit(DatePickerDateUpdated(parsedDate));
      
      String formattedDate = DateFormat('MMMM d, y').format(parsedDate);
      await _flutterTts.speak("You said: $formattedDate");
      await _flutterTts.awaitSpeakCompletion(true);
      
      add(StopListeningEvent());
    } else {
      _handleError('Failed to parse date.', emit);
    }
  }

  void _handleError(String errorMessage, Emitter<DatePickerState> emit) async {
    debugPrint('Error: $errorMessage');
    await _flutterTts.speak("Sorry, I couldn't recognize the date. Please try again.");
    await _flutterTts.awaitSpeakCompletion(true);
    emit(DatePickerError(errorMessage));
    add(StopListeningEvent());
  }

  DateTime? _parseDateFromText(String text) {
    try {
      final formattedText = text.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
      
      List<String> monthNames = [
        'january', 'february', 'march', 'april', 'may', 'june',
        'july', 'august', 'september', 'october', 'november', 'december'
      ];

      final yearRegExp = RegExp(r'\b(19|20)\d{2}\b');
      final yearMatch = yearRegExp.firstMatch(formattedText);
      int spokenYear = DateTime.now().year;
      
      if (yearMatch != null) {
        spokenYear = int.parse(yearMatch.group(0)!);
      }

      for (int i = 0; i < monthNames.length; i++) {
        if (formattedText.contains(monthNames[i])) {
          String spokenMonth = (i + 1).toString().padLeft(2, '0');

          final dayRegExp = RegExp(r'\b\d{1,2}\b');
          final dayMatch = dayRegExp.firstMatch(formattedText);
          
          if (dayMatch != null) {
            String spokenDay = dayMatch.group(0)!.padLeft(2, '0');

            String dateString = '$spokenMonth $spokenDay $spokenYear';
            return DateFormat('MM dd yyyy').parseLoose(dateString);
          }
        }
      }
    } catch (e) {
      debugPrint('Error in custom date parsing: $e');
    }

    return null;
  }
}

// BLoC states
abstract class DatePickerState {}

class DatePickerInitial extends DatePickerState {}

class DatePickerListening extends DatePickerState {}

class DatePickerNotListening extends DatePickerState {}

class DatePickerDateUpdated extends DatePickerState {
  final DateTime date;
  DatePickerDateUpdated(this.date);
}

class DatePickerError extends DatePickerState {
  final String message;
  DatePickerError(this.message);
}