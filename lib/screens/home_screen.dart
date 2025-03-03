import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/research_provider.dart';
import 'form_screen.dart';
import 'detail_screen.dart';
import 'space_wave_background.dart';

class HomeScreen extends StatefulWidget {
  final String category;

  const HomeScreen({super.key, required this.category});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = "";
  String _searchType = "ชื่อโครงการ";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<ResearchProvider>(
        context,
        listen: false,
      ).fetchData(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ ปรับ AppBar เป็นไล่สีฟิลอวกาศ
      appBar: AppBar(
        title: Text('โครงการวิจัยอวกาศ', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF3E1E68), // สีม่วง-น้ำเงิน
                Color(0xFF1B1A55), // สีน้ำเงินเข้ม
              ],
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "ค้นหา...",
                    hintStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("ค้นหาจาก: ", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _searchType,
                      dropdownColor: Color(0xFF1B1A55),
                      style: TextStyle(color: Colors.white),
                      items:
                          ["ชื่อโครงการ", "ผู้คิดค้น"].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _searchType = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ✅ เพิ่มพื้นหลังคลื่นน้ำอวกาศ
          SpaceWaveBackground(),

          Consumer<ResearchProvider>(
            builder: (context, provider, child) {
              final filteredData =
                  provider.data.where((item) {
                    if (_searchType == "ชื่อโครงการ") {
                      return item.title.toLowerCase().contains(_searchQuery);
                    } else if (_searchType == "ผู้คิดค้น") {
                      return item.inventor.toLowerCase().contains(_searchQuery);
                    }
                    return false;
                  }).toList();

              return filteredData.isEmpty
                  ? Center(
                    child: Text(
                      "ไม่มีข้อมูล",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                  : ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final data = filteredData[index];

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6, // ✅ เพิ่มเงาให้ดูนุ่มนวลขึ้น
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.fromARGB(255, 93, 49, 122).withOpacity(1), // ม่วงเข้ม
                                Color.fromARGB(255, 39, 21, 53).withOpacity(0.6), // ม่วงสว่าง
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailScreen(data: data),
                                ),
                              );
                            },
                            leading:
                                data.imagePath != null &&
                                        data.imagePath!.isNotEmpty &&
                                        File(data.imagePath!).existsSync()
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(data.imagePath!),
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : Icon(
                                      Icons.image,
                                      color: Colors.white54,
                                      size: 60,
                                    ),
                            title: Text(
                              data.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (data.description.trim().isNotEmpty)
                                  Text(
                                    data.description.trim(),
                                    style: TextStyle(color: Colors.white70),
                                      maxLines: 2,
                                  ),
                                if (data.inventor.trim().isNotEmpty)
                                  Text(
                                    "ผู้คิดค้น: ${data.inventor.trim()}",
                                    style: TextStyle(
                                      color: Colors.lightBlueAccent,
                                      fontStyle: FontStyle.italic,
                                      
                                    ),
                                    maxLines: 2,
                                  ),
                                Text(
                                  "วันที่เริ่มต้นโครงการ:${data.date}",
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.white),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => FormScreen(
                                              category: widget.category,
                                              data: data,
                                            ),
                                      ),
                                    ).then((_) {
                                      Provider.of<ResearchProvider>(
                                        context,
                                        listen: false,
                                      ).fetchData(widget.category);
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    provider.deleteData(
                                      data.id!,
                                      widget.category,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FormScreen(category: widget.category),
            ),
          );
        },
        child: Icon(Icons.add, color: const Color.fromARGB(255, 218, 202, 248)),
      ),
    );
  }
}
