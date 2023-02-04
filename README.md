# PythonDev
## Первый спринт
<details>
  <summary><b>1. Ближайший ноль (<a href="https://github.com/DmitryMogilnikov/PythonDev/blob/master/Homework_1/nearest_zero.py">nearest_zero.py</a>)</b></summary>
  
Тимофей ищет место, чтобы построить себе дом. Улица, на которой он хочет жить, имеет длину n, то есть состоит из n одинаковых идущих подряд участков.     Каждый участок либо пустой, либо на нём уже построен дом.

Общительный Тимофей не хочет жить далеко от других людей на этой улице. Поэтому ему важно для каждого участка знать расстояние до ближайшего пустого участка. Если участок пустой, эта величина будет равна нулю — расстояние до самого себя.

Помогите Тимофею посчитать искомые расстояния. Для этого у вас есть карта улицы. Дома в городе Тимофея нумеровались в том порядке, в котором строились, поэтому их номера на карте никак не упорядочены. Пустые участки обозначены нулями.
</details>

<details>
  <summary><b>2. Ловкость рук (<a href="https://github.com/DmitryMogilnikov/PythonDev/blob/master/Homework_1/sleight_of_hand.py">sleight_of_hand.py</a>)</b></summary>
  
Игра «Тренажёр для скоростной печати» представляет собой поле из клавиш 4x4. В нём на каждом раунде появляется конфигурация цифр и точек. На клавише написана либо точка, либо цифра от 1 до 9.

В момент времени t игрок должен одновременно нажать на все клавиши, на которых написана цифра t. Гоша и Тимофей могут нажать в один момент времени на k клавиш каждый. Если в момент времени t нажаты все нужные клавиши, то игроки получают 1 балл.

Найдите число баллов, которое смогут заработать Гоша и Тимофей, если будут нажимать на клавиши вдвоём.
</details>



## Второй спринт
<details>
  <summary><b>1. Правильные скобочные последовательности (<a href="https://github.com/DmitryMogilnikov/PythonDev/blob/master/Homework_2/correct_bracket_sequences.py">correct_bracket_sequences.py</a>)</b></summary>
  
Необходимо реализовать функцию, генерирующую скобочную последовательность, в зависимости от входного параметра ( n = 0…10 )

Правило генерации следующее:
- “(” должна идти раньше “)”
- Длина последовательности 2n
- Необходимо выполнить перебор всевозможных вариантов в лексикографическом порядке
</details>

<details>
  <summary><b>2. Составить самое большое число (<a href="https://github.com/DmitryMogilnikov/PythonDev/blob/master/Homework_2/largest_number.py">largest_number.py</a>)</b></summary>
  
Необходимо составить наибольшее число из числа предложенных.

На вход поступает два параметра:
- количество чисел n ≤ 100
- строка с n числами, записанными через пробел. Каждое отдельное число не превосходит 1000
</details>



## Третий спринт
<details>
  <summary><b>1. Двоичная система счисления (<a href="https://github.com/DmitryMogilnikov/PythonDev/blob/master/Homework_3/src/binary_number_system.py">binary_number_system.py </a>)</b></summary>
  
Реализуйте функцию, которая переводит число из десятичной системы счисленияв двоичную. Встроенные методы языка программирования использовать нельзя!
</details>

<details>
  <summary><b>2. Палиндром (<a href="https://github.com/DmitryMogilnikov/PythonDev/blob/master/Homework_3/src/palindrome.py">palindrome.py</a>)</b></summary>
  
Определите, является ли строка палиндромом. Учитываются только буквы и цифры, заглавные и строчные буквы считаются одинаковыми.Буквы могут быть только латинские. Фраза может состоять из строчных и прописных латинских букв, цифр, знаков препинания.

Функция возвращает True, если фраза является палиндромом, иначе - False
</details>



## PostgreSQL
<details>
  <summary><b>1. Создание схемы (<a href="https://github.com/DmitryMogilnikov/PythonDev/blob/master/PostgreSQL/01.%20create_schema.sql">01. create_schema.sql</a>)</b></summary>
  
Создать в своей тестовой базе данных схему «tag_data». Создать в схеме «tag_data» структуру таблиц для хранения данных, представленных в файле «ДЗ №1.xlsx»
</details>

<details>
  <summary><b>2. Наполнение таблиц (<a href="https://github.com/DmitryMogilnikov/PythonDev/blob/master/PostgreSQL/02.%20filling_tables.sql">02. filling_tables.sql</a>)</b></summary>
  
Необходимо загрузить из файла данные в ранее подготовленные таблицы. Написать запрос, который вернет из ваших таблиц данные в исходном виде (как в файле)
</details>

<details>
  <summary><b>3. Views, joins, unions (<a href="https://github.com/DmitryMogilnikov/PythonDev/blob/master/PostgreSQL/03.%20views%2C%20joins%2C%20unions.sql">03. views, joins, unions.sql</a>)</b></summary>
  
### Задача №1.
Создать представление в схеме public с использованием JOIN:
Условия выборки в представлении:
- Город вылета Москва или Санкт-Петербург
- Время вылета – первая половина дня (до 12:00)

### Задача №2.
Создать VIEW в схеме public с использованием JOIN и UNION, которое вернет следующие поля из таблиц в схеме «tag_data»:
- Имя тега
- Единица измерения
- Дата и время значения
- Значение тега
Условия выборки в представлении:
- Выберите по 10 последних значений по любым трем тегам
- Объедините выборки по каждому тегу через UNION

### Задача №3.
Создать две таблицы в схеме public с одним полем «название языка программирования». Заполнить обе таблицы произвольным набором языков. Отобразить в запросах что у обоих таблиц общее и чем они отличаются.
</details>

<details>
  <summary><b>4. Group by, with, recursive (<a href="https://github.com/DmitryMogilnikov/PythonDev/blob/master/PostgreSQL/04.%20group%20by%2C%20with.sql">04. group by, with.sql</a>)</b></summary>
  
### Задача №1.
- Напишите запрос к таблицам в схеме «booking», который вернет суммарное количество рейсов (перелетов) по каждому типу самолета, посуточно за январь 2017 года.
- Напишите запрос из таблиц в схеме «booking» который вернет общую сумму бронирований и среднее значение бронирований посуточно за январь 2017 года.

### Задача №2.
- Выполнить в своей тестовой базе данных скрипт script.sql. Используя рекурсивный запрос WITH RECURSIVE, посчитать сколько у каждого человека сотрудников в подчинении.
- Задача со * посчитать сколько у каждого человека сотрудников в подчинении, и непосредственных, и косвенных. Т.е. у гендира в непосредственном подчинении четыре зама, а в косвенном подчинении все сотрудники компании, кроме
него самого.
</details>
