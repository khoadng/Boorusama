// Package imports:
import 'package:purchases_flutter/purchases_flutter.dart';

// Project imports:
import '../../iap/iap.dart' as i;

i.Package mapRevenuecatPackageToPackage(Package package) {
  return i.Package(
    id: package.identifier,
    product: mapRevenuecatProductToProductDetails(package.storeProduct),
    type: mapRevenuecatPackageTypeToPackageType(package.packageType),
  );
}

i.ProductDetails mapRevenuecatProductToProductDetails(StoreProduct product) {
  return i.ProductDetails(
    id: product.identifier,
    title: product.title,
    description: product.description,
    price: product.priceString,
    currencyCode: product.currencyCode,
    rawPrice: product.price,
  );
}

i.PackageType mapRevenuecatPackageTypeToPackageType(PackageType type) =>
    switch (type) {
      PackageType.unknown => i.PackageType.annual,
      PackageType.custom => i.PackageType.annual,
      PackageType.lifetime => i.PackageType.annual,
      PackageType.annual => i.PackageType.annual,
      PackageType.sixMonth => i.PackageType.monthly,
      PackageType.threeMonth => i.PackageType.monthly,
      PackageType.twoMonth => i.PackageType.monthly,
      PackageType.monthly => i.PackageType.monthly,
      PackageType.weekly => i.PackageType.monthly,
    };
