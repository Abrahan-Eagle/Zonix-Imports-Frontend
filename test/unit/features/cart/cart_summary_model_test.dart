import 'package:flutter_test/flutter_test.dart';
import 'package:zonix/features/cart/data/models/cart_summary_model.dart';

void main() {
  group('CartSummaryModel', () {
    test('fromJson crea modelo correctamente', () {
      final json = {
        'items_count': 3,
        'subtotal': '125.50',
        'shipping': '10.00',
        'discount': '5.00',
        'total': '130.50',
      };

      final summary = CartSummaryModel.fromJson(json);

      expect(summary.itemsCount, 3);
      expect(summary.subtotal, 125.50);
      expect(summary.shipping, 10.00);
      expect(summary.discount, 5.00);
      expect(summary.total, 130.50);
    });

    test('hasDiscount retorna true cuando hay descuento', () {
      final summary = CartSummaryModel(
        itemsCount: 1,
        subtotal: 100.00,
        shipping: 10.00,
        discount: 5.00,
        total: 105.00,
      );

      expect(summary.hasDiscount, true);
    });

    test('hasDiscount retorna false cuando no hay descuento', () {
      final summary = CartSummaryModel(
        itemsCount: 1,
        subtotal: 100.00,
        shipping: 10.00,
        discount: 0.00,
        total: 110.00,
      );

      expect(summary.hasDiscount, false);
    });

    test('isEmpty retorna true cuando items_count es 0', () {
      final summary = CartSummaryModel(
        itemsCount: 0,
        subtotal: 0,
        shipping: 0,
        discount: 0,
        total: 0,
      );

      expect(summary.isEmpty, true);
    });

    test('totalFormatted retorna string con formato correcto', () {
      final summary = CartSummaryModel(
        itemsCount: 2,
        subtotal: 100.00,
        shipping: 10.50,
        discount: 0,
        total: 110.50,
      );

      expect(summary.totalFormatted, '\$110.50');
    });

    test('subtotalFormatted retorna string con formato correcto', () {
      final summary = CartSummaryModel(
        itemsCount: 2,
        subtotal: 99.99,
        shipping: 10.00,
        discount: 0,
        total: 109.99,
      );

      expect(summary.subtotalFormatted, '\$99.99');
    });

    test('toJson serializa correctamente', () {
      final summary = CartSummaryModel(
        itemsCount: 3,
        subtotal: 125.50,
        shipping: 10.00,
        discount: 5.00,
        total: 130.50,
      );

      final json = summary.toJson();

      expect(json['items_count'], 3);
      expect(json['subtotal'], 125.50);
      expect(json['shipping'], 10.00);
      expect(json['discount'], 5.00);
      expect(json['total'], 130.50);
    });
  });
}
