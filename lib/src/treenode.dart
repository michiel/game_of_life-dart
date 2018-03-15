class TreeNode {
  TreeNode nw;
  TreeNode ne;
  TreeNode sw;
  TreeNode se;
  int level;
  bool alive;
  int population;

  static TreeNode createLeaf(alive) {
    TreeNode node = new TreeNode(null, null, null, null);
    node.population = alive ? 1 : 0;
    node.alive = alive;
    return node;
  }

  TreeNode(this.nw, this.ne, this.sw, this.se) {
    this.level = _safeGuessLevel();
    this.population = _safeCountPopulation();
    this.alive = this.population > 0;
  }

  int _safeGuessLevel() {
    if (this.nw == null) {
      return 0;
    } else {
      return this.nw.level - 1;
    }
  }

  int _safeCountPopulation() {
    int pop = 0;
    if (this.nw != null) {
      pop += this.nw.population;
    }
    if (this.ne != null) {
      pop += this.ne.population;
    }
    if (this.sw != null) {
      pop += this.sw.population;
    }
    if (this.se != null) {
      pop += this.se.population;
    }
    return pop;
  }

  static TreeNode create() {
    return createLeaf(false).createEmptyTree(3);
  }

  TreeNode createEmptyTree(int level) {
    if (level == 0) {
      return createLeaf(false);
    } else {
      TreeNode n = createEmptyTree(level - 1);
      return new TreeNode(n, n, n, n);
    }
  }

  TreeNode expand() {
    TreeNode border = createEmptyTree(this.level - 1);
    return new TreeNode(
        new TreeNode(border, border, border, this.nw),
        new TreeNode(border, border, this.ne, border),
        new TreeNode(border, this.sw, border, border),
        new TreeNode(this.se, border, border, border));
  }

  TreeNode setBit(int x, int y) {
    if (this.level == 0) {
      return createLeaf(true);
    } else {
      int offset = 1 << (this.level - 2);
      if (x < 0) {
        if (y < 0) {
          return new TreeNode(this.nw.setBit(x + offset, y + offset), this.ne,
              this.sw, this.se);
        } else {
          return new TreeNode(this.nw, this.ne,
              this.sw.setBit(x + offset, y - offset), this.se);
        }
      } else {
        if (y < 0) {
          return new TreeNode(this.nw, this.ne.setBit(x - offset, y + offset),
              this.sw, this.se);
        } else {
          return new TreeNode(this.nw, this.ne, this.sw,
              this.se.setBit(x - offset, y - offset));
        }
      }
    }
  }

  int getBit(int x, int y) {
    if (level == 0) {
      return this.alive ? 1 : 0;
    } else {
      int offset = 1 << (this.level - 2);
      if (x < 0) {
        if (y < 0) {
          return this.nw.getBit(x + offset, y + offset);
        } else {
          return this.sw.getBit(x + offset, y - offset);
        }
      } else {
        if (y < 0) {
          return this.ne.getBit(x - offset, y + offset);
        } else {
          return this.se.getBit(x - offset, y - offset);
        }
      }
    }
  }

  TreeNode oneGen(int bitmask) {
    if (bitmask == 0) {
      return createLeaf(false);
    } else {
      int self = (bitmask >> 5) & 1;
      bitmask &= 0x757;

      int neighbourCount = 0;
      while (bitmask != 0) {
        neighbourCount += 1;
        bitmask &= bitmask - 1; // clears LSB
      }

      if ((neighbourCount == 3) || (neighbourCount == 2) && (self != 0)) {
        return createLeaf(true);
      } else {
        return createLeaf(false);
      }
    }
  }

  TreeNode slowSimulation() {
    int allbits = 0;
    for (int y = -2; y < 2; y++) {
      for (int x = -2; x < 2; x++) {
        allbits = (allbits << 1) + getBit(x, y);
      }
    }

    return new TreeNode(oneGen(allbits >> 5), oneGen(allbits >> 4),
        oneGen(allbits >> 1), oneGen(allbits));
  }

  TreeNode centeredSubNode() {
    return new TreeNode(this.nw.se, this.ne.sw, this.sw.ne, this.se.nw);
  }

  TreeNode centeredHorizontal(TreeNode w, TreeNode e) {
    return new TreeNode(w.ne.se, e.nw.sw, w.se.ne, e.sw.nw);
  }

  TreeNode centeredVertical(TreeNode n, TreeNode s) {
    return new TreeNode(n.sw.se, n.se.sw, s.nw.ne, s.ne.nw);
  }

  TreeNode centeredSubSubNode() {
    return new TreeNode(
        this.nw.se.se, this.ne.sw.sw, this.sw.ne.ne, this.se.nw.nw);
  }

  TreeNode nextGeneration() {
    if (this.population == 0) {
      return this.nw;
    } else if (this.level == 2) {
      return slowSimulation();
    } else {
      TreeNode n00 = this.nw.centeredSubNode(),
          n01 = centeredHorizontal(this.nw, this.ne),
          n02 = this.ne.centeredSubNode(),
          n10 = centeredVertical(this.nw, this.sw),
          n11 = centeredSubSubNode(),
          n12 = centeredVertical(this.ne, this.se),
          n20 = this.sw.centeredSubNode(),
          n21 = centeredHorizontal(this.sw, this.se),
          n22 = se.centeredSubNode();

      return new TreeNode(
          new TreeNode(n00, n01, n10, n11).nextGeneration(),
          new TreeNode(n01, n02, n11, n12).nextGeneration(),
          new TreeNode(n10, n11, n20, n21).nextGeneration(),
          new TreeNode(n11, n12, n21, n22).nextGeneration());
    }
  }
}
