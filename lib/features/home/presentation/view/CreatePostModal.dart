import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:softconnect/features/home/domain/use_case/getPostsUseCase.dart';

// import 'package:softconnect/features/home/domain/usecase/post_usecases.dart';

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
        const SnackBar(content: Text('Please enter some content')),
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
              SnackBar(content: Text('Image upload failed: ${failure.message}')),
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
            SnackBar(content: Text('Failed to create post: ${failure.message}')),
          );
          setState(() {
            _isLoading = false;
          });
        },
        (post) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post created successfully')),
          );
          Navigator.of(context).pop();
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
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
    return AlertDialog(
      title: const Text("Create Post"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'What\'s on your mind?',
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _privacy,
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
            const SizedBox(height: 10),
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 150)
                : const SizedBox(),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Add Image"),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitPost,
          child: const Text("Post"),
        ),
      ],
    );
  }
}
