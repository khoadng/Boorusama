// Package imports:
import 'package:equatable/equatable.dart';

enum PackageType {
  monthly,
  annual,
}

extension PackageX on Package {
  String get typeDurationString => switch (type) {
        PackageType.monthly => 'month',
        PackageType.annual => 'year',
        null => '',
      };

  double get annualPrice => switch (type) {
        PackageType.annual => product.rawPrice,
        PackageType.monthly => product.rawPrice * 12,
        null => 0,
      };

  Package withDealFrom(Package? other) => switch (other) {
        null => this,
        final Package p => copyWith(
            deal: () => _compareWith(p),
          ),
      };

  DealData? _compareWith(Package other) {
    if (type != PackageType.monthly) {
      final savingsPercent = 1 - (annualPrice / other.annualPrice);

      return DealData(
        from: other.product.id,
        to: product.id,
        savings: savingsPercent,
      );
    }

    return null;
  }
}

class DealData extends Equatable {
  const DealData({
    required this.from,
    required this.to,
    required this.savings,
  });

  final String from;
  final String to;
  final double savings;

  @override
  List<Object> get props => [
        from,
        to,
        savings,
      ];
}

class Package extends Equatable {
  const Package({
    required this.id,
    required this.product,
    required this.type,
    this.bestValue,
  });

  final String id;
  final ProductDetails product;
  final PackageType? type;
  final DealData? bestValue;

  Package copyWith({
    DealData? Function()? deal,
  }) {
    return Package(
      bestValue: deal != null ? deal() : bestValue,
      id: id,
      product: product,
      type: type,
    );
  }

  @override
  List<Object?> get props => [
        id,
        product,
        type,
        bestValue,
      ];
}

class Offering extends Equatable {
  const Offering({
    required this.id,
    required this.availablePackages,
  });

  final String id;
  final List<ProductDetails> availablePackages;

  @override
  List<Object> get props => [
        id,
        availablePackages,
      ];
}

abstract class InAppPurchase {
  Future<bool?> restorePurchases();
  Future<List<Package>> getAvailablePackages();
  Future<bool> purchasePackage(Package package);

  String? describePurchaseError(Object error);
}

class ProductDetails extends Equatable {
  const ProductDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rawPrice,
    required this.currencyCode,
  });

  final String id;
  final String title;
  final String description;
  final String price;
  final double rawPrice;
  final String currencyCode;

  @override
  List<Object> get props => [
        id,
        title,
        description,
        price,
        rawPrice,
        currencyCode,
      ];
}

// class IAPUtils {
//   static double comparePrice(ProductDetails a, ProductDetails b) {
//     return a.rawPrice - b.rawPrice;
//   }
// }

enum PurchaseStatus {
  pending,
  purchased,
  error,
  restored,
  cancelled,
}

class PurchaseVerificationData extends Equatable {
  const PurchaseVerificationData({
    required this.localVerificationData,
    required this.serverVerificationData,
    required this.source,
  });

  const PurchaseVerificationData.empty()
      : localVerificationData = '',
        serverVerificationData = '',
        source = '';

  final String localVerificationData;
  final String serverVerificationData;
  final String source;

  @override
  List<Object> get props => [
        localVerificationData,
        serverVerificationData,
        source,
      ];
}

class PurchaseDetails extends Equatable {
  const PurchaseDetails({
    required this.productID,
    required this.verificationData,
    required this.status,
    this.purchaseID,
    this.transactionDate,
  });

  final String? purchaseID;
  final String productID;
  final PurchaseVerificationData verificationData;
  final String? transactionDate;
  final PurchaseStatus status;

  @override
  List<Object?> get props => [
        purchaseID,
        productID,
        verificationData,
        transactionDate,
        status,
      ];
}
