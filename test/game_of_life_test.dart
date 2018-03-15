import 'package:game_of_life/game_of_life.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    TreeNode root;

    setUp(() {
      root = TreeNode.create();
    });

    test('First Test', () {
      expect(root.ne, new isInstanceOf<TreeNode>());
    });
  });
}
