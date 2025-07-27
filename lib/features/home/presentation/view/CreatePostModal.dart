import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:softconnect/app/theme/colors/themecolor.dart';
import 'package:softconnect/features/home/domain/use_case/getPostsUseCase.dart';

class CreatePostModal extends StatefulWidget {
  final CreatePostUsecase createPostUsecase;
  final UploadImageUsecase uploadImageUsecase;
  final String userId;

  const CreatePostModal({
    super.key,
    required this.createPostUsecase,
    required this.uploadImageUsecase,
    required this.userId,
  });

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final _contentController = TextEditingController();
  String _privacy = 'Public';
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter some content'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        final uploadResult = await widget.uploadImageUsecase
            .call(UploadImageParams(_selectedImage!));
        uploadResult.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image upload failed: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          },
          (url) {
            imageUrl = url;
          },
        );
      }

      final createResult = await widget.createPostUsecase.call(CreatePostParams(
        userId: widget.userId,
        content: _contentController.text.trim(),
        privacy: _privacy,
        imageUrl: imageUrl,
      ));

      createResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create post: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        },
        (post) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Post created successfully'),
              backgroundColor:Color(0xFF37225C),
            ),
          );
          Navigator.of(context).pop(true); 
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return AlertDialog(
      backgroundColor: Themecolor.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Themecolor.lavender.withOpacity(0.3),
          width: 1,
        ),
      ),
      title: Text(
        "Create Post",
        style: TextStyle(
          color: Themecolor.purple,
          fontSize: isTablet ? 22 : 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: isTablet ? 500 : double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _contentController,
                maxLines: isTablet ? 6 : 4,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: Themecolor.purple,
                ),
                decoration: InputDecoration(
                  labelText: 'What\'s on your mind?',
                  labelStyle: TextStyle(
                    color: Themecolor.lavender,
                    fontSize: isTablet ? 16 : 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Themecolor.lavender),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Themecolor.purple, width: 2),
                  ),
                  contentPadding: EdgeInsets.all(isTablet ? 16 : 12),
                ),
              ),
              SizedBox(height: isTablet ? 16 : 10),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Themecolor.lavender),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _privacy,
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: TextStyle(
                    color: Themecolor.purple,
                    fontSize: isTablet ? 16 : 14,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Public', child: Text('Public')),
                    DropdownMenuItem(value: 'Private', child: Text('Private')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _privacy = value;
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: isTablet ? 16 : 10),
              if (_selectedImage != null)
                Container(
                  margin: EdgeInsets.only(bottom: isTablet ? 16 : 10),
                  height: isTablet ? 200 : 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Themecolor.lavender.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Container(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(
                    Icons.image,
                    color: Themecolor.purple,
                    size: isTablet ? 24 : 20,
                  ),
                  label: Text(
                    "Add Image",
                    style: TextStyle(
                      color: Themecolor.purple,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Themecolor.lavender.withOpacity(0.1),
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 16 : 12,
                      horizontal: isTablet ? 20 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Themecolor.lavender.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.only(top: isTablet ? 20 : 16),
                  child: CircularProgressIndicator(color: Themecolor.purple),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Themecolor.lavender,
              fontSize: isTablet ? 16 : 14,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitPost,
          style: ElevatedButton.styleFrom(
            backgroundColor: Themecolor.purple,
            foregroundColor: Themecolor.white,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 20,
              vertical: isTablet ? 14 : 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            "Post",
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
