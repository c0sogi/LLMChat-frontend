import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_web/viewmodel/chat/theme_viewmodel.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_web/viewmodel/chat/chat_viewmodel.dart';
import 'package:get/get.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_config.dart';

class ChatMessagePlaceholder extends StatelessWidget {
  final int index;
  const ChatMessagePlaceholder({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final ChatViewModel chatViewModel = Get.find<ChatViewModel>();
    final bool isGptSpeaking =
        chatViewModel.messagePlaceholder[index].isGptSpeaking;
    return Container(
      alignment: isGptSpeaking ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment:
            isGptSpeaking ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isGptSpeaking
                  ? ThemeViewModel.idleColor
                  : ThemeViewModel.activeColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: isGptSpeaking
                    ? const Radius.circular(0)
                    : const Radius.circular(12),
                bottomRight: isGptSpeaking
                    ? const Radius.circular(12)
                    : const Radius.circular(0),
              ),
            ),
            child: MarkdownWidget(
              text: chatViewModel.messagePlaceholder[index].message.value,
            ),
          )
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final int index;
  const ChatMessage({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChatViewModel chatViewModel = Get.find<ChatViewModel>();
    final bool isGptSpeaking = chatViewModel.messages![index].isGptSpeaking;

    return GestureDetector(
      onLongPress: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copied to clipboard'),
          ),
        );
        Clipboard.setData(
            ClipboardData(text: chatViewModel.messages![index].message.value));
      },
      child: Container(
        alignment: isGptSpeaking ? Alignment.centerLeft : Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isGptSpeaking ? Colors.grey[600] : Colors.blue[600],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isGptSpeaking
                  ? const Radius.circular(0)
                  : const Radius.circular(12),
              bottomRight: isGptSpeaking
                  ? const Radius.circular(12)
                  : const Radius.circular(0),
            ),
          ),
          child: Obx(() {
            SchedulerBinding.instance
                .addPostFrameCallback(chatViewModel.scrollToBottomCallback);
            if (chatViewModel.messages![index].isLoading.value) {
              return Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.3,
                ),
                child: const Center(
                  child: LinearProgressIndicator(),
                ),
              );
            }
            return MarkdownWidget(
              text: chatViewModel.messages![index].message.value,
            );
          }),
        ),
      ),
    );
  }
}

// class ChatMessage extends StatefulWidget {
//   final int index;
//   const ChatMessage({
//     Key? key,
//     required this.index,
//   }) : super(key: key);

//   @override
//   State<ChatMessage> createState() => _ChatMessageState();
// }

// class _ChatMessageState extends State<ChatMessage>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ChatViewModel chatViewModel = Get.find<ChatViewModel>();
//     final bool isGptSpeaking =
//         chatViewModel.messages![widget.index].isGptSpeaking;

//     return GestureDetector(
//       onLongPress: () {
//         copyToClipboard(
//           context,
//           chatViewModel.messages![widget.index].message.value,
//         );
//       },
//       child: Container(
//         alignment: isGptSpeaking ? Alignment.centerLeft : Alignment.centerRight,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         child: SlideTransition(
//           position: _slideAnimation,
//           child: Container(
//             constraints: BoxConstraints(
//               maxWidth: MediaQuery.of(context).size.width * 0.7,
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               color: isGptSpeaking ? Colors.grey[600] : Colors.blue[600],
//               borderRadius: BorderRadius.only(
//                 topLeft: const Radius.circular(12),
//                 topRight: const Radius.circular(12),
//                 bottomLeft: isGptSpeaking
//                     ? const Radius.circular(0)
//                     : const Radius.circular(12),
//                 bottomRight: isGptSpeaking
//                     ? const Radius.circular(12)
//                     : const Radius.circular(0),
//               ),
//             ),
//             child: Obx(() {
//               SchedulerBinding.instance
//                   .addPostFrameCallback(chatViewModel.scrollToBottomCallback);
//               if (chatViewModel.messages![widget.index].isLoading.value) {
//                 return Container(
//                   constraints: BoxConstraints(
//                     maxWidth: MediaQuery.of(context).size.width * 0.3,
//                   ),
//                   child: const Center(
//                     child: LinearProgressIndicator(),
//                   ),
//                 );
//               }
//               return MarkdownWidget(
//                   text: chatViewModel.messages![widget.index].message.value);
//             }),
//           ),
//         ),
//       ),
//     );
//   }
// }

class MarkdownWidget extends StatelessWidget {
  final String text;
  const MarkdownWidget({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      selectable: false,
      fitContent: true,
      data: text,
      builders: {'pre': CodeblockBuilder()},
      extensionSet: md.ExtensionSet.gitHubWeb,
      styleSheet: MarkdownStyleSheet(
        codeblockPadding: const EdgeInsets.symmetric(horizontal: 8),
        codeblockDecoration: BoxDecoration(
          color: Colors.blueGrey[800],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
      ),
    );
  }
}

class CodeblockBuilder extends MarkdownElementBuilder {
  String? language;

  @override
  void visitElementBefore(md.Element element) {
    language = null;
    element.children?.whereType<md.Element>().forEach((e) {
      final String? className =
          e.attributes['class']?.replaceFirst("language-", "");
      if (className != null && Config.supportedLanguages.contains(className)) {
        language = className;
      }
    });
  }

  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CodeblockHeader(language: language, text: text),
        CodeblockBody(text: text, language: language),
      ],
    );
  }
}

class CodeblockHeader extends StatelessWidget {
  const CodeblockHeader({
    super.key,
    required this.language,
    required this.text,
  });

  final String? language;
  final md.Text text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(language ?? "", style: const TextStyle(color: Colors.white)),
          Row(
            children: [
              const Icon(Icons.content_copy, size: 18),
              TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                      ),
                    );
                    Clipboard.setData(ClipboardData(text: text.textContent));
                  },
                  child:
                      const Text('복사', style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
      ),
    );
  }
}

class CodeblockBody extends StatelessWidget {
  const CodeblockBody({
    super.key,
    required this.text,
    required this.language,
  });

  final md.Text text;
  final String? language;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:
          MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
      child: HighlightView(
        text.textContent,
        language: language ?? "plaintext",
        theme: atomOneDarkTheme,
        padding: const EdgeInsets.all(8),
        textStyle: GoogleFonts.robotoMono(),
      ),
    );
  }
}
