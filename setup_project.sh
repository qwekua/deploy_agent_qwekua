#!/usr/bin/env bash
# Attendance tracker bootstrap — creates directory layout, prompts for
# thresholds, validates env, registers SIGINT trap, and runs the checker.
set -u

PROJECT_NAME="${1:-attendance_tracker_default}"
ROOT="attendance_tracker_${PROJECT_NAME}"

cleanup() {
  echo ""
  echo "[trap] SIGINT received — cleaning up and exiting."
  exit 130
}
trap cleanup SIGINT

echo "==> Creating project tree at ${ROOT}"
if ! mkdir -p "${ROOT}/Helpers" "${ROOT}/reports"; then
  echo "ERROR: could not create ${ROOT}" >&2
  exit 1
fi

cd "${ROOT}" || { echo "ERROR: cd failed" >&2; exit 1; }

echo "==> Checking python3"
if ! python3 --version; then
  echo "ERROR: python3 not installed" >&2
  exit 1
fi

read -r -p "Warning threshold % [default 75]: " WARN
read -r -p "Failure threshold % [default 50]: " FAIL
WARN="${WARN:-75}"
FAIL="${FAIL:-50}"

cat > Helpers/config.json <<EOF
{
    "thresholds": {
        "warning": ${WARN},
        "failure": ${FAIL}
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF

# allow re-running by tuning thresholds in-place
sed -i.bak "s/\"warning\": [0-9]*/\"warning\": ${WARN}/" Helpers/config.json
sed -i.bak "s/\"failure\": [0-9]*/\"failure\": ${FAIL}/" Helpers/config.json
rm -f Helpers/config.json.bak

touch reports/reports.log
echo "==> Running attendance_checker.py"
python3 Helpers/attendance_checker.py
echo "==> Done. See reports/reports.log"
