import 'package:eschool_teacher/data/models/studyMaterial.dart';
import 'package:eschool_teacher/utils/constants.dart';

class Lesson {
  Lesson(
      {required this.id,
      required this.name,
      required this.description,
      required this.classSectionId,
      required this.subjectId,
      required this.studyMaterials,
      required this.topicsCount,});
  late final int id;
  late final List<StudyMaterial> studyMaterials;

  late final String name;
  late final String description;
  late final int classSectionId;
  late final int subjectId;
  late final int topicsCount;

  Lesson.fromJson(Map<String, dynamic> json) {
    logger.i(json);
    id = json['id'] ?? 0;
    name = json['name'] ?? "";
    topicsCount =int.parse(( json['topic_count'] ?? 0).toString());
    description = json['description'] ?? "";
    classSectionId = int.parse((json['class_section_id'] ?? 0).toString());
    subjectId =int.parse(( json['subject_id'] ?? 0).toString());
    studyMaterials =
        ((json['file'] ?? []) as List)
        .map((file) => StudyMaterial.fromJson(Map.from(file)))
        .toList();
  }
}
