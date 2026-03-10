import 'dart:io';
import 'package:flutter/material.dart';
import 'package:agentic_ai/app/features/property_listing/presentation/pages/property_list_page.dart';
import 'package:agentic_ai/app/features/search/presentation/pages/search_page.dart';
import 'package:agentic_ai/app/features/chat/presentation/pages/chat_list_page.dart';
import 'package:agentic_ai/app/features/profile/presentation/pages/profile_page.dart';
import 'package:agentic_ai/app/features/property_listing/presentation/pages/add_property_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Store submitted properties so Home can display them
  final List<Map<String, dynamic>> _submittedProperties = [];

  // Define the pages dynamically in build so we can pass callbacks/state
  // late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Create the static user object for the profile page

    // Keep user in state via a field closure (we'll use this in build)
  }

  void _handlePropertySubmit(Map<String, dynamic> payload) {
    // Add to submitted list and switch to Home tab
    setState(() {
      _submittedProperties.insert(0, payload);
      _selectedIndex = 0;
    });

    // Show a success snackbar with an action to view
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Property submitted successfully'),
      action: SnackBarAction(label: 'View', onPressed: () => setState(() => _selectedIndex = 0)),
    ));
  }

  void _handlePlaceBid(Map<String, dynamic> property) async {
    final amountCtrl = TextEditingController();
    final res = await showDialog<bool?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Place a bid for ${property['title'] ?? 'Property'}'),
        content: TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Enter bid amount (BDT)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () {
            // In a real app you'd send the bid to backend
            Navigator.pop(ctx, true);
          }, child: const Text('Place Bid')),
        ],
      ),
    );
    if (res == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bid placed (demo)')));
    }
  }

  // Handles bottom navigation taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // recreate static user here (same as before)

    final pages = <Widget>[
      HomeContent(userProperties: _submittedProperties, onPlaceBid: _handlePlaceBid),
      const SearchPage(),
      AddPropertyPage(onSubmit: _handlePropertySubmit),
      const ChatListPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Add/Bid',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
      ),
    );
  }
}

// The main content of the home screen, extracted into a separate widget
// The main content of the home screen, extracted into a separate widget
class HomeContent extends StatelessWidget {
  final List<Map<String, dynamic>> userProperties;
  final void Function(Map<String, dynamic> property)? onPlaceBid;

