" Vim syntax file for AccuRev
"
" Maintainer:   David P Thomas, <davidpthomas@gmail.com>
" Last Changed: Mon Aug 17 13:23:55 PDT 2009
"
if !exists("main_syntax")
  if version < 600
    syntax clear
  elseif exists("b:current_syntax")
    finish
  endif
  let main_syntax='accurev'
endif

"====================================================
"
" ********************
" Info
" ********************
syntax match accurevInfo /\(Plugin_Version\|client_ver\|server_ver\|Host\|Domain\|Server\ name\|Port\|Server\ time\|Shell\|Principal\|ACCUREV_BIN\|Client\ time\|Depot\|Basis\|Workspace\/ref\|Top\)\ \+:/
highlight accurevInfo term=NONE cterm=NONE gui=NONE ctermfg=Yellow ctermbg=NONE guifg=Yellow guibg=NONE

" ********************
" Element Properties
" ********************
syntax match accurevElement /\(status\|location\|dir\|Virtual\|id\|Real\|namedVersion\|modTime\|elemType\|hierType\|size\)\ \+:/
highlight accurevElement term=NONE cterm=NONE gui=NONE ctermfg=Yellow ctermbg=NONE guifg=Yellow guibg=NONE

" ********************
" Update
" ********************
syntax match accurevUpdateStarted /Update started/
syntax match accurevUpdateScanning /Scanning .*/
syntax match accurevUpdateCalculating /Calculating .*/
syntax match accurevUpdateMakingChanges /Making .* changes/
syntax match accurevUpdateComplete /Update complete/
syntax match accurevUpdateNoChanges /Already up to date. Nothing to do./
syntax match accurevUpdateFailed /Update failed\./
syntax match accurevUpdateContent /Content.*of /
syntax match accurevUpdateCreatingDir /Creating dir/
syntax match accurevUpdateRemovingRecursively /Recursively removing/
syntax match accurevUpdateRemoving /Removing/
syntax match accurevUpdateElementStranded /Element would be stranded .*/

syntax match accurevUpdatePreviewStarted /Update preview started/
syntax match accurevUpdatePreviewComplete /Update preview complete/
syntax match accurevUpdatePreviewCreatingDir /Would create dir/
syntax match accurevUpdatePreviewRemoving /Would remove/
syntax match accurevUpdatePreviewMakingChanges /Would make .* changes/
syntax match accurevUpdatePreviewContent /Would replace content of/

highlight accurevUpdateNotify term=NONE cterm=bold gui=bold ctermfg=Yellow ctermbg=NONE guifg=Yellow guibg=NONE
highlight accurevUpdateNotifyItalic term=NONE cterm=NONE gui=NONE ctermfg=White ctermbg=NONE guifg=White guibg=NONE
highlight accurevUpdateContent term=NONE cterm=NONE gui=NONE ctermfg=Green ctermbg=NONE guifg=Green guibg=NONE
highlight accurevUpdateCreatingDir term=NONE cterm=bold gui=bold ctermfg=White ctermbg=Green guifg=White guibg=Green
highlight accurevUpdateRemoving term=NONE cterm=NONE gui=NONE ctermfg=Red ctermbg=NONE guifg=Red guibg=NONE
highlight accurevUpdateRemovingRecursively term=NONE cterm=bold gui=bold ctermfg=White ctermbg=Red guifg=White guibg=Red
highlight accurevUpdateElementStranded term=NONE cterm=bold gui=bold ctermfg=White ctermbg=Red guifg=White guibg=Red

highlight link accurevUpdateStarted accurevUpdateNotify
highlight link accurevUpdateComplete accurevUpdateNotify
highlight link accurevUpdateFailed accurevUpdateNotify
highlight link accurevUpdateScanning accurevUpdateNotifyItalic
highlight link accurevUpdateCalculating accurevUpdateNotifyItalic
highlight link accurevUpdateMakingChanges accurevUpdateNotify
highlight link accurevUpdateNoChanges accurevUpdateNotify

highlight link accurevUpdatePreviewStarted accurevUpdateStarted
highlight link accurevUpdatePreviewComplete accurevUpdateComplete
highlight link accurevUpdatePreviewCreatingDir accurevUpdateCreatingDir
highlight link accurevUpdatePreviewRemoving accurevUpdateRemoving
highlight link accurevUpdatePreviewMakingChanges accurevUpdateMakingChanges
highlight link accurevUpdatePreviewContent accurevUpdateContent


