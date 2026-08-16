import 'package:dio/dio.dart';
import 'package:movie_journal/features/movie/data/data_sources/movie_api.dart';
import 'package:movie_journal/features/movie/data/models/detailed_movie.dart';
import 'package:movie_journal/features/movie/data/models/movie_image.dart';

class MovieRepository {
  final MovieAPI api;
  final String _language;

  MovieRepository(this.api, {String language = 'en-US'}) : _language = language;

  Future<MovieListResponse> search({
    required String query,
    required int page,
    CancelToken? cancelToken,
  }) async {
    final data = await api.searchMovies(
      query: query,
      page: page,
      language: _language,
      cancelToken: cancelToken,
    );
    return data;
  }

  Future<MovieListResponse> popular({
    required int page,
    CancelToken? cancelToken,
  }) async {
    final data = await api.popularMovies(
      page: page,
      language: _language,
      cancelToken: cancelToken,
    );
    return data;
  }

  Future<DetailedMovie> getMovieDetails(int id) async {
    final data = await api.getMovieDetails(id: id, language: _language);
    return data;
  }

  Future<
    ({
      List<MovieImage> posters,
      List<MovieImage> logos,
      List<MovieImage> backdrops,
    })
  >
  getMovieImages({required int id, String? language}) async {
    final data = await api.getMovieImages(id: id, language: language);
    return data;
  }
}
