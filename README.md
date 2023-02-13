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

Далее, нужно создать модель User. Сначала создается класс с соответствующим названием, но расширяется он от контекста бд - ManagedObject. Поля прописываются в другом классе - User с нижним подчеркиванием. Пользователь имеет: ID (аннотация Primary key, указывающая первичный ключ), имя (имеет аннотацию Column, где указывается уникальность, индекс), почта, пароль (имеет разрешение только на запись), токен, токен для обновления, соль, хэшированный пароль, активность (забанен ли). Помимо этого, с помощью ManagedSet устанавливается зависимость - получение списка всех действий пользователя. 

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic5.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 5 - Создание модели User </p>

Необходима так же модель заметки. Заметка имеет ID, наименование, содержание, дату создания и дату обновления (имеют встроенный в Dart тип Date). Помимо этого, каждая заметка имеет Автора и категорию. Так как эти параметры идут внешним ключом, устанавливается аннотация Relate, которая содержит: название поля в модели первичного ключа, обязательна ли и одно из правил удаления. 

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic6.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 6 - Создание модели Post </p>

Затем создается модель History - содержит в себе тип действия, дату воспроизведения действия и ID пользователя, который это действие совершил. 

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic7.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 7 - Создание модели History </p>

Категория хранит в себе название и список заметок, которые к ней относятся. А так же автора - таким образом, каждый пользователь сможет создавать свои категории и добавлять в них заметки.

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic8.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 8 - Создание модели Category </p>

Модель Author имеет ID, список заметок и категорий. 

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic9.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 9 - Создание модели Author </p>

Пришло время создания контроллеров, которые нужны для обработки логики запросов и возвращения каких-либо ответов на них. Прежде всего необходимо создать в папке bin папку Controllers, в которую нужно добавить файл app_user_controller.dart. В файле создается класс, который расширяется от ResourceController. Объявляется экземпляр контекста для взаимодействия с БД, инициализируется через конструктор. 

Далее идет создание первого метода. Аннотация Operation позволяет указать тип запроса - в данном случае GET. Метод getProfile асинхронный, возвращает Response. С помощью аннотации @Bind.header можно привязать данные из Header'а запроса - а именно из того, что связан с авторизацией. Таким образом, данные из заголовка перейдут в переменную header. 

Для получения данных о пользователе, нужно сначала получить его Id.




