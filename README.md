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

Пришло время создания контроллеров, которые нужны для обработки логики запросов и возвращения каких-либо ответов на них. Прежде всего необходимо создать в папке bin папку Controllers, в которую нужно добавить файл app_auth_controller.dart. В файле создается класс, который расширяется от ResourceController. Объявляется экземпляр контекста для взаимодействия с БД, инициализируется через конструктор.

Первый метод - signIn. Имеет аннотацию @Operation.post, которая говорит о том, что будет использоваться Post-запрос. Метод асинхронный, возвращает Response - ответ. В качестве параметров принимает модель User через @Bind.body, которая заполняется самим пользователем в теле запроса. Прежде всего идет проверка, заполнены ли все поля. Если проверка пройдена, то происходит формирование запроса с помощью конструкции Query<User> (managedContext). С помощью where выделяются только те строчки, где параметр userName соответствует введеному пользователем. Затем, возвращаются значения: id, salt, hashPassword, isActive. 
  
Запрос выполняется асинхронно с помощью метода fetchOne. Далее, производится проверка на Null, блокировку аккаунта. Генерируется хэшированный пароль и сверяется с текущим хэшированным паролем. Если пароли одинаковы, то обновляется токен с помощью метода _updateTokens. 
  
 Затем, с помощью метода fetchObjectWithId происходит получение данных пользователя. Создается запрос на добавление данных в историю действий, где указывается время действия, пользователь и тип действия - авторизация. Возвращается модель - данные пользователя и сообщение об успешной авторизации. 
  
<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic23.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 10 - Авторизация </p>

Второй метод - signUp отвечает за авторизацию. Он принимает модель User в теле запроса и также является асинхронным. Первым делом происходится проверка на null значения какого-либо из полей. Если проверк а пройдена, то генерируется соль, по которой создается хэшированный пароль. Далее, создается запрос на создание пользователя, где через ..values заполняется информация о нем (данные берутся из тела запроса, которое заполнил пользователь). Запрос выполняется в БД с помощью метода insert(). Токен обновляется через метод _updateTokens. Данные об этом действии записываются в историю, происходит получение данных о только что созданном пользователе и эти данные, как и сообщение об успешной регистрации, выводятся в качестве ответа на запрос. 

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic24.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 11 - Регистрация </p>

Метод _updateTokens позволяет обновить JWT-токен пользователя. Данный метод создает запрос на обновление, в котором заменяет поля access, refresh (соотвественно токены) на те, что указаны в параметрах метода. 

Метод getTokens возвращает сам токен. Для начала, в переменную key записывается ключ, по которому должны генерироваться все токены (он берется из переменной среды). Затем создается JWTClaim, который устанавливает время жизни токена и его claim'ы - в данном случае ID (то, что будет храниться в токене). Затем, оба токена генерируется через метод issue.

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic26.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 12 - Update, get tokens </p>

Сам запрос refreshTokens получает через Bind.path рефреш токен и сверяет его с тем, что находится в БД. Если проверка пройдена, то запрос возвращает метод UpdateTokens, описанный выше.

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic25.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 13 - Refresh Token </p>


Теперь можно приступить к созданию контроллера, отвечающего за взаимодействие с данными пользователя.
Далее идет создание первого метода. Аннотация Operation позволяет указать тип запроса - в данном случае GET. Метод getProfile асинхронный, возвращает Response. С помощью аннотации @Bind.header можно привязать данные из Header'а запроса - а именно из того, что связан с авторизацией. Таким образом, данные из заголовка перейдут в переменную header. 

Для получения данных о пользователе, нужно сначала получить его Id. Делается это с помощью заранее прописанного метода класса AppUtils. 
Затем, в переменную User записываются данные о пользователе, полученные с помощью метода fetchObjectWithId. Данный метод возвращает данные из БД определенной модели по указанному ID. 
Из модели убираются данные о токенах и возвращается ответ с выводом данных пользователя. 

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic10.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 14 - getProfile </p>

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic-utils.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 15 - AppUtils </p>

Иногда пользователям нужно обновлять информацию о себе. Для реализации этого, нужно создать метод updateProfile с аннотацией @Operation.post (так как персональные данные должны отправляться через тело запроса). Помимо этого, в параметрах функции указывается аннотация @Bind.body User user, которая говорит о том, что отправленное в тело запроса информация будет записана в модель User. 

По ID находится пользователь, а затем создается запрос через конструкцию Query<User>(managedContext) для обновления данных этого пользователя. С помощью where определяется строка для обновления, а с помощью ..values указываются параметры для обновления и их новое значение. Затем вызывается асинхронное обновление данных в БД с помощью функции updateOne. Полученый пользователь снова выводится в ответе к запросу. 
  
<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic11.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 16 - updateProfile </p>

Реализовано также изменение пароля. Выбран метод Put, потому что производится обновление данных. С помощью @Bind.query переменным присваются значения, которые пользователь укажет в параметрах запроса - новый и старый пароль. 

Затем производится поиск пользователя, но из его данных возвращается информация о соли и хэшированном пароле, так как необходимо хэшировать введенный пароль для проверки со старым по этой соли. 

Создается переменная oldHashPassword, которая хэширует введенный пользователем старый пароль по той же соли, что был создан актуальный пароль. Если пароли совпадают, то генерируется новый хэшированный пароль, по той же соли, что и старый. Затем создается запрос на обновление пароля - тот же самый Update, рассмотренный выше, только из значений изменяется лишь hashPassword. Исполняется запрос на обновление строчки в БД.
  

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic12.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 17 - updatePassword </p>

