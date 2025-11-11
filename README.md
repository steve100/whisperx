# Whisperx - an ML tool 

## Setup and Tools to use the Whisperx transciption locally
   Uses Windows WSL and CPU only

## Pre-Setup - 
   How to install WSL2
   https://learn.microsoft.com/en-us/windows/wsl/install

## Setup
```
cd setup-folder
~/whisperx/setup-folder$ cat run-order.txt
# To reduce confusion, copy and paste the commands to run them.

# install os changes for wsl .. 
# not necessary to repeat this step with new download.
./start-here-prep.sh

# create the pythone environment
./create-env.sh

# activate the new python environment  ./activate-manually.txt
source ~/whisperx-venv/bin/activate  

# install the python modules for whisperx
./install-whisperx-tools.sh

# install whisperx
./install-more-whisperx.sh

```

## Easy Test
```
# change directory
cd ~/whisperx

# clean out the test information modify as necessary
# there is an rm command echoed at the bottom which is probably what you want
bash clean-movies-for-testing.sh

#optionally clean
bash  ./clean-movies-for-testing.sh

#run the conversions
bash run-movies-for-testing-example.sh
```


# More Information
- Various tools found in run-movies-for-testing-example
- all should run on their own
- most assume filenames will NOT have spaces

- The names are self-explanitory. 

```
    command.sh filename
    all_command.sh -- does a loop through the files.
```
## Ways to Run the programs
 - Use a list 
    run-transcribe-list.sh
 - Run once
    run-transcribe.sh filename
 - Run "all" cd into the directory - see below

```
echo "Activate the Python3 Environment" 
source ./do-activate.sh

echo "Change to a working directory "
cd movies-for-testing

pwd

echo "Show the movies to convert in this case .mov"
shopt -s nocaseglob
ls *.mov
shopt -u nocaseglob   # optional: turn it back off

echo "Output files are assumed to not exist. "
echo "prompt [Y/N] if they already exist"


echo "Convert .mov files to .mkv files"
../all_mov.sh

echo "Convert the .mkv files to .mp3"
../all_mp3.sh 

echo "Convert the .mkv files to .wav - better for transcription"
../all_real_wav.sh

echo "Convert the .mkv file to a text transcription"
../all_txt.sh

echo "List the directory"
ls -lh *

echo "Done"
```
