import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import 'post.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final String currentUsername;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUsername,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final TextEditingController commentController = TextEditingController();
  final List<String> _localComments = [];
  bool _localLiked = false;

  @override
  void initState() {
    super.initState();
    _localComments.addAll(widget.post.comments);
    _localLiked = widget.post.likes.contains(widget.currentUsername);
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.post.id != null) {
      _localLiked = widget.post.likes.contains(widget.currentUsername);
    }
  }

  void likePost() {
    if (widget.post.id != null) {
      FirestoreService.instance.toggleLike(widget.post.id!, widget.currentUsername);
    } else {
      setState(() {
        _localLiked = !_localLiked;
      });
    }
  }

  void addComment() {
    final String comment = commentController.text.trim();
    if (comment.isEmpty) return;

    final formattedComment = '${widget.currentUsername}: $comment';

    if (widget.post.id != null) {
      FirestoreService.instance.addComment(widget.post.id!, formattedComment);
    } else {
      setState(() {
        _localComments.add(formattedComment);
      });
    }

    commentController.clear();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.post.username.trim();
    final isLiked = widget.post.id != null
        ? widget.post.likes.contains(widget.currentUsername)
        : _localLiked;
    final commentsList = widget.post.id != null
        ? widget.post.comments
        : _localComments;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(
                username.isEmpty ? '?' : username[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Student Feed'),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              widget.post.caption,
              style: const TextStyle(fontSize: 16),
            ),
          ),

          Image.network(
            widget.post.imageUrl,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                height: 220,
                child: Center(
                  child: Icon(Icons.broken_image, size: 70, color: Colors.grey),
                ),
              );
            },
          ),

          Row(
            children: [
              TextButton.icon(
                onPressed: likePost,
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : null,
                ),
                label: Text(isLiked ? 'Liked' : 'Like'),
              ),
              const SizedBox(width: 8),
              if (widget.post.likes.isNotEmpty)
                Text(
                  '${widget.post.likes.length} ${widget.post.likes.length == 1 ? 'like' : 'likes'}',
                  style: const TextStyle(color: Colors.grey),
                ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text('${commentsList.length} Comments'),
              ),
            ],
          ),

          for (final String comment in commentsList)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(comment),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => addComment(),
                  ),
                ),
                IconButton(
                  onPressed: addComment,
                  icon: const Icon(Icons.send),
                  color: Colors.green,
                  tooltip: 'Send comment',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
