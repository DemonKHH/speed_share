import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:speed_share/app/routes/app_pages.dart';
import 'package:speed_share/config/config.dart';

class JoinChat extends StatefulWidget {
  const JoinChat({Key key}) : super(key: key);

  @override
  _JoinChatState createState() => _JoinChatState();
}

class _JoinChatState extends State<JoinChat> {
  TextEditingController controller = TextEditingController(
    text: '',
  );
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 180,
          width: 260,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '请输入文件共享窗口地址',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.w,
                  ),
                ),
                SizedBox(
                  height: 8.w,
                ),
                TextField(
                  controller: controller,
                  onSubmitted: (_) {
                    joinChat();
                  },
                  decoration: InputDecoration(
                    fillColor: const Color(0xfff0f0f0),
                    helperText: '这个地址在创建窗口的时候会提示',
                    hintText: '请输入共享窗口的URL',
                    hintStyle: TextStyle(
                      fontSize: 12.w,
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.w,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      joinChat();
                    },
                    child: const Text(
                      '加入',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void joinChat() {
    if (controller.text.isEmpty) {
      showToast('URL不能为空');
      return;
    }
    String url = controller.text;
    if (!url.startsWith('http://')) {
      url = 'http://' + url;
    }
    if (!url.endsWith(':${Config.chatPortRangeStart}')) {
      url = url + ':${Config.chatPortRangeStart}';
    }
    Get.back();
    Get.toNamed(
      '${Routes.chat}?needCreateChatServer=false&chatServerAddress=$url',
    );
  }
}
