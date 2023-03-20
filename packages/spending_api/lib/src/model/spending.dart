import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:spending_api/spending_api.dart';
import 'package:uuid/uuid.dart';

part 'spending.g.dart';

/// {@template spending_item}
/// A single `spending` item.
///
/// [Spending] are immutable and can be copied using [copyWith], in addition to
/// being serialized / deserialized using [toJson] and [fromJson] respectively.
/// {@template}
@immutable
@JsonSerializable()
class Spending extends Equatable {
  /// {@macro spending_item}
  Spending({
    required this.title,
    required this.money,
    String? id,
    this.taskId,
    this.startDate,
    this.subject,
    this.isDeleted = false,
  })  : assert(
          id == null || id.isNotEmpty,
          'id can not be null and should be empty',
        ),
        id = id ?? const Uuid().v4();

  /// Cannot be empty.
  final String id;

  /// which task belong to
  final String? taskId;

  /// Note that the title may be empty.
  final String title;

  /// spending money.
  final int money;

  /// Date of the spending.
  final DateTime? startDate;

  /// Spending's subject
  final String? subject;

  /// Defaults to `false`.
  final bool isDeleted;

  /// Returns a copy of this `spending` with the given values updated.
  ///
  /// {@macro spending_item}
  Spending copyWith({
    String? id,
    String? taskId,
    String? title,
    int? money,
    DateTime? startDate,
    String? subject,
    bool? isDeleted,
  }) {
    return Spending(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      money: money ?? this.money,
      startDate: startDate ?? this.startDate,
      subject: subject ?? this.subject,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Deserializes the given [JsonMap] into a [Spending].
  static Spending fromJson(JsonMap json) => _$SpendingFromJson(json);

  /// Converts this [Spending] into a [JsonMap].
  JsonMap toJson() => _$SpendingToJson(this);

  @override
  String toString() => title;

  @override
  List<Object> get props => [
        id,
        taskId ?? '',
        title,
        money,
        startDate ?? false,
        subject ?? false,
        isDeleted,
      ];
}
