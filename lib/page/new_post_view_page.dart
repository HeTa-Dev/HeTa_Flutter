import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;

import '../config/web_config.dart';
import '../entity/post_view.dart';
import '../provider/user_provider.dart';

// 入口在主页面右下方的一个Icon(Icons.border_color)
// 只有上述用户的界面里面才有这个Icon
class NewPostViewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewPostViewPage();
  }
}

class _NewPostViewPage extends State<NewPostViewPage> {
  List<File> _images = []; // 用于保存选中的图片
  final picker = ImagePicker();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _textController = TextEditingController();

  bool _isLoading = false; // 方便显示加载中图标

  // 这是用来从手机相册中选择图片，目前一次只能添加一张
  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File compressedImage = await compressToWebP(File(pickedFile.path));
      setState(() {
        _images.add(compressedImage);
      });
    } else {
      print('No image selected.');
    }
  }

  Future<File> compressToWebP(File file) async {
    final outputFilePath = file.absolute.path + "_compressed.webp";
    final XFile? compressedImage =
    await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outputFilePath,
      format: CompressFormat.webp,
      quality: 50,
    );

    if (compressedImage != null) {
      return File(compressedImage.path);
    } else {
      throw Exception("Image compression failed.");
    }
  }

  // 上传图片到OSS服务器中，返回路径
  Future<String?> _uploadImage(File _image) async {
    final uri = Uri.parse(
        "http://" + WebConfig.SERVER_HOST_ADDRESS + ":8080/heta/oss/upload");
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', _image.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var newImagePath = await response.stream.bytesToString();
      return newImagePath;
    } else {
      return null;
    }
  }

  Future<void> _addNewPostView() async {
    setState(() {
      _isLoading = true; //显示加载图标
    });

    List<String> imagePath = [];
    for (int i = 0; i < _images.length; i++) {
      File _image = _images[i];
      String? uploadedImagePath = await _uploadImage(_image);
      if (uploadedImagePath != null) {
        imagePath.add(uploadedImagePath); // 将路径添加到列表中
      }
    }

    // 获取封面图片的尺寸
    final imageBytes = await _images[0].readAsBytes();
    final decodedImage = img.decodeImage(imageBytes);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    PostView postView = PostView(
        userName: user!.username,
        userId: user.id ?? 0,
        title: _titleController.text,
        text: _textController.text,
        coverImagePath: imagePath[0],
        imagePathList: imagePath,
        coverWidth: decodedImage?.width,
        coverHeight: decodedImage?.height,
    );

    final response1 = await http.post(
        Uri.parse("http://" +
            WebConfig.SERVER_HOST_ADDRESS +
            ":8080/heta/postView/addNewPostView"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(postView.toJson()));

    setState(() {
      _isLoading = false; //上传完成，隐藏加载图标
    });

    if (response1.statusCode == 200) {
      // 显示对话框
      showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 1), () {
            // 延迟1秒后关闭对话框并返回上一层页面
            Navigator.of(context).pop(); // 关闭对话框
            Navigator.of(context).pop(true); // 返回上一层页面并传递刷新标识
          });
          return AlertDialog(
            content: Text("发布成功！"),
          );
        },
      );
    }else {
      showDialog(
          context: context,
          builder: (context) {
            Future.delayed(Duration(seconds: 1), () {
              Navigator.of(context).pop(true);
            });
            return AlertDialog(
              content: Text('''发布失败！
                               错误码：${response1.statusCode}'''),
            );
          });
    }
  }

  // 删除图片
  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // 显示图片预览，也就是点击图片可以查看放大的图片，同时放大过的图片也可以用手指再次缩放
  void _showImagePreview(File image) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: InteractiveViewer(
              child: Image.file(
                image,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    print(deviceWidth);
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 120, // 设置高度确保 ListView 可以显示完整的图片
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal, // 横向滚动
                      itemCount: _images.length + 1, // 加 1 是为了显示 add 按钮
                      itemBuilder: (context, index) {
                        if (index == _images.length) {
                          return InkWell(
                            onTap: () {
                              pickImage();
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => _showImagePreview(_images[index]),
                                  child: ClipRRect(
                                    child: Image.file(
                                      _images[index],
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.white),
                                    onPressed: () => _deleteImage(index),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "填写标题...",
                    ),
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "添加正文...",
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    minLines: 5,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _addNewPostView();
                        },
                        child: Text("             发布             "),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
