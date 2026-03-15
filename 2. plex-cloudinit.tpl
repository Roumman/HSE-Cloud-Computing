# Создаёт скрипт установки Plex в /opt/plex/ и запускает его при инициализации ВМ

#cloud-config
# Plex: write install script and run once (script is idempotent).

write_files:
  - path: /opt/plex/install-plex.sh
    permissions: "0755"
    owner: root:root
    encoding: b64
    content: ${script_content_base64}

runcmd:
  - /opt/plex/install-plex.sh