AppTokenController необходим для того, чтобы получать и сверять JWT-токен в процессе обработки запросов. Для начала, через Header запроса берется сам токен, который проверяется через метод. Затем, токен валидируется и контроллер возвращает запрос пользователя. 

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic13.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 18 - AppTokenController </p>

Следующий контроллер отвечает за логическое удаление и восстановление заметок. Прежде всего необходимо получить ID автора запроса через Header (c помощью парсерса, прописанного в AppUtils). Затем происходят проверки на Null и на то, что автор запроса является также автором заметки, которую собирается добавить в корзину. Если все проверки пройдены, то создается запрос на обновление, в котором через ..values меняется параметр статус с true на false. Запрос выполняется через метод updateOne(). Логическое восстановление происходит по тому же принципу, только тип запроса - PUT, а не DELETE. 

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic14.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 19 - Логическое удаление </p>

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic15.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 20 - Логическое восстановление </p>

Контроллер AppPostController отвечает за все действия, связанные с заметками. Для добавления новой заметки, необходимо в качестве параметров метода принимает модель Post. Затем, по ID нужно найти категорию заметки и автора. Если чего-то из этого нет, то создаются запросы на добавления - автора с пользовательским ID и категории с названием "Новая категория". После этого, создается сама заметка - все ее поля заполняются через ..values, значения которого берутся из тела запроса. 

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic17.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 21 - Добавление заметки </p>

Затем следует метод, с помощью которого пользователь может получить все свои заметки. В параметрах метода указаны значения в {} скобках, что указывает на то, что они необязательны для отправки запроса. В первую очередь, через Bind.query задается переменная Keyword, отвечающая за поиск. Также задаются переменные PageLimit и Skiprows, отвечающие за пагинацию. 

Если ключевое слово для поиска не задано, то создается запрос с ..fetchLimit - для вывода определенного количества значений и offset - смещение (произведение pageLimit и Skiprows). Помимо этого, выбираются только те значения, где автором является автор запроса и сами заметки не добавлены в корзину. 

Через fetch заполняется список со всеми заметками, подходящими под условия описанные выше. Проверяется, что список не пустой и, в зависимости от проверки, выводится результат. 

Если же пользователь указал слово для поиска, то формируется запрос, где важным является ..predicate, который позволяет осуществлять конструкцию OR. В данном случае поиск производится по двум вещам - названию заметки и ее содержанию. Через запрос указывается OR конструкция, которая также позволяет не учитывать регистр для облегчения поиска. 

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic18.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 22 - Вывод заметок </p>


Иногда необходимо просмотреть информацию об одной заметке. Пользователь в запросе должен указать ID. Чтобы считать этот ID заметки, необходимо использовать аннотацию @Bind.path. Затем производится поиск заметки по этому ID, убирается лишняя информация и сама модель выводится в качестве ответа на запрос. 

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic19.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 23 - Вывод заметки </p>

Обновление заметки имеет схожий код с добавлением. Через @Bind.path передается ID заметки для обновления, а через @Bind.body - данные. Создается запрос, который через where определяет строчку для обновлeния, а через ..values заменяет данные на те, что пользователь указал в теле запроса. 

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic20.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 24 - Обновление заметки </p>

Для удаление, необходимо получить ID заметки через @Bind.path. Затем, нужно осуществить проверки на существование заметки и на то, что автор запроса является автором заметки. Если все проверки пройдены, то создается запрос, который выделяет только ту строчку, где соответствует ID. Удаление происходит через функцию delete(). 

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic21.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 25 - Удаление заметки </p>

Контроллер AppHistoryController необходим для вывода всех действий пользователя. Выводятся только те действия, автором которых является автор запроса. 

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic22.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 26 - Вывод истории </p>

Теперь пришло время вернуться к главному файлу, которая располагается в папке bin. В нем объявляется переменная port, которая обозначает порт, по которому будет работать веб-сервер. Затем инициализируется переменная service, которая принимает в качестве параметров port и конфигурационный файл. После этого, сервис запускается через функцию start, с указанным количеством инстанций и включенным консольным логгированием. 

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic27.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 27 - Старт сервера </p>

</br>

<h3> Результат работы </h3>

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic28.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 28 - Регистрация </p>

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic29.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 29 - Авторизация </p>

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic30.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 30 - Обновление токена </p>

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic31.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 31 - Добавление поста </p>

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic32.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 32 - Вывод постов </p>

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic33.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 33 - Изменение поста </p>

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic34.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 34 - Поиск </p>

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic35jpg.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 35 - Логическое удаление </p>

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic36.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 36 - Логическое восстановление </p>

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic37.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 37 - История </p>

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic38.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 38 - Профиль </p>

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic39.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 39 - Изменение профиля </p>

<div align="center"> 
<img src="https://github.com/midnightRanger/Dart-backend/blob/main/images_git/pic40.jpg?raw=true">
</div>
<p color="grey" style="font-size: 12px" align="center"> Рисунок 40 - Изменение пароля </p>

<h3> Заключение <h3>

В ходе практической работы были усвоены принципы работы с фреймворком Conduit, была реализована backend-часть приложения на Dart'e. Развернуто API с системами авторизации и регистрации, которое позволяет манипулировать данными из БД, изменять, удалять, производить логическое удаление и восстановление, осуществлять поиск и пагинацию данных. 