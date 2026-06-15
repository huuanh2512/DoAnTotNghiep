# Bug Notes

## Flutter `_dependents.isEmpty` when submitting bottom-sheet forms

- Seen on the court management bottom sheet when editing a court name.
- Do not mutate cubit/bloc state or pop the sheet while a `TextField` still has focus.
- Before closing a bottom sheet that contains editable fields, call
  `FocusManager.instance.primaryFocus?.unfocus()` and wait a short frame-friendly
  delay before `Navigator.pop`.
- Run create/update/delete state mutations only after the sheet has closed.
- Reusing the old pattern can crash with:
  `package:flutter/src/widgets/framework.dart: Failed assertion: line 6268 pos 12: '_dependents.isEmpty': is not true.`

## Vietnamese mojibake in Flutter UI text

- Seen in court management after adding grouped court cards. Text such as `Giá`,
  `sân`, `giờ`, and `Sẵn sàng hoạt động` rendered as mojibake (`GiÃ¡`,
  `sÃ¢n`, `giá»`, etc.).
- Do not copy Vietnamese literals from a terminal output that may be decoded
  incorrectly. Prefer reading source with `rg` or inspect the editor buffer, then
  patch with proper UTF-8 text.
- After editing Vietnamese UI strings, scan for mojibake markers such as `Ã`,
  `Ä`, `Æ`, `áº`, and `á»`.
