import 'dart:math';



class User {
  int id;
  String name;
  String email;

  User(this.id, this.name, this.email);

  @override
  String toString() => 'Користувач #$id: $name ($email)';
}

class Product {
  int id;
  String title;
  double price;

  Product(this.id, this.title, this.price);

  @override
  String toString() => '#$id $title - $price \$';
}

class Order {
  int id;
  String date;
  double total;

  Order(this.id, this.date, this.total);

  @override
  String toString() => 'Замовлення #$id від $date на суму $total \$';
}


final _random = Random();

void _maybeFail(String operation) {
  if (_random.nextDouble() < 0.2) {
    throw Exception('Помилка мережі під час завантаження: $operation');
  }
}

//асинхрон

Future<User> getUser() async {
  await Future.delayed(const Duration(seconds: 2));
  _maybeFail('користувач');
  return User(1, 'Danil', 'danil@gmail.com');
}

Future<List<Product>> getProducts() async {
  await Future.delayed(const Duration(seconds: 3));
  _maybeFail('товари');
  return [
    Product(1, 'Ноутбук', 1299.99),
    Product(2, 'Навушники', 89.50),
    Product(3, 'Клавіатура', 49.90),
  ];
}

Future<List<Order>> getOrders() async {
  await Future.delayed(const Duration(seconds: 2));
  _maybeFail('замовлення');
  return [
    Order(101, '2026-10-12', 1349.89),
    Order(102, '2026-11-03', 89.50),
  ];
}

String _seconds(Stopwatch sw) =>
    (sw.elapsedMilliseconds / 1000).toStringAsFixed(1);

// послідовне

Future<void> loadSequentially() async {
  print('Послідовне завантаження');
  final stopwatch = Stopwatch()..start();

  final user = await getUser();
  print('Отримано: $user');
  final products = await getProducts();
  print('Отримано товарів: ${products.length}');
  final orders = await getOrders();
  print('Отримано замовлень: ${orders.length}');

  stopwatch.stop();
  print('Час послідовного виконання: ${_seconds(stopwatch)} с\n');
}

// паралельне

Future<void> loadInParallel() async {
  print('Паралельне завантаження (Future.wait)');
  final stopwatch = Stopwatch()..start();

  final results = await Future.wait([
    getUser(),
    getProducts(),
    getOrders(),
  ]);

  final user = results[0] as User;
  final products = results[1] as List<Product>;
  final orders = results[2] as List<Order>;

  print(user);
  print('Товари:');
  for (final p in products) {
    print('  $p');
  }
  print('Замовлення:');
  for (final o in orders) {
    print('  $o');
  }

  stopwatch.stop();
  print('Час паралельного виконання: ${_seconds(stopwatch)} с\n');
}



Future<void> main() async {
  try {
    await loadSequentially();
    await loadInParallel();
  } on Exception catch (e) {
    print('Помилка: $e');
  } finally {
    print('Готово.');
  }
}