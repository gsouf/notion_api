import 'package:notion_api/notion/general/types/notion_types.dart';
import 'package:notion_api/notion/general/rich_text.dart';
import 'package:notion_api/utils/utils.dart';

/// A representation of a single property for any Notion object.
class Property {
  /// The property type.
  final PropertiesTypes type = PropertiesTypes.None;

  /// The property id.
  String? id;

  /// The base getter for the content of any property.
  dynamic get value => false;

  /// The string value for this property type.
  String get strType => propertyTypeToString(type);

  /// Returns true if property is Title type.
  bool get isTitle => type == PropertiesTypes.Title;

  /// Returns true if property is RichText type.
  bool get isRichText => type == PropertiesTypes.RichText;

  /// Returns true if property is MultiSelect type.
  bool get isMultiSelect => type == PropertiesTypes.MultiSelect;

  /// Returns true if property don't have a known type.
  bool get isNone => type == PropertiesTypes.None;

  /// Main property constructor.
  ///
  /// Can receive the property [id].
  Property({this.id});

  /// Constructor for empty property.
  Property.empty();

  /// Convert this to a valid json representation for the Notion API.
  Map<String, dynamic> toJson() {
    if (type == PropertiesTypes.None) {
      throw 'None type for property';
    }

    Map<String, dynamic> json = {'type': strType};

    if (id != null) {
      json['id'] = id;
    }

    return json;
  }

  /// Map a list of properties from a [json] map.
  static Map<String, Property> propertiesFromJson(Map<String, dynamic> json) {
    Map<String, Property> properties = {};
    json.entries.forEach((entry) {
      properties[entry.key] = Property.propertyFromJson(entry.value);
    });
    return properties;
  }

  /// Create a new Property instance from json.
  ///
  /// Receive a [json] from where the information is extracted.
  static Property propertyFromJson(Map<String, dynamic> json) {
    PropertiesTypes type = extractPropertyType(json);
    if (type == PropertiesTypes.Title) {
      bool contentIsList = Property.contentIsList(json, type);
      return TitleProp.fromJson(json, subfield: contentIsList ? null : 'title');
    } else if (type == PropertiesTypes.RichText) {
      return RichTextProp.fromJson(json);
    } else if (type == PropertiesTypes.MultiSelect) {
      bool contentIsList = MultiSelectProp.contentIsList(json);
      MultiSelectProp multi = MultiSelectProp.fromJson(json,
          subfield: contentIsList ? null : 'options');
      return multi;
    } else if (type == PropertiesTypes.Number) {
      return NumberProp.fromJson(json);
    } else if (type == PropertiesTypes.Checkbox) {
      return CheckboxProp.fromJson(json);
    } else if (type == PropertiesTypes.Date) {
      return DateProp.fromJson(json);
    } else {
      return Property();
    }
  }

  /// Check if the specific json have a content list.
  static bool contentIsList(Map<String, dynamic> json, PropertiesTypes type) =>
      fieldIsList(json[propertyTypeToString(type)]);

  /// Returns true if the properties are empty.
  static bool isEmpty(Map<String, dynamic> json, PropertiesTypes type) {
    if (json[propertyTypeToString(type)] != null) {
      return json[propertyTypeToString(type)]!.isEmpty;
    }
    return true;
  }
}

/// A representation of a title property for any Notion object.
class TitleProp extends Property {
  /// The property type. Always Title for this.
  @override
  final PropertiesTypes type = PropertiesTypes.Title;

  /// The property name.
  String? name;

  /// The property content.
  List<Text> content;

  /// The value of the content.
  @override
  List<Text> get value => this.content;

  /// Main title property constructor.
  ///
  /// Can receive a list ot texts as the title [content].
  TitleProp({this.content: const <Text>[], this.name});

  /// Create a new property instance from json.
  ///
  /// Receive a [json] from where the information is extracted.
  TitleProp.fromJson(Map<String, dynamic> json, {String? subfield})
      : this.name = json['name'] ?? '',
        this.content = Text.fromListJson(((subfield != null
                    ? json[propertyTypeToString(PropertiesTypes.Title)]
                        [subfield]
                    : json[propertyTypeToString(PropertiesTypes.Title)]) ??
                []) as List)
            .toList(),
        super(id: json['id']);

  /// Convert this to a valid json representation for the Notion API.
  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {'type': this.strType};

    if (this.id != null) {
      json['id'] = this.id;
    }
    if (this.name != null) {
      json['name'] = this.name;
    }

    json[this.strType] = this.content.map((e) => e.toJson()).toList();

    return json;
  }
}

/// A representation of a rich text property for any Notion object.
class RichTextProp extends Property {
  /// The property type. Always RichText for this.
  @override
  final PropertiesTypes type = PropertiesTypes.RichText;

  /// The list of rich text.
  List<Text> content;

  /// The value of the content.
  @override
  List<Text> get value => this.content;

