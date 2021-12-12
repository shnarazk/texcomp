;;; texcomp.el --- a completion package for latex -*- coding:emacs-mule -*-

;;--------------------------------------------------------------------------------
;;
;; Copyright (C) 2000-2018 Shuji Narazaki
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2 of
;; the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be
;; useful, but WITHOUT ANY WARRANTY; without even the implied
;; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE.  See the GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public
;; License along with this program; if not, write to the Free
;; Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
;; MA 02111-1307 USA
;;
;;-------------------------------------------------------------------
;; Author: Shuji Narazaki <shuji.narazaki@gmail.com>
;; Created: 2018-06-16
;; Version: 1.2.22
;; Keywords: tex, conevience
;;
;;; Commentary:
;;
;; Misc funcitons for reducing key typing in LaTeX mode.
;;-------------------------------------------------------------------
;;
;; This file contains following 1? commands:
;;  texcomp:insert-symbol
;;  texcomp:insert-environment
;;  texcomp:add-environment-name
;;  texcomp:add-symbol-name
;;  texcomp:strip-environment
;;  texcomp:end-current-environment
;;  texcomp:jump-to-environment-pair
;;  texcomp:mark-environment
;;  texcomp:backward-up-environment
;;  texcomp:up-environment
;;  texcomp:forward-environment
;;  texcomp:beginning-of-environment
;;  texcomp:end-of-environment
;;  texcomp:kill-environment
;;
;; Change Log
;;   2003/04/21 narazaki@cs.cis.nagasaki-u.ac.jp (Shuji Narazaki)
;;      add TAB key to start completion
;;   2003/01/10 narazaki@cs.cis.nagasaki-u.ac.jp (Shuji Narazaki)
;;     fix the code for keybindings
;;   2003/01/10 narazaki@cs.cis.nagasaki-u.ac.jp (Shuji Narazaki)
;;     add new command: texcomp:insert-environment-or-brace and bindings for it
;;     prefix tex: replaced with texcomp:
;;   1990/07/16 narazaki@nttslb.ntt.jp (Shuji Narazaki)
;;     adds command: texcomp:mark-environment and function:
;;     texcomp:search-environment-pair.
;;   1990/07/17 narazaki@nttslb.ntt.jp (Shuji Narazaki)
;;     adds command: texcomp:backward-up-environment.
;;   1990/07/18 narazaki@nttslb.ntt.jp (Shuji Narazaki)
;;     adds command: texcomp:up-environment , texcomp:forward-environment
;;   1990/07/20 narazaki@nttslb.ntt.jp (Shuji Narazaki)
;;     You can define key sequences for commands as you like.
;;   1990/09/11 narazaki@nttslb.ntt.jp (Shuji Narazaki)
;;     bug fix (texcomp:add-{symbol|environment}-name)
;;   1990/11/01 narazaki@nttslb.ntt.jp (Shuji Narazaki)
;;     bug fix (texcomp:insert-environment) which was occured when dot and
;;     mark is in same location and numeric arg is given.
;;   1991/04/30 narazaki@nttslb.ntt.jp (Shuji Narazaki)
;;     bug fix (texcomp:insert-symbol) which was occured when dot and mark is
;;     in same location and numeric arg is given.
;;   1991/06/19 narazaki@nttslb.ntt.jp (Narazaki Shuji)
;;     An environment in the middle of a line is recognized well.
;;     This meas that the restriction about the location of begin/end
;;     becomes that "you can locate them any place in a line as long as
;;     there is only one begin/end in the line."
;;   1991/06/25 narazaki@nttslb.ntt.jp (Narazaki Shuji)
;;     Appending method for new symbol/environment name is changed to deal
;;     with its args.
;;   1991/07/19 narazaki@nttslb.ntt.jp (Narazaki Shuji)
;;     Long format for inserting symbol args is supported newly.
;;   1991/12/02 narazaki@nttslb.ntt.jp (Narazaki Shuji)
;;     User interface of texcomp:insert-symbol is modified.
;;   1992/01/21 narazaki@nttslb.ntt.jp (Narazaki Shuji)
;;     Dealing with TeX symbols which includes "*" correctly.
;;
;; How to define the command with args.
;;  Variables: texcomp:environment-completion-list is  the lists of the
;;  following list.
;;    1. (NAME)
;;          NAME is the string for the command name.
;;          This produces:
;;          \begin{NAME}
;;          \end{NAME}
;;    2. (NAME . ARGS)
;;         ARGS is the string which is insert after \begin{NAME}, namely:
;;         \begin{NAME}ARGS
;;         \end{NAME}
;;    Both produce the following when invoked with C-u:
;;         \begin{NAME}ARGS
;;         REGION
;;         \end{NAME}
;;	   where REGION means the region between mark and point.
;;
;;  Variables: texcomp:symbol-completion-list is  the lists of the following
;;  list.
;;    1. (NAME)
;;          NAME is the string for the command name.
;;          This produces:
;;          No args	=>	\NAME
;;          With C-u	=>	{\NAME REGION}
;;    2. (Name . Argstr)
;;          Argstr is the argument string for command: Name.
;;          No args	=>	\NameArgstr{}
;;          With C-u	=>	\NameArgstr{REGION}
;;    3. (Name Prefix Postfix)
;;          No args	=>	NamePrefixPostfix
;;	    With C-u	=>	NamePrefixREGIONPostfix

