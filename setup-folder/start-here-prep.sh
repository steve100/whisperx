#update your wsl .. in this case ubuntu
sudo apt update && sudo apt install -y ffmpeg python3-venv python3-dev build-essential git wget vim 
# make sure CPU audio backend is available
sudo apt-get update && sudo apt-get install -y libsndfile1
