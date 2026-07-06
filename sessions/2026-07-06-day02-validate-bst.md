---
date: 2026-07-06
day: 02
type: coding
company_archetype: general
difficulty: medium
---

# Day 02 — coding — validate-bst

## Problem / Prompt
Validate Binary Search Tree: given a binary tree, determine whether it is a
valid BST. A valid BST requires every node in a left subtree to be less
than *all* of its ancestors on the right-going path (not just its
immediate parent), and symmetrically for right subtrees. The interviewer
first asked me to construct a tree where checking only each node against
its immediate parent would wrongly pass, but the tree is not actually a
valid BST — to test whether I understood the global vs. local property
before designing a solution.

## Transcript

**Me:** okay so 10 at root 5 its left child 20 its right child for 5 its
left is 4 and right is 15

```
        10
       /  \
      5    20
     / \
    4   15
```

**Interviewer:** Yes. That's it. You found it. Walking through why: 10's
children (5 < 10 < 20) check out, 5's children (4 < 5 < 15) check out —
every local parent-child check passes. But 15 sits in the left subtree of
10, and 15 > 10, so the tree is not a valid BST under the global
definition. Local checks are insufficient because a node deep in a left
subtree must be less than every ancestor on its right-going path, not just
its immediate parent. So the recursion can't just be "check my kids and
recurse" — each call needs to carry the valid range for that node, based
on the ancestors above it. Now redo Lay out properly: (1) what are the
inputs to your recursive function — hint, more than just a node; (2) what
does it return; (3) what's the base case; (4) what's the recursive case?
Don't code yet.

**Me:** can i suggest other approach if we traverse this tree dfs way and
maintain a last node value in pointer and check current nodes value
against it or lets just append it in an array and check if the array is
sorted or not because this approach i think will resolve our global bst
condition as it will place in our example's case 4 5 15 10 20 — i don't
know the exact name for this traversal but it's like go to leftmost node
then its parent then go to right nodes, continue this recursively.

**Interviewer:** Yes — that traversal is called in-order traversal (left →
node → right), and the observation is right: for a valid BST, in-order
traversal produces a strictly increasing sequence. Verified against the
counter-example: in-order gives 4, 5, 15, 10, 20 — not sorted, since
15 > 10 breaks it, so the tree is correctly flagged invalid. Two variants
of what was proposed: Variant A — traverse, append every value to an
array, then check if the array is sorted (O(n) time, O(n) space). Variant
B — traverse while tracking only the previous value seen, comparing as you
go and returning false immediately on the first violation (O(n) time, but
early-exit in practice; O(h) space for the recursion stack instead of
O(n)). B strictly dominates A. There's also a third canonical approach:
recurse with a `(min, max)` range each node's value must fall within,
passing `(-inf, node.val)` left and `(node.val, +inf)` right — same
complexity as B, different mental model. Go with B. Before coding: (1)
function signature — what does the top-level function take and return?
(2) helper function or one function — why? (3) how are you tracking
`previous` across recursive calls, given this is the tricky part in
Python?

**Me:** i will need a helper function i think because i will need to send
previous value as parameter as recursion is call to the same function and
in the given function we are not using any additional parameter. so
in-order traversal is like this:
`def inorder(root, val=None): if root: inorder(root.left, val); root.val; inorder(root.right, val)`
— i am unable to think of how to do with variant B.

**Interviewer:** Correct instinct on needing a helper, but this hits the
core problem: Python integers are immutable, so passing `val` as a plain
parameter and reassigning it inside a recursive call doesn't propagate
back to the caller — each frame holds its own copy. Fix options: (1) wrap
`prev` in a single-element mutable list so every frame reads/writes the
same object; (2) use `nonlocal`; (3) store it as a `self` attribute if
this is a class method. Recommended: the mutable-list version, since it's
self-contained and doesn't need `nonlocal`. [Full working code was then
given for all three options.] Task handed back: fill in the logic —
left child first, compare to `prev[0]` if it exists, update `prev[0]`,
then right child, return True if the traversal completes.

*(Session transcript ends here — I had not yet written the completed
function when this was logged.)*

## Claude's Feedback

### Rubric (1-5 each)
- **Clarify:** 4 — the counter-example construction showed real
  understanding of the global-vs-local BST property, which is the crux of
  this problem. Slight deduction because this was in response to the
  interviewer's specific prompt rather than something self-initiated
  before being asked.
- **Lay out:** 3 — the in-order-traversal insight and the A vs. B
  complexity comparison were both strong and correctly reasoned. But the
  interviewer asked four direct structural questions (inputs, return
  value, base case, recursive case) and they were never answered —
  instead the conversation pivoted straight to a different approach. A
  better move: answer the four questions for the range-based approach
  first, in one or two sentences each, *then* offer the in-order
  alternative as a second option. Answering a direct question before
  redirecting is part of what's being scored here, not just having a good
  idea.
- **Execute:** 2 — got stuck on Python's immutability across recursive
  calls, and rather than proposing a guess (a list, `nonlocal`,
  returning the value, a class attribute — any of these would have shown
  reasoning), the response stopped at "i am unable to think of how." In a
  real interview, no one is going to hand over three complete code
  options the way this transcript did. Saying "I'm stuck" out loud is the
  right instinct (much better than going silent), but the next move
  should be a half-formed guess, not a full stop.
- **Assess:** not reached — the session ended before the function was
  completed or dry-run against the counter-example.
- **Refine:** not reached — same reason.

### Flags
- **Hedge-stacking:** absent. Language was direct ("i will need a helper
  function i think because...") — mild uncertainty, not stacked.
- **Signposting:** absent. There was no explicit phase language ("let me
  move to Execute now" / "stepping back to Lay out") — transitions
  happened implicitly through what was typed rather than being named.
  Compare to Day 01, where phase transitions were labeled explicitly.
- **Silent debugging:** borderline-present. Not fully silent — the stuck
  point was named out loud — but there was no attempted fix before
  asking for one. In a live interview, an interviewer reads "I don't know
  how" with zero attempt very differently from "I don't know exactly, but
  maybe I could pass a mutable object instead of a plain value" — the
  second one is a narrated attempt even if it turns out wrong.

### Specific notes
1. When asked a direct structured question (the four Lay-out questions),
   answer it — even briefly — before pivoting to a different approach.
   Redirecting to a better idea without acknowledging the original
   question reads as dodging it, not as confidence.
2. At the stuck point on state-across-recursion, produce a guess before
   asking for the answer. Even a wrong guess ("could I pass it by
   reference somehow, or maybe make it a global?") gives the interviewer
   something to correct, which is a much stronger signal than a blank
   stop.
3. Memorize the four-question template for tree recursion problems
   (inputs / return value / base case / recursive case) as a fixed
   reflex — it applies to nearly every tree or graph problem, and having
   it ready removes the need for the interviewer to prompt for it.

### Model verbal answer
"I need this comparison to survive across recursive calls, and since
Python integers are immutable, passing `previous` as a plain argument
won't let a child call's update reach the parent's frame — each call gets
its own copy. So instead of a plain variable, let me hold `previous`
inside something mutable, like a single-element list, so every recursive
call is reading and writing the same object instead of its own copy."

## Voice Self-Review
- Pace:
- Filler words noticed:
- Where I'd have gone quiet if actually speaking:
- One thing to fix tomorrow:
