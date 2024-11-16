#!/usr/bin/env bash
# SCRIPT: install-texlive.sh
# AUTHOR: erfan-main 
# DATE: 2024-11-12T17:46:55
# REV: 1.0
# PURPOSE: It installs the current texlive
# GITHUB_URL: https://raw.githubusercontent.com/picupup/scripts/refs/heads/main/one-time-bin/install-texlive.sh
# FLAGS: 
#       -p : path: Recommended, and default, is "$HOME/texlive" or manually set to "/usr/local/texlive" if you have root access.
#       -f : run in forground
#
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution

function get_binary_name {
        if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS
                echo -n 'binary_universal-darwin 1'
        else
                # Linux or other UNIX-like systems
                echo -n 'binary_x86_64-linux 1'
        fi
}

function printconfig {
    echo "# texlive.profile written on $(date '+%F %T')
    # It will NOT be updated and reflects only the
    # installation profile at installation time.
    selected_scheme scheme-full
    TEXDIR ${installdir}
    TEXMFCONFIG ~/.texlive/${lversion}/texmf-config
    TEXMFHOME ~/texmf
    TEXMFLOCAL ${installbasedir}/texmf-local
    TEXMFSYSCONFIG ${installdir}/texmf-config
    TEXMFSYSVAR ${installdir}/texmf-var
    TEXMFVAR ${installdir}/texmf-var
    $(get_binary_name)
    instopt_adjustpath 0
    instopt_adjustrepo 1
    instopt_letter 0
    instopt_portable 0
    instopt_write18_restricted 1
    tlpdbopt_autobackup 1
    tlpdbopt_backupdir tlpkg/backups
    tlpdbopt_create_formats 1
    tlpdbopt_desktop_integration 1
    tlpdbopt_file_assocs 1
    tlpdbopt_generate_updmap 0
    tlpdbopt_install_docfiles 1
    tlpdbopt_install_srcfiles 1
    tlpdbopt_post_code 1
    tlpdbopt_sys_bin /usr/local/bin
    tlpdbopt_sys_info /usr/local/share/info
    tlpdbopt_sys_man /usr/local/share/man
    tlpdbopt_w32_multi_user 1"
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

function get-flag-value {
  local flag="$1"
  shift

  for ((i = 0; i < $#; i++)); do
    if [ "${!i}" = "${flag}" ]; then
        next_i=$((i +1));
      echo "${!next_i}"
      return 0  # Return success if the flag is found
    fi
  done

  return 1  # Return failure if the flag isn't found
}

# ------------------------------------------

userhomedir="$(echo ~)"
flag_p="$(get-flag-value -p "$@" 2>/dev/null)"
installbasedir="${flag_p:-"${userhomedir}/texlive"}"

dir=$(mktemp -d)
cd $dir
echo created $dir

curl -LO http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xzf install-tl-unx.tar.gz
cd $(ls -d */)

version="${PWD##*-}"
year="${version:0:4}"
echo "Version $year"
installdir="${installbasedir}/${year}"

printconfig > texlive.profile

if hasFlag "-f" "$@"; then
        ./install-tl -profile texlive.profile
else
        nohup ./install-tl -profile texlive.profile &> /tmp/installtlmg.log &
        process="$?"
        echo "The instalation process has started in '${installdir}'."
        echo "It is running in the background, so you can close the terminal and wait for estimately 2 hours for it to finish."
        echo "The Backgroup-process-id is: ${process}"
        echo "The output can be seen in /tmp/installtlmg.log"
fi

# --------------- Setting path ---------------------------- >

if [[ "$OSTYPE" == "darwin"* ]]; then
    bindir='universal-darwin'
else
    bindir='x86_64-linux'
fi

path="${installdir}/bin/${bindir}"
manpath="${installdir}/texmf-dist/doc/man"
infopath="${installdir}/texmf-dist/doc/info"

if [ "$(id -u)" -eq 0 ]; then
        # Root user: configure system-wide
        echo "Configuring system-wide PATH, MANPATH, and INFOPATH for root..."

        if [ -f /etc/profile ] && grep -q "${path}" /etc/profile; then
        echo "export PATH=${path}:\$PATH" >> /etc/profile
        fi
        if [ -f /etc/manpath.config ] && grep -q "${manpath}" /etc/manpath.config; then
        echo "MANPATH_MAP ${manpath}" >> /etc/manpath.config
        fi

        # Create script in /etc/profile.d
        echo "Creating script in /etc/profile.d/texlive.sh"
        cat <<EOF > /etc/profile.d/texlive.sh
export PATH=${path}:\$PATH
export MANPATH=${manpath}:\$MANPATH
export INFOPATH=${infopath}:\$INFOPATH
EOF
        chmod -R a+rX /usr/local/texlive
        chmod +x /etc/profile.d/texlive.sh
else
        # Non-root user: configure user-specific
        echo "Configuring PATH, MANPATH, and INFOPATH for current user..."
        if [ -f ~/.bashrc ] && grep -q "${path}" ~/.bashrc; then
        echo "export PATH=${path}:\$PATH" >> ~/.bashrc
        echo "export MANPATH=${manpath}:\$MANPATH" >> ~/.bashrc
        echo "export INFOPATH=${infopath}:\$INFOPATH" >> ~/.bashrc
        elif [ -f ~/.bash_profile ] && grep -q "${path}" ~/.bash_profile; then
        echo "export PATH=${path}:\$PATH" >> ~/.bash_profile
        echo "export MANPATH=${manpath}:\$MANPATH" >> ~/.bash_profile
        echo "export INFOPATH=${infopath}:\$INFOPATH" >> ~/.bash_profile
        fi
fi

# < --------------- Setting path ----------------------------

cd 
rm -rf "${dir}"