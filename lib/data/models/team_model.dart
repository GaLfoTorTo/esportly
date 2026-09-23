// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:esportly/core/helpers/date_helper.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/user_model.dart';

class TeamModel {
  final int? id;
  final int? gameId;
  final String? uuid;
  final String? name;
  final String? emblem;
  final List<UserModel> players;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  TeamModel({
    this.id,
    this.gameId,
    this.uuid,
    this.name,
    this.emblem,
    required this.players,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  TeamModel copyWith({
    int? id,
    int? gameId,
    String? uuid,
    EventModel? event,
    String? name,
    String? emblem,
    List<UserModel>? players,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TeamModel(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      emblem: emblem ?? this.emblem,
      players: players ?? this.players,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'gameId': gameId,
      'uuid': uuid,
      'name': name,
      'emblem': emblem,
      'players': players.map((x) => x.toMap()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt,
    };
  }

  factory TeamModel.fromMap(Map<String, dynamic> map) {
    return TeamModel(
      id: map['id'] as int?,
      gameId: map['gameId'] as int?,
      uuid: map['uuid'] as String?,
      name: map['name'] != null ? map['name'] as String : null,
      emblem: map['emblem'] != null ? map['emblem'] as String : null,
      players: map['players'] != null
        ? List<UserModel>.from((map['players'] as List<Map<String, dynamic>>)
          .map<UserModel>(
            (x) => UserModel.fromMap(x),
          ),
        )
        : [],
      createdAt: DateHelper.parseDate(map['createdAt']),
      updatedAt: DateHelper.parseDate(map['updatedAt']),
      deletedAt: DateHelper.parseDate(map['deletedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory TeamModel.fromJson(String source) => TeamModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TeamModel(id: $id, gameId: $gameId, uuid: $uuid, name: $name, emblem: $emblem, players: $players, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(covariant TeamModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.gameId == gameId &&
      other.uuid == uuid &&
      other.name == name &&
      other.emblem == emblem &&
      listEquals(other.players, players) &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return 
      id.hashCode ^
      gameId.hashCode ^
      uuid.hashCode ^
      name.hashCode ^
      emblem.hashCode ^
      players.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      deletedAt.hashCode;
  }
}
