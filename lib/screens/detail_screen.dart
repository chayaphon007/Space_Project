import 'dart:io';
import 'package:flutter/material.dart';
import '../models/research_data.dart';

class DetailScreen extends StatelessWidget {
  final ResearchData data;

  const DetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data.title),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.imagePath != null &&
                  data.imagePath!.isNotEmpty &&
                  File(data.imagePath!).existsSync())
                Center(
                  child: Image.file(
                    File(data.imagePath!),
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),

              SizedBox(height: 20),

              Text(
                "รายละเอียด",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(data.description, style: TextStyle(fontSize: 16)),

              SizedBox(height: 20),

              Text(
                "ผู้คิดค้น: ${data.inventor}",
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.blueAccent,
                ),
              ),

              if (data.date.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    "วันที่เริ่มต้นโครงการ: ${data.date}",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
