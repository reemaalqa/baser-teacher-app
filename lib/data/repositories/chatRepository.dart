import 'package:dio/dio.dart';
import 'package:eschool_teacher/data/models/chatMessage.dart';
import 'package:eschool_teacher/data/models/chatUser.dart';
import 'package:eschool_teacher/utils/api.dart';
import 'package:eschool_teacher/utils/constants.dart';
import 'package:flutter/foundation.dart';

class ChatRepository {
  Future<Map<String, dynamic>> fetchChatUsers(
      {required int offset, required bool isParent}) async {
    try {
      final response = await Api.get(
        url: Api.getChatUsers,
        useAuthToken: true,
        queryParameters: {
          "offset": offset,
          "limit": offsetLimitPaginationAPIDefaultItemFetchLimit,
          "isParent": isParent ? 1 : 0,
        },
      );

      List<ChatUser> chatUsers = [];
// logger.i(response);
      for (int i = 0; i < response['data']['items'].length; i++) {
        chatUsers.add(ChatUser.fromJsonAPI(response['data']['items'][i]));
      }
      // logger.i(chatUsers.length);

      return {
        "chatUsers": chatUsers,
        "totalItems": response['data']['total_items'] ?? 1,
        "totalUnreadUsers": response['data']['total_unread_users'] ?? 0,
      };
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      throw ApiException(error.toString());
    }
  }

  Future<Map<String, dynamic>> fetchChatMessages(
      {required int offset, required String chatUserId}) async {
    try {
      final response = await Api.post(
        url: Api.getChatMessages,
        useAuthToken: true,
        body: {
          "offset": offset,
          "user_id": chatUserId,
          "limit": offsetLimitPaginationAPIDefaultItemFetchLimit
        },
      );

      List<ChatMessage> chatMessage = [];

      for (int i = 0; i < response['data']['items'].length; i++) {
        chatMessage.add(ChatMessage.fromJsonAPI(response['data']['items'][i]));
      }

      return {
        "chatMessages": chatMessage,
        "totalItems": response['data']['total_items'],
      };
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      throw ApiException(error.toString());
    }
  }

  Future<ChatMessage> sendChatMessage(
      {required String message,
      List<String> filePaths = const [],
      required int receiverId}) async {
    try {
      List<MultipartFile> files = [];
      for (var filePath in filePaths) {
        files.add(await MultipartFile.fromFile(filePath));
      }
      final result = await Api.post(
        body: {
          "receiver_id": receiverId.toString(),
          "message": message,
          if (files.isNotEmpty) "file": files
        },
        url: Api.sendChatMessage,
        useAuthToken: true,
      );
      return ChatMessage.fromJsonAPI(result['data']);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> readAllMessages({
    required String userId,
  }) async {
    try {
      //this will call API to make all messages read, noting in failure
      await Api.post(
        url: Api.readAllMessages,
        useAuthToken: true,
        body: {
          "user_id": userId,
        },
      );
    } catch (_) {}
  }
}
