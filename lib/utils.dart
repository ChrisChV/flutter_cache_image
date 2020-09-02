import 'package:cache_image/constants.dart';

class Utils{

  static bool isGsUrl(String url){
    Uri uri = Uri.parse(url);
    return uri.scheme == Constants.GS_SCHEME;
  }

}