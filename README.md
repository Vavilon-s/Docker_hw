## Выполнение ДЗ

запуск из папки проекта:
```
cp .env.example .env
docker compose up -d --build --wait --wait-timeout 90
```

в .env можно поменять APP_PORT и GREETING. сейчас пример с портом 8000, то есть адрес http://127.0.0.1:8000/
если поменял настройки, снова docker compose up -d --wait --wait-timeout 90

ниже результаты по очереди: сначала был sqlite, потом переключил на redis.

### N1
Команда сборки — docker build -t hm:1 .
Команда запуска первого контейнера:

```bash
docker run -d --name docker-hm \
  -p 127.0.0.1:8080:8000 \
  -e GREETING='Hello from Konstantin' \
  hm:1
```

результат запроса:
```
Konstantin@MacBook-Air-Kostin Docker_hm % curl http://127.0.0.1:8080/
{"greeting": "Hello from Konstantin", "count": 1, "hostname": "7a5a0cd48b6a", "storage": "sqlite"}
```

а еще вот логи, показывающие отправку запроса на увеличение(результат увеличения счетчика можно посмотреть выше, там count=1 а не 0):
```
Konstantin@MacBook-Air-Kostin Docker_hm % docker logs docker-hm
2026-11-15 13:53:30,494 listening port=8000 storage=sqlite
2026-11-15 13:53:49,966 http 172.17.0.1 "GET / HTTP/1.1" 200 -
2026-11-15 13:55:55,878 http 172.17.0.1 "POST /increment HTTP/1.1" 200 -
2026-11-15 13:56:03,931 http 172.17.0.1 "GET / HTTP/1.1" 200 -
```


### N2

сохранение значения count через volume:
```
Konstantin@MacBook-Air-Kostin Docker_hm % docker compose up -d        
[+] up 1/1
 ✔ Container docker_hm-app-1 Started                                                                                                                                                     3.4s
Konstantin@MacBook-Air-Kostin Docker_hm % curl http://127.0.0.1:8000/
{"greeting": "Hello from Konstantin", "count": 0, "hostname": "4dcab02a4dc9", "storage": "sqlite"}%                                                                                          
Konstantin@MacBook-Air-Kostin Docker_hm % curl -X POST http://127.0.0.1:8000/increment
{"greeting": "Hello from Konstantin", "count": 1, "hostname": "4dcab02a4dc9", "storage": "sqlite"}%                                                                                          
Konstantin@MacBook-Air-Kostin Docker_hm % curl -X POST http://127.0.0.1:8000/increment
{"greeting": "Hello from Konstantin", "count": 2, "hostname": "4dcab02a4dc9", "storage": "sqlite"}%                                                                                          
Konstantin@MacBook-Air-Kostin Docker_hm % curl http://127.0.0.1:8000/                 
{"greeting": "Hello from Konstantin", "count": 2, "hostname": "4dcab02a4dc9", "storage": "sqlite"}%                                                                                          
Konstantin@MacBook-Air-Kostin Docker_hm % docker compose down
[+] down 2/2
 ✔ Container docker_hm-app-1 Removed                                                                                                                                                     3.2s
 ✔ Network docker_hm_default Removed                                                                                                                                                     0.1s
Konstantin@MacBook-Air-Kostin Docker_hm % docker compose up -d
[+] up 2/2
 ✔ Network docker_hm_default Created                                                                                                                                                     0.0s
 ✔ Container docker_hm-app-1 Started                                                                                                                                                     0.2s
Konstantin@MacBook-Air-Kostin Docker_hm % curl http://127.0.0.1:8000/
{"greeting": "Hello from Konstantin", "count": 2, "hostname": "8eefc0a5d82e", "storage": "sqlite"}%                                                                                          
Konstantin@MacBook-Air-Kostin Docker_hm % 
```

- сначала просто запустил контейнер, пару раз добавил 1, удалил, снова запустил и проверил текцщее значение


### N3

приписал проверку работоспособности app и redis:
```
 ✔ Image redis:7.4-alpine      Pulled                                                                                                                                                    8.6s
 ✔ Image docker_hm-app         Built                                                                                                                                                     2.8s
 ✔ Volume docker_hm_redis-data Created                                                                                                                                                   0.0s
 ✔ Container docker_hm-redis-1 Healthy                                                                                                                                                   9.3s
 ✔ Container docker_hm-app-1   Healthy                                                                                                                                                  14.1s
Konstantin@MacBook-Air-Kostin Docker_hm % docker compose ps
NAME                IMAGE              COMMAND                  SERVICE   CREATED          STATUS                    PORTS
docker_hm-app-1     docker_hm-app      "python -u app.py"       app       18 seconds ago   Up 9 seconds (healthy)    127.0.0.1:8000->8000/tcp
docker_hm-redis-1   redis:7.4-alpine   "docker-entrypoint.s…"   redis     18 seconds ago   Up 15 seconds (healthy)   6379/tcp
Konstantin@MacBook-Air-Kostin Docker_hm % 
```


