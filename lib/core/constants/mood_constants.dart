enum MoodLabel { happy, sad, angry, surprised, neutral, fearful, disgusted }

enum MusicSource { spotify, youtube, local }

extension MoodLabelExtension on MoodLabel {
  String get displayName {
    switch (this) {
      case MoodLabel.happy: return 'Happy';
      case MoodLabel.sad: return 'Sad';
      case MoodLabel.angry: return 'Angry';
      case MoodLabel.surprised: return 'Surprised';
      case MoodLabel.neutral: return 'Neutral';
      case MoodLabel.fearful: return 'Fearful';
      case MoodLabel.disgusted: return 'Disgusted';
    }
  }

  String get emoji {
    switch (this) {
      case MoodLabel.happy: return '😊';
      case MoodLabel.sad: return '😢';
      case MoodLabel.angry: return '😠';
      case MoodLabel.surprised: return '😲';
      case MoodLabel.neutral: return '😐';
      case MoodLabel.fearful: return '😨';
      case MoodLabel.disgusted: return '🤢';
    }
  }
}

extension MusicSourceExtension on MusicSource {
  String get displayName {
    switch (this) {
      case MusicSource.spotify: return 'Spotify';
      case MusicSource.youtube: return 'YouTube';
      case MusicSource.local: return 'Local Files';
    }
  }
}

class MoodToGenre {
  static const Map<MoodLabel, List<String>> spotifySeeds = {
    MoodLabel.happy:     ['pop', 'dance', 'happy'],
    MoodLabel.sad:       ['sad', 'acoustic', 'piano'],
    MoodLabel.angry:     ['metal', 'rock', 'punk'],
    MoodLabel.surprised: ['electronic', 'edm', 'party'],
    MoodLabel.neutral:   ['chill', 'ambient', 'indie'],
    MoodLabel.fearful:   ['ambient', 'classical', 'sleep'],
    MoodLabel.disgusted: ['blues', 'jazz', 'soul'],
  };

  static const Map<MoodLabel, List<String>> youtubeQueries = {
    MoodLabel.happy:     ['happy upbeat music', 'feel good hits'],
    MoodLabel.sad:       ['sad emotional music', 'acoustic sad songs'],
    MoodLabel.angry:     ['rock metal intense music', 'aggressive beats'],
    MoodLabel.surprised: ['edm electronic music', 'energetic party music'],
    MoodLabel.neutral:   ['chill lofi music', 'relaxing indie'],
    MoodLabel.fearful:   ['calming ambient music', 'peaceful classical'],
    MoodLabel.disgusted: ['blues jazz music', 'soul rhythm blues'],
  };
}