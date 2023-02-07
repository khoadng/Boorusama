// Flutter imports:
import 'package:flutter/material.dart';

class CreateFavoriteGroupDialog extends StatefulWidget {
  const CreateFavoriteGroupDialog({
    super.key,
    required this.onCreate,
    this.padding,
  });

  final void Function(
    String name,
    String initialIds,
    bool isPrivate,
  ) onCreate;
  final double? padding;

  @override
  State<CreateFavoriteGroupDialog> createState() =>
      _CreateFavoriteGroupDialogState();
}

class _CreateFavoriteGroupDialogState extends State<CreateFavoriteGroupDialog> {
  final textController = TextEditingController();
  final nameController = TextEditingController();
  bool isPrivate = false;

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  'Create a group',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              TextField(
                controller: nameController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Group name',
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                child: TextField(
                  controller: textController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintMaxLines: 6,
                    hintText:
                        '${'Initial post ids (Optional). Space delimited'}\n\n\n\n\n',
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
              ListTile(
                title: const Text('Private?'),
                trailing: Switch.adaptive(
                  value: isPrivate,
                  onChanged: (value) => setState(() => isPrivate = value),
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: textController,
                builder: (context, value, child) => ElevatedButton(
                  onPressed: nameController.text.isNotEmpty
                      ? () {
                          Navigator.of(context).pop();
                          widget.onCreate(
                            nameController.text,
                            textController.text,
                            isPrivate,
                          );
                        }
                      : null,
                  child: const Text('Create'),
                ),
              ),
              SizedBox(height: widget.padding ?? 0),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
