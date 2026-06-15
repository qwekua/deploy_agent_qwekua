# Attendance Tracker

Auto-completed by the ALU Summative Checker support tool.

## Run

```bash
chmod +x setup_project.sh
./setup_project.sh myclass
```

## Layout

- `Helpers/attendance_checker.py` — core logic
- `Helpers/assets.csv` — roster + counts
- `Helpers/config.json` — thresholds + run mode
- `reports/reports.log` — generated alerts
- `setup_project.sh` — bootstrap + runner
