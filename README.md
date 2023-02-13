<h1 align="center"> Практическая работа №1 </h1>
<h3 align="center"> Тема: Создание backend-части с помощью Conduit </h3>
<p> Цель: Изучение принципов работы фреймворка Conduit, разработка backend-части Flutter-приложения по созданию заметок </p>
</br>
<p> №1. Подключение зависимостей </p>
Прежде всего необходимо подключить недостающие зависимости - Conduit, Jaguar JWT. Conduit необходим для работы с БД через ORM, запуска сервера - Backend часть приложения. Jaguar JWT позволяет использовать JWT-токены для средств авторизации. Подключение производится в файле pubspec.yaml. 
<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic1.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 1 - Зависимости </p>

Далее необходимо создать файл database.yaml и заполнить в нем поля, необходимые для подключения к базе данных. 

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic2.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 2 - Database.yaml </p>

Затем нужно создать файл, а в нем класс - AppService. В данном классе производится инициализация подключения к базе данных, инициализируется БД, производится создание контекста для работы с ней. Помимо этого, устанавливается роутинг посредством класса Router() и метода route().
<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic3.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 3 - AppService </p>

Следующим этапом создаются модели. Но перед этим, нужно сначала создать папку models внутри папки bin. В ней нужно сначала создать модель Model_response.dart. Внутри файла создается класс, имеющий поля - ошибка, данные, сообщение. Класс имеет метод, который парсит содержимое модели в Json.

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic4.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 4 - Создание модели Model Response </p>

