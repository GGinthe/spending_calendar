import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:tasks_api/tasks_api.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

/// {@template task_item}
/// A single `task` item.
///
/// [Task]s are immutable and can be copied using [copyWith], in addition to
/// being serialized / deserialized using [toJson] and [fromJson] respectively.
/// {@endtemplate}
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
      ];
}
