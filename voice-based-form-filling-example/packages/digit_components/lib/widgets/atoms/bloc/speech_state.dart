
abstract class VoiceState {}

class VoiceInitial extends VoiceState {}

class VoiceListening extends VoiceState {}

class VoiceStopped extends VoiceState {}

class VoiceTextUpdated extends VoiceState {
  final String text;
  VoiceTextUpdated(this.text);
}

