import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CartScreen(),
    ),
  );
}

class CartItem {
  final String id;
  final String name;
  final String subtitle;
  final double price;
  final IconData icon;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.icon,
    this.quantity = 1,
  });
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<CartItem> _cartItems = [
    CartItem(
      id: '1',
      name: 'Wireless Headphones',
      subtitle: 'Noise Cancelling • Black',
      price: 129.99,
      icon: Icons.headphones,
      quantity: 1,
    ),
    CartItem(
      id: '2',
      name: 'Mechanical Keyboard',
      subtitle: 'RGB Backlit • Tactile',
      price: 89.50,
      icon: Icons.keyboard,
      quantity: 2,
    ),
    CartItem(
      id: '3',
      name: 'USB-C Fast Charger',
      subtitle: '65W GaN Adapter',
      price: 34.00,
      icon: Icons.power,
      quantity: 1,
    ),
  ];

  double get _subtotal =>
      _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  double get _shipping => _cartItems.isEmpty ? 0.0 : 5.99;

  double get _total => _subtotal + _shipping;

  void _incrementQuantity(int index) {
    setState(() {
      _cartItems[index].quantity++;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _removeItem(index);
      }
    });
  }

  void _removeItem(int index) {
    final removedItem = _cartItems[index];
    setState(() {
      _cartItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removedItem.name} removed from cart'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _cartItems.insert(index, removedItem);
            });
          },
        ),
      ),
    );
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        centerTitle: true,
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear Cart',
              onPressed: _clearCart,
            ),
        ],
      ),
      body: _cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildCartItemCard(_cartItems[index], index);
                    },
                  ),
                ),
                _buildCheckoutSection(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like you have not added anything to your cart yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item, int index) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.icon,
                size: 32,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => _decrementQuantity(index),
                  icon: const Icon(Icons.remove_circle_outline),
                  visualDensity: VisualDensity.compact,
                ),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                IconButton(
                  onPressed: () => _incrementQuantity(index),
                  icon: const Icon(Icons.add_circle_outline),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPriceRow('Subtotal', _subtotal),
            const SizedBox(height: 8),
            _buildPriceRow('Shipping', _shipping),
            const Divider(height: 24),
            _buildPriceRow('Total', _total, isTotal: true),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Proceeding to checkout (\$${_total.toStringAsFixed(2)})',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    final style = TextStyle(
      fontSize: isTotal ? 18 : 14,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      color: isTotal ? null : Colors.grey.shade700,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('\$${amount.toStringAsFixed(2)}', style: style),
      ],
    );
  }
}
