import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:softconnect/app/theme/theme_provider.dart';
import 'package:softconnect/features/auth/presentation/view/View/login.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_event.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_state.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';

// Mock Bloc
class MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginViewModel {}

// Mock ThemeProvider
class MockThemeProvider extends Mock implements ThemeProvider {}

void main() {
  late MockLoginBloc loginBloc;
  late MockThemeProvider themeProvider;

  setUp(() {
    loginBloc = MockLoginBloc();
    themeProvider = MockThemeProvider();

    // Default state
    when(() => loginBloc.state).thenReturn(LoginState.initial());

    // Mock theme provider properties based on your actual ThemeProvider
    when(() => themeProvider.isDarkMode).thenReturn(false);

    // Mock the notifyListeners method since ThemeProvider extends ChangeNotifier
    when(() => themeProvider.addListener(any())).thenReturn(null);
    when(() => themeProvider.removeListener(any())).thenReturn(null);
  });

  Widget createLoginScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        BlocProvider<LoginViewModel>.value(value: loginBloc),
      ],
      child: MaterialApp(
        home: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('LoginScreen shows Login button', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      expect(loginButton, findsOneWidget);
    });

    testWidgets('LoginScreen shows email and password input fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      final emailLabel = find.text('Email');
      expect(emailLabel, findsOneWidget);

      final passwordLabel = find.text('Password');
      expect(passwordLabel, findsOneWidget);

      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));
    });

    testWidgets('LoginScreen shows forgot password and create account buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      final forgotPasswordButton =
          find.widgetWithText(TextButton, 'Forgot password?');
      expect(forgotPasswordButton, findsOneWidget);

      final createAccountButton =
          find.widgetWithText(OutlinedButton, 'Create an account');
      expect(createAccountButton, findsOneWidget);
    });

    testWidgets('LoginScreen shows SoftConnect branding',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      final scText = find.text('SC');
      expect(scText, findsOneWidget);

      final softConnectText = find.text('SoftConnect');
      expect(softConnectText, findsOneWidget);

      final taglineText = find.text('Building Bridges at Softwarica');
      expect(taglineText, findsOneWidget);
    });

    testWidgets('LoginScreen password field toggles visibility',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      final visibilityIcon = find.byIcon(Icons.visibility);
      expect(visibilityIcon, findsOneWidget);

      await tester.tap(visibilityIcon);
      await tester.pumpAndSettle();

      final visibilityOffIcon = find.byIcon(Icons.visibility_off);
      expect(visibilityOffIcon, findsOneWidget);
    });
  });
}
