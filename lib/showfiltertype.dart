import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onlineapp_ing/productdetail.dart';

class showfiltertype extends StatefulWidget {
  final String category; // รับค่าหมวดหมู่ที่ถูกส่งจากหน้าแรก

  const showfiltertype({Key? key, required this.category}) : super(key: key);

  @override
  State<showfiltertype> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<showfiltertype> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref('products');
  List<Map<String, dynamic>> products = [];

  Future<void> fetchProducts() async {
    try {
      final query = dbRef
          .orderByChild('category')
          .equalTo(widget.category); // กรองสินค้าตามหมวดหมู่ที่ได้รับ

      final snapshot = await query.get();

      if (snapshot.exists) {
        List<Map<String, dynamic>> loadedProducts = [];
        snapshot.children.forEach((child) {
          Map<String, dynamic> product =
              Map<String, dynamic>.from(child.value as Map);
          product['key'] = child.key;
          loadedProducts.add(product);
        });

        setState(() {
          products = loadedProducts;
        });

        print("สินค้าในหมวด ${widget.category}: ${products.length} รายการ");
      } else {
        print("ไม่พบรายการสินค้าในหมวด ${widget.category}");
      }
    } catch (e) {
      print("Error loading products: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e')),
      );
    }
  }

  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('สินค้าในหมวด ${widget.category}'),
        backgroundColor: const Color.fromARGB(255, 240, 131, 225),
        foregroundColor: Colors.white,
      ),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return GestureDetector(
                  onTap: () {
                    // ไปยังหน้า ProductDetail และส่งข้อมูลสินค้าไป
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetail(product: product),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'] ?? 'ไม่มีชื่อสินค้า',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'รายละเอียด: ${product['description'] ?? 'ไม่มีรายละเอียด'}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ราคา: ${product['price']} บาท',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'วันที่ผลิต: ${formatDate(product['productionDate'] ?? '')}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
