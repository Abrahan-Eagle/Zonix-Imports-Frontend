import 'package:flutter_test/flutter_test.dart';
import 'package:zonix/features/payments/data/models/payment_model.dart';

void main() {
  group('PaymentModel', () {
    test('debe crear un PaymentModel desde JSON', () {
      final json = {
        'id': 1,
        'order_id': 100,
        'method': 'stripe',
        'amount': 150.50,
        'status': 'succeeded',
        'reference': 'pi_test_123',
        'external_id': 'pi_ext_123',
        'currency': 'USD',
        'processed_at': '2025-10-16T12:00:00Z',
        'created_at': '2025-10-16T10:00:00Z',
      };

      final payment = PaymentModel.fromJson(json);

      expect(payment.id, 1);
      expect(payment.orderId, 100);
      expect(payment.method, 'stripe');
      expect(payment.amount, 150.50);
      expect(payment.status, 'succeeded');
      expect(payment.reference, 'pi_test_123');
      expect(payment.currency, 'USD');
    });

    test('debe convertir PaymentModel a JSON', () {
      final payment = PaymentModel(
        id: 1,
        orderId: 100,
        method: 'paypal',
        amount: 200.00,
        status: 'pending',
        currency: 'USD',
        createdAt: DateTime(2025, 10, 16),
      );

      final json = payment.toJson();

      expect(json['id'], 1);
      expect(json['method'], 'paypal');
      expect(json['amount'], 200.00);
      expect(json['status'], 'pending');
    });

    test('debe retornar statusLabel correcto', () {
      final pending = PaymentModel(
        id: 1,
        orderId: 1,
        method: 'stripe',
        amount: 100,
        status: 'pending',
        currency: 'USD',
        createdAt: DateTime.now(),
      );

      final succeeded = PaymentModel(
        id: 2,
        orderId: 2,
        method: 'paypal',
        amount: 100,
        status: 'succeeded',
        currency: 'USD',
        createdAt: DateTime.now(),
      );

      expect(pending.statusLabel, 'Pendiente');
      expect(succeeded.statusLabel, 'Exitoso');
    });

    test('debe retornar methodLabel correcto', () {
      final stripe = PaymentModel(
        id: 1,
        orderId: 1,
        method: 'stripe',
        amount: 100,
        status: 'pending',
        currency: 'USD',
        createdAt: DateTime.now(),
      );

      final pagoMovil = PaymentModel(
        id: 2,
        orderId: 2,
        method: 'pago_movil',
        amount: 100,
        status: 'pending',
        currency: 'USD',
        createdAt: DateTime.now(),
      );

      expect(stripe.methodLabel, 'Tarjeta');
      expect(pagoMovil.methodLabel, 'Pago Móvil');
    });

    test('debe formatear amount correctamente', () {
      final payment = PaymentModel(
        id: 1,
        orderId: 1,
        method: 'stripe',
        amount: 150.50,
        status: 'pending',
        currency: 'USD',
        createdAt: DateTime.now(),
      );

      expect(payment.amountFormatted, '\$150.50');
    });

    test('debe identificar si es pago manual', () {
      final pagoMovil = PaymentModel(
        id: 1,
        orderId: 1,
        method: 'pago_movil',
        amount: 100,
        status: 'pending',
        currency: 'USD',
        createdAt: DateTime.now(),
      );

      final stripe = PaymentModel(
        id: 2,
        orderId: 2,
        method: 'stripe',
        amount: 100,
        status: 'pending',
        currency: 'USD',
        createdAt: DateTime.now(),
      );

      expect(pagoMovil.isManual, true);
      expect(stripe.isManual, false);
    });
  });
}

