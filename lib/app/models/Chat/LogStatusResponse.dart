import 'package:equatable/equatable.dart';

class LogStatusResponse extends Equatable {
  final bool? success;
  final String? message;
  final String? error;

  const LogStatusResponse({
    this.success,
    this.message,
    this.error,
  });

  factory LogStatusResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LogStatusResponse();
    return LogStatusResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'error': error,
    };
  }

  @override
  List<Object?> get props => [success, message, error];
}