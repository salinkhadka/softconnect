import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:softconnect/features/auth/presentation/view/View/login.dart';
// import 'package:softconnect/features/auth/presentation/view/login_screen.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_event.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_state.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';

// Mock Bloc
class MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginViewModel {}

void main() {
  late MockLoginBloc loginBloc;

  setUp(() {
    loginBloc = MockLoginBloc();
    // Default state
    when(() => loginBloc.state).thenReturn(LoginState.initial());
  });

  Widget loadLoginScreen() {
    return BlocProvider<LoginViewModel>.value(
      value: loginBloc,
      child:  MaterialApp(
        home:  LoginScreen(),
      ),
    );
  }

  testWidgets('LoginScreen shows Login button', (WidgetTester tester) async {
    await tester.pumpWidget(loadLoginScreen());
    await tester.pumpAndSettle();

    final loginButton = find.widgetWithText(ElevatedButton, 'Login');

    expect(loginButton, findsOneWidget);
  });
}
