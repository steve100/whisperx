for file in *.mkv; do

 echo "--------------------------"
 bash ../run-transcribe.sh    $file
 echo "."
done
