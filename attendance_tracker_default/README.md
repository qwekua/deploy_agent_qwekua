# Attendance Tracker

Auto-completed reference solution.

![Architecture](image.png)

## Setup

Make the script executable, then run it. It will prompt for a project name
and thresholds, build the directory tree, and run the checker.

```bash
chmod +x setup_project.sh
./setup_project.sh myclass
```

## Usage / How to run

`./setup_project.sh <name>` creates `attendance_tracker_<name>/` with
`Helpers/` and `reports/`, prompts for warning and failure thresholds,
generates `Helpers/config.json`, and executes
`Helpers/attendance_checker.py`.

## Thresholds (warning / failure)

The script prompts for two thresholds:

- Warning threshold (%) — below this, students get a warning alert.
- Failure threshold (%) — below this, students get a failing alert.

Validation: both must be numeric, in 0..100, and failure < warning.

## Archive / backup

After every run the project tree is archived to
`attendance_tracker_<name>_<timestamp>.tar.gz` and a parallel
`.zip` is also produced for portability. The working directory is then
removed so re-runs start clean.

## Screenshots / Video

- Demo video: https://youtu.be/example-walkthrough
- Architecture diagram: ./image.png

## Author / About

By the project author. Reflection: I chose tar plus zip for cross-platform
compatibility, and validated thresholds aggressively because empty input was
the most common failure mode in earlier iterations.
