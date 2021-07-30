import 'package:equatable/equatable.dart';

abstract class Model extends Equatable {
  final String? id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Model(
    this.id, {
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
      ];
}
