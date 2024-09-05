import 'package:flutter_newsapp/models/article.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NetworkResponse {
  static const String baseUrl = "https://newsapi.org/v2/everything";
  static const String apiKey = "013dcbad9e834cb49ea6606b23d332b6";
  static Future<List<NewsApi>> fetchNews(
      {String query = "tesla", String from = "2024-08-02"}) async {
    final url =
        '$baseUrl?q=$query&from=$from&sortBy=publishedAt&apiKey=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return compute(parseNews, response.body);
    } else if (response.statusCode == 404) {
      throw Exception("Not Found");
    } else {
      throw Exception("Can't get news");
    }
  }

  static List<NewsApi> parseNews(String responseBody) {
    final parsed = json.decode(responseBody);
    var list = parsed['articles'] as List<dynamic>;
    List<NewsApi> news = list.map((model) => NewsApi.fromJson(model)).toList();
    return news;
  }
}
