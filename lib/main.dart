import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey,
        ),
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController controller;
  String name = '';
  List<dynamic> arrName = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
    controller = TextEditingController();
  }

  void fetchUsers() async {
    const url = "https://jsonplaceholder.typicode.com/photos?_limit=5";
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final List<dynamic> body = json.decode(response.body);
    setState(() {
      arrName = body;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Image.asset(
              "assets/images/projectpic.jpeg",
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 350,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    final dynamic comment = arrName[index];
                    final thumbnailUrl = comment['thumbnailUrl'] ?? '';
                    final title = comment['title'].toString();
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          thumbnailUrl,
                        ),
                      ),
                      title: Text(title),
                      trailing: Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () async {
                              final name = await openDialog();
                              if (name == null || name.isEmpty) return;

                              setState(() => this.name = name);
                              addComment(
                                'https://www.google.com/s2/favicons?sz=64&domain_url=yahoo.com',
                              );
                            },
                          )
                        ],
                      ),
                    );
                  },
                  itemCount: arrName.length,
                  separatorBuilder: (context, index) {
                    return Divider(height: 10, thickness: 1);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "Add Card",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.newspaper,
              color: Colors.blue,
            ),
            label: "News",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: Colors.blue,
            ),
            label: "Profile",
          ),
        ],
        selectedLabelStyle:
            const TextStyle(color: Colors.blue), // Set color for selected label
        unselectedLabelStyle:
            TextStyle(color: Colors.black), // Set color for unselected label
      ),
    );
  }

  Future<String?> openDialog() {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Type Below"),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: "Comment"),
          controller: controller,
          onSubmitted: (_) => submit(),
        ),
        actions: [
          TextButton(
            child: Text("Add"),
            onPressed: submit,
          ),
        ],
      ),
    );
  }

  void submit() {
    final text = controller.text;

    if (text.isNotEmpty) {
      addComment(text); // Add the comment
    }

    Navigator.of(context).pop(controller.text);
    controller.clear();

    final snackBar = SnackBar(
      content: Row(
        children: [
          const Text('New comment was added!'),
          const SizedBox(width: 5),
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.check_box,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void addComment(String comment) async {
    const apiUrl = "https://jsonplaceholder.typicode.com/photos";
    final uri = Uri.parse(apiUrl);

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'title': comment,
          'thumbnailUrl':
              'https://www.google.com/s2/favicons?sz=64&domain_url=yahoo.com',
          'url': 'https://yahoo.com',
        }),
      );

      if (response.statusCode == 201) {
        final addedComment = json.decode(response.body);
        setState(() {
          arrName.add(addedComment);
        });
      } else {
        print("Failed to add comment. Error: ${response.statusCode}");
      }
    } catch (exception) {
      print("Exception occurred while adding comment: $exception");
    }
  }
}