;;; Code:
(provide 'tex-completion)
(require 'tex-mode)

(defvar texcomp:environment-completion-list
  '(("abstract")
    ("align")
    ("align*")
    ("aligned")
    ("alltt")
    ("array" . "[tb]{}")
    ("center")
    ("comment")
    ("description" . "\n\\item[]\n")
    ("Description" . "[][0mm]")
    ("displaymath" . "should be replaced with \\[")
    ("document")
    ("enumerate" . "%\\itemsep8pt\n\\item\n")
    ("eqnarray" . "should be replaced with align")
    ("eqnarray*". "should be replaced with align")
    ("equation")
    ("figure" . "\n\\caption{}\n\\label{}\n")
    ("figure*" . "\\centering\n\\caption{}\n\\label{}\n")
    ("float")
    ("flushleft" . "\t% ’º¸’´ó’¤»")
    ("flushright" . "\t% ’±¦’´ó’¤»")
    ("footnotesize")
    ("indentation" . "{cm}")
    ("itemize" . "%\\itemsep8pt\n\\item\n")
    ("jdescription")
    ("list")
    ("math")
    ("minipage" . "[tb]{mm}")
    ("Para")
    ("picture" . "(X,Y)(0,0)\\setlength{\\unitlength}{1mm}")
    ("quotation")
    ("quote")
    ("sloppypar")
    ("small")
    ("tabbing")
    ("table" ."\n\\caption{}\n\\label{}\n")
    ("table*" . "\\centering\n\\caption{}\n\\label{}\n")
    ("tabular" . "[tb]{}")
    ("tabular*" . "[tb]{}")
    ("thebibliography" . "{99}")
    ("theindex")
    ("theorem" . "[]")
    ("titlepage")
    ("trivlist")
    ("verbatim")
    ("verbatim*")
    ("verse")
    ;; for beamer
    ("exampleblock" . "{}")
    ("alertblock" . "{}")
    ("block" . "{}")
    ("frame" . "[fragile]{}{}")
    ;; lstlisting
    ("lstlisting" . "[]\t%firstnumber=last")
    ("columns" . "\n\\begin{column}{0.5\\textwidth}\n\\end{column}\n")
    ("column" . "{0.5\\textwidth}")
    ;; PGK/tkiZ
    ("tikzpicture". "[\n    overlay\n    , xshift=0.5\\textwidth\n]")
    ("scope" . "[]")
    ("pgfonlayer" . "{background}")

    ;; tcolorbox
    ("codeof" . "{language=}{}")
    ("tcolorbox" . "{}")
    ("term" . "{}")
    ("answerbox" . "{}")

    ;; others
    ("markdown")
    )
  "Alist of the words(string) which are used as names of tex environment.
The cdr part of elements represents the argument string of the environment.")

(defvar texcomp:symbol-completion-list
  '(("\\")				; escape symbol itself
    ("[")
    ("]")
    ("(")
    (")")
    ("lceil")
    ("rceil")
    ;; ("-")				; allow hyphenation

    ;; font name
    ("selectfont")
    ("gtfamily")
    ("mcfamily")
    ("rmfamily")
    ("sffamily")
    ("ttfamily")
    ("bf")
    ("cal")
    ("dg")
    ("dm")
    ("em")
    ("it")
    ("footnotesize")
    ("normalsize")
    ("rm")
    ("sc")
    ("scriptsize")
    ("sf")
    ("sl")
    ("small")
    ("tiny")
    ("tt")
    ("textbf" . "")
    ("textit" . "")
    ("textsl" . "")
    ("texttt" . "")

    ;; font size
    ("fontsize" "{" "}{}\\selectfont")
    ("huge")
    ("Huge")
    ("large")
    ("Large")
    ("LARGE")

    ("`" . "")
    ("~" . "")
    ("v" . "")
    ("c" . "")
    ("'" . "")
    ("^" . "")
    ("." . "")
    ("\"" . "")

    ;; greek letter
    ("alpha")
    ("beta")
    ("gamma")
    ("delta")
    ("epsilon")
    ("varepsilon")
    ("zeta")
    ("eta")
    ("theta")
    ("vetheta")
    ("iota")
    ("kappa")
    ("lambda")
    ("mu")
    ("nu")
    ("xi")
    ("o")
    ("pi")
    ("varpi")
    ("rho")
    ("varrho")
    ("sigma")
    ("varsigma")
    ("tau")
    ("upsilon")
    ("phi")
    ("varphi")
    ("chi")
    ("psi")
    ("omega")
    ("Gamma")
    ("Delta")
    ("Theta")
    ("Lambda")
    ("Xi")

    ;; symbols for math mode
    ("bigl")
    ("bigm")
    ("bigr")
    ("Bigl")
    ("Bigm")
    ("Bigr")
    ("biggl")
    ("biggm")
    ("biggr")
    ("downarrow")
    ("Downarrow")
    ("frown")
    ("leftarrow")
    ("Leftarrow")
    ("rightarrow")
    ("Rightarrow")
    ("leftrightarrow")
    ("Leftrightarrow")
    ("longleftarrow")
    ("Longleftarrow")
    ("longrightarrow")
    ("Longrightarrow")
    ("longleftrightarrow")
    ("Longleftrightarrow")
    ("langle")
    ("nonumber")
    ("prec")
    ("preceq")
    ("rangle")
    ("stackrel" . "{}")
    ("succ")
    ("succeq")
    ("uparrow")
    ("Uparrow")
    ("updownarrow")
    ("Updownarrow")

    ("approx")				; ’ÇÈ’Àþ’¤Î’¡á
    ("bigcap")
    ("bigcirc")				; ’¡û
    ("bigcup")
    ("bigvee")
    ("bigwedge")
    ("bot")				; ’¢Ý
    ("Box")				; ’¢¢
    ("cap")				; ’¢Á
    ("cdot")				; ’¡¦
    ("clubsuit")
    ("circ")				; ’Ãæ’Çò’´Ý
    ("cup")				; ’¢À
    ("diamondsuit")
    ("Diamond")				; ’¡þ
    ("emptyset")			; ’¶õ’½¸’¹ç
    ("equiv")				; ’¢á
    ("Exists")
    ("exists")				; ’¢Ð
    ("Forall")
    ("forall")				; ’¢Ï
    ("geq")				; ’¡æ
    ("gg")				; ’¡Õ
    ("heartsuit")
    ("in")				; ’¢º
    ("leq")				; ’¡å
    ("ll")				; ’¡Ô
    ("mid")
    ("models")				; ’ÂÐ’±þ’¤¹’¤ë’Á´’³Ñ’Ê¸’»ú’¤Ê’¤·
    ("neg")				; ’¢Ì
    ("parallel")			; ’¡Â
    ("perp")				; ’¢Ý
    ("prec")				; ’ÂÐ’±þ’¤¹’¤ë’Á´’³Ñ’Ê¸’»ú’¤Ê’¤·
    ("prime")				; '
    ("sim")				; ’¡Á
    ("spadesuit")
    ("subset")				; ’¢¾
    ("subseteq")			; ’¢¼
    ("supset")				; ’¢¿
    ("supseteq")			; ’¢½
    ("succ")				; ’ÂÐ’±þ’¤¹’¤ë’Á´’³Ñ’Ê¸’»ú’¤Ê’¤·
    ("times")
    ("vdash")				; ’¨§ (’Æ³’½Ð’²Ä’Ç½’À­’¡Ë
    ("vee")				; ’¢Ë
    ("wedge")				; ’¢Ê
    ;; symbols of LaTeX and TeX

    ("acknowledgment")
    ("addtocounter" . "{}")
    ("addtolength" . "{}")
    ("advance")
    ("appendix")
    ("arabic")
    ("arraycolsep")
    ("arrayrulewidth")
    ("arraystrech")
    ("author" . "")
    ("backslash")
    ("baselineskip")
    ("begin" . "")
    ("bibitem" . "[]")
    ("bibliography" . "")
    ("bigskip")
    ("caption" . "")
    ("cdots")
    ("centering")
    ("chapter" . "")
    ("circle" . "")
    ("cite" .  "")
    ("cleardoublepage")
    ("clearpage")
    ("cline" . "")
    ("columnbreak")
    ("copyright")
    ("cr")
    ("dag")
    ("dashbox")
    ("date" . "")
    ("ddag")
    ("def")
    ("displaystyle")
    ("documentstyle" . "")
    ("documentclass" . "{} %article,book,report")
    ("eject")				; tex command
    ("empty")
    ("end" . "")
    ;; ("epsfile" "{file=" "width=1,height=1}")
    ("epsfig" "{file=" "width=SIZE,height=SIZE}")
    ("fbox" . "")
    ("footnote" . "")
    ("footnotemark")
    ("footnotetext")
    ("frac" . "{}")
    ("framebox" . "[lr][cm]")
    ("glossary")
    ("hfill")
    ("hide" . "")
    ("hline")
    ("hrule")
    ("hrulefill")
    ("hspace" . "")
    ("vspace*" . "")
    ("include" . "")
    ("includegraphics" . "[width=\\textwidth]")
    ("includeonly" . "")
    ("indent" . "")
    ("index" . "")
    ("infty")
    ("input" . "")
    ("item")
    ("label" . "")
    ("left")
    ("lefteqn" . "")
    ("let")
    ("ldots")
    ("line" . "(,)")
    ("linebreak" "[" "]")
    ("listoffigures")
    ("listoftables")
    ("locate" "{cm}{cm}")
    ("makeatletter")
    ("makeatother")
    ("makebox" . "(,)[lr]")
    ("makeglossary")
    ("makeindex")
    ("maketitle")
    ("marginpar" . "")
    ("markboth" . "{}")
    ("markright" . "")
    ("mbox" . "")
    ("medskip")
    ("multicolumn" . "{num}{lrcp{}}")
    ("multiput" . "(X,Y)(’¦¤X,’¦¤Y){times}")
    ("newcommand" . "{}")
    ("newenvironment" . "{}{}")
    ("newlength" . "")
    ("newline")
    ("newpage")
    ("newsavebox" . "")
    ("newtheorem" . "{}")
    ("noalign")
    ("noindent")
    ("nolinebreak")
    ("nopagebreak")
    ("normalsize")
    ("oval" "(,)[lrtb]" "")
    ("overline" . "")
    ("pagebreak")
    ("pagenumbering" . "")
    ("pageref")
    ("pagestyle" . "")
    ("paragraph" . "")
    ("parbox" . "{}")
    ("part" . "")
    ("pgfimage" "[width=0.3\\pagewidth]{" "}")
    ("protect")
    ("put" . "(,)")
    ("raggedleft")
    ("raggedright")
    ("raggedright")
    ("raisebox")
    ("ref" . "")
    ("renewcommand")
    ("right")
    ("roman")
    ("rule" . "[hieght]{width}")
    ("samepage")
    ("savebox")
    ("sbox" . "")
    ("scalebox" . "{1.0}")
    ("scriptscriptsize")
    ("scriptsize")
    ("section" "{" "}\t\t%%%%%%%%")
    ("section*" "{" "}\t\t%%%%%%%%")
    ("setlength" . "{}")
    ("setcounter" . "{}")
    ("shortstack" . "[]")
    ("site" . "")
    ("slash")				; /
    ("sloppy")
    ("smallskip")
    ("sqrt" . "[2]")
    ("subsection" "{" "}")
    ("subsection*" "{" "}")
    ("subsubsection" "{" "}")
    ("subsubsection*" "{" "}")
    ("subsubsubsection" "{" "}")
    ("subsubsubsection*" "{" "}")
    ("tabcolsep")
    ("tableofcontents")
    ("term" . "{}")
    ("thepage")
    ("tilde")
    ("title" . "")
    ("thanks" . "")
    ("thicklines")
    ("thinlines")
    ("thispagestyle")
    ("today")
    ("usebox")
    ("underbrace" . "_{}")
    ("underline" . "")
    ("usepackage" . "")
    ("vector" . "(X,Y)")
    ("verb")
    ("hfill")
    ("vline")
    ("vspace" . "")
    ("vspace*" . "")

    ;; parameters
    ("columnsep")
    ("columnseprule")
    ("columnwidth")
    ("evensidemargin")
    ("footinsertskip")
    ("footsep")
    ("floatsep")
    ("headheight")
    ("headsep")
    ("indentsep")			; list environment
    ("itemsep")				; list environment
    ("labelsep")			; list environment
    ("labelwidth")			; list environment
    ("leftmargin")			; list environment
    ("listparindent")			; list environment
    ("oddsidemargin")
    ("parindent")
    ("parsep")				; list environment
    ("parskip")
    ("partopsep")			; list environment
    ("rightmargin")			; list environment
    ("textheight")
    ("textfloatsep")
    ("textwidth")
    ("topmargin")
    ("topsep")				; list environment
    ("unitlength")

    ;; tabbing environment
    ("kill")
    (">")
    ("-")
    ("pushtab")
    ("<")
    ("=")
    ("poptab")
    ("+")

    ;; extended tables
    ("toprule")
    ("midrule")
    ("bottomrule")

    ;; for beamer
    ("alert")
    ("beamergotobutton" . "")

    ;; for lstlisting
    ("lstinputlisting" . "[]")

    ;; pgf/tikZ
    ("foreach" . "\\xxx in {,...,}")
    ("draw" "[] () .. controls +(0,0) and +(0,0) .. ()" ";")
    ("matrix" . "[matrix of nodes, nodes in empty cells, row/column sep,text height/depth/width, anchor/align, ampersand replacement=\\&]\n")
    ("node" "[] at () {}" ";")
    ("path")
    ("tikz" . "[overlay]")
    ("tikzstyle" . "{}=[]")
    ("usetikzlibrary" . "")
    ("visible" . "<>")
    ("url" . "")
    ("href" "{}{\\beamergotobutton{}}" "")
    ("textcolor" . "{}")

    ;; tcolorbox
    ("tcblower")
    ("tcbset" . "")

    ;; for style file
    ("@ifnextchar")
    ("@ifundefined")

    ("markdownInput" . "")

    ;; narazaki's symbols
    ("choice" . "")
    ("fillin" . "")
    ("Define" . "")
    ("DDefine" . "{}")
    ("PICTURE". "")
    ("goodanswer" . "")
    ("POINT" "[-2pt]{name}{" "}")
    ("TRUE")
    ("FALSE")
    ("BOTTOM")
    ("land")
    ("lor")
    ("lne")
    ("xor")
    )

  "Alist of the words(STRING) which is used as names of tex symbol. CDR
part of the pairs is either nil or string. If it is nil, then the symbol
does not acept any argument. If it is null string, the symbol requires
only 1 argument. Otherwise, it is the template string of the argument of
the symbol.")

;; (load (expand-file-name "~/.texcomp.el") 'noerror)

;; Bind commands to keys if they aren't bound to any key yet.
(mapc
 (function (lambda (list)
	     (let ((map (symbol-value (car (cdr list))))
		   (keys (car (cdr (cdr list))))
		   (command (eval (car (cdr (cdr (cdr list)))))))
	       (or (where-is-internal command map) ; set already ?
		   ;; (lookup-key latex-mode-map keys)
		   (define-key map keys command)))))
 '((define-key latex-mode-map "\\" 'texcomp:insert-symbol)
   (define-key latex-mode-map "{" 'texcomp:insert-environment-or-brace)
   (define-key latex-mode-map "\C-c\\" 'texcomp:insert-environment)
   (define-key latex-mode-map "\C-x\\" 'texcomp:insert-environment)
   (define-key latex-mode-map "\C-c\C-s" 'texcomp:strip-environment)
   (define-key latex-mode-map "\C-c\C-e" 'texcomp:end-current-environment)
   (define-key latex-mode-map "\C-c\C-j" 'texcomp:jump-to-environment-pair)
   ;;(define-key latex-mode-map "\M-\C-@" 'texcomp:mark-environment)
   (define-key latex-mode-map "\M-\C-h" 'texcomp:mark-environment)
   ;; (define-key latex-mode-map "\M-\C-u" 'texcomp:backward-up-environment)
   ;; (define-key latex-mode-map "\M-\C-f" 'texcomp:forward-environment)
   (define-key latex-mode-map "\M-\C-a" 'texcomp:beginning-of-environment)
   (define-key latex-mode-map "\M-\C-e" 'texcomp:end-of-environment)
   (define-key latex-mode-map "\C-c\C-i" 'tex-complete-symbol)
   (define-key latex-mode-map "\M-\C-k" 'texcomp:kill-environment)))

(let ((map (lookup-key tex-mode-map [menu-bar tex])))
  (when (keymapp map)
    (define-key-after map [insert-symbol]
      '("Insert TeX Symbol" . texcomp:insert-symbol-body) 'tex-kill-job)
    (define-key-after map [insert-environment]
      '("Insert TeX Environment" . texcomp:insert-environment) 'insert-symbol)))

(defvar texcomp:last-completion-evironment-name nil)
(defvar texcomp:last-completion-symbol-name nil)

;;;###autoload
(defun texcomp:insert-environment-or-brace (enclose)
  "Insert an environment block if followed by a space.
Otherwise insert a brace as is. If numeric arg(ENCLOSE) is given, the region
becomes 1st arg of the environment. The name is completed by using variable:
texcomp:symbol-completion-list."
  (interactive "*P")
  (let (key)
    (if enclose
	(texcomp:insert-environment enclose)
      (insert "{")
      (cond ((member (setq key (read-char)) '(?  ?\t))
	     (delete-char -1)
	     (texcomp:insert-environment enclose))
	    ((= key ?{)
	     (insert "{"))
	    (t
	     ;; (setq unread-command-char key)
	     (setq unread-command-events (list key))
	     )))))

;;;###autoload
(defun texcomp:insert-environment (enclose)
  "Insert the skelton of environment block. If given numeric arg, the
region is blocked in as the body of the environment. The name of
environment is completed using variable: texcomp:environment-completion-list.
If the name is unknown, then you can memorize it."
  (interactive "*P")
  (let (name loc arg end-mark (column 0))
    (setq name
	  (completing-read
	   (if (stringp texcomp:last-completion-evironment-name)
	       (concat "Insert environment name (default "
		       texcomp:last-completion-evironment-name
		       "): ")
	     "Insert environment name: ")
	   texcomp:environment-completion-list
	   nil nil))
    (if (string= name "")
	(setq name texcomp:last-completion-evironment-name))
    (setq texcomp:last-completion-evironment-name name)
    ;; If name is an unknown, long string, memorize it.
    (and (null (assoc name texcomp:environment-completion-list))
	 (< 3 (length name))
	 (texcomp:add-environment-name
	  (read-minibuffer "Edit the args pattern: "
			   (concat "(\"" name "\" )"))))
    ;; arg will be string: template of arguments of NAME(LaTeX command) or
    ;; nil.
    (setq arg (cdr (assoc name texcomp:environment-completion-list)))
    ;; added by narazaki 1990 November 1
    (if (and (marker-buffer (mark-marker))
	     (= (point-marker) (mark-marker)))
	(setq enclose nil))
    (if enclose
	(progn
	  (setq end-mark (copy-marker (if (< (point-marker) (mark-marker))
					  (mark-marker)
					(point-marker))))
	  (goto-char (if (< (point-marker) (mark-marker))
			 (point-marker)
		       (mark-marker))))
      (setq column (current-column)))
    (insert "\\begin{" name "}")
    (setq loc (point))
    (if arg (insert arg))
    (insert "\n")
    (if enclose
	(progn
	  (goto-char end-mark)
	  (or (zerop (current-column))
	      (insert "\n")))
      ;; Go forward until reached the column of the beginning of \begin
      (insert-char ?  column))
    (insert "\\end{" name "}\n")
    (goto-char (1+ loc))))

(defun texcomp:insert-symbol (enclose)
  "Insert a symbol of LaTeX. If numeric arg(ENCLOSE) is given, the region
becomes 1st arg of the symbol. The name is completed by using variable:
texcomp:symbol-completion-list."
  (interactive "*P")
  (let (key)
    (if enclose
	(texcomp:insert-symbol-body enclose)
      (insert "\\")
      (cond ((member (setq key (read-char)) '(? ?\t))
	     (delete-char -1)
	     (texcomp:insert-symbol-body enclose))
	    ((= key ?\\)
	     (insert "\\"))
	    (t
	     ;; (setq unread-command-char key)
	     (setq unread-command-events (list key))
	     )))))

(defun texcomp:insert-symbol-body (enclose)
  (interactive "*P")
  (let (name loc arg end-mark)
    (setq name
	  (completing-read
	   (if (stringp texcomp:last-completion-symbol-name)
	       (concat "Insert Symbol name (default "
		       texcomp:last-completion-symbol-name
		       "): ")
	     "Insert symbol name: ")
	     texcomp:symbol-completion-list
	     nil nil))
    (if (string= name "")
	(setq name texcomp:last-completion-symbol-name))
    (setq texcomp:last-completion-symbol-name name)
    ;; If name is an unknown, long string, memorize it.
    (and (null (assoc name texcomp:symbol-completion-list))
	 (< 3 (length name))
	 (texcomp:add-symbol-name
	  (read-minibuffer "Edit the args pattern: "
			   (concat "(\"" name "\" )"))))
    (setq arg (cdr (assoc name texcomp:symbol-completion-list)))
    (or (marker-position (mark-marker))
	(set-marker (mark-marker) (point)))
    (if enclose
	(progn
	  (setq end-mark (copy-marker (if (< (point-marker) (mark-marker))
					  (mark-marker)
					(point-marker))))
	  (goto-char (if (< (point-marker) (mark-marker))
			 (point-marker)
		       (mark-marker)))))
    (setq loc (point))
    (insert "\\" name)
    (if (null arg)
	(when enclose
	  (insert " ")
	  (if (< end-mark (point))
	      (set-marker end-mark (point)))
	  ;; closing region by braces
	  (goto-char loc)
	  (insert "{")
	  (goto-char end-mark)
	  (insert "}"))
      (setq loc (point))
      (if (consp arg)
	  (and (car arg) (insert (car arg)))
	(insert arg "{"))
      (if (and enclose (< (point) end-mark)) ; darty patch
	  (goto-char end-mark))
      (if (consp arg)
	  (and (car (cdr arg)) (insert (car (cdr arg))))
	(insert "}"))
      (goto-char (1+ loc)))))

(defun texcomp:add-environment-name (name)
  "Push a new environment NAME to texcomp:environment-completion-list."
  (interactive "xInput new environment name: ")
  (let ((newpair (cond ((consp name) name)
		       ((stringp name) (list name))
		       ((symbolp name) (list (symbol-name name)))))
	(name&def (assoc (car name) texcomp:environment-completion-list)))
    (if name&def
	(rplacd name&def (cdr newpair))
	(setq texcomp:environment-completion-list
	      (cons newpair texcomp:environment-completion-list)))))

(defun texcomp:add-symbol-name (name)
  "Push a symbol NAME to texcomp:symbol-completion-list."
  (interactive "xInput new symbol name: ")
  (let ((newpair (cond ((consp name) name)
		       ((stringp  name) (list name))
		       ((symbolp name) (list (symbol-name name)))))
	(name&def (assoc (car name) texcomp:symbol-completion-list)))
    (if name&def
	(rplacd name&def (cdr newpair))
	(setq texcomp:symbol-completion-list
	      (cons newpair texcomp:symbol-completion-list)))))

(defun texcomp:strip-environment ()
  "Delete both of begin and end of the environment under the current
line. The location of current position is marked."
  (interactive "*")
  (let ((name "")			; string of environment name
	(level 1)			; depth of environment
	temp				; push down list of env. name
	forward)			; search direction flag
    ;; Search environment name in the current line.
    (let ((end 0))
      (end-of-line)
      (setq end (point))
      (beginning-of-line 1)
      (or (re-search-forward "\\\\\\(begin\\|end\\){\\([^}]+\\)}" end t)
	  (error "No environment name in curent line!")))
    (if (eq (char-after (match-beginning 1)) ?b)
	(setq forward t)		; search "\end" forward
      (setq forward nil))		; search "\begin" backward
    (setq name (regexp-quote (buffer-substring (match-beginning 2) (match-end 2))))
    (beginning-of-line 1)
    (kill-line 1)
    (push-mark (point))		; remember the loc. of the head
    ;;(delete-region (match-beginning 0) (match-end 0))
    (texcomp:search-environment-pair (point) name forward)
    (goto-char (match-beginning 0))
    (kill-line 1)))

(defun texcomp:search-environment-pair (loc name forward &optional error)
  (let ((level 1)			; depth of environment
	(temp nil))			; push down list of env. name
    (while (< 0 level)
      (if forward
	  (setq temp (re-search-forward
;;		      (concat "^[ \t]*\\\\\\(begin\\|end\\){" name "}")
		      (concat "\\\\\\(begin\\|end\\){" name "}")
		      (point-max) t))
	(setq temp (re-search-backward
		    (concat "\\\\\\(begin\\|end\\){" name "}")
		    (point-min) t)))
      (cond ((null temp)
	     (setq level -1))
	    ((eq (char-after (match-beginning 1)) ?b)
	     (setq level (if forward (1+ level) (1- level))))
	    ((eq (char-after (match-beginning 1)) ?e)
	     (setq level (if forward (1- level) (1+ level))))
	    (t
	     (setq level (- level)))))
    (cond ((zerop level) (point))
	  (error (error "Unbalanced environment: %s" name)))))

;;;###autoload
(defun texcomp:end-current-environment ()
  "Close the current most-inner environment."
  (interactive "*")
  (let ((level 1)			; depth of environment
	(here (copy-marker (point-marker))) ; position to insert string
	(namelist nil)			; push down list of env. name
	(name "")			; name of most-inner env.
	temp)				; regexp matched ?
    (while (< 0 level)
      (setq temp (re-search-backward
;;		  (concat "^[ \t]*\\\\\\(begin\\|end\\){\\([^}]+\\)}")
		  (concat "\\\\\\(begin\\|end\\){\\([^}]+\\)}")
		  1 t))
      (if temp
	  (setq name
		(regexp-quote (buffer-substring (match-beginning 2) (match-end 2)))))
      (cond ((null temp)
	     (setq level (- level)))
	    ((eq (char-after (match-beginning 1)) ?b)
	     (if (or (string= name (car namelist)) (null namelist))
		 (setq namelist (cdr namelist))
	       (error "Unmatched environment:%s" name))
	     (setq level (1- level)))
	    ((eq (char-after (match-beginning 1)) ?e)
	     (setq namelist (cons name namelist))
	     (setq level (1+ level)))
	    (t
	     (setq level -1))))
    ;; Now level must be either 0 or minus number.
    ;; 0 means the environment was found. minus meams abnormally exit.
    (if (zerop level)
	(let ((start-column 0))		; column num. of the start of "\begin"
	  (goto-char (match-beginning 0))
	  (setq start-column (current-column))
	  (setq name (buffer-substring (match-beginning 2) (match-end 2)))
	  (goto-char here)
	  (if (< (current-column) start-column)
	      (progn (move-to-column start-column)
		     (if (< (current-column) start-column)
			 (insert-char ? (- start-column (current-column))))))
	  (insert "\\end{" name "}"))
      (if (= level -1)
	  (error "I think all environment are closed, isn't it ?")
      (error "Mismatched envrionment")))))

(defun texcomp:jump-to-environment-pair ()
  "Jump to the position of the pair command of the current environment.
Current (before executing this funciton) position is marked."
  (interactive)
  (let ((name "")			; string of environment name
	(level 1)			; depth of environment
	(temp nil)			; push down list of env. name
	forward)			; search direction flag
    ;; Search environment name in the current line.
    (let ((end 0))
      (end-of-line)
      (setq end (point))
      (beginning-of-line 1)
      (or (re-search-forward "\\\\\\(begin\\|end\\){\\([^}]+\\)}" end t)
	  (error "No environment name in curent line!")))
    (if (eq (char-after (match-beginning 1)) ?b)
	(setq forward t)		; search "\end" forward
      (setq forward nil))		; search "\begin" backward
    (setq name (regexp-quote (buffer-substring (match-beginning 2) (match-end 2))))
    (push-mark (match-beginning 0))
    (if forward
	(goto-char (match-end 0))
      (goto-char (match-beginning 0)))
    ;; OK, start searching!
    ;; (texcomp:search-environment-pair (point) name forward)
    ;;(texcomp:scan-environment (point) (if forward 1 -1))
    (texcomp:search-environment-terminator (if forward 1 -1))
    (goto-char (match-beginning 0))))

(defun texcomp:mark-environment ()
  "Set mark the environment from point."
  (interactive)
  (let (beg end search)
    (end-of-line)
    (setq end (point))
    (beginning-of-line)
    (setq beg (point))
    (texcomp:jump-to-environment-pair)
    (if (< (point) end)
	(setq beg (point))
      (end-of-line)
      (setq end (point)))
    ;; texcomp:jump-to-environment-pair set mark at the location of starting
    ;; searching.
    (pop-mark)
    (push-mark end)
    (goto-char beg)))

;;;###autoload
(defun texcomp:backward-up-environment (arg)
  "Move backward the head of current level of environment."
  (interactive "p")
  (texcomp:up-environment (- arg)))

;;;###autoload
(defun texcomp:up-environment (arg)
  "Move forward out of one level of parentheses.
With argument, do this that many times.
A negative argument means move backward but still to a less deep spot."
  (interactive "p")
  (let ((inc (if (> arg 0) 1 -1))	; increment value
	(points (texcomp:scan-environment (point) arg)))
    (cond ((null points)
	   (error "Something is wrong."))
	  ((= inc 1)			; go forward
	   (goto-char (cdr points)))
	  ((= inc -1)
	   (goto-char (car points)))
	  (t
	   (error "Something is wrong!")))))

(defun texcomp:scan-environment (from count)
  "Scan from character number FROM by COUNT environments' terminator.
Return the cons of character numbers of the position thus found.
The car of the cons is the starting point of matched string. The cdr is
the end of it.

If DEPTH is nonzero, environment depth begins counting from that value,
only places where the depth in environment becomes zero are candidates for
stopping; COUNT such places are counted. Thus, a positive value for DEPTH
means go out levels.

If the begginning or end of (the visible part of) the buffer is readched
and the depth is wrong, an error is signaled.
If the depth is right but the count is not used up, nil is returned."
  (let ((inc (if (< 0 count) 1 -1))	; increment value
	(env-starter (if (< 0 count) ?b ?e))
	(env-terminator (if (< 0 count) ?e ?b))
	(namelist nil)			; push down list of env. name
	(name "")			; name of most-inner env.
	temp				; regexp matched ?
        (back-to-same-level nil)	; loop exit flag
	not-reached)			; exception flag
    (while (/= count 0)
      (setq temp (funcall
		  (if (< 0 count) (function re-search-forward)
		    (function re-search-backward))
;;		  (concat "^[ \t]*\\\\\\(begin\\|end\\){\\([^}]+\\)}")
		  (concat "\\\\\\(begin\\|end\\){\\([^}]+\\)}")
		  (point-max) t))
      (if temp
	  (setq name (regexp-quote
		      (buffer-substring (match-beginning 2) (match-end 2)))))
      (cond ((null temp)
	     (if namelist
		 (error "Mismatched envrionment")
	       ;; Exception is occured.
	       (setq not-reached t
		     count 0)))
	    ((eq (char-after (match-beginning 1)) env-starter)
	     (cond ((and (null namelist) (= count inc))
		    (setq count (- count inc)))
		   (t
		    (setq namelist (cons name namelist)))))
	    ((eq (char-after (match-beginning 1)) env-terminator)
	     (cond ((string= name (car namelist))
		    (setq namelist (cdr namelist))
		    (setq count (- count inc)))
		   (t
		    (error "Unmatched environment: %s" name))))))
    (cond (not-reached nil)
	  ((< 0 inc) (match-end 0))
	  (t (match-beginning 0)))))

(defun %%texcomp:scan-environment (from count depth)
  (let ((inc (if (> count 0) 1 -1))	; increment value
	(namelist nil)			; push down list of env. name
	(name "")			; name of most-inner env.
	temp				; regexp matched ?
        (back-to-same-level nil)	; loop exit flag
	not-reached)			; exception flag
    (while (/= count 0)
      (if (< inc 0)			; backward ?
	  (setq temp (re-search-backward
		      (concat "^[ \t]*\\\\\\(begin\\|end\\){\\([^}]+\\)}")
		      (point-min) t))
	(setq temp (re-search-forward
		    (concat "^[ \t]*\\\\\\(begin\\|end\\){\\([^}]+\\)}")
		    (point-max) t)))
      (if temp (setq name (buffer-substring (match-beginning 2) (match-end 2))))
      (cond ((null temp)
	     (if namelist
		 (error "Mismatched envrionment")
	       (setq not-reached t)))
	    ((eq (char-after (match-beginning 1)) ?b)
	     (cond ((and (null namelist) (= count -1))
		    (setq count (- count inc)))
		   ((< 0 inc)		; forward
		    (setq namelist (cons name namelist)))
		   ((< inc 0)		; backward
		   (if (string= name (car namelist))
		       (setq namelist (cdr namelist))
		     (error "fail to search backward")))
		   (t (error "Unmatched environment: %s" name))))
	    ((eq (char-after (match-beginning 1)) ?e)
	     (cond ((and (null namelist) (= count 1))
		    (setq count (- count inc)))
		   ((< 0 inc)
		    (if (string=  name (car namelist))
			(setq namelist (cdr namelist))
		      (error "fail to search forward")))
		   ((< inc 0)		; backward
		    (setq namelist (cons name namelist)))))
	    (t
	     ;; (setq depth -1)
	     (error "I think all environment are closed, isn't it ?")))
      (if (= count 0)
	  (setq back-to-same-level t)))
    ;; Initialize variables for next loop.
    (setq depth 0)
    (setq back-to-same-level nil)
    (setq namelist nil)
    (setq count (- count inc))
    (if not-reached
	nil
      (cons (match-beginning 0) (match-end 0)))))

(defun texcomp:search-environment-terminator (dir)
  "Move to the terminator of the current environment.
If dir is plus, search forward. If dir is nonplus, saerch backward."
  (let ((start (point))			; position of starting searching
	(name "")			; string of environment name
	(in (if (< 0 dir) ?b ?e))	; begin of environment
	(out (if (< 0 dir) ?e ?b))	; end of environment
	(level 1)			; depth of environment
	(namelist nil)			; push down list of env. name
	(temp nil))
    (while (< 0 level)
      ;;(message "%d" level)
      (setq temp (if (< 0 dir)
		     (re-search-forward
;;		      "\\(^\\|\015\\)[ \t]*\\\\\\(begin\\|end\\){\\([^}]+\\)}"
		      "\\\\\\(begin\\|end\\){\\([^}]+\\)}"
					(point-max) t)
		   (re-search-backward
		    ;; "\\(^\\|\015\\)[ \t]*\\\\\\(begin\\|end\\){\\([^}]+\\)}"
		    "\\\\\\(begin\\|end\\){\\([^}]+\\)}"
				       1 t)))
      (if temp
	  (setq name (regexp-quote
		      (buffer-substring (match-beginning 2) (match-end 2)))))
      (cond ((null temp)
	     (setq level (- level)))
	    ((eq (char-after (match-beginning 1)) in)
	     (if  (/= start (match-beginning 0))
		  ;; If starting point of searching contains in, then
		  ;; ignore it !!
		  (progn
		    ;; (message "%d %d" start (match-beginning 0))
		    (setq namelist (cons name namelist))
		    (setq level (1+ level)))))
	    ((eq (char-after (match-beginning 1)) out)
	     (if (or (string= name (car namelist)) (null namelist))
		 (setq namelist (cdr namelist))
	       (error "Unmatched environment:%s" name))
	     (setq level (1- level)))
	    (t
	     (setq level -1))))
    (goto-char (funcall (if (< 0 dir) (function match-end)
			  (function match-beginning))
			0))))

;;;###autoload
(defun texcomp:forward-environment (&optional arg)
  "Move forward across one balanced environment.
With argument, do this that many times."
  (interactive "p")
  (or arg (setq arg 1))
  (goto-char (or (texcomp:scan-environment (point) arg) (buffer-end arg))))

;;;###autoload
(defun texcomp:backward-environment (&optional arg)
  "Move backward across one balanced environment.
With argument, do this that many times."
  (interactive "p")
  (or arg (setq arg 1))
  (texcomp:forward-environment (- arg)))

;;;###autoload
(defun texcomp:down-environment (arg)
  "Move forward down one level of environment.
With argument, do this that many times.
A negative argument menas move backward but still go down a level."
  (interactive "p")
  (let ((inc (if (> arg 0) 1 -1)))
    (while (/= arg 0)
      (goto-char (or (texcomp:scan-environment (point) inc)
		     (buffer-end arg)))
      (setq arg (- arg inc)))))

;;;###autoload
(defun texcomp:end-of-environment ()
  (interactive)
  (texcomp:search-environment-terminator 1))

;;;###autoload
(defun texcomp:beginning-of-environment ()
  (interactive)
  (texcomp:search-environment-terminator -1))

;;;###autoload
(defun texcomp:kill-environment ()
  "Kill the environment in current line."
  (interactive "*")
;;  (beginning-of-line)
  (let ((beg (point))
	end)
    (texcomp:end-of-environment)
    (kill-region beg (point))))

;;;###autoload
(defun tex-complete-symbol ()
  (interactive)
  (let* ((end (point))
	 (beg (save-excursion
		(re-search-backward "\\\\")
		(1+ (point))))
	 (pattern (buffer-substring beg end))
	 (predicate
;	  (if (eq (char-after (1- beg)) ?\()
;	      'fboundp
;	    (function (lambda (sym)
;			(or (boundp sym) (fboundp sym)
;			    (symbol-plist sym)))))
	  nil
)
	 (completion
	  (try-completion pattern texcomp:symbol-completion-list predicate)))
    (cond ((eq completion t))
	  ((null completion)
	   (message "Can't find completion for \"%s\"" pattern)
	   (ding))
	  ((not (string= pattern completion))
	   (delete-region beg end)
	   (insert completion))
	  (t
	   (message "Making completion list...")
	   (let ((list
		  (all-completions pattern texcomp:symbol-completion-list predicate)))
	     (or (eq predicate 'fboundp)
		 (let (new)
		   (while list
		     (setq new (cons (if (fboundp (intern (car list)))
					 (list (car list) " <f>")
				       (car list))
				     new))
		     (setq list (cdr list)))
		   (setq list (nreverse new))))
	     (with-output-to-temp-buffer "*Help*"
	       (display-completion-list list)))
	   (message "Making completion list...%s" "done")))))

(provide 'texcomp)

;;; texcomp.el ends here
