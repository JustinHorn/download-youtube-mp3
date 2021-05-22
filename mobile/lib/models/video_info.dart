class VideoInfo {
  final String code;
  final String title;
  final String thumbnail;
  final int seconds;
  final String audioURL;
  final String taskId;

  VideoInfo(this.code, this.title, this.thumbnail, this.seconds, this.audioURL,
      this.taskId);

  static VideoInfo fromJSON(Map<String, dynamic> json) {
    return VideoInfo(
      json['code'],
      json['title'],
      json['thumbnail'],
      json['lengthSeconds'],
      json['audioURL'],
      json['taskId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'title': title,
      'thumbnail': thumbnail,
      'seconds': seconds,
      'audioURL': audioURL,
      'taskId': taskId,
    };
  }
}
