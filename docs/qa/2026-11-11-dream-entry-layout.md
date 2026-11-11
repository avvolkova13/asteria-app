# Dream-entry layout correction

Figma references: file `iRwq5h8Hi7qqhuFLJ2iEtg`, frames `4505:57654` (free) and `4515:60008` (PRO).

The greeting, supporting prompt and free-attempt badge now share the left column beside Liveya. The introductory area has a minimum height, grows with content, and keeps the dream field/button near the design positions. The avatar retains its existing local composite assets and styling; its size adapts on narrow screens. Existing input, button, history link and character styling were preserved.

Removed a duplicate keyboard inset from the scroll padding: the containing Scaffold already resizes for the keyboard. Bottom safe-area padding is retained.

Checked:

- iPhone 16 simulator: populated free-attempt state, corrected alignment, field and decode button on the first viewport, field focus. Software keyboard was not shown because hardware-keyboard mode is active.
- Widget tests with real Lora/Onest: free/PRO intro geometry, badge visibility, entering draft text, 300pt software-keyboard inset, scrolling the decode button above the keyboard, retained draft and no layout exception.
- Four Sonnik tests passed; targeted analyzer clean; no dream submitted and no attempt consumed.
- Repository search found one greeting/prompt/avatar entry layout. PRO and free use this same screen; exhausted-attempt purchase screens do not duplicate it and were not restyled.
