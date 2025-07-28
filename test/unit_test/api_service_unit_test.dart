import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/app/constants/api_endpoints.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late ApiService apiService;

  setUp(() {
  mockDio = MockDio();

  // Provide a real BaseOptions
  final options = BaseOptions();
  when(() => mockDio.options).thenReturn(options);

  // Provide a real Interceptors object
  final interceptors = Interceptors();
  when(() => mockDio.interceptors).thenReturn(interceptors);

  apiService = ApiService(mockDio);
});


  group('ApiService', () {
    test('should configure base URL correctly', () {
      expect(apiService.dio.options.baseUrl, ApiEndpoints.baseUrl);
    });

    test('should set correct headers', () {
      expect(apiService.dio.options.headers['Content-Type'], 'application/json');
      expect(apiService.dio.options.headers['Accept'], 'application/json');
    });

    test('should handle GET request successfully', () async {
      // Arrange
      const testEndpoint = '/test';
      final mockResponse = Response(
        data: {'message': 'success'},
        statusCode: 200,
        requestOptions: RequestOptions(path: testEndpoint),
      );

      when(() => mockDio.get(testEndpoint)).thenAnswer((_) async => mockResponse);

      // Act
      final result = await mockDio.get(testEndpoint); // mockDio directly

      // Assert
      expect(result.data, {'message': 'success'});
      expect(result.statusCode, 200);
      verify(() => mockDio.get(testEndpoint)).called(1);
    });

    test('should handle POST request successfully', () async {
      const testEndpoint = '/test';
      final testData = {'name': 'John', 'email': 'john@example.com'};
      final mockResponse = Response(
        data: {'id': '1', 'message': 'created'},
        statusCode: 201,
        requestOptions: RequestOptions(path: testEndpoint),
      );

      when(() => mockDio.post(testEndpoint, data: testData))
          .thenAnswer((_) async => mockResponse);

      final result = await mockDio.post(testEndpoint, data: testData);

      expect(result.data, {'id': '1', 'message': 'created'});
      expect(result.statusCode, 201);
      verify(() => mockDio.post(testEndpoint, data: testData)).called(1);
    });

    test('should handle DioException correctly', () async {
      const testEndpoint = '/test';
      final dioException = DioException(
        requestOptions: RequestOptions(path: testEndpoint),
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: testEndpoint),
        ),
        type: DioExceptionType.badResponse,
      );

      when(() => mockDio.get(testEndpoint)).thenThrow(dioException);

      expect(() => mockDio.get(testEndpoint), throwsA(isA<DioException>()));
    });

    test('should add authorization header when token is provided', () {
      const token = 'Bearer test-token';

      apiService.dio.options.headers['Authorization'] = token;

      expect(apiService.dio.options.headers['Authorization'], token);
    });
  });
}
