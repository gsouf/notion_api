import 'package:notion_api/notion/blocks/block.dart';
import 'package:notion_api/notion/general/types/notion_types.dart';
import 'package:notion_api/notion/objects/database.dart';
import 'package:notion_api/utils/utils.dart';

/// A representation of the pagination response from the Notion API.
class Pagination {
  /// The cursor to the next page.
  String? nextCursor;

  /// The marker to know if has more pages.
  bool hasMore;

  /// The marker to know if is empty.
  bool isEmpty;

  List<Block>? _blocks;
  List<Database>? _databases;

  /// TODO: made pages class
  List<dynamic>? _pages;

  /// The list of blocks for when the response is for blocks.
  List<Block> get blocks => isEmpty ? [] : _blocks!;

  /// The list of databases for when the response is for databases.
  List<Database> get databases => isEmpty ? [] : _databases!;

  /// The list of pages for when the response is for pages.
  List<dynamic> get pages => isEmpty ? [] : _pages!;

  /// Returns true if the result is a list of blocks.
  bool get isBlocksList => _blocks != null;

  /// Returns true if the result is a list of databases.
  bool get isDatabasesList => _databases != null;

  /// Returns true if the result is a list of pages.
  bool get isPagesList => _pages != null;

  /// Main pagination constructor.
  ///
  /// Can receive the [nextCursor], if [hasMore] pages, if [isEmpty] and the corresponding list: [blocks], [databases] or [pages].
  Pagination({
    this.nextCursor,
    this.hasMore: false,
    this.isEmpty: false,
    List<Block>? blocks,
    List<Database>? databases,
    List<dynamic>? pages,
  });

  /// Map a new pagination instance from a [json] map.
  factory Pagination.fromJson(Map<String, dynamic> json,
      {ObjectTypes? staticType}) {
    Pagination pagination =
        Pagination(hasMore: json['has_more'], nextCursor: json['next_cursor']);

    // Extract the type of the list
    List listOfUnknowns = json['results'] as List;
    if (listOfUnknowns.length > 0) {
      ObjectTypes autoType =
          NotionUtils.stringToObjectType(listOfUnknowns.first['object'] ?? '');

      // Map the corresponding list accord to the type
      ObjectTypes object =
          autoType == ObjectTypes.None ? staticType ?? autoType : autoType;
      if (object == ObjectTypes.Block) {
        List<Block> blocks = List<Block>.from(
            (json['results'] as List).map((e) => Block.fromJson(e)));
        pagination._blocks = [...blocks];
      } else if (object == ObjectTypes.Database) {
        List<Database> databases = List<Database>.from(
            (json['results'] as List).map((e) => Database.fromJson(e)));
        pagination._databases = [...databases];
      } else if (object == ObjectTypes.Page) {}
    } else {
      pagination.isEmpty = true;
    }

    return pagination;
  }

  List<Block> filterBlocks({
    List<BlockTypes> exclude: const [],
    List<BlockTypes> include: const [],
    BlockTypes? onlyLeft,
    String? id,
  }) {
    List<Block> filetered = <Block>[];
    if (isBlocksList) {
      filetered.addAll(_blocks!);
      if (exclude.isNotEmpty) {
        filetered.removeWhere((block) => exclude.contains(block.type));
      } else if (include.isNotEmpty) {
        filetered.removeWhere((block) => !include.contains(block.type));
      } else if (onlyLeft != null) {
        filetered.removeWhere((element) => element.type != onlyLeft);
      } else if (id != null) {
        filetered.removeWhere((element) => element.id == id);
      }
    }
    return filetered;
  }
}
