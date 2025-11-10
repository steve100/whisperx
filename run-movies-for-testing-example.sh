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



