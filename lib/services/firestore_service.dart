import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../social_media/post.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._internal();
  FirestoreService._internal();

  bool get isFirebaseAvailable => Firebase.apps.isNotEmpty;

  FirebaseFirestore? get _firestore =>
      isFirebaseAvailable ? FirebaseFirestore.instance : null;

  CollectionReference<Map<String, dynamic>>? get _postsRef =>
      _firestore?.collection('posts');

  Stream<List<Post>> getPostsStream() {
    if (!isFirebaseAvailable || _postsRef == null) {
      return Stream.value(const [
        Post(
          username: 'JohnDoe',
          caption: 'Enjoying the sunny weather!',
          imageUrl: 'https://picsum.photos/id/20/600/400',
        ),
        Post(
          username: 'JaneSmith',
          caption: 'Just finished a great book!',
          imageUrl: 'https://picsum.photos/id/24/600/400',
        ),
      ]);
    }

    return _postsRef!
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    }).handleError((error) {
      debugPrint('Firestore stream error: $error');
      return <Post>[];
    });
  }

  Future<void> addPost(Post post) async {
    if (!isFirebaseAvailable || _postsRef == null) {
      throw Exception('Firebase is not initialized. Please ensure google-services.json is added.');
    }
    await _postsRef!.add(post.toMap());
  }

  Future<void> toggleLike(String postId, String username) async {
    if (!isFirebaseAvailable || _postsRef == null) return;
    final docRef = _postsRef!.doc(postId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data() ?? {};
    final rawLikes = data['likes'] as List<dynamic>? ?? [];
    final likes = rawLikes.map((e) => e.toString()).toList();

    if (likes.contains(username)) {
      likes.remove(username);
    } else {
      likes.add(username);
    }
    await docRef.update({'likes': likes});
  }

  Future<void> addComment(String postId, String comment) async {
    if (!isFirebaseAvailable || _postsRef == null) return;
    final docRef = _postsRef!.doc(postId);
    await docRef.update({
      'comments': FieldValue.arrayUnion([comment]),
    });
  }
}
