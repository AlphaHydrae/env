root '~/Projects'
clone_url_type :ssh

add bitbucket
add github
add gitlab

repos.by(:probedock).on(:github).clone_into(:probedock)
repos.by(:probedock).on(:bitbucket).prefix('probedock-').clone_into(:probedock)

repos.by(:MediaComem).named(/biosentiers/, /mongodb-gis/, 'hhpp').clone_into(:mei)
repos.by(:sysin).named(/mongodb-gis/).clone_into(:mei)

mine = repos.by(:alphahydrae).on(:github)
mine.forks.clone_into('forks')
mine.named('ansible-roles', /^ansible-.*playbooks?$/).clone
mine.named(/^ansible-/).rename(/^ansible-/, 'AlphaHydrae.').clone_into('ansible-roles')
mine.clone
