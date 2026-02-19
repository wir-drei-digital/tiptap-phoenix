# TiptapPhoenix

A Tiptap rich-text editor integration for Phoenix LiveView. Provides a
production-ready Notion-like editing experience with slash commands, bubble
menu, drag handles, and server-side JSON-to-HTML rendering.

## Installation

Add to your `mix.exs`:

```elixir
def deps do
  [
    {:tiptap_phoenix, "~> 0.1.0"}
  ]
end
```

Add the npm package to your `assets/package.json`:

```json
{
  "dependencies": {
    "tiptap-phoenix": "file:../deps/tiptap_phoenix/assets"
  }
}
```

## Setup

### JavaScript

In your `app.js`:

```js
import { createTiptapHook } from "tiptap-phoenix"

const TiptapEditor = createTiptapHook()

const liveSocket = new LiveSocket("/live", Socket, {
  hooks: { TiptapEditor },
})
```

### CSS

In your `app.css`:

```css
@import "tiptap-phoenix/css/tiptap.css";
```

### LiveView

In your template:

```heex
<TiptapPhoenix.Component.tiptap_editor
  id="my-editor"
  content={@content}
  section_key="body"
  placeholder="Type '/' for commands..."
/>
```

Handle events in your LiveView:

```elixir
def handle_event("tiptap:" <> _ = event, params, socket) do
  TiptapPhoenix.Component.handle_editor_event(event, params, socket)
end
```

## Customization

### Custom slash commands

```js
import { createTiptapHook, defaultCommands } from "tiptap-phoenix"

const TiptapEditor = createTiptapHook({
  slashCommands: [
    ...defaultCommands,
    {
      title: "Callout",
      description: "Callout box",
      icon: "info",
      command: ({ editor, range }) => { /* ... */ },
    },
  ],
})
```

### Theming

Override CSS custom properties:

```css
:root {
  --ttp-bg: #ffffff;
  --ttp-text: #1a1a1a;
  --ttp-primary: #3b82f6;
}
```

## Server-side rendering

```elixir
html = TiptapPhoenix.Renderer.render(json_content)
```
