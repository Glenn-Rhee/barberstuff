import 'package:mobile_barberstuff/features/promo/data/repositories/promo_repository_impl.dart';
import 'package:mobile_barberstuff/features/promo/domain/repositories/promo_repository.dart';
import 'package:mobile_barberstuff/features/promo/domain/usecases/get_promo_content.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Rakitan fitur promo: repository → use case.
List<SingleChildWidget> promoProviders() => <SingleChildWidget>[
  Provider<PromoRepository>(create: (_) => const PromoRepositoryImpl()),
  Provider<GetPromoContent>(
    create: (ctx) => GetPromoContent(ctx.read<PromoRepository>()),
  ),
];
