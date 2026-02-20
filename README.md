Below are three videos part1 ,part2 and part 3 that briefly explain how this script is run as well as the archieve feature.
https://www.loom.com/share/e48a56b7d69b4d40a4492a23b7f7a0ae
https://www.loom.com/share/4e7ef0f311d746aebfd71ce1df9f73eb
https://www.loom.com/share/583c58947bcb4e82bb3f13ef198d27ee

This script setup_project.sh will create a parent directory named attendance_tracker_v1
It also creates within the parent directory two directory named Helpers and reports containing assets.csv, config.json and reports.log respectively.
This script allows you to change the attendance thresholds from the ones that a student starts receiving warning from to the mminimum attendance threshold required to pass the course.
Moreover this script checks if python three is installed
It verifies if this attendance tracker was created successfully
To run this script, firstly the execution permission must be given to it.
Secondly, the project name is given and that is v1 otherwise the text "You must specify the project name after the script name. For eg: ./setup_project.sh v1" will be displayed.
Thirdly, the prompts given to the user must be answered. For instance yes or no if asked if the thresholds need to be changed.
From there all the verifications can be made including the test of if the file exists and if python3 is installed using the respective command which is python3 --version
The speciality of this script is that it has the archieve feature which is triggered by clicking the Ctrl+c. When you click the Ctrl+c the  clanup() function is called and it automatically runs and stops the script from executing right there . This feature keeps the already existing or the unfisnished work.
