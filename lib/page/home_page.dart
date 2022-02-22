import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopping_riverpod/general_providers.dart';
import 'package:flutter_shopping_riverpod/models/item_model.dart';
import 'package:flutter_shopping_riverpod/repositories/custom_exception.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authControllerProvider);
    final exceptionController = ref.watch(itemListExceptionProvider);

    if (exceptionController != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(exceptionController.message!),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping List"),
        actions: [
          if (authController != null)
            IconButton(
                onPressed: () {
                  ref.read(authControllerProvider.notifier).signOut();
                },
                icon: const Icon(Icons.logout))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AddItemDialog.show(context, Item.empty());
        },
        child: const Icon(Icons.add),
      ),
      body: const ItemList(),
    );
  }
}

class AddItemDialog extends ConsumerWidget {
  final Item item;
  const AddItemDialog({Key? key, required this.item}) : super(key: key);
  bool get isUpdating => item.id != null;

  static void show(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(item: item),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textEditController = TextEditingController(text: item.name);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textEditController,
              autofocus: true,
              decoration: const InputDecoration(hintText: "Item name demo"),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: isUpdating
                          ? Colors.orange
                          : Theme.of(context).primaryColor),
                  onPressed: () {
                    Navigator.of(context).pop();
                    isUpdating
                        ? ref
                            .read(itemListControllerProvider.notifier)
                            .updateItem(
                                itemUpdate: item.copyWith(
                                    name: textEditController.text.trim(),
                                    obtained: item.obtained))
                        : ref
                            .read(itemListControllerProvider.notifier)
                            .addItem(name: textEditController.text.trim());
                  },
                  child: Text(isUpdating ? "Update" : "Add")),
            )
          ],
        ),
      ),
    );
  }
}

// final currentItem = Provider<Item>((_) => throw UnimplementedError());

class ItemList extends ConsumerWidget {
  const ItemList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemListState = ref.watch(itemListControllerProvider);
    return itemListState.when(
        data: (_lstItem) => _lstItem.isEmpty
            ? const Center(child: Text("Tap + to add item"))
            : ListView.builder(
                itemCount: _lstItem.length,
                itemBuilder: (context, index) {
                  Item _item = _lstItem[index];
                  return ListTile(
                    key: ValueKey(_item.id),
                    title: Text(_item.name),
                    trailing: Checkbox(
                        value: _item.obtained,
                        onChanged: (val) => ref
                            .read(itemListControllerProvider.notifier)
                            .updateItem(
                                itemUpdate:
                                    _item.copyWith(obtained: !_item.obtained))),
                    onTap: () => AddItemDialog.show(context, _item),
                    onLongPress: () => ref
                        .read(itemListControllerProvider.notifier)
                        .deleteItem(itemId: _item.id!),
                  );
                },
              ),
        error: (error, _) => ItemListError(
              message: error is CustomException
                  ? error.message!
                  : 'Something went wrong!',
            ),
        loading: () => const Center(child: CircularProgressIndicator()));
  }
}

class ItemListError extends ConsumerWidget {
  final String message;

  const ItemListError({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(fontSize: 20.0)),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () => ref
                .read(itemListControllerProvider.notifier)
                .retriveItems(isRefeshing: true),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
