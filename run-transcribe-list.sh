set -x
source ~/whisperx-venv/bin/activate
sleep 5
for i in `cat list` ; do
        bash ./run-transcribe.sh $i

done
