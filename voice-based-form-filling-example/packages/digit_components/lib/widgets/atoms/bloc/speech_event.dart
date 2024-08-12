
abstract class VoiceEvent {}

class StartListening extends VoiceEvent {}

class StopListening extends VoiceEvent {}

class UpdateText extends VoiceEvent {
  final String text;
  UpdateText(this.text);
}

