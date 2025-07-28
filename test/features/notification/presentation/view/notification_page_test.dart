import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/theme/theme_provider.dart';
import 'package:softconnect/features/notification/presentation/view/notification_page.dart';
import 'package:softconnect/features/notification/presentation/view_model/notification_viewmodel.dart';
import 'package:softconnect/features/notification/domain/entity/notification_entity.dart';

// Mock classes
class MockNotificationViewModel extends Mock implements NotificationViewModel {}

class MockThemeProvider extends Mock implements ThemeProvider {}

// Mock entity classes
class MockNotificationEntity extends Mock implements NotificationEntity {}

class MockSender extends Mock {
  String get username => 'test_user';
  String? get profilePhoto => null;
}

void main() {
  late MockNotificationViewModel notificationViewModel;
  late MockThemeProvider themeProvider;

  setUp(() {
    notificationViewModel = MockNotificationViewModel();
    themeProvider = MockThemeProvider();

    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({'userId': 'test-user-id'});

    // Mock theme provider properties
    when(() => themeProvider.isDarkMode).thenReturn(false);
    when(() => themeProvider.addListener(any())).thenReturn(null);
    when(() => themeProvider.removeListener(any())).thenReturn(null);

    // Mock stream for BlocConsumer - default to loading state
    when(() => notificationViewModel.stream)
        .thenAnswer((_) => Stream<NotificationState>.fromIterable([NotificationLoading()]));
    when(() => notificationViewModel.state).thenReturn(NotificationLoading());

    // Mock methods
    when(() => notificationViewModel.loadNotifications(any(), showLoader: any(named: 'showLoader')))
        .thenAnswer((_) async {});
    when(() => notificationViewModel.markNotificationRead(any(), any()))
        .thenAnswer((_) async {});
    when(() => notificationViewModel.deleteNotification(any(), any()))
        .thenAnswer((_) async {});
  });

  Widget createNotificationScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        BlocProvider<NotificationViewModel>.value(value: notificationViewModel),
      ],
      child: MaterialApp(
        home: const NotificationPage(),
      ),
    );
  }

  group('NotificationPage Widget Tests', () {
    

    testWidgets('NotificationPage shows loading indicator when state is loading',
        (WidgetTester tester) async {
      // Set up stream to emit loading state
      when(() => notificationViewModel.stream)
          .thenAnswer((_) => Stream<NotificationState>.fromIterable([NotificationLoading()]));
      when(() => notificationViewModel.state).thenReturn(NotificationLoading());

      await tester.pumpWidget(createNotificationScreen());
      await tester.pump(); // Allow initial build
      await tester.pump(); // Allow stream to emit

      // Check for loading indicator
      final loadingIndicator = find.byType(CircularProgressIndicator);
      expect(loadingIndicator, findsAtLeastNWidgets(1));

      // Check for loading text
      final loadingText = find.text('Loading notifications...');
      expect(loadingText, findsOneWidget);
    });

    testWidgets('NotificationPage shows empty state when no notifications',
        (WidgetTester tester) async {
      // Set up stream to emit empty loaded state
      when(() => notificationViewModel.stream)
          .thenAnswer((_) => Stream<NotificationState>.fromIterable([NotificationLoaded([])]));
      when(() => notificationViewModel.state).thenReturn(NotificationLoaded([]));

      await tester.pumpWidget(createNotificationScreen());
      await tester.pump(); // Allow initial build
      await tester.pump(); // Allow stream to emit

      // Check for empty state icon
      final emptyIcon = find.byIcon(Icons.notifications_none_outlined);
      expect(emptyIcon, findsOneWidget);

      // Check for empty state text
      final emptyTitle = find.text('No notifications yet');
      expect(emptyTitle, findsOneWidget);

      final emptySubtitle = find.text('When you receive notifications, they\'ll appear here');
      expect(emptySubtitle, findsOneWidget);
    });
  });
}