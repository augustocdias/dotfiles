; Folds a section of the document
; that starts with a heading.
((section
    (atx_heading)) @fold
    (#trim! @fold))

; (#trim!) is used to prevent empty
; lines at the end of the section
; from being folded.
