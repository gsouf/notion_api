import 'package:notion_api/notion/general/base_properties.dart';
import 'package:notion_api/notion/general/property.dart';
import 'package:notion_api/notion/general/rich_text.dart';
import 'package:notion_api/notion/general/types/notion_types.dart';
import 'package:notion_api/utils/utils.dart';

/// A representation of the Databse Notion object.
class Database extends BaseProperties {
  /// The type of this object. Always Database for this.
  @override
  ObjectTypes object = ObjectTypes.Database;

  /// The title of this database.
  List<Text> title = <Text>[];

  /// The properties of this database.
  Properties properties = Properties();

  /// Main database constructor.
  ///
  /// Can receive the [title], the [createdTime], the [lastEditedTime] and the database [id].
  Database({
    this.title: const <Text>[],
    String createdTime: '',
    String lastEditedTime: '',
    String id: '',
  }) {
    this.id = id;
    this.setBaseProperties(
      createdTime: createdTime,
      lastEditedTime: lastEditedTime,
    );
  }

  /// Map a new database instance from a [json] map.
  factory Database.fromJson(Map<String, dynamic> json) => Database(
        id: json['id'] ?? '',
        title: Text.fromListJson(json['title'] ?? []),
        createdTime: json['created_time'] ?? '',
        lastEditedTime: json['last_edited_time'] ?? '',
      ).addPropertiesFromJson(json['properties'] ?? {});

  /// Add a new database [property] with an specific [name].
  ///
  /// Example:
  /// ```dart
  /// // For the title of a database
  /// this.add(
  ///   name: 'title',
  ///   property: TitleProp(content: [
  ///     Text('Title'),
  ///   ]),
  /// );
  /// ```
  Database addProperty({required String name, required Property property}) {
    this.properties.add(name: name, property: property);
    return this;
  }

  /// Add a group of properties from a [json] map and return this instance.
  Database addPropertiesFromJson(Map<String, dynamic> json) {
    this.properties.addAllFromJson(json);
    return this;
  }

  /// Convert this to a valid json representation for the Notion API.
  Map<String, dynamic> toJson() => {
        'object': NotionUtils.objectTypeToString(this.object),
        'title': title.map((e) => e.toJson()).toList(),
        'properties': properties.toJson(),
      };
}
