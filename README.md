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




Условие дз доступно по [ссылке](https://github.com/Nikfilk2030/missing_semester_hse_cs/blob/main/2026/amcs/year_1/hw_3/README.md)
