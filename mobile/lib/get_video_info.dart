import 'dart:convert';
import 'package:http/http.dart' as http;

getVideoInfo(String videoCode) async {
  final response = await http.get(Uri.parse(
      'https://www.youtube.com/get_video_info?video_id=$videoCode&html5=1'));
  if (response.statusCode == 200) {
    var decoded = utf8.decode(response.bodyBytes);

    var info = Uri.splitQueryString(decoded);

    var player_response = findPlayerResponse(info);

    var details = player_response['microformat']['playerMicroformatRenderer'];

    var seconds = int.parse(details['lengthSeconds']);
    var title = details['title']['simpleText'];
    var thumbnail = details['thumbnail']['thumbnails'][0]['url'];
    print(player_response['streamingData']['adaptiveFormats']
        .map((x) => x['mimeType']));
    var audioURL = player_response['streamingData']['adaptiveFormats']
        .firstWhere((x) =>
            x['mimeType'].contains("audio/mp3") ||
            x['mimeType'].contains("audio/mp4"))['url'];

    //print(player_response['streamingData']['adaptiveFormats']);
    var data = {
      'code': videoCode,
      'seconds': seconds,
      'title': title,
      'thumbnail': thumbnail,
      'audioURL': audioURL,
    };
    return data;
  }
}

findPlayerResponse(info) {
  var jsonClosingChars = r"^[)\]}'\s]+";

  String player_response = info != null
      ? ((info['args'] != null
          ? info['args']['player_response']
          : info['player_response'] ??
              info['playerResponse'] ??
              info['embedded_player_response']))
      : null;

  player_response = player_response.replaceAll(jsonClosingChars, "");
  return jsonDecode(player_response);
}
