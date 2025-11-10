# How to create and push


🧑‍💻 1  Get your github account going.  
      The rest of this is to setup for a repo create.
      it uses my example of steve100 

🧑‍💻 2. Created a new ssh Key

       ssh-keygen -t ed25519 -C "username"
      cat ~/.ssh/id_ed25519.pub

🧑‍💻 3. Set your identity (global config)

      Git uses your name and email in commits:

      git config --global user.name "yourname"
      git config --global user.email "your_email@example.com"


      Check:

      git config --list

🔐 4. Authenticate with GitHub 

      ssh -T git@github.com

      You should see:
     "Hi [your user]! You’ve successfully authenticated…”

🔐 5. the create repo should work
    create-repo.sh 


