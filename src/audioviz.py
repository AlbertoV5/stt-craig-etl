# [[file:etl.org::#loading-audio][Loading audio:2]]
import librosa
import plotly.express as px
import numpy as np
from pathlib import Path
import matplotlib.pyplot as plt
import warnings

warnings.filterwarnings("ignore", category=DeprecationWarning)
resources = Path('resources') / 'test'
output_file = resources / 'test.png'
# Librosa data
y, sr = librosa.load(resources / 'test.wav', mono=True)
# mfcc = librosa.feature.mfcc(y=y[0:22050 * 4], sr=sr, hop_length=512, n_mfcc=13)
lim = (sr*5, sr*8)
data = y[lim[0]:lim[1]]
oldsr = sr
sr = int(sr/4)
data = librosa.resample(data, orig_sr=oldsr, target_sr=sr)
plt.figure(figsize=(8, 5), dpi=150)
plt.specgram(data, Fs=2, NFFT=256, scale='dB', cmap='plasma')
# plt.plot(data)
plt.xticks(np.arange(0, sr*1.5, sr/4), labels=np.arange(5, 8, 0.5))
plt.yticks(np.arange(0, 1, 0.2), labels=np.arange(0, sr, sr/5).astype(int))
plt.title("Spectrogram for 'You look sensational, man'")
plt.xlabel("Time (s)")
plt.ylabel("Frequency (Hz)")
plt.savefig(output_file)
plt.close()
print(output_file, end="")
# Loading audio:2 ends here
