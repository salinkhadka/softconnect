import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/message/data/data_source/message_datsource.dart';
import 'package:softconnect/features/message/data/data_source/message_hive_datasource.dart';
import 'package:softconnect/features/message/data/model/message_inbox_hive_model.dart';
import 'package:softconnect/features/message/data/model/message_model.dart';
import 'package:softconnect/features/message/domain/entity/message_entity.dart';
import 'package:softconnect/features/message/domain/entity/message_inbox_entity.dart';
import 'package:softconnect/features/message/domain/repository/message_repository.dart';

class MessageRepositoryImpl implements IMessageRepository {
  final IMessageDataSource remoteDataSource;
  final IMessageLocalDataSource localDataSource;
  final Connectivity connectivity;

  MessageRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Either<Failure, List<MessageInboxEntity>>> getInbox(String userId) async {
    final hasInternet = await _hasInternetConnection();

    if (hasInternet) {
      try {
        final models = await remoteDataSource.getInboxConversations(userId);
        final hiveModels = models.map((m) => MessageInboxHiveModel.fromModel(m)).toList();
        await localDataSource.cacheInboxMessages(hiveModels);

        return Right(models.map((m) => m.toEntity()).toList());
      } catch (e) {
        print("⚠️ Remote fetch failed: $e");
        return await _getInboxFromCache();
      }
    } else {
      print("📡 Offline, loading inbox from cache...");
      return await _getInboxFromCache();
    }
  }

  Future<Either<Failure, List<MessageInboxEntity>>> _getInboxFromCache() async {
    try {
      final cached = await localDataSource.getLastInboxMessages();
      if (cached.isEmpty) {
        return Left(LocalDatabaseFailure(message: "No cached inbox available."));
      }

      return Right(cached.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: "Failed to load inbox from cache: $e"));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessagesBetweenUsers(
      String user1Id, String user2Id) async {
    final hasInternet = await _hasInternetConnection();

    if (!hasInternet) {
      return Left(RemoteDatabaseFailure(message: "Connect to internet to view conversation."));
    }

    try {
      final models = await remoteDataSource.getMessagesBetweenUsers(user1Id, user2Id);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage(
      String senderId, String recipientId, String content) async {
    final hasInternet = await _hasInternetConnection();

    if (!hasInternet) {
      return Left(RemoteDatabaseFailure(message: "You must be online to send a message."));
    }

    try {
      final message = await remoteDataSource.sendMessage(senderId, recipientId, content);
      return Right(message.toEntity());
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(String messageId) async {
    final hasInternet = await _hasInternetConnection();

    if (!hasInternet) {
      return Left(RemoteDatabaseFailure(message: "You must be online to delete a message."));
    }

    try {
      await remoteDataSource.deleteMessage(messageId);
      return const Right(null);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead(String otherUserId) async {
    final hasInternet = await _hasInternetConnection();

    if (!hasInternet) {
      return Left(RemoteDatabaseFailure(message: "You must be online to mark messages as read."));
    }

    try {
      await remoteDataSource.markMessagesAsRead(otherUserId);
      return const Right(null);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }
}
