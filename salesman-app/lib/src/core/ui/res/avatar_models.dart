import 'package:track/src/core/ui/res/app_assets.dart';

class AvatarModel {
  final String id;
  final String path;

  AvatarModel({required this.id, required this.path});
}

class AvatarModels {
  static List<AvatarModel> avatars = [
    AvatarModel(id: 'm1', path: AppAssets.avatarF1),
    AvatarModel(id: 'f1', path: AppAssets.avatarM1),
    AvatarModel(id: 'm2', path: AppAssets.avatarM2),
    AvatarModel(id: 'f2', path: AppAssets.avatarF2),
  ];
}