сохранение значения счетчика в redis работает исправно:
```
Konstantin@MacBook-Air-Kostin Docker_hm % curl http://127.0.0.1:8000/
{"greeting": "Hello from Konstantin", "count": 0, "hostname": "6ecdc36684b9", "storage": "redis"}%                                                                                           
Konstantin@MacBook-Air-Kostin Docker_hm % curl -X POST http://127.0.0.1:8000/increment
curl -X POST http://127.0.0.1:8000/increment
curl http://127.0.0.1:8000/
{"greeting": "Hello from Konstantin", "count": 1, "hostname": "6ecdc36684b9", "storage": "redis"}{"greeting": "Hello from Konstantin", "count": 2, "hostname": "6ecdc36684b9", "storage": "redis"}{"greeting": "Hello from Konstantin", "count": 2, "hostname": "6ecdc36684b9", "storage": "redis"}%                                                                                      
Konstantin@MacBook-Air-Kostin Docker_hm % docker compose down
docker compose up -d --wait
[+] down 3/3
 ✔ Container docker_hm-app-1   Removed                                                                                                                                                   3.2s
 ✔ Container docker_hm-redis-1 Removed                                                                                                                                                   0.2s
 ✔ Network docker_hm_default   Removed                                                                                                                                                   0.1s
[+] up 3/3
 ✔ Network docker_hm_default   Created                                                                                                                                                   0.0s
 ✔ Container docker_hm-redis-1 Healthy                                                                                                                                                   5.9s
 ✔ Container docker_hm-app-1   Healthy                                                                                                                                                  10.3s
Konstantin@MacBook-Air-Kostin Docker_hm % curl http://127.0.0.1:8000/
{"greeting": "Hello from Konstantin", "count": 2, "hostname": "943a73d1083e", "storage": "redis"}%                                                                                           
```

хранение данных app подвязано к redis. перед проверкой останавливаем его:

```bash
docker compose stop redis
```

ответы без redis:
```
Konstantin@MacBook-Air-Kostin Docker_hm % curl -i http://127.0.0.1:8000/healthz
curl -i http://127.0.0.1:8000/readyz
curl -i -X POST http://127.0.0.1:8000/increment
HTTP/1.0 200 OK
Server: BaseHTTP/0.6 Python/3.13.18
Date: Sun, 15 Nov 2026 20:07:41 GMT
Content-Type: application/json; charset=utf-8
Content-Length: 19
Cache-Control: no-store

{"status": "alive"}HTTP/1.0 503 Service Unavailable
Server: BaseHTTP/0.6 Python/3.13.18
Date: Sun, 15 Nov 2026 20:07:41 GMT
Content-Type: application/json; charset=utf-8
Content-Length: 32
Cache-Control: no-store

{"error": "storage_unavailable"}HTTP/1.0 503 Service Unavailable
Server: BaseHTTP/0.6 Python/3.13.18
Date: Sun, 15 Nov 2026 20:07:41 GMT
Content-Type: application/json; charset=utf-8
Content-Length: 32
Cache-Control: no-store

{"error": "storage_unavailable"}%                                                                                                                                                            
Konstantin@MacBook-Air-Kostin Docker_hm % docker compose start redis
docker compose ps
[+] start 1/1
 ✔ Container docker_hm-redis-1 Started                                                                                                                                                   0.1s
NAME                IMAGE              COMMAND                  SERVICE   CREATED         STATUS                                     PORTS
docker_hm-app-1     docker_hm-app      "python -u app.py"       app       7 minutes ago   Up 7 minutes (unhealthy)                   127.0.0.1:8000->8000/tcp
docker_hm-redis-1   redis:7.4-alpine   "docker-entrypoint.s…"   redis     7 minutes ago   Up Less than a second (health: starting)   6379/tcp
Konstantin@MacBook-Air-Kostin Docker_hm % curl http://127.0.0.1:8000/
curl -X POST http://127.0.0.1:8000/increment
{"greeting": "Hello from Konstantin", "count": 2, "hostname": "943a73d1083e", "storage": "redis"}{"greeting": "Hello from Konstantin", "count": 3, "hostname": "943a73d1083e", "storage": "redis"}% 
```


### N4

добавил ограничения для app: не root (10001), файловая система только для чтения, память 256 MiB и cpu 1.

проверка запускается из папки проекта:
```
./scripts/check.sh
```

нужны docker с compose и curl. питон для разбора ответов запускается внутри контейнера.

скрипт создает отдельный проект с пустым volume, проверяет счетчик 0, увеличивает до 3, пересоздает только app и проверяет, что осталось 3. потом вырубает redis: healthz дает 200, readyz и increment дают 503. после запуска redis значение опять 3, следующий increment дает 4. app при этом не перезапускается.

потом останавливает app и redis и сохраняет весь /data в tar, со структурой и правами. архив остается в backups, в гит эта папка не идет. в конце через trap удаляется только тестовый проект вместе с его volume. запросы ограничены 5 секундами, ожидание готовности 90. если что-то не прошло, скрипт пишет этап и выходит с ошибкой.

два запуска подряд прошли, оба PASS. полный вывод тут:

[первый запуск](reports/check-run-1.log)

[второй запуск](reports/check-run-2.log)

Условие дз доступно по [ссылке](https://github.com/Nikfilk2030/missing_semester_hse_cs/blob/main/2026/amcs/year_1/hw_3/README.md)
