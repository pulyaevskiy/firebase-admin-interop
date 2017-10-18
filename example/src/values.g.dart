// GENERATED CODE - DO NOT MODIFY BY HAND

part of values;

// **************************************************************************
// Generator: BuiltValueGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line
// ignore_for_file: annotate_overrides
// ignore_for_file: avoid_annotating_with_dynamic
// ignore_for_file: avoid_returning_this
// ignore_for_file: omit_local_variable_types
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: sort_constructors_first

Serializer<Memo> _$memoSerializer = new _$MemoSerializer();

class _$MemoSerializer implements StructuredSerializer<Memo> {
  @override
  final Iterable<Type> types = const [Memo, _$Memo];
  @override
  final String wireName = 'Memo';

  @override
  Iterable serialize(Serializers serializers, Memo object,
      {FullType specifiedType: FullType.unspecified}) {
    final result = <Object>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(int)),
      'title',
      serializers.serialize(object.title,
          specifiedType: const FullType(String)),
      'createdAt',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(DateTime)),
    ];

    return result;
  }

  @override
  Memo deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType: FullType.unspecified}) {
    final result = new MemoBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'createdAt':
          result.createdAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime;
          break;
      }
    }

    return result.build();
  }
}

class _$Memo extends Memo {
  @override
  final int id;
  @override
  final String title;
  @override
  final DateTime createdAt;

  factory _$Memo([void updates(MemoBuilder b)]) =>
      (new MemoBuilder()..update(updates)).build();

  _$Memo._({this.id, this.title, this.createdAt}) : super._() {
    if (id == null) throw new ArgumentError.notNull('id');
    if (title == null) throw new ArgumentError.notNull('title');
    if (createdAt == null) throw new ArgumentError.notNull('createdAt');
  }

  @override
  Memo rebuild(void updates(MemoBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  MemoBuilder toBuilder() => new MemoBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is! Memo) return false;
    return id == other.id &&
        title == other.title &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    return $jf(
        $jc($jc($jc(0, id.hashCode), title.hashCode), createdAt.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Memo')
          ..add('id', id)
          ..add('title', title)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class MemoBuilder implements Builder<Memo, MemoBuilder> {
  _$Memo _$v;

  int _id;
  int get id => _$this._id;
  set id(int id) => _$this._id = id;

  String _title;
  String get title => _$this._title;
  set title(String title) => _$this._title = title;

  DateTime _createdAt;
  DateTime get createdAt => _$this._createdAt;
  set createdAt(DateTime createdAt) => _$this._createdAt = createdAt;

  MemoBuilder();

  MemoBuilder get _$this {
    if (_$v != null) {
      _id = _$v.id;
      _title = _$v.title;
      _createdAt = _$v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Memo other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other as _$Memo;
  }

  @override
  void update(void updates(MemoBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$Memo build() {
    final _$result =
        _$v ?? new _$Memo._(id: id, title: title, createdAt: createdAt);
    replace(_$result);
    return _$result;
  }
}
