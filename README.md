## The AI Agent That Neovim Deserves

### TODO
- when opencode fails right away, the marks are not cleaned up.  Likely because on error oncomplete is not called.
  * its likely that fill in function on failure needs a better way to display the failure to the end user.
  * consider doing a small pop-up in the corner that explains the failure

- if the function's definition in typescript is mutli-line

```typescript
function display_text(
  game_state: GameState,
  text: string,
  x: number,
  y: number,
): void {
  const ctx = game_state.canvas.getContext("2d");
  assert(ctx, "cannot get game context");
  ctx.fillStyle = "white";
  ctx.fillText(text, x, y);
}
```

Then the virtual text will be displayed one line below "function" instead of first line in body

* if you are on an export statement in typescript, it cannot find the function "you are on"
  * when the result comes back, the function is replaced but the export is not preserved due to the fact that the code submitted does not have the export
  * this is a sub bug to the generalized problem.  The text replacement is line based and not perfectly over TSRange
  * i could be over selecting with lexical_declaration over arrow_function

### Feature
able to use visual selection to send off a request to the ai and have the visual selection replaced by ai
