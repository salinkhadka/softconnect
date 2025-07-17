// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:softconnect/features/home/domain/entity/comment_entity.dart';
// import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_view_model.dart';
// // import 'package:softconnect/features/home/presentation/view_model/comment_view_model.dart';

// class CommentDisplay extends StatelessWidget {
//   final String postId;

//   const CommentDisplay({super.key, required this.postId});

//   @override
//   Widget build(BuildContext context) {
//     final commentViewModel = context.read<CommentViewModel>();

//     return FutureBuilder(
//       future: commentViewModel.getCommentsByPostId(postId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError || !snapshot.hasData) {
//           return const Center(child: Text("Error fetching comments"));
//         }

//         final comments = snapshot.data!;

//         return ListView.builder(
//           shrinkWrap: true,
//           itemCount: comments.length,
//           itemBuilder: (context, index) {
//             CommentEntity comment = comments[index];
//             return ListTile(
//               title: Text(comment.content),
//               subtitle: Text("by ${comment.userId} • ${comment.createdAt.toLocal()}"),
//               trailing: IconButton(
//                 icon: const Icon(Icons.delete),
//                 onPressed: () {
//                   commentViewModel.deleteComment(comment.id);
//                 },
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
