#!/usr/bin/env bash
# SCRIPT: pe.sh
# AUTHOR: erfankarimi
# DATE: 2023-11-15_14:21:17
# REV: 1.0
# PURPOSE:
#         This file will create a python virutural envirments with the '-c' flag and delete or terminate with the '-t' flag.
#         You can create a Python virutural envirment and run the jupyter Notebook inside of the envirment using the '-j' flag.
#
# FLAGS:
#        - '-c'         - Create Python environment
#        - '-t' | '-d'  - Terminate Python environment
#        - '-j'         - Create Python environment and run Jupyter Notebook
#
#
# HOW TO:
#          ACTIVATE PYTHON ENVIRONMENT:
#                       #   . pe.sh -c
#                       #   source make-env.sh -c
#
#          ACTIVATE PYTHON ENVIRONMENT AND RUN JUPYTER Notebook:
#                       #   . pe.sh -j
#                       #   source pe.sh -j
#
#          TERMINATE PYTHON ENVIRONMENT: -t or -d
#                       #   . pe.sh -t
#                       #   source pe.sh -t
#
#          DEFINE YOUR OWN PYTHON PATH:
#                       #   ENVPATH='/tmp/anotherenv' . pe.sh -c
#			-- Also the default or set path will be saved
#			under the root of git repo or HOME dir of user.
#
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution

find_root_path() {
  # Function to find the root path of the Git repository
  # Or the Home dir of the user

  # Find the root directory of the Git repository
  local git_root_path=$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)

  if [ -n "$git_root_path" ]; then
    echo -n "$git_root_path"
  else
    echo -n "$HOME"
  fi
}

function hasFlag {
  local flag="$1"
  shift

  for arg in "$@"; do
    if test "${arg}" = "${flag}"; then
      return 0
    fi
  done
  return 1
}

function CreateEnv {
  echo "Creating environment in Path ${envPath}..."
  mkdir -p ${envPath}
  $PYTHON -m venv ${envPath} &&
    echo -e "Acivating environment ...\n" &&
    source ${envPath}/bin/activate || {
    echo "ERROR: Something went wrong" >&2
    return 1
  }
}

function RunJupyterNotebook {
  echo -e "Launching Jupyter Notebook... \n"
  jupyter notebook
}

function TerminateEnv {
  echo -e "Terminating the Envirment ... \n"
  source "${envPath}/bin/deactivate" 2>/dev/null
  deactivate 2>/dev/null
  rm -rf "$envPath" 2>/dev/null
  >"$default_path"
}

# ---------------------------------------------------
# ----------------   MAIN ---------------------------
# ---------------------------------------------------

echo "Use -c or no flag to create python envirment, -j (create and start with jupiter) or -t (terminate)."

PYTHON="$(which python &>/dev/null && echo -n python || echo -n python3)"
root_path="$(find_root_path)"
REQUIREMENTS_FILE="${root_path}/requirements.txt"

if [ "$0" = "$BASH_SOURCE" ]; then
  flags="< -c -j -t >"
  echo -e "Error: Please run this script while sourcing it into the terminal.\nLike:\n\t'. $0 $flags'\n\t\tor\n\t'source $0 $flags'\n"
  exit 1
fi

default_path="${root_path}/.python.env.path"
touch "$default_path"

if [ -n "${ENVPATH}" ]; then
  envPath="${ENVPATH}"
  echo "${ENVPATH}" > "${default_path}"
elif [ -z "$(cat "$default_path")" ]; then
  envPath="$(mktemp -d | tee "${default_path}")"
else
  envPath="$(cat "${default_path}")"
fi

if hasFlag "-r" "$@"; then
  CreateEnv 2>/dev/null
  [ -e "${REQUIREMENTS_FILE}" ] && echo "Installing requirements" || { echo "REQUIREMENTS_FILE ${REQUIREMENTS_FILE} does not exits"; exit 1; }
  pip3 install -r "${REQUIREMENTS_FILE}" || exit 1
elif hasFlag "-t" "$@" || hasFlag '-d' "$@"; then
  TerminateEnv
elif hasFlag "-c" "$@"; then
  CreateEnv
elif hasFlag '-j' "$@"; then
  CreateEnv && RunJupyterNotebook
else
  CreateEnv
fi
