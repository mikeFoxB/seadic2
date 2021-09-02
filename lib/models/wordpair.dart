import 'package:flutter/foundation.dart';


@immutable
class Wordpair {

  const Wordpair({
    required this.en,
    required this.th,
  });

  final String en;
  final String th;

  factory Wordpair.fromJson(Map<String,dynamic> json) => Wordpair(
    en: json['en'] as String,
    th: json['th'] as String
  );
  
  Map<String, dynamic> toJson() => {
    'en': en,
    'th': th
  };

  Wordpair clone() => Wordpair(
    en: en,
    th: th
  );


  Wordpair copyWith({
    String? en,
    String? th
  }) => Wordpair(
    en: en ?? this.en,
    th: th ?? this.th,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Wordpair && en == other.en && th == other.th;

  @override
  int get hashCode => en.hashCode ^ th.hashCode;
}
