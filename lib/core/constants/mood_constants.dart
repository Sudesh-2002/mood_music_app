enum MoodLabel { happy, sad, angry, surprised, neutral, fearful, disgusted }

enum MusicSource { spotify, youtube, local }

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
}