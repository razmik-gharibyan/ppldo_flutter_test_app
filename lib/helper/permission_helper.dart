import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {

  Future<PermissionStatus> getPermissionStatus() async {
    var contactsPermissionStatus = await Permission.contacts.status;
    if (!contactsPermissionStatus.isGranted || !contactsPermissionStatus.isPermanentlyDenied) {
      contactsPermissionStatus = await Permission.contacts.request();
    }
    return contactsPermissionStatus;
  }

}