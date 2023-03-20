// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spending.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Spending _$SpendingFromJson(Map<String, dynamic> json) => Spending(
      title: json['title'] as String,
      money: json['money'] as int,
      id: json['id'] as String?,
      taskId: json['taskId'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      subject: json['subject'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$SpendingToJson(Spending instance) => <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'title': instance.title,
      'money': instance.money,
      'startDate': instance.startDate?.toIso8601String(),
      'subject': instance.subject,
      'isDeleted': instance.isDeleted,
    };
