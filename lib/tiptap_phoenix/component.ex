defmodule TiptapPhoenix.Component do
  @moduledoc """
  Phoenix LiveView component for the Tiptap editor.

  ## Usage

      <TiptapPhoenix.Component.tiptap_editor
        id="my-editor"
        content={@content}
        section_key="body"
        placeholder="Type '/' for commands..."
      />

  ## Events

  The editor fires the following events to the LiveView:

  | Event | Payload | Description |
  |-------|---------|-------------|
  | `tiptap:change` | `%{key, content}` | Content synced (debounced) |
  | `tiptap:save` | `%{key, content}` | Auto-save trigger (longer debounce) |
  | `tiptap:focus` | `%{key}` | Editor focused |
  | `tiptap:blur` | `%{key}` | Editor blurred |

  ## Server-to-client events

  Push events to update editor content:

  - `tiptap:set_content:{key}` — push new content into a specific editor
  - `tiptap:set_content` — generic content update
  """

  use Phoenix.Component

  @doc """
  Renders a Tiptap editor container.

  The actual editor is initialized client-side by the `TiptapEditor` hook.

  ## Attributes

  * `id` (required) — unique DOM id for the editor container
  * `content` — initial ProseMirror JSON content (defaults to empty doc)
  * `section_key` — identifier for this editor section (default: `"body"`)
  * `placeholder` — placeholder text shown in empty editor
  * `debounce_sync` — milliseconds for change event debounce (default: `1000`)
  * `debounce_save` — milliseconds for save event debounce (default: `3000`)
  * `class` — additional CSS classes for the outer container
  """
  attr :id, :string, required: true
  attr :content, :any, default: nil
  attr :section_key, :string, default: "body"
  attr :placeholder, :string, default: "Type '/' for commands..."
  attr :debounce_sync, :integer, default: 1000
  attr :debounce_save, :integer, default: 3000
  attr :class, :string, default: nil

  def tiptap_editor(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="TiptapEditor"
      phx-update="ignore"
      data-content={Jason.encode!(@content || TiptapPhoenix.default_doc())}
      data-section-key={@section_key}
      data-placeholder={@placeholder}
      data-debounce-sync={to_string(@debounce_sync)}
      data-debounce-save={to_string(@debounce_save)}
      class={@class}
    >
      <div data-tiptap-editor></div>
    </div>
    """
  end

  @doc """
  Handles standard Tiptap editor events.

  Delegate events from your LiveView to this function:

      def handle_event("tiptap:" <> _ = event, params, socket) do
        TiptapPhoenix.Component.handle_editor_event(event, params, socket)
      end

  ## Options

  * `:on_change` — callback `fn key, content, socket -> {:noreply, socket}` for content changes
  * `:on_save` — callback `fn key, content, socket -> {:noreply, socket}` for auto-save triggers
  * `:on_focus` — callback `fn key, socket -> {:noreply, socket}` for focus events
  * `:on_blur` — callback `fn key, socket -> {:noreply, socket}` for blur events
  """
  def handle_editor_event(event, params, socket, opts \\ [])

  def handle_editor_event("tiptap:change", %{"key" => key, "content" => content}, socket, opts) do
    case Keyword.get(opts, :on_change) do
      nil -> {:noreply, socket}
      callback -> callback.(key, content, socket)
    end
  end

  def handle_editor_event("tiptap:save", %{"key" => key, "content" => content}, socket, opts) do
    case Keyword.get(opts, :on_save) do
      nil -> {:noreply, socket}
      callback -> callback.(key, content, socket)
    end
  end

  def handle_editor_event("tiptap:focus", %{"key" => key}, socket, opts) do
    case Keyword.get(opts, :on_focus) do
      nil -> {:noreply, socket}
      callback -> callback.(key, socket)
    end
  end

  def handle_editor_event("tiptap:blur", %{"key" => key}, socket, opts) do
    case Keyword.get(opts, :on_blur) do
      nil -> {:noreply, socket}
      callback -> callback.(key, socket)
    end
  end

  def handle_editor_event(_event, _params, socket, _opts) do
    {:noreply, socket}
  end
end
