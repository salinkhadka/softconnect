import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:softconnect/app/theme/theme_provider.dart';
import 'package:softconnect/features/home/presentation/view/FeedPage.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_state.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_event.dart';
import 'package:softconnect/features/home/domain/entity/post_entity.dart';
import 'package:softconnect/features/home/domain/entity/user_preview_entity.dart';

// Mock classes
class MockFeedViewModel extends Mock implements FeedViewModel {}

class MockThemeProvider extends Mock implements ThemeProvider {}

// Mock entity classes
class MockPostEntity extends Mock implements PostEntity {}

class MockUserPreviewEntity extends Mock implements UserPreviewEntity {}

// Fake classes for mocktail fallback values
class FakeFeedEvent extends Fake implements FeedEvent {}

void main() {
  late MockFeedViewModel feedViewModel;
  late MockThemeProvider themeProvider;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(FakeFeedEvent());
  });

  setUp(() {
    feedViewModel = MockFeedViewModel();
    themeProvider = MockThemeProvider();

    // Mock theme provider properties
    when(() => themeProvider.isDarkMode).thenReturn(false);
    when(() => themeProvider.addListener(any())).thenReturn(null);
    when(() => themeProvider.removeListener(any())).thenReturn(null);

    // Mock stream for BlocConsumer - default to loading state
    when(() => feedViewModel.stream)
        .thenAnswer((_) => Stream<FeedState>.fromIterable([FeedState.initial().copyWith(isLoading: true)]));
    when(() => feedViewModel.state).thenReturn(FeedState.initial().copyWith(isLoading: true));

    // Mock methods
    when(() => feedViewModel.add(any())).thenReturn(null);
  });

  Widget createFeedScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        BlocProvider<FeedViewModel>.value(value: feedViewModel),
      ],
      child: MaterialApp(
        home: const FeedPage(currentUserId: 'test-user-id'),
      ),
    );
  }

  group('FeedPage Widget Tests', () {
    testWidgets('FeedPage shows loading indicator when state is loading',
        (WidgetTester tester) async {
      // Set up stream to emit loading state
      when(() => feedViewModel.stream)
          .thenAnswer((_) => Stream<FeedState>.fromIterable([
                FeedState.initial().copyWith(isLoading: true)
              ]));
      when(() => feedViewModel.state)
          .thenReturn(FeedState.initial().copyWith(isLoading: true));

      await tester.pumpWidget(createFeedScreen());
      await tester.pump(); // Allow initial build
      await tester.pump(); // Allow stream to emit

      // Check for loading indicator
      final loadingIndicator = find.byType(CircularProgressIndicator);
      expect(loadingIndicator, findsOneWidget);
    });

    testWidgets('FeedPage shows empty state when no posts are available',
        (WidgetTester tester) async {
      // Set up stream to emit empty loaded state
      when(() => feedViewModel.stream)
          .thenAnswer((_) => Stream<FeedState>.fromIterable([
                FeedState.initial().copyWith(
                  isLoading: false,
                  posts: [],
                )
              ]));
      when(() => feedViewModel.state)
          .thenReturn(FeedState.initial().copyWith(
            isLoading: false,
            posts: [],
          ));

      await tester.pumpWidget(createFeedScreen());
      await tester.pump(); // Allow initial build
      await tester.pump(); // Allow stream to emit

      // Check for empty state icon
      final emptyIcon = find.byIcon(Icons.post_add_outlined);
      expect(emptyIcon, findsOneWidget);

      // Check for empty state text
      final emptyText = find.text('No posts available');
      expect(emptyText, findsOneWidget);
    });

    
  });
}