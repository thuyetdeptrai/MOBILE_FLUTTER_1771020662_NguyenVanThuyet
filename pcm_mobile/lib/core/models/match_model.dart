import 'package:intl/intl.dart';

class MatchModel {
  final int id;
  final int? courtId;
  final String courtName;
  final DateTime matchDate;
  final String startTime; // "HH:mm:ss"
  
  final MatchPlayer team1Player1;
  final MatchPlayer? team1Player2;
  final MatchPlayer team2Player1;
  final MatchPlayer? team2Player2;
  
  final int team1Score;
  final int team2Score;
  
  final int status; // 0: Scheduled, 1: InProgress, 2: Completed, 3: Cancelled
  final int type; // 0: Friendly, 1: Ranked, 2: Tournament
  final int winner; // 0: None, 1: Team1, 2: Team2
  
  MatchModel({
    required this.id,
    this.courtId,
    required this.courtName,
    required this.matchDate,
    required this.startTime,
    required this.team1Player1,
    this.team1Player2,
    required this.team2Player1,
    this.team2Player2,
    this.team1Score = 0,
    this.team2Score = 0,
    this.status = 0,
    this.type = 0,
    this.winner = 0,
  });

  bool get isCompleted => status == 2;
  bool get isDoubles => team1Player2 != null && team2Player2 != null;
  
  String get scoreDisplay => isCompleted ? '$team1Score - $team2Score' : 'vs';

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] ?? 0,
      courtId: json['courtId'],
      courtName: json['courtName'] ?? 'Sân ngoài',
      matchDate: DateTime.tryParse(json['matchDate'] ?? '') ?? DateTime.now(),
      startTime: json['startTime']?.toString() ?? '00:00:00',
      team1Player1: MatchPlayer.fromJson(json['team1Player1'] ?? {}),
      team1Player2: json['team1Player2'] != null ? MatchPlayer.fromJson(json['team1Player2']) : null,
      team2Player1: MatchPlayer.fromJson(json['team2Player1'] ?? {}),
      team2Player2: json['team2Player2'] != null ? MatchPlayer.fromJson(json['team2Player2']) : null,
      team1Score: json['team1Score'] ?? 0,
      team2Score: json['team2Score'] ?? 0,
      status: json['status'] ?? 0,
      type: json['type'] ?? 0,
      winner: json['winner'] ?? 0,
    );
  }
}

class MatchPlayer {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final double duprRating;
  
  MatchPlayer({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    required this.duprRating,
  });
  
  factory MatchPlayer.fromJson(Map<String, dynamic> json) {
    return MatchPlayer(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? 'Unknown',
      avatarUrl: json['avatarUrl'],
      duprRating: (json['duprRating'] as num?)?.toDouble() ?? 3.0,
    );
  }
}
