## 1) Подготовка на машине A (192.168.1.197)

### 1.1. Настройте переменные окружения

Скопируйте `.env.example` в `.env` и поправьте под вашу сеть:

cp .env.example .env
nano .env

Ключевые параметры:

- `PARENT_IF` — физический интерфейс в LAN на машине A (часто `enp3s0`, `eth0`, `ens18` и т.п.)
- `LAN_SUBNET`, `LAN_GATEWAY` — подсеть и шлюз
- `CASS1_IP..CASS3_IP` — IP контейнеров (должны быть **свободны** и **исключены из DHCP**)
- `HOST_SHIM_IP` — свободный IP для shim-интерфейса на машине A

Как быстро узнать интерфейс:

ip route get 1.1.1.1


### 1.2. Поднимите кластер

docker compose up -d --build
docker compose ps

## 2) Доступ с машины A (192.168.1.197) к macvlan-контейнерам: создаём macvlan-shim

На машине A выполните:

set -a
source .env
set +a

sudo ip link add cassandra-shim link "$PARENT_IF" type macvlan mode bridge
sudo ip addr add "$HOST_SHIM_IP/24" dev cassandra-shim
sudo ip link set cassandra-shim up

# Маршрут до диапазона 192.168.1.200-207 (включает .200-.202)
sudo ip route add 192.168.1.200/29 dev cassandra-shim

## 3) SSH: доступ с 192.168.1.197 на 192.168.1.200 (cassandra1)

### 3.1. Сгенерируйте ключ на машине A

ssh-keygen -t ed25519 -f ~/.ssh/cassandra_lan -N ""

### 3.2. Добавьте public key в контейнер cassandra1 (через docker exec)

cat ~/.ssh/cassandra_lan.pub | docker compose exec -T cassandra1 bash -lc '
  cat >> /home/admin/.ssh/authorized_keys &&
  chown -R admin:admin /home/admin/.ssh &&
  chmod 700 /home/admin/.ssh &&
  chmod 600 /home/admin/.ssh/authorized_keys
'

### 3.3. Подключитесь по SSH (после настройки shim)

ssh -i ~/.ssh/cassandra_lan admin@192.168.1.200

## 4) Проверка `cqlsh` с машины B (192.168.1.198)

На машине B:

docker run --rm -it cassandra:4.1.5 cqlsh 192.168.1.200 9042

Выход (`exit`) и подключаемся к другим узлам:

docker run --rm -it cassandra:4.1.5 cqlsh 192.168.1.201 9042
docker run --rm -it cassandra:4.1.5 cqlsh 192.168.1.202 9042

## 6) Скриншот результата
docs/result.png

