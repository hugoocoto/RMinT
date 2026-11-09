#include <stdlib.h>

struct RMinT {
        float *items;
        long last_index;
        long capacity;
};

static void
RMinT_swap(struct RMinT *tree, int i, int j)
{
        float temp = tree->items[i];
        tree->items[i] = tree->items[j];
        tree->items[j] = temp;
}

static int
RMinT_get_parent(int current_index)
{
        return (current_index - 1) / 2;
}

static int
RMinT_get_Lchild(int current_index)
{
        return current_index * 2 + 1;
}

static int
RMinT_get_Rchild(int current_index)
{
        return current_index * 2 + 2;
}

static void
RMinT_fix_topward(struct RMinT *tree, int current_index)
{
        while (current_index != 0) {
                int parent = RMinT_get_parent(current_index);
                if (tree->items[current_index] < tree->items[parent]) {
                        RMinT_swap(tree, parent, current_index);
                        current_index = parent;
                } else {
                        break;
                }
        }
}

static void
RMinT_fix_backward(struct RMinT *tree, int current_index)
{
        int childL, childR, smallest_child;

        while (current_index <= tree->last_index) {
                childL = RMinT_get_Lchild(current_index);
                childR = RMinT_get_Rchild(current_index);
                if (childR > tree->last_index) childR = childL;
                if (childL > tree->last_index) break;
                smallest_child = tree->items[childR] < tree->items[childL]
                               ? childR
                               : childL;
                if (!(tree->items[smallest_child] < tree->items[current_index])) {
                        break;
                }
                RMinT_swap(tree, current_index, smallest_child);
                current_index = smallest_child;
        }
}

struct RMinT
RMinT_create(int capacity)
{
        struct RMinT tree;

        tree.items = malloc(sizeof(float) * capacity);
        tree.capacity = capacity;
        tree.last_index = -1;
        return tree;
}

void
RMinT_destroy(struct RMinT *tree)
{
        free(tree->items);
        tree->items = NULL;
}

float
RMinT_poll(struct RMinT *tree)
{
        float result = tree->items[0];

        RMinT_swap(tree, 0, tree->last_index--);
        RMinT_fix_backward(tree, 0);
        return result;
}

void
RMinT_add(struct RMinT *tree, float element)
{
        if (tree->last_index + 1 == tree->capacity) {
                if (tree->items[0] >= element) return;
                tree->items[0] = element;
                RMinT_fix_backward(tree, 0);
                return;
        }

        tree->items[++tree->last_index] = element;
        RMinT_fix_topward(tree, tree->last_index);
}
