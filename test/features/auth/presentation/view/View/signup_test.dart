import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:softconnect/features/auth/presentation/view/View/signup.dart';
// import 'package:softconnect/features/auth/presentation/view/signup_screen.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_event.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_state.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_viewmodel.dart';

// Mock Bloc
class MockSignupBloc extends MockBloc<SignupEvent, SignupState>
    implements SignupViewModel {}

void main() {
  late MockSignupBloc signupBloc;

  setUp(() {
    signupBloc = MockSignupBloc();
    when(() => signupBloc.state).thenReturn(SignupState.initial());
  });

  Widget loadSignupScreen() {
    return BlocProvider<SignupViewModel>.value(
      value: signupBloc,
      child: MaterialApp(
        home: SignupScreen(), // Replace with your actual SignupScreen widget
      ),
    );
  }

  testWidgets('SignupScreen shows Sign Up button', (tester) async {
    await tester.pumpWidget(loadSignupScreen());
    await tester.pumpAndSettle();

    final signupButton = find.widgetWithText(ElevatedButton, 'Signup');

    expect(signupButton, findsOneWidget);
  });
}
