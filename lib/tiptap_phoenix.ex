defmodule TiptapPhoenix do
  @moduledoc """
  Tiptap rich-text editor integration for Phoenix LiveView.

  Provides a production-ready Notion-like editing experience with slash commands,
  bubble menu, drag handles, and server-side JSON-to-HTML rendering.

  ## Quick start

  1. Add the hook in your `app.js`:

      ```js
      import { createTiptapHook } from "tiptap-phoenix"
      const TiptapEditor = createTiptapHook()
      ```

  2. Use the component in your LiveView template:

      ```heex
      <TiptapPhoenix.Component.tiptap_editor
        id="my-editor"
        content={@content}
        section_key="body"
      />
      ```

  3. Handle events in your LiveView:

      ```elixir
      def handle_event("tiptap:" <> _ = event, params, socket) do
        TiptapPhoenix.Component.handle_editor_event(event, params, socket)
      end
      ```
  """

  @doc """
  Returns a default empty ProseMirror document.

  Useful as initial content for new editors.
  """
  @spec default_doc() :: map()
  def default_doc do
    %{"type" => "doc", "content" => [%{"type" => "paragraph"}]}
  end
end
