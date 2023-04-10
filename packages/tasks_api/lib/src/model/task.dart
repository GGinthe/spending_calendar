// ignore_for_file: lines_longer_than_80_chars

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tasks_api/tasks_api.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

/// Create a new Color from int.
class ColorSerialiser implements JsonConverter<Color, int> {
  /// TO use json_serial
  const ColorSerialiser();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color color) => color.value;
}

/// {@template task_item}
/// A single `task` item.
///
/// [Task]s are immutable and can be copied using [copyWith], in addition to
/// being serialized / deserialized using [toJson] and [fromJson] respectively.
/// {@template}
@immutable
@JsonSerializable()
class Task extends Equatable {
  /// {@macro task_item}
  Task({
    required this.title,
    String? id,
    this.description = '',
    this.isCompleted = false,
    this.isDeleted = false,
    this.startDate,
    this.endDate,
    this.deleteDate,
    this.subject,
    this.color,
    this.isAllDay = false,
    this.notificationsDuration = const [],
    this.notificationsId = const [],
  })  : assert(
          id == null || id.isNotEmpty,
          'id can not be null and should be empty',
        ),
        id = id ?? const Uuid().v4();

  /// Cannot be empty.
  final String id;

  /// Note that the title may be empty.
  final String title;

  /// Defaults to an empty string.
  final String description;

  /// Defaults to `false`.
  final bool isCompleted;

  /// Defaults to `false`.
  final bool isDeleted;

  /// Start of the task.
  final DateTime? startDate;

  /// End of the task.
  final DateTime? endDate;

  /// Fake delete of the task
  final DateTime? deleteDate;

  /// Task's subject
  final String? subject;

  /// Color of the task
  @ColorSerialiser()
  final Color? color;

  /// whether the task is all day
  final bool isAllDay;

  ///
  final List<Duration> notificationsDuration;

  ///
  final List<int> notificationsId;

  /// Returns a copy of this `task` with the given values updated.
  ///
  /// {@macro task_item}
  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    bool? isDeleted,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? deleteDate,
    String? subject,
    Color? color,
    bool? isAllDay,
    List<Duration>? notificationsDuration,
    List<int>? notificationsId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      isDeleted: isDeleted ?? this.isDeleted,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      deleteDate: deleteDate ?? this.deleteDate,
      subject: subject ?? this.subject,
      color: color ?? this.color,
      isAllDay: isAllDay ?? this.isAllDay,
      notificationsDuration: notificationsDuration ?? this.notificationsDuration,
      notificationsId: notificationsId ?? this.notificationsId,
    );
  }

  /// Deserializes the given [JsonMap] into a [Task].
  static Task fromJson(JsonMap json) => _$TaskFromJson(json);

  /// Converts this [Task] into a [JsonMap].
  JsonMap toJson() => _$TaskToJson(this);

  @override
  String toString() => title;

  @override
  List<Object> get props => [
        id,
        title,
        description,
        isCompleted,
        isDeleted,
        startDate ?? false,
        endDate ?? false,
        deleteDate ?? false,
        subject ?? false,
        color ?? false,
        isAllDay,
        notificationsDuration,
        notificationsId,
      ];
}
