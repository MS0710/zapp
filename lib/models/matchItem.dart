class MatchItem {
  final String? title;
  final int? currentPlayers;
  final int? maxPlayers;
  final String? location;
  final DateTime? date;

  MatchItem({
    this.title,
    this.currentPlayers,
    this.maxPlayers,
    this.location,
    this.date,
  });

  bool get isPlaceholder => title == null;
}
