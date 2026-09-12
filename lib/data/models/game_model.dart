// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:esportly/core/enum/enums.dart';
import 'package:esportly/core/helpers/date_helper.dart';
import 'package:esportly/data/models/result_model.dart';
import 'package:esportly/data/models/team_model.dart';

class GameModel {
  final int? id;
  final int? number;
  final int? eventId;
  int? refereeId;
  final int? duration;
  DateTime? date;
  DateTime? startTime;
  DateTime? endTime;
  GameStatus? status;
  ResultModel? result;
  List<TeamModel>? teams;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  GameModel({
    this.id,
    this.number,
    this.eventId,
    this.refereeId,
    this.duration,
    this.date,
    this.startTime,
    this.endTime,
    this.status,
    this.result,
    this.teams,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  GameModel copyWith({
    int? id,
    int? number,
    int? eventId,
    int? refereeId,
    int? duration,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    GameStatus? status,
    ResultModel? result,
    List<TeamModel>? teams,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return GameModel(
      id: id ?? this.id,
      number: number ?? this.number,
      eventId: eventId ?? this.eventId,
      refereeId: refereeId ?? this.refereeId,
      duration: duration ?? this.duration,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      result: result ?? this.result,
      teams: teams ?? this.teams,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'number': number,
      'eventId': eventId,
      'refereeId': refereeId,
      'duration': duration,
      'date': date?.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'result': result?.toMap(),
      'teams': teams != null && teams!.isNotEmpty ? teams!.map((x) => x.toMap()).toList() : [],
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt,
    };
  }

  factory GameModel.fromMap(Map<String, dynamic> map) {
    final DateTime? date = DateHelper.parseDate(map['date']);
    return GameModel(
      id: map['id'] != null ? map['id'] as int : null,
      number: map['number'] as int,
      eventId: map['eventId'] as int,
      refereeId: map['refereeId'] != null ? map['refereeId'] as int : null,
      duration: map['duration'] != null ? map['duration'] as int : null,
      date: date,
      startTime: DateHelper.parseTime(map['startTime'], baseDate: date),
      endTime: DateHelper.parseTime(map['endTime'], baseDate: date),
      status: map['status'] != null
        ? GameStatus.values.where((e) => e.name == map['status']).firstOrNull
        : null,
      result: map['result'] != null 
        ? ResultModel.fromMap(map['result'] as Map<String,dynamic>) 
        : null,
      teams: map['teams'] != null 
        ? List<TeamModel>.from(
            (map['teams'] as List<dynamic>).map<TeamModel?>(
              (x) => TeamModel.fromMap(x as Map<String,dynamic>),
            ),
          ) 
        : null,
      createdAt: DateHelper.parseDate(map['createdAt']),
      updatedAt: DateHelper.parseDate(map['updatedAt']),
      deletedAt: DateHelper.parseDate(map['deletedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory GameModel.fromJson(String source) => GameModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'GameModel(id: $id, number: $number, eventId: $eventId, refereeId: $refereeId, duration: $duration, date: $date, startTime: $startTime, endTime: $endTime, status: $status, result: $result, teams: $teams, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(covariant GameModel other) {
    if (identical(this, other)) return true;
  
    return
      other.id == id &&
      other.number == number &&
      other.eventId == eventId &&
      other.refereeId == refereeId &&
      other.duration == duration &&
      other.date == date &&
      other.startTime == startTime &&
      other.endTime == endTime &&
      other.status == status &&
      other.result == result &&
      listEquals(other.teams, teams) &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      number.hashCode ^
      eventId.hashCode ^
      refereeId.hashCode ^
      duration.hashCode ^
      date.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      status.hashCode ^
      result.hashCode ^
      teams.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      deletedAt.hashCode;
  }
}
