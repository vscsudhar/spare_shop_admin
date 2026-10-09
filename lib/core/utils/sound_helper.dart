import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class SoundHelper {
  /// Plays an authentic, sharp metallic impact sound ("arrow / sword hitting metal shield with ringing steel resonance")
  static void playOrderChime() {
    playMetalHitSound();
  }

  /// Plays a realistic metal-on-metal hit / arrow strike sound
  static void playMetalHitSound() {
    try {
      if (kIsWeb) {
        _playWebAudioMetalClang();
      } else {
        SystemSound.play(SystemSoundType.alert);
      }
    } catch (_) {
      try {
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  static void _playWebAudioMetalClang() {
    try {
      js.context.callMethod('eval', [
        r'''
        (function() {
          try {
            var AudioCtx = window.AudioContext || window.webkitAudioContext;
            if (!AudioCtx) return;
            var ctx = new AudioCtx();
            if (ctx.state === 'suspended') {
              ctx.resume();
            }
            var now = ctx.currentTime;

            // Master Volume
            var masterGain = ctx.createGain();
            masterGain.gain.setValueAtTime(0.55, now);
            masterGain.connect(ctx.destination);

            // 1. Initial Sharp Metallic Strike (FM Transient Punch)
            var modOsc = ctx.createOscillator();
            var modGain = ctx.createGain();
            modOsc.type = 'triangle';
            modOsc.frequency.setValueAtTime(740, now);
            modGain.gain.setValueAtTime(950, now);
            modGain.gain.exponentialRampToValueAtTime(1, now + 0.09);

            var carrierOsc = ctx.createOscillator();
            var carrierGain = ctx.createGain();
            carrierOsc.type = 'sine';
            carrierOsc.frequency.setValueAtTime(1650, now);
            modGain.connect(carrierOsc.frequency);
            modOsc.connect(modGain);

            carrierGain.gain.setValueAtTime(0.65, now);
            carrierGain.gain.exponentialRampToValueAtTime(0.001, now + 0.14);
            carrierOsc.connect(carrierGain);
            carrierGain.connect(masterGain);

            modOsc.start(now);
            carrierOsc.start(now);
            modOsc.stop(now + 0.16);
            carrierOsc.stop(now + 0.16);

            // 2. High-frequency Arrowhead / Steel Friction Strike Burst (Noise Transient)
            var sampleLength = Math.floor(ctx.sampleRate * 0.045);
            var noiseBuffer = ctx.createBuffer(1, sampleLength, ctx.sampleRate);
            var noiseData = noiseBuffer.getChannelData(0);
            for (var i = 0; i < sampleLength; i++) {
              noiseData[i] = (Math.random() * 2 - 1) * Math.exp(-i / (sampleLength * 0.22));
            }
            var noiseSource = ctx.createBufferSource();
            noiseSource.buffer = noiseBuffer;
            var noiseFilter = ctx.createBiquadFilter();
            noiseFilter.type = 'bandpass';
            noiseFilter.frequency.setValueAtTime(4500, now);
            noiseFilter.Q.setValueAtTime(3.8, now);
            var noiseGain = ctx.createGain();
            noiseGain.gain.setValueAtTime(0.38, now);
            noiseGain.gain.exponentialRampToValueAtTime(0.001, now + 0.045);
            noiseSource.connect(noiseFilter);
            noiseFilter.connect(noiseGain);
            noiseGain.connect(masterGain);
            noiseSource.start(now);

            // 3. Resonant Metallic Inharmonic Ringing Modes (Archer Arrow / Blade on Armor Clang)
            var metalHarmonics = [
              { freq: 960,  gain: 0.36, decay: 0.88 }, // Deep metallic body vibration
              { freq: 1480, gain: 0.40, decay: 0.78 }, // Primary ringing clang
              { freq: 2380, gain: 0.32, decay: 0.68 }, // Steel blade harmonic
              { freq: 3840, gain: 0.26, decay: 0.46 }, // Metallic ping overtone
              { freq: 5820, gain: 0.18, decay: 0.28 }  // High arrowhead strike shimmer
            ];

            metalHarmonics.forEach(function(h) {
              var osc = ctx.createOscillator();
              var gain = ctx.createGain();
              osc.type = 'sine';
              osc.frequency.setValueAtTime(h.freq, now);
              // Subtle dynamic micro pitch-bend on impact
              osc.frequency.exponentialRampToValueAtTime(h.freq * 0.988, now + h.decay);

              gain.gain.setValueAtTime(h.gain, now);
              gain.gain.exponentialRampToValueAtTime(0.0005, now + h.decay);

              osc.connect(gain);
              gain.connect(masterGain);
              osc.start(now);
              osc.stop(now + h.decay + 0.05);
            });
          } catch(e) {
            console.warn('[SoundHelper] Metallic hit sound failed:', e);
          }
        })();
      '''
      ]);
    } catch (e) {
      debugPrint('[SoundHelper] Web Audio error: $e');
    }
  }
}
