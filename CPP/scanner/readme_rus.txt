﻿=============== ОПИСАНИЕ ===============

Пример демонстрирует:
1. Использование ООП
2. Применение шаблонов проектирования
3. Работа с библиотеками boost (1.52) и stl
4. Применение WinApi
5. Многопоточное программирование

=============== ЗАВИСИМОСТИ + ОГРАНИЧЕНИЯ ===============
1. Библиотека Boost
2. libboost_thread-vc100-mt-gd-1_52.lib
3. Максимум потоков = [количество ядер процессора] х [ThreadsPerKernel( = 10, объявлено в cThreadPool.cpp)]

=============== ДЕТАЛИЗАЦИЯ ===============
1. cTaskGenerator - создаёт заданное количество случайных задач и запускает их в cThreadPool
2. cThreadPool - пул потоков. Постоянно сканирует очередь задач и запускает новые задачи. 
3. cThreadPool - создаёт либо новые потоки, либо назначает новую задачу на приостановленный поток
4. cTask - абстрактная задача, выполняемая в потоке. 
5. cTaskParams - общие параметры для задач, включающие в том числе callback функцию