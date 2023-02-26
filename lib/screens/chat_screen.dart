import 'package:chatgpt/core/app_theme.dart';
import 'package:chatgpt/models/chat_model.dart';
import 'package:chatgpt/repositories/chat_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputCtrl = TextEditingController();
  final _inputFN = FocusNode();
  final _repository = ChatRepository(Dio());
  final _messages = <ChatModel>[];
  final _scrollCtrl = ScrollController();

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          "ChatGPT - Flutter",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SizedBox.expand(
        child: Container(
          padding: const EdgeInsets.all(10),
          color: AppTheme.primaryColor,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  itemCount: _messages.length,
                  itemBuilder: (_, int index) {
                    return Row(
                      children: [
                        if (_messages[index].messageFrom == MessageFrom.me)
                          const Spacer(),
                        Container(
                          margin: const EdgeInsets.all(12),
                          width: MediaQuery.of(context).size.width * 0.7,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _messages[index].message,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              TextField(
                focusNode: _inputFN,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                maxLines: 4,
                minLines: 1,
                controller: _inputCtrl,
                decoration: InputDecoration(
                  hintText: "Digite aqui ...",
                  hintStyle: const TextStyle(
                    color: Colors.white,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.secondaryColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fillColor: AppTheme.secondaryColor,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.secondaryColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  suffixIcon: IconButton(
                    onPressed: () async {
                      _inputFN.unfocus();
                      if (_inputCtrl.text.isNotEmpty) {
                        final prompt = _inputCtrl.text;

                        setState(() {
                          _messages.add(ChatModel(
                            message: prompt,
                            messageFrom: MessageFrom.me,
                          ));

                          _inputCtrl.text = '';

                          _scrollDown();
                        });

                        final chatResponse =
                            await _repository.promptMessage(prompt);

                        setState(() {
                          _messages.add(
                            ChatModel(
                              message: chatResponse,
                              messageFrom: MessageFrom.bot,
                            ),
                          );
                          _scrollDown();
                        });
                      }
                    },
                    icon: const Icon(Icons.send, color: Colors.white,),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
