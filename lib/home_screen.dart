import 'package:flutter/material.dart';
import 'package:todo_list_sqlite/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> allData = [];
  bool isLoading = true;

  void refreshData() async {
    final data = await DBHelper.getAllData();
    setState(() {
      allData = data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  Future<void> addData() async {
    await DBHelper.createData(titleController.text, descController.text);
    refreshData();
  }

  Future<void> updateData(int id) async {
    await DBHelper.updateData(id, titleController.text, descController.text);
    refreshData();
  }

  Future<void> checkData(int id) async {
    await DBHelper.checkData(id);
    refreshData();
  }

  Future<void> unCheckData(int id) async {
    await DBHelper.unCheckData(id);
    refreshData();
  }

  Future<void> deleteData(int id) async {
    await DBHelper.deleteData(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Data deleted successfully!")));
    refreshData();
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData = allData.firstWhere((element) => element["id"] == id);
      titleController.text = existingData['title'];
      descController.text = existingData['desc'];
    }

    showModalBottomSheet(
        elevation: 5,
        isScrollControlled: true,
        context: context,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 30,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 50,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), hintText: "Your Todo..."),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: descController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Description..."),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          if (!mounted) return;
                          if (titleController.text == "") {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    backgroundColor: Colors.redAccent,
                                    content: Text(
                                        "Todo field must be at least 1 characters!")));
                          } else {
                            await addData();
                          }
                        }
                        if (id != null) {
                          if (!mounted) return;
                          if (titleController.text == "") {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    backgroundColor: Colors.redAccent,
                                    content: Text(
                                        "Todo field must be at least 1 characters!")));
                          } else {
                            await updateData(id);
                          }
                        }

                        titleController.text = "";
                        descController.text = "";

                        if (!mounted) return;
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Text(id == null ? "Add Todo" : "Update Todo",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500)),
                      ),
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
          backgroundColor: Colors.purple,
          title: const Text(
            "My Todo",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: allData.length,
                itemBuilder: (context, index) => Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        allData[index]["title"],
                        style: TextStyle(
                            fontSize: 20,
                            decoration: bool.parse(
                                    allData[index]['is_done'].toLowerCase())
                                ? TextDecoration.lineThrough
                                : TextDecoration.none),
                      ),
                    ),
                    leading: IconButton(
                        icon: Icon(
                          bool.parse(allData[index]['is_done'].toLowerCase())
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 25,
                        ),
                        onPressed: () async {
                          !bool.parse(allData[index]['is_done'].toLowerCase())
                              ? await checkData(allData[index]['id'])
                              : await unCheckData(allData[index]['id']);
                        }),
                    subtitle: Text(
                      allData[index]['desc'],
                      style: TextStyle(
                          decoration: bool.parse(
                                  allData[index]['is_done'].toLowerCase())
                              ? TextDecoration.lineThrough
                              : TextDecoration.none),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            showBottomSheet(allData[index]['id']);
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.purple,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            deleteData(allData[index]['id']);
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          hoverColor: Colors.purple[600],
          backgroundColor: Colors.purple,
          onPressed: () => showBottomSheet(null),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ));
  }
}
