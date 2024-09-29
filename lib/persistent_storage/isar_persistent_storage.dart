import 'dart:io';

import 'package:isar/isar.dart';
import 'package:kgl_time/work_entry.dart';
import 'package:path_provider/path_provider.dart';

import 'persistent_storage_interface.dart';

class IsarPersistentStorage implements PersistentStorage{
  late final Isar isar;
  late final Directory dir;
  @override
  Future<void> addEntry(WorkEntry entry) {
    // TODO: implement addEntry
    throw UnimplementedError();
  }

  @override
  Future<void> close() {
    // TODO: implement close
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAllEntries() {
    // TODO: implement deleteAllEntries
    throw UnimplementedError();
  }

  @override
  Future<void> deleteEntry(WorkEntry entry) {
    // TODO: implement deleteEntry
    throw UnimplementedError();
  }

  @override
  Future<void> initialize() async {
    dir = await getApplicationDocumentsDirectory();
    //isar = await Isar.open(schemas, directory: directory);

  }

  @override
  Future<List<WorkEntry>> loadEntries() {
    // TODO: implement loadEntries
    throw UnimplementedError();
  }

  @override
  Future<void> saveEntries(List<WorkEntry> entries) {
    // TODO: implement saveEntries
    throw UnimplementedError();
  }

  @override
  Future<void> updateEntry(WorkEntry newEntry, WorkEntry oldEntry) {
    // TODO: implement updateEntry
    throw UnimplementedError();
  }
  
}