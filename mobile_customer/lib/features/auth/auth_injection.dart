import 'package:mobile_barberstuff/core/network/dio_client.dart';
import 'package:mobile_barberstuff/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile_barberstuff/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_barberstuff/features/auth/domain/usecases/complete_google_registration.dart';
import 'package:mobile_barberstuff/features/auth/domain/usecases/login_with_email.dart';
import 'package:mobile_barberstuff/features/auth/domain/usecases/register_account.dart';
import 'package:mobile_barberstuff/features/auth/domain/usecases/request_password_reset.dart';
import 'package:mobile_barberstuff/features/auth/domain/usecases/reset_password.dart';
import 'package:mobile_barberstuff/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:mobile_barberstuff/features/auth/domain/usecases/verify_otp.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Rakitan fitur auth. Butuh [DioClient] sudah terpasang di atasnya.
List<SingleChildWidget> authProviders() => <SingleChildWidget>[
  Provider<AuthRemoteDataSource>(
    create: (ctx) => AuthRemoteDataSource(ctx.read<DioClient>().dio),
  ),
  Provider<AuthRepository>(
    create: (ctx) => AuthRepositoryImpl(ctx.read<AuthRemoteDataSource>()),
  ),
  ...authUseCases(),
];

/// Use case saja, supaya tes bisa memasang [AuthRepository] sendiri.
List<SingleChildWidget> authUseCases() => <SingleChildWidget>[
  Provider<RegisterAccount>(
    create: (ctx) => RegisterAccount(ctx.read<AuthRepository>()),
  ),
  Provider<VerifyOtp>(create: (ctx) => VerifyOtp(ctx.read<AuthRepository>())),
  Provider<SignInWithGoogle>(
    create: (ctx) => SignInWithGoogle(ctx.read<AuthRepository>()),
  ),
  Provider<CompleteGoogleRegistration>(
    create: (ctx) => CompleteGoogleRegistration(ctx.read<AuthRepository>()),
  ),
  Provider<LoginWithEmail>(
    create: (ctx) => LoginWithEmail(ctx.read<AuthRepository>()),
  ),
  Provider<RequestPasswordReset>(
    create: (ctx) => RequestPasswordReset(ctx.read<AuthRepository>()),
  ),
  Provider<ResetPassword>(
    create: (ctx) => ResetPassword(ctx.read<AuthRepository>()),
  ),
];
