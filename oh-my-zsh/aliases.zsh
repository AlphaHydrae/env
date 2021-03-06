alias less="less -R"
alias ogc="open -a Google\ Chrome"
alias pg="playground"
alias pub="cat ~/.ssh/id_*.pub"
alias remove-all-docker-containers="docker rm -f \$\(docker ps -a -q\)"
alias smn="summon"
alias telnet='telnet -e "^C"'
alias vcurl="curl -vvv -w '\n\nTotal time: %{time_total}'"
alias vi="vim"
alias vimt="vimtree"
alias vimtree="vim -c NERDTree"
alias vlc="open -n /Applications/VLC.app"

# https://hub.github.com
hash hub 2>/dev/null && alias git="hub"
