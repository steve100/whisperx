# Whisperx

## Setup and Tools to use the Whisperx transciption locally
   Uses Windows WSL and CPU only

## Pre-Setup - 
   How to install WSL2
   https://learn.microsoft.com/en-us/windows/wsl/install

## Setup
   Here is how to create a repo on github .. this is mine
   create-repo.sh

   Go into the setup-folder
   cd setup-folder

   Set up the WSL environment -- uses Ubuntu
   ./start-here-prep.sh

   Run the create-env.sh line by line if you must.
   ./create-env.sh
   
   Insure the Python Virtual environment is running 
   source ~/whisperx-venv/bin/activate

# Various tools found in run-movies-for-testing-example
## all should run on their own
## most assume filenames will NOT have spaces
   The names are self-explanitory. 
   command.sh filename
   all_command.sh -- does a loop through the files.

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
