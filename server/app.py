from flask import Flask, request, send_file, jsonify
from pydub import AudioSegment
import tempfile
import os
import numpy as np

app = Flask(__name__)

def mix_audios(audio_segment1, audio_segment2, background_volume=-10):
    try:
        if len(audio_segment2) < len(audio_segment1):
            loops = (len(audio_segment1) // len(audio_segment2)) + 1
            audio_segment2 = audio_segment2 * loops
        audio_segment2 = audio_segment2[:len(audio_segment1)]
        audio_segment2 = audio_segment2 + background_volume
        mixed = audio_segment1.overlay(audio_segment2, position=0)
        return mixed
    except Exception as e:
        print(f"Error mixing audios: {e}")
        return None

def create_gentle_binaural_audio(audio, base_freq=100, freq_diff=6, effect_strength=0.05):
    samples = np.array(audio.get_array_of_samples()).astype(np.float32)
    
    if audio.channels == 1:
        samples = np.column_stack((samples, samples))
    else:
        samples = samples.reshape((-1, 2))
    
    duration = len(samples) / audio.frame_rate
    t = np.linspace(0, duration, len(samples), False)
    
    left_freq = base_freq
    right_freq = base_freq + freq_diff
    
    left_wave = np.sin(2 * np.pi * left_freq * t)
    right_wave = np.sin(2 * np.pi * right_freq * t)
    
    # Apply a very gentle binaural effect
    left_channel = samples[:, 0] * (1 - effect_strength) + samples[:, 0] * effect_strength * left_wave
    right_channel = samples[:, 1] * (1 - effect_strength) + samples[:, 1] * effect_strength * right_wave
    
    # Combine channels
    stereo_audio = np.column_stack((left_channel, right_channel))
    
    # Normalize to prevent any potential clipping
    max_val = np.max(np.abs(stereo_audio))
    if max_val > 32767:
        stereo_audio = stereo_audio * (32767 / max_val)
    
    stereo_audio = np.int16(stereo_audio)
    
    binaural_audio = AudioSegment(
        stereo_audio.tobytes(),
        frame_rate=audio.frame_rate,
        sample_width=2,
        channels=2
    )
    
    return binaural_audio

@app.route('/process_audio', methods=['POST'])
def process_audio():
    if 'audio1' not in request.files:
        return jsonify({"error": "Please provide 'audio1' (main audio)."}), 400

    try:
        audio1 = AudioSegment.from_file(request.files['audio1'])
        audio2_path = 'D:\\Pranit\\Flutter\\calm\\server\\Whispers_of_the_Butterflies.mp3'
        if not os.path.exists(audio2_path):
            return jsonify({"error": "The background audio (audio2) file was not found."}), 404

        audio2 = AudioSegment.from_file(audio2_path)
        mixed = mix_audios(audio1, audio2, background_volume=-5)
        if mixed is None:
            return jsonify({"error": "Error processing the audio."}), 500

        binaural_audio = create_gentle_binaural_audio(mixed, base_freq=100, freq_diff=6, effect_strength=0.05)

        with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as tmp_output_file:
            binaural_audio.export(tmp_output_file.name, format="mp3", bitrate="192k")
            tmp_output_file_path = tmp_output_file.name

        return send_file(tmp_output_file_path, as_attachment=True, download_name="final_binaural_output.mp3")
    except Exception as e:
        print(f"Error processing audio: {e}")
        return jsonify({"error": "An error occurred while processing the audio."}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')