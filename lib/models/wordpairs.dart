import 'package:flutter/foundation.dart';
import 'wordpair.dart';

@immutable
class Wordpairs {

  const Wordpairs({
    required this.wordpairs,
  });

  final List<Wordpair> wordpairs;

  factory Wordpairs.fromJson(Map<String,dynamic> json) => Wordpairs(
    wordpairs: (json['wordpairs'] as List? ?? []).map((e) => Wordpair.fromJson(e as Map<String, dynamic>)).toList()
  );
  
  Map<String, dynamic> toJson() => {
    'wordpairs': wordpairs.map((e) => e.toJson()).toList()
  };

  Wordpairs clone() => Wordpairs(
    wordpairs: wordpairs.map((e) => e.clone()).toList()
  );


  Wordpairs copyWith({
    List<Wordpair>? wordpairs
  }) => Wordpairs(
    wordpairs: wordpairs ?? this.wordpairs,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Wordpairs && wordpairs == other.wordpairs;

  @override
  int get hashCode => wordpairs.hashCode;
}
