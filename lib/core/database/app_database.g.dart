// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AdminUsersTable extends AdminUsers
    with TableInfo<$AdminUsersTable, AdminUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdminUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<String> salt = GeneratedColumn<String>(
    'salt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    email,
    passwordHash,
    salt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'admin_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdminUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('salt')) {
      context.handle(
        _saltMeta,
        salt.isAcceptableOrUnknown(data['salt']!, _saltMeta),
      );
    } else if (isInserting) {
      context.missing(_saltMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdminUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdminUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      salt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}salt'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AdminUsersTable createAlias(String alias) {
    return $AdminUsersTable(attachedDatabase, alias);
  }
}

class AdminUser extends DataClass implements Insertable<AdminUser> {
  final int id;
  final String name;
  final String email;
  final String passwordHash;
  final String salt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.salt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['password_hash'] = Variable<String>(passwordHash);
    map['salt'] = Variable<String>(salt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AdminUsersCompanion toCompanion(bool nullToAbsent) {
    return AdminUsersCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      passwordHash: Value(passwordHash),
      salt: Value(salt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AdminUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdminUser(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      salt: serializer.fromJson<String>(json['salt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'salt': serializer.toJson<String>(salt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AdminUser copyWith({
    int? id,
    String? name,
    String? email,
    String? passwordHash,
    String? salt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AdminUser(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    passwordHash: passwordHash ?? this.passwordHash,
    salt: salt ?? this.salt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AdminUser copyWithCompanion(AdminUsersCompanion data) {
    return AdminUser(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      salt: data.salt.present ? data.salt.value : this.salt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdminUser(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('salt: $salt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, email, passwordHash, salt, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdminUser &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.passwordHash == this.passwordHash &&
          other.salt == this.salt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AdminUsersCompanion extends UpdateCompanion<AdminUser> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String> passwordHash;
  final Value<String> salt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const AdminUsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.salt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AdminUsersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String email,
    required String passwordHash,
    required String salt,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       email = Value(email),
       passwordHash = Value(passwordHash),
       salt = Value(salt);
  static Insertable<AdminUser> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? passwordHash,
    Expression<String>? salt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (salt != null) 'salt': salt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AdminUsersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? email,
    Value<String>? passwordHash,
    Value<String>? salt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return AdminUsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (salt.present) {
      map['salt'] = Variable<String>(salt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdminUsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('salt: $salt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _codigoExemplarMeta = const VerificationMeta(
    'codigoExemplar',
  );
  @override
  late final GeneratedColumn<String> codigoExemplar = GeneratedColumn<String>(
    'codigo_exemplar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nomeLocalExemplarMeta = const VerificationMeta(
    'nomeLocalExemplar',
  );
  @override
  late final GeneratedColumn<String> nomeLocalExemplar =
      GeneratedColumn<String>(
        'nome_local_exemplar',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _numeroPatrimonioMeta = const VerificationMeta(
    'numeroPatrimonio',
  );
  @override
  late final GeneratedColumn<String> numeroPatrimonio = GeneratedColumn<String>(
    'numero_patrimonio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
    'titulo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tituloRevistaMeta = const VerificationMeta(
    'tituloRevista',
  );
  @override
  late final GeneratedColumn<String> tituloRevista = GeneratedColumn<String>(
    'titulo_revista',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _classificacaoMeta = const VerificationMeta(
    'classificacao',
  );
  @override
  late final GeneratedColumn<String> classificacao = GeneratedColumn<String>(
    'classificacao',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codigoTipoObraMeta = const VerificationMeta(
    'codigoTipoObra',
  );
  @override
  late final GeneratedColumn<String> codigoTipoObra = GeneratedColumn<String>(
    'codigo_tipo_obra',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nomeTipoObraMeta = const VerificationMeta(
    'nomeTipoObra',
  );
  @override
  late final GeneratedColumn<String> nomeTipoObra = GeneratedColumn<String>(
    'nome_tipo_obra',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exemplarVolumeMeta = const VerificationMeta(
    'exemplarVolume',
  );
  @override
  late final GeneratedColumn<String> exemplarVolume = GeneratedColumn<String>(
    'exemplar_volume',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _autorMeta = const VerificationMeta('autor');
  @override
  late final GeneratedColumn<String> autor = GeneratedColumn<String>(
    'autor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaConhecimentoMeta = const VerificationMeta(
    'areaConhecimento',
  );
  @override
  late final GeneratedColumn<String> areaConhecimento = GeneratedColumn<String>(
    'area_conhecimento',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _anoPublicacaoMeta = const VerificationMeta(
    'anoPublicacao',
  );
  @override
  late final GeneratedColumn<String> anoPublicacao = GeneratedColumn<String>(
    'ano_publicacao',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isbnMeta = const VerificationMeta('isbn');
  @override
  late final GeneratedColumn<String> isbn = GeneratedColumn<String>(
    'isbn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenciaMeta = const VerificationMeta(
    'referencia',
  );
  @override
  late final GeneratedColumn<String> referencia = GeneratedColumn<String>(
    'referencia',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Disponível'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codigoExemplar,
    nomeLocalExemplar,
    numeroPatrimonio,
    titulo,
    tituloRevista,
    classificacao,
    codigoTipoObra,
    nomeTipoObra,
    exemplarVolume,
    autor,
    areaConhecimento,
    anoPublicacao,
    isbn,
    referencia,
    coverUrl,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<Book> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codigo_exemplar')) {
      context.handle(
        _codigoExemplarMeta,
        codigoExemplar.isAcceptableOrUnknown(
          data['codigo_exemplar']!,
          _codigoExemplarMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_codigoExemplarMeta);
    }
    if (data.containsKey('nome_local_exemplar')) {
      context.handle(
        _nomeLocalExemplarMeta,
        nomeLocalExemplar.isAcceptableOrUnknown(
          data['nome_local_exemplar']!,
          _nomeLocalExemplarMeta,
        ),
      );
    }
    if (data.containsKey('numero_patrimonio')) {
      context.handle(
        _numeroPatrimonioMeta,
        numeroPatrimonio.isAcceptableOrUnknown(
          data['numero_patrimonio']!,
          _numeroPatrimonioMeta,
        ),
      );
    }
    if (data.containsKey('titulo')) {
      context.handle(
        _tituloMeta,
        titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta),
      );
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('titulo_revista')) {
      context.handle(
        _tituloRevistaMeta,
        tituloRevista.isAcceptableOrUnknown(
          data['titulo_revista']!,
          _tituloRevistaMeta,
        ),
      );
    }
    if (data.containsKey('classificacao')) {
      context.handle(
        _classificacaoMeta,
        classificacao.isAcceptableOrUnknown(
          data['classificacao']!,
          _classificacaoMeta,
        ),
      );
    }
    if (data.containsKey('codigo_tipo_obra')) {
      context.handle(
        _codigoTipoObraMeta,
        codigoTipoObra.isAcceptableOrUnknown(
          data['codigo_tipo_obra']!,
          _codigoTipoObraMeta,
        ),
      );
    }
    if (data.containsKey('nome_tipo_obra')) {
      context.handle(
        _nomeTipoObraMeta,
        nomeTipoObra.isAcceptableOrUnknown(
          data['nome_tipo_obra']!,
          _nomeTipoObraMeta,
        ),
      );
    }
    if (data.containsKey('exemplar_volume')) {
      context.handle(
        _exemplarVolumeMeta,
        exemplarVolume.isAcceptableOrUnknown(
          data['exemplar_volume']!,
          _exemplarVolumeMeta,
        ),
      );
    }
    if (data.containsKey('autor')) {
      context.handle(
        _autorMeta,
        autor.isAcceptableOrUnknown(data['autor']!, _autorMeta),
      );
    }
    if (data.containsKey('area_conhecimento')) {
      context.handle(
        _areaConhecimentoMeta,
        areaConhecimento.isAcceptableOrUnknown(
          data['area_conhecimento']!,
          _areaConhecimentoMeta,
        ),
      );
    }
    if (data.containsKey('ano_publicacao')) {
      context.handle(
        _anoPublicacaoMeta,
        anoPublicacao.isAcceptableOrUnknown(
          data['ano_publicacao']!,
          _anoPublicacaoMeta,
        ),
      );
    }
    if (data.containsKey('isbn')) {
      context.handle(
        _isbnMeta,
        isbn.isAcceptableOrUnknown(data['isbn']!, _isbnMeta),
      );
    }
    if (data.containsKey('referencia')) {
      context.handle(
        _referenciaMeta,
        referencia.isAcceptableOrUnknown(data['referencia']!, _referenciaMeta),
      );
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      codigoExemplar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo_exemplar'],
      )!,
      nomeLocalExemplar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome_local_exemplar'],
      ),
      numeroPatrimonio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}numero_patrimonio'],
      ),
      titulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titulo'],
      )!,
      tituloRevista: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titulo_revista'],
      ),
      classificacao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}classificacao'],
      ),
      codigoTipoObra: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo_tipo_obra'],
      ),
      nomeTipoObra: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome_tipo_obra'],
      ),
      exemplarVolume: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exemplar_volume'],
      ),
      autor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}autor'],
      ),
      areaConhecimento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_conhecimento'],
      ),
      anoPublicacao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ano_publicacao'],
      ),
      isbn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isbn'],
      ),
      referencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}referencia'],
      ),
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final int id;
  final String codigoExemplar;
  final String? nomeLocalExemplar;
  final String? numeroPatrimonio;
  final String titulo;
  final String? tituloRevista;
  final String? classificacao;
  final String? codigoTipoObra;
  final String? nomeTipoObra;
  final String? exemplarVolume;
  final String? autor;
  final String? areaConhecimento;
  final String? anoPublicacao;
  final String? isbn;
  final String? referencia;
  final String? coverUrl;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Book({
    required this.id,
    required this.codigoExemplar,
    this.nomeLocalExemplar,
    this.numeroPatrimonio,
    required this.titulo,
    this.tituloRevista,
    this.classificacao,
    this.codigoTipoObra,
    this.nomeTipoObra,
    this.exemplarVolume,
    this.autor,
    this.areaConhecimento,
    this.anoPublicacao,
    this.isbn,
    this.referencia,
    this.coverUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['codigo_exemplar'] = Variable<String>(codigoExemplar);
    if (!nullToAbsent || nomeLocalExemplar != null) {
      map['nome_local_exemplar'] = Variable<String>(nomeLocalExemplar);
    }
    if (!nullToAbsent || numeroPatrimonio != null) {
      map['numero_patrimonio'] = Variable<String>(numeroPatrimonio);
    }
    map['titulo'] = Variable<String>(titulo);
    if (!nullToAbsent || tituloRevista != null) {
      map['titulo_revista'] = Variable<String>(tituloRevista);
    }
    if (!nullToAbsent || classificacao != null) {
      map['classificacao'] = Variable<String>(classificacao);
    }
    if (!nullToAbsent || codigoTipoObra != null) {
      map['codigo_tipo_obra'] = Variable<String>(codigoTipoObra);
    }
    if (!nullToAbsent || nomeTipoObra != null) {
      map['nome_tipo_obra'] = Variable<String>(nomeTipoObra);
    }
    if (!nullToAbsent || exemplarVolume != null) {
      map['exemplar_volume'] = Variable<String>(exemplarVolume);
    }
    if (!nullToAbsent || autor != null) {
      map['autor'] = Variable<String>(autor);
    }
    if (!nullToAbsent || areaConhecimento != null) {
      map['area_conhecimento'] = Variable<String>(areaConhecimento);
    }
    if (!nullToAbsent || anoPublicacao != null) {
      map['ano_publicacao'] = Variable<String>(anoPublicacao);
    }
    if (!nullToAbsent || isbn != null) {
      map['isbn'] = Variable<String>(isbn);
    }
    if (!nullToAbsent || referencia != null) {
      map['referencia'] = Variable<String>(referencia);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      codigoExemplar: Value(codigoExemplar),
      nomeLocalExemplar: nomeLocalExemplar == null && nullToAbsent
          ? const Value.absent()
          : Value(nomeLocalExemplar),
      numeroPatrimonio: numeroPatrimonio == null && nullToAbsent
          ? const Value.absent()
          : Value(numeroPatrimonio),
      titulo: Value(titulo),
      tituloRevista: tituloRevista == null && nullToAbsent
          ? const Value.absent()
          : Value(tituloRevista),
      classificacao: classificacao == null && nullToAbsent
          ? const Value.absent()
          : Value(classificacao),
      codigoTipoObra: codigoTipoObra == null && nullToAbsent
          ? const Value.absent()
          : Value(codigoTipoObra),
      nomeTipoObra: nomeTipoObra == null && nullToAbsent
          ? const Value.absent()
          : Value(nomeTipoObra),
      exemplarVolume: exemplarVolume == null && nullToAbsent
          ? const Value.absent()
          : Value(exemplarVolume),
      autor: autor == null && nullToAbsent
          ? const Value.absent()
          : Value(autor),
      areaConhecimento: areaConhecimento == null && nullToAbsent
          ? const Value.absent()
          : Value(areaConhecimento),
      anoPublicacao: anoPublicacao == null && nullToAbsent
          ? const Value.absent()
          : Value(anoPublicacao),
      isbn: isbn == null && nullToAbsent ? const Value.absent() : Value(isbn),
      referencia: referencia == null && nullToAbsent
          ? const Value.absent()
          : Value(referencia),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<int>(json['id']),
      codigoExemplar: serializer.fromJson<String>(json['codigoExemplar']),
      nomeLocalExemplar: serializer.fromJson<String?>(
        json['nomeLocalExemplar'],
      ),
      numeroPatrimonio: serializer.fromJson<String?>(json['numeroPatrimonio']),
      titulo: serializer.fromJson<String>(json['titulo']),
      tituloRevista: serializer.fromJson<String?>(json['tituloRevista']),
      classificacao: serializer.fromJson<String?>(json['classificacao']),
      codigoTipoObra: serializer.fromJson<String?>(json['codigoTipoObra']),
      nomeTipoObra: serializer.fromJson<String?>(json['nomeTipoObra']),
      exemplarVolume: serializer.fromJson<String?>(json['exemplarVolume']),
      autor: serializer.fromJson<String?>(json['autor']),
      areaConhecimento: serializer.fromJson<String?>(json['areaConhecimento']),
      anoPublicacao: serializer.fromJson<String?>(json['anoPublicacao']),
      isbn: serializer.fromJson<String?>(json['isbn']),
      referencia: serializer.fromJson<String?>(json['referencia']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codigoExemplar': serializer.toJson<String>(codigoExemplar),
      'nomeLocalExemplar': serializer.toJson<String?>(nomeLocalExemplar),
      'numeroPatrimonio': serializer.toJson<String?>(numeroPatrimonio),
      'titulo': serializer.toJson<String>(titulo),
      'tituloRevista': serializer.toJson<String?>(tituloRevista),
      'classificacao': serializer.toJson<String?>(classificacao),
      'codigoTipoObra': serializer.toJson<String?>(codigoTipoObra),
      'nomeTipoObra': serializer.toJson<String?>(nomeTipoObra),
      'exemplarVolume': serializer.toJson<String?>(exemplarVolume),
      'autor': serializer.toJson<String?>(autor),
      'areaConhecimento': serializer.toJson<String?>(areaConhecimento),
      'anoPublicacao': serializer.toJson<String?>(anoPublicacao),
      'isbn': serializer.toJson<String?>(isbn),
      'referencia': serializer.toJson<String?>(referencia),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Book copyWith({
    int? id,
    String? codigoExemplar,
    Value<String?> nomeLocalExemplar = const Value.absent(),
    Value<String?> numeroPatrimonio = const Value.absent(),
    String? titulo,
    Value<String?> tituloRevista = const Value.absent(),
    Value<String?> classificacao = const Value.absent(),
    Value<String?> codigoTipoObra = const Value.absent(),
    Value<String?> nomeTipoObra = const Value.absent(),
    Value<String?> exemplarVolume = const Value.absent(),
    Value<String?> autor = const Value.absent(),
    Value<String?> areaConhecimento = const Value.absent(),
    Value<String?> anoPublicacao = const Value.absent(),
    Value<String?> isbn = const Value.absent(),
    Value<String?> referencia = const Value.absent(),
    Value<String?> coverUrl = const Value.absent(),
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Book(
    id: id ?? this.id,
    codigoExemplar: codigoExemplar ?? this.codigoExemplar,
    nomeLocalExemplar: nomeLocalExemplar.present
        ? nomeLocalExemplar.value
        : this.nomeLocalExemplar,
    numeroPatrimonio: numeroPatrimonio.present
        ? numeroPatrimonio.value
        : this.numeroPatrimonio,
    titulo: titulo ?? this.titulo,
    tituloRevista: tituloRevista.present
        ? tituloRevista.value
        : this.tituloRevista,
    classificacao: classificacao.present
        ? classificacao.value
        : this.classificacao,
    codigoTipoObra: codigoTipoObra.present
        ? codigoTipoObra.value
        : this.codigoTipoObra,
    nomeTipoObra: nomeTipoObra.present ? nomeTipoObra.value : this.nomeTipoObra,
    exemplarVolume: exemplarVolume.present
        ? exemplarVolume.value
        : this.exemplarVolume,
    autor: autor.present ? autor.value : this.autor,
    areaConhecimento: areaConhecimento.present
        ? areaConhecimento.value
        : this.areaConhecimento,
    anoPublicacao: anoPublicacao.present
        ? anoPublicacao.value
        : this.anoPublicacao,
    isbn: isbn.present ? isbn.value : this.isbn,
    referencia: referencia.present ? referencia.value : this.referencia,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      codigoExemplar: data.codigoExemplar.present
          ? data.codigoExemplar.value
          : this.codigoExemplar,
      nomeLocalExemplar: data.nomeLocalExemplar.present
          ? data.nomeLocalExemplar.value
          : this.nomeLocalExemplar,
      numeroPatrimonio: data.numeroPatrimonio.present
          ? data.numeroPatrimonio.value
          : this.numeroPatrimonio,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      tituloRevista: data.tituloRevista.present
          ? data.tituloRevista.value
          : this.tituloRevista,
      classificacao: data.classificacao.present
          ? data.classificacao.value
          : this.classificacao,
      codigoTipoObra: data.codigoTipoObra.present
          ? data.codigoTipoObra.value
          : this.codigoTipoObra,
      nomeTipoObra: data.nomeTipoObra.present
          ? data.nomeTipoObra.value
          : this.nomeTipoObra,
      exemplarVolume: data.exemplarVolume.present
          ? data.exemplarVolume.value
          : this.exemplarVolume,
      autor: data.autor.present ? data.autor.value : this.autor,
      areaConhecimento: data.areaConhecimento.present
          ? data.areaConhecimento.value
          : this.areaConhecimento,
      anoPublicacao: data.anoPublicacao.present
          ? data.anoPublicacao.value
          : this.anoPublicacao,
      isbn: data.isbn.present ? data.isbn.value : this.isbn,
      referencia: data.referencia.present
          ? data.referencia.value
          : this.referencia,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('codigoExemplar: $codigoExemplar, ')
          ..write('nomeLocalExemplar: $nomeLocalExemplar, ')
          ..write('numeroPatrimonio: $numeroPatrimonio, ')
          ..write('titulo: $titulo, ')
          ..write('tituloRevista: $tituloRevista, ')
          ..write('classificacao: $classificacao, ')
          ..write('codigoTipoObra: $codigoTipoObra, ')
          ..write('nomeTipoObra: $nomeTipoObra, ')
          ..write('exemplarVolume: $exemplarVolume, ')
          ..write('autor: $autor, ')
          ..write('areaConhecimento: $areaConhecimento, ')
          ..write('anoPublicacao: $anoPublicacao, ')
          ..write('isbn: $isbn, ')
          ..write('referencia: $referencia, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    codigoExemplar,
    nomeLocalExemplar,
    numeroPatrimonio,
    titulo,
    tituloRevista,
    classificacao,
    codigoTipoObra,
    nomeTipoObra,
    exemplarVolume,
    autor,
    areaConhecimento,
    anoPublicacao,
    isbn,
    referencia,
    coverUrl,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.codigoExemplar == this.codigoExemplar &&
          other.nomeLocalExemplar == this.nomeLocalExemplar &&
          other.numeroPatrimonio == this.numeroPatrimonio &&
          other.titulo == this.titulo &&
          other.tituloRevista == this.tituloRevista &&
          other.classificacao == this.classificacao &&
          other.codigoTipoObra == this.codigoTipoObra &&
          other.nomeTipoObra == this.nomeTipoObra &&
          other.exemplarVolume == this.exemplarVolume &&
          other.autor == this.autor &&
          other.areaConhecimento == this.areaConhecimento &&
          other.anoPublicacao == this.anoPublicacao &&
          other.isbn == this.isbn &&
          other.referencia == this.referencia &&
          other.coverUrl == this.coverUrl &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<String> codigoExemplar;
  final Value<String?> nomeLocalExemplar;
  final Value<String?> numeroPatrimonio;
  final Value<String> titulo;
  final Value<String?> tituloRevista;
  final Value<String?> classificacao;
  final Value<String?> codigoTipoObra;
  final Value<String?> nomeTipoObra;
  final Value<String?> exemplarVolume;
  final Value<String?> autor;
  final Value<String?> areaConhecimento;
  final Value<String?> anoPublicacao;
  final Value<String?> isbn;
  final Value<String?> referencia;
  final Value<String?> coverUrl;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.codigoExemplar = const Value.absent(),
    this.nomeLocalExemplar = const Value.absent(),
    this.numeroPatrimonio = const Value.absent(),
    this.titulo = const Value.absent(),
    this.tituloRevista = const Value.absent(),
    this.classificacao = const Value.absent(),
    this.codigoTipoObra = const Value.absent(),
    this.nomeTipoObra = const Value.absent(),
    this.exemplarVolume = const Value.absent(),
    this.autor = const Value.absent(),
    this.areaConhecimento = const Value.absent(),
    this.anoPublicacao = const Value.absent(),
    this.isbn = const Value.absent(),
    this.referencia = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String codigoExemplar,
    this.nomeLocalExemplar = const Value.absent(),
    this.numeroPatrimonio = const Value.absent(),
    required String titulo,
    this.tituloRevista = const Value.absent(),
    this.classificacao = const Value.absent(),
    this.codigoTipoObra = const Value.absent(),
    this.nomeTipoObra = const Value.absent(),
    this.exemplarVolume = const Value.absent(),
    this.autor = const Value.absent(),
    this.areaConhecimento = const Value.absent(),
    this.anoPublicacao = const Value.absent(),
    this.isbn = const Value.absent(),
    this.referencia = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : codigoExemplar = Value(codigoExemplar),
       titulo = Value(titulo);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<String>? codigoExemplar,
    Expression<String>? nomeLocalExemplar,
    Expression<String>? numeroPatrimonio,
    Expression<String>? titulo,
    Expression<String>? tituloRevista,
    Expression<String>? classificacao,
    Expression<String>? codigoTipoObra,
    Expression<String>? nomeTipoObra,
    Expression<String>? exemplarVolume,
    Expression<String>? autor,
    Expression<String>? areaConhecimento,
    Expression<String>? anoPublicacao,
    Expression<String>? isbn,
    Expression<String>? referencia,
    Expression<String>? coverUrl,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codigoExemplar != null) 'codigo_exemplar': codigoExemplar,
      if (nomeLocalExemplar != null) 'nome_local_exemplar': nomeLocalExemplar,
      if (numeroPatrimonio != null) 'numero_patrimonio': numeroPatrimonio,
      if (titulo != null) 'titulo': titulo,
      if (tituloRevista != null) 'titulo_revista': tituloRevista,
      if (classificacao != null) 'classificacao': classificacao,
      if (codigoTipoObra != null) 'codigo_tipo_obra': codigoTipoObra,
      if (nomeTipoObra != null) 'nome_tipo_obra': nomeTipoObra,
      if (exemplarVolume != null) 'exemplar_volume': exemplarVolume,
      if (autor != null) 'autor': autor,
      if (areaConhecimento != null) 'area_conhecimento': areaConhecimento,
      if (anoPublicacao != null) 'ano_publicacao': anoPublicacao,
      if (isbn != null) 'isbn': isbn,
      if (referencia != null) 'referencia': referencia,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BooksCompanion copyWith({
    Value<int>? id,
    Value<String>? codigoExemplar,
    Value<String?>? nomeLocalExemplar,
    Value<String?>? numeroPatrimonio,
    Value<String>? titulo,
    Value<String?>? tituloRevista,
    Value<String?>? classificacao,
    Value<String?>? codigoTipoObra,
    Value<String?>? nomeTipoObra,
    Value<String?>? exemplarVolume,
    Value<String?>? autor,
    Value<String?>? areaConhecimento,
    Value<String?>? anoPublicacao,
    Value<String?>? isbn,
    Value<String?>? referencia,
    Value<String?>? coverUrl,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      codigoExemplar: codigoExemplar ?? this.codigoExemplar,
      nomeLocalExemplar: nomeLocalExemplar ?? this.nomeLocalExemplar,
      numeroPatrimonio: numeroPatrimonio ?? this.numeroPatrimonio,
      titulo: titulo ?? this.titulo,
      tituloRevista: tituloRevista ?? this.tituloRevista,
      classificacao: classificacao ?? this.classificacao,
      codigoTipoObra: codigoTipoObra ?? this.codigoTipoObra,
      nomeTipoObra: nomeTipoObra ?? this.nomeTipoObra,
      exemplarVolume: exemplarVolume ?? this.exemplarVolume,
      autor: autor ?? this.autor,
      areaConhecimento: areaConhecimento ?? this.areaConhecimento,
      anoPublicacao: anoPublicacao ?? this.anoPublicacao,
      isbn: isbn ?? this.isbn,
      referencia: referencia ?? this.referencia,
      coverUrl: coverUrl ?? this.coverUrl,
      status: status ?? this.status,
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
    if (codigoExemplar.present) {
      map['codigo_exemplar'] = Variable<String>(codigoExemplar.value);
    }
    if (nomeLocalExemplar.present) {
      map['nome_local_exemplar'] = Variable<String>(nomeLocalExemplar.value);
    }
    if (numeroPatrimonio.present) {
      map['numero_patrimonio'] = Variable<String>(numeroPatrimonio.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (tituloRevista.present) {
      map['titulo_revista'] = Variable<String>(tituloRevista.value);
    }
    if (classificacao.present) {
      map['classificacao'] = Variable<String>(classificacao.value);
    }
    if (codigoTipoObra.present) {
      map['codigo_tipo_obra'] = Variable<String>(codigoTipoObra.value);
    }
    if (nomeTipoObra.present) {
      map['nome_tipo_obra'] = Variable<String>(nomeTipoObra.value);
    }
    if (exemplarVolume.present) {
      map['exemplar_volume'] = Variable<String>(exemplarVolume.value);
    }
    if (autor.present) {
      map['autor'] = Variable<String>(autor.value);
    }
    if (areaConhecimento.present) {
      map['area_conhecimento'] = Variable<String>(areaConhecimento.value);
    }
    if (anoPublicacao.present) {
      map['ano_publicacao'] = Variable<String>(anoPublicacao.value);
    }
    if (isbn.present) {
      map['isbn'] = Variable<String>(isbn.value);
    }
    if (referencia.present) {
      map['referencia'] = Variable<String>(referencia.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('codigoExemplar: $codigoExemplar, ')
          ..write('nomeLocalExemplar: $nomeLocalExemplar, ')
          ..write('numeroPatrimonio: $numeroPatrimonio, ')
          ..write('titulo: $titulo, ')
          ..write('tituloRevista: $tituloRevista, ')
          ..write('classificacao: $classificacao, ')
          ..write('codigoTipoObra: $codigoTipoObra, ')
          ..write('nomeTipoObra: $nomeTipoObra, ')
          ..write('exemplarVolume: $exemplarVolume, ')
          ..write('autor: $autor, ')
          ..write('areaConhecimento: $areaConhecimento, ')
          ..write('anoPublicacao: $anoPublicacao, ')
          ..write('isbn: $isbn, ')
          ..write('referencia: $referencia, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $StudentsTable extends Students with TableInfo<$StudentsTable, Student> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rmRaMeta = const VerificationMeta('rmRa');
  @override
  late final GeneratedColumn<String> rmRa = GeneratedColumn<String>(
    'rm_ra',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _segmentoMeta = const VerificationMeta(
    'segmento',
  );
  @override
  late final GeneratedColumn<String> segmento = GeneratedColumn<String>(
    'segmento',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('fundamental1'),
  );
  static const VerificationMeta _fotoPathMeta = const VerificationMeta(
    'fotoPath',
  );
  @override
  late final GeneratedColumn<String> fotoPath = GeneratedColumn<String>(
    'foto_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ativoMeta = const VerificationMeta('ativo');
  @override
  late final GeneratedColumn<bool> ativo = GeneratedColumn<bool>(
    'ativo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ativo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rmRa,
    nome,
    segmento,
    fotoPath,
    ativo,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(
    Insertable<Student> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('rm_ra')) {
      context.handle(
        _rmRaMeta,
        rmRa.isAcceptableOrUnknown(data['rm_ra']!, _rmRaMeta),
      );
    } else if (isInserting) {
      context.missing(_rmRaMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('segmento')) {
      context.handle(
        _segmentoMeta,
        segmento.isAcceptableOrUnknown(data['segmento']!, _segmentoMeta),
      );
    }
    if (data.containsKey('foto_path')) {
      context.handle(
        _fotoPathMeta,
        fotoPath.isAcceptableOrUnknown(data['foto_path']!, _fotoPathMeta),
      );
    }
    if (data.containsKey('ativo')) {
      context.handle(
        _ativoMeta,
        ativo.isAcceptableOrUnknown(data['ativo']!, _ativoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Student map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Student(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rmRa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rm_ra'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      segmento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}segmento'],
      )!,
      fotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_path'],
      ),
      ativo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ativo'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StudentsTable createAlias(String alias) {
    return $StudentsTable(attachedDatabase, alias);
  }
}

class Student extends DataClass implements Insertable<Student> {
  final int id;
  final String rmRa;
  final String nome;
  final String segmento;
  final String? fotoPath;
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Student({
    required this.id,
    required this.rmRa,
    required this.nome,
    required this.segmento,
    this.fotoPath,
    required this.ativo,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rm_ra'] = Variable<String>(rmRa);
    map['nome'] = Variable<String>(nome);
    map['segmento'] = Variable<String>(segmento);
    if (!nullToAbsent || fotoPath != null) {
      map['foto_path'] = Variable<String>(fotoPath);
    }
    map['ativo'] = Variable<bool>(ativo);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StudentsCompanion toCompanion(bool nullToAbsent) {
    return StudentsCompanion(
      id: Value(id),
      rmRa: Value(rmRa),
      nome: Value(nome),
      segmento: Value(segmento),
      fotoPath: fotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoPath),
      ativo: Value(ativo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Student.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Student(
      id: serializer.fromJson<int>(json['id']),
      rmRa: serializer.fromJson<String>(json['rmRa']),
      nome: serializer.fromJson<String>(json['nome']),
      segmento: serializer.fromJson<String>(json['segmento']),
      fotoPath: serializer.fromJson<String?>(json['fotoPath']),
      ativo: serializer.fromJson<bool>(json['ativo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rmRa': serializer.toJson<String>(rmRa),
      'nome': serializer.toJson<String>(nome),
      'segmento': serializer.toJson<String>(segmento),
      'fotoPath': serializer.toJson<String?>(fotoPath),
      'ativo': serializer.toJson<bool>(ativo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Student copyWith({
    int? id,
    String? rmRa,
    String? nome,
    String? segmento,
    Value<String?> fotoPath = const Value.absent(),
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Student(
    id: id ?? this.id,
    rmRa: rmRa ?? this.rmRa,
    nome: nome ?? this.nome,
    segmento: segmento ?? this.segmento,
    fotoPath: fotoPath.present ? fotoPath.value : this.fotoPath,
    ativo: ativo ?? this.ativo,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Student copyWithCompanion(StudentsCompanion data) {
    return Student(
      id: data.id.present ? data.id.value : this.id,
      rmRa: data.rmRa.present ? data.rmRa.value : this.rmRa,
      nome: data.nome.present ? data.nome.value : this.nome,
      segmento: data.segmento.present ? data.segmento.value : this.segmento,
      fotoPath: data.fotoPath.present ? data.fotoPath.value : this.fotoPath,
      ativo: data.ativo.present ? data.ativo.value : this.ativo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Student(')
          ..write('id: $id, ')
          ..write('rmRa: $rmRa, ')
          ..write('nome: $nome, ')
          ..write('segmento: $segmento, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('ativo: $ativo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rmRa,
    nome,
    segmento,
    fotoPath,
    ativo,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Student &&
          other.id == this.id &&
          other.rmRa == this.rmRa &&
          other.nome == this.nome &&
          other.segmento == this.segmento &&
          other.fotoPath == this.fotoPath &&
          other.ativo == this.ativo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StudentsCompanion extends UpdateCompanion<Student> {
  final Value<int> id;
  final Value<String> rmRa;
  final Value<String> nome;
  final Value<String> segmento;
  final Value<String?> fotoPath;
  final Value<bool> ativo;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const StudentsCompanion({
    this.id = const Value.absent(),
    this.rmRa = const Value.absent(),
    this.nome = const Value.absent(),
    this.segmento = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.ativo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  StudentsCompanion.insert({
    this.id = const Value.absent(),
    required String rmRa,
    required String nome,
    this.segmento = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.ativo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : rmRa = Value(rmRa),
       nome = Value(nome);
  static Insertable<Student> custom({
    Expression<int>? id,
    Expression<String>? rmRa,
    Expression<String>? nome,
    Expression<String>? segmento,
    Expression<String>? fotoPath,
    Expression<bool>? ativo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rmRa != null) 'rm_ra': rmRa,
      if (nome != null) 'nome': nome,
      if (segmento != null) 'segmento': segmento,
      if (fotoPath != null) 'foto_path': fotoPath,
      if (ativo != null) 'ativo': ativo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  StudentsCompanion copyWith({
    Value<int>? id,
    Value<String>? rmRa,
    Value<String>? nome,
    Value<String>? segmento,
    Value<String?>? fotoPath,
    Value<bool>? ativo,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return StudentsCompanion(
      id: id ?? this.id,
      rmRa: rmRa ?? this.rmRa,
      nome: nome ?? this.nome,
      segmento: segmento ?? this.segmento,
      fotoPath: fotoPath ?? this.fotoPath,
      ativo: ativo ?? this.ativo,
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
    if (rmRa.present) {
      map['rm_ra'] = Variable<String>(rmRa.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (segmento.present) {
      map['segmento'] = Variable<String>(segmento.value);
    }
    if (fotoPath.present) {
      map['foto_path'] = Variable<String>(fotoPath.value);
    }
    if (ativo.present) {
      map['ativo'] = Variable<bool>(ativo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentsCompanion(')
          ..write('id: $id, ')
          ..write('rmRa: $rmRa, ')
          ..write('nome: $nome, ')
          ..write('segmento: $segmento, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('ativo: $ativo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LoansTable extends Loans with TableInfo<$LoansTable, Loan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id)',
    ),
  );
  static const VerificationMeta _dataEmprestimoMeta = const VerificationMeta(
    'dataEmprestimo',
  );
  @override
  late final GeneratedColumn<DateTime> dataEmprestimo =
      GeneratedColumn<DateTime>(
        'data_emprestimo',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _dataDevolucaoPrevistaMeta =
      const VerificationMeta('dataDevolucaoPrevista');
  @override
  late final GeneratedColumn<DateTime> dataDevolucaoPrevista =
      GeneratedColumn<DateTime>(
        'data_devolucao_prevista',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dataDevolucaoEfetivaMeta =
      const VerificationMeta('dataDevolucaoEfetiva');
  @override
  late final GeneratedColumn<DateTime> dataDevolucaoEfetiva =
      GeneratedColumn<DateTime>(
        'data_devolucao_efetiva',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Ativo'),
  );
  static const VerificationMeta _observacoesMeta = const VerificationMeta(
    'observacoes',
  );
  @override
  late final GeneratedColumn<String> observacoes = GeneratedColumn<String>(
    'observacoes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    studentId,
    dataEmprestimo,
    dataDevolucaoPrevista,
    dataDevolucaoEfetiva,
    status,
    observacoes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loans';
  @override
  VerificationContext validateIntegrity(
    Insertable<Loan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('data_emprestimo')) {
      context.handle(
        _dataEmprestimoMeta,
        dataEmprestimo.isAcceptableOrUnknown(
          data['data_emprestimo']!,
          _dataEmprestimoMeta,
        ),
      );
    }
    if (data.containsKey('data_devolucao_prevista')) {
      context.handle(
        _dataDevolucaoPrevistaMeta,
        dataDevolucaoPrevista.isAcceptableOrUnknown(
          data['data_devolucao_prevista']!,
          _dataDevolucaoPrevistaMeta,
        ),
      );
    }
    if (data.containsKey('data_devolucao_efetiva')) {
      context.handle(
        _dataDevolucaoEfetivaMeta,
        dataDevolucaoEfetiva.isAcceptableOrUnknown(
          data['data_devolucao_efetiva']!,
          _dataDevolucaoEfetivaMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('observacoes')) {
      context.handle(
        _observacoesMeta,
        observacoes.isAcceptableOrUnknown(
          data['observacoes']!,
          _observacoesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Loan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Loan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      dataEmprestimo: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_emprestimo'],
      )!,
      dataDevolucaoPrevista: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_devolucao_prevista'],
      ),
      dataDevolucaoEfetiva: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_devolucao_efetiva'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      observacoes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observacoes'],
      ),
    );
  }

  @override
  $LoansTable createAlias(String alias) {
    return $LoansTable(attachedDatabase, alias);
  }
}

class Loan extends DataClass implements Insertable<Loan> {
  final int id;
  final int bookId;
  final int studentId;
  final DateTime dataEmprestimo;
  final DateTime? dataDevolucaoPrevista;
  final DateTime? dataDevolucaoEfetiva;
  final String status;
  final String? observacoes;
  const Loan({
    required this.id,
    required this.bookId,
    required this.studentId,
    required this.dataEmprestimo,
    this.dataDevolucaoPrevista,
    this.dataDevolucaoEfetiva,
    required this.status,
    this.observacoes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['student_id'] = Variable<int>(studentId);
    map['data_emprestimo'] = Variable<DateTime>(dataEmprestimo);
    if (!nullToAbsent || dataDevolucaoPrevista != null) {
      map['data_devolucao_prevista'] = Variable<DateTime>(
        dataDevolucaoPrevista,
      );
    }
    if (!nullToAbsent || dataDevolucaoEfetiva != null) {
      map['data_devolucao_efetiva'] = Variable<DateTime>(dataDevolucaoEfetiva);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || observacoes != null) {
      map['observacoes'] = Variable<String>(observacoes);
    }
    return map;
  }

  LoansCompanion toCompanion(bool nullToAbsent) {
    return LoansCompanion(
      id: Value(id),
      bookId: Value(bookId),
      studentId: Value(studentId),
      dataEmprestimo: Value(dataEmprestimo),
      dataDevolucaoPrevista: dataDevolucaoPrevista == null && nullToAbsent
          ? const Value.absent()
          : Value(dataDevolucaoPrevista),
      dataDevolucaoEfetiva: dataDevolucaoEfetiva == null && nullToAbsent
          ? const Value.absent()
          : Value(dataDevolucaoEfetiva),
      status: Value(status),
      observacoes: observacoes == null && nullToAbsent
          ? const Value.absent()
          : Value(observacoes),
    );
  }

  factory Loan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Loan(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      studentId: serializer.fromJson<int>(json['studentId']),
      dataEmprestimo: serializer.fromJson<DateTime>(json['dataEmprestimo']),
      dataDevolucaoPrevista: serializer.fromJson<DateTime?>(
        json['dataDevolucaoPrevista'],
      ),
      dataDevolucaoEfetiva: serializer.fromJson<DateTime?>(
        json['dataDevolucaoEfetiva'],
      ),
      status: serializer.fromJson<String>(json['status']),
      observacoes: serializer.fromJson<String?>(json['observacoes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'studentId': serializer.toJson<int>(studentId),
      'dataEmprestimo': serializer.toJson<DateTime>(dataEmprestimo),
      'dataDevolucaoPrevista': serializer.toJson<DateTime?>(
        dataDevolucaoPrevista,
      ),
      'dataDevolucaoEfetiva': serializer.toJson<DateTime?>(
        dataDevolucaoEfetiva,
      ),
      'status': serializer.toJson<String>(status),
      'observacoes': serializer.toJson<String?>(observacoes),
    };
  }

  Loan copyWith({
    int? id,
    int? bookId,
    int? studentId,
    DateTime? dataEmprestimo,
    Value<DateTime?> dataDevolucaoPrevista = const Value.absent(),
    Value<DateTime?> dataDevolucaoEfetiva = const Value.absent(),
    String? status,
    Value<String?> observacoes = const Value.absent(),
  }) => Loan(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    studentId: studentId ?? this.studentId,
    dataEmprestimo: dataEmprestimo ?? this.dataEmprestimo,
    dataDevolucaoPrevista: dataDevolucaoPrevista.present
        ? dataDevolucaoPrevista.value
        : this.dataDevolucaoPrevista,
    dataDevolucaoEfetiva: dataDevolucaoEfetiva.present
        ? dataDevolucaoEfetiva.value
        : this.dataDevolucaoEfetiva,
    status: status ?? this.status,
    observacoes: observacoes.present ? observacoes.value : this.observacoes,
  );
  Loan copyWithCompanion(LoansCompanion data) {
    return Loan(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      dataEmprestimo: data.dataEmprestimo.present
          ? data.dataEmprestimo.value
          : this.dataEmprestimo,
      dataDevolucaoPrevista: data.dataDevolucaoPrevista.present
          ? data.dataDevolucaoPrevista.value
          : this.dataDevolucaoPrevista,
      dataDevolucaoEfetiva: data.dataDevolucaoEfetiva.present
          ? data.dataDevolucaoEfetiva.value
          : this.dataDevolucaoEfetiva,
      status: data.status.present ? data.status.value : this.status,
      observacoes: data.observacoes.present
          ? data.observacoes.value
          : this.observacoes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Loan(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('studentId: $studentId, ')
          ..write('dataEmprestimo: $dataEmprestimo, ')
          ..write('dataDevolucaoPrevista: $dataDevolucaoPrevista, ')
          ..write('dataDevolucaoEfetiva: $dataDevolucaoEfetiva, ')
          ..write('status: $status, ')
          ..write('observacoes: $observacoes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    studentId,
    dataEmprestimo,
    dataDevolucaoPrevista,
    dataDevolucaoEfetiva,
    status,
    observacoes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Loan &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.studentId == this.studentId &&
          other.dataEmprestimo == this.dataEmprestimo &&
          other.dataDevolucaoPrevista == this.dataDevolucaoPrevista &&
          other.dataDevolucaoEfetiva == this.dataDevolucaoEfetiva &&
          other.status == this.status &&
          other.observacoes == this.observacoes);
}

class LoansCompanion extends UpdateCompanion<Loan> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<int> studentId;
  final Value<DateTime> dataEmprestimo;
  final Value<DateTime?> dataDevolucaoPrevista;
  final Value<DateTime?> dataDevolucaoEfetiva;
  final Value<String> status;
  final Value<String?> observacoes;
  const LoansCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.dataEmprestimo = const Value.absent(),
    this.dataDevolucaoPrevista = const Value.absent(),
    this.dataDevolucaoEfetiva = const Value.absent(),
    this.status = const Value.absent(),
    this.observacoes = const Value.absent(),
  });
  LoansCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required int studentId,
    this.dataEmprestimo = const Value.absent(),
    this.dataDevolucaoPrevista = const Value.absent(),
    this.dataDevolucaoEfetiva = const Value.absent(),
    this.status = const Value.absent(),
    this.observacoes = const Value.absent(),
  }) : bookId = Value(bookId),
       studentId = Value(studentId);
  static Insertable<Loan> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<int>? studentId,
    Expression<DateTime>? dataEmprestimo,
    Expression<DateTime>? dataDevolucaoPrevista,
    Expression<DateTime>? dataDevolucaoEfetiva,
    Expression<String>? status,
    Expression<String>? observacoes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (studentId != null) 'student_id': studentId,
      if (dataEmprestimo != null) 'data_emprestimo': dataEmprestimo,
      if (dataDevolucaoPrevista != null)
        'data_devolucao_prevista': dataDevolucaoPrevista,
      if (dataDevolucaoEfetiva != null)
        'data_devolucao_efetiva': dataDevolucaoEfetiva,
      if (status != null) 'status': status,
      if (observacoes != null) 'observacoes': observacoes,
    });
  }

  LoansCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<int>? studentId,
    Value<DateTime>? dataEmprestimo,
    Value<DateTime?>? dataDevolucaoPrevista,
    Value<DateTime?>? dataDevolucaoEfetiva,
    Value<String>? status,
    Value<String?>? observacoes,
  }) {
    return LoansCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      studentId: studentId ?? this.studentId,
      dataEmprestimo: dataEmprestimo ?? this.dataEmprestimo,
      dataDevolucaoPrevista:
          dataDevolucaoPrevista ?? this.dataDevolucaoPrevista,
      dataDevolucaoEfetiva: dataDevolucaoEfetiva ?? this.dataDevolucaoEfetiva,
      status: status ?? this.status,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (dataEmprestimo.present) {
      map['data_emprestimo'] = Variable<DateTime>(dataEmprestimo.value);
    }
    if (dataDevolucaoPrevista.present) {
      map['data_devolucao_prevista'] = Variable<DateTime>(
        dataDevolucaoPrevista.value,
      );
    }
    if (dataDevolucaoEfetiva.present) {
      map['data_devolucao_efetiva'] = Variable<DateTime>(
        dataDevolucaoEfetiva.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (observacoes.present) {
      map['observacoes'] = Variable<String>(observacoes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoansCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('studentId: $studentId, ')
          ..write('dataEmprestimo: $dataEmprestimo, ')
          ..write('dataDevolucaoPrevista: $dataDevolucaoPrevista, ')
          ..write('dataDevolucaoEfetiva: $dataDevolucaoEfetiva, ')
          ..write('status: $status, ')
          ..write('observacoes: $observacoes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AdminUsersTable adminUsers = $AdminUsersTable(this);
  late final $BooksTable books = $BooksTable(this);
  late final $StudentsTable students = $StudentsTable(this);
  late final $LoansTable loans = $LoansTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    adminUsers,
    books,
    students,
    loans,
  ];
}

typedef $$AdminUsersTableCreateCompanionBuilder =
    AdminUsersCompanion Function({
      Value<int> id,
      required String name,
      required String email,
      required String passwordHash,
      required String salt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$AdminUsersTableUpdateCompanionBuilder =
    AdminUsersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> email,
      Value<String> passwordHash,
      Value<String> salt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$AdminUsersTableFilterComposer
    extends Composer<_$AppDatabase, $AdminUsersTable> {
  $$AdminUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AdminUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $AdminUsersTable> {
  $$AdminUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AdminUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdminUsersTable> {
  $$AdminUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AdminUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdminUsersTable,
          AdminUser,
          $$AdminUsersTableFilterComposer,
          $$AdminUsersTableOrderingComposer,
          $$AdminUsersTableAnnotationComposer,
          $$AdminUsersTableCreateCompanionBuilder,
          $$AdminUsersTableUpdateCompanionBuilder,
          (
            AdminUser,
            BaseReferences<_$AppDatabase, $AdminUsersTable, AdminUser>,
          ),
          AdminUser,
          PrefetchHooks Function()
        > {
  $$AdminUsersTableTableManager(_$AppDatabase db, $AdminUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdminUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdminUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdminUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<String> salt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AdminUsersCompanion(
                id: id,
                name: name,
                email: email,
                passwordHash: passwordHash,
                salt: salt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String email,
                required String passwordHash,
                required String salt,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AdminUsersCompanion.insert(
                id: id,
                name: name,
                email: email,
                passwordHash: passwordHash,
                salt: salt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AdminUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdminUsersTable,
      AdminUser,
      $$AdminUsersTableFilterComposer,
      $$AdminUsersTableOrderingComposer,
      $$AdminUsersTableAnnotationComposer,
      $$AdminUsersTableCreateCompanionBuilder,
      $$AdminUsersTableUpdateCompanionBuilder,
      (AdminUser, BaseReferences<_$AppDatabase, $AdminUsersTable, AdminUser>),
      AdminUser,
      PrefetchHooks Function()
    >;
typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      required String codigoExemplar,
      Value<String?> nomeLocalExemplar,
      Value<String?> numeroPatrimonio,
      required String titulo,
      Value<String?> tituloRevista,
      Value<String?> classificacao,
      Value<String?> codigoTipoObra,
      Value<String?> nomeTipoObra,
      Value<String?> exemplarVolume,
      Value<String?> autor,
      Value<String?> areaConhecimento,
      Value<String?> anoPublicacao,
      Value<String?> isbn,
      Value<String?> referencia,
      Value<String?> coverUrl,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      Value<String> codigoExemplar,
      Value<String?> nomeLocalExemplar,
      Value<String?> numeroPatrimonio,
      Value<String> titulo,
      Value<String?> tituloRevista,
      Value<String?> classificacao,
      Value<String?> codigoTipoObra,
      Value<String?> nomeTipoObra,
      Value<String?> exemplarVolume,
      Value<String?> autor,
      Value<String?> areaConhecimento,
      Value<String?> anoPublicacao,
      Value<String?> isbn,
      Value<String?> referencia,
      Value<String?> coverUrl,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, Book> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LoansTable, List<Loan>> _loansRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.loans,
    aliasName: 'books__id__loans__book_id',
  );

  $$LoansTableProcessedTableManager get loansRefs {
    final manager = $$LoansTableTableManager(
      $_db,
      $_db.loans,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_loansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigoExemplar => $composableBuilder(
    column: $table.codigoExemplar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nomeLocalExemplar => $composableBuilder(
    column: $table.nomeLocalExemplar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get numeroPatrimonio => $composableBuilder(
    column: $table.numeroPatrimonio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tituloRevista => $composableBuilder(
    column: $table.tituloRevista,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classificacao => $composableBuilder(
    column: $table.classificacao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigoTipoObra => $composableBuilder(
    column: $table.codigoTipoObra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nomeTipoObra => $composableBuilder(
    column: $table.nomeTipoObra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exemplarVolume => $composableBuilder(
    column: $table.exemplarVolume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get autor => $composableBuilder(
    column: $table.autor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaConhecimento => $composableBuilder(
    column: $table.areaConhecimento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anoPublicacao => $composableBuilder(
    column: $table.anoPublicacao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> loansRefs(
    Expression<bool> Function($$LoansTableFilterComposer f) f,
  ) {
    final $$LoansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loans,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableFilterComposer(
            $db: $db,
            $table: $db.loans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigoExemplar => $composableBuilder(
    column: $table.codigoExemplar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nomeLocalExemplar => $composableBuilder(
    column: $table.nomeLocalExemplar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get numeroPatrimonio => $composableBuilder(
    column: $table.numeroPatrimonio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tituloRevista => $composableBuilder(
    column: $table.tituloRevista,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classificacao => $composableBuilder(
    column: $table.classificacao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigoTipoObra => $composableBuilder(
    column: $table.codigoTipoObra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nomeTipoObra => $composableBuilder(
    column: $table.nomeTipoObra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exemplarVolume => $composableBuilder(
    column: $table.exemplarVolume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get autor => $composableBuilder(
    column: $table.autor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaConhecimento => $composableBuilder(
    column: $table.areaConhecimento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anoPublicacao => $composableBuilder(
    column: $table.anoPublicacao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codigoExemplar => $composableBuilder(
    column: $table.codigoExemplar,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nomeLocalExemplar => $composableBuilder(
    column: $table.nomeLocalExemplar,
    builder: (column) => column,
  );

  GeneratedColumn<String> get numeroPatrimonio => $composableBuilder(
    column: $table.numeroPatrimonio,
    builder: (column) => column,
  );

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get tituloRevista => $composableBuilder(
    column: $table.tituloRevista,
    builder: (column) => column,
  );

  GeneratedColumn<String> get classificacao => $composableBuilder(
    column: $table.classificacao,
    builder: (column) => column,
  );

  GeneratedColumn<String> get codigoTipoObra => $composableBuilder(
    column: $table.codigoTipoObra,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nomeTipoObra => $composableBuilder(
    column: $table.nomeTipoObra,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exemplarVolume => $composableBuilder(
    column: $table.exemplarVolume,
    builder: (column) => column,
  );

  GeneratedColumn<String> get autor =>
      $composableBuilder(column: $table.autor, builder: (column) => column);

  GeneratedColumn<String> get areaConhecimento => $composableBuilder(
    column: $table.areaConhecimento,
    builder: (column) => column,
  );

  GeneratedColumn<String> get anoPublicacao => $composableBuilder(
    column: $table.anoPublicacao,
    builder: (column) => column,
  );

  GeneratedColumn<String> get isbn =>
      $composableBuilder(column: $table.isbn, builder: (column) => column);

  GeneratedColumn<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> loansRefs<T extends Object>(
    Expression<T> Function($$LoansTableAnnotationComposer a) f,
  ) {
    final $$LoansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loans,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableAnnotationComposer(
            $db: $db,
            $table: $db.loans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, $$BooksTableReferences),
          Book,
          PrefetchHooks Function({bool loansRefs})
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> codigoExemplar = const Value.absent(),
                Value<String?> nomeLocalExemplar = const Value.absent(),
                Value<String?> numeroPatrimonio = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<String?> tituloRevista = const Value.absent(),
                Value<String?> classificacao = const Value.absent(),
                Value<String?> codigoTipoObra = const Value.absent(),
                Value<String?> nomeTipoObra = const Value.absent(),
                Value<String?> exemplarVolume = const Value.absent(),
                Value<String?> autor = const Value.absent(),
                Value<String?> areaConhecimento = const Value.absent(),
                Value<String?> anoPublicacao = const Value.absent(),
                Value<String?> isbn = const Value.absent(),
                Value<String?> referencia = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                codigoExemplar: codigoExemplar,
                nomeLocalExemplar: nomeLocalExemplar,
                numeroPatrimonio: numeroPatrimonio,
                titulo: titulo,
                tituloRevista: tituloRevista,
                classificacao: classificacao,
                codigoTipoObra: codigoTipoObra,
                nomeTipoObra: nomeTipoObra,
                exemplarVolume: exemplarVolume,
                autor: autor,
                areaConhecimento: areaConhecimento,
                anoPublicacao: anoPublicacao,
                isbn: isbn,
                referencia: referencia,
                coverUrl: coverUrl,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String codigoExemplar,
                Value<String?> nomeLocalExemplar = const Value.absent(),
                Value<String?> numeroPatrimonio = const Value.absent(),
                required String titulo,
                Value<String?> tituloRevista = const Value.absent(),
                Value<String?> classificacao = const Value.absent(),
                Value<String?> codigoTipoObra = const Value.absent(),
                Value<String?> nomeTipoObra = const Value.absent(),
                Value<String?> exemplarVolume = const Value.absent(),
                Value<String?> autor = const Value.absent(),
                Value<String?> areaConhecimento = const Value.absent(),
                Value<String?> anoPublicacao = const Value.absent(),
                Value<String?> isbn = const Value.absent(),
                Value<String?> referencia = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                codigoExemplar: codigoExemplar,
                nomeLocalExemplar: nomeLocalExemplar,
                numeroPatrimonio: numeroPatrimonio,
                titulo: titulo,
                tituloRevista: tituloRevista,
                classificacao: classificacao,
                codigoTipoObra: codigoTipoObra,
                nomeTipoObra: nomeTipoObra,
                exemplarVolume: exemplarVolume,
                autor: autor,
                areaConhecimento: areaConhecimento,
                anoPublicacao: anoPublicacao,
                isbn: isbn,
                referencia: referencia,
                coverUrl: coverUrl,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BooksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({loansRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (loansRefs) db.loans],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (loansRefs)
                    await $_getPrefetchedData<Book, $BooksTable, Loan>(
                      currentTable: table,
                      referencedTable: $$BooksTableReferences._loansRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$BooksTableReferences(db, table, p0).loansRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.bookId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, $$BooksTableReferences),
      Book,
      PrefetchHooks Function({bool loansRefs})
    >;
typedef $$StudentsTableCreateCompanionBuilder =
    StudentsCompanion Function({
      Value<int> id,
      required String rmRa,
      required String nome,
      Value<String> segmento,
      Value<String?> fotoPath,
      Value<bool> ativo,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$StudentsTableUpdateCompanionBuilder =
    StudentsCompanion Function({
      Value<int> id,
      Value<String> rmRa,
      Value<String> nome,
      Value<String> segmento,
      Value<String?> fotoPath,
      Value<bool> ativo,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$StudentsTableReferences
    extends BaseReferences<_$AppDatabase, $StudentsTable, Student> {
  $$StudentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LoansTable, List<Loan>> _loansRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.loans,
    aliasName: 'students__id__loans__student_id',
  );

  $$LoansTableProcessedTableManager get loansRefs {
    final manager = $$LoansTableTableManager(
      $_db,
      $_db.loans,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_loansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StudentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rmRa => $composableBuilder(
    column: $table.rmRa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get segmento => $composableBuilder(
    column: $table.segmento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ativo => $composableBuilder(
    column: $table.ativo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> loansRefs(
    Expression<bool> Function($$LoansTableFilterComposer f) f,
  ) {
    final $$LoansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loans,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableFilterComposer(
            $db: $db,
            $table: $db.loans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rmRa => $composableBuilder(
    column: $table.rmRa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get segmento => $composableBuilder(
    column: $table.segmento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ativo => $composableBuilder(
    column: $table.ativo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rmRa =>
      $composableBuilder(column: $table.rmRa, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get segmento =>
      $composableBuilder(column: $table.segmento, builder: (column) => column);

  GeneratedColumn<String> get fotoPath =>
      $composableBuilder(column: $table.fotoPath, builder: (column) => column);

  GeneratedColumn<bool> get ativo =>
      $composableBuilder(column: $table.ativo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> loansRefs<T extends Object>(
    Expression<T> Function($$LoansTableAnnotationComposer a) f,
  ) {
    final $$LoansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loans,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableAnnotationComposer(
            $db: $db,
            $table: $db.loans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentsTable,
          Student,
          $$StudentsTableFilterComposer,
          $$StudentsTableOrderingComposer,
          $$StudentsTableAnnotationComposer,
          $$StudentsTableCreateCompanionBuilder,
          $$StudentsTableUpdateCompanionBuilder,
          (Student, $$StudentsTableReferences),
          Student,
          PrefetchHooks Function({bool loansRefs})
        > {
  $$StudentsTableTableManager(_$AppDatabase db, $StudentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> rmRa = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> segmento = const Value.absent(),
                Value<String?> fotoPath = const Value.absent(),
                Value<bool> ativo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => StudentsCompanion(
                id: id,
                rmRa: rmRa,
                nome: nome,
                segmento: segmento,
                fotoPath: fotoPath,
                ativo: ativo,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String rmRa,
                required String nome,
                Value<String> segmento = const Value.absent(),
                Value<String?> fotoPath = const Value.absent(),
                Value<bool> ativo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => StudentsCompanion.insert(
                id: id,
                rmRa: rmRa,
                nome: nome,
                segmento: segmento,
                fotoPath: fotoPath,
                ativo: ativo,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StudentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({loansRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (loansRefs) db.loans],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (loansRefs)
                    await $_getPrefetchedData<Student, $StudentsTable, Loan>(
                      currentTable: table,
                      referencedTable: $$StudentsTableReferences
                          ._loansRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$StudentsTableReferences(db, table, p0).loansRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.studentId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentsTable,
      Student,
      $$StudentsTableFilterComposer,
      $$StudentsTableOrderingComposer,
      $$StudentsTableAnnotationComposer,
      $$StudentsTableCreateCompanionBuilder,
      $$StudentsTableUpdateCompanionBuilder,
      (Student, $$StudentsTableReferences),
      Student,
      PrefetchHooks Function({bool loansRefs})
    >;
typedef $$LoansTableCreateCompanionBuilder =
    LoansCompanion Function({
      Value<int> id,
      required int bookId,
      required int studentId,
      Value<DateTime> dataEmprestimo,
      Value<DateTime?> dataDevolucaoPrevista,
      Value<DateTime?> dataDevolucaoEfetiva,
      Value<String> status,
      Value<String?> observacoes,
    });
typedef $$LoansTableUpdateCompanionBuilder =
    LoansCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<int> studentId,
      Value<DateTime> dataEmprestimo,
      Value<DateTime?> dataDevolucaoPrevista,
      Value<DateTime?> dataDevolucaoEfetiva,
      Value<String> status,
      Value<String?> observacoes,
    });

final class $$LoansTableReferences
    extends BaseReferences<_$AppDatabase, $LoansTable, Loan> {
  $$LoansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('loans__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('loans__student_id__students__id');

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LoansTableFilterComposer extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataEmprestimo => $composableBuilder(
    column: $table.dataEmprestimo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataDevolucaoPrevista => $composableBuilder(
    column: $table.dataDevolucaoPrevista,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataDevolucaoEfetiva => $composableBuilder(
    column: $table.dataDevolucaoEfetiva,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observacoes => $composableBuilder(
    column: $table.observacoes,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoansTableOrderingComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataEmprestimo => $composableBuilder(
    column: $table.dataEmprestimo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataDevolucaoPrevista => $composableBuilder(
    column: $table.dataDevolucaoPrevista,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataDevolucaoEfetiva => $composableBuilder(
    column: $table.dataDevolucaoEfetiva,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observacoes => $composableBuilder(
    column: $table.observacoes,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoansTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get dataEmprestimo => $composableBuilder(
    column: $table.dataEmprestimo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataDevolucaoPrevista => $composableBuilder(
    column: $table.dataDevolucaoPrevista,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataDevolucaoEfetiva => $composableBuilder(
    column: $table.dataDevolucaoEfetiva,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get observacoes => $composableBuilder(
    column: $table.observacoes,
    builder: (column) => column,
  );

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoansTable,
          Loan,
          $$LoansTableFilterComposer,
          $$LoansTableOrderingComposer,
          $$LoansTableAnnotationComposer,
          $$LoansTableCreateCompanionBuilder,
          $$LoansTableUpdateCompanionBuilder,
          (Loan, $$LoansTableReferences),
          Loan,
          PrefetchHooks Function({bool bookId, bool studentId})
        > {
  $$LoansTableTableManager(_$AppDatabase db, $LoansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<DateTime> dataEmprestimo = const Value.absent(),
                Value<DateTime?> dataDevolucaoPrevista = const Value.absent(),
                Value<DateTime?> dataDevolucaoEfetiva = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> observacoes = const Value.absent(),
              }) => LoansCompanion(
                id: id,
                bookId: bookId,
                studentId: studentId,
                dataEmprestimo: dataEmprestimo,
                dataDevolucaoPrevista: dataDevolucaoPrevista,
                dataDevolucaoEfetiva: dataDevolucaoEfetiva,
                status: status,
                observacoes: observacoes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required int studentId,
                Value<DateTime> dataEmprestimo = const Value.absent(),
                Value<DateTime?> dataDevolucaoPrevista = const Value.absent(),
                Value<DateTime?> dataDevolucaoEfetiva = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> observacoes = const Value.absent(),
              }) => LoansCompanion.insert(
                id: id,
                bookId: bookId,
                studentId: studentId,
                dataEmprestimo: dataEmprestimo,
                dataDevolucaoPrevista: dataDevolucaoPrevista,
                dataDevolucaoEfetiva: dataDevolucaoEfetiva,
                status: status,
                observacoes: observacoes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$LoansTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false, studentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$LoansTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$LoansTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable: $$LoansTableReferences
                                    ._studentIdTable(db),
                                referencedColumn: $$LoansTableReferences
                                    ._studentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LoansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoansTable,
      Loan,
      $$LoansTableFilterComposer,
      $$LoansTableOrderingComposer,
      $$LoansTableAnnotationComposer,
      $$LoansTableCreateCompanionBuilder,
      $$LoansTableUpdateCompanionBuilder,
      (Loan, $$LoansTableReferences),
      Loan,
      PrefetchHooks Function({bool bookId, bool studentId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AdminUsersTableTableManager get adminUsers =>
      $$AdminUsersTableTableManager(_db, _db.adminUsers);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db, _db.students);
  $$LoansTableTableManager get loans =>
      $$LoansTableTableManager(_db, _db.loans);
}
