import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:get_it/get_it.dart';

import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_auth_stream_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/domain/usecases/verify_otp_usecase.dart';
import 'features/auth/domain/usecases/verify_phone_number_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ! Features - Auth
  // Provider
  sl.registerFactory(
    () => AuthProvider(
      verifyPhoneNumberUseCase: sl(),
      verifyOTPUseCase: sl(),
      signOutUseCase: sl(),
      getAuthStreamUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => VerifyPhoneNumberUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOTPUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetAuthStreamUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );

  // ! External
  final firebaseAuth = FirebaseAuth.instance;
  sl.registerLazySingleton(() => firebaseAuth);
}
