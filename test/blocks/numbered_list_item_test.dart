import 'package:notion_api/notion/blocks/numbered_list_item.dart';
import 'package:notion_api/notion/blocks/paragraph.dart';
import 'package:notion_api/notion/general/rich_text.dart';
import 'package:notion_api/notion/general/types/notion_types.dart';
import 'package:notion_api/utils/utils.dart';
import 'package:test/test.dart';

void main() {
  group('NumberedListItem tests =>', () {
    test('Create an empty instance', () {
      NumberedItem block = NumberedItem();

      expect(block, isNotNull);
      expect(block.strType, blockTypeToString(BlockTypes.NumberedListItem));
      expect(block.content, allOf([isList, isEmpty]));
      expect(block.isNumberedItem, true);
      expect(block.type, BlockTypes.NumberedListItem);
    });

    test('Create an instance with information', () {
      NumberedItem block = NumberedItem(text: Text('A')).addText('B');

      expect(block.content.length, 2);
      expect(block.content.first.text, 'A');
      expect(block.content.last.text, 'B');
    });

    test('Create an instance with mixed information', () {
      NumberedItem block = NumberedItem(
        text: Text('first'),
        texts: [
          Text('foo'),
          Text('bar'),
        ],
      ).addText('last').addChild(Paragraph(texts: [
            Text('A'),
            Text('B'),
          ]));

      expect(block.content.length, 4);
      expect(block.content.first.text, 'first');
      expect(block.content.last.text, 'last');
      expect(block.content.length, 1);
    });

    test('Create json from instance', () {
      Map<String, dynamic> json = NumberedItem(text: Text('A'))
          .addChild(Paragraph(texts: [
            Text('A'),
            Text('B'),
          ]))
          .toJson();

      expect(
          json['type'],
          allOf([
            isNotNull,
            isNotEmpty,
            blockTypeToString(BlockTypes.NumberedListItem)
          ]));
      expect(json, contains(blockTypeToString(BlockTypes.NumberedListItem)));
      expect(json[blockTypeToString(BlockTypes.NumberedListItem)]['text'],
          allOf([isList, isNotEmpty]));
      expect(json[blockTypeToString(BlockTypes.NumberedListItem)]['children'],
          allOf([isList, isNotEmpty]));
    });

    test('Create json from empty instance', () {
      Map<String, dynamic> json = NumberedItem().toJson();

      expect(
          json['type'],
          allOf([
            isNotNull,
            isNotEmpty,
            blockTypeToString(BlockTypes.NumberedListItem)
          ]));
      expect(json, contains(blockTypeToString(BlockTypes.NumberedListItem)));
      expect(json[blockTypeToString(BlockTypes.NumberedListItem)]['text'],
          allOf([isList, isEmpty]));
      expect(json[blockTypeToString(BlockTypes.NumberedListItem)]['children'],
          allOf([isList, isEmpty]));
    });
  });
}
