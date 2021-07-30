abstract class FirebaseMapper<T> {
  T fromFirebase(Map<String, dynamic> map);

  Map<String, dynamic> toFirebase(T object);
}