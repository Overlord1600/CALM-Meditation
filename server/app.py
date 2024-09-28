from flask import Flask, request, send_file, jsonify
from pydub import AudioSegment
import tempfile
import os
import numpy as np
from AccelBrainBeat.brainbeat.binaural_beat import BinauralBeat

app = Flask(__name__)

def mix_audios(audio_segment1, audio_segment2, background_volume=-5):
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

def create_binaural_audio(audio, base_freq=100, freq_diff=6, effect_strength=0.2):
    # Create BinauralBeat object
    brain_beat = BinauralBeat()
    
    # Calculate the second frequency
    second_freq = base_freq + freq_diff
    
    # Create a temporary file to save the binaural beat
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp_file:
        binaural_file = tmp_file.name
    
    # Generate binaural beat
    brain_beat.save_beat(
        output_file_name=binaural_file,
        frequencys=(base_freq, second_freq),
        play_time=len(audio) / 1000,  # pydub works in milliseconds
        volume=effect_strength
    )
    
    # Load the generated binaural beat
    binaural_audio = AudioSegment.from_wav(binaural_file)
    
    # Ensure binaural audio matches the length of original audio
    if len(binaural_audio) < len(audio):
        binaural_audio = binaural_audio + AudioSegment.silent(duration=len(audio) - len(binaural_audio))
    else:
        binaural_audio = binaural_audio[:len(audio)]
    
    # Mix original audio with binaural beat
    mixed_audio = audio.overlay(binaural_audio)
    
    # Clean up the temporary file
    os.remove(binaural_file)
    
    return mixed_audio

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

        binaural_audio = create_binaural_audio(mixed, base_freq=100, freq_diff=6, effect_strength=0.2)

        with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as tmp_output_file:
            binaural_audio.export(tmp_output_file.name, format="mp3", bitrate="192k")
            tmp_output_file_path = tmp_output_file.name

        return send_file(tmp_output_file_path, as_attachment=True, download_name="final_output.mp3")
    except Exception as e:
        print(f"Error processing audio: {e}")
        return jsonify({"error": "An error occurred while processing the audio."}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')