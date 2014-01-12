library movie_board.models;

import 'dart:convert';
import 'dart:html';

import 'package:polymer/polymer.dart';
import 'services.dart';


/**
 * Data which are storage on the client
 */
class MovieStorage {
  
  bool favorite;
  String comment;
  int _movieId;
  
  MovieStorage.fromLocalStorage(this._movieId) {
    try {
      String data = window.localStorage["${_movieId}"];
      Map map = JSON.decode(data);
      favorite = map['fav'] != null ? map['fav'] : false;
      comment = map['comment'] != null ? map['comment'] : "";
    }
    catch(e) {
      favorite = false;
      comment = "";
    }
  }
  
  save() => window.localStorage["${_movieId}"] = '{ "fav" : ${favorite}, "comment" : "${comment}" }';
}

/**
 * A movie model
 */
@observable
class Movie extends Object with Observable {
  
  // Available comparators
  static final Map _comparators = {
    "title": (Movie a, Movie b) => a.title.compareTo(b.title),
    "vote": (Movie a, Movie b) => a.voteAverage.compareTo(b.voteAverage) * -1,
    "favorite": (Movie a, Movie b) => a.favorite && !b.favorite ? -1 : b.favorite && !a.favorite ? 1 : 0,
  };
  
  int id;
  String tag;
  String title;
  String posterPath;
  String releasedDate;
  int voteAverage;
  int voteCount;
  @observable bool favorite = false;
  
  Movie(this.title, this.posterPath);
  
  Movie.fromMap(Map<String, Object> map) {
    id = map['id'];
    tag = map['tag'];
    title = map['title'] != null ? map['title'] : map['original_name'];
    posterPath = map['poster_path'] != null ? 'json/images/posters${map['poster_path']}' : 'img/no-poster-w130.jpg';
    releasedDate = map['release_date'];
    voteAverage = map['vote_average'] != null ? (map['vote_average'] as num).toInt() : 0;
    voteCount = map['vote_count'];
  }
  
  /// Get a comparator according to a field: if it does not exist then all movies are equals
  static getComparator(String field) => _comparators.containsKey(field) ? _comparators[field] : (a, b) => 0;

  /// Hashcode relies on movie's id
  int get hashCode => id;
  /// Equals relies also on movies's id
  bool operator ==(Movie other) => other != null ? id == other.id : false;
}

/**
 * A movie detail is a [Movie] with extends attributes
 */
class MovieDetail extends Movie {
  int id;
  String tag;
  String title;
  String posterPath;
  String releaseDate;
  int voteAverage;
  int voteCount;
  
  String genre;
  String tagLine;
  String overview;
  String productionCountry;
  String trailer;
  String country;
  
  MovieDetail.fromMap(Map<String, Object> map) : super.fromMap(map) {
    genre = map['genres'] != null && (map['genres'] as List).isNotEmpty ? (map['genres'] as List)[0]['name'] : '';
    tagLine = map['tagline']!= null && (map['tagline'] as String).isNotEmpty ? "\"${map['tagline']}\"" : "";
    overview = map['overview'];
    productionCountry = map['production_countries'] != null && (map['production_countries'] as List).isNotEmpty ? (map['production_countries'] as List)[0]['name'] : "";
    List trailers = map['trailers'] != null ? ((map['trailers'] as Map)['youtube'] as List) : [];
    trailer = trailers.isNotEmpty? ((map['trailers'] as Map)['youtube'] as List)[0]['source'] : '';
    country = map['production_countries'] != null ? ((map['production_countries'] as List)[0] as Map)['name'] : "";
  }
}

/**
 * Menu
 */
@observable
class Menu extends Object with Observable {
  
  int id;
  @observable String name;
  bool selected = false;
  MoviesRetriever retriever;
  
  Menu(this.id, this.name, this.retriever, [this.selected = false]);
  Menu.fromMap(Map<String, Object> map) {
    id = map['id'];
    name = map['name'];
  }
}