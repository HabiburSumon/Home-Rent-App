import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  String query = '';
  String selectedCategory = 'All';
  RangeValues priceRange = const RangeValues(5000, 25000);

  final List<String> categories = ['All', 'Family', 'Bachelor', 'Student', 'Sublet'];

  final List<Map<String, dynamic>> areas = [
    {'name': 'Mirpur', 'avgRent': '12,000', 'rooms': 120, 'color': Colors.blue},
    {'name': 'Dhanmondi', 'avgRent': '18,500', 'rooms': 80, 'color': Colors.green},
    {'name': 'Uttara', 'avgRent': '14,200', 'rooms': 95, 'color': Colors.orange},
    {'name': 'Banani', 'avgRent': '22,000', 'rooms': 60, 'color': Colors.purple},
    {'name': 'Mohammadpur', 'avgRent': '11,500', 'rooms': 45, 'color': Colors.teal},
  ];

  final List<Map<String, dynamic>> demoProperties = List.generate(6, (i) {
    return {
      'title': '${i + 1} BHK in Mirpur ${i + 1}',
      'area': i % 2 == 0 ? 'Mirpur' : 'Dhanmondi',
      'price': (8000 + i * 2000).toString(),
      'imageColor': Colors.primaries[i % Colors.primaries.length],
      'category': i % 2 == 0 ? 'Family' : 'Bachelor'
    };
  });

  List<Map<String, dynamic>> get filteredProperties {
    return demoProperties.where((p) {
      final matchesQuery = query.isEmpty || p['title'].toLowerCase().contains(query.toLowerCase()) || p['area'].toLowerCase().contains(query.toLowerCase());
      final matchesCategory = selectedCategory == 'All' || p['category'] == selectedCategory;
      final price = int.tryParse(p['price'].toString()) ?? 0;
      final matchesPrice = price >= priceRange.start && price <= priceRange.end;
      return matchesQuery && matchesCategory && matchesPrice;
    }).toList();
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        RangeValues tmpRange = priceRange;
        String tmpCategory = selectedCategory;
        return StatefulBuilder(builder: (context, setStateSheet) {
          return Padding(
            padding: MediaQuery.of(ctx).viewInsets,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('Category'),
                  Wrap(
                    spacing: 8,
                    children: categories.map((c) {
                      final sel = c == tmpCategory;
                      return ChoiceChip(
                        label: Text(c),
                        selected: sel,
                        onSelected: (_) => setStateSheet(() => tmpCategory = c),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text('Budget Range (BDT)'),
                  RangeSlider(
                    values: tmpRange,
                    min: 0,
                    max: 50000,
                    divisions: 100,
                    labels: RangeLabels(tmpRange.start.round().toString(), tmpRange.end.round().toString()),
                    onChanged: (v) => setStateSheet(() => tmpRange = v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedCategory = tmpCategory;
                              priceRange = tmpRange;
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Apply Filters'),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Rentals'),
        actions: [
          IconButton(onPressed: _openFilters, icon: const Icon(Icons.filter_list)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Search area, road, flat type...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _controller.clear();
                                  setState(() => query = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: theme.cardColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: (v) => setState(() => query = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(10)),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.my_location, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),

            // Categories
            SizedBox(
              height: 64,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final c = categories[index];
                  final selected = c == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: selected,
                      onSelected: (_) => setState(() => selectedCategory = c),
                      selectedColor: theme.primaryColor,
                      backgroundColor: theme.cardColor,
                      labelStyle: TextStyle(color: selected ? Colors.white : theme.textTheme.bodyLarge?.color),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Area Quick Picks + Map preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: areas.length,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        itemBuilder: (context, index) {
                          final area = areas[index];
                          return GestureDetector(
                            onTap: () => setState(() => query = area['name']),
                            child: Container(
                              width: 130,
                              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: (area['color'] as Color).withOpacity(0.15),
                                          child: Icon(Icons.location_on, color: (area['color'] as Color)),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(area['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text('Avg: ${area['avgRent']} BDT', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                                    const SizedBox(height: 4),
                                    Text('${area['rooms']} listings', style: TextStyle(fontSize: 12, color: theme.primaryColor)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 140,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
                      ),
                      child: InkWell(
                        onTap: () {},
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, size: 40, color: theme.primaryColor),
                            const SizedBox(height: 8),
                            const Text('Map Preview'),
                            const SizedBox(height: 6),
                            Text('Tap to open', style: TextStyle(color: theme.hintColor, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Results header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Results (${filteredProperties.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${priceRange.start.round()} - ${priceRange.end.round()} BDT', style: TextStyle(color: theme.hintColor)),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Results list
            Expanded(
              child: filteredProperties.isEmpty
                  ? Center(child: Text('No properties found', style: TextStyle(color: theme.hintColor)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filteredProperties.length,
                      itemBuilder: (context, index) {
                        final p = filteredProperties[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 100,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: (p['imageColor'] as MaterialColor).withOpacity(0.15),
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), bottomLeft: Radius.circular(6)),
                                ),
                                child: Center(
                                  child: Icon(Icons.home, color: (p['imageColor'] as MaterialColor), size: 36),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Text('${p['area']} • ${p['category']}', style: TextStyle(color: theme.hintColor, fontSize: 12)),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('${p['price']} BDT', style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor)),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: theme.primaryColor,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            onPressed: () {},
                                            child: const Text('Place Bid'),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

