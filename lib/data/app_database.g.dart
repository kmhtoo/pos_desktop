// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BusinessDaysTable extends BusinessDays
    with TableInfo<$BusinessDaysTable, BusinessDayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BusinessDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openedByNameMeta = const VerificationMeta(
    'openedByName',
  );
  @override
  late final GeneratedColumn<String> openedByName = GeneratedColumn<String>(
    'opened_by_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedByIdMeta = const VerificationMeta(
    'openedById',
  );
  @override
  late final GeneratedColumn<String> openedById = GeneratedColumn<String>(
    'opened_by_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedByNameMeta = const VerificationMeta(
    'closedByName',
  );
  @override
  late final GeneratedColumn<String> closedByName = GeneratedColumn<String>(
    'closed_by_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedByIdMeta = const VerificationMeta(
    'closedById',
  );
  @override
  late final GeneratedColumn<String> closedById = GeneratedColumn<String>(
    'closed_by_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    openedAt,
    closedAt,
    openedByName,
    openedById,
    closedByName,
    closedById,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'business_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<BusinessDayRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_openedAtMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('opened_by_name')) {
      context.handle(
        _openedByNameMeta,
        openedByName.isAcceptableOrUnknown(
          data['opened_by_name']!,
          _openedByNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openedByNameMeta);
    }
    if (data.containsKey('opened_by_id')) {
      context.handle(
        _openedByIdMeta,
        openedById.isAcceptableOrUnknown(
          data['opened_by_id']!,
          _openedByIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openedByIdMeta);
    }
    if (data.containsKey('closed_by_name')) {
      context.handle(
        _closedByNameMeta,
        closedByName.isAcceptableOrUnknown(
          data['closed_by_name']!,
          _closedByNameMeta,
        ),
      );
    }
    if (data.containsKey('closed_by_id')) {
      context.handle(
        _closedByIdMeta,
        closedById.isAcceptableOrUnknown(
          data['closed_by_id']!,
          _closedByIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BusinessDayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BusinessDayRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
      openedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opened_by_name'],
      )!,
      openedById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opened_by_id'],
      )!,
      closedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_by_name'],
      ),
      closedById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_by_id'],
      ),
    );
  }

  @override
  $BusinessDaysTable createAlias(String alias) {
    return $BusinessDaysTable(attachedDatabase, alias);
  }
}

