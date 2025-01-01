import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Foodie",
    profileImage: "assets/images/chef.jpg",
  );

  final List<String> foodKeywords = [
    "Hello"
        "food",
    "recipe",
    "ingredient",
    "cuisine",
    "restaurant",
    "eat",
    "cook",
    "dinner",
    "lunch",
    "breakfast",
    "christmas"
        "easter"
        "holiday"
        "new year"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/food.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: _buildUI(),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Food Chat App",
        ),
      ),
    );
  }

  Widget _buildUI() {
    return DashChat(
      inputOptions: InputOptions(trailing: [
        IconButton(
          onPressed: _sendMediaMessage,
          icon: const Icon(Icons.image),
        ),
      ]),
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text.toLowerCase();
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }

      // Check for food-related keywords
      if (foodKeywords.any((keyword) => question.contains(keyword))) {
        // Send the query to Gemini if it's food-related
        gemini.streamGenerateContent(question, images: images).listen((event) {
          ChatMessage? lastMessage = messages.firstOrNull;
          if (lastMessage != null && lastMessage.user == geminiUser) {
            lastMessage = messages.removeAt(0);
            String response = event.content?.parts?.fold(
                    "", (previous, current) => "$previous ${current.text}") ??
                "";
            lastMessage.text += response;
            setState(() {
              messages = [lastMessage!, ...messages];
            });
          } else {
            String response = event.content?.parts?.fold(
                    "", (previous, current) => "$previous ${current.text}") ??
                "";
            ChatMessage message = ChatMessage(
              user: geminiUser,
              createdAt: DateTime.now(),
              text: response,
            );
            setState(() {
              messages = [message, ...messages];
            });
          }
        });
      } else {
        // Provide a custom response if not food-related
        setState(() {
          messages = [
            ChatMessage(
                user: geminiUser,
                createdAt: DateTime.now(),
                text:
                    "I'm designed to answer food-related questions. Please try asking me something about food."),
            ...messages
          ];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);

    ChatMessage chatMessage = ChatMessage(
      user: currentUser,
      createdAt: DateTime.now(),
      text: "Describe this food",
      medias: [
        ChatMedia(url: file!.path, fileName: "", type: MediaType.image),
      ],
    );
    _sendMessage(chatMessage);
  }
}
