import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class SearchResponse {
  final List<Track> collection;
  final int totalResults;
  final String nextHref;
  final String queryUrn;

  SearchResponse(
      {this.collection, this.totalResults, this.nextHref, this.queryUrn});

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    List<Track> list = [];
    if (json['collection'].length > 0) {
      for (var item in json['collection']) {
        Track track = Track.fromJson(item);
        if (track != null) {
          list.add(track);
        } else {
          print(
              "Corrupt Track: Title: ${item['title']}; ID: ${item['id']}; URI: ${item['uri']}");
        }
      }
    }
    return SearchResponse(
      collection: list,
      totalResults: json['total_results'],
      nextHref: json['next_href'],
      queryUrn: json['query_urn'],
    );
  }
}

class Track {
  final int id;
  final String title;
  final String description;
  final String uri;
  final String transcodingURL;
  String streamUrl;
  final Duration duration;
  final int playbackCount;
  final String artwork;
  final int likesCount;
  final DateTime date;

  Track({
    this.id,
    this.title,
    this.description,
    this.uri,
    this.transcodingURL,
    this.duration,
    this.playbackCount,
    this.artwork,
    this.likesCount,
    this.date,
    this.streamUrl,
  });

  void setStreamUrl(String streamUrl) {
    this.streamUrl = streamUrl;
  }

  String printDuration() {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(this.duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(this.duration.inSeconds.remainder(60));
    return "${twoDigits(this.duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String printPlaycount() {
    var numberFormat = NumberFormat.compact(locale: 'en');
    return numberFormat.format(this.playbackCount);
  }

  String printLikescount() {
    var numberFormat = NumberFormat.compact(locale: 'en');
    return numberFormat.format(this.likesCount);
  }

  String printUploadSince() {
    var now = DateTime.now();
    var old = this.date;
    Duration difference = now.difference(old);
    final timeAgo = now.subtract(difference);

    return timeago.format(timeAgo);
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    String transcodingURL = "";
    for (var transcoding in json['media']['transcodings']) {
      if (transcoding["format"]["mime_type"] == "audio/mpeg") {
        transcodingURL = transcoding["url"];
        break;
      }
    }
    if (transcodingURL != "") {
      return Track(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        uri: json['uri'],
        transcodingURL: transcodingURL,
        duration: Duration(milliseconds: json['duration']),
        playbackCount: json['playback_count'],
        artwork: json['artwork_url'],
        likesCount: json['likes_count'],
        date: DateTime.parse(json['display_date']),
      );
    } else {
      // This will ignore all track which do not consist of mp3 streams
      return null;
    }
  }
}
