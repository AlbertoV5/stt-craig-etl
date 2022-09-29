# Dev Environment


## Poetry

We are going to install everything under a `poetry` project. So the first thing is to initialize poetry and add the whisper dependency. Then we will add our fork of the whisper repository as submodule of this repo and then add all the dependencies to the poetry environment.

```shell
poetry init
```

```shell
poetry add git+https://github.com/openai/whisper.git
```

```shell
git submodule add git@github.com:AlbertoV5/whisper.git whisper
```

```shell
cat whisper/requirements.txt | xargs poetry add
```

    Using version ^1.23.3 for numpy
    Using version ^1.12.1 for torch
    Using version ^4.64.1 for tqdm
    Using version ^8.14.0 for more-itertools
    
    Updating dependencies
    Resolving dependencies...
    
    Writing lock file
    
    Package operations: 20 installs, 0 updates, 0 removals
    
      • Installing certifi (2022.9.24)
      • Installing charset-normalizer (2.1.1)
      • Installing idna (3.4)
      • Installing pyparsing (3.0.9)
      • Installing urllib3 (1.26.12)
      • Installing filelock (3.8.0)
      • Installing packaging (21.3)
      • Installing pyyaml (6.0)
      • Installing requests (2.28.1)
      • Installing tqdm (4.64.1)
      • Installing typing-extensions (4.3.0)
      • Installing future (0.18.2)
      • Installing huggingface-hub (0.10.0)
      • Installing numpy (1.23.3)
      • Installing regex (2022.9.13)
      • Installing tokenizers (0.12.1)
      • Installing ffmpeg-python (0.2.0)
      • Installing more-itertools (8.14.0)
      • Installing torch (1.12.1)
      • Installing transformers (4.22.2)

Finall we will install `ffmpeg` globally as we also need it for running `whisper`.

```shell
brew install ffmpeg
```


## Test Case

We already have our specifications so we are going to start with a basic test:

-   Load a mp4 file through `whisper` and compare the result with a transcipt made by a human.

We are going to add the test to the repository but we won&rsquo;t upload any mp4 file so we will ignore them with `**/*.mp4` in our .gitignore.


## Dealing with audio

We are going to start by converting the .mp4 video file to a .wav file, which is audio only.

```shell
ffmpeg -i resources/test.mp4 resources/test.wav
```

We are going to change the conversion settings because our source is already compressed at a bitrate of `192kbps`. This means that there is no information in the higher frequencies starting at around `16khz`. However, we expect some files to be even more compressed so we are just gonna set our limit to `12khz` which brings the smaple rate to `24khz` (double the nyquist).

Then we are going to reduce the number of channels from 2 to 1. In an ideal scenario, we would do this by encoding to M/S (midside) and then getting rid of the side channel but we are going to stop at the ffmpeg interface and provide the `-ac 1` flag instead. In the future we can improve the process by finding a Midside tool. The reason for using the mid channel only is that TV broadcasts are mixed with the dialog in the center channel.

```shell
ffmpeg -i resources/test.mp4 -ar 24000 -ac 1 resources/test.wav
```

So in the end we end up with the following audio specifications.

| Format | Channels | Sample Rate | Bits |
|------ |-------- |----------- |---- |
| .wav   | 1        | 24000       | 16   |

```python
channels = 1
samplerate = 24000
bits = 16
bits_to_mb = lambda x: x / 8e6
print(f"{round(duration * samplerate * channels * bits_to_mb(bits), 2)}")
```

    1.44

Our test is about 30 seconds long so our final file size will be: `1.44` MB. Assuming the average episode of the TV Show is no more than 40 minutes long, we would have `57.6` MB of audio to process per episode if we work with .wav files.

We may need to compress to FLAC or MP3 as they are supported by whisper too<sup><a id="fnr.1" class="footref" href="#fn.1" role="doc-backlink">1</a></sup>.


## Testing the model

Let&rsquo;s start by running `whisper` from the command line.

```shell
poetry run whisper resources/test.wav
```

    

We are going to include an MP3 version of the test file in here.

<audio controls>
  <source src="../resources/test.mp3" type="audio/mpeg">
Your browser does not support the audio element.
</audio>

And here is the transcript from whisper:

```shell
cat test.wav.txt
```

    Man, it's crazy out there.
    You look sensational, man.
    Well, that's correct.
    And that's not just the cold medication talking.
    I'm telling you.
    You look great.
    You got the beard going on.
    It's very dynamic.
    Oh, thank you very much.
    No, it's good.
    You like Robin Williams?
    You grow a beard.
    Do you want an Oscar?
    No.
    All right.
    All right.
    So listen, tell me about the side-by-side movie you were interviewing.
    Is he really as much of a douche as everyone says he is?

We can build a test around this just for comparing the different model sizes and helping us chose the parameters for when we scale the process up.


## Scaling the process

We are going to use Assembly AI&rsquo;s analysis<sup><a id="fnr.2" class="footref" href="#fn.2" role="doc-backlink">2</a></sup> to help us decide how to move forward and what technologies we need for running the model with large amounts of data.

Our local CPU takes too long transcribing the 30 seconds and I don&rsquo;t have a GPU available right now so we are definitely going to the cloud.

## Footnotes

<sup><a id="fn.1" class="footnum" href="#fnr.1">1</a></sup> <https://github.com/openai/whisper>

<sup><a id="fn.2" class="footnum" href="#fnr.2">2</a></sup> <https://www.assemblyai.com/blog/how-to-run-openais-whisper-speech-recognition-model/#openai-whisper-analysis>
