import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopping_riverpod/general_providers.dart';
import 'package:flutter_shopping_riverpod/models/item_model.dart';
import 'package:flutter_shopping_riverpod/repositories/custom_exception.dart';


class ItemListController extends StateNotifier<AsyncValue<List<Item>>> {
  final Reader _reader;
  final String? _userId;

  ItemListController(this._reader, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      retriveItems();
    }
  }

  Future<void> retriveItems({bool isRefeshing = false}) async {
    if (isRefeshing) state = const AsyncValue.loading();
    try {
      final items =
          await _reader(itemRepositoryProvider).retriveItems(userId: _userId!);
      if (mounted) {
        state = AsyncValue.data(items);
      }
    } on CustomException catch (e) {
      state = AsyncValue.error(e);
    }
  }

  Future<void> addItem({required String name, bool obtained = false}) async {
    try {
      final item = Item(name: name, obtained: obtained);
      final itemId = await _reader(itemRepositoryProvider)
          .createItem(userId: _userId!, item: item);
      state.whenData((value) =>
          state = AsyncValue.data(value..add(item.copyWith(id: itemId.id))));
    } on CustomException catch (e) {
      _reader(itemListExceptionProvider.notifier).state = e;
    }
  }

  Future<void> updateItem({required Item itemUpdate}) async {
    try {
      await _reader(itemRepositoryProvider)
          .updateItem(userId: _userId!, item: itemUpdate);
      state.whenData((value) {
        int _indexItemUpdate =
            value.indexWhere((element) => element.id == itemUpdate.id);
        value[_indexItemUpdate] = itemUpdate;
        return state = AsyncValue.data(value);
      });
    } on CustomException catch (e) {
      _reader(itemListExceptionProvider.notifier).state = e;
    }
  }

  Future<void> deleteItem({required String itemId}) async {
    try {
      await _reader(itemRepositoryProvider)
          .deleteItem(userId: _userId!, itemId: itemId);
      state.whenData((value) => state = AsyncValue.data(
          value..removeWhere((element) => element.id == itemId)));
    } on CustomException catch (e) {
      _reader(itemListExceptionProvider.notifier).state = e;
    }
  }
}
