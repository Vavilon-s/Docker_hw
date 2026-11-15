## Выполнение ДЗ


### N1
Команда сборки — docker build -t hm:1 .
Команда запуска — та, где указаны порт и GREETING='Hello from Konstantin'
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







Условие дз доступно по [ссылке](https://github.com/Nikfilk2030/missing_semester_hse_cs/blob/main/2026/amcs/year_1/hw_3/README.md)
