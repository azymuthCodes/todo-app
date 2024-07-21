import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

part "main.g.dart";

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ToDoTileAdapter());
  await Hive.openBox('myBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

@HiveType(typeId: 1)
class ToDoTile extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  String title;
  @HiveField(2)
  bool completed;

  ToDoTile(this.id, this.title, this.completed);

  void isCompleted() {
    completed = !completed;
  }
}

class HomePageState extends State<HomePage> {
  final myBox = Hive.box('myBox');
  TextEditingController taskController = TextEditingController();
  List<ToDoTile> tiles = [];
  int maxID = 0;
  bool retrieved = false;
  void _retrieve() async {
    for (var value in myBox.values) {
      tiles.add(value);
    }
  }

  void _maxID() {
    for (var value in myBox.values) {
      if (value.id > maxID) {
        maxID = value.id;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!retrieved && myBox.isNotEmpty) {
      _retrieve();
      _maxID();
    }
    retrieved = true;
    // myBox.clear();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          "To-do",
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 165, 30),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: const Color.fromARGB(255, 255, 165, 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(
                  height: 10,
                ),
                itemCount: tiles.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red[500],
                        child: const Icon(Icons.delete),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        color: const Color.fromARGB(255, 247, 198, 40),
                        width: 400,
                        height: 100,
                        child: CheckboxListTile(
                          title: AnimatedDefaultTextStyle(
                            style: TextStyle(
                                decoration: tiles[index].completed
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                fontSize: 20,
                                color: tiles[index].completed
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.black),
                            duration: const Duration(milliseconds: 500),
                            child: Text(tiles[index].title),
                          ),
                          checkColor: Colors.green,
                          value: tiles[index].completed,
                          onChanged: (value) async {
                            setState(() {
                              tiles[index].isCompleted();
                            });
                            await myBox.put(tiles[index].id, tiles[index]);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      onDismissed: (DismissDirection direction) async {
                        await myBox.delete(tiles[index].id);
                        setState(() {
                          tiles.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    title: const Text("New Task"),
                    backgroundColor: const Color.fromARGB(255, 255, 76, 76),
                    content: Container(
                        padding: const EdgeInsets.all(5),
                        height: 120,
                        child: Column(
                          children: [
                            TextField(
                              controller: taskController,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Enter a new task"),
                            ),
                            MaterialButton(
                              onPressed: () async => {
                                // myBox.put(tiles.length, taskController.text),
                                maxID++,
                                setState(() {
                                  tiles.add(ToDoTile(
                                      maxID, taskController.text, false));
                                }),
                                Navigator.pop(context),
                                taskController.clear(),
                                await myBox.put(maxID, tiles.last),
                              },
                              color: const Color.fromARGB(255, 214, 48, 48),
                              shape: BeveledRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              elevation: 0,
                              child: const Text("ADD"),
                            )
                          ],
                        )),
                  ));
        },
        foregroundColor: const Color.fromARGB(255, 197, 0, 0),
        backgroundColor: const Color.fromARGB(255, 255, 76, 76),
        enableFeedback: false,
        child: const Icon(Icons.add_box_rounded),
      ),
    );
  }
}
