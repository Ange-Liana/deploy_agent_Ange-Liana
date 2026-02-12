#!/bin/bash


if [ -z "$1" ]; then
   echo "You must specify the project name after the script name. For eg: ./setup_project.sh v1"
   exit 1
fi

PROJECT_NAME="attendance_tracker_$1"
ARCHIVE_NAME="${PROJECT_NAME}_archive"


cleanup() {
   echo ""
   echo "Script interrupted! Creating archive..."

   if [ -d "$PROJECT_NAME" ]; then
       tar -czf "$ARCHIVE_NAME" "$PROJECT_NAME"
       rm -rf "$PROJECT_NAME"
       echo "Archive created: $ARCHIVE_NAME"
       echo "Incomplete project directory removed."
   fi

   exit 1
}

trap cleanup SIGINT

echo "Creating project structure..."

mkdir -p "$PROJECT_NAME/Helpers"
mkdir -p "$PROJECT_NAME/reports"


cat > "$PROJECT_NAME/attendance_checker.py" << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
   with open('Helpers/config.json', 'r') as f:
       config = json.load(f)

   if os.path.exists('reports/reports.log'):
       timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
       os.rename('reports/reports.log',
                 f'reports/reports_{timestamp}.log.archive')

   with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log','w') as log:
       reader = csv.DictReader(f)
       total_sessions = config['total_sessions']

       log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

       for row in reader:
           name = row['Names']
           email = row['Email']
           attended = int(row['Attendance Count'])

           attendance_pct = (attended / total_sessions) * 100
           message = ""

           if attendance_pct < config['thresholds']['failure']:
               message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
           elif attendance_pct < config['thresholds']['warning']:
               message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."

           if message:
               if config['run_mode'] == "live":
                   log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                   print(f"Logged alert for {name}")
               else:
                   print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
   run_attendance_check()
EOF


cat > "$PROJECT_NAME/Helpers/assets.csv" << EOF
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

cat > "$PROJECT_NAME/Helpers/config.json" << EOF
{
   "thresholds": {
       "warning": 75,
       "failure": 50
   },
   "run_mode": "live",
   "total_sessions": 15
}
EOF

touch "$PROJECT_NAME/reports/reports.log"


echo ""
read -p "Do you want to update attendance thresholds? (y/n): " choice

if [ "$choice" = "y" ]; then
   read -p "Enter Warning threshold (default 75): " warning
   read -p "Enter Failure threshold (default 50): " failure

   warning=${warning:-75}
   failure=${failure:-50}

   sed -i "s/\"warning\": [0-9]*/\"warning\": $warning/" "$PROJECT_NAME/Helpers/config.json"
   sed -i "s/\"failure\": [0-9]*/\"failure\": $failure/" "$PROJECT_NAME/Helpers/config.json"

   echo "Thresholds are updated."
else
   echo "Using default thresholds."
fi

echo ""
echo "Running Health Check..."

if python3 --version &> /dev/null; then
   echo "Python3 is installed."
else
   echo "Warning: Python3 is NOT installed."
fi

if [ -f "$PROJECT_NAME/attendance_checker.py" ] &&
  [ -f "$PROJECT_NAME/Helpers/assets.csv" ] &&
  [ -f "$PROJECT_NAME/Helpers/config.json" ] &&
  [ -f "$PROJECT_NAME/reports/reports.log" ]; then
   echo "The directory structure is verified."
else
   echo "The directory structure is not correct"
fi

echo ""
echo "Project setup complete!"


