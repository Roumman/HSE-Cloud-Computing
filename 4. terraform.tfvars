# Файл с переменными для Terraform: задаёт ID облака и каталога Yandex Cloud, зону доступности и SSH‑ключ для доступа к виртуальной машине.

cloud_id       = "" # ID облака в Yandex Cloud (можно найти в консоли управления)
folder_id     = "" # ID каталога (папки) в Yandex Cloud
zone          = "ru-central1-b" # Зона доступности (по умолчанию — ru-central1‑b)
ssh_public_key = "" # Публичный SSH‑ключ для доступа к ВМ. Поддерживаемые форматы: ssh‑ed25519 AAAA... или ssh‑rsa AAAA...
