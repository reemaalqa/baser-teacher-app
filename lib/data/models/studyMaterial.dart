enum StudyMaterialType { file, youtubeVideo, uploadedVideoUrl, other }

StudyMaterialType getStudyMaterialType(int type) {
  if (type == 1) {
    return StudyMaterialType.file;
  }
  if (type == 2) {
    return StudyMaterialType.youtubeVideo;
  }
  if (type == 3) {
    return StudyMaterialType.uploadedVideoUrl;
  }

  return StudyMaterialType.other;
}

class StudyMaterial {
  late final StudyMaterialType studyMaterialType;

  late final int id;
  late final String fileName;
  late final String fileThumbnail;
  late final String fileUrl;
  late final String fileExtension;

  StudyMaterial.fromJson(Map<String, dynamic> json) {
    studyMaterialType = getStudyMaterialType(int.parse((json['type'] ?? "0").toString()));

    id = json['id'] ?? 0;
    fileName = json['file_name'] ?? "";
    fileThumbnail = json['file_thumbnail'] ?? "";
    fileUrl = json['file_url'] ?? "";
    fileExtension = json['file_extension'] ?? "";
  }
  StudyMaterial.fromURL(String url) {
    fileUrl = url;
    fileExtension = url.split('.').last.toString();
    studyMaterialType = StudyMaterialType.file;
    id = 0;
    fileName = url.split("/").last.toString();
    fileThumbnail = '';
  }
}
