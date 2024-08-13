
// import 'package:digit_components/widgets/atoms/bloc/speech_event.dart';
// import 'package:digit_components/widgets/atoms/bloc/speech_state.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;


// class VoiceBloc extends Bloc<VoiceEvent, VoiceState> {
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   bool _isListening = false;

//   VoiceBloc() : super(VoiceInitial()) {
//     on<StartListening>((event, emit) async {
//       print('StartListening event received');
//       if (!_isListening) {
//         bool available = await _speech.initialize();
//         print('Speech recognition available: $available');
//         if (available) {
//           _speech.listen(onResult: (result) {
//             print('Recognized words: ${result.recognizedWords}');
//             add(UpdateText(result.recognizedWords));
//           });
//           _isListening = true;
//           emit(VoiceListening());
//           print('VoiceListening state emitted');
//         } else {
//           emit(VoiceStopped());
//           print('VoiceStopped state emitted (not available)');
//         }
//       }
//     });

//     on<StopListening>((event, emit) async {
//       print('StopListening event received');
//       if (_isListening) {
//         _speech.stop();
//         _isListening = false;
//         emit(VoiceStopped());
//         print('VoiceStopped state emitted');
//       }
//     });

//     on<UpdateText>((event, emit) {
//       print('UpdateText event received with text: ${event.text}');
//       emit(VoiceTextUpdated(event.text));
//     });
//   }
// }



// import 'package:digit_components/widgets/atoms/bloc/speech_event.dart';
// import 'package:digit_components/widgets/atoms/bloc/speech_state.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;


// class VoiceBloc extends Bloc<VoiceEvent, VoiceState> {
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   bool _isListening = false;

//   VoiceBloc() : super(VoiceInitial()) {
//     on<StartListening>((event, emit) async {
//       print('StartListening event received');
//       if (!_isListening) {
//         bool available = await _speech.initialize();
//         print('Speech recognition available: $available');
//         if (available) {
//           _speech.listen(onResult: (result) {
//             print('Recognized words: ${result.recognizedWords}');
//             add(UpdateText(result.recognizedWords));
//           });
//           _isListening = true;
//           emit(VoiceListening());
//           print('VoiceListening state emitted');
//         } else {
//           emit(VoiceStopped());
//           print('VoiceStopped state emitted (not available)');
//         }
//       }
//     });

//     on<StopListening>((event, emit) async {
//       print('StopListening event received');
//       if (_isListening) {
//         _speech.stop();
//         _isListening = false;
//         emit(VoiceStopped());
//         print('VoiceStopped state emitted');
//       }
//     });

//     on<UpdateText>((event, emit) {
//       print('UpdateText event received with text: ${event.text}');
//       emit(VoiceTextUpdated(event.text));
//     });
//   }
// }


import 'package:digit_components/widgets/atoms/bloc/speech_event.dart';
import 'package:digit_components/widgets/atoms/bloc/speech_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceBloc extends Bloc<VoiceEvent, VoiceState> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  VoiceBloc() : super(VoiceInitial()) {
    on<StartListening>((event, emit) async {
      print('StartListening event received');
      if (!_isListening) {
        bool available = await _speech.initialize();
        print('Speech recognition available: $available');
        if (available) {
          _speech.listen(onResult: (result) {
            print('Recognized words: ${result.recognizedWords}');
            add(UpdateText(result.recognizedWords));
          });
          _isListening = true;
          emit(VoiceListening());
          print('VoiceListening state emitted');
        } else {
          emit(VoiceStopped());
          print('VoiceStopped state emitted (not available)');
        }
      }
    });

    on<StopListening>((event, emit) async {
      print('StopListening event received');
      if (_isListening) {
        _speech.stop();
        _isListening = false;
        emit(VoiceStopped());
        print('VoiceStopped state emitted');
      }
    });

    on<UpdateText>((event, emit) {
      print('UpdateText event received with text: ${event.text}');
      emit(VoiceTextUpdated(event.text));
      _isListening = false;
    //  emit(VoiceStopped());
    });
  }
}