class BusinessDayRow extends DataClass implements Insertable<BusinessDayRow> {
  final String id;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String openedByName;
  final String openedById;
  final String? closedByName;
  final String? closedById;
  const BusinessDayRow({
    required this.id,
    required this.openedAt,
    this.closedAt,
    required this.openedByName,
    required this.openedById,
    this.closedByName,
    this.closedById,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['opened_at'] = Variable<DateTime>(openedAt);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    map['opened_by_name'] = Variable<String>(openedByName);
    map['opened_by_id'] = Variable<String>(openedById);
    if (!nullToAbsent || closedByName != null) {
      map['closed_by_name'] = Variable<String>(closedByName);
    }
    if (!nullToAbsent || closedById != null) {
      map['closed_by_id'] = Variable<String>(closedById);
    }
    return map;
  }

  BusinessDaysCompanion toCompanion(bool nullToAbsent) {
    return BusinessDaysCompanion(
      id: Value(id),
      openedAt: Value(openedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      openedByName: Value(openedByName),
      openedById: Value(openedById),
      closedByName: closedByName == null && nullToAbsent
          ? const Value.absent()
          : Value(closedByName),
      closedById: closedById == null && nullToAbsent
          ? const Value.absent()
          : Value(closedById),
    );
  }

  factory BusinessDayRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BusinessDayRow(
      id: serializer.fromJson<String>(json['id']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
      openedByName: serializer.fromJson<String>(json['openedByName']),
      openedById: serializer.fromJson<String>(json['openedById']),
      closedByName: serializer.fromJson<String?>(json['closedByName']),
      closedById: serializer.fromJson<String?>(json['closedById']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'openedAt': serializer.toJson<DateTime>(openedAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
      'openedByName': serializer.toJson<String>(openedByName),
      'openedById': serializer.toJson<String>(openedById),
      'closedByName': serializer.toJson<String?>(closedByName),
      'closedById': serializer.toJson<String?>(closedById),
    };
  }

  BusinessDayRow copyWith({
    String? id,
    DateTime? openedAt,
    Value<DateTime?> closedAt = const Value.absent(),
    String? openedByName,
    String? openedById,
    Value<String?> closedByName = const Value.absent(),
    Value<String?> closedById = const Value.absent(),
  }) => BusinessDayRow(
    id: id ?? this.id,
    openedAt: openedAt ?? this.openedAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    openedByName: openedByName ?? this.openedByName,
    openedById: openedById ?? this.openedById,
    closedByName: closedByName.present ? closedByName.value : this.closedByName,
    closedById: closedById.present ? closedById.value : this.closedById,
  );
  BusinessDayRow copyWithCompanion(BusinessDaysCompanion data) {
    return BusinessDayRow(
      id: data.id.present ? data.id.value : this.id,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      openedByName: data.openedByName.present
          ? data.openedByName.value
          : this.openedByName,
      openedById: data.openedById.present
          ? data.openedById.value
          : this.openedById,
      closedByName: data.closedByName.present
          ? data.closedByName.value
          : this.closedByName,
      closedById: data.closedById.present
          ? data.closedById.value
          : this.closedById,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BusinessDayRow(')
          ..write('id: $id, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('openedByName: $openedByName, ')
          ..write('openedById: $openedById, ')
          ..write('closedByName: $closedByName, ')
          ..write('closedById: $closedById')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    openedAt,
    closedAt,
    openedByName,
    openedById,
    closedByName,
    closedById,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BusinessDayRow &&
          other.id == this.id &&
          other.openedAt == this.openedAt &&
          other.closedAt == this.closedAt &&
          other.openedByName == this.openedByName &&
          other.openedById == this.openedById &&
          other.closedByName == this.closedByName &&
          other.closedById == this.closedById);
}

class BusinessDaysCompanion extends UpdateCompanion<BusinessDayRow> {
  final Value<String> id;
  final Value<DateTime> openedAt;
  final Value<DateTime?> closedAt;
  final Value<String> openedByName;
  final Value<String> openedById;
  final Value<String?> closedByName;
  final Value<String?> closedById;
  final Value<int> rowid;
  const BusinessDaysCompanion({
    this.id = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.openedByName = const Value.absent(),
    this.openedById = const Value.absent(),
    this.closedByName = const Value.absent(),
    this.closedById = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BusinessDaysCompanion.insert({
    required String id,
    required DateTime openedAt,
    this.closedAt = const Value.absent(),
    required String openedByName,
    required String openedById,
    this.closedByName = const Value.absent(),
    this.closedById = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       openedAt = Value(openedAt),
       openedByName = Value(openedByName),
       openedById = Value(openedById);
  static Insertable<BusinessDayRow> custom({
    Expression<String>? id,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? closedAt,
    Expression<String>? openedByName,
    Expression<String>? openedById,
    Expression<String>? closedByName,
    Expression<String>? closedById,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (openedAt != null) 'opened_at': openedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (openedByName != null) 'opened_by_name': openedByName,
      if (openedById != null) 'opened_by_id': openedById,
      if (closedByName != null) 'closed_by_name': closedByName,
      if (closedById != null) 'closed_by_id': closedById,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BusinessDaysCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? openedAt,
    Value<DateTime?>? closedAt,
    Value<String>? openedByName,
    Value<String>? openedById,
    Value<String?>? closedByName,
    Value<String?>? closedById,
    Value<int>? rowid,
  }) {
    return BusinessDaysCompanion(
      id: id ?? this.id,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      openedByName: openedByName ?? this.openedByName,
      openedById: openedById ?? this.openedById,
      closedByName: closedByName ?? this.closedByName,
      closedById: closedById ?? this.closedById,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (openedByName.present) {
      map['opened_by_name'] = Variable<String>(openedByName.value);
    }
    if (openedById.present) {
      map['opened_by_id'] = Variable<String>(openedById.value);
    }
    if (closedByName.present) {
      map['closed_by_name'] = Variable<String>(closedByName.value);
    }
    if (closedById.present) {
      map['closed_by_id'] = Variable<String>(closedById.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BusinessDaysCompanion(')
          ..write('id: $id, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('openedByName: $openedByName, ')
          ..write('openedById: $openedById, ')
          ..write('closedByName: $closedByName, ')
          ..write('closedById: $closedById, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShiftsTable extends Shifts with TableInfo<$ShiftsTable, ShiftRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessDayIdMeta = const VerificationMeta(
    'businessDayId',
  );
  @override
  late final GeneratedColumn<String> businessDayId = GeneratedColumn<String>(
    'business_day_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openedByNameMeta = const VerificationMeta(
    'openedByName',
  );
  @override
  late final GeneratedColumn<String> openedByName = GeneratedColumn<String>(
    'opened_by_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedByIdMeta = const VerificationMeta(
    'openedById',
  );
  @override
  late final GeneratedColumn<String> openedById = GeneratedColumn<String>(
    'opened_by_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedByNameMeta = const VerificationMeta(
    'closedByName',
  );
  @override
  late final GeneratedColumn<String> closedByName = GeneratedColumn<String>(
    'closed_by_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedByIdMeta = const VerificationMeta(
    'closedById',
  );
  @override
  late final GeneratedColumn<String> closedById = GeneratedColumn<String>(
    'closed_by_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessDayId,
    type,
    openedAt,
    closedAt,
    openedByName,
    openedById,
    closedByName,
    closedById,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shifts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShiftRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_day_id')) {
      context.handle(
        _businessDayIdMeta,
        businessDayId.isAcceptableOrUnknown(
          data['business_day_id']!,
          _businessDayIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDayIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_openedAtMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('opened_by_name')) {
      context.handle(
        _openedByNameMeta,
        openedByName.isAcceptableOrUnknown(
          data['opened_by_name']!,
          _openedByNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openedByNameMeta);
    }
    if (data.containsKey('opened_by_id')) {
      context.handle(
        _openedByIdMeta,
        openedById.isAcceptableOrUnknown(
          data['opened_by_id']!,
          _openedByIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openedByIdMeta);
    }
    if (data.containsKey('closed_by_name')) {
      context.handle(
        _closedByNameMeta,
        closedByName.isAcceptableOrUnknown(
          data['closed_by_name']!,
          _closedByNameMeta,
        ),
      );
    }
    if (data.containsKey('closed_by_id')) {
      context.handle(
        _closedByIdMeta,
        closedById.isAcceptableOrUnknown(
          data['closed_by_id']!,
          _closedByIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShiftRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShiftRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_day_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
      openedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opened_by_name'],
      )!,
      openedById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opened_by_id'],
      )!,
      closedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_by_name'],
      ),
      closedById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_by_id'],
      ),
    );
  }

  @override
  $ShiftsTable createAlias(String alias) {
    return $ShiftsTable(attachedDatabase, alias);
  }
}

class ShiftRow extends DataClass implements Insertable<ShiftRow> {
  final String id;
  final String businessDayId;
  final String type;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String openedByName;
  final String openedById;
  final String? closedByName;
  final String? closedById;
  const ShiftRow({
    required this.id,
    required this.businessDayId,
    required this.type,
    required this.openedAt,
    this.closedAt,
    required this.openedByName,
    required this.openedById,
    this.closedByName,
    this.closedById,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_day_id'] = Variable<String>(businessDayId);
    map['type'] = Variable<String>(type);
    map['opened_at'] = Variable<DateTime>(openedAt);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    map['opened_by_name'] = Variable<String>(openedByName);
    map['opened_by_id'] = Variable<String>(openedById);
    if (!nullToAbsent || closedByName != null) {
      map['closed_by_name'] = Variable<String>(closedByName);
    }
    if (!nullToAbsent || closedById != null) {
      map['closed_by_id'] = Variable<String>(closedById);
    }
    return map;
  }

  ShiftsCompanion toCompanion(bool nullToAbsent) {
    return ShiftsCompanion(
      id: Value(id),
      businessDayId: Value(businessDayId),
      type: Value(type),
      openedAt: Value(openedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      openedByName: Value(openedByName),
      openedById: Value(openedById),
      closedByName: closedByName == null && nullToAbsent
          ? const Value.absent()
          : Value(closedByName),
      closedById: closedById == null && nullToAbsent
          ? const Value.absent()
          : Value(closedById),
    );
  }

  factory ShiftRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShiftRow(
      id: serializer.fromJson<String>(json['id']),
      businessDayId: serializer.fromJson<String>(json['businessDayId']),
      type: serializer.fromJson<String>(json['type']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
      openedByName: serializer.fromJson<String>(json['openedByName']),
      openedById: serializer.fromJson<String>(json['openedById']),
      closedByName: serializer.fromJson<String?>(json['closedByName']),
      closedById: serializer.fromJson<String?>(json['closedById']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessDayId': serializer.toJson<String>(businessDayId),
      'type': serializer.toJson<String>(type),
      'openedAt': serializer.toJson<DateTime>(openedAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
      'openedByName': serializer.toJson<String>(openedByName),
      'openedById': serializer.toJson<String>(openedById),
      'closedByName': serializer.toJson<String?>(closedByName),
      'closedById': serializer.toJson<String?>(closedById),
    };
  }

  ShiftRow copyWith({
    String? id,
    String? businessDayId,
    String? type,
    DateTime? openedAt,
    Value<DateTime?> closedAt = const Value.absent(),
    String? openedByName,
    String? openedById,
    Value<String?> closedByName = const Value.absent(),
    Value<String?> closedById = const Value.absent(),
  }) => ShiftRow(
    id: id ?? this.id,
    businessDayId: businessDayId ?? this.businessDayId,
    type: type ?? this.type,
    openedAt: openedAt ?? this.openedAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    openedByName: openedByName ?? this.openedByName,
    openedById: openedById ?? this.openedById,
    closedByName: closedByName.present ? closedByName.value : this.closedByName,
    closedById: closedById.present ? closedById.value : this.closedById,
  );
  ShiftRow copyWithCompanion(ShiftsCompanion data) {
    return ShiftRow(
      id: data.id.present ? data.id.value : this.id,
      businessDayId: data.businessDayId.present
          ? data.businessDayId.value
          : this.businessDayId,
      type: data.type.present ? data.type.value : this.type,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      openedByName: data.openedByName.present
          ? data.openedByName.value
          : this.openedByName,
      openedById: data.openedById.present
          ? data.openedById.value
          : this.openedById,
      closedByName: data.closedByName.present
          ? data.closedByName.value
          : this.closedByName,
      closedById: data.closedById.present
          ? data.closedById.value
          : this.closedById,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShiftRow(')
          ..write('id: $id, ')
          ..write('businessDayId: $businessDayId, ')
          ..write('type: $type, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('openedByName: $openedByName, ')
          ..write('openedById: $openedById, ')
          ..write('closedByName: $closedByName, ')
          ..write('closedById: $closedById')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessDayId,
    type,
    openedAt,
    closedAt,
    openedByName,
    openedById,
    closedByName,
    closedById,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShiftRow &&
          other.id == this.id &&
          other.businessDayId == this.businessDayId &&
          other.type == this.type &&
          other.openedAt == this.openedAt &&
          other.closedAt == this.closedAt &&
          other.openedByName == this.openedByName &&
          other.openedById == this.openedById &&
          other.closedByName == this.closedByName &&
          other.closedById == this.closedById);
}

class ShiftsCompanion extends UpdateCompanion<ShiftRow> {
  final Value<String> id;
  final Value<String> businessDayId;
  final Value<String> type;
  final Value<DateTime> openedAt;
  final Value<DateTime?> closedAt;
  final Value<String> openedByName;
  final Value<String> openedById;
  final Value<String?> closedByName;
  final Value<String?> closedById;
  final Value<int> rowid;
  const ShiftsCompanion({
    this.id = const Value.absent(),
    this.businessDayId = const Value.absent(),
    this.type = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.openedByName = const Value.absent(),
    this.openedById = const Value.absent(),
    this.closedByName = const Value.absent(),
    this.closedById = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShiftsCompanion.insert({
    required String id,
    required String businessDayId,
    required String type,
    required DateTime openedAt,
    this.closedAt = const Value.absent(),
    required String openedByName,
    required String openedById,
    this.closedByName = const Value.absent(),
    this.closedById = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessDayId = Value(businessDayId),
       type = Value(type),
       openedAt = Value(openedAt),
       openedByName = Value(openedByName),
       openedById = Value(openedById);
  static Insertable<ShiftRow> custom({
    Expression<String>? id,
    Expression<String>? businessDayId,
    Expression<String>? type,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? closedAt,
    Expression<String>? openedByName,
    Expression<String>? openedById,
    Expression<String>? closedByName,
    Expression<String>? closedById,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessDayId != null) 'business_day_id': businessDayId,
      if (type != null) 'type': type,
      if (openedAt != null) 'opened_at': openedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (openedByName != null) 'opened_by_name': openedByName,
      if (openedById != null) 'opened_by_id': openedById,
      if (closedByName != null) 'closed_by_name': closedByName,
      if (closedById != null) 'closed_by_id': closedById,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShiftsCompanion copyWith({
    Value<String>? id,
    Value<String>? businessDayId,
    Value<String>? type,
    Value<DateTime>? openedAt,
    Value<DateTime?>? closedAt,
    Value<String>? openedByName,
    Value<String>? openedById,
    Value<String?>? closedByName,
    Value<String?>? closedById,
    Value<int>? rowid,
  }) {
    return ShiftsCompanion(
      id: id ?? this.id,
      businessDayId: businessDayId ?? this.businessDayId,
      type: type ?? this.type,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      openedByName: openedByName ?? this.openedByName,
      openedById: openedById ?? this.openedById,
      closedByName: closedByName ?? this.closedByName,
      closedById: closedById ?? this.closedById,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessDayId.present) {
      map['business_day_id'] = Variable<String>(businessDayId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (openedByName.present) {
      map['opened_by_name'] = Variable<String>(openedByName.value);
    }
    if (openedById.present) {
      map['opened_by_id'] = Variable<String>(openedById.value);
    }
    if (closedByName.present) {
      map['closed_by_name'] = Variable<String>(closedByName.value);
    }
    if (closedById.present) {
      map['closed_by_id'] = Variable<String>(closedById.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsCompanion(')
          ..write('id: $id, ')
          ..write('businessDayId: $businessDayId, ')
          ..write('type: $type, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('openedByName: $openedByName, ')
          ..write('openedById: $openedById, ')
          ..write('closedByName: $closedByName, ')
          ..write('closedById: $closedById, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
    'shift_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashierIdMeta = const VerificationMeta(
    'cashierId',
  );
  @override
  late final GeneratedColumn<String> cashierId = GeneratedColumn<String>(
    'cashier_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cashierNameMeta = const VerificationMeta(
    'cashierName',
  );
  @override
  late final GeneratedColumn<String> cashierName = GeneratedColumn<String>(
    'cashier_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxMeta = const VerificationMeta('tax');
  @override
  late final GeneratedColumn<double> tax = GeneratedColumn<double>(
    'tax',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenderTypeMeta = const VerificationMeta(
    'tenderType',
  );
  @override
  late final GeneratedColumn<String> tenderType = GeneratedColumn<String>(
    'tender_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashAmountMeta = const VerificationMeta(
    'cashAmount',
  );
  @override
  late final GeneratedColumn<double> cashAmount = GeneratedColumn<double>(
    'cash_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardAmountMeta = const VerificationMeta(
    'cardAmount',
  );
  @override
  late final GeneratedColumn<double> cardAmount = GeneratedColumn<double>(
    'card_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changeAmountMeta = const VerificationMeta(
    'changeAmount',
  );
  @override
  late final GeneratedColumn<double> changeAmount = GeneratedColumn<double>(
    'change_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isVoidedMeta = const VerificationMeta(
    'isVoided',
  );
  @override
  late final GeneratedColumn<bool> isVoided = GeneratedColumn<bool>(
    'is_voided',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_voided" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _voidedByNameMeta = const VerificationMeta(
    'voidedByName',
  );
  @override
  late final GeneratedColumn<String> voidedByName = GeneratedColumn<String>(
    'voided_by_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidedByIdMeta = const VerificationMeta(
    'voidedById',
  );
  @override
  late final GeneratedColumn<String> voidedById = GeneratedColumn<String>(
    'voided_by_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidedAtMeta = const VerificationMeta(
    'voidedAt',
  );
  @override
  late final GeneratedColumn<DateTime> voidedAt = GeneratedColumn<DateTime>(
    'voided_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shiftId,
    cashierId,
    cashierName,
    subtotal,
    tax,
    total,
    tenderType,
    cashAmount,
    cardAmount,
    changeAmount,
    timestamp,
    isVoided,
    voidedByName,
    voidedById,
    voidedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shiftIdMeta);
    }
    if (data.containsKey('cashier_id')) {
      context.handle(
        _cashierIdMeta,
        cashierId.isAcceptableOrUnknown(data['cashier_id']!, _cashierIdMeta),
      );
    }
    if (data.containsKey('cashier_name')) {
      context.handle(
        _cashierNameMeta,
        cashierName.isAcceptableOrUnknown(
          data['cashier_name']!,
          _cashierNameMeta,
        ),
      );
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('tax')) {
      context.handle(
        _taxMeta,
        tax.isAcceptableOrUnknown(data['tax']!, _taxMeta),
      );
    } else if (isInserting) {
      context.missing(_taxMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('tender_type')) {
      context.handle(
        _tenderTypeMeta,
        tenderType.isAcceptableOrUnknown(data['tender_type']!, _tenderTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_tenderTypeMeta);
    }
    if (data.containsKey('cash_amount')) {
      context.handle(
        _cashAmountMeta,
        cashAmount.isAcceptableOrUnknown(data['cash_amount']!, _cashAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_cashAmountMeta);
    }
    if (data.containsKey('card_amount')) {
      context.handle(
        _cardAmountMeta,
        cardAmount.isAcceptableOrUnknown(data['card_amount']!, _cardAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_cardAmountMeta);
    }
    if (data.containsKey('change_amount')) {
      context.handle(
        _changeAmountMeta,
        changeAmount.isAcceptableOrUnknown(
          data['change_amount']!,
          _changeAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_changeAmountMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('is_voided')) {
      context.handle(
        _isVoidedMeta,
        isVoided.isAcceptableOrUnknown(data['is_voided']!, _isVoidedMeta),
      );
    }
    if (data.containsKey('voided_by_name')) {
      context.handle(
        _voidedByNameMeta,
        voidedByName.isAcceptableOrUnknown(
          data['voided_by_name']!,
          _voidedByNameMeta,
        ),
      );
    }
    if (data.containsKey('voided_by_id')) {
      context.handle(
        _voidedByIdMeta,
        voidedById.isAcceptableOrUnknown(
          data['voided_by_id']!,
          _voidedByIdMeta,
        ),
      );
    }
    if (data.containsKey('voided_at')) {
      context.handle(
        _voidedAtMeta,
        voidedAt.isAcceptableOrUnknown(data['voided_at']!, _voidedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift_id'],
      )!,
      cashierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cashier_id'],
      ),
      cashierName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cashier_name'],
      ),
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      tax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      tenderType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tender_type'],
      )!,
      cashAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cash_amount'],
      )!,
      cardAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}card_amount'],
      )!,
      changeAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}change_amount'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      isVoided: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_voided'],
      )!,
      voidedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voided_by_name'],
      ),
      voidedById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voided_by_id'],
      ),
      voidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}voided_at'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final String id;
  final String shiftId;
  final String? cashierId;
  final String? cashierName;
  final double subtotal;
  final double tax;
  final double total;
  final String tenderType;
  final double cashAmount;
  final double cardAmount;
  final double changeAmount;
  final DateTime timestamp;
  final bool isVoided;
  final String? voidedByName;
  final String? voidedById;
  final DateTime? voidedAt;
  const TransactionRow({
    required this.id,
    required this.shiftId,
    this.cashierId,
    this.cashierName,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.tenderType,
    required this.cashAmount,
    required this.cardAmount,
    required this.changeAmount,
    required this.timestamp,
    required this.isVoided,
    this.voidedByName,
    this.voidedById,
    this.voidedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shift_id'] = Variable<String>(shiftId);
    if (!nullToAbsent || cashierId != null) {
      map['cashier_id'] = Variable<String>(cashierId);
    }
    if (!nullToAbsent || cashierName != null) {
      map['cashier_name'] = Variable<String>(cashierName);
    }
    map['subtotal'] = Variable<double>(subtotal);
    map['tax'] = Variable<double>(tax);
    map['total'] = Variable<double>(total);
    map['tender_type'] = Variable<String>(tenderType);
    map['cash_amount'] = Variable<double>(cashAmount);
    map['card_amount'] = Variable<double>(cardAmount);
    map['change_amount'] = Variable<double>(changeAmount);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['is_voided'] = Variable<bool>(isVoided);
    if (!nullToAbsent || voidedByName != null) {
      map['voided_by_name'] = Variable<String>(voidedByName);
    }
    if (!nullToAbsent || voidedById != null) {
      map['voided_by_id'] = Variable<String>(voidedById);
    }
    if (!nullToAbsent || voidedAt != null) {
      map['voided_at'] = Variable<DateTime>(voidedAt);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      shiftId: Value(shiftId),
      cashierId: cashierId == null && nullToAbsent
          ? const Value.absent()
          : Value(cashierId),
      cashierName: cashierName == null && nullToAbsent
          ? const Value.absent()
          : Value(cashierName),
      subtotal: Value(subtotal),
      tax: Value(tax),
      total: Value(total),
      tenderType: Value(tenderType),
      cashAmount: Value(cashAmount),
      cardAmount: Value(cardAmount),
      changeAmount: Value(changeAmount),
      timestamp: Value(timestamp),
      isVoided: Value(isVoided),
      voidedByName: voidedByName == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedByName),
      voidedById: voidedById == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedById),
      voidedAt: voidedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedAt),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      id: serializer.fromJson<String>(json['id']),
      shiftId: serializer.fromJson<String>(json['shiftId']),
      cashierId: serializer.fromJson<String?>(json['cashierId']),
      cashierName: serializer.fromJson<String?>(json['cashierName']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      tax: serializer.fromJson<double>(json['tax']),
      total: serializer.fromJson<double>(json['total']),
      tenderType: serializer.fromJson<String>(json['tenderType']),
      cashAmount: serializer.fromJson<double>(json['cashAmount']),
      cardAmount: serializer.fromJson<double>(json['cardAmount']),
      changeAmount: serializer.fromJson<double>(json['changeAmount']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      isVoided: serializer.fromJson<bool>(json['isVoided']),
      voidedByName: serializer.fromJson<String?>(json['voidedByName']),
      voidedById: serializer.fromJson<String?>(json['voidedById']),
      voidedAt: serializer.fromJson<DateTime?>(json['voidedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shiftId': serializer.toJson<String>(shiftId),
      'cashierId': serializer.toJson<String?>(cashierId),
      'cashierName': serializer.toJson<String?>(cashierName),
      'subtotal': serializer.toJson<double>(subtotal),
      'tax': serializer.toJson<double>(tax),
      'total': serializer.toJson<double>(total),
      'tenderType': serializer.toJson<String>(tenderType),
      'cashAmount': serializer.toJson<double>(cashAmount),
      'cardAmount': serializer.toJson<double>(cardAmount),
      'changeAmount': serializer.toJson<double>(changeAmount),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'isVoided': serializer.toJson<bool>(isVoided),
      'voidedByName': serializer.toJson<String?>(voidedByName),
      'voidedById': serializer.toJson<String?>(voidedById),
      'voidedAt': serializer.toJson<DateTime?>(voidedAt),
    };
  }

  TransactionRow copyWith({
    String? id,
    String? shiftId,
    Value<String?> cashierId = const Value.absent(),
    Value<String?> cashierName = const Value.absent(),
    double? subtotal,
    double? tax,
    double? total,
    String? tenderType,
    double? cashAmount,
    double? cardAmount,
    double? changeAmount,
    DateTime? timestamp,
    bool? isVoided,
    Value<String?> voidedByName = const Value.absent(),
    Value<String?> voidedById = const Value.absent(),
    Value<DateTime?> voidedAt = const Value.absent(),
  }) => TransactionRow(
    id: id ?? this.id,
    shiftId: shiftId ?? this.shiftId,
    cashierId: cashierId.present ? cashierId.value : this.cashierId,
    cashierName: cashierName.present ? cashierName.value : this.cashierName,
    subtotal: subtotal ?? this.subtotal,
    tax: tax ?? this.tax,
    total: total ?? this.total,
    tenderType: tenderType ?? this.tenderType,
    cashAmount: cashAmount ?? this.cashAmount,
    cardAmount: cardAmount ?? this.cardAmount,
    changeAmount: changeAmount ?? this.changeAmount,
    timestamp: timestamp ?? this.timestamp,
    isVoided: isVoided ?? this.isVoided,
    voidedByName: voidedByName.present ? voidedByName.value : this.voidedByName,
    voidedById: voidedById.present ? voidedById.value : this.voidedById,
    voidedAt: voidedAt.present ? voidedAt.value : this.voidedAt,
  );
  TransactionRow copyWithCompanion(TransactionsCompanion data) {
    return TransactionRow(
      id: data.id.present ? data.id.value : this.id,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      cashierId: data.cashierId.present ? data.cashierId.value : this.cashierId,
      cashierName: data.cashierName.present
          ? data.cashierName.value
          : this.cashierName,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      tax: data.tax.present ? data.tax.value : this.tax,
      total: data.total.present ? data.total.value : this.total,
      tenderType: data.tenderType.present
          ? data.tenderType.value
          : this.tenderType,
      cashAmount: data.cashAmount.present
          ? data.cashAmount.value
          : this.cashAmount,
      cardAmount: data.cardAmount.present
          ? data.cardAmount.value
          : this.cardAmount,
      changeAmount: data.changeAmount.present
          ? data.changeAmount.value
          : this.changeAmount,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      isVoided: data.isVoided.present ? data.isVoided.value : this.isVoided,
      voidedByName: data.voidedByName.present
          ? data.voidedByName.value
          : this.voidedByName,
      voidedById: data.voidedById.present
          ? data.voidedById.value
          : this.voidedById,
      voidedAt: data.voidedAt.present ? data.voidedAt.value : this.voidedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('cashierId: $cashierId, ')
          ..write('cashierName: $cashierName, ')
          ..write('subtotal: $subtotal, ')
          ..write('tax: $tax, ')
          ..write('total: $total, ')
          ..write('tenderType: $tenderType, ')
          ..write('cashAmount: $cashAmount, ')
          ..write('cardAmount: $cardAmount, ')
          ..write('changeAmount: $changeAmount, ')
          ..write('timestamp: $timestamp, ')
          ..write('isVoided: $isVoided, ')
          ..write('voidedByName: $voidedByName, ')
          ..write('voidedById: $voidedById, ')
          ..write('voidedAt: $voidedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shiftId,
    cashierId,
    cashierName,
    subtotal,
    tax,
    total,
    tenderType,
    cashAmount,
    cardAmount,
    changeAmount,
    timestamp,
    isVoided,
    voidedByName,
    voidedById,
    voidedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.id == this.id &&
          other.shiftId == this.shiftId &&
          other.cashierId == this.cashierId &&
          other.cashierName == this.cashierName &&
          other.subtotal == this.subtotal &&
          other.tax == this.tax &&
          other.total == this.total &&
          other.tenderType == this.tenderType &&
          other.cashAmount == this.cashAmount &&
          other.cardAmount == this.cardAmount &&
          other.changeAmount == this.changeAmount &&
          other.timestamp == this.timestamp &&
          other.isVoided == this.isVoided &&
          other.voidedByName == this.voidedByName &&
          other.voidedById == this.voidedById &&
          other.voidedAt == this.voidedAt);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<String> id;
  final Value<String> shiftId;
  final Value<String?> cashierId;
  final Value<String?> cashierName;
  final Value<double> subtotal;
  final Value<double> tax;
  final Value<double> total;
  final Value<String> tenderType;
  final Value<double> cashAmount;
  final Value<double> cardAmount;
  final Value<double> changeAmount;
  final Value<DateTime> timestamp;
  final Value<bool> isVoided;
  final Value<String?> voidedByName;
  final Value<String?> voidedById;
  final Value<DateTime?> voidedAt;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.cashierId = const Value.absent(),
    this.cashierName = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.tax = const Value.absent(),
    this.total = const Value.absent(),
    this.tenderType = const Value.absent(),
    this.cashAmount = const Value.absent(),
    this.cardAmount = const Value.absent(),
    this.changeAmount = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isVoided = const Value.absent(),
    this.voidedByName = const Value.absent(),
    this.voidedById = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String shiftId,
    this.cashierId = const Value.absent(),
    this.cashierName = const Value.absent(),
    required double subtotal,
    required double tax,
    required double total,
    required String tenderType,
    required double cashAmount,
    required double cardAmount,
    required double changeAmount,
    required DateTime timestamp,
    this.isVoided = const Value.absent(),
    this.voidedByName = const Value.absent(),
    this.voidedById = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shiftId = Value(shiftId),
       subtotal = Value(subtotal),
       tax = Value(tax),
       total = Value(total),
       tenderType = Value(tenderType),
       cashAmount = Value(cashAmount),
       cardAmount = Value(cardAmount),
       changeAmount = Value(changeAmount),
       timestamp = Value(timestamp);
  static Insertable<TransactionRow> custom({
    Expression<String>? id,
    Expression<String>? shiftId,
    Expression<String>? cashierId,
    Expression<String>? cashierName,
    Expression<double>? subtotal,
    Expression<double>? tax,
    Expression<double>? total,
    Expression<String>? tenderType,
    Expression<double>? cashAmount,
    Expression<double>? cardAmount,
    Expression<double>? changeAmount,
    Expression<DateTime>? timestamp,
    Expression<bool>? isVoided,
    Expression<String>? voidedByName,
    Expression<String>? voidedById,
    Expression<DateTime>? voidedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shiftId != null) 'shift_id': shiftId,
      if (cashierId != null) 'cashier_id': cashierId,
      if (cashierName != null) 'cashier_name': cashierName,
      if (subtotal != null) 'subtotal': subtotal,
      if (tax != null) 'tax': tax,
      if (total != null) 'total': total,
      if (tenderType != null) 'tender_type': tenderType,
      if (cashAmount != null) 'cash_amount': cashAmount,
      if (cardAmount != null) 'card_amount': cardAmount,
      if (changeAmount != null) 'change_amount': changeAmount,
      if (timestamp != null) 'timestamp': timestamp,
      if (isVoided != null) 'is_voided': isVoided,
      if (voidedByName != null) 'voided_by_name': voidedByName,
      if (voidedById != null) 'voided_by_id': voidedById,
      if (voidedAt != null) 'voided_at': voidedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? shiftId,
    Value<String?>? cashierId,
    Value<String?>? cashierName,
    Value<double>? subtotal,
    Value<double>? tax,
    Value<double>? total,
    Value<String>? tenderType,
    Value<double>? cashAmount,
    Value<double>? cardAmount,
    Value<double>? changeAmount,
    Value<DateTime>? timestamp,
    Value<bool>? isVoided,
    Value<String?>? voidedByName,
    Value<String?>? voidedById,
    Value<DateTime?>? voidedAt,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      shiftId: shiftId ?? this.shiftId,
      cashierId: cashierId ?? this.cashierId,
      cashierName: cashierName ?? this.cashierName,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      tenderType: tenderType ?? this.tenderType,
      cashAmount: cashAmount ?? this.cashAmount,
      cardAmount: cardAmount ?? this.cardAmount,
      changeAmount: changeAmount ?? this.changeAmount,
      timestamp: timestamp ?? this.timestamp,
      isVoided: isVoided ?? this.isVoided,
      voidedByName: voidedByName ?? this.voidedByName,
      voidedById: voidedById ?? this.voidedById,
      voidedAt: voidedAt ?? this.voidedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (cashierId.present) {
      map['cashier_id'] = Variable<String>(cashierId.value);
    }
    if (cashierName.present) {
      map['cashier_name'] = Variable<String>(cashierName.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (tax.present) {
      map['tax'] = Variable<double>(tax.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (tenderType.present) {
      map['tender_type'] = Variable<String>(tenderType.value);
    }
    if (cashAmount.present) {
      map['cash_amount'] = Variable<double>(cashAmount.value);
    }
    if (cardAmount.present) {
      map['card_amount'] = Variable<double>(cardAmount.value);
    }
    if (changeAmount.present) {
      map['change_amount'] = Variable<double>(changeAmount.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (isVoided.present) {
      map['is_voided'] = Variable<bool>(isVoided.value);
    }
    if (voidedByName.present) {
      map['voided_by_name'] = Variable<String>(voidedByName.value);
    }
    if (voidedById.present) {
      map['voided_by_id'] = Variable<String>(voidedById.value);
    }
    if (voidedAt.present) {
      map['voided_at'] = Variable<DateTime>(voidedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('cashierId: $cashierId, ')
          ..write('cashierName: $cashierName, ')
          ..write('subtotal: $subtotal, ')
          ..write('tax: $tax, ')
          ..write('total: $total, ')
          ..write('tenderType: $tenderType, ')
          ..write('cashAmount: $cashAmount, ')
          ..write('cardAmount: $cardAmount, ')
          ..write('changeAmount: $changeAmount, ')
          ..write('timestamp: $timestamp, ')
          ..write('isVoided: $isVoided, ')
          ..write('voidedByName: $voidedByName, ')
          ..write('voidedById: $voidedById, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CartItemsTable extends CartItems
    with TableInfo<$CartItemsTable, CartItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CartItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productPriceMeta = const VerificationMeta(
    'productPrice',
  );
  @override
  late final GeneratedColumn<double> productPrice = GeneratedColumn<double>(
    'product_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productCategoryMeta = const VerificationMeta(
    'productCategory',
  );
  @override
  late final GeneratedColumn<String> productCategory = GeneratedColumn<String>(
    'product_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productEmojiMeta = const VerificationMeta(
    'productEmoji',
  );
  @override
  late final GeneratedColumn<String> productEmoji = GeneratedColumn<String>(
    'product_emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productColorMeta = const VerificationMeta(
    'productColor',
  );
  @override
  late final GeneratedColumn<int> productColor = GeneratedColumn<int>(
    'product_color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionId,
    productId,
    productName,
    productPrice,
    productCategory,
    productEmoji,
    productColor,
    quantity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cart_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CartItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('product_price')) {
      context.handle(
        _productPriceMeta,
        productPrice.isAcceptableOrUnknown(
          data['product_price']!,
          _productPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productPriceMeta);
    }
    if (data.containsKey('product_category')) {
      context.handle(
        _productCategoryMeta,
        productCategory.isAcceptableOrUnknown(
          data['product_category']!,
          _productCategoryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productCategoryMeta);
    }
    if (data.containsKey('product_emoji')) {
      context.handle(
        _productEmojiMeta,
        productEmoji.isAcceptableOrUnknown(
          data['product_emoji']!,
          _productEmojiMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productEmojiMeta);
    }
    if (data.containsKey('product_color')) {
      context.handle(
        _productColorMeta,
        productColor.isAcceptableOrUnknown(
          data['product_color']!,
          _productColorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productColorMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CartItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CartItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      productPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}product_price'],
      )!,
      productCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_category'],
      )!,
      productEmoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_emoji'],
      )!,
      productColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_color'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $CartItemsTable createAlias(String alias) {
    return $CartItemsTable(attachedDatabase, alias);
  }
}

class CartItemRow extends DataClass implements Insertable<CartItemRow> {
  final int id;
  final String transactionId;
  final String productId;
  final String productName;
  final double productPrice;
  final String productCategory;
  final String productEmoji;
  final int productColor;
  final int quantity;
  const CartItemRow({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productCategory,
    required this.productEmoji,
    required this.productColor,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['product_price'] = Variable<double>(productPrice);
    map['product_category'] = Variable<String>(productCategory);
    map['product_emoji'] = Variable<String>(productEmoji);
    map['product_color'] = Variable<int>(productColor);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  CartItemsCompanion toCompanion(bool nullToAbsent) {
    return CartItemsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      productId: Value(productId),
      productName: Value(productName),
      productPrice: Value(productPrice),
      productCategory: Value(productCategory),
      productEmoji: Value(productEmoji),
      productColor: Value(productColor),
      quantity: Value(quantity),
    );
  }

  factory CartItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CartItemRow(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      productPrice: serializer.fromJson<double>(json['productPrice']),
      productCategory: serializer.fromJson<String>(json['productCategory']),
      productEmoji: serializer.fromJson<String>(json['productEmoji']),
      productColor: serializer.fromJson<int>(json['productColor']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'productPrice': serializer.toJson<double>(productPrice),
      'productCategory': serializer.toJson<String>(productCategory),
      'productEmoji': serializer.toJson<String>(productEmoji),
      'productColor': serializer.toJson<int>(productColor),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  CartItemRow copyWith({
    int? id,
    String? transactionId,
    String? productId,
    String? productName,
    double? productPrice,
    String? productCategory,
    String? productEmoji,
    int? productColor,
    int? quantity,
  }) => CartItemRow(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    productPrice: productPrice ?? this.productPrice,
    productCategory: productCategory ?? this.productCategory,
    productEmoji: productEmoji ?? this.productEmoji,
    productColor: productColor ?? this.productColor,
    quantity: quantity ?? this.quantity,
  );
  CartItemRow copyWithCompanion(CartItemsCompanion data) {
    return CartItemRow(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      productPrice: data.productPrice.present
          ? data.productPrice.value
          : this.productPrice,
      productCategory: data.productCategory.present
          ? data.productCategory.value
          : this.productCategory,
      productEmoji: data.productEmoji.present
          ? data.productEmoji.value
          : this.productEmoji,
      productColor: data.productColor.present
          ? data.productColor.value
          : this.productColor,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CartItemRow(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('productPrice: $productPrice, ')
          ..write('productCategory: $productCategory, ')
          ..write('productEmoji: $productEmoji, ')
          ..write('productColor: $productColor, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionId,
    productId,
    productName,
    productPrice,
    productCategory,
    productEmoji,
    productColor,
    quantity,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartItemRow &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.productPrice == this.productPrice &&
          other.productCategory == this.productCategory &&
          other.productEmoji == this.productEmoji &&
          other.productColor == this.productColor &&
          other.quantity == this.quantity);
}

class CartItemsCompanion extends UpdateCompanion<CartItemRow> {
  final Value<int> id;
  final Value<String> transactionId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<double> productPrice;
  final Value<String> productCategory;
  final Value<String> productEmoji;
  final Value<int> productColor;
  final Value<int> quantity;
  const CartItemsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.productPrice = const Value.absent(),
    this.productCategory = const Value.absent(),
    this.productEmoji = const Value.absent(),
    this.productColor = const Value.absent(),
    this.quantity = const Value.absent(),
  });
  CartItemsCompanion.insert({
    this.id = const Value.absent(),
    required String transactionId,
    required String productId,
    required String productName,
    required double productPrice,
    required String productCategory,
    required String productEmoji,
    required int productColor,
    required int quantity,
  }) : transactionId = Value(transactionId),
       productId = Value(productId),
       productName = Value(productName),
       productPrice = Value(productPrice),
       productCategory = Value(productCategory),
       productEmoji = Value(productEmoji),
       productColor = Value(productColor),
       quantity = Value(quantity);
  static Insertable<CartItemRow> custom({
    Expression<int>? id,
    Expression<String>? transactionId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<double>? productPrice,
    Expression<String>? productCategory,
    Expression<String>? productEmoji,
    Expression<int>? productColor,
    Expression<int>? quantity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (productPrice != null) 'product_price': productPrice,
      if (productCategory != null) 'product_category': productCategory,
      if (productEmoji != null) 'product_emoji': productEmoji,
      if (productColor != null) 'product_color': productColor,
      if (quantity != null) 'quantity': quantity,
    });
  }

  CartItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? transactionId,
    Value<String>? productId,
    Value<String>? productName,
    Value<double>? productPrice,
    Value<String>? productCategory,
    Value<String>? productEmoji,
    Value<int>? productColor,
    Value<int>? quantity,
  }) {
    return CartItemsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      productCategory: productCategory ?? this.productCategory,
      productEmoji: productEmoji ?? this.productEmoji,
      productColor: productColor ?? this.productColor,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (productPrice.present) {
      map['product_price'] = Variable<double>(productPrice.value);
    }
    if (productCategory.present) {
      map['product_category'] = Variable<String>(productCategory.value);
    }
    if (productEmoji.present) {
      map['product_emoji'] = Variable<String>(productEmoji.value);
    }
    if (productColor.present) {
      map['product_color'] = Variable<int>(productColor.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CartItemsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('productPrice: $productPrice, ')
          ..write('productCategory: $productCategory, ')
          ..write('productEmoji: $productEmoji, ')
          ..write('productColor: $productColor, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BusinessDaysTable businessDays = $BusinessDaysTable(this);
  late final $ShiftsTable shifts = $ShiftsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $CartItemsTable cartItems = $CartItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    businessDays,
    shifts,
    transactions,
    cartItems,
  ];
}

typedef $$BusinessDaysTableCreateCompanionBuilder =
    BusinessDaysCompanion Function({
      required String id,
      required DateTime openedAt,
      Value<DateTime?> closedAt,
      required String openedByName,
      required String openedById,
      Value<String?> closedByName,
      Value<String?> closedById,
      Value<int> rowid,
    });
typedef $$BusinessDaysTableUpdateCompanionBuilder =
    BusinessDaysCompanion Function({
      Value<String> id,
      Value<DateTime> openedAt,
      Value<DateTime?> closedAt,
      Value<String> openedByName,
      Value<String> openedById,
      Value<String?> closedByName,
      Value<String?> closedById,
      Value<int> rowid,
    });

class $$BusinessDaysTableFilterComposer
    extends Composer<_$AppDatabase, $BusinessDaysTable> {
  $$BusinessDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openedByName => $composableBuilder(
    column: $table.openedByName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openedById => $composableBuilder(
    column: $table.openedById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedByName => $composableBuilder(
    column: $table.closedByName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedById => $composableBuilder(
    column: $table.closedById,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BusinessDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $BusinessDaysTable> {
  $$BusinessDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openedByName => $composableBuilder(
    column: $table.openedByName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openedById => $composableBuilder(
    column: $table.openedById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedByName => $composableBuilder(
    column: $table.closedByName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedById => $composableBuilder(
    column: $table.closedById,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BusinessDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $BusinessDaysTable> {
  $$BusinessDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<String> get openedByName => $composableBuilder(
    column: $table.openedByName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openedById => $composableBuilder(
    column: $table.openedById,
    builder: (column) => column,
  );

  GeneratedColumn<String> get closedByName => $composableBuilder(
    column: $table.closedByName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get closedById => $composableBuilder(
    column: $table.closedById,
    builder: (column) => column,
  );
}

class $$BusinessDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BusinessDaysTable,
          BusinessDayRow,
          $$BusinessDaysTableFilterComposer,
          $$BusinessDaysTableOrderingComposer,
          $$BusinessDaysTableAnnotationComposer,
          $$BusinessDaysTableCreateCompanionBuilder,
          $$BusinessDaysTableUpdateCompanionBuilder,
          (
            BusinessDayRow,
            BaseReferences<_$AppDatabase, $BusinessDaysTable, BusinessDayRow>,
          ),
          BusinessDayRow,
          PrefetchHooks Function()
        > {
  $$BusinessDaysTableTableManager(_$AppDatabase db, $BusinessDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BusinessDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BusinessDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BusinessDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> openedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<String> openedByName = const Value.absent(),
                Value<String> openedById = const Value.absent(),
                Value<String?> closedByName = const Value.absent(),
                Value<String?> closedById = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BusinessDaysCompanion(
                id: id,
                openedAt: openedAt,
                closedAt: closedAt,
                openedByName: openedByName,
                openedById: openedById,
                closedByName: closedByName,
                closedById: closedById,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime openedAt,
                Value<DateTime?> closedAt = const Value.absent(),
                required String openedByName,
                required String openedById,
                Value<String?> closedByName = const Value.absent(),
                Value<String?> closedById = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BusinessDaysCompanion.insert(
                id: id,
                openedAt: openedAt,
                closedAt: closedAt,
                openedByName: openedByName,
                openedById: openedById,
                closedByName: closedByName,
                closedById: closedById,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BusinessDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BusinessDaysTable,
      BusinessDayRow,
      $$BusinessDaysTableFilterComposer,
      $$BusinessDaysTableOrderingComposer,
      $$BusinessDaysTableAnnotationComposer,
      $$BusinessDaysTableCreateCompanionBuilder,
      $$BusinessDaysTableUpdateCompanionBuilder,
      (
        BusinessDayRow,
        BaseReferences<_$AppDatabase, $BusinessDaysTable, BusinessDayRow>,
      ),
      BusinessDayRow,
      PrefetchHooks Function()
    >;
typedef $$ShiftsTableCreateCompanionBuilder =
    ShiftsCompanion Function({
      required String id,
      required String businessDayId,
      required String type,
      required DateTime openedAt,
      Value<DateTime?> closedAt,
      required String openedByName,
      required String openedById,
      Value<String?> closedByName,
      Value<String?> closedById,
      Value<int> rowid,
    });
typedef $$ShiftsTableUpdateCompanionBuilder =
    ShiftsCompanion Function({
      Value<String> id,
      Value<String> businessDayId,
      Value<String> type,
      Value<DateTime> openedAt,
      Value<DateTime?> closedAt,
      Value<String> openedByName,
      Value<String> openedById,
      Value<String?> closedByName,
      Value<String?> closedById,
      Value<int> rowid,
    });

class $$ShiftsTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDayId => $composableBuilder(
    column: $table.businessDayId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openedByName => $composableBuilder(
    column: $table.openedByName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openedById => $composableBuilder(
    column: $table.openedById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedByName => $composableBuilder(
    column: $table.closedByName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedById => $composableBuilder(
    column: $table.closedById,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShiftsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDayId => $composableBuilder(
    column: $table.businessDayId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openedByName => $composableBuilder(
    column: $table.openedByName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openedById => $composableBuilder(
    column: $table.openedById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedByName => $composableBuilder(
    column: $table.closedByName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedById => $composableBuilder(
    column: $table.closedById,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShiftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessDayId => $composableBuilder(
    column: $table.businessDayId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<String> get openedByName => $composableBuilder(
    column: $table.openedByName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openedById => $composableBuilder(
    column: $table.openedById,
    builder: (column) => column,
  );

  GeneratedColumn<String> get closedByName => $composableBuilder(
    column: $table.closedByName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get closedById => $composableBuilder(
    column: $table.closedById,
    builder: (column) => column,
  );
}

class $$ShiftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftsTable,
          ShiftRow,
          $$ShiftsTableFilterComposer,
          $$ShiftsTableOrderingComposer,
          $$ShiftsTableAnnotationComposer,
          $$ShiftsTableCreateCompanionBuilder,
          $$ShiftsTableUpdateCompanionBuilder,
          (ShiftRow, BaseReferences<_$AppDatabase, $ShiftsTable, ShiftRow>),
          ShiftRow,
          PrefetchHooks Function()
        > {
  $$ShiftsTableTableManager(_$AppDatabase db, $ShiftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessDayId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> openedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<String> openedByName = const Value.absent(),
                Value<String> openedById = const Value.absent(),
                Value<String?> closedByName = const Value.absent(),
                Value<String?> closedById = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftsCompanion(
                id: id,
                businessDayId: businessDayId,
                type: type,
                openedAt: openedAt,
                closedAt: closedAt,
                openedByName: openedByName,
                openedById: openedById,
                closedByName: closedByName,
                closedById: closedById,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessDayId,
                required String type,
                required DateTime openedAt,
                Value<DateTime?> closedAt = const Value.absent(),
                required String openedByName,
                required String openedById,
                Value<String?> closedByName = const Value.absent(),
                Value<String?> closedById = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftsCompanion.insert(
                id: id,
                businessDayId: businessDayId,
                type: type,
                openedAt: openedAt,
                closedAt: closedAt,
                openedByName: openedByName,
                openedById: openedById,
                closedByName: closedByName,
                closedById: closedById,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShiftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftsTable,
      ShiftRow,
      $$ShiftsTableFilterComposer,
      $$ShiftsTableOrderingComposer,
      $$ShiftsTableAnnotationComposer,
      $$ShiftsTableCreateCompanionBuilder,
      $$ShiftsTableUpdateCompanionBuilder,
      (ShiftRow, BaseReferences<_$AppDatabase, $ShiftsTable, ShiftRow>),
      ShiftRow,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required String shiftId,
      Value<String?> cashierId,
      Value<String?> cashierName,
      required double subtotal,
      required double tax,
      required double total,
      required String tenderType,
      required double cashAmount,
      required double cardAmount,
      required double changeAmount,
      required DateTime timestamp,
      Value<bool> isVoided,
      Value<String?> voidedByName,
      Value<String?> voidedById,
      Value<DateTime?> voidedAt,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String> shiftId,
      Value<String?> cashierId,
      Value<String?> cashierName,
      Value<double> subtotal,
      Value<double> tax,
      Value<double> total,
      Value<String> tenderType,
      Value<double> cashAmount,
      Value<double> cardAmount,
      Value<double> changeAmount,
      Value<DateTime> timestamp,
      Value<bool> isVoided,
      Value<String?> voidedByName,
      Value<String?> voidedById,
      Value<DateTime?> voidedAt,
      Value<int> rowid,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashierId => $composableBuilder(
    column: $table.cashierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashierName => $composableBuilder(
    column: $table.cashierName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tax => $composableBuilder(
    column: $table.tax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenderType => $composableBuilder(
    column: $table.tenderType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cashAmount => $composableBuilder(
    column: $table.cashAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cardAmount => $composableBuilder(
    column: $table.cardAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVoided => $composableBuilder(
    column: $table.isVoided,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidedByName => $composableBuilder(
    column: $table.voidedByName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidedById => $composableBuilder(
    column: $table.voidedById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashierId => $composableBuilder(
    column: $table.cashierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashierName => $composableBuilder(
    column: $table.cashierName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tax => $composableBuilder(
    column: $table.tax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenderType => $composableBuilder(
    column: $table.tenderType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cashAmount => $composableBuilder(
    column: $table.cashAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cardAmount => $composableBuilder(
    column: $table.cardAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVoided => $composableBuilder(
    column: $table.isVoided,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidedByName => $composableBuilder(
    column: $table.voidedByName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidedById => $composableBuilder(
    column: $table.voidedById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<String> get cashierId =>
      $composableBuilder(column: $table.cashierId, builder: (column) => column);

  GeneratedColumn<String> get cashierName => $composableBuilder(
    column: $table.cashierName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get tax =>
      $composableBuilder(column: $table.tax, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get tenderType => $composableBuilder(
    column: $table.tenderType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cashAmount => $composableBuilder(
    column: $table.cashAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cardAmount => $composableBuilder(
    column: $table.cardAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get isVoided =>
      $composableBuilder(column: $table.isVoided, builder: (column) => column);

  GeneratedColumn<String> get voidedByName => $composableBuilder(
    column: $table.voidedByName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get voidedById => $composableBuilder(
    column: $table.voidedById,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get voidedAt =>
      $composableBuilder(column: $table.voidedAt, builder: (column) => column);
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionRow,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            TransactionRow,
            BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow>,
          ),
          TransactionRow,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shiftId = const Value.absent(),
                Value<String?> cashierId = const Value.absent(),
                Value<String?> cashierName = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> tax = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String> tenderType = const Value.absent(),
                Value<double> cashAmount = const Value.absent(),
                Value<double> cardAmount = const Value.absent(),
                Value<double> changeAmount = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> isVoided = const Value.absent(),
                Value<String?> voidedByName = const Value.absent(),
                Value<String?> voidedById = const Value.absent(),
                Value<DateTime?> voidedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                shiftId: shiftId,
                cashierId: cashierId,
                cashierName: cashierName,
                subtotal: subtotal,
                tax: tax,
                total: total,
                tenderType: tenderType,
                cashAmount: cashAmount,
                cardAmount: cardAmount,
                changeAmount: changeAmount,
                timestamp: timestamp,
                isVoided: isVoided,
                voidedByName: voidedByName,
                voidedById: voidedById,
                voidedAt: voidedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shiftId,
                Value<String?> cashierId = const Value.absent(),
                Value<String?> cashierName = const Value.absent(),
                required double subtotal,
                required double tax,
                required double total,
                required String tenderType,
                required double cashAmount,
                required double cardAmount,
                required double changeAmount,
                required DateTime timestamp,
                Value<bool> isVoided = const Value.absent(),
                Value<String?> voidedByName = const Value.absent(),
                Value<String?> voidedById = const Value.absent(),
                Value<DateTime?> voidedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                shiftId: shiftId,
                cashierId: cashierId,
                cashierName: cashierName,
                subtotal: subtotal,
                tax: tax,
                total: total,
                tenderType: tenderType,
                cashAmount: cashAmount,
                cardAmount: cardAmount,
                changeAmount: changeAmount,
                timestamp: timestamp,
                isVoided: isVoided,
                voidedByName: voidedByName,
                voidedById: voidedById,
                voidedAt: voidedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionRow,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        TransactionRow,
        BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow>,
      ),
      TransactionRow,
      PrefetchHooks Function()
    >;
typedef $$CartItemsTableCreateCompanionBuilder =
    CartItemsCompanion Function({
      Value<int> id,
      required String transactionId,
      required String productId,
      required String productName,
      required double productPrice,
      required String productCategory,
      required String productEmoji,
      required int productColor,
      required int quantity,
    });
typedef $$CartItemsTableUpdateCompanionBuilder =
    CartItemsCompanion Function({
      Value<int> id,
      Value<String> transactionId,
      Value<String> productId,
      Value<String> productName,
      Value<double> productPrice,
      Value<String> productCategory,
      Value<String> productEmoji,
      Value<int> productColor,
      Value<int> quantity,
    });

class $$CartItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CartItemsTable> {
  $$CartItemsTableFilterComposer({
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

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get productPrice => $composableBuilder(
    column: $table.productPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productCategory => $composableBuilder(
    column: $table.productCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productEmoji => $composableBuilder(
    column: $table.productEmoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productColor => $composableBuilder(
    column: $table.productColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CartItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CartItemsTable> {
  $$CartItemsTableOrderingComposer({
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

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get productPrice => $composableBuilder(
    column: $table.productPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productCategory => $composableBuilder(
    column: $table.productCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productEmoji => $composableBuilder(
    column: $table.productEmoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productColor => $composableBuilder(
    column: $table.productColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CartItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CartItemsTable> {
  $$CartItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get productPrice => $composableBuilder(
    column: $table.productPrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productCategory => $composableBuilder(
    column: $table.productCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productEmoji => $composableBuilder(
    column: $table.productEmoji,
    builder: (column) => column,
  );

  GeneratedColumn<int> get productColor => $composableBuilder(
    column: $table.productColor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$CartItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CartItemsTable,
          CartItemRow,
          $$CartItemsTableFilterComposer,
          $$CartItemsTableOrderingComposer,
          $$CartItemsTableAnnotationComposer,
          $$CartItemsTableCreateCompanionBuilder,
          $$CartItemsTableUpdateCompanionBuilder,
          (
            CartItemRow,
            BaseReferences<_$AppDatabase, $CartItemsTable, CartItemRow>,
          ),
          CartItemRow,
          PrefetchHooks Function()
        > {
  $$CartItemsTableTableManager(_$AppDatabase db, $CartItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CartItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CartItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CartItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<double> productPrice = const Value.absent(),
                Value<String> productCategory = const Value.absent(),
                Value<String> productEmoji = const Value.absent(),
                Value<int> productColor = const Value.absent(),
                Value<int> quantity = const Value.absent(),
              }) => CartItemsCompanion(
                id: id,
                transactionId: transactionId,
                productId: productId,
                productName: productName,
                productPrice: productPrice,
                productCategory: productCategory,
                productEmoji: productEmoji,
                productColor: productColor,
                quantity: quantity,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String transactionId,
                required String productId,
                required String productName,
                required double productPrice,
                required String productCategory,
                required String productEmoji,
                required int productColor,
                required int quantity,
              }) => CartItemsCompanion.insert(
                id: id,
                transactionId: transactionId,
                productId: productId,
                productName: productName,
                productPrice: productPrice,
                productCategory: productCategory,
                productEmoji: productEmoji,
                productColor: productColor,
                quantity: quantity,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CartItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CartItemsTable,
      CartItemRow,
      $$CartItemsTableFilterComposer,
      $$CartItemsTableOrderingComposer,
      $$CartItemsTableAnnotationComposer,
      $$CartItemsTableCreateCompanionBuilder,
      $$CartItemsTableUpdateCompanionBuilder,
      (
        CartItemRow,
        BaseReferences<_$AppDatabase, $CartItemsTable, CartItemRow>,
      ),
      CartItemRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BusinessDaysTableTableManager get businessDays =>
      $$BusinessDaysTableTableManager(_db, _db.businessDays);
  $$ShiftsTableTableManager get shifts =>
      $$ShiftsTableTableManager(_db, _db.shifts);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$CartItemsTableTableManager get cartItems =>
      $$CartItemsTableTableManager(_db, _db.cartItems);
}
