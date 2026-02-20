import { Editor } from "@tiptap/core"
import StarterKit from "@tiptap/starter-kit"
import Placeholder from "@tiptap/extension-placeholder"
import Image from "@tiptap/extension-image"
import Link from "@tiptap/extension-link"
import Underline from "@tiptap/extension-underline"
import CodeBlockLowlight from "@tiptap/extension-code-block-lowlight"
import Typography from "@tiptap/extension-typography"
import Table from "@tiptap/extension-table"
import TableRow from "@tiptap/extension-table-row"
import TableCell from "@tiptap/extension-table-cell"
import TableHeader from "@tiptap/extension-table-header"
import Details from "@tiptap/extension-details"
import DetailsSummary from "@tiptap/extension-details-summary"
import DetailsContent from "@tiptap/extension-details-content"
import { common, createLowlight } from "lowlight"
import { createSlashCommand } from "./extensions/slash_command"
import { createBubbleMenu } from "./extensions/bubble_menu"
import { DragHandle } from "./extensions/drag_handle"

const lowlight = createLowlight(common)

/**
 * Creates a TiptapEditor LiveView hook with optional customization.
 *
 * @param {Object} [options]
 * @param {Array}  [options.slashCommands] - Custom slash command items (defaults to defaultCommands)
 * @param {Array}  [options.extensions]    - Additional Tiptap extensions to include
 * @param {Array}  [options.bubbleMenuExtras] - Extra items for the bubble menu (see createBubbleMenu)
 * @returns {Object} A Phoenix LiveView hook
 */
export function createTiptapHook(options = {}) {
  const {
    slashCommands,
    extensions: extraExtensions = [],
    bubbleMenuExtras = [],
  } = options

  return {
    mounted() {
      const editorEl = this.el.querySelector("[data-tiptap-editor]")
      if (!editorEl) return

      // Read config from data attributes
      this._sectionKey = this.el.dataset.sectionKey || "body"
      const placeholder = this.el.dataset.placeholder || "Type '/' for commands..."
      const debounceSync = parseInt(this.el.dataset.debounceSync, 10) || 1000
      const debounceSave = parseInt(this.el.dataset.debounceSave, 10) || 3000

      let initialContent = { type: "doc", content: [{ type: "paragraph" }] }
      try {
        const raw = this.el.dataset.content
        if (raw) initialContent = JSON.parse(raw)
      } catch (_) {}

      this._pendingUpdate = false
      this._debounceTimer = null
      this._autoSaveTimer = null

      const slashCommandExt = createSlashCommand(slashCommands)
      const bubbleMenuExt = createBubbleMenu({
        extras: bubbleMenuExtras,
        pushEvent: (event, payload) => this.pushEvent(event, payload),
      })

      this.editor = new Editor({
        element: editorEl,
        extensions: [
          StarterKit.configure({
            codeBlock: false,
          }),
          Placeholder.configure({
            placeholder,
          }),
          Image.configure({
            inline: false,
            allowBase64: false,
          }),
          Link.configure({
            openOnClick: false,
            autolink: true,
          }),
          Underline,
          CodeBlockLowlight.configure({
            lowlight,
          }),
          Typography,
          Table.configure({ resizable: false }),
          TableRow,
          TableCell,
          TableHeader,
          Details,
          DetailsSummary,
          DetailsContent,
          slashCommandExt,
          bubbleMenuExt,
          DragHandle,
          ...extraExtensions,
        ],
        content: initialContent,
        onUpdate: ({ editor }) => {
          if (this._pendingUpdate) {
            this._pendingUpdate = false
            return
          }

          // Instant unsaved feedback
          this.pushEvent("tiptap:change", {
            key: this._sectionKey,
            content: editor.getJSON(),
          })

          // Debounced sync to LiveView assigns
          clearTimeout(this._debounceTimer)
          this._debounceTimer = setTimeout(() => {
            this.pushEvent("tiptap:change", {
              key: this._sectionKey,
              content: editor.getJSON(),
            })
          }, debounceSync)

          // Longer debounce: trigger auto-save
          clearTimeout(this._autoSaveTimer)
          this._autoSaveTimer = setTimeout(() => {
            clearTimeout(this._debounceTimer)
            this.pushEvent("tiptap:save", {
              key: this._sectionKey,
              content: editor.getJSON(),
            })
          }, debounceSave)
        },
        onFocus: () => {
          this.pushEvent("tiptap:focus", { key: this._sectionKey })
        },
        onBlur: () => {
          this.pushEvent("tiptap:blur", { key: this._sectionKey })
        },
      })

      // Listen for section-specific content updates
      this.handleEvent(`tiptap:set_content:${this._sectionKey}`, ({ content }) => {
        clearTimeout(this._debounceTimer)
        clearTimeout(this._autoSaveTimer)
        this._pendingUpdate = true
        this.editor.commands.setContent(content)
      })

      // Generic content update (backwards compat)
      this.handleEvent("tiptap:set_content", ({ content }) => {
        clearTimeout(this._debounceTimer)
        clearTimeout(this._autoSaveTimer)
        this._pendingUpdate = true
        this.editor.commands.setContent(content)
      })
    },

    destroyed() {
      clearTimeout(this._debounceTimer)
      clearTimeout(this._autoSaveTimer)
      if (this.editor) {
        this.editor.destroy()
        this.editor = null
      }
    },
  }
}
