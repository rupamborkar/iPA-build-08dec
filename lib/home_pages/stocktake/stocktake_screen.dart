import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_login/baseUrl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'stocktake_detail_screen.dart';

class StocktakeScreen extends StatefulWidget {
  final String token;

  const StocktakeScreen({super.key, required this.token});

  @override
  State<StocktakeScreen> createState() => _StocktakeScreenState();
}

class _StocktakeScreenState extends State<StocktakeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> stocktakes = [];
  List<Map<String, dynamic>> filteredStocktakes = [];

  @override
  void initState() {
    super.initState();
    _fetchStocktakes();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchStocktakes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/stocktake/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          stocktakes = data
              .map((stocktake) => stocktake as Map<String, dynamic>)
              .toList();
          filteredStocktakes = stocktakes;
        });
      } else {
        throw Exception('Failed to load stocktakes');
      }
    } catch (error) {
      print('Error fetching stocktakes: $error');
    }
  }

  void _onSearchChanged() {
    setState(() {
      filteredStocktakes = stocktakes.where((stocktake) {
        return stocktake['stocktake_name']
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Stocktake',
          style: TextStyle(
            fontSize: 20,
            height: 24,
            fontWeight: FontWeight.w600,
            color: Color.fromRGBO(10, 15, 13, 1),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              width: 353,
              height: 32,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(231, 231, 231, 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          color: Color.fromRGBO(101, 104, 103, 1),
                        ),
                        prefixIcon: const Icon(
                          EneftyIcons.search_normal_2_outline,
                          //Icons.search,
                          size: 20,
                          color: Color.fromRGBO(101, 104, 103, 1),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Stocktake List
            Expanded(
              child: ListView(
                children: filteredStocktakes.map((stocktake) {
                  return StocktakeCard(
                    id: stocktake['id'] ?? '',
                    stocktakeName: stocktake['stocktake_name'] ?? 'Unknown',
                    lastUpdate: stocktake['last_update'].toString() ?? '',
                    totalItems: stocktake['total_items'].toString() ?? '0',
                    totalValue: stocktake['total_values'].toString() ?? '0',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StocktakeDetailScreen(
                            stocktakeName:
                                stocktake['stocktake_name'] ?? 'Unknown',
                            stocktakeId: stocktake['id'].toString(),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StocktakeCard extends StatelessWidget {
  final String id;
  final String stocktakeName;
  final String lastUpdate;
  final String totalItems;
  final String totalValue;
  final VoidCallback onTap;

  const StocktakeCard({
    required this.id,
    required this.stocktakeName,
    required this.lastUpdate,
    required this.totalItems,
    required this.totalValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stocktakeName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(10, 15, 13, 1),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lastUpdate,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(150, 152, 151, 1),
                ),
              ),
              const Divider(
                thickness: 1,
                color: Color.fromRGBO(230, 242, 242, 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn(totalItems, 'Total Items'),
                  _buildInfoColumn(totalValue, 'Total Value'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: Color.fromRGBO(10, 15, 13, 1),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color.fromRGBO(150, 152, 151, 1),
          ),
        ),
      ],
    );
  }
}
