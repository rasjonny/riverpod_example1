import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: const HomePage(),
      ),
    ),
  );
}

class Person {
  final String name;
  final String age;
  final String uuid;

  Person({
    required this.name,
    required this.age,
    String? uuid,
  }) : uuid = uuid ?? const Uuid().v4();
  Person updated(String? name, String? age) {
    return Person(
      name: name ?? this.name,
      age: age ?? this.age,
      uuid: uuid,
    );
  }

  String get displayname => '$name($age years old)';

  @override
  bool operator ==(covariant Person other) => uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() {
    return 'person is $name and $age years old';
  }
}

class DataModel extends ChangeNotifier {
  final List<Person> _people = [];
  int get count => _people.length;

  UnmodifiableListView<Person> get people => UnmodifiableListView(_people);
  void add(Person person) {
    _people.add(person);
    notifyListeners();
  }

  void remove(Person person) {
    _people.remove(person);
    notifyListeners();
  }

  void update(Person updatedPerson) {
    final index = _people.indexOf(updatedPerson);

    final oldPerson = _people[index];

    if (oldPerson.name != updatedPerson.name ||
        oldPerson.age != updatedPerson.age) {
      _people[index] = oldPerson.updated(updatedPerson.name, updatedPerson.age);
      notifyListeners();
    }
  }
}

final peopleProvider = ChangeNotifierProvider((ref) => DataModel());

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Person List'),
      ),
      body: Consumer(builder: (context, ref, child) {
        final dataModel = ref.watch(peopleProvider);
        return ListView.builder(
            itemCount: dataModel.count,
            itemBuilder: (context, index) {
              final person = dataModel.people[index];
              return ListTile(
                title: GestureDetector(
                  onTap: () async {
                    final updatedPerson =
                        await createUpdateDialogue(context, person);
                    if (updatedPerson != null) {
                      dataModel.update(updatedPerson);
                    }
                  },
                  child: Text(person.displayname),
                ),
                trailing: IconButton(
                  onPressed: () {
                    dataModel.remove(person);
                  },
                  icon: const Icon(Icons.delete),
                ),
              );
            });
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newPerson = await createUpdateDialogue(context);
          if (newPerson != null) {
            final dataModel = ref.read(peopleProvider);
            dataModel.add(newPerson);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

final nameController = TextEditingController();
final ageController = TextEditingController();
Future<Person?> createUpdateDialogue(BuildContext context,
    [Person? existingPerson]) {
  String? name = existingPerson?.name;
  String? age = existingPerson?.age;

  nameController.text = name ?? '';
  ageController.text = age ?? '';

  return showDialog<Person?>(
    context: context,
    builder: ((context) {
      return AlertDialog(
        title: const Text('create or update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'enter name here'),
              onChanged: (value) => name = value,
              autofocus: true,
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'enter age here'),
              onChanged: (value) => age = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('cancel'),
          ),
          TextButton(
            onPressed: () {
              if (name != null && age != null) {
                if (name == existingPerson?.name ||
                    age == existingPerson?.age) {
                  final updatedPerson = existingPerson?.updated(name, age);
                  Navigator.of(context).pop(updatedPerson);
                } else {
                  final newPerson = Person(name: name!, age: age!);
                  Navigator.of(context).pop(newPerson);
                }
              } else {
                Navigator.of(context).pop();
              }
            },
            child: const Text('save'),
          )
        ],
      );
    }),
  );
}
