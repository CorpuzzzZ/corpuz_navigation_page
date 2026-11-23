import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import 'create_post_sheet.dart';
import 'post.dart';
import 'post_card.dart';

class SocialMediaPage extends StatefulWidget {
  final String username;

  const SocialMediaPage({super.key, required this.username});

  @override
  State<SocialMediaPage> createState() => _SocialMediaPageState();
}

class _SocialMediaPageState extends State<SocialMediaPage> {
  final FirestoreService _firestoreService = FirestoreService.instance;
  final List<Post> _localFallbackPosts = [
    const Post(
      username: 'JohnDoe',
      caption: 'Enjoying the sunny weather!',
      imageUrl: 'https://picsum.photos/id/20/600/400',
    ),
    const Post(
      username: 'JaneSmith',
      caption: 'Just finished a great book!',
      imageUrl: 'https://picsum.photos/id/24/600/400',
    ),
  ];

  Future<void> openCreatePostSheet() async {
    final Post? newPost = await showModalBottomSheet<Post>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return CreatePostSheet(username: widget.username);
      },
    );

    if (!mounted || newPost == null) {
      return;
    }

    try {
      if (_firestoreService.isFirebaseAvailable) {
        await _firestoreService.addPost(newPost);
      } else {
        setState(() {
          _localFallbackPosts.insert(0, newPost);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Firebase not yet connected. Post saved locally!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving post: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Media'),
        actions: [
          if (!_firestoreService.isFirebaseAvailable)
            Tooltip(
              message: 'Firebase awaiting google-services.json',
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(Icons.cloud_off, color: Colors.amber.shade700),
              ),
            ),
        ],
      ),
      body: StreamBuilder<List<Post>>(
        stream: _firestoreService.getPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.hasData && snapshot.data!.isNotEmpty
              ? snapshot.data!
              : _localFallbackPosts;

          if (posts.isEmpty) {
            return const Center(child: Text('No posts yet. Create one!'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                key: ObjectKey(post.id ?? '${post.username}_$index'),
                post: post,
                currentUsername: widget.username,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openCreatePostSheet,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        tooltip: 'Create Post',
        child: const Icon(Icons.add),
      ),
    );
  }
}
