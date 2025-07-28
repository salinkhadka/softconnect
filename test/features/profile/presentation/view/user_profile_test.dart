import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:softconnect/features/auth/domain/entity/user_entity.dart';
import 'package:softconnect/features/friends/domain/use_case/follow_user_usecase.dart';
import 'package:softconnect/features/profile/presentation/view/user_profile.dart';
import 'package:softconnect/features/profile/presentation/view_model/user_profile_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_state.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_event.dart';
import 'package:softconnect/app/theme/theme_provider.dart';

// Import your actual use cases - adjust these paths according to your project structure
// import 'package:softconnect/features/profile/domain/usecases/follow_user_usecase.dart';
// Add other use cases that might be needed by UserProfilePage

// Mock classes using bloc_test for proper BLoC mocking
class MockUserProfileViewModel extends MockCubit<UserProfileState> 
    implements UserProfileViewModel {}

class MockFeedViewModel extends MockBloc<FeedEvent, FeedState> 
    implements FeedViewModel {}

class MockThemeProvider extends Mock implements ThemeProvider {}

// Mock entities and use cases
class MockUserEntity extends Mock implements UserEntity {}
class MockFollowUserUseCase extends Mock implements FollowUserUseCase {}

void main() {
  late MockUserProfileViewModel mockUserProfileViewModel;
  late MockFeedViewModel mockFeedViewModel;
  late MockThemeProvider mockThemeProvider;
  late UserEntity mockUser;
  late MockFollowUserUseCase mockFollowUserUseCase;

  // Get GetIt instance
  final GetIt sl = GetIt.instance;

  setUp(() {
    // Reset GetIt before each test
    sl.reset();
    
    mockUserProfileViewModel = MockUserProfileViewModel();
    mockFeedViewModel = MockFeedViewModel();
    mockThemeProvider = MockThemeProvider();
    mockUser = MockUserEntity();
    mockFollowUserUseCase = MockFollowUserUseCase();

    // Register mock dependencies in GetIt
    sl.registerLazySingleton<FollowUserUseCase>(() => mockFollowUserUseCase);
    
    // Register other use cases that might be needed by UserProfilePage
    // Add similar registrations for other dependencies if needed

    // Setup mock user entity
    when(() => mockUser.userId).thenReturn('test-user-id');
    when(() => mockUser.username).thenReturn('TestUser');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.role).thenReturn('Student');
    when(() => mockUser.studentId).thenReturn(12345);
    when(() => mockUser.profilePhoto).thenReturn('profile.jpg');
    when(() => mockUser.bio).thenReturn('Test bio');
    when(() => mockUser.followersCount).thenReturn(10);
    when(() => mockUser.followingCount).thenReturn(5);

    // Setup mock theme provider
    when(() => mockThemeProvider.isDarkMode).thenReturn(false);

    // Setup default states for BLoCs
    when(() => mockFeedViewModel.state).thenReturn(
      FeedState(
        posts: [],
        isLoading: false,
        error: null,
        isLikedMap: {},
        likeCounts: {},
        commentCounts: {},
      ),
    );
  });

  tearDown(() {
    // Clean up GetIt after each test
    sl.reset();
  });

  Widget createTestWidget({String? userId, UserProfileState? profileState}) {
    // Set up the profile state
    final state = profileState ?? UserProfileState(
      user: mockUser, 
      isLoading: false, 
      error: null
    );
    
    when(() => mockUserProfileViewModel.state).thenReturn(state);
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: mockThemeProvider),
        BlocProvider<UserProfileViewModel>.value(value: mockUserProfileViewModel),
        BlocProvider<FeedViewModel>.value(value: mockFeedViewModel),
      ],
      child: MaterialApp(
        theme: ThemeData.light(),
        home: UserProfilePage(userId: userId),
      ),
    );
  }

  group('UserProfilePage Widget Tests', () {
    testWidgets('shows loading indicator when user is null and loading', (tester) async {
      // Arrange
      final loadingState = UserProfileState(user: null, isLoading: true, error: null);
      
      // Act
      await tester.pumpWidget(createTestWidget(profileState: loadingState));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays user profile information correctly', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Pump a few times to ensure the widget builds completely
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Debug: Print widget tree to see what's actually rendered
      debugDumpApp();

      // Assert - be more flexible with text finding
      expect(find.textContaining('TestUser'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Student'), findsAtLeastNWidgets(1));
      expect(find.textContaining('12345'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Followers'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Following'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows "My Profile" in app bar for own profile', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('My Profile'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows Edit Profile button for own profile', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Check for buttons by text or type
      expect(
        find.byWidgetPredicate(
          (widget) => widget is ElevatedButton && 
          widget.child is Text && 
          (widget.child as Text).data?.contains('Edit Profile') == true
        ), 
        findsAtLeastNWidgets(1)
      );
    });

    testWidgets('handles error state correctly', (tester) async {
      // Arrange
      final errorState = UserProfileState(
        user: null, 
        isLoading: false, 
        error: 'Failed to load user'
      );
      
      // Act
      await tester.pumpWidget(createTestWidget(profileState: errorState));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Failed to load user'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows Follow button for other user profile', (tester) async {
      // Arrange - Create a different user
      final otherUser = MockUserEntity();
      when(() => otherUser.userId).thenReturn('other-user-id');
      when(() => otherUser.username).thenReturn('OtherUser');
      when(() => otherUser.email).thenReturn('other@example.com');
      when(() => otherUser.role).thenReturn('Student');
      when(() => otherUser.studentId).thenReturn(67890);
      when(() => otherUser.profilePhoto).thenReturn('other_profile.jpg');
      when(() => otherUser.bio).thenReturn('Other user bio');
      when(() => otherUser.followersCount).thenReturn(20);
      when(() => otherUser.followingCount).thenReturn(15);

      final otherUserState = UserProfileState(
        user: otherUser, 
        isLoading: false, 
        error: null
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        userId: 'other-user-id', 
        profileState: otherUserState
      ));
      await tester.pumpAndSettle();

      // Wait a bit more for the widget to determine it's not own profile
      await tester.pump(const Duration(milliseconds: 200));

      // Assert - Look for Follow button
      expect(
        find.byWidgetPredicate(
          (widget) => widget is ElevatedButton && 
          widget.child is Text && 
          (widget.child as Text).data?.contains('Follow') == true
        ), 
        findsAtLeastNWidgets(1)
      );
    });
  });

  group('UserProfilePage Edge Cases', () {
    testWidgets('handles null user gracefully when not loading', (tester) async {
      // Arrange
      final nullUserState = UserProfileState(user: null, isLoading: false, error: null);
      
      // Act
      await tester.pumpWidget(createTestWidget(profileState: nullUserState));
      await tester.pumpAndSettle();

      // Assert - Should show some placeholder or empty state
      expect(find.byType(CircularProgressIndicator), findsNothing);
      // Add assertions for your app's empty state handling
    });

    testWidgets('updates when state changes', (tester) async {
      // Arrange
      final initialState = UserProfileState(user: null, isLoading: true, error: null);
      final loadedState = UserProfileState(user: mockUser, isLoading: false, error: null);
      
      // Act - Start with loading state
      await tester.pumpWidget(createTestWidget(profileState: initialState));
      await tester.pump();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Update to loaded state
      when(() => mockUserProfileViewModel.state).thenReturn(loadedState);
      await tester.pumpWidget(createTestWidget(profileState: loadedState));
      await tester.pumpAndSettle();

      // Assert - Should now show user info
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('TestUser'), findsAtLeastNWidgets(1));
    });
  });
}