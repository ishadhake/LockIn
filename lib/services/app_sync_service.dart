import 'package:device_apps/device_apps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppSyncService {
  /// Uploads all user-installed app packages and names to Firestore under current user's UID.
  static Future<void> uploadInstalledApps() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: false,
      includeSystemApps: false,
    );
    final appList = apps
        .map((app) => {'package': app.packageName, 'name': app.appName})
        .toList();

    final batch = FirebaseFirestore.instance.batch();
    final appsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('installedApps');
    final snapshots = await appsCollection.get();
    for (final doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    for (final app in appList) {
      final docRef = appsCollection.doc(app['package']);
      batch.set(docRef, {'name': app['name']});
    }
    await batch.commit();
  }

  /// Returns a stream of app info maps for a given childUid
  static Stream<List<Map<String, String>>> getChildApps(String childUid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(childUid)
        .collection('installedApps')
        .snapshots()
        .map(
          (query) => query.docs
              .map((doc) => {'package': doc.id, 'name': doc['name'] as String})
              .toList(),
        );
  }
}
