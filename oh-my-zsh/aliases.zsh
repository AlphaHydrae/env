alias less="less -R"
alias mvn-sql="mvn -Dspring.jpa.show-sql=true -Dspring.jpa.properties.hibernate.format_sql=true -Dlogging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE test"
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
alias z="zellij"
alias zf="zellij run --floating --"
alias zr="zellij run --"

# https://hub.github.com
hash hub 2>/dev/null && alias git="hub"
