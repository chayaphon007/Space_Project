import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/research_data.dart';
import '../providers/research_provider.dart';
import 'package:permission_handler/permission_handler.dart'; // ✅ เพิ่มการขอสิทธิ์เข้าถึงรูปภาพ

class FormScreen extends StatefulWidget {
  final ResearchData? data;
  final String category;

  const FormScreen({super.key, this.data, required this.category});

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _inventorController;
  late TextEditingController _dateController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.data?.title ?? "");
    _descriptionController = TextEditingController(
      text: widget.data?.description ?? "",
    );
    _inventorController = TextEditingController(
      text: widget.data?.inventor ?? "",
    );

    // ✅ ถ้าไม่มีวันที่ ให้ใช้วันที่ปัจจุบัน
    _dateController = TextEditingController(
      text:
          widget.data?.date.isNotEmpty == true
              ? widget.data!.date
              : DateTime.now().toLocal().toString().split(' ')[0],
    );

    if (widget.data?.imagePath != null && widget.data!.imagePath!.isNotEmpty) {
      setState(() {
        _imageFile = File(widget.data!.imagePath!);
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text =
            pickedDate.toLocal().toString().split(' ')[0]; // ✅ แสดงเฉพาะวันที่
      });
    }
  }

  // ✅ ขอสิทธิ์เข้าถึงรูปภาพ (ใช้สำหรับ Android 13+)
  Future<void> _requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      return;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ต้องอนุญาตให้เข้าถึงไฟล์เพื่อเพิ่มรูปภาพ")),
      );
    }
  }

  // ✅ ฟังก์ชันเลือกรูปภาพ
  Future<void> _pickImage() async {
    await _requestPermission(); // ขอสิทธิ์ก่อน
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // ✅ ฟังก์ชันบันทึกข้อมูล
  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return; // ✅ ตรวจสอบว่ากรอกข้อมูลครบทุกช่อง
    }

    if (_dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("กรุณาเลือกวันที่ก่อนบันทึกข้อมูล")),
      );
      return;
    }

    final data = ResearchData(
      id: widget.data?.id,
      category: widget.category,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      inventor: _inventorController.text.trim(),
      imagePath: _imageFile?.path ?? "",
      date: _dateController.text,
    );

    print("✅ บันทึกข้อมูล: ${data.title}, วันที่: ${data.date}");

    final provider = Provider.of<ResearchProvider>(context, listen: false);

    if (widget.data == null) {
      await provider.addData(data);
    } else {
      await provider.updateData(data);
    }

    if (mounted) {
      provider.notifyListeners(); // ✅ อัปเดต UI
      Navigator.pop(context); // ✅ ป้องกัน `BuildContext across async gaps`
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data == null ? 'เพิ่มข้อมูล' : 'แก้ไขข้อมูล'),
        
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ✅ แสดงตัวอย่างรูปภาพ ถ้ามี
              _imageFile != null
                  ? Image.file(_imageFile!, height: 150)
                  : Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        "ไม่มีภาพ",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),

              TextButton.icon(
                icon: Icon(Icons.image),
                label: Text("เลือกรูปภาพ"),
                onPressed: _pickImage,
              ),

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'หัวข้อ',
                  border: OutlineInputBorder(), // ✅ ทำให้ขอบฟอร์มดูดีขึ้น
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "กรุณากรอกหัวข้อ"; // ✅ แจ้งเตือนถ้าไม่ได้กรอก
                  }
                  return null;
                },
              ),
              SizedBox(height: 10), // ✅ เพิ่มระยะห่างระหว่างฟิลด์

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'รายละเอียด',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "กรุณากรอกรายละเอียด";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: _inventorController,
                decoration: InputDecoration(
                  labelText: 'ผู้คิดค้น',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "กรุณากรอกชื่อผู้คิดค้น";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'วันที่เริ่มต้นโครงการ',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    color: Colors.deepPurple,
                  ),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาเลือกวันที่";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              ElevatedButton(onPressed: _submit, child: Text('บันทึก')),
            ],
          ),
        ),
      ),
    );
  }
}
