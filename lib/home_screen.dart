import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allData = [];

  bool _isLoading = true;

  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _addData() async {
    final title = _titleController.text;
    final desc = _descController.text;

    if (title.isEmpty) {
      return;
    }

    await SQLHelper.createData(title, desc);

    _titleController.clear();
    _descController.clear();

    _refreshData();
  }

  Future<void> _updateData(int id) async {
    final title = _titleController.text;
    final desc = _descController.text;

    if (title.isEmpty) {
      return;
    }

    await SQLHelper.updateData(id, title, desc);

    _titleController.clear();
    _descController.clear();

    _refreshData();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // showBottomSheet

  void showBottomSheet(int? id) async {
    if (id != null) {
      final data = await SQLHelper.getSingleData(id);
      _titleController.text = data[0]['title'];
      _descController.text = data[0]['desc'];
    }

    // ignore: use_build_context_synchronously
    showModalBottomSheet(
        elevation: 5,
        isScrollControlled: true,
        context: context,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  top: 30,
                  left: 15,
                  right: 15,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), hintText: "Title"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), hintText: "Description"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        _addData();
                      } else {
                        _updateData(id);
                      }

                      _titleController.clear();
                      _descController.clear();

                      Navigator.of(context).pop();
                    },
                    child: Text(
                      id == null ? "Add" : "Update",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEAF4),
      appBar: AppBar(
        title: const Text('CRUD Operations'),
      ),
      // ignore: prefer_const_constructors
      body: _isLoading
          // ignore: prefer_const_constructors
          ? Center(
              child: const CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _allData.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.all(15),
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      _allData[index]['title'],
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  subtitle: Text(_allData[index]['desc']),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      onPressed: () {
                        showBottomSheet(_allData[index]['id']);
                      },
                      icon: const Icon(Icons.edit, color: Colors.blue),
                    ),
                    IconButton(
                      onPressed: () async {
                        await SQLHelper.deleteData(_allData[index]['id']);
                        _refreshData();
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ]),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() => showBottomSheet(null)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
