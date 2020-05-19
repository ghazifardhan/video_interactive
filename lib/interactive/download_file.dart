import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class DownloadFile extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<DownloadFile> {
  Stream<FileResponse> fileStream;
  var url = 'https://s3-ap-southeast-1.amazonaws.com//kriyapeople/86b7e43b-aaee-44ee-a03c-cc76b58354fe';

  void _downloadFile() {
    setState(() {
      fileStream = DefaultCacheManager().getFileStream(url, withProgress: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (fileStream == null) {
      return Scaffold(
        appBar: _appBar(),
        body: const ListTile(
            title: Text('Tap the floating action button to download.')),
        floatingActionButton: Fab(
          downloadFile: _downloadFile,
        ),
      );
    }
    return DownloadPage(
      fileStream: fileStream,
      downloadFile: _downloadFile,
      clearCache: _clearCache,
      url: url,
    );
  }

  void _clearCache() {
    DefaultCacheManager().emptyCache();
    setState(() {
      fileStream = null;
    });
  }
}

class DownloadPage extends StatelessWidget {
  final Stream<FileResponse> fileStream;
  final VoidCallback downloadFile;
  final VoidCallback clearCache;
  final String url;

  const DownloadPage(
      {Key key, this.fileStream, this.downloadFile, this.clearCache, this.url})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FileResponse>(
      stream: DefaultCacheManager().getFileStream(url, withProgress: true),
      builder: (context, snapshot) {
        Widget body;

        var loading = !snapshot.hasData || snapshot.data is DownloadProgress;

        if (snapshot.hasError) {
          body = ListTile(
            title: const Text('Error'),
            subtitle: Text(snapshot.error.toString()),
          );
        } else if (loading) {
          body = ProgressIndicator(progress: snapshot.data as DownloadProgress);
        } else {
          body = FileInfoWidget(
            fileInfo: snapshot.data as FileInfo,
            clearCache: clearCache,
          );
        }

        return Scaffold(
          appBar: _appBar(),
          body: body,
          floatingActionButton: !loading
              ? Fab(
                  downloadFile: downloadFile,
                )
              : null,
        );
      },
    );
  }
}

AppBar _appBar() {
  return AppBar(
    title: const Text('Flutter Cache Manager Demo'),
  );
}

class Fab extends StatelessWidget {
  final VoidCallback downloadFile;
  const Fab({Key key, this.downloadFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: downloadFile,
      tooltip: 'Download',
      child: Icon(Icons.cloud_download),
    );
  }
}

class ProgressIndicator extends StatelessWidget {
  final DownloadProgress progress;
  const ProgressIndicator({Key key, this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("progress ${progress.downloaded}");
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 50.0,
            height: 50.0,
            child: CircularProgressIndicator(
              value: progress?.progress,
            ),
          ),
          const SizedBox(width: 20.0),
          const Text('Downloading'),
        ],
      ),
    );
  }
}

class FileInfoWidget extends StatelessWidget {
  final FileInfo fileInfo;
  final VoidCallback clearCache;

  const FileInfoWidget({Key key, this.fileInfo, this.clearCache})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    print(fileInfo.file.path);
    return ListView(
      children: <Widget>[
        ListTile(
          title: const Text('Original URL'),
          subtitle: Text(fileInfo.originalUrl),
        ),
        if (fileInfo.file != null)
          ListTile(
            title: const Text('Local file path'),
            subtitle: Text(fileInfo.file.path),
          ),
        ListTile(
          title: const Text('Loaded from'),
          subtitle: Text(fileInfo.source.toString()),
        ),
        ListTile(
          title: const Text('Valid Until'),
          subtitle: Text(fileInfo.validTill.toIso8601String()),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: RaisedButton(
            child: const Text('CLEAR CACHE'),
            onPressed: clearCache,
          ),
        ),
      ],
    );
  }
}