  /// Main RichText constructor.
  ///
  /// Can receive the [content] as a list of texts.
  RichTextProp({this.content: const <Text>[]});

  /// Create a new rich text instance from json.
  ///
  /// Receive a [json] from where the information is extracted.
  RichTextProp.fromJson(Map<String, dynamic> json)
      : this.content = Text.fromListJson(
            json[propertyTypeToString(PropertiesTypes.RichText)] is List
                ? json[propertyTypeToString(PropertiesTypes.RichText)] as List
                : []),
        super(id: json['id']);

  /// Convert this to a valid json representation for the Notion API.
  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {'type': strType};

    if (id != null) {
      json['id'] = id;
    }

    json[strType] = content.map((e) => e.toJson()).toList();

    return json;
  }
}

/// A representation of the multi select Notion object.
class MultiSelectProp extends Property {
  /// The property type. Always MultiSelect for this.
  @override
  final PropertiesTypes type = PropertiesTypes.MultiSelect;

  List<MultiSelectOption> options;

  /// The options of the multi select.
  @override
  List<MultiSelectOption> get value => this.options;

  /// Main multi select constructor.
  ///
  /// Can receive the list6 of the options.
  MultiSelectProp({this.options: const <MultiSelectOption>[]});

  MultiSelectProp.fromJson(Map<String, dynamic> json, {String? subfield})
      : this.options = MultiSelectOption.fromListJson((subfield != null
            ? json[propertyTypeToString(PropertiesTypes.MultiSelect)][subfield]
            : json[propertyTypeToString(PropertiesTypes.MultiSelect)]) as List),
        super(id: json['id']);

  /// Add a new [option] to the multi select options and returns this instance.
  MultiSelectProp addOption(MultiSelectOption option) {
    this.options.add(option);
    return this;
  }

  /// Convert this to a valid json representation for the Notion API.
  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {'type': strType};

    if (id != null) {
      json['id'] = id;
    }

    json[strType] = {'options': options.map((e) => e.toJson()).toList()};

    return json;
  }

  /// Returns true if a json field is a list.
  static bool contentIsList(Map<String, dynamic> json) =>
      fieldIsList(json[propertyTypeToString(PropertiesTypes.MultiSelect)]);
}

/// A representation of a multi select option property for any Notion object.
class MultiSelectOption {
  /// The option name.
  String name;

  /// The option id.
  String? id;

  /// The option color.
  ColorsTypes color;

  /// Main multi select option property constructor.
  ///
  /// Required the [name] field to display a text for the option. Also can receive the [id] and the [color] of the option.
  MultiSelectOption(
      {required this.name, this.id, this.color: ColorsTypes.Default});

  /// Create a new multi select instance from json.
  ///
  /// Receive a [json] from where the information is extracted.
  MultiSelectOption.fromJson(Map<String, dynamic> json)
      : this.name = json['name'] ?? '',
        this.id = json['id'],
        this.color = stringToColorType(json['color'] ?? '');

  /// Convert this to a valid json representation for the Notion API.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'name': name,
      'color': colorTypeToString(color),
    };

    if (id != null) {
      json['id'] = id;
    }

    return json;
  }

  /// Map a list of options from a [json] list with dynamics.
  static List<MultiSelectOption> fromListJson(List<dynamic> options) =>
      options.map((e) => MultiSelectOption.fromJson(e)).toList();
}

/// A representation of a number property for any Notion object.
class NumberProp extends Property {
  num? value;

  @override
  final PropertiesTypes type = PropertiesTypes.Number;

  NumberProp(this.value);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {'type': this.strType};

    if (this.id != null) {
      json['id'] = this.id;
    }

    json[this.strType] = this.value;

    return json;
  }

  NumberProp.fromJson(Map<String, dynamic> json)
      : this.value = json['number'],
        super(id: json['id']);
}

/// A representation of a number property for any Notion object.
class CheckboxProp extends Property {
  bool value;

  @override
  final PropertiesTypes type = PropertiesTypes.Checkbox;

  CheckboxProp(this.value);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {'type': 'checkbox', 'checkbox': this.value};

    if (this.id != null) {
      json['id'] = this.id;
    }

    return json;
  }

  CheckboxProp.fromJson(Map<String, dynamic> json)
      : this.value = json['checkbox'],
        super(id: json['id']);
}

/// A representation of a date property for any Notion object.
class DateProp extends Property {
  DateTime startDate;

  @override
  final PropertiesTypes type = PropertiesTypes.Date;

  DateProp({required this.startDate});

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {'type': this.strType};

    if (this.id != null) {
      json['id'] = this.id;
    }

    json[this.strType] = {
      "start":
          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}"
    };

    return json;
  }

  DateProp.fromJson(Map<String, dynamic> json)
      : this.startDate = DateTime.parse(json['date']['start']),
        super(id: json['id']);
}
