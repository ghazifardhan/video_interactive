import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VideoQuality extends StatefulWidget {
 
  @override
  State<StatefulWidget> createState() {
    return _VideoQualityState();
  }

}

class _VideoQualityState extends State<VideoQuality> {

  List<String> videos = new List<String>();

  @override
  void initState() {
    super.initState();

    // 4k
    videos.add("https://r3---sn-2a5thxqp5-jb3z.googlevideo.com/videoplayback?expire=1589897696&ei=gJXDXsfpCbyEx_APtMWv6Ak&ip=80.187.140.26&id=o-AIzH2TN8A1839wUk8lnJE87rp_bmBMhpjvXAVl2ARESV&itag=313&aitags=133%2C134%2C135%2C136%2C137%2C160%2C242%2C243%2C244%2C247%2C248%2C271%2C278%2C313&source=youtube&requiressl=yes&vprv=1&mime=video%2Fwebm&gir=yes&clen=384802111&dur=199.032&lmt=1561115411068043&fvip=3&keepalive=yes&c=WEB&txp=5431432&sparams=expire%2Cei%2Cip%2Cid%2Caitags%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cgir%2Cclen%2Cdur%2Clmt&sig=AOq0QJ8wRQIgZEM-_nQvJpaDQJXa--o69m3Fcn3k0CuwkayrckiFK9sCIQDccf65Jtqd9BbMYpBsoQaMf6JennXqs8QueypwkL5_fg%3D%3D&video_id=4It9yQSjaGA&title=Istanbul%2C+Turkey+%F0%9F%87%B9%F0%9F%87%B7+-+by+drone+%5B4K%5D&redirect_counter=1&rm=sn-4g5ezs7s&fexp=23812955&req_id=ebcd1cef645da3ee&cms_redirect=yes&ipbypass=yes&mh=-8&mip=202.80.218.152&mm=31&mn=sn-2a5thxqp5-jb3z&ms=au&mt=1589876609&mv=m&mvi=2&pl=24&lsparams=ipbypass,mh,mip,mm,mn,ms,mv,mvi,pl&lsig=AG3C_xAwRAIgefIiwvXa28Q3TPA3me52WuiTHq6SI3WA5DunukcO1LkCIC2M5WZh1OlqXYqG4MezuTEGEpyiCEbT5oLvOfzWzJbF");
    // 1080p
    videos.add("https://r3---sn-2a5thxqp5-jb3z.googlevideo.com/videoplayback?expire=1589897696&ei=gJXDXsfpCbyEx_APtMWv6Ak&ip=80.187.140.26&id=o-AIzH2TN8A1839wUk8lnJE87rp_bmBMhpjvXAVl2ARESV&itag=248&aitags=133%2C134%2C135%2C136%2C137%2C160%2C242%2C243%2C244%2C247%2C248%2C271%2C278%2C313&source=youtube&requiressl=yes&vprv=1&mime=video%2Fwebm&gir=yes&clen=57446667&dur=199.032&lmt=1561114407124208&fvip=3&keepalive=yes&c=WEB&txp=5431432&sparams=expire%2Cei%2Cip%2Cid%2Caitags%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cgir%2Cclen%2Cdur%2Clmt&sig=AOq0QJ8wRgIhAN7WB8a-aTJlJ5Ni_o6LsR-ufBRfaTFZgyr6ho5X3V-OAiEAyNb9LgQKtdRDvEYmzn7Js4dUajdLT3VQ4MNmAL2oJlY%3D&video_id=4It9yQSjaGA&title=Istanbul%2C+Turkey+%F0%9F%87%B9%F0%9F%87%B7+-+by+drone+%5B4K%5D&redirect_counter=1&rm=sn-4g5ezs7s&fexp=23812955&req_id=358c1e7db4c3a3ee&cms_redirect=yes&ipbypass=yes&mh=-8&mip=202.80.218.152&mm=31&mn=sn-2a5thxqp5-jb3z&ms=au&mt=1589876728&mv=m&mvi=2&pcm2cms=yes&pl=24&lsparams=ipbypass,mh,mip,mm,mn,ms,mv,mvi,pcm2cms,pl&lsig=AG3C_xAwRgIhAKdCnu1UHasESrcmBvhF5oPyuSjBsZhB9J9jNcGIjtvHAiEAuXGCRVSSGaoRof6GwGjTSEbsQklvG9CaZfGmqhbtAuw%3D");
    // 720p
    videos.add("https://r3---sn-npoe7n7z.googlevideo.com/videoplayback?expire=1589897696&ei=gJXDXsfpCbyEx_APtMWv6Ak&ip=80.187.140.26&id=o-AIzH2TN8A1839wUk8lnJE87rp_bmBMhpjvXAVl2ARESV&itag=22&source=youtube&requiressl=yes&vprv=1&mime=video%2Fmp4&ratebypass=yes&dur=199.087&lmt=1561114406114595&fvip=3&c=WEB&txp=5432432&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cratebypass%2Cdur%2Clmt&sig=AOq0QJ8wRgIhAIHj7YHOSe_8GMXzQRdi6vH9U4MWLq4ftWbPJa6B_ojMAiEAn-G-LN-ljOCo-jz-YPaTzQv4Kor9twgFEM0SZP739DQ%3D&contentlength=46120140&video_id=4It9yQSjaGA&title=Istanbul%2C+Turkey+%F0%9F%87%B9%F0%9F%87%B7+-+by+drone+%5B4K%5D&rm=sn-4g5ezs7s&fexp=23812955&req_id=a512394c4d84a3ee&ipbypass=yes&redirect_counter=2&cm2rm=sn-2a5thxqp5-jb3z7s&cms_redirect=yes&mh=-8&mip=202.80.218.152&mm=29&mn=sn-npoe7n7z&ms=rdu&mt=1589876789&mv=m&mvi=2&pl=24&lsparams=ipbypass,mh,mip,mm,mn,ms,mv,mvi,pl&lsig=AG3C_xAwRQIhAMRsDn_HQkn7aOfiBOU_WEn6priAOAUfpR4KeGJ7KgubAiA3z1I9SWId4yTlI0KsHkNwj9bBe4jCb2YCl4F3hvnlNw%3D%3D");
    // 360p
    videos.add("https://r3---sn-npoe7n7z.googlevideo.com/videoplayback?expire=1589897696&ei=gJXDXsfpCbyEx_APtMWv6Ak&ip=80.187.140.26&id=o-AIzH2TN8A1839wUk8lnJE87rp_bmBMhpjvXAVl2ARESV&itag=18&source=youtube&requiressl=yes&vprv=1&mime=video%2Fmp4&gir=yes&clen=16300401&ratebypass=yes&dur=199.087&lmt=1561114171643861&fvip=3&c=WEB&txp=5431432&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cgir%2Cclen%2Cratebypass%2Cdur%2Clmt&sig=AOq0QJ8wRQIhANA_oz5b0UkT3k6E_xKjeharCmqXd2ZucdJwJxn_5x_YAiAzTGki0-BeMI9_wnESNlOHiXxQk2UwDNALoutCkZ6krA%3D%3D&video_id=4It9yQSjaGA&title=Istanbul%2C+Turkey+%F0%9F%87%B9%F0%9F%87%B7+-+by+drone+%5B4K%5D&rm=sn-4g5ezs7s&fexp=23812955&req_id=a11126db84bfa3ee&ipbypass=yes&redirect_counter=2&cm2rm=sn-2a5thxqp5-jb3z7s&cms_redirect=yes&mh=-8&mip=202.80.218.152&mm=29&mn=sn-npoe7n7z&ms=rdu&mt=1589876789&mv=m&mvi=2&pl=24&lsparams=ipbypass,mh,mip,mm,mn,ms,mv,mvi,pl&lsig=AG3C_xAwRQIgKZ7gAfngDxsaDbdSjkfolDZMUV1NF97KLQISQUhdzW8CIQDuBZZV-8bwYJ8R8L2n29suHW8g8LJzRPYkHVsxmzAWJA%3D%3D");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text("Video Quality"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: videos.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 10);
              }, 
              itemBuilder: (context, index) {
                return CupertinoButton(
                  onPressed: () {
                    print(videos[index]);
                  },
                  child: new Text(generateText(index)), 
                );
              }, 
            )
          ],
        ),
      ),
    );
  }

  String generateText(int index) {
    switch (index) {
      case 0:
        return "4K Video";
      case 1:
        return "1080p Video";
      case 2:
        return "720p Video";
      case 3:
        return "360p Video";
      default:
        return "Undefined";
    }
  }

}