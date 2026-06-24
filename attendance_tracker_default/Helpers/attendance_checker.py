import csv
import json
import os
from datetime import datetime

def run_attendance_check():
  with open('Helpers/config.json', 'r') as f:
    config = json.load(f)
  if os.path.exists('reports/reports.log'):
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')
  os.makedirs('reports', exist_ok=True)
  with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
    reader = csv.DictReader(f)
    total_sessions = config['total_sessions']
    log.write(f"Attendance run: {datetime.now()}\n")
    for row in reader:
      name = row['Names']
      email = row['Email']
      attended = int(row['Attendance Count'])
      pct = (attended / total_sessions) * 100
      msg = ""
      if pct < config['thresholds']['failure']:
        msg = f"URGENT: {name}, attendance {pct:.1f}% — failing."
      elif pct < config['thresholds']['warning']:
        msg = f"WARNING: {name}, attendance {pct:.1f}% — at risk."
      if msg:
        if config['run_mode'] == "live":
          log.write(f"[{datetime.now()}] ALERT {email}: {msg}\n")
          print(f"Logged alert for {name}")
        else:
          print(f"[DRY] {email}: {msg}")

if __name__ == "__main__":
  run_attendance_check()
