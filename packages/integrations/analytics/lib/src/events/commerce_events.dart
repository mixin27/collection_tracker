import 'package:app_analytics/src/core/analytics_event.dart';

/// E-commerce events
class CommerceEvents {
  /// Product viewed
  static AnalyticsEvent productViewed({
    required String productId,
    required String productName,
    String? category,
    double? price,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'product_viewed',
      category: 'commerce',
      properties: {
        'product_id': productId,
        'product_name': productName,
        if (category != null) 'category': category,
        if (price != null) 'price': price,
        ...?properties,
      },
    );
  }

  /// Purchase completed
  static AnalyticsEvent purchaseCompleted({
    required String orderId,
    required double revenue,
    String? currency,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'purchase_completed',
      category: 'commerce',
      value: revenue,
      currency: currency ?? 'USD',
      properties: {
        'order_id': orderId,
        'revenue': revenue,
        'currency': currency ?? 'USD',
        ...?properties,
      },
    );
  }

  /// Subscription started
  static AnalyticsEvent subscriptionStarted({
    required String planId,
    required String planName,
    required double price,
    String? currency,
    String? billingPeriod,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'subscription_started',
      category: 'commerce',
      value: price,
      currency: currency ?? 'USD',
      properties: {
        'plan_id': planId,
        'plan_name': planName,
        'price': price,
        'currency': currency ?? 'USD',
        if (billingPeriod != null) 'billing_period': billingPeriod,
        ...?properties,
      },
    );
  }
}
