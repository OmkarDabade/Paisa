import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject with EquatableMixin {
  @HiveField(0)
  String name;

  @HiveField(1)
  String description;

  @HiveField(2)
  int icon;

  @HiveField(4, defaultValue: 0)
  int? superId;

  @HiveField(6, defaultValue: 0)
  double? budget;

  Category({
    required this.description,
    required this.name,
    this.icon = -1,
    this.budget = -1,
  });

  @override
  List<Object?> get props => [name, icon, description];

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        name: json["name"],
        description: json["description"],
        icon: json["icon"],
        budget: json["budget"],
      )..superId = json["superId"];

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'icon': icon,
        'superId': superId,
        'budget': budget,
      };
}