  const HomeContent({super.key, this.userProperties = const [], this.onPlaceBid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dummy data for demonstration
    final List<Map<String, dynamic>> categories = [
      {'name': 'Family Flat', 'icon': Icons.family_restroom, 'color': Colors.blue},
      {'name': 'Student Room', 'icon': Icons.school, 'color': Colors.deepPurple},
      {'name': 'Bachelor', 'icon': Icons.person, 'color': Colors.teal},
      {'name': 'Shared Room', 'icon': Icons.group, 'color': Colors.orange},
      {'name': 'Apartment', 'icon': Icons.apartment, 'color': Colors.redAccent},
      {'name': 'Mess/Hostel', 'icon': Icons.bed, 'color': Colors.green},
    ];
    final List<Map<String, dynamic>> areas = [
      {'name': 'Mirpur', 'avgRent': '12k', 'rooms': 32, 'image': 'https://secure.toletbd.app/uploads/all/EN5NSnKk4Y281PyH2oy8iE598YnBZzQqcyuNHZnv.png'},
      {'name': 'Dhanmondi', 'avgRent': '25k', 'rooms': 18, 'image': 'https://propertyguide-store.s3.ap-southeast-1.amazonaws.com/bikroy/Dhanmondi_Area_Review_8dbd7dfd44.jpg'},
      {'name': 'Uttara', 'avgRent': '18k', 'rooms': 22, 'image': 'https://sarabangla.net/wp-content/uploads/2025/01/Untitled-1-copy-141.jpg'},
      {'name': 'Banani', 'avgRent': '30k', 'rooms': 10, 'image': 'https://picsum.photos/id/240/400/200'},
      {'name': 'Mohammadpur', 'avgRent': '15k', 'rooms': 14, 'image': 'https://picsum.photos/id/241/400/200'},
      {'name': 'Badda', 'avgRent': '10k', 'rooms': 8, 'image': 'https://sarabangla.net/wp-content/uploads/2025/01/Untitled-1-copy-141.jpg'},
      {'name': 'Jatrabari', 'avgRent': '9k', 'rooms': 6, 'image': 'https://blog.bikroy.com/en/wp-content/uploads/2019/10/Blog-Image-Why-you-should-consider-buying-a-property-in-Uttara.png'},
    ];
    final List<String> promoBanners = [
      'Best houses under 10k in Mirpur',
      'Family flats available this month',
      'Rooms near University Campus',
      'Premium owners verified',
    ];
    final List<Map<String, dynamic>> recommended = [
      {'rent': '15,000 BDT', 'category': 'Family', 'area': 'Gulshan', 'amenities': 'Wifi, Lift', 'owner': 'Verified', 'image': 'https://assets.savills.com/properties/IN3101054290/313381801_447745544152773_5978822150767244979_n_l_gal.jpg'},
      {'rent': '8,000 BDT', 'category': 'Student', 'area': 'Farmgate', 'amenities': 'Wifi', 'owner': 'Unverified', 'image': 'https://propertyguide-store.s3.ap-southeast-1.amazonaws.com/bikroy/anwar_landmark_whispering_green_af6d2506ff.jpg'},
      {'rent': '20,000 BDT', 'category': 'Bachelor', 'area': 'Dhanmondi', 'amenities': 'Parking', 'owner': 'Verified', 'image': 'https://shorturl.at/NOhO9'},
    ];
    final List<Map<String, dynamic>> liveBids = [
      {'property': '2 BHK in Mirpur 10', 'currentBid': '12,000 BDT', 'timeLeft': '3h'},
      {'property': 'Studio in Banani', 'currentBid': '10,500 BDT', 'timeLeft': '1h'},
    ];
    final List<Map<String, dynamic>> messages = [
      {'summary': 'You have 3 new offers'},
      {'summary': 'Owner counter-offered'},
      {'summary': 'Bid updated'},
    ];
    final List<Map<String, dynamic>> notifications = [
      {'title': 'Bid Accepted', 'desc': 'Your bid for Mirpur flat was accepted.'},
      {'title': 'New Message', 'desc': 'You have a new message from Mrs. Khan.'},
      {'title': 'Room near you just listed!', 'desc': 'Check out new rooms in Dhanmondi.'},
    ];
    final List<Map<String, dynamic>> recentlyViewed = [
      {'property': '1 BHK in Badda', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcST-Vnr_SCFA9--fpo49Fqx9KJCLa98yDJ-7Q&s'},
      {'property': 'Studio in Mohammadpur', 'image': 'https://shorturl.at/NOhO9'},
      {'property': 'Family Flat in Mirpur', 'image': 'https://secure.toletbd.app/uploads/all/EN5NSnKk4Y281PyH2oy8iE598YnBZzQqcyuNHZnv.png'},
      {'property': 'Shared Room in Jatrabari', 'image': 'https://propertyguide-store.s3.ap-southeast-1.amazonaws.com/bikroy/anwar_landmark_whispering_green_af6d2506ff.jpg'},
      {'property': 'Shared Room in Jatrabari', 'image': 'https://picsum.photos/id/248/200/300'},
    ];
    final List<Map<String, dynamic>> bookmarks = [
      {'property': '2 BHK in Banani', 'image': 'https://picsum.photos/id/249/200/300'},
      {'property': 'Apartment in Uttara', 'image': 'https://blog.tropicalhomesltd.com/wp-content/uploads/2025/03/thl-studio-apartment-1024x768.jpg'},
      {'property': 'Apartment in Uttara', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSxr3rslH3iT4MMhoLeZn_tRK0T32scMDiExw&s'},
      {'property': 'Apartment in Uttara', 'image': 'https://img.freepik.com/premium-photo/luxury-apartment-modern-interior-design_636537-363402.jpg'},
    ];
    final userProps = userProperties;

    return CustomScrollView(
      slivers: [
        // 1. Top Section: Search Bar & Location
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search area, road, flat type…',
                          prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                          suffixIcon: Icon(Icons.mic, color: theme.primaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.filter_alt, color: theme.primaryColor),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: theme.primaryColor),
                      const SizedBox(width: 5),
                      Text('Dhaka, Bangladesh', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Chip(label: Text('Home')),
                      const SizedBox(width: 5),
                      Chip(label: Text('Office')),
                      const SizedBox(width: 5),
                      Chip(label: Text('University')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // 2. Rent Categories
        _buildSectionTitle(context, 'Rent Categories'),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cat['color'].withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(cat['icon'], size: 30, color: cat['color']),
                        ),
                        const SizedBox(height: 8),
                        Text(cat['name'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // 3. Area Quick Picks
        _buildSectionTitle(context, 'Area Quick Picks'),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: areas.length,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (context, index) {
                final area = areas[index];
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: double.infinity,
                    width: 130,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          child: Image.network(
                            area['image'] ?? '',
                            height: 70,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 70,
                              color: Colors.grey[300],
                              child: Icon(Icons.location_city, size: 36, color: Colors.grey[600]),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  area['name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Avg Rent: ${area['avgRent']}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${area['rooms']} rooms',
                                  style: TextStyle(fontSize: 12, color: theme.primaryColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // 4. Promo Banner (interactive)
        _buildSectionTitle(context, 'Hot Deals & Promos'),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 88,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: promoBanners.length,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              itemBuilder: (context, index) {
                final title = promoBanners[index];
                final colors = [Colors.orange, Colors.blue, Colors.purple, Colors.green, Colors.redAccent];
                final icons = [Icons.local_offer, Icons.star, Icons.whatshot, Icons.verified, Icons.flash_on];
                final bg = colors[index % colors.length];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: InkWell(
                    onTap: () {
                      // Temporary interaction: show detail/snackbar. Replace with navigation later.
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selected: $title')));
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 260,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [bg.withOpacity(0.16), bg.withOpacity(0.04)]),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: bg.withOpacity(0.18)),
                        boxShadow: [BoxShadow(color: bg.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 18, backgroundColor: bg, child: Icon(icons[index % icons.length], color: Colors.white, size: 18)),
                          const SizedBox(width: 12),
                          Expanded(child: Builder(builder: (ctx) { final dark = HSLColor.fromColor(bg).withLightness((HSLColor.fromColor(bg).lightness - 0.22).clamp(0.0,1.0)).toColor(); return Text(title, style: TextStyle(color: dark, fontWeight: FontWeight.bold)); })),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
                            child: const Text('See', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // 5. Recommended For You
        _buildSectionTitle(context, 'Recommended For You'),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recommended.length,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (context, index) {
                final rec = recommended[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: Image.network(
                          rec['image'],
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 120,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rec['rent'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.primaryColor)),
                            Text('${rec['category']}, ${rec['area']}', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                            Text('Amenities: ${rec['amenities']}', style: TextStyle(fontSize: 12)),
                            Text('Owner: ${rec['owner']}', style: TextStyle(fontSize: 12, color: rec['owner'] == 'Verified' ? Colors.green : Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        // 6. My Listings (submitted by user)
        if (userProps.isNotEmpty) _buildSectionTitle(context, 'My Listings'),
        if (userProps.isNotEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: userProps.length,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (context, index) {
                  final p = userProps[index];
                  final img = p['featureImage'] ?? (p['images'] != null && (p['images'] as List).isNotEmpty ? p['images'][0] : null);
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: img != null
                              ? (img.toString().startsWith('http')
                              ? Image.network(img, height: 110, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(height: 110, color: Colors.grey[200], child: const Icon(Icons.broken_image)))
                              : Image.file(File(img), height: 110, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(height: 110, color: Colors.grey[200], child: const Icon(Icons.broken_image))))
                              : Container(height: 110, color: Colors.grey[200], child: const Icon(Icons.home, size: 40)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('Rent: ${p['rent']} BDT', style: TextStyle(color: theme.primaryColor)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(onPressed: () => onPlaceBid?.call(p), child: const Text('Place Bid')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        // 7. Live Bidding Section
        _buildSectionTitle(context, 'Live Bidding'),
        SliverToBoxAdapter(
          child: Column(
            children: liveBids.map((bid) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                leading: Icon(Icons.gavel, color: theme.primaryColor),
                title: Text(bid['property']),
                subtitle: Text('Current Bid: ${bid['currentBid']} • ${bid['timeLeft']} left'),
                trailing: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor:theme.primaryColor,
                    side: BorderSide(color: theme.primaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: Text('Place Bid', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            )).toList(),
          ),
        ),
        // 8. Negotiation / Messages Summary
        _buildSectionTitle(context, 'Negotiation & Messages'),
        SliverToBoxAdapter(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: Icon(Icons.message, color: theme.primaryColor),
              title: Text(messages[0]['summary']),
              subtitle: Text(messages[1]['summary']),
              trailing: Text(messages[2]['summary'], style: TextStyle(color: theme.primaryColor)),
              onTap: () {},
            ),
          ),
        ),
        // 9. Near You (Map-based Listing)
        _buildSectionTitle(context, 'Near You (Map View)'),
        SliverToBoxAdapter(
          child: Container(
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://img.icons8.com/ios-filled/100/000000/map-marker.png',
                        height: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Map preview unavailable',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enable Google Maps to view nearby rentals.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // 10. Recently Viewed Properties
        _buildSectionTitle(context, 'Recently Viewed'),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recentlyViewed.length,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (context, index) {
                final prop = recentlyViewed[index];
                return Container(
                  width: 90,
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          prop['image'],
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 50,
                            width: 50,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 24, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(prop['property'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        // 11. Bookmark / Wishlist Section
        _buildSectionTitle(context, 'Bookmarks & Wishlist'),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: bookmarks.length,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (context, index) {
                final prop = bookmarks[index];
                return Container(
                  width: 90,
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          prop['image'],
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 50,
                            width: 50,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 24, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(prop['property'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        // 12. Notifications
        _buildSectionTitle(context, 'Notifications'),
        SliverToBoxAdapter(
          child: Column(
            children: notifications.map((note) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                leading: Icon(Icons.notifications, color: theme.primaryColor),
                title: Text(note['title']),
                subtitle: Text(note['desc']),
              ),
            )).toList(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  SliverToBoxAdapter _buildSectionTitle(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