" ********************
" History
" ********************
syntax match accurevHistoryElement /^\(element\|eid\):.*$/
syntax match accurevHistoryTransaction /transaction.*/ contains=accurevHistoryTransactionNumber,accurevHistoryTransactionType,accurevHistoryTransactionDateTime,accurevHistoryTransactionUser,accurevHistoryComment
syntax match accurevHistoryTransactionNumber /transaction \d\+;/me=e-1 contained
syntax match accurevHistoryTransactionType skipwhite /; [a-z]\+;/ms=s,me=e contained
syntax match accurevHistoryTransactionDateTime /\ \d\d\d\d\/\d\d\/\d\d\ \d\d:\d\d:\d\d/ contained
syntax match accurevHistoryTransactionUser /user: .*$/ contained
syntax match accurevHistoryComment /#.*$/
syntax match accurevHistoryAttributes /eid.*mdate.*cksum.*sz.*type.*/

highlight accurevHistoryElement term=NONE cterm=bold gui=bold ctermfg=White ctermbg=Blue guifg=Green guibg=NONE
highlight accurevHistoryTransaction term=NONE cterm=NONE gui=NONE ctermfg=NONE ctermbg=Red guifg=NONE guibg=Red
highlight accurevHistoryTransactionNumber term=NONE cterm=bold gui=bold ctermfg=White ctermbg=Red guifg=White guibg=Red
highlight accurevHistoryTransactionType term=NONE cterm=bold gui=bold ctermfg=White  ctermbg=Red guifg=White guibg=Red
highlight accurevHistoryTransactionDateTime term=NONE cterm=bold gui=bold ctermfg=White ctermbg=Red guifg=White guibg=Red
highlight accurevHistoryTransactionUser term=NONE cterm=bold gui=bold ctermfg=White ctermbg=Red guifg=White guibg=Red
highlight accurevHistoryComment term=NONE cterm=bold gui=bold ctermfg=Yellow ctermbg=NONE guifg=Yellow guibg=NONE
highlight accurevHistoryAttributes term=NONE cterm=bold gui=bold ctermfg=Green ctermbg=NONE guifg=Green guibg=NONE


" ********************
" Search 
" ********************
syntax match accurevSearchNoResults /No results found\./

highlight accurevSearchNotify term=NONE cterm=bold gui=bold ctermfg=Yellow ctermbg=NONE guifg=Yellow guibg=NONE

highlight link accurevSearchNoResults accurevSearchNotify

" ********************
" Element Status
" ********************
syntax match accurevSearchStatusOverlap /(overlap.\{-})/
syntax match accurevSearchStatusMember /(member)/
syntax match accurevSearchStatusKept /(kept)/
syntax match accurevSearchStatusModified /(modified)/
syntax match accurevSearchStatusDefunct /(defunct)/
syntax match accurevSearchStatusExternal /(external)/
syntax match accurevSearchStatusStranded /(stranded)/
syntax match accurevSearchStatusStale /(stale)/
syntax match accurevSearchStatusBacked /(backed)/

highlight accurevSearchStatusOverlap term=NONE cterm=bold gui=bold ctermfg=Red ctermbg=NONE guifg=Red guibg=NONE
highlight accurevSearchStatusMember term=NONE cterm=bold gui=bold ctermfg=Green ctermbg=NONE guifg=Green guibg=NONE
highlight accurevSearchStatusKept term=NONE cterm=bold gui=bold ctermfg=Yellow ctermbg=NONE guifg=Green guibg=NONE
highlight accurevSearchStatusModified term=NONE cterm=bold gui=bold ctermfg=Blue ctermbg=NONE guifg=Blue guibg=NONE
highlight accurevSearchStatusDefunct term=NONE cterm=bold gui=bold ctermfg=White ctermbg=Red guifg=White guibg=Red
highlight accurevSearchStatusExternal term=NONE cterm=bold gui=bold ctermfg=White ctermbg=Blue guifg=White guibg=Blue
highlight accurevSearchStatusStranded term=NONE cterm=bold gui=bold ctermfg=White ctermbg=Yellow guifg=White guibg=Yellow
highlight accurevSearchStatusStale term=NONE cterm=bold gui=bold ctermfg=White ctermbg=Yellow guifg=White guibg=Yellow
highlight accurevSearchStatusBacked term=NONE cterm=bold gui=bold ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE

" ********************
" Annotate
" ********************
highlight accurevAnnotate term=NONE cterm=NONE gui=NONE ctermfg=White ctermbg=Blue guifg=White guibg=Blue

"highlight link accurevSearchNoResults accurevSearchNotify


"====================================================
"
"
let b:current_syntax = "accurev"

if main_syntax == 'accurev'
  unlet main_syntax
endif

