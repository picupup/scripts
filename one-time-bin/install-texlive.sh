#!/usr/bin/env bash
# SCRIPT: install-texlive.sh
# AUTHOR: erfan-main 
# DATE: 2024-11-12T17:46:55
# REV: 1.0
# PURPOSE: It installs the current tex
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution


function printconfig {
    local lversion=$1

    echo "# texlive.profile written on $(date '+%F %T')
    # It will NOT be updated and reflects only the
    # installation profile at installation time.
    selected_scheme scheme-full
    TEXDIR $HOME/texlive/${lversion}
    TEXMFCONFIG ~/.texlive${lversion}/texmf-config
    TEXMFHOME ~/texmf
    TEXMFLOCAL $HOME/texlive/texmf-local
    TEXMFSYSCONFIG $HOME/texlive/${lversion}/texmf-config
    TEXMFSYSVAR $HOME/texlive/${lversion}/texmf-var
    TEXMFVAR ~/.texlive${lversion}/texmf-var
    binary_x86_64-linux 1
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

# ------------------------------------------

dir=$(mktemp -d)
echo created $dir

cd $dir

curl -LO http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xzf install-tl-unx.tar.gz
cd $(ls -d */)
version="${PWD##*-}"
year="${version:0:4}"
echo "Version $year"
printconfig "${year}" > texlive.profile

nohup {
    ./install-tl -profile texlive.profile;

    if [ -f ~/.bashrc ]; then
        echo 'export PATH=$PATH:/usr/local/texlive/2024/bin/x86_64-linux' >> ~/.bashrc;
    elif [ -f ~/.bash_profile ]; then
        echo 'export PATH=$PATH:/usr/local/texlive/2024/bin/x86_64-linux' >> ~/.bash_profile;
    fi

} &> /tmp/installtlmg.log &

echo "Process id is $?"

echo "The output can Be seen in /tmp/installtlmg.log"
echo "The instalation process has started. It is running in the background, so you could close the terminal and see the process in estimately 2 hours..."


