import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/asset/asset_loader_service.dart';
import 'package:ssurade_application/ssurade_application.dart';

@Singleton(as: AgreementRetrievalPort)
class AgreementRetrievalService implements AgreementRetrievalPort {
  final AssetLoaderService _assetLoaderService;

  AgreementRetrievalService({
    required AssetLoaderService assetLoaderService,
  }) : _assetLoaderService = assetLoaderService;

  @override
  Future<String> getShortAgreement() {
    return _assetLoaderService.loadAsset('agreement/agreement_short.txt');
  }

  @override
  Future<String> getLongAgreement() {
    return _assetLoaderService.loadAsset('agreement/agreement.txt');
  }
}
