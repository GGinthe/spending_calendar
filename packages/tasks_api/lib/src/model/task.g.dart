// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      title: json['title'] as String,
      id: json['id'] as String?,
      description: json['description'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      deleteDate: json['deleteDate'] == null
          ? null
          : DateTime.parse(json['deleteDate'] as String),
      subject: json['subject'] as String?,
      color: _$JsonConverterFromJson<int, Color>(
          json['color'], const ColorSerialiser().fromJson,),
      isAllDay: json['isAllDay'] as bool? ?? false,
      notificationsDuration: (json['notificationsDuration'] as List<dynamic>?)
              ?.map((e) => Duration(microseconds: e as int))
              .toList() ??
          const [],
      notificationsId: (json['notificationsId'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'isCompleted': instance.isCompleted,
      'isDeleted': instance.isDeleted,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'deleteDate': instance.deleteDate?.toIso8601String(),
      'subject': instance.subject,
      'color': _$JsonConverterToJson<int, Color>(
          instance.color, const ColorSerialiser().toJson,),
      'isAllDay': instance.isAllDay,
      'notificationsDuration':
          instance.notificationsDuration.map((e) => e.inMicroseconds).toList(),
      'notificationsId': instance.notificationsId,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
