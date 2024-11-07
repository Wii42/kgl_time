import 'package:isar/isar.dart';

import 'isar_storable.dart';

part 'key_value.g.dart';

/// Stores key value pairs, where the value can be a string, int, double, bool or DateTime.
///
/// Adapted from [isar_key_value](https://github.com/MohiuddinM/isar_key_value) <br>
/// Original file:
/// [lib/src/key_value.dart at commit c868add](https://github.com/MohiuddinM/isar_key_value/blob/c868add1741511205cee356483154564cbcea3ee/lib/src/key_value.dart)
///
/// Licensed under the MIT License. See the full license below.
///
/// ```
/// MIT License
///
/// Copyright (c) 2023 muha.dev
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
/// ```

@collection
class KeyValue implements IsarStorable {
  @override
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key;

  String? stringValue;
  int? intValue;
  double? doubleValue;
  bool? boolValue;
  String? dateTimeValue;
}

extension KeyValueX on KeyValue {
  set value(dynamic value) {
    switch (value.runtimeType) {
      case const (String):
        stringValue = value;
        break;
      case const (int):
        intValue = value;
        break;
      case const (double):
        doubleValue = value;
        break;
      case const (bool):
        boolValue = value;
        break;
      case const (DateTime):
        dateTimeValue = value.toIso8601String();
        break;
      default:
        throw UnsupportedError('${value.runtimeType} is not supported');
    }
  }

  dynamic get value {
    return stringValue ??
        intValue ??
        doubleValue ??
        boolValue ??
        (dateTimeValue != null ? DateTime.parse(dateTimeValue!) : null);
  }
}
