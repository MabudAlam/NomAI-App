import 'package:equatable/equatable.dart';
import 'package:NomAi/app/models/Chat/ChatPostModel.dart';

class ChatGetModelResponse extends Equatable {
  final List<ChatMessageModel>? messages;
  final int? total;
  final int? offset;
  final int? limit;

  const ChatGetModelResponse({
    this.messages,
    this.total,
    this.offset,
    this.limit,
  });

  factory ChatGetModelResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ChatGetModelResponse();
    return ChatGetModelResponse(
      messages: json['messages'] is List
          ? (json['messages'] as List)
              .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>?))
              .toList()
          : null,
      total: json['total'] as int?,
      offset: json['offset'] as int?,
      limit: json['limit'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messages': messages?.map((e) => e.toJson()).toList(),
      'total': total,
      'offset': offset,
      'limit': limit,
    };
  }

  @override
  List<Object?> get props => [messages, total, offset, limit];
}

class ChatMessageModel extends Equatable {
  final String? messageId;
  final String? role;
  final String? text;
  final String? imageUrl;
  final ChatSources? sources;
  final bool? isAddedToLogs;
  final DateTime? timestamp;

  const ChatMessageModel({
    this.messageId,
    this.role,
    this.text,
    this.imageUrl,
    this.sources,
    this.isAddedToLogs,
    this.timestamp,
  });

  bool get isUser => role == 'user';
  bool get isModel => role == 'model';

  factory ChatMessageModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ChatMessageModel();
    return ChatMessageModel(
      messageId: json['messageId'] as String?,
      role: json['role'] as String?,
      text: json['text'] as String?,
      imageUrl: json['image_url'] as String?,
      sources: json['sources'] != null
          ? ChatSources.fromJson(json['sources'] as Map<String, dynamic>?)
          : null,
      isAddedToLogs: json['isAddedToLogs'] as bool?,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'role': role,
      'text': text,
      'image_url': imageUrl,
      'sources': sources?.toJson(),
      'isAddedToLogs': isAddedToLogs,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [messageId, role, text, imageUrl, sources, isAddedToLogs, timestamp];
}

class ChatSources extends Equatable {
  final NutritionData? nutritionData;
  final List<String>? toolsUsed;

  const ChatSources({
    this.nutritionData,
    this.toolsUsed,
  });

  factory ChatSources.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ChatSources();
    return ChatSources(
      nutritionData: json['nutrition_data'] != null
          ? NutritionData.fromJson(
              json['nutrition_data'] as Map<String, dynamic>?)
          : null,
      toolsUsed: json['tools_used'] is List
          ? List<String>.from(json['tools_used'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nutrition_data': nutritionData?.toJson(),
      'tools_used': toolsUsed,
    };
  }

  @override
  List<Object?> get props => [nutritionData, toolsUsed];
}
