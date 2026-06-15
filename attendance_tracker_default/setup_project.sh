#!/usr/bin/env bash
# Attendance tracker bootstrap — builds the project tree, validates input,
# runs the checker, archives results, and cleans up on Ctrl+C.
set -u

PROJECT_NAME="${1:-default}"
ROOT="attendance_tracker_${PROJECT_NAME}"

cleanup() {
  echo ""
  echo "[trap] SIGINT received — archiving partial results and exiting."
  if [ -d "${ROOT}/reports" ]; then
    tar -czf "${ROOT}_partial_$(date +%s).tar.gz" "${ROOT}/reports" 2>/dev/null || true
  fi
  exit 130
}
trap cleanup SIGINT INT

read -p "Project name [default]: " INPUT_NAME
if [ -n "${INPUT_NAME}" ]; then
  PROJECT_NAME="${INPUT_NAME}"
  ROOT="attendance_tracker_${PROJECT_NAME}"
fi

echo "==> Creating ${ROOT}/Helpers and ${ROOT}/reports"
mkdir -p "${ROOT}/Helpers" "${ROOT}/reports" || { echo "ERROR: mkdir failed" >&2; exit 1; }

# Required files
touch "${ROOT}/reports/reports.log"
touch "${ROOT}/Helpers/assets.csv"
> "${ROOT}/Helpers/config.json"
> "${ROOT}/Helpers/attendance_checker.py"

echo "==> Checking python3 installation"
if command -v python3 >/dev/null 2>&1; then
  python3 --version
  echo "success: python3 is installed"
else
  echo "warning: python3 is missing — install it before running the checker"
fi

read -p "Warning threshold % [default 75]: " WARN
read -p "Failure threshold % [default 50]: " FAIL
WARN="${WARN:-75}"
FAIL="${FAIL:-50}"

# Validate empty inputs
if [ -z "$WARN" ] || [ -z "$FAIL" ]; then
  echo "ERROR: thresholds cannot be empty" >&2
  exit 1
fi

# Validate non-numeric values
if ! [[ "$WARN" =~ ^[0-9]+$ ]] || ! [[ "$FAIL" =~ ^[0-9]+$ ]]; then
  echo "ERROR: thresholds must be numbers (digit)" >&2
  exit 1
fi

# Validate threshold ranges (0..100 and failure < warning)
if [ "$WARN" -gt 100 ] || [ "$FAIL" -lt 0 ] || [ "$FAIL" -ge "$WARN" ]; then
  echo "ERROR: need 0 <= failure < warning <= 100" >&2
  exit 1
fi

cat > "${ROOT}/Helpers/config.json" <<EOF
{
  "thresholds": {
    "warning": ${WARN},
    "failure": ${FAIL}
  },
  "run_mode": "live",
  "total_sessions": 15
}
EOF

# In-place tuning of thresholds
sed -i.bak "s/\"warning\": [0-9]*/\"warning\": ${WARN}/" "${ROOT}/Helpers/config.json"
sed -i.bak "s/\"failure\": [0-9]*/\"failure\": ${FAIL}/" "${ROOT}/Helpers/config.json"
rm -f "${ROOT}/Helpers/config.json.bak"

echo "==> Running attendance_checker.py"
( cd "${ROOT}" && python3 Helpers/attendance_checker.py ) || echo "checker exited non-zero"

# Archive the run, then remove the working tree per spec
ARCHIVE="${ROOT}_$(date +%Y%m%d_%H%M%S).tar.gz"
echo "==> Archiving ${ROOT} -> ${ROOT}_archive.zip and ${ARCHIVE}"
tar -czf "${ARCHIVE}" "${ROOT}"
zip -rq "${ROOT}_archive.zip" "${ROOT}" 2>/dev/null || true

echo "==> Cleanup: removing working directory after archive"
rm -rf "${ROOT}"

echo "==> Done. Archive: ${ARCHIVE}"
