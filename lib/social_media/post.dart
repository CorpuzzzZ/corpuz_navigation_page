import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String? id;
  final String username;
  final String caption;
  final String imageUrl;
  final List<String> likes;
  final List<String> comments;
  final DateTime? timestamp;

  const Post({
    this.id,
    required this.username,
    required this.caption,
    required this.imageUrl,
    this.likes = const [],
    this.comments = const [],
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'caption': caption,
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments,
      'timestamp': timestamp != null
          ? Timestamp.fromDate(timestamp!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['timestamp'] as Timestamp?;
    final rawLikes = data['likes'] as List<dynamic>? ?? [];
    final rawComments = data['comments'] as List<dynamic>? ?? [];

    return Post(
      id: doc.id,
      username: data['username'] as String? ?? '',
      caption: data['caption'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      likes: rawLikes.map((e) => e.toString()).toList(),
      comments: rawComments.map((e) => e.toString()).toList(),
      timestamp: ts?.toDate(),
    );
  }
}
