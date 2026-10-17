import 'dart:convert';
import 'package:esportly/core/enum/enums.dart';

class RoomEventModel {
  final RoomEventType type;
  final int? userId;
  final List<int> participants;

  const RoomEventModel({
    required this.type,
    this.userId,
    this.participants = const [],
  });

  factory RoomEventModel.fromMap(Map<String, dynamic> map) {
    final typeStr   = map['type']   as String? ?? '';
    final statusStr = map['status'] as String? ?? '';
    final type = switch (typeStr) {
      'room'   => statusStr == 'open' ? RoomEventType.open : RoomEventType.close,
      'user'   => statusStr == 'join' ? RoomEventType.join : RoomEventType.exit,
      'open' => RoomEventType.open,
      'close' => RoomEventType.close,
      'join' => RoomEventType.join,
      'exit'   => RoomEventType.exit,
      _        => RoomEventType.open,
    };
    final rawIds = map['participants'] ?? map['present_ids'];
    final participants = rawIds is List
        ? rawIds.map((e) => e is int ? e : int.tryParse(e.toString())).whereType<int>().toList()
        : <int>[];
    return RoomEventModel(
      type: type,
      userId: map['user_id'] as int?,
      participants: participants,
    );
  }

  Map<String, dynamic> toMap() => {
    'type': switch (type) {
      RoomEventType.open  => 'open',
      RoomEventType.close => 'close',
      RoomEventType.join  => 'join',
      RoomEventType.exit  => 'exit',
    },
    'user_id': userId,
    'present_ids': participants,
  };

  String toJson() => json.encode(toMap());

  factory RoomEventModel.fromJson(String source) => RoomEventModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
