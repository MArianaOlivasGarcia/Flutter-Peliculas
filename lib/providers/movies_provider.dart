import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculasapp/helpers/debouncer.dart';
import 'package:peliculasapp/models/models.dart';

class MoviesProvider extends ChangeNotifier {
  String _apiKey = '33df75fbfb8a42f0c4b82954d0c28435';
  String _baseUrl = 'api.themoviedb.org';
  String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  int _popularPage = 0;

  Map<int, List<Cast>> moviesCast = {};

  final debouncer = Debouncer(
    duration: Duration( milliseconds: 500 ),
  );

  final StreamController<List<Movie>> _suggestionsStreamController =
      new StreamController.broadcast();

  Stream<List<Movie>> get suggestionsStream =>
      this._suggestionsStreamController.stream;

  MoviesProvider() {
    print('MoviesProvider inicializando...');
    this.getOnDisplayMovies();
    this.getPopularMovies();
  }

  Future<String> _getJsonData(String endpoint, [int page = 1]) async {
    var url = Uri.https(_baseUrl, endpoint, {
      'api_key': _apiKey,
      'language': _language,
      'page': '$page',
    });

    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async {
    final jsonData = await this._getJsonData('3/movie/now_playing');

    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);

    this.onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }

  getPopularMovies() async {
    this._popularPage++;
    final jsonData =
        await this._getJsonData('3/movie/popular', this._popularPage);
    final popularResponse = PopularResponse.fromJson(jsonData);

    this.popularMovies = [...popularMovies, ...popularResponse.results];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int idMovie) async {
    /* Revisar el mapa, para ver si ya lo hemos cargado */
    if (moviesCast.containsKey(idMovie)) return moviesCast[idMovie];

    final jsonData = await this._getJsonData('3/movie/$idMovie/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);

    /* Añadirlo a nuestro Map */
    moviesCast[idMovie] = creditsResponse.cast;

    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovies(String query) async {
    var url = Uri.https(_baseUrl, '3/search/movie',
        {'api_key': _apiKey, 'language': _language, 'query': query});

    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);

    return searchResponse.results;
  }


  void getSuggestionsByQuery(String query){

    debouncer.value = '';
    debouncer.onValue = ( value ) async{
      /* print('Tenemos valor a buscar'); */
      final results = await this.searchMovies(value);
      this._suggestionsStreamController.add(results);
    };

    final timer = Timer.periodic( Duration( milliseconds: 300), (_) {
      debouncer.value = query;
    });

    Future.delayed( Duration( milliseconds: 301 ) )
        .then((_) => timer.cancel());

  }

}
