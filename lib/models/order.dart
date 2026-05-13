enum OrderType { buy, sell }

enum OrderStatus { pending, filled, cancelled }

class Order {
  final String id;
  final String code;
  final String name;
  final OrderType type;
  final double price;
  final int quantity;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createTime;
  final String market;

  const Order({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.price,
    required this.quantity,
    required this.totalAmount,
    required this.status,
    required this.createTime,
    required this.market,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'type': type.name,
        'price': price,
        'quantity': quantity,
        'totalAmount': totalAmount,
        'status': status.name,
        'createTime': createTime.toIso8601String(),
        'market': market,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        code: json['code'],
        name: json['name'],
        type: OrderType.values.firstWhere((e) => e.name == json['type']),
        price: json['price'],
        quantity: json['quantity'],
        totalAmount: json['totalAmount'],
        status: OrderStatus.values.firstWhere((e) => e.name == json['status']),
        createTime: DateTime.parse(json['createTime']),
        market: json['market'],
      );
}
