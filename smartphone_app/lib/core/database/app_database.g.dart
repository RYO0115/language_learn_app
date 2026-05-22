// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WordsTable extends Words with TableInfo<$WordsTable, Word> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
      'word', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _readingMeta =
      const VerificationMeta('reading');
  @override
  late final GeneratedColumn<String> reading = GeneratedColumn<String>(
      'reading', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _meaningMeta =
      const VerificationMeta('meaning');
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
      'meaning', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _partOfSpeechMeta =
      const VerificationMeta('partOfSpeech');
  @override
  late final GeneratedColumn<String> partOfSpeech = GeneratedColumn<String>(
      'part_of_speech', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, word, reading, meaning, partOfSpeech, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(Insertable<Word> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word')) {
      context.handle(
          _wordMeta, word.isAcceptableOrUnknown(data['word']!, _wordMeta));
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('reading')) {
      context.handle(_readingMeta,
          reading.isAcceptableOrUnknown(data['reading']!, _readingMeta));
    }
    if (data.containsKey('meaning')) {
      context.handle(_meaningMeta,
          meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta));
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
          _partOfSpeechMeta,
          partOfSpeech.isAcceptableOrUnknown(
              data['part_of_speech']!, _partOfSpeechMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Word map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Word(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      word: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word'])!,
      reading: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reading']),
      meaning: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meaning'])!,
      partOfSpeech: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}part_of_speech']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }
}

class Word extends DataClass implements Insertable<Word> {
  final int id;
  final String word;
  final String? reading;
  final String meaning;
  final String? partOfSpeech;
  final int createdAt;
  final int updatedAt;
  const Word(
      {required this.id,
      required this.word,
      this.reading,
      required this.meaning,
      this.partOfSpeech,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word'] = Variable<String>(word);
    if (!nullToAbsent || reading != null) {
      map['reading'] = Variable<String>(reading);
    }
    map['meaning'] = Variable<String>(meaning);
    if (!nullToAbsent || partOfSpeech != null) {
      map['part_of_speech'] = Variable<String>(partOfSpeech);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      id: Value(id),
      word: Value(word),
      reading: reading == null && nullToAbsent
          ? const Value.absent()
          : Value(reading),
      meaning: Value(meaning),
      partOfSpeech: partOfSpeech == null && nullToAbsent
          ? const Value.absent()
          : Value(partOfSpeech),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Word.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Word(
      id: serializer.fromJson<int>(json['id']),
      word: serializer.fromJson<String>(json['word']),
      reading: serializer.fromJson<String?>(json['reading']),
      meaning: serializer.fromJson<String>(json['meaning']),
      partOfSpeech: serializer.fromJson<String?>(json['partOfSpeech']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'word': serializer.toJson<String>(word),
      'reading': serializer.toJson<String?>(reading),
      'meaning': serializer.toJson<String>(meaning),
      'partOfSpeech': serializer.toJson<String?>(partOfSpeech),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Word copyWith(
          {int? id,
          String? word,
          Value<String?> reading = const Value.absent(),
          String? meaning,
          Value<String?> partOfSpeech = const Value.absent(),
          int? createdAt,
          int? updatedAt}) =>
      Word(
        id: id ?? this.id,
        word: word ?? this.word,
        reading: reading.present ? reading.value : this.reading,
        meaning: meaning ?? this.meaning,
        partOfSpeech:
            partOfSpeech.present ? partOfSpeech.value : this.partOfSpeech,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Word copyWithCompanion(WordsCompanion data) {
    return Word(
      id: data.id.present ? data.id.value : this.id,
      word: data.word.present ? data.word.value : this.word,
      reading: data.reading.present ? data.reading.value : this.reading,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Word(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('reading: $reading, ')
          ..write('meaning: $meaning, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, word, reading, meaning, partOfSpeech, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Word &&
          other.id == this.id &&
          other.word == this.word &&
          other.reading == this.reading &&
          other.meaning == this.meaning &&
          other.partOfSpeech == this.partOfSpeech &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WordsCompanion extends UpdateCompanion<Word> {
  final Value<int> id;
  final Value<String> word;
  final Value<String?> reading;
  final Value<String> meaning;
  final Value<String?> partOfSpeech;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
    this.reading = const Value.absent(),
    this.meaning = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WordsCompanion.insert({
    this.id = const Value.absent(),
    required String word,
    this.reading = const Value.absent(),
    required String meaning,
    this.partOfSpeech = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  })  : word = Value(word),
        meaning = Value(meaning),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Word> custom({
    Expression<int>? id,
    Expression<String>? word,
    Expression<String>? reading,
    Expression<String>? meaning,
    Expression<String>? partOfSpeech,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
      if (reading != null) 'reading': reading,
      if (meaning != null) 'meaning': meaning,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WordsCompanion copyWith(
      {Value<int>? id,
      Value<String>? word,
      Value<String?>? reading,
      Value<String>? meaning,
      Value<String?>? partOfSpeech,
      Value<int>? createdAt,
      Value<int>? updatedAt}) {
    return WordsCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
      reading: reading ?? this.reading,
      meaning: meaning ?? this.meaning,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (reading.present) {
      map['reading'] = Variable<String>(reading.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('reading: $reading, ')
          ..write('meaning: $meaning, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ExampleSentencesTable extends ExampleSentences
    with TableInfo<$ExampleSentencesTable, ExampleSentence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExampleSentencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
      'word_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES words (id) ON DELETE CASCADE'));
  static const VerificationMeta _sentenceEnMeta =
      const VerificationMeta('sentenceEn');
  @override
  late final GeneratedColumn<String> sentenceEn = GeneratedColumn<String>(
      'sentence_en', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sentenceJaMeta =
      const VerificationMeta('sentenceJa');
  @override
  late final GeneratedColumn<String> sentenceJa = GeneratedColumn<String>(
      'sentence_ja', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, wordId, sentenceEn, sentenceJa, order, label];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'example_sentences';
  @override
  VerificationContext validateIntegrity(Insertable<ExampleSentence> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word_id')) {
      context.handle(_wordIdMeta,
          wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta));
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('sentence_en')) {
      context.handle(
          _sentenceEnMeta,
          sentenceEn.isAcceptableOrUnknown(
              data['sentence_en']!, _sentenceEnMeta));
    } else if (isInserting) {
      context.missing(_sentenceEnMeta);
    }
    if (data.containsKey('sentence_ja')) {
      context.handle(
          _sentenceJaMeta,
          sentenceJa.isAcceptableOrUnknown(
              data['sentence_ja']!, _sentenceJaMeta));
    } else if (isInserting) {
      context.missing(_sentenceJaMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExampleSentence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExampleSentence(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      wordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_id'])!,
      sentenceEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sentence_en'])!,
      sentenceJa: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sentence_ja'])!,
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label']),
    );
  }

  @override
  $ExampleSentencesTable createAlias(String alias) {
    return $ExampleSentencesTable(attachedDatabase, alias);
  }
}

class ExampleSentence extends DataClass implements Insertable<ExampleSentence> {
  final int id;
  final int wordId;
  final String sentenceEn;
  final String sentenceJa;
  final int order;
  final String? label;
  const ExampleSentence(
      {required this.id,
      required this.wordId,
      required this.sentenceEn,
      required this.sentenceJa,
      required this.order,
      this.label});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word_id'] = Variable<int>(wordId);
    map['sentence_en'] = Variable<String>(sentenceEn);
    map['sentence_ja'] = Variable<String>(sentenceJa);
    map['order'] = Variable<int>(order);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    return map;
  }

  ExampleSentencesCompanion toCompanion(bool nullToAbsent) {
    return ExampleSentencesCompanion(
      id: Value(id),
      wordId: Value(wordId),
      sentenceEn: Value(sentenceEn),
      sentenceJa: Value(sentenceJa),
      order: Value(order),
      label:
          label == null && nullToAbsent ? const Value.absent() : Value(label),
    );
  }

  factory ExampleSentence.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExampleSentence(
      id: serializer.fromJson<int>(json['id']),
      wordId: serializer.fromJson<int>(json['wordId']),
      sentenceEn: serializer.fromJson<String>(json['sentenceEn']),
      sentenceJa: serializer.fromJson<String>(json['sentenceJa']),
      order: serializer.fromJson<int>(json['order']),
      label: serializer.fromJson<String?>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wordId': serializer.toJson<int>(wordId),
      'sentenceEn': serializer.toJson<String>(sentenceEn),
      'sentenceJa': serializer.toJson<String>(sentenceJa),
      'order': serializer.toJson<int>(order),
      'label': serializer.toJson<String?>(label),
    };
  }

  ExampleSentence copyWith(
          {int? id,
          int? wordId,
          String? sentenceEn,
          String? sentenceJa,
          int? order,
          Value<String?> label = const Value.absent()}) =>
      ExampleSentence(
        id: id ?? this.id,
        wordId: wordId ?? this.wordId,
        sentenceEn: sentenceEn ?? this.sentenceEn,
        sentenceJa: sentenceJa ?? this.sentenceJa,
        order: order ?? this.order,
        label: label.present ? label.value : this.label,
      );
  ExampleSentence copyWithCompanion(ExampleSentencesCompanion data) {
    return ExampleSentence(
      id: data.id.present ? data.id.value : this.id,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      sentenceEn:
          data.sentenceEn.present ? data.sentenceEn.value : this.sentenceEn,
      sentenceJa:
          data.sentenceJa.present ? data.sentenceJa.value : this.sentenceJa,
      order: data.order.present ? data.order.value : this.order,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExampleSentence(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('sentenceEn: $sentenceEn, ')
          ..write('sentenceJa: $sentenceJa, ')
          ..write('order: $order, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, wordId, sentenceEn, sentenceJa, order, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExampleSentence &&
          other.id == this.id &&
          other.wordId == this.wordId &&
          other.sentenceEn == this.sentenceEn &&
          other.sentenceJa == this.sentenceJa &&
          other.order == this.order &&
          other.label == this.label);
}

class ExampleSentencesCompanion extends UpdateCompanion<ExampleSentence> {
  final Value<int> id;
  final Value<int> wordId;
  final Value<String> sentenceEn;
  final Value<String> sentenceJa;
  final Value<int> order;
  final Value<String?> label;
  const ExampleSentencesCompanion({
    this.id = const Value.absent(),
    this.wordId = const Value.absent(),
    this.sentenceEn = const Value.absent(),
    this.sentenceJa = const Value.absent(),
    this.order = const Value.absent(),
    this.label = const Value.absent(),
  });
  ExampleSentencesCompanion.insert({
    this.id = const Value.absent(),
    required int wordId,
    required String sentenceEn,
    required String sentenceJa,
    this.order = const Value.absent(),
    this.label = const Value.absent(),
  })  : wordId = Value(wordId),
        sentenceEn = Value(sentenceEn),
        sentenceJa = Value(sentenceJa);
  static Insertable<ExampleSentence> custom({
    Expression<int>? id,
    Expression<int>? wordId,
    Expression<String>? sentenceEn,
    Expression<String>? sentenceJa,
    Expression<int>? order,
    Expression<String>? label,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wordId != null) 'word_id': wordId,
      if (sentenceEn != null) 'sentence_en': sentenceEn,
      if (sentenceJa != null) 'sentence_ja': sentenceJa,
      if (order != null) 'order': order,
      if (label != null) 'label': label,
    });
  }

  ExampleSentencesCompanion copyWith(
      {Value<int>? id,
      Value<int>? wordId,
      Value<String>? sentenceEn,
      Value<String>? sentenceJa,
      Value<int>? order,
      Value<String?>? label}) {
    return ExampleSentencesCompanion(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      sentenceEn: sentenceEn ?? this.sentenceEn,
      sentenceJa: sentenceJa ?? this.sentenceJa,
      order: order ?? this.order,
      label: label ?? this.label,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (sentenceEn.present) {
      map['sentence_en'] = Variable<String>(sentenceEn.value);
    }
    if (sentenceJa.present) {
      map['sentence_ja'] = Variable<String>(sentenceJa.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExampleSentencesCompanion(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('sentenceEn: $sentenceEn, ')
          ..write('sentenceJa: $sentenceJa, ')
          ..write('order: $order, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }
}

class $WordSourcesTable extends WordSources
    with TableInfo<$WordSourcesTable, WordSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
      'word_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES words (id) ON DELETE CASCADE'));
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pageNumberMeta =
      const VerificationMeta('pageNumber');
  @override
  late final GeneratedColumn<String> pageNumber = GeneratedColumn<String>(
      'page_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
      'detail', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, wordId, sourceType, title, url, pageNumber, detail, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_sources';
  @override
  VerificationContext validateIntegrity(Insertable<WordSource> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word_id')) {
      context.handle(_wordIdMeta,
          wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta));
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    }
    if (data.containsKey('page_number')) {
      context.handle(
          _pageNumberMeta,
          pageNumber.isAcceptableOrUnknown(
              data['page_number']!, _pageNumberMeta));
    }
    if (data.containsKey('detail')) {
      context.handle(_detailMeta,
          detail.isAcceptableOrUnknown(data['detail']!, _detailMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordSource(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      wordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_id'])!,
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url']),
      pageNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}page_number']),
      detail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}detail']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $WordSourcesTable createAlias(String alias) {
    return $WordSourcesTable(attachedDatabase, alias);
  }
}

class WordSource extends DataClass implements Insertable<WordSource> {
  final int id;
  final int wordId;
  final String sourceType;
  final String? title;
  final String? url;
  final String? pageNumber;
  final String? detail;
  final int createdAt;
  const WordSource(
      {required this.id,
      required this.wordId,
      required this.sourceType,
      this.title,
      this.url,
      this.pageNumber,
      this.detail,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word_id'] = Variable<int>(wordId);
    map['source_type'] = Variable<String>(sourceType);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || pageNumber != null) {
      map['page_number'] = Variable<String>(pageNumber);
    }
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  WordSourcesCompanion toCompanion(bool nullToAbsent) {
    return WordSourcesCompanion(
      id: Value(id),
      wordId: Value(wordId),
      sourceType: Value(sourceType),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      pageNumber: pageNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(pageNumber),
      detail:
          detail == null && nullToAbsent ? const Value.absent() : Value(detail),
      createdAt: Value(createdAt),
    );
  }

  factory WordSource.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordSource(
      id: serializer.fromJson<int>(json['id']),
      wordId: serializer.fromJson<int>(json['wordId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      title: serializer.fromJson<String?>(json['title']),
      url: serializer.fromJson<String?>(json['url']),
      pageNumber: serializer.fromJson<String?>(json['pageNumber']),
      detail: serializer.fromJson<String?>(json['detail']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wordId': serializer.toJson<int>(wordId),
      'sourceType': serializer.toJson<String>(sourceType),
      'title': serializer.toJson<String?>(title),
      'url': serializer.toJson<String?>(url),
      'pageNumber': serializer.toJson<String?>(pageNumber),
      'detail': serializer.toJson<String?>(detail),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  WordSource copyWith(
          {int? id,
          int? wordId,
          String? sourceType,
          Value<String?> title = const Value.absent(),
          Value<String?> url = const Value.absent(),
          Value<String?> pageNumber = const Value.absent(),
          Value<String?> detail = const Value.absent(),
          int? createdAt}) =>
      WordSource(
        id: id ?? this.id,
        wordId: wordId ?? this.wordId,
        sourceType: sourceType ?? this.sourceType,
        title: title.present ? title.value : this.title,
        url: url.present ? url.value : this.url,
        pageNumber: pageNumber.present ? pageNumber.value : this.pageNumber,
        detail: detail.present ? detail.value : this.detail,
        createdAt: createdAt ?? this.createdAt,
      );
  WordSource copyWithCompanion(WordSourcesCompanion data) {
    return WordSource(
      id: data.id.present ? data.id.value : this.id,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      sourceType:
          data.sourceType.present ? data.sourceType.value : this.sourceType,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      pageNumber:
          data.pageNumber.present ? data.pageNumber.value : this.pageNumber,
      detail: data.detail.present ? data.detail.value : this.detail,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordSource(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('sourceType: $sourceType, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('detail: $detail, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, wordId, sourceType, title, url, pageNumber, detail, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordSource &&
          other.id == this.id &&
          other.wordId == this.wordId &&
          other.sourceType == this.sourceType &&
          other.title == this.title &&
          other.url == this.url &&
          other.pageNumber == this.pageNumber &&
          other.detail == this.detail &&
          other.createdAt == this.createdAt);
}

class WordSourcesCompanion extends UpdateCompanion<WordSource> {
  final Value<int> id;
  final Value<int> wordId;
  final Value<String> sourceType;
  final Value<String?> title;
  final Value<String?> url;
  final Value<String?> pageNumber;
  final Value<String?> detail;
  final Value<int> createdAt;
  const WordSourcesCompanion({
    this.id = const Value.absent(),
    this.wordId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.pageNumber = const Value.absent(),
    this.detail = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WordSourcesCompanion.insert({
    this.id = const Value.absent(),
    required int wordId,
    required String sourceType,
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.pageNumber = const Value.absent(),
    this.detail = const Value.absent(),
    required int createdAt,
  })  : wordId = Value(wordId),
        sourceType = Value(sourceType),
        createdAt = Value(createdAt);
  static Insertable<WordSource> custom({
    Expression<int>? id,
    Expression<int>? wordId,
    Expression<String>? sourceType,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? pageNumber,
    Expression<String>? detail,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wordId != null) 'word_id': wordId,
      if (sourceType != null) 'source_type': sourceType,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (pageNumber != null) 'page_number': pageNumber,
      if (detail != null) 'detail': detail,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WordSourcesCompanion copyWith(
      {Value<int>? id,
      Value<int>? wordId,
      Value<String>? sourceType,
      Value<String?>? title,
      Value<String?>? url,
      Value<String?>? pageNumber,
      Value<String?>? detail,
      Value<int>? createdAt}) {
    return WordSourcesCompanion(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      sourceType: sourceType ?? this.sourceType,
      title: title ?? this.title,
      url: url ?? this.url,
      pageNumber: pageNumber ?? this.pageNumber,
      detail: detail ?? this.detail,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (pageNumber.present) {
      map['page_number'] = Variable<String>(pageNumber.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordSourcesCompanion(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('sourceType: $sourceType, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('detail: $detail, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $QuizSessionsTable extends QuizSessions
    with TableInfo<$QuizSessionsTable, QuizSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
      'started_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, startedAt, completedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<QuizSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuizSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}started_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $QuizSessionsTable createAlias(String alias) {
    return $QuizSessionsTable(attachedDatabase, alias);
  }
}

class QuizSession extends DataClass implements Insertable<QuizSession> {
  final int id;
  final int startedAt;
  final int? completedAt;
  const QuizSession(
      {required this.id, required this.startedAt, this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    return map;
  }

  QuizSessionsCompanion toCompanion(bool nullToAbsent) {
    return QuizSessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory QuizSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizSession(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<int>(startedAt),
      'completedAt': serializer.toJson<int?>(completedAt),
    };
  }

  QuizSession copyWith(
          {int? id,
          int? startedAt,
          Value<int?> completedAt = const Value.absent()}) =>
      QuizSession(
        id: id ?? this.id,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  QuizSession copyWithCompanion(QuizSessionsCompanion data) {
    return QuizSession(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizSession(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, startedAt, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizSession &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt);
}

class QuizSessionsCompanion extends UpdateCompanion<QuizSession> {
  final Value<int> id;
  final Value<int> startedAt;
  final Value<int?> completedAt;
  const QuizSessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  QuizSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int startedAt,
    this.completedAt = const Value.absent(),
  }) : startedAt = Value(startedAt);
  static Insertable<QuizSession> custom({
    Expression<int>? id,
    Expression<int>? startedAt,
    Expression<int>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  QuizSessionsCompanion copyWith(
      {Value<int>? id, Value<int>? startedAt, Value<int?>? completedAt}) {
    return QuizSessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $QuizAnswersTable extends QuizAnswers
    with TableInfo<$QuizAnswersTable, QuizAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
      'session_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES quiz_sessions (id) ON DELETE CASCADE'));
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
      'word_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES words (id) ON DELETE CASCADE'));
  static const VerificationMeta _isCorrectMeta =
      const VerificationMeta('isCorrect');
  @override
  late final GeneratedColumn<int> isCorrect = GeneratedColumn<int>(
      'is_correct', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _answeredAtMeta =
      const VerificationMeta('answeredAt');
  @override
  late final GeneratedColumn<int> answeredAt = GeneratedColumn<int>(
      'answered_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, sessionId, wordId, isCorrect, answeredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_answers';
  @override
  VerificationContext validateIntegrity(Insertable<QuizAnswer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(_wordIdMeta,
          wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta));
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(_isCorrectMeta,
          isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta));
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    if (data.containsKey('answered_at')) {
      context.handle(
          _answeredAtMeta,
          answeredAt.isAcceptableOrUnknown(
              data['answered_at']!, _answeredAtMeta));
    } else if (isInserting) {
      context.missing(_answeredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuizAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizAnswer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      wordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_id'])!,
      isCorrect: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_correct'])!,
      answeredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}answered_at'])!,
    );
  }

  @override
  $QuizAnswersTable createAlias(String alias) {
    return $QuizAnswersTable(attachedDatabase, alias);
  }
}

class QuizAnswer extends DataClass implements Insertable<QuizAnswer> {
  final int id;
  final int sessionId;
  final int wordId;
  final int isCorrect;
  final int answeredAt;
  const QuizAnswer(
      {required this.id,
      required this.sessionId,
      required this.wordId,
      required this.isCorrect,
      required this.answeredAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['word_id'] = Variable<int>(wordId);
    map['is_correct'] = Variable<int>(isCorrect);
    map['answered_at'] = Variable<int>(answeredAt);
    return map;
  }

  QuizAnswersCompanion toCompanion(bool nullToAbsent) {
    return QuizAnswersCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      wordId: Value(wordId),
      isCorrect: Value(isCorrect),
      answeredAt: Value(answeredAt),
    );
  }

  factory QuizAnswer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizAnswer(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      wordId: serializer.fromJson<int>(json['wordId']),
      isCorrect: serializer.fromJson<int>(json['isCorrect']),
      answeredAt: serializer.fromJson<int>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'wordId': serializer.toJson<int>(wordId),
      'isCorrect': serializer.toJson<int>(isCorrect),
      'answeredAt': serializer.toJson<int>(answeredAt),
    };
  }

  QuizAnswer copyWith(
          {int? id,
          int? sessionId,
          int? wordId,
          int? isCorrect,
          int? answeredAt}) =>
      QuizAnswer(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        wordId: wordId ?? this.wordId,
        isCorrect: isCorrect ?? this.isCorrect,
        answeredAt: answeredAt ?? this.answeredAt,
      );
  QuizAnswer copyWithCompanion(QuizAnswersCompanion data) {
    return QuizAnswer(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      answeredAt:
          data.answeredAt.present ? data.answeredAt.value : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizAnswer(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('wordId: $wordId, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, wordId, isCorrect, answeredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizAnswer &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.wordId == this.wordId &&
          other.isCorrect == this.isCorrect &&
          other.answeredAt == this.answeredAt);
}

class QuizAnswersCompanion extends UpdateCompanion<QuizAnswer> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> wordId;
  final Value<int> isCorrect;
  final Value<int> answeredAt;
  const QuizAnswersCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.answeredAt = const Value.absent(),
  });
  QuizAnswersCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int wordId,
    required int isCorrect,
    required int answeredAt,
  })  : sessionId = Value(sessionId),
        wordId = Value(wordId),
        isCorrect = Value(isCorrect),
        answeredAt = Value(answeredAt);
  static Insertable<QuizAnswer> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? wordId,
    Expression<int>? isCorrect,
    Expression<int>? answeredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (wordId != null) 'word_id': wordId,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (answeredAt != null) 'answered_at': answeredAt,
    });
  }

  QuizAnswersCompanion copyWith(
      {Value<int>? id,
      Value<int>? sessionId,
      Value<int>? wordId,
      Value<int>? isCorrect,
      Value<int>? answeredAt}) {
    return QuizAnswersCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      wordId: wordId ?? this.wordId,
      isCorrect: isCorrect ?? this.isCorrect,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<int>(isCorrect.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<int>(answeredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizAnswersCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('wordId: $wordId, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }
}

class $StudyRecordsTable extends StudyRecords
    with TableInfo<$StudyRecordsTable, StudyRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _studyDateMeta =
      const VerificationMeta('studyDate');
  @override
  late final GeneratedColumn<String> studyDate = GeneratedColumn<String>(
      'study_date', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _wordsStudiedMeta =
      const VerificationMeta('wordsStudied');
  @override
  late final GeneratedColumn<int> wordsStudied = GeneratedColumn<int>(
      'words_studied', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _quizCompletedMeta =
      const VerificationMeta('quizCompleted');
  @override
  late final GeneratedColumn<int> quizCompleted = GeneratedColumn<int>(
      'quiz_completed', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, studyDate, wordsStudied, quizCompleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_records';
  @override
  VerificationContext validateIntegrity(Insertable<StudyRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('study_date')) {
      context.handle(_studyDateMeta,
          studyDate.isAcceptableOrUnknown(data['study_date']!, _studyDateMeta));
    } else if (isInserting) {
      context.missing(_studyDateMeta);
    }
    if (data.containsKey('words_studied')) {
      context.handle(
          _wordsStudiedMeta,
          wordsStudied.isAcceptableOrUnknown(
              data['words_studied']!, _wordsStudiedMeta));
    }
    if (data.containsKey('quiz_completed')) {
      context.handle(
          _quizCompletedMeta,
          quizCompleted.isAcceptableOrUnknown(
              data['quiz_completed']!, _quizCompletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudyRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      studyDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}study_date'])!,
      wordsStudied: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}words_studied'])!,
      quizCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quiz_completed'])!,
    );
  }

  @override
  $StudyRecordsTable createAlias(String alias) {
    return $StudyRecordsTable(attachedDatabase, alias);
  }
}

class StudyRecord extends DataClass implements Insertable<StudyRecord> {
  final int id;
  final String studyDate;
  final int wordsStudied;
  final int quizCompleted;
  const StudyRecord(
      {required this.id,
      required this.studyDate,
      required this.wordsStudied,
      required this.quizCompleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['study_date'] = Variable<String>(studyDate);
    map['words_studied'] = Variable<int>(wordsStudied);
    map['quiz_completed'] = Variable<int>(quizCompleted);
    return map;
  }

  StudyRecordsCompanion toCompanion(bool nullToAbsent) {
    return StudyRecordsCompanion(
      id: Value(id),
      studyDate: Value(studyDate),
      wordsStudied: Value(wordsStudied),
      quizCompleted: Value(quizCompleted),
    );
  }

  factory StudyRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyRecord(
      id: serializer.fromJson<int>(json['id']),
      studyDate: serializer.fromJson<String>(json['studyDate']),
      wordsStudied: serializer.fromJson<int>(json['wordsStudied']),
      quizCompleted: serializer.fromJson<int>(json['quizCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studyDate': serializer.toJson<String>(studyDate),
      'wordsStudied': serializer.toJson<int>(wordsStudied),
      'quizCompleted': serializer.toJson<int>(quizCompleted),
    };
  }

  StudyRecord copyWith(
          {int? id,
          String? studyDate,
          int? wordsStudied,
          int? quizCompleted}) =>
      StudyRecord(
        id: id ?? this.id,
        studyDate: studyDate ?? this.studyDate,
        wordsStudied: wordsStudied ?? this.wordsStudied,
        quizCompleted: quizCompleted ?? this.quizCompleted,
      );
  StudyRecord copyWithCompanion(StudyRecordsCompanion data) {
    return StudyRecord(
      id: data.id.present ? data.id.value : this.id,
      studyDate: data.studyDate.present ? data.studyDate.value : this.studyDate,
      wordsStudied: data.wordsStudied.present
          ? data.wordsStudied.value
          : this.wordsStudied,
      quizCompleted: data.quizCompleted.present
          ? data.quizCompleted.value
          : this.quizCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyRecord(')
          ..write('id: $id, ')
          ..write('studyDate: $studyDate, ')
          ..write('wordsStudied: $wordsStudied, ')
          ..write('quizCompleted: $quizCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, studyDate, wordsStudied, quizCompleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyRecord &&
          other.id == this.id &&
          other.studyDate == this.studyDate &&
          other.wordsStudied == this.wordsStudied &&
          other.quizCompleted == this.quizCompleted);
}

class StudyRecordsCompanion extends UpdateCompanion<StudyRecord> {
  final Value<int> id;
  final Value<String> studyDate;
  final Value<int> wordsStudied;
  final Value<int> quizCompleted;
  const StudyRecordsCompanion({
    this.id = const Value.absent(),
    this.studyDate = const Value.absent(),
    this.wordsStudied = const Value.absent(),
    this.quizCompleted = const Value.absent(),
  });
  StudyRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String studyDate,
    this.wordsStudied = const Value.absent(),
    this.quizCompleted = const Value.absent(),
  }) : studyDate = Value(studyDate);
  static Insertable<StudyRecord> custom({
    Expression<int>? id,
    Expression<String>? studyDate,
    Expression<int>? wordsStudied,
    Expression<int>? quizCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studyDate != null) 'study_date': studyDate,
      if (wordsStudied != null) 'words_studied': wordsStudied,
      if (quizCompleted != null) 'quiz_completed': quizCompleted,
    });
  }

  StudyRecordsCompanion copyWith(
      {Value<int>? id,
      Value<String>? studyDate,
      Value<int>? wordsStudied,
      Value<int>? quizCompleted}) {
    return StudyRecordsCompanion(
      id: id ?? this.id,
      studyDate: studyDate ?? this.studyDate,
      wordsStudied: wordsStudied ?? this.wordsStudied,
      quizCompleted: quizCompleted ?? this.quizCompleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studyDate.present) {
      map['study_date'] = Variable<String>(studyDate.value);
    }
    if (wordsStudied.present) {
      map['words_studied'] = Variable<int>(wordsStudied.value);
    }
    if (quizCompleted.present) {
      map['quiz_completed'] = Variable<int>(quizCompleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyRecordsCompanion(')
          ..write('id: $id, ')
          ..write('studyDate: $studyDate, ')
          ..write('wordsStudied: $wordsStudied, ')
          ..write('quizCompleted: $quizCompleted')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WordsTable words = $WordsTable(this);
  late final $ExampleSentencesTable exampleSentences =
      $ExampleSentencesTable(this);
  late final $WordSourcesTable wordSources = $WordSourcesTable(this);
  late final $QuizSessionsTable quizSessions = $QuizSessionsTable(this);
  late final $QuizAnswersTable quizAnswers = $QuizAnswersTable(this);
  late final $StudyRecordsTable studyRecords = $StudyRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        words,
        exampleSentences,
        wordSources,
        quizSessions,
        quizAnswers,
        studyRecords
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('words',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('example_sentences', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('words',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('word_sources', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('quiz_sessions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('quiz_answers', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('words',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('quiz_answers', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$WordsTableCreateCompanionBuilder = WordsCompanion Function({
  Value<int> id,
  required String word,
  Value<String?> reading,
  required String meaning,
  Value<String?> partOfSpeech,
  required int createdAt,
  required int updatedAt,
});
typedef $$WordsTableUpdateCompanionBuilder = WordsCompanion Function({
  Value<int> id,
  Value<String> word,
  Value<String?> reading,
  Value<String> meaning,
  Value<String?> partOfSpeech,
  Value<int> createdAt,
  Value<int> updatedAt,
});

final class $$WordsTableReferences
    extends BaseReferences<_$AppDatabase, $WordsTable, Word> {
  $$WordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExampleSentencesTable, List<ExampleSentence>>
      _exampleSentencesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.exampleSentences,
              aliasName: $_aliasNameGenerator(
                  db.words.id, db.exampleSentences.wordId));

  $$ExampleSentencesTableProcessedTableManager get exampleSentencesRefs {
    final manager =
        $$ExampleSentencesTableTableManager($_db, $_db.exampleSentences)
            .filter((f) => f.wordId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_exampleSentencesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$WordSourcesTable, List<WordSource>>
      _wordSourcesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.wordSources,
          aliasName: $_aliasNameGenerator(db.words.id, db.wordSources.wordId));

  $$WordSourcesTableProcessedTableManager get wordSourcesRefs {
    final manager = $$WordSourcesTableTableManager($_db, $_db.wordSources)
        .filter((f) => f.wordId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_wordSourcesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$QuizAnswersTable, List<QuizAnswer>>
      _quizAnswersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.quizAnswers,
          aliasName: $_aliasNameGenerator(db.words.id, db.quizAnswers.wordId));

  $$QuizAnswersTableProcessedTableManager get quizAnswersRefs {
    final manager = $$QuizAnswersTableTableManager($_db, $_db.quizAnswers)
        .filter((f) => f.wordId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_quizAnswersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reading => $composableBuilder(
      column: $table.reading, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get meaning => $composableBuilder(
      column: $table.meaning, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
      column: $table.partOfSpeech, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> exampleSentencesRefs(
      Expression<bool> Function($$ExampleSentencesTableFilterComposer f) f) {
    final $$ExampleSentencesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.exampleSentences,
        getReferencedColumn: (t) => t.wordId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExampleSentencesTableFilterComposer(
              $db: $db,
              $table: $db.exampleSentences,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> wordSourcesRefs(
      Expression<bool> Function($$WordSourcesTableFilterComposer f) f) {
    final $$WordSourcesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.wordSources,
        getReferencedColumn: (t) => t.wordId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordSourcesTableFilterComposer(
              $db: $db,
              $table: $db.wordSources,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> quizAnswersRefs(
      Expression<bool> Function($$QuizAnswersTableFilterComposer f) f) {
    final $$QuizAnswersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.quizAnswers,
        getReferencedColumn: (t) => t.wordId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuizAnswersTableFilterComposer(
              $db: $db,
              $table: $db.quizAnswers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reading => $composableBuilder(
      column: $table.reading, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get meaning => $composableBuilder(
      column: $table.meaning, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
      column: $table.partOfSpeech,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get reading =>
      $composableBuilder(column: $table.reading, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
      column: $table.partOfSpeech, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> exampleSentencesRefs<T extends Object>(
      Expression<T> Function($$ExampleSentencesTableAnnotationComposer a) f) {
    final $$ExampleSentencesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.exampleSentences,
        getReferencedColumn: (t) => t.wordId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExampleSentencesTableAnnotationComposer(
              $db: $db,
              $table: $db.exampleSentences,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> wordSourcesRefs<T extends Object>(
      Expression<T> Function($$WordSourcesTableAnnotationComposer a) f) {
    final $$WordSourcesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.wordSources,
        getReferencedColumn: (t) => t.wordId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordSourcesTableAnnotationComposer(
              $db: $db,
              $table: $db.wordSources,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> quizAnswersRefs<T extends Object>(
      Expression<T> Function($$QuizAnswersTableAnnotationComposer a) f) {
    final $$QuizAnswersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.quizAnswers,
        getReferencedColumn: (t) => t.wordId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuizAnswersTableAnnotationComposer(
              $db: $db,
              $table: $db.quizAnswers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WordsTable,
    Word,
    $$WordsTableFilterComposer,
    $$WordsTableOrderingComposer,
    $$WordsTableAnnotationComposer,
    $$WordsTableCreateCompanionBuilder,
    $$WordsTableUpdateCompanionBuilder,
    (Word, $$WordsTableReferences),
    Word,
    PrefetchHooks Function(
        {bool exampleSentencesRefs,
        bool wordSourcesRefs,
        bool quizAnswersRefs})> {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> word = const Value.absent(),
            Value<String?> reading = const Value.absent(),
            Value<String> meaning = const Value.absent(),
            Value<String?> partOfSpeech = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
          }) =>
              WordsCompanion(
            id: id,
            word: word,
            reading: reading,
            meaning: meaning,
            partOfSpeech: partOfSpeech,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String word,
            Value<String?> reading = const Value.absent(),
            required String meaning,
            Value<String?> partOfSpeech = const Value.absent(),
            required int createdAt,
            required int updatedAt,
          }) =>
              WordsCompanion.insert(
            id: id,
            word: word,
            reading: reading,
            meaning: meaning,
            partOfSpeech: partOfSpeech,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$WordsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {exampleSentencesRefs = false,
              wordSourcesRefs = false,
              quizAnswersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (exampleSentencesRefs) db.exampleSentences,
                if (wordSourcesRefs) db.wordSources,
                if (quizAnswersRefs) db.quizAnswers
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exampleSentencesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$WordsTableReferences
                            ._exampleSentencesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WordsTableReferences(db, table, p0)
                                .exampleSentencesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.wordId == item.id),
                        typedResults: items),
                  if (wordSourcesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$WordsTableReferences._wordSourcesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WordsTableReferences(db, table, p0)
                                .wordSourcesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.wordId == item.id),
                        typedResults: items),
                  if (quizAnswersRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$WordsTableReferences._quizAnswersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WordsTableReferences(db, table, p0)
                                .quizAnswersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.wordId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$WordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WordsTable,
    Word,
    $$WordsTableFilterComposer,
    $$WordsTableOrderingComposer,
    $$WordsTableAnnotationComposer,
    $$WordsTableCreateCompanionBuilder,
    $$WordsTableUpdateCompanionBuilder,
    (Word, $$WordsTableReferences),
    Word,
    PrefetchHooks Function(
        {bool exampleSentencesRefs,
        bool wordSourcesRefs,
        bool quizAnswersRefs})>;
typedef $$ExampleSentencesTableCreateCompanionBuilder
    = ExampleSentencesCompanion Function({
  Value<int> id,
  required int wordId,
  required String sentenceEn,
  required String sentenceJa,
  Value<int> order,
  Value<String?> label,
});
typedef $$ExampleSentencesTableUpdateCompanionBuilder
    = ExampleSentencesCompanion Function({
  Value<int> id,
  Value<int> wordId,
  Value<String> sentenceEn,
  Value<String> sentenceJa,
  Value<int> order,
  Value<String?> label,
});

final class $$ExampleSentencesTableReferences extends BaseReferences<
    _$AppDatabase, $ExampleSentencesTable, ExampleSentence> {
  $$ExampleSentencesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $WordsTable _wordIdTable(_$AppDatabase db) => db.words.createAlias(
      $_aliasNameGenerator(db.exampleSentences.wordId, db.words.id));

  $$WordsTableProcessedTableManager? get wordId {
    if ($_item.wordId == null) return null;
    final manager = $$WordsTableTableManager($_db, $_db.words)
        .filter((f) => f.id($_item.wordId!));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ExampleSentencesTableFilterComposer
    extends Composer<_$AppDatabase, $ExampleSentencesTable> {
  $$ExampleSentencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sentenceEn => $composableBuilder(
      column: $table.sentenceEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sentenceJa => $composableBuilder(
      column: $table.sentenceJa, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableFilterComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExampleSentencesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExampleSentencesTable> {
  $$ExampleSentencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sentenceEn => $composableBuilder(
      column: $table.sentenceEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sentenceJa => $composableBuilder(
      column: $table.sentenceJa, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableOrderingComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExampleSentencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExampleSentencesTable> {
  $$ExampleSentencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sentenceEn => $composableBuilder(
      column: $table.sentenceEn, builder: (column) => column);

  GeneratedColumn<String> get sentenceJa => $composableBuilder(
      column: $table.sentenceJa, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableAnnotationComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExampleSentencesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExampleSentencesTable,
    ExampleSentence,
    $$ExampleSentencesTableFilterComposer,
    $$ExampleSentencesTableOrderingComposer,
    $$ExampleSentencesTableAnnotationComposer,
    $$ExampleSentencesTableCreateCompanionBuilder,
    $$ExampleSentencesTableUpdateCompanionBuilder,
    (ExampleSentence, $$ExampleSentencesTableReferences),
    ExampleSentence,
    PrefetchHooks Function({bool wordId})> {
  $$ExampleSentencesTableTableManager(
      _$AppDatabase db, $ExampleSentencesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExampleSentencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExampleSentencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExampleSentencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> wordId = const Value.absent(),
            Value<String> sentenceEn = const Value.absent(),
            Value<String> sentenceJa = const Value.absent(),
            Value<int> order = const Value.absent(),
            Value<String?> label = const Value.absent(),
          }) =>
              ExampleSentencesCompanion(
            id: id,
            wordId: wordId,
            sentenceEn: sentenceEn,
            sentenceJa: sentenceJa,
            order: order,
            label: label,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int wordId,
            required String sentenceEn,
            required String sentenceJa,
            Value<int> order = const Value.absent(),
            Value<String?> label = const Value.absent(),
          }) =>
              ExampleSentencesCompanion.insert(
            id: id,
            wordId: wordId,
            sentenceEn: sentenceEn,
            sentenceJa: sentenceJa,
            order: order,
            label: label,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ExampleSentencesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({wordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (wordId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.wordId,
                    referencedTable:
                        $$ExampleSentencesTableReferences._wordIdTable(db),
                    referencedColumn:
                        $$ExampleSentencesTableReferences._wordIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ExampleSentencesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExampleSentencesTable,
    ExampleSentence,
    $$ExampleSentencesTableFilterComposer,
    $$ExampleSentencesTableOrderingComposer,
    $$ExampleSentencesTableAnnotationComposer,
    $$ExampleSentencesTableCreateCompanionBuilder,
    $$ExampleSentencesTableUpdateCompanionBuilder,
    (ExampleSentence, $$ExampleSentencesTableReferences),
    ExampleSentence,
    PrefetchHooks Function({bool wordId})>;
typedef $$WordSourcesTableCreateCompanionBuilder = WordSourcesCompanion
    Function({
  Value<int> id,
  required int wordId,
  required String sourceType,
  Value<String?> title,
  Value<String?> url,
  Value<String?> pageNumber,
  Value<String?> detail,
  required int createdAt,
});
typedef $$WordSourcesTableUpdateCompanionBuilder = WordSourcesCompanion
    Function({
  Value<int> id,
  Value<int> wordId,
  Value<String> sourceType,
  Value<String?> title,
  Value<String?> url,
  Value<String?> pageNumber,
  Value<String?> detail,
  Value<int> createdAt,
});

final class $$WordSourcesTableReferences
    extends BaseReferences<_$AppDatabase, $WordSourcesTable, WordSource> {
  $$WordSourcesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordsTable _wordIdTable(_$AppDatabase db) => db.words
      .createAlias($_aliasNameGenerator(db.wordSources.wordId, db.words.id));

  $$WordsTableProcessedTableManager? get wordId {
    if ($_item.wordId == null) return null;
    final manager = $$WordsTableTableManager($_db, $_db.words)
        .filter((f) => f.id($_item.wordId!));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WordSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $WordSourcesTable> {
  $$WordSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableFilterComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WordSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $WordSourcesTable> {
  $$WordSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableOrderingComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WordSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordSourcesTable> {
  $$WordSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableAnnotationComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WordSourcesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WordSourcesTable,
    WordSource,
    $$WordSourcesTableFilterComposer,
    $$WordSourcesTableOrderingComposer,
    $$WordSourcesTableAnnotationComposer,
    $$WordSourcesTableCreateCompanionBuilder,
    $$WordSourcesTableUpdateCompanionBuilder,
    (WordSource, $$WordSourcesTableReferences),
    WordSource,
    PrefetchHooks Function({bool wordId})> {
  $$WordSourcesTableTableManager(_$AppDatabase db, $WordSourcesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> wordId = const Value.absent(),
            Value<String> sourceType = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<String?> pageNumber = const Value.absent(),
            Value<String?> detail = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              WordSourcesCompanion(
            id: id,
            wordId: wordId,
            sourceType: sourceType,
            title: title,
            url: url,
            pageNumber: pageNumber,
            detail: detail,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int wordId,
            required String sourceType,
            Value<String?> title = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<String?> pageNumber = const Value.absent(),
            Value<String?> detail = const Value.absent(),
            required int createdAt,
          }) =>
              WordSourcesCompanion.insert(
            id: id,
            wordId: wordId,
            sourceType: sourceType,
            title: title,
            url: url,
            pageNumber: pageNumber,
            detail: detail,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WordSourcesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({wordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (wordId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.wordId,
                    referencedTable:
                        $$WordSourcesTableReferences._wordIdTable(db),
                    referencedColumn:
                        $$WordSourcesTableReferences._wordIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$WordSourcesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WordSourcesTable,
    WordSource,
    $$WordSourcesTableFilterComposer,
    $$WordSourcesTableOrderingComposer,
    $$WordSourcesTableAnnotationComposer,
    $$WordSourcesTableCreateCompanionBuilder,
    $$WordSourcesTableUpdateCompanionBuilder,
    (WordSource, $$WordSourcesTableReferences),
    WordSource,
    PrefetchHooks Function({bool wordId})>;
typedef $$QuizSessionsTableCreateCompanionBuilder = QuizSessionsCompanion
    Function({
  Value<int> id,
  required int startedAt,
  Value<int?> completedAt,
});
typedef $$QuizSessionsTableUpdateCompanionBuilder = QuizSessionsCompanion
    Function({
  Value<int> id,
  Value<int> startedAt,
  Value<int?> completedAt,
});

final class $$QuizSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $QuizSessionsTable, QuizSession> {
  $$QuizSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$QuizAnswersTable, List<QuizAnswer>>
      _quizAnswersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.quizAnswers,
              aliasName: $_aliasNameGenerator(
                  db.quizSessions.id, db.quizAnswers.sessionId));

  $$QuizAnswersTableProcessedTableManager get quizAnswersRefs {
    final manager = $$QuizAnswersTableTableManager($_db, $_db.quizAnswers)
        .filter((f) => f.sessionId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_quizAnswersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$QuizSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $QuizSessionsTable> {
  $$QuizSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> quizAnswersRefs(
      Expression<bool> Function($$QuizAnswersTableFilterComposer f) f) {
    final $$QuizAnswersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.quizAnswers,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuizAnswersTableFilterComposer(
              $db: $db,
              $table: $db.quizAnswers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$QuizSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuizSessionsTable> {
  $$QuizSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$QuizSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuizSessionsTable> {
  $$QuizSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  Expression<T> quizAnswersRefs<T extends Object>(
      Expression<T> Function($$QuizAnswersTableAnnotationComposer a) f) {
    final $$QuizAnswersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.quizAnswers,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuizAnswersTableAnnotationComposer(
              $db: $db,
              $table: $db.quizAnswers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$QuizSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuizSessionsTable,
    QuizSession,
    $$QuizSessionsTableFilterComposer,
    $$QuizSessionsTableOrderingComposer,
    $$QuizSessionsTableAnnotationComposer,
    $$QuizSessionsTableCreateCompanionBuilder,
    $$QuizSessionsTableUpdateCompanionBuilder,
    (QuizSession, $$QuizSessionsTableReferences),
    QuizSession,
    PrefetchHooks Function({bool quizAnswersRefs})> {
  $$QuizSessionsTableTableManager(_$AppDatabase db, $QuizSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuizSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuizSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuizSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> startedAt = const Value.absent(),
            Value<int?> completedAt = const Value.absent(),
          }) =>
              QuizSessionsCompanion(
            id: id,
            startedAt: startedAt,
            completedAt: completedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int startedAt,
            Value<int?> completedAt = const Value.absent(),
          }) =>
              QuizSessionsCompanion.insert(
            id: id,
            startedAt: startedAt,
            completedAt: completedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$QuizSessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({quizAnswersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (quizAnswersRefs) db.quizAnswers],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (quizAnswersRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$QuizSessionsTableReferences
                            ._quizAnswersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$QuizSessionsTableReferences(db, table, p0)
                                .quizAnswersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$QuizSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuizSessionsTable,
    QuizSession,
    $$QuizSessionsTableFilterComposer,
    $$QuizSessionsTableOrderingComposer,
    $$QuizSessionsTableAnnotationComposer,
    $$QuizSessionsTableCreateCompanionBuilder,
    $$QuizSessionsTableUpdateCompanionBuilder,
    (QuizSession, $$QuizSessionsTableReferences),
    QuizSession,
    PrefetchHooks Function({bool quizAnswersRefs})>;
typedef $$QuizAnswersTableCreateCompanionBuilder = QuizAnswersCompanion
    Function({
  Value<int> id,
  required int sessionId,
  required int wordId,
  required int isCorrect,
  required int answeredAt,
});
typedef $$QuizAnswersTableUpdateCompanionBuilder = QuizAnswersCompanion
    Function({
  Value<int> id,
  Value<int> sessionId,
  Value<int> wordId,
  Value<int> isCorrect,
  Value<int> answeredAt,
});

final class $$QuizAnswersTableReferences
    extends BaseReferences<_$AppDatabase, $QuizAnswersTable, QuizAnswer> {
  $$QuizAnswersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $QuizSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.quizSessions.createAlias(
          $_aliasNameGenerator(db.quizAnswers.sessionId, db.quizSessions.id));

  $$QuizSessionsTableProcessedTableManager? get sessionId {
    if ($_item.sessionId == null) return null;
    final manager = $$QuizSessionsTableTableManager($_db, $_db.quizSessions)
        .filter((f) => f.id($_item.sessionId!));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WordsTable _wordIdTable(_$AppDatabase db) => db.words
      .createAlias($_aliasNameGenerator(db.quizAnswers.wordId, db.words.id));

  $$WordsTableProcessedTableManager? get wordId {
    if ($_item.wordId == null) return null;
    final manager = $$WordsTableTableManager($_db, $_db.words)
        .filter((f) => f.id($_item.wordId!));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$QuizAnswersTableFilterComposer
    extends Composer<_$AppDatabase, $QuizAnswersTable> {
  $$QuizAnswersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isCorrect => $composableBuilder(
      column: $table.isCorrect, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get answeredAt => $composableBuilder(
      column: $table.answeredAt, builder: (column) => ColumnFilters(column));

  $$QuizSessionsTableFilterComposer get sessionId {
    final $$QuizSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.quizSessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuizSessionsTableFilterComposer(
              $db: $db,
              $table: $db.quizSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableFilterComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$QuizAnswersTableOrderingComposer
    extends Composer<_$AppDatabase, $QuizAnswersTable> {
  $$QuizAnswersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isCorrect => $composableBuilder(
      column: $table.isCorrect, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get answeredAt => $composableBuilder(
      column: $table.answeredAt, builder: (column) => ColumnOrderings(column));

  $$QuizSessionsTableOrderingComposer get sessionId {
    final $$QuizSessionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.quizSessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuizSessionsTableOrderingComposer(
              $db: $db,
              $table: $db.quizSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableOrderingComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$QuizAnswersTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuizAnswersTable> {
  $$QuizAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<int> get answeredAt => $composableBuilder(
      column: $table.answeredAt, builder: (column) => column);

  $$QuizSessionsTableAnnotationComposer get sessionId {
    final $$QuizSessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.quizSessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuizSessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.quizSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableAnnotationComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$QuizAnswersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuizAnswersTable,
    QuizAnswer,
    $$QuizAnswersTableFilterComposer,
    $$QuizAnswersTableOrderingComposer,
    $$QuizAnswersTableAnnotationComposer,
    $$QuizAnswersTableCreateCompanionBuilder,
    $$QuizAnswersTableUpdateCompanionBuilder,
    (QuizAnswer, $$QuizAnswersTableReferences),
    QuizAnswer,
    PrefetchHooks Function({bool sessionId, bool wordId})> {
  $$QuizAnswersTableTableManager(_$AppDatabase db, $QuizAnswersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuizAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuizAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuizAnswersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sessionId = const Value.absent(),
            Value<int> wordId = const Value.absent(),
            Value<int> isCorrect = const Value.absent(),
            Value<int> answeredAt = const Value.absent(),
          }) =>
              QuizAnswersCompanion(
            id: id,
            sessionId: sessionId,
            wordId: wordId,
            isCorrect: isCorrect,
            answeredAt: answeredAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sessionId,
            required int wordId,
            required int isCorrect,
            required int answeredAt,
          }) =>
              QuizAnswersCompanion.insert(
            id: id,
            sessionId: sessionId,
            wordId: wordId,
            isCorrect: isCorrect,
            answeredAt: answeredAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$QuizAnswersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sessionId = false, wordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable:
                        $$QuizAnswersTableReferences._sessionIdTable(db),
                    referencedColumn:
                        $$QuizAnswersTableReferences._sessionIdTable(db).id,
                  ) as T;
                }
                if (wordId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.wordId,
                    referencedTable:
                        $$QuizAnswersTableReferences._wordIdTable(db),
                    referencedColumn:
                        $$QuizAnswersTableReferences._wordIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$QuizAnswersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuizAnswersTable,
    QuizAnswer,
    $$QuizAnswersTableFilterComposer,
    $$QuizAnswersTableOrderingComposer,
    $$QuizAnswersTableAnnotationComposer,
    $$QuizAnswersTableCreateCompanionBuilder,
    $$QuizAnswersTableUpdateCompanionBuilder,
    (QuizAnswer, $$QuizAnswersTableReferences),
    QuizAnswer,
    PrefetchHooks Function({bool sessionId, bool wordId})>;
typedef $$StudyRecordsTableCreateCompanionBuilder = StudyRecordsCompanion
    Function({
  Value<int> id,
  required String studyDate,
  Value<int> wordsStudied,
  Value<int> quizCompleted,
});
typedef $$StudyRecordsTableUpdateCompanionBuilder = StudyRecordsCompanion
    Function({
  Value<int> id,
  Value<String> studyDate,
  Value<int> wordsStudied,
  Value<int> quizCompleted,
});

class $$StudyRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $StudyRecordsTable> {
  $$StudyRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get studyDate => $composableBuilder(
      column: $table.studyDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wordsStudied => $composableBuilder(
      column: $table.wordsStudied, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quizCompleted => $composableBuilder(
      column: $table.quizCompleted, builder: (column) => ColumnFilters(column));
}

class $$StudyRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudyRecordsTable> {
  $$StudyRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get studyDate => $composableBuilder(
      column: $table.studyDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wordsStudied => $composableBuilder(
      column: $table.wordsStudied,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quizCompleted => $composableBuilder(
      column: $table.quizCompleted,
      builder: (column) => ColumnOrderings(column));
}

class $$StudyRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudyRecordsTable> {
  $$StudyRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studyDate =>
      $composableBuilder(column: $table.studyDate, builder: (column) => column);

  GeneratedColumn<int> get wordsStudied => $composableBuilder(
      column: $table.wordsStudied, builder: (column) => column);

  GeneratedColumn<int> get quizCompleted => $composableBuilder(
      column: $table.quizCompleted, builder: (column) => column);
}

class $$StudyRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StudyRecordsTable,
    StudyRecord,
    $$StudyRecordsTableFilterComposer,
    $$StudyRecordsTableOrderingComposer,
    $$StudyRecordsTableAnnotationComposer,
    $$StudyRecordsTableCreateCompanionBuilder,
    $$StudyRecordsTableUpdateCompanionBuilder,
    (
      StudyRecord,
      BaseReferences<_$AppDatabase, $StudyRecordsTable, StudyRecord>
    ),
    StudyRecord,
    PrefetchHooks Function()> {
  $$StudyRecordsTableTableManager(_$AppDatabase db, $StudyRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> studyDate = const Value.absent(),
            Value<int> wordsStudied = const Value.absent(),
            Value<int> quizCompleted = const Value.absent(),
          }) =>
              StudyRecordsCompanion(
            id: id,
            studyDate: studyDate,
            wordsStudied: wordsStudied,
            quizCompleted: quizCompleted,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String studyDate,
            Value<int> wordsStudied = const Value.absent(),
            Value<int> quizCompleted = const Value.absent(),
          }) =>
              StudyRecordsCompanion.insert(
            id: id,
            studyDate: studyDate,
            wordsStudied: wordsStudied,
            quizCompleted: quizCompleted,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StudyRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StudyRecordsTable,
    StudyRecord,
    $$StudyRecordsTableFilterComposer,
    $$StudyRecordsTableOrderingComposer,
    $$StudyRecordsTableAnnotationComposer,
    $$StudyRecordsTableCreateCompanionBuilder,
    $$StudyRecordsTableUpdateCompanionBuilder,
    (
      StudyRecord,
      BaseReferences<_$AppDatabase, $StudyRecordsTable, StudyRecord>
    ),
    StudyRecord,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$ExampleSentencesTableTableManager get exampleSentences =>
      $$ExampleSentencesTableTableManager(_db, _db.exampleSentences);
  $$WordSourcesTableTableManager get wordSources =>
      $$WordSourcesTableTableManager(_db, _db.wordSources);
  $$QuizSessionsTableTableManager get quizSessions =>
      $$QuizSessionsTableTableManager(_db, _db.quizSessions);
  $$QuizAnswersTableTableManager get quizAnswers =>
      $$QuizAnswersTableTableManager(_db, _db.quizAnswers);
  $$StudyRecordsTableTableManager get studyRecords =>
      $$StudyRecordsTableTableManager(_db, _db.studyRecords);
}
