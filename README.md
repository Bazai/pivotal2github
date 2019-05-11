# PivotalTracker to Github Issues migration scripts

To succesful migrate tickets from PivotalTracker to Github do:

1. Clone this repo
2. Run in console: `gem install httparty`
3. Run in console: `gem install highline`
4. Import all user stories from PivotalTracker to csv file
5. Name it `issues.csv`
6. If you need to clear all existing repo labels, run: `ruby delete_labels.rb`, but check `your_github_username/your_repository_name` block inside the file first
7. For importing tickets from csv to repo, run: `ruby import_issues.rb issues.csv` and follow prompts

Thanks for making these scripts to @robotarmy and his gist: https://gist.github.com/2257596

Done!
