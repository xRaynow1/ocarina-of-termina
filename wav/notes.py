import math
import os
import random
import struct
import wave

SAMPLE_RATE = 44100
DURATION = 0.75

NOTES = {
    "note_c_low.wav":  523.25,   # Do grave (C5)
    "note_d.wav":      587.33,   # Ré (D5)
    "note_e.wav":      659.25,   # Mi (E5)
    "note_f.wav":      698.46,   # Fa (F5)
    "note_g.wav":      783.99,   # Sol (G5)
    "note_a.wav":      880.00,   # La (A5)
    "note_b.wav":      987.77,   # Si (B5)
    "note_c_high.wav": 1046.50,  # Do aigu (C6)
}


def generer_ocarina(chemin, freq):
    n_samples = int(SAMPLE_RATE * DURATION)
    phase = 0.0
    noise_lp = 0.0
    frames = bytearray()

    for i in range(n_samples):
        t = i / SAMPLE_RATE

        vib_env = min(1.0, max(0.0, (t - 0.08) / 0.18))
        f_inst = freq * (1.0 + 0.0045 * vib_env * math.sin(2.0 * math.pi * 5.5 * t))
        phase += 2.0 * math.pi * f_inst / SAMPLE_RATE

        tone = (
            0.85 * math.sin(phase)
            + 0.12 * math.sin(2.0 * phase)
            + 0.03 * math.sin(3.0 * phase)
        )

        raw = random.uniform(-1.0, 1.0)
        noise_lp = 0.85 * noise_lp + 0.15 * raw
        breath = 0.10 * math.exp(-t / 0.045) * noise_lp

        if t < 0.035:
            env = (t / 0.035) ** 1.5
        elif t > DURATION - 0.25:
            env = max(0.0, (DURATION - t) / 0.25) ** 1.6
        else:
            env = 1.0

        sample = max(-1.0, min(1.0, (tone + breath) * env * 0.72))
        frames += struct.pack("<h", int(sample * 32767))

    with wave.open(chemin, "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(frames)


def main():
    os.makedirs("notes", exist_ok=True)
    for nom, freq in NOTES.items():
        chemin = os.path.join("notes", nom)
        generer_ocarina(chemin, freq)
        print(f"Généré : {chemin} ({freq} Hz)")


if __name__ == "__main__":
    main()