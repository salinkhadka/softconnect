import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';
import 'package:softconnect/features/auth/domain/use_case/user_login_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockUserLoginUsecase extends Mock implements UserLoginUsecase {}

void main() {
  late LoginViewModel loginViewModel;
  late MockUserLoginUsecase mockUserLoginUsecase;

  setUp(() {
    mockUserLoginUsecase = MockUserLoginUsecase();
    loginViewModel = LoginViewModel(userLoginUsecase: mockUserLoginUsecase);
  });

  blocTest<LoginViewModel, dynamic>(
    'emits nothing but initial state',
    build: () => loginViewModel,
    act: (_) {},
    expect: () => [],
  );
}
