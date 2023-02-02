import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

final tickerProvider = StreamProvider(
  (ref) => Stream.periodic(
      const Duration(
        seconds: 1,
      ),
      (i) => i + 1),
);
final nameProvider = StreamProvider(
  (ref) => ref.watch(tickerProvider.stream).map(
        (count) => names.getRange(0, count),
      ),
);
const names = [
  'abe',
  'kebe',
  'lema',
  'tedi',
  'sol',
  'mane',
  'jo',
  'kira',
];

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final names = ref.watch(nameProvider);
    return Scaffold(
        appBar: AppBar(title: const Text('Weather')),
        body: names.when(data: (name) {
          return Expanded(
            child: ListView.builder(
                itemCount: name.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(name.elementAt(index)),
                  );
                }),
          );
        }, error: (_, __) {
          return const Text('reached end of list');
        }, loading: () {
          return const CircularProgressIndicator();
        }));
  }
}
