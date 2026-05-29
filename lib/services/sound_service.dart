import 'sound_stub.dart'
    if (dart.library.html) 'sound_web.dart';

/// SoundService — generates synthesized audio tones using Web Audio API.
/// No external audio files needed: all sounds are generated programmatically.
/// Gracefully no-ops on non-web platforms.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  bool _enabled = true;
  bool get enabled => _enabled;
  void setEnabled(bool v) => _enabled = v;

  void _tone(double freq, String type, double dur, double gain, double fade) {
    if (!_enabled) return;
    final total = dur + fade;
    webEval('''
(function(){
  try{
    var c=new(window.AudioContext||window.webkitAudioContext)();
    var o=c.createOscillator();
    var g=c.createGain();
    o.connect(g);g.connect(c.destination);
    o.type="$type";
    o.frequency.setValueAtTime($freq,c.currentTime);
    g.gain.setValueAtTime($gain,c.currentTime);
    g.gain.exponentialRampToValueAtTime(0.001,c.currentTime+$total);
    o.start(c.currentTime);
    o.stop(c.currentTime+$total);
    o.onended=function(){c.close();};
  }catch(e){}
})();''');
  }

  void _chord(List<double> freqs,
      {String type = 'sine',
      double duration = 0.2,
      double gain = 0.12,
      double fadeOut = 0.12}) {
    for (final f in freqs) {
      _tone(f, type, duration, gain, fadeOut);
    }
  }

  // ── Sound Effects ──────────────────────────────────────────────────────────

  void playTap() => _tone(880, 'sine', 0.06, 0.12, 0.06);

  void playToggle() => _tone(660, 'square', 0.05, 0.08, 0.05);

  void playNavigate() => _tone(523, 'sine', 0.08, 0.10, 0.06);

  void playStart() {
    _tone(440, 'sine', 0.08, 0.14, 0.06);
    Future.delayed(const Duration(milliseconds: 100), () =>
        _tone(660, 'sine', 0.08, 0.14, 0.06));
    Future.delayed(const Duration(milliseconds: 200), () =>
        _tone(880, 'sine', 0.12, 0.16, 0.08));
  }

  void playPause() {
    _tone(440, 'sine', 0.10, 0.12, 0.07);
    Future.delayed(const Duration(milliseconds: 120), () =>
        _tone(330, 'sine', 0.12, 0.10, 0.08));
  }

  void playResume() {
    _tone(330, 'sine', 0.08, 0.12, 0.06);
    Future.delayed(const Duration(milliseconds: 100), () =>
        _tone(440, 'sine', 0.10, 0.14, 0.07));
  }

  void playFinish() {
    _chord([523.25, 659.25, 783.99],
        type: 'sine', duration: 0.25, gain: 0.13, fadeOut: 0.18);
    Future.delayed(const Duration(milliseconds: 300), () =>
        _chord([1046.5, 1318.5],
            type: 'sine', duration: 0.20, gain: 0.10, fadeOut: 0.15));
  }

  void playSave() {
    _tone(587, 'sine', 0.08, 0.13, 0.07);
    Future.delayed(const Duration(milliseconds: 100), () =>
        _tone(784, 'sine', 0.10, 0.14, 0.08));
  }

  void playDelete() {
    _tone(330, 'sawtooth', 0.08, 0.10, 0.06);
    Future.delayed(const Duration(milliseconds: 80), () =>
        _tone(220, 'sawtooth', 0.10, 0.09, 0.07));
  }

  void playError() {
    _tone(220, 'square', 0.12, 0.10, 0.08);
    Future.delayed(const Duration(milliseconds: 140), () =>
        _tone(185, 'square', 0.14, 0.09, 0.08));
  }

  void playLoginSuccess() {
    _tone(523, 'sine', 0.10, 0.14, 0.07);
    Future.delayed(const Duration(milliseconds: 130), () =>
        _tone(659, 'sine', 0.10, 0.14, 0.07));
    Future.delayed(const Duration(milliseconds: 260), () =>
        _tone(784, 'sine', 0.10, 0.14, 0.07));
    Future.delayed(const Duration(milliseconds: 390), () =>
        _chord([523, 659, 784],
            type: 'sine', duration: 0.22, gain: 0.11, fadeOut: 0.16));
  }

  void playLogout() {
    _tone(440, 'sine', 0.08, 0.10, 0.06);
    Future.delayed(const Duration(milliseconds: 100), () =>
        _tone(330, 'sine', 0.10, 0.09, 0.07));
    Future.delayed(const Duration(milliseconds: 220), () =>
        _tone(220, 'sine', 0.14, 0.08, 0.08));
  }

  void playAchievement() {
    final notes = [523.25, 659.25, 783.99, 1046.5];
    for (var i = 0; i < notes.length; i++) {
      Future.delayed(Duration(milliseconds: i * 90), () =>
          _tone(notes[i], 'sine', 0.12, 0.14, 0.10));
    }
  }
}
