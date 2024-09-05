import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/article.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      debugShowCheckedModeBanner: false,
      builder: DevicePreview.appBuilder,
      title: 'Flutter Demo',
      home: NewsUI(),
    );
  }
}

class NewsUI extends StatefulWidget {
  const NewsUI({super.key});

  @override
  State<NewsUI> createState() => _NewsUIState();
}

class _NewsUIState extends State<NewsUI> {
  final Dio dio = Dio();
  List<NewsApi> articles = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("News App"),
      ),
      body: articles.isEmpty ? _loading() : _buildUI(),
    );
  }

  Widget _loading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildUI() {
    return ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return ListTile(
            onTap: () {
              _launchUrl(
                Uri.parse(article.url ?? ""),
              );
            },
            leading: Image.network(
              article.urlToImage!,
              height: 250,
              width: 100,
              fit: BoxFit.cover,
            ),
            title: Text(article.title ?? ""),
            subtitle: Text(article.publishedAt ?? ""),
          );
        });
  }

  Future<void> _getNews() async {
    final response = await dio.get(
        "https://newsapi.org/v2/everything?q=tesla&from=2024-08-05&sortBy=publishedAt&apiKey=013dcbad9e834cb49ea6606b23d332b6");
    final articlesJson = response.data['articles'] as List;
    setState(() {
      List<NewsApi> newsArticles =
          articlesJson.map((a) => NewsApi.fromJson(a)).toList();
      newsArticles = newsArticles.where((a) => a.title != "[Removed]").toList();
      articles = newsArticles;
    });
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
