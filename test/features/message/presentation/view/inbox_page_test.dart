import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/theme/theme_provider.dart';
import 'package:softconnect/features/message/presentation/view/inbox_page.dart';
import 'package:softconnect/features/message/presentation/view_model/inbox_viewmodel.dart';
import 'package:softconnect/features/message/presentation/view_model/inbox_state.dart';
import 'package:softconnect/features/message/presentation/view_model/inbox_event.dart';
import 'package:softconnect/features/message/domain/entity/message_inbox_entity.dart';

// Mock classes
class MockInboxViewModel extends Mock implements InboxViewModel {}
class MockThemeProvider extends Mock implements ThemeProvider {}

// Fake classes for mocktail fallback values
class FakeInboxEvent extends Fake implements InboxEvent {}

void main() {
  late MockInboxViewModel inboxViewModel;
  late MockThemeProvider themeProvider;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(FakeInboxEvent());
  });

  setUp(() {
    inboxViewModel = MockInboxViewModel();
    themeProvider = MockThemeProvider();

    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({'userId': 'test-user-123'});

    // Mock theme provider properties
    when(() => themeProvider.isDarkMode).thenReturn(false);
    when(() => themeProvider.addListener(any())).thenReturn(null);
    when(() => themeProvider.removeListener(any())).thenReturn(null);

    // Mock default stream and state
    when(() => inboxViewModel.stream)
        .thenAnswer((_) => Stream<InboxState>.fromIterable([MessageInitialState()]));
    when(() => inboxViewModel.state).thenReturn(MessageInitialState());

    // Mock methods
    when(() => inboxViewModel.add(any())).thenReturn(null);
  });

  Widget createInboxScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        BlocProvider<InboxViewModel>.value(value: inboxViewModel),
      ],
      child: MaterialApp(
        home: const InboxPage(),
      ),
    );
  }

  // Create message entities
  MessageInboxEntity createMessage({
    required String id,
    required String username,
    required String lastMessage,
    DateTime? lastMessageTime,
    bool lastMessageIsRead = true,
    String? lastMessageSenderId,
    String? profilePhoto,
    String email = 'test@example.com',
  }) {
    return MessageInboxEntity(
      id: id,
      username: username,
      email: email,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime ?? DateTime.now(),
      lastMessageIsRead: lastMessageIsRead,
      lastMessageSenderId: lastMessageSenderId ?? 'other-user',
      profilePhoto: profilePhoto,
    );
  }

  group('InboxPage Widget Tests', () {
    testWidgets('Test 1: Shows loading indicator when in loading state',
        (WidgetTester tester) async {
      // Set up stream to emit loading state
      when(() => inboxViewModel.stream)
          .thenAnswer((_) => Stream<InboxState>.fromIterable([MessageLoadingState()]));
      when(() => inboxViewModel.state).thenReturn(MessageLoadingState());

      await tester.pumpWidget(createInboxScreen());
      await tester.pump(); // Allow initial build
      await tester.pump(); // Allow stream to emit

      // Check for loading indicator
      final loadingIndicator = find.byType(CircularProgressIndicator);
      expect(loadingIndicator, findsAtLeastNWidgets(1));
    });

    testWidgets('Test 2: Shows empty state when no messages',
        (WidgetTester tester) async {
      // Set up stream to emit empty loaded state
      when(() => inboxViewModel.stream)
          .thenAnswer((_) => Stream<InboxState>.fromIterable([MessageLoadedState([])]));
      when(() => inboxViewModel.state).thenReturn(MessageLoadedState([]));

      await tester.pumpWidget(createInboxScreen());
      await tester.pump(); // Allow initial build
      await tester.pump(); // Allow stream to emit

      // Check for empty state icon
      final emptyIcon = find.byIcon(Icons.message_outlined);
      expect(emptyIcon, findsOneWidget);

      // Check for empty state text
      final emptyText = find.text('No messages yet.');
      expect(emptyText, findsOneWidget);
    });

    testWidgets('Test 3: Shows inbox list when messages are loaded',
        (WidgetTester tester) async {
      // Create message entities
      final mockMessages = [
        createMessage(
          id: '1',
          username: 'John Doe',
          lastMessage: 'Hello there!',
          lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
          lastMessageIsRead: false,
          lastMessageSenderId: 'other-user',
        ),
        createMessage(
          id: '2',
          username: 'Jane Smith',
          lastMessage: 'How are you?',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
          lastMessageIsRead: true,
          lastMessageSenderId: 'test-user-123',
        ),
      ];

      // Set up stream to emit loaded state with messages
      when(() => inboxViewModel.stream)
          .thenAnswer((_) => Stream<InboxState>.fromIterable([MessageLoadedState(mockMessages)]));
      when(() => inboxViewModel.state).thenReturn(MessageLoadedState(mockMessages));

      await tester.pumpWidget(createInboxScreen());
      await tester.pump(); // Allow initial build
      await tester.pump(); // Allow stream to emit

      // Check for ListView
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      // Check for user names
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);

      // Check for messages
      expect(find.text('Hello there!'), findsOneWidget);
      expect(find.text('How are you?'), findsOneWidget);

      // Check for ListTile widgets
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('Test 4: Shows error state when there is an error',
        (WidgetTester tester) async {
      const errorMessage = 'Failed to load messages';
      
      // Set up stream to emit error state
      when(() => inboxViewModel.stream)
          .thenAnswer((_) => Stream<InboxState>.fromIterable([MessageErrorState(errorMessage)]));
      when(() => inboxViewModel.state).thenReturn(MessageErrorState(errorMessage));

      await tester.pumpWidget(createInboxScreen());
      await tester.pump(); // Allow initial build
      await tester.pump(); // Allow stream to emit

      // Check for error icon
      final errorIcon = find.byIcon(Icons.error_outline);
      expect(errorIcon, findsOneWidget);

      // Check for error message
      final errorText = find.text('Error: $errorMessage');
      expect(errorText, findsOneWidget);
    });

    testWidgets('Test 5: Shows unread message indicator for unread messages',
        (WidgetTester tester) async {
      // Create message with unread status
      final mockMessages = [
        createMessage(
          id: '1',
          username: 'John Doe',
          lastMessage: 'New unread message',
          lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
          lastMessageIsRead: false,
          lastMessageSenderId: 'other-user', // Not current user, so should show as unread
        ),
      ];

      // Set up stream to emit loaded state with unread message
      when(() => inboxViewModel.stream)
          .thenAnswer((_) => Stream<InboxState>.fromIterable([MessageLoadedState(mockMessages)]));
      when(() => inboxViewModel.state).thenReturn(MessageLoadedState(mockMessages));

      await tester.pumpWidget(createInboxScreen());
      await tester.pump(); // Allow initial build
      await tester.pump(); // Allow stream to emit

      // Check for unread indicator (small circle)
      final unreadIndicators = find.byWidgetPredicate(
        (widget) => widget is Container && 
                   widget.decoration is BoxDecoration &&
                   (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(unreadIndicators, findsAtLeastNWidgets(1));

      // Check that the message appears
      expect(find.text('New unread message'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('Test 6: Shows refresh indicator and can be pulled to refresh',
        (WidgetTester tester) async {
      // Create message entities
      final mockMessages = [
        createMessage(
          id: '1',
          username: 'Test User',
          lastMessage: 'Test message',
        ),
      ];

      // Set up stream to emit loaded state
      when(() => inboxViewModel.stream)
          .thenAnswer((_) => Stream<InboxState>.fromIterable([MessageLoadedState(mockMessages)]));
      when(() => inboxViewModel.state).thenReturn(MessageLoadedState(mockMessages));

      await tester.pumpWidget(createInboxScreen());
      await tester.pump(); // Allow initial build
      await tester.pump(); // Allow stream to emit

      // Check for RefreshIndicator
      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);

      // Test pull to refresh gesture
      await tester.fling(find.text('Test User'), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify that add method was called (refresh triggers LoadInboxEvent)
      verify(() => inboxViewModel.add(any())).called(greaterThanOrEqualTo(1));
    });
  });
}