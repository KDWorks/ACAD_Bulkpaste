;;;------------------------------------------------------------------------------------------------
;;; LISP Command to Insert DXF and DWG Files as Blocks
;;;------------------------------------------------------------------------------------------------

(defun C:BULKPASTE ( / folderPath spacing alignment blockName insertionPoint textPoint fileList fileName textHeight)

  ;; Function to browse for a folder (similar to a dialog box)
  (defun browseForFolder (message)
    (vl-load-com)
    (setq shell (vlax-get-or-create-object "Shell.Application"))
    (setq folder (vlax-invoke-method shell 'BrowseForFolder 0 message 0))
    (if folder
      (setq folderPath (vlax-get-property folder 'Self)
            folderPath (vlax-get-property folderPath 'Path))
    )
    (vlax-release-object shell)
    folderPath
  )

  ;; Get folder path from the user
  (setq folderPath (browseForFolder "Please select the folder containing DXF/DWG files."))
  (if (not folderPath)
    (progn
      (alert "No folder selected. Command canceled.")
      (exit)
    )
  )

  ;; Get spacing from the user
  (setq spacing (getreal "\nEnter spacing between blocks: "))
  (if (not spacing)
    (progn
      (alert "Invalid spacing. Command canceled.")
      (exit)
    )
  )

  ;; Get alignment option from the user
  (initget "Horizontal Vertical")
  (setq alignment (getkword "\nSelect alignment [Horizontal/Vertical]: "))
  (if (not alignment)
    (progn
      (alert "Invalid alignment selected. Command canceled.")
      (exit)
    )
  )
  
  ;; Get text height from the user
  (setq textHeight (getreal "\nEnter text height: "))
  (if (not textHeight)
    (setq textHeight 5.0) ; Default text height
  )

  ;; Find DXF and DWG files in the selected folder
  (setq fileList (vl-directory-files folderPath "*.dxf" 1))
  (setq fileList (append fileList (vl-directory-files folderPath "*.dwg" 1)))

  (if (not fileList)
    (progn
      (alert "No DXF or DWG files found in the selected folder.")
      (exit)
    )
  )

  ;; Set the initial insertion point
  (setq insertionPoint '(0.0 0.0 0.0))

  ;; Loop through each file
  (foreach fileName fileList
    (setq filePath (strcat folderPath "\\" fileName))
    (setq blockName (vl-filename-base fileName))

    ;; Insert the file as a block using the _INSERT command
    (command "._INSERT" filePath insertionPoint 1 1 0)
    (princ (strcat "\nBlock inserted: " blockName))

    ;; Add text below or to the left of the block
    (if (equal alignment "Horizontal")
      (progn
        ;; Horizontal alignment: Text is centered below the block
        (setq textPoint (list (car insertionPoint) (- (cadr insertionPoint) 10.0) 0.0))
        (command "._TEXT" "J" "MC" textPoint textHeight "0" blockName)
      )
      (progn
        ;; Vertical alignment: Text is right-aligned to the left of the block
        (setq textPoint (list (- (car insertionPoint) 10.0) (cadr insertionPoint) 0.0))
        (command "._TEXT" "J" "MR" textPoint textHeight "0" blockName)
      )
    )
    
    ;; Set the insertion point for the next block
    (if (equal alignment "Vertical")
      (setq insertionPoint (list (car insertionPoint) (- (cadr insertionPoint) spacing) 0.0))
      (setq insertionPoint (list (+ (car insertionPoint) spacing) (cadr insertionPoint) 0.0))
    )
  )

  (princ "\nOperation completed.")
  (princ)
)

;; Command line prompt to start the command
(princ "\nType BULKPASTE to start the command.")
(princ)