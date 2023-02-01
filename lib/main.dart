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

enum City {
  naz,
  assel,
  addis,
}

typedef WeatherEmoji = String;

Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(const Duration(seconds: 1), () {
    return {
          City.addis: '🌧',
          City.naz: '☀',
          City.assel: '💨',
        }[city] ??
        'unknown';
  });
}

final currentCityProvider = StateProvider<City?>((ref) => null);
final weatherProvider = FutureProvider<WeatherEmoji>((ref) {
  final city = ref.watch(currentCityProvider);
  if (city != null) {
    return getWeather(city);
  }
  return '🤷‍♂️';
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final cityWeather = ref.watch(weatherProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        cityWeather.when(
          data: (data) => Text(
            data,
            style: const TextStyle(fontSize: 40),
          ),
          error: (_, __) => const Text('ERRoR'),
          loading: () => const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: City.values.length,
              itemBuilder: (context, index) {
                final city = City.values[index];
                final isSelected = city == ref.watch(currentCityProvider);
                return ListTile(
                    title: Text(
                      city.name,
                    ),
                    trailing: isSelected ? const Icon(Icons.check) : null,
                    onTap: () {
                      ref.read(currentCityProvider.notifier).state = city;
                    });
              },
            ),
          ),
        ),
      ]),
    );
  }
}
