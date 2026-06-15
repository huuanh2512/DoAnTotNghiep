import 'package:equatable/equatable.dart';

class BaseResponse<T> extends Equatable {
  final bool success;
  final String? message;
  final T? data;

  const BaseResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    final result = json['result'] as Map<String, dynamic>? ?? json;

    return BaseResponse<T>(
      success: result['success'] as bool? ?? false,
      message: result['message'] as String?,
      data: fromJsonT != null ? fromJsonT(json) : null,
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}