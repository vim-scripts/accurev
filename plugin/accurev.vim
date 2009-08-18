" Copyright 2009 AccuRev, Inc
" 
" Licensed under the Apache License, Version 2.0 (the "License");
" you may not use this file except in compliance with the License.
" You may obtain a copy of the License at
" 
"     http://www.apache.org/licenses/LICENSE-2.0
" 
" Unless required by applicable law or agreed to in writing, software
" distributed under the License is distributed on an "AS IS" BASIS,
" WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
" See the License for the specific language governing permissions and
" limitations under the License.

" AccuRev SCM Integration for Vim
"
" Last Changed:   Sun Aug 16 07:35:48 PDT 2009
" Maintainer:     David P Thomas <davidpthomas@gmail.com>
" URL:            www.davidpthomas.name

" Section: Documentation {{{1
"
"   All documentation is available within vim by typing ':help accurev'.
"
"   If you cannot see the accurev help docs, load them as follows:
"
"       1. verify the help doc is available locally
"                Unix: ~/.vim/doc/accurev.txt
"             Windows: ~\vimfiles\doc\accurev.txt
"       2. Load the help doc from within Vim
"                Unix: :helptags ~/.vim/doc
"             Windows: :helptags ~\vimfiles\doc
"       3. View the help doc within Vim, ':help accurev'
"
" }}}

" Section: Plugin Initialization {{{1

" Sub-Section: Vim Plugin Pre-Load Setup {{{2

" Enable line continuation w/o disrupting compatibility mode
let s:save_cpo = &cpo
set cpo&vim

" }}}

" Sub-Section: Plugin Validation {{{2

" Prevent unintentional re-loading or redefining errors
if exists("g:loaded_accurev_plugin") | finish | endif
let g:loaded_accurev_plugin = 1

" Require Vim 7.0+; due to FuncRefs and Dictionary usage
if v:version < 700 | echomsg 'AccuRev: Plugin requires Vim 7.0 or greater' | finish | endif

" }}}

" Sub-Section: Script-Scoped Global Variables {{{2

" Version of this plugin
let s:accurev_plugin_version = "1.1.1"
let s:accurev_plugin_date = "2009.08.18"
let s:accurev_plugin_release = s:accurev_plugin_version . " " . s:accurev_plugin_date

" boolean variable aliases used in conditionals and function returns
let s:true = 1
let s:false = 0
let s:notfound = -1
let s:empty = ""

" TODO put in buffer; need to refactor view logic for multi-select
" delimiter for selectable comment widget
let s:comment_delimeter = "+--------------------------[ Enter Comment Above ]--------------------------+"
" }}}

" }}}

" Section: User Customizations {{{
" set the first key for all mappings aka <Leader>
let s:mapleader = '\'

" Determines if the accurev plugin is initialized/loaded during vim startup.
" Most people will load; common to disable if working over slow network connection
" and load/unload via key mappings to work in accurev only when necessary.
let s:load_on_startup = s:true "[s:true|s:false]

" flag to launch graphical merge on conflict; otherwise external, manual merge required
let s:graphical_merge_enabled = s:true "[s:true|s:false]

" flag to require non-empty comments
let s:require_comments = s:true

" show informational status messages during processing; minimally verbose
" - ideal for the curious user
let s:show_status_messages = s:false  " [s:true|s:false]

" turn on verbose user messaging at critical points; useful for debugging
let s:plugin_debugging = s:false " [s:true|s:false]

" turn on recording of all cli calls to the AccuRev server; key mapping displays history
let s:record_command_history = s:true  " [s:true|s:false]
" display output alongside cli in command history window (can be verbose!)
let s:verbose_command_history = s:false " [s:true|s:false]

" promote comment template; eg "BugId:####:"
let s:promote_comment_prefix = ""

" flag to prompt user for issue number on promote
let s:enable_issue_promote = s:false

" }}}

" Section:  Mappings {{{1
"
" Sub-Section:  Key Mappings {{{2

" Function: LoadBootMappings {{{3
" Description: Register mappings only available at boot time.  These mappings
"              essentially bootstrap the program and are avaiable even if the
"              plugin is configured to not load on startup.  These allow the
"              user to enable the plugin during the current session.
" Return: None.
function! s:LoadBootMappings()

  call s:DisplayDebug("Loading Boot Key/Plugin Mappings.")

  if !hasmapto('<Plug>AccurevLoadPlugin')
    nmap <buffer> <Leader>+   <Plug>AccurevLoadPlugin
    nnoremap <buffer> <script> <Plug>AccurevLoadPlugin <SID>LoadPlugin
  endif
  nnoremap <buffer> <silent> <SID>LoadPlugin :call <SID>LoadPlugin()<CR>

  if !hasmapto('<Plug>AccurevLaunchStreamBrowser')
    nmap <buffer> <Leader>sb   <Plug>AccurevLaunchStreamBrowser
    nnoremap <buffer> <script> <Plug>AccurevLaunchStreamBrowser <SID>LaunchStreamBrowser
  endif
  nnoremap <buffer> <silent> <SID>LaunchStreamBrowser :call <SID>LaunchStreamBrowser()<CR>

  if !hasmapto('<Plug>AccurevInfo')
    nmap <buffer> <Leader>i   <Plug>AccurevInfo
    nnoremap <buffer> <script> <Plug>AccurevInfo <SID>Info
  endif
  nnoremap <buffer> <silent> <SID>Info :call <SID>Info()<CR>

  if s:IsRunningGui()
    call s:LoadBootMenuMappings()
  end

endfunction " }}}

" Function: LoadAuthMappings {{{3
" Description: Register all keyboard mappings available after logging in.
" Return: None.
function! s:LoadAuthMappings()

  call s:DisplayDebug("Loading Auth Key/Plugin Mappings.")

  if !hasmapto('<Plug>AccurevUnloadPlugin')
    nmap <buffer> <Leader>-   <Plug>AccurevUnloadPlugin
    nnoremap <buffer> <script> <Plug>AccurevUnloadPlugin <SID>UnloadPlugin
  endif
  nnoremap <buffer> <silent> <SID>UnloadPlugin :call <SID>UnloadPlugin()<CR>

  if !hasmapto('<Plug>AccurevLogin')
    nmap <buffer> <Leader>l   <Plug>AccurevLogin
    nnoremap <buffer> <script> <Plug>AccurevLogin <SID>Login
  endif
  nnoremap <buffer> <silent> <SID>Login :call <SID>Login()<CR>

  if !hasmapto('<Plug>AccurevLogout')
    nmap <buffer> <Leader>x   <Plug>AccurevLogout
    nnoremap <buffer> <script> <Plug>AccurevLogout <SID>Logout
  endif
  nnoremap <buffer> <silent> <SID>Logout :call <SID>Logout()<CR>

  if !hasmapto('<Plug>AccurevAdd')
    nmap <buffer> <Leader>a   <Plug>AccurevAdd
    nnoremap <buffer> <script> <Plug>AccurevAdd <SID>Add
  endif
  nnoremap <buffer> <silent> <SID>Add :call <SID>Add()<CR>

  if !hasmapto('<Plug>AccurevKeep')
    nmap <buffer> <Leader>k   <Plug>AccurevKeep
    nnoremap <buffer> <script> <Plug>AccurevKeep <SID>Keep
  endif
  nnoremap <buffer> <silent> <SID>Keep :call <SID>Keep()<CR>

  if !hasmapto('<Plug>AccurevAnchor')
    nmap <buffer> <Leader>@   <Plug>AccurevAnchor
    nnoremap <buffer> <script> <Plug>AccurevAnchor <SID>Anchor
  endif
  nnoremap <buffer> <silent> <SID>Anchor :call <SID>Anchor()<CR>

  if !hasmapto('<Plug>AccurevPopulate')
    nmap <buffer> <Leader>v   <Plug>AccurevPopulate
    nnoremap <buffer> <script> <Plug>AccurevPopulate <SID>Populate
  endif
  nnoremap <buffer> <silent> <SID>Populate :call <SID>Populate()<CR>

  if !hasmapto('<Plug>AccurevPromote')
    nmap <buffer> <Leader>p   <Plug>AccurevPromote
    nnoremap <buffer> <script> <Plug>AccurevPromote <SID>Promote
  endif
  nnoremap <buffer> <silent> <SID>Promote :call <SID>Promote('single')<CR>

  if !hasmapto('<Plug>AccurevGroupPromote')
    nmap <buffer> <Leader>gp   <Plug>AccurevGroupPromote
    nnoremap <buffer> <script> <Plug>AccurevGroupPromote <SID>GroupPromote
  endif
  nnoremap <buffer> <silent> <SID>GroupPromote :call <SID>Promote('multi')<CR>

  if !hasmapto('<Plug>AccurevMerge')
    nmap <buffer> <Leader>m   <Plug>AccurevMerge
    nnoremap <buffer> <script> <Plug>AccurevMerge <SID>Merge
  endif
  nnoremap <buffer> <silent> <SID>Merge :call <SID>Merge()<CR>

  if !hasmapto('<Plug>AccurevSyncTime')
    nmap <buffer> <Leader>~   <Plug>AccurevSyncTime
    nnoremap <buffer> <script> <Plug>AccurevSyncTime <SID>SyncTime
  endif
  nnoremap <buffer> <silent> <SID>SyncTime :call <SID>SyncTime()<CR>

  if !hasmapto('<Plug>AccurevUpdate')
    nmap <buffer> <Leader>u   <Plug>AccurevUpdate
    nnoremap <buffer> <script> <Plug>AccurevUpdate <SID>Update
  endif
  nnoremap <buffer> <silent> <SID>Update :call <SID>Update()<CR>

  if !hasmapto('<Plug>AccurevUpdatePreview')
    nmap <buffer> <Leader>n   <Plug>AccurevUpdatePreview
    nnoremap <buffer> <script> <Plug>AccurevUpdatePreview <SID>UpdatePreview
  endif
  nnoremap <buffer> <silent> <SID>UpdatePreview :call <SID>UpdatePreview()<CR>

  if !hasmapto('<Plug>AccurevElementProperties')
    nmap <buffer> <Leader>e   <Plug>AccurevElementProperties
    nnoremap <buffer> <script> <Plug>AccurevElementProperties <SID>ElementProperties
  endif
  nnoremap <buffer> <silent> <SID>ElementProperties :call <SID>ElementProperties()<CR>

  if !hasmapto('<Plug>AccurevHistory')
    nmap <buffer> <Leader>h   <Plug>AccurevHistory
    nnoremap <buffer> <script> <Plug>AccurevHistory <SID>History
  endif
  nnoremap <buffer> <silent> <SID>History :call <SID>History()<CR>

  if !hasmapto('<Plug>AccurevAnnotate')
    nmap <buffer> <Leader>b   <Plug>AccurevAnnotate
    nnoremap <buffer> <script> <Plug>AccurevAnnotate <SID>Annotate
  endif
  nnoremap <buffer> <silent> <SID>Annotate :call <SID>Annotate()<CR>


  " Searches {{{
  if !hasmapto('<Plug>AccurevSearchPending')
    nmap <buffer> <Leader>sp   <Plug>AccurevSearchPending
    nnoremap <buffer> <script> <Plug>AccurevSearchPending <SID>SearchPending
  endif
  nnoremap <buffer> <silent> <SID>SearchPending :call <SID>Search('pending')<CR>

  if !hasmapto('<Plug>AccurevSearchModified')
    nmap <buffer> <Leader>sm   <Plug>AccurevSearchModified
    nnoremap <buffer> <script> <Plug>AccurevSearchModified <SID>SearchModified
  endif
  nnoremap <buffer> <silent> <SID>SearchModified :call <SID>Search('modified')<CR>

  if !hasmapto('<Plug>AccurevSearchKept')
    nmap <buffer> <Leader>sk   <Plug>AccurevSearchKept
    nnoremap <buffer> <script> <Plug>AccurevSearchKept <SID>SearchKept
  endif
  nnoremap <buffer> <silent> <SID>SearchKept :call <SID>Search('kept')<CR>

  if !hasmapto('<Plug>AccurevSearchNonMember')
    nmap <buffer> <Leader>sn   <Plug>AccurevSearchNonMember
    nnoremap <buffer> <script> <Plug>AccurevSearchNonMember <SID>SearchNonMember
  endif
  nnoremap <buffer> <silent> <SID>SearchNonMember :call <SID>Search('nonmember')<CR>

  if !hasmapto('<Plug>AccurevSearchDefaultGroup')
    nmap <buffer> <Leader>sd   <Plug>AccurevSearchDefaultGroup
    nnoremap <buffer> <script> <Plug>AccurevSearchDefaultGroup <SID>SearchDefaultGroup
  endif
  nnoremap <buffer> <silent> <SID>SearchDefaultGroup :call <SID>Search('defgroup')<CR>

  if !hasmapto('<Plug>AccurevSearchOverlap')
    nmap <buffer> <Leader>so   <Plug>AccurevSearchOverlap
    nnoremap <buffer> <script> <Plug>AccurevSearchOverlap <SID>SearchOverlap
  endif
  nnoremap <buffer> <silent> <SID>SearchOverlap :call <SID>Search('overlap')<CR>

  if !hasmapto('<Plug>AccurevSearchDeepOverlap')
    nmap <buffer> <Leader>sO   <Plug>AccurevSearchDeepOverlap
    nnoremap <buffer> <script> <Plug>AccurevSearchDeepOverlap <SID>SearchDeepOverlap
  endif
  nnoremap <buffer> <silent> <SID>SearchDeepOverlap :call <SID>Search('deepoverlap')<CR>

  if !hasmapto('<Plug>AccurevSearchModDefaultGroup')
    nmap <buffer> <Leader>sD   <Plug>AccurevSearchModDefaultGroup
    nnoremap <buffer> <script> <Plug>AccurevSearchModDefaultGroup <SID>SearchModDefaultGroup
  endif
  nnoremap <buffer> <silent> <SID>SearchModDefaultGroup :call <SID>Search('moddefgroup')<CR>

  if !hasmapto('<Plug>AccurevSearchExternal')
    nmap <buffer> <Leader>sx   <Plug>AccurevSearchExternal
    nnoremap <buffer> <script> <Plug>AccurevSearchExternal <SID>SearchExternal
  endif
  nnoremap <buffer> <silent> <SID>SearchExternal :call <SID>Search('external')<CR>

  if !hasmapto('<Plug>AccurevSearchMissing')
    nmap <buffer> <Leader>sM   <Plug>AccurevSearchMissing
    nnoremap <buffer> <script> <Plug>AccurevSearchMissing <SID>SearchMissing
  endif
  nnoremap <buffer> <silent> <SID>SearchMissing :call <SID>Search('missing')<CR>

  if !hasmapto('<Plug>AccurevSearchStranded')
    nmap <buffer> <Leader>ss   <Plug>AccurevSearchStranded
    nnoremap <buffer> <script> <Plug>AccurevSearchStranded <SID>SearchStranded
  endif
  nnoremap <buffer> <silent> <SID>SearchStranded :call <SID>Search('stranded')<CR>

  if !hasmapto('<Plug>AccurevSearchDefunct')
    nmap <buffer> <Leader>sX   <Plug>AccurevSearchDefunct
    nnoremap <buffer> <script> <Plug>AccurevSearchDefunct <SID>SearchDefunct
  endif
  nnoremap <buffer> <silent> <SID>SearchDefunct :call <SID>Search('defunct')<CR>

  if !hasmapto('<Plug>AccurevSearchStale')
    nmap <buffer> <Leader>su   <Plug>AccurevSearchStale
    nnoremap <buffer> <script> <Plug>AccurevSearchStale <SID>SearchStale
  endif
  nnoremap <buffer> <silent> <SID>SearchStale :call <SID>Search('stale')<CR>

  " }}}

  if !hasmapto('<Plug>AccurevDefunct')
    nmap <buffer> <Leader>!  <Plug>AccurevDefunct
    nnoremap <buffer> <script> <Plug>AccurevDefunct <SID>Defunct
  endif
  nnoremap <buffer> <silent> <SID>Defunct :call <SID>Defunct()<CR>

  if !hasmapto('<Plug>AccurevUndefunct')
    nmap <buffer> <Leader>*  <Plug>AccurevUndefunct
    nnoremap <buffer> <script> <Plug>AccurevUndefunct <SID>Undefunct
  endif
  nnoremap <buffer> <silent> <SID>Undefunct :call <SID>Undefunct()<CR>

  if !hasmapto('<Plug>AccurevRevertRecent')
    nmap <buffer> <Leader>rr  <Plug>AccurevRevertRecent
    nnoremap <buffer> <script> <Plug>AccurevRevertRecent <SID>RevertRecent
  endif
  nnoremap <buffer> <silent> <SID>RevertRecent :call <SID>RevertRecent()<CR>

  if !hasmapto('<Plug>AccurevRevertBacked')
    nmap <buffer> <Leader>rb  <Plug>AccurevRevertBacked
    nnoremap <buffer> <script> <Plug>AccurevRevertBacked <SID>RevertBacked
  endif
  nnoremap <buffer> <silent> <SID>RevertBacked :call <SID>RevertBacked()<CR>

  if !hasmapto('<Plug>AccurevDiffMostRecent')
    nmap <buffer> <Leader>dr  <Plug>AccurevDiffMostRecent
    nnoremap <buffer> <script> <Plug>AccurevDiffMostRecent <SID>DiffMostRecent
  endif
  nnoremap <buffer> <silent> <SID>DiffMostRecent :call <SID>Diff('mostrecent')<CR>

  if !hasmapto('<Plug>AccurevDiffBacked')
    nmap <buffer> <Leader>db  <Plug>AccurevDiffBacked
    nnoremap <buffer> <script> <Plug>AccurevDiffBacked <SID>DiffBacked
  endif
  nnoremap <buffer> <silent> <SID>DiffBacked :call <SID>Diff('backed')<CR>

  if !hasmapto('<Plug>AccurevDiffBasis')
    nmap <buffer> <Leader>da  <Plug>AccurevDiffBasis
    nnoremap <buffer> <script> <Plug>AccurevDiffBasis <SID>DiffBasis
  endif
  nnoremap <buffer> <silent> <SID>DiffBasis :call <SID>Diff('basis')<CR>

  if !hasmapto('<Plug>AccurevDiffExit')
    nmap <buffer> <Leader>dx  <Plug>AccurevDiffExit
    nnoremap <buffer> <script> <Plug>AccurevDiffExit <SID>DiffExit
  endif
  nnoremap <buffer> <silent> <SID>DiffExit :call <SID>DiffExit()<CR>

  if !hasmapto('<Plug>AccurevRefresh')
    nmap <buffer> <Leader><space>  <Plug>AccurevRefresh
    nnoremap <buffer> <script> <Plug>AccurevRefresh <SID>Refresh
  endif
  nnoremap <buffer> <silent> <SID>Refresh :call <SID>Refresh('user')<CR>

  " --- internal commands

  if !hasmapto('<Plug>AccurevCommandHistory')
    nmap <buffer> <Leader>?  <Plug>AccurevCommandHistory
    nnoremap <buffer> <script> <Plug>AccurevCommandHistory <SID>CommandHistory
  endif
  nnoremap <buffer> <silent> <SID>CommandHistory :call <SID>CommandHistory()<CR>

  if !hasmapto('<Plug>AccurevListBufferAttributes')
    nmap <buffer> <Leader>A  <Plug>AccurevListBufferAttributes
    nnoremap <buffer> <script> <Plug>AccurevListBufferAttributes <SID>ListBufferAttributes
  endif
  nnoremap <buffer> <silent> <SID>ListBufferAttributes :call <SID>ListBufferAttributes()<CR>

  if s:IsRunningGui()
    call s:LoadAuthMenuMappings()
  end

endfunction

" }}}

" Function: DeactivateAuthMappings {{{3
" Description: Disable all mappings that require user authentication.
" Return: None.
function! s:DeactivateAuthMappings()

  call s:DisplayDebug("Deactivating Auth Mappings.")

  " deregister plugin mappings; causes key bindings to not work as well
  nunmap <buffer> <SID>UnloadPlugin
  nunmap <buffer> <SID>Logout
  nunmap <buffer> <SID>Add
  nunmap <buffer> <SID>Keep
  nunmap <buffer> <SID>Anchor
  nunmap <buffer> <SID>Populate
  nunmap <buffer> <SID>Promote
  nunmap <buffer> <SID>GroupPromote
  nunmap <buffer> <SID>Merge
  nunmap <buffer> <SID>SyncTime
  nunmap <buffer> <SID>Update
  nunmap <buffer> <SID>UpdatePreview
  nunmap <buffer> <SID>ElementProperties
  nunmap <buffer> <SID>History
  nunmap <buffer> <SID>Annotate
  nunmap <buffer> <SID>SearchPending
  nunmap <buffer> <SID>SearchModified
  nunmap <buffer> <SID>SearchKept
  nunmap <buffer> <SID>SearchNonMember
  nunmap <buffer> <SID>SearchDefaultGroup
  nunmap <buffer> <SID>SearchOverlap
  nunmap <buffer> <SID>SearchDeepOverlap
  nunmap <buffer> <SID>SearchModDefaultGroup
  nunmap <buffer> <SID>SearchExternal
  nunmap <buffer> <SID>SearchMissing
  nunmap <buffer> <SID>SearchStranded
  nunmap <buffer> <SID>SearchDefunct
  nunmap <buffer> <SID>SearchStale
  nunmap <buffer> <SID>Defunct
  nunmap <buffer> <SID>Undefunct
  nunmap <buffer> <SID>RevertRecent
  nunmap <buffer> <SID>RevertBacked
  nunmap <buffer> <SID>DiffMostRecent
  nunmap <buffer> <SID>DiffBacked
  nunmap <buffer> <SID>DiffBasis
  nunmap <buffer> <SID>DiffExit
  nunmap <buffer> <SID>Refresh
  nunmap <buffer> <SID>CommandHistory
  nunmap <buffer> <SID>ListBufferAttributes

  if s:IsRunningGui()
    call s:DisableAuthMenuMappings()
  end

endfunction "}}}

" }}}
"
" Sub-Section:  GUI Mappings {{{2

" Function: LoadBootMenuMappings {{{3
" Description: Register menu mappings only available at boot time.
" Return: None.
function! s:LoadBootMenuMappings()

    " menus only work in Normal mode; mouseover tooltips provided
    nmenu <silent> &Plugin.&AccuRev.&Info<Tab>:i <Plug>AccurevInfo
      tmenu &Plugin.&AccuRev.&Info<Tab>:i Displays AccuRev client/server information

    " menus only work in Normal mode; mouseover tooltips provided
    nmenu <silent> &Plugin.&AccuRev.&LaunchStreamBrowser<Tab>:sb <Plug>AccurevLaunchStreamBrowser
      tmenu &Plugin.&AccuRev.&LaunchStreamBrowser<Tab>:sb Launch AccuRev Graphical Stream Browser

  nmenu &Plugin.AccuRev.-GlobalCommandsSeparator- :

    " menus only work in Normal mode; mouseover tooltips provided
    nmenu <silent> &Plugin.&AccuRev.&Enable<Tab>:+ <Plug>AccurevLoadPlugin
      tmenu &Plugin.&AccuRev.&Enable<Tab>:+ Enable AccuRev plugin


endfunction "}}}

" Function: LoadAuthMenuMappings {{{3
" Description: Register all keyboard mappings available after logging in.
" Return: None.
function! s:LoadAuthMenuMappings()

  call s:DisplayDebug("Loading Menu Mappings.")

  source $VIMRUNTIME/menu.vim
  set wildmenu
  set cpo-=<
  set wcm=<C-Z>
  map <F4> :emenu <C-Z>

  nunmenu &Plugin.&AccuRev.&Enable<Tab>:+


  " menus only work in Normal mode; mouseover tooltips provided
  nmenu &Plugin.&AccuRev.&Disable<Tab>:- <Plug>AccurevUnloadPlugin
    tmenu &Plugin.&AccuRev.&Disable<Tab>:- Disable AccuRev plugin

  nmenu &Plugin.AccuRev.-GlobalLoadUnloadSeparator- :

  " menus only work in Normal mode; mouseover tooltips provided
  nmenu &Plugin.&AccuRev.&Login<Tab>:l <Plug>AccurevLogin
    tmenu &Plugin.&AccuRev.&Login<Tab>:l Login to AccuRev
  nmenu &Plugin.&AccuRev.&Logout<Tab>:x <Plug>AccurevLogout
    tmenu &Plugin.&AccuRev.&Logout<Tab>:x Logout of AccuRev

  nmenu &Plugin.AccuRev.-BasicLoginLogoutSeparator- :

  nmenu &Plugin.&AccuRev.&Add<Tab>:a <Plug>AccurevAdd
    tmenu &Plugin.&AccuRev.&Add<Tab>:a Add current file to workspace
  nmenu &Plugin.&AccuRev.&Keep<Tab>:k <Plug>AccurevKeep
    tmenu &Plugin.&AccuRev.&Keep<Tab>:k Keep current file in workspace
  nmenu &Plugin.&AccuRev.&Anchor<Tab>:@ <Plug>AccurevAnchor
    tmenu &Plugin.&AccuRev.&Anchor<Tab>:@ Anchor current file to workspace
  nmenu &Plugin.&AccuRev.&Populate<Tab>:v <Plug>AccurevPopulate
    tmenu &Plugin.&AccuRev.&Populate<Tab>:v Populate current file in workspace
  nmenu &Plugin.&AccuRev.&Promote<Tab>:p <Plug>AccurevPromote
    tmenu &Plugin.&AccuRev.&Promote<Tab>:p Promote current file to parent stream
  nmenu &Plugin.&AccuRev.&Group.&Promote<Tab>:gp <Plug>AccurevGroupPromote
    tmenu &Plugin.&AccuRev.&Group.&Promote<Tab>:gp Promote selected files in default group
  nmenu &Plugin.&AccuRev.&Merge<Tab>:m <Plug>AccurevMerge
    tmenu &Plugin.&AccuRev.&Merge<Tab>:m Merge overlap (trivial changes only)
  nmenu &Plugin.AccuRev.-BasicCommandsSeparator- :
  nmenu &Plugin.&AccuRev.&Defunct<Tab>:! <Plug>AccurevDefunct
    tmenu &Plugin.&AccuRev.&Defunct<Tab>:! Defunct current file from workspace; version controlled delete
  nmenu &Plugin.&AccuRev.&Undefunct<Tab>:* <Plug>AccurevUndefunct
    tmenu &Plugin.&AccuRev.&Undefunct<Tab>:* Undefunct current file in workspace; reactivate defuncted file
  nmenu &Plugin.&AccuRev.&Revert\ To.&Recent<Tab>:rr <Plug>AccurevRevertRecent
    tmenu &Plugin.&AccuRev.&Revert\ To.&Recent<Tab>:rr Revert file to most recent version; discard recent modifications
  nmenu &Plugin.&AccuRev.&Revert\ To.&Backed<Tab>:rb <Plug>AccurevRevertBacked
    tmenu &Plugin.&AccuRev.&Revert\ To.&Backed<Tab>:rb Revert file to backed version; retrieve starting version (since last promote)
  nmenu &Plugin.&AccuRev.&Diff\ Against.&Most\ Recent<Tab>:dm <Plug>AccurevDiffMostRecent
    tmenu &Plugin.&AccuRev.&Diff\ Against.&Most\ Recent<Tab>:dm Diff file against most recent version; diff unkept modifications
  nmenu &Plugin.&AccuRev.&Diff\ Against.&Backed<Tab>:db <Plug>AccurevDiffBacked
    tmenu &Plugin.&AccuRev.&Diff\ Against.&Backed<Tab>:db Diff file against backed version; diff changes from others in parent streams
  nmenu &Plugin.&AccuRev.&Diff\ Against.&Basis<Tab>:da <Plug>AccurevDiffBasis
    tmenu &Plugin.&AccuRev.&Diff\ Against.&Basis<Tab>:da Diff file against basis version; diff all workspace changes
  nmenu &Plugin.AccuRev.-RevertDiffSeparator- :
  nmenu &Plugin.&AccuRev.&Synchronize\ Time<Tab>:~ <Plug>AccurevSyncTime
    tmenu &Plugin.&AccuRev.&Synchronize\ Time<Tab>:~ Synchronize client time with AccuRev server time; 5-sec threshold
  nmenu &Plugin.&AccuRev.&Update<Tab>:u <Plug>AccurevUpdate
    tmenu &Plugin.&AccuRev.&Update<Tab>:u Update entire workspace with changes from server
  nmenu &Plugin.&AccuRev.&Update\ Preview<Tab>:n <Plug>AccurevUpdatePreview
    tmenu &Plugin.&AccuRev.&Update\ Preview<Tab>:n Preview workspace update to see available changes
  nmenu &Plugin.AccuRev.-UpdateSeparator- :
  nmenu &Plugin.&AccuRev.&History<Tab>:h <Plug>AccurevHistory
    tmenu &Plugin.&AccuRev.&History<Tab>:h View transaction history for current file
  nmenu &Plugin.&AccuRev.&Annotate<Tab>:h <Plug>AccurevAnnotate
    tmenu &Plugin.&AccuRev.&Annotate<Tab>:h View transaction history for current file
  nmenu &Plugin.&AccuRev.&Search.&Pending<Tab>:sp <Plug>AccurevSearchPending
    tmenu &Plugin.&AccuRev.&Search.&Pending<Tab>:sp View all kept/modified files in workspace
  nmenu &Plugin.&AccuRev.&Search.&Modified<Tab>:sm <Plug>AccurevSearchModified
    tmenu &Plugin.&AccuRev.&Search.&Modified<Tab>:sp View all modified files in workspace
  nmenu &Plugin.&AccuRev.&Search.&Kept<Tab>:sm <Plug>AccurevSearchKept
    tmenu &Plugin.&AccuRev.&Search.&Kept<Tab>:sp View all kept files in workspace
  nmenu &Plugin.&AccuRev.&Search.&NonMember<Tab>:sm <Plug>AccurevSearchNonMember
    tmenu &Plugin.&AccuRev.&Search.&NonMember<Tab>:sp View all unkept/modified files in workspace
  nmenu &Plugin.&AccuRev.&Search.&DefaultGroup<Tab>:sm <Plug>AccurevSearchDefaultGroup
    tmenu &Plugin.&AccuRev.&Search.&DefaultGroup<Tab>:sp View all active member files in workspace
  nmenu &Plugin.&AccuRev.&Search.&Overlap<Tab>:sm <Plug>AccurevSearchOverlap
    tmenu &Plugin.&AccuRev.&Search.&Overlap<Tab>:sp View all overlap files in workspace
  nmenu &Plugin.&AccuRev.&Search.&DeepOverlap<Tab>:sm <Plug>AccurevSearchDeepOverlap
    tmenu &Plugin.&AccuRev.&Search.&DeepOverlap<Tab>:sp View all deep overlap files in workspace
  nmenu &Plugin.&AccuRev.&Search.&ModDefaultGroup<Tab>:sm <Plug>AccurevSearchModDefaultGroup
    tmenu &Plugin.&AccuRev.&Search.&ModDefaultGroup<Tab>:sp View all modified member files in workspace
  nmenu &Plugin.&AccuRev.&Search.&External<Tab>:sm <Plug>AccurevSearchExternal
    tmenu &Plugin.&AccuRev.&Search.&External<Tab>:sp View all external files in workspace
  nmenu &Plugin.&AccuRev.&Search.&Missing<Tab>:sm <Plug>AccurevSearchMissing
    tmenu &Plugin.&AccuRev.&Search.&Missing<Tab>:sp View all missing files in workspace
  nmenu &Plugin.&AccuRev.&Search.&Stranded<Tab>:sm <Plug>AccurevSearchStranded
    tmenu &Plugin.&AccuRev.&Search.&Stranded<Tab>:sp View all stranded files in workspace
  nmenu &Plugin.&AccuRev.&Search.&Defunct<Tab>:sm <Plug>AccurevSearchDefunct
    tmenu &Plugin.&AccuRev.&Search.&Defunct<Tab>:sp View all defunct files in workspace
  nmenu &Plugin.&AccuRev.&Search.&Stale<Tab>:sm <Plug>AccurevSearchStale
    tmenu &Plugin.&AccuRev.&Search.&Stale<Tab>:sp View all stale files in workspace
  nmenu &Plugin.AccuRev.-HistorySeparator- :
  nmenu &Plugin.&AccuRev.&CommandHistory<Tab>:? <Plug>AccurevCommandHistory
    tmenu &Plugin.&AccuRev.&CommandHistory<Tab>:? View all AccuRev CLI calls made in current buffer/session
  nmenu &Plugin.&AccuRev.&Refresh<Tab>:<space> <Plug>AccurevRefresh
    tmenu &Plugin.&AccuRev.&Refresh<Tab>:<space> Manually refresh buffer status line
  nmenu &Plugin.&AccuRev.&Properties<Tab>:e <Plug>AccurevElementProperties
    tmenu &Plugin.&AccuRev.&Properties<Tab>:e View element properties

endfunction

" }}}

" Function: DisableAuthMenuMappings {{{3
" Description: Disable all menu mappings that require user authentication.
" Return: None.
function! s:DisableAuthMenuMappings()
  " deregister menu options; both console and gui
  " note: cannot use menu disable due to console menus not responding to it (?)
  nmenu disable &Plugin.&AccuRev
endfunction " }}}

" }}}
"
" }}}

" Section: Plugin Functions (Business Controller) {{{1

" Function: UnloadPlugin {{{2
" Description:  Unloads AccuRev plugin on demand.
" Return: N/A
function! s:UnloadPlugin()

  if b:PluginLoaded() == s:false
    return
  endif

  call s:RecordActionBegin('plugin unload')

  call s:UnloadPluginCurrentWindow()
  call s:UnloadPluginCurrentBuffer()
  call b:UnsetPluginLoaded()

  call s:RecordActionFinish('plugin unload')

endfunction " 2}}}

" Function: LoadPluginCurrentBuffer {{{2
" Description:  Loads AccuRev plugin in current buffer.
" Return: N/A
function! s:LoadPluginCurrentBuffer()

  call s:DisplayDebug("Initializing Plugin.  buffer=[" . bufname('%') . "]")
  call s:RecordActionBegin('load plugin buffer')

  " already initialized
  if s:IsInitialized()
    call s:DisplayDebug("Plugin Already Initialized.")
    return
  endif

  "----------------------------------------------------------------------------
  " Note: At this point, all criteria have passed and the plugin can be loaded.
  "----------------------------------------------------------------------------
  call s:DisplayDebug("User authenticated.  Workspace found.")

  " register all mappings available after login
  call s:LoadAuthMappings()

  augroup accurev_events
    " clear any events from same group; start fresh
    autocmd!
    " update the accurev file status when changes are written to disk
    " - called implicitely when file loaded
    autocmd BufWritePost <buffer> :call s:Refresh('bufwrite/bufenter')
  " - BufEnter: determine if file has changed on disk
    autocmd BufEnter <buffer> checktime
  augroup END

  " toggle gui menus depending if the buffer has the plugin enabled or not
  augroup accurev_menu_events
    autocmd!
    autocmd BufEnter <buffer> :call s:EnableGuiMenus()
    autocmd BufLeave <buffer> :call s:DisableGuiMenus()
  augroup END

  " always read in newer versions of file on disk into *unmodified* buffers
  " - used when reverting and loading previous versions
  setlocal autoread

  " Developer Note: The AccuRev-specific element status shown on the status
  " line e.g. '(modified)(member)' for a given element has been externalized
  " using a buffer variable to prevent the internal, very-frequent statusline
  " refresh from contacting AccuRev server for status info per-screen-refresh.
  " Thus, this plugin ~indirectly~ updates the element status using buffer events
  " that change the externalized value.  Events of interest are those AccuRev
  " commands that cause the element's status to change (e.g. add/keep/promote).

  " need to refresh & set per-buffer element status info during init for -o/-O  options that init buffers before showing windows
  call s:Refresh('init')

  call s:SetBufferAttribute('is_initialized', s:true)
  call s:SetBufferAttribute('element_relpath', substitute(s:GetBufferAttribute('element_abspath'), s:GetBufferAttribute('workspace_root'), '', ''))
  call s:RecordActionFinish('load plugin buffer')

  call s:DisplayDebug("Init Buffer Attributes=[" . string(b:accurev_attributes) . "]")
  call s:DisplayDebug("Initializing Completed.")

endfunction "}}}

" Function: LoadPluginCurrentWindow {{{2
" Description:  Sets up the current window with AccuRev plugin decorations.
" Return: N/A
function! s:LoadPluginCurrentWindow()

  " show two lines below statusbar for info/error messaging
  set cmdheight=2

  " always show status line for buffer windows
  " status line that displays file status and other information
  setlocal laststatus=2
  " Note: using buffer var directly since statusline requires direct access; no <SID> scoped method calls
  setlocal statusline=AccuRev\ [%{b:accurev_attributes['principal']}]\ %<%t\ %{b:accurev_attributes['element_status']}%r%m%=%l,%c\ %p%%\ [%{b:accurev_attributes['element_size']}][%{&fileformat}]
endfunction "}}}

" Function: UnloadPluginCurrentWindow {{{2
" Description:  Removes all AccuRev plugin window decorations.
"               Resets to vim session defaults.
" Return: N/A
function! s:UnloadPluginCurrentWindow()
  setlocal laststatus&vim
  setlocal statusline&vim
  setlocal cmdheight&vim
endfunction "}}}

" Function: UnloadPluginCurrentBuffer {{{2
" Description:  Unloads AccuRev plugin.
" Return: N/A
function! s:UnloadPluginCurrentBuffer()
  call s:RecordActionBegin('plugin unload [' . bufname('%') . ']')

  call s:LogoutDeactivatePlugin() " disable plugin features but allow login

  call s:RecordActionFinish('plugin unload [' . bufname('%') . ']')

endfunction "}}}

" Function: LoadPlugin {{{2
" Description: Loads the AccuRev plugin.  At this point, it is assumed
" that the vim user knows AccuRev exists but this plugin does not
" assume the AccuRev server is available.  Validation will occur
" prior to fully loading the plugin.
" Return: N/A
function! s:LoadPlugin()

  " nothing to do if already loaded
  if b:PluginLoaded()
    return
  end

  call s:RecordActionBegin('plugin load')
  call s:DisplayStatusStart("Loading plugin...")

  redraw!

  " Optimization NOTE: auth check used to determine both user authentication and
  "                    server availability with a single command
  let l:status = s:ServerAuthCheck()

  " server must be available to continue
  if s:IsServerUnavailable(l:status)
    call s:DisplayStatusFinish("Server unavailable.")
    call s:DisplayInfoWithPrompt("See |accurev-unavailable|", "<Enter> to continue without plugin.")
    call s:RecordActionFinish('plugin load (server unavailable)')
    redraw!
    return
  endif

  " NOTE: User must be logged in to correctly determine workspace status.
  "       I debated checking for wspace first, then logging in, but the workspace
  "       check needs the login to have happened already.  eh.

  " user must be logged in to continue
  if s:IsLoggedOut(l:status)
    call s:DisplayStatusFinish("login required.")
    call s:Login()
    redraw!
  endif

  " load workspace information into buffer variables for buffer-global access
  call s:LoadWorkspaceInfo()
  " determine workspace status
  call s:IdentifyWorkspace()

  " must be in a workspace to continue
  if s:NotInWorkspace()
    call s:RecordActionFinish('plugin load (not in workspace)')
    redraw!
    return
  endif

  " hey user, get ready to rock!
  call s:DisplayDebug("Workspace detected.")

  " load plugin
  call s:LoadPluginCurrentBuffer()
  call s:LoadPluginCurrentWindow()

  redraw!

  call s:DisplayStatus("Plugin Loaded (v" .  s:accurev_plugin_version . "/" .  s:accurev_plugin_date . ")")

  " clear all messages unless verbose mode is on
  if !s:ShowStatusMessages()
    redraw!
  endif

  call b:SetPluginLoaded()

  call s:RecordActionFinish('plugin load')

endfunction "}}}

" Function: Info {{{2
" Description: Display client/server AccuRev info in separate buffer.
" Return: N/A
function! s:Info()
  call s:RecordActionBegin('info')
  let l:bufname = "AccuRev Info"
  let l:ContentFnRef = function("s:ContentController_Info")
  call s:ManagedDisplayBuffer('info', l:bufname, l:ContentFnRef)
endfunction "}}}

" Function: LaunchStreamBrowser {{{2
" Description: Launch AccuRev's Graphical Stream Browser
" Return: N/A
function! s:LaunchStreamBrowser()

  let l:cli = s:empty
  let l:msg = s:empty

  " assume executable in path
  if s:OnUnix()
    let l:cli = 'acgui &'
    let l:msg = "Launching Stream Browser in background. [assumes 'acgui' in Path]"
  elseif s:OnWindows()
    let l:cli = 'acgui'
    let l:msg = "Launching Stream Browser in foreground... Exit to continue vim."
  else
    return
  endif

  call s:RecordActionBegin('launch stream browser')
  call s:DisplayInfo(l:msg)
  let l:output = system(l:cli)
  let l:return_code = v:shell_error

  " save exec history
  call s:RecordCommand(l:cli, l:output, l:return_code)

  " Debugging - display system command and error codes
  if l:return_code > 0
    let l:msg = "acgui failed.  Not in path? cmd=[" . l:cli . "] code=[" . l:return_code . "]\n"
    call s:DisplayError(l:msg)
    return
  endif

  call s:RecordActionFinish('launch stream browser')

endfunction "}}}

" Function: Login {{{2
" Description: Prompts user to login.  Plugin initialized on successful login.
" Return: N/A
function! s:Login()

  call s:RecordActionBegin('login')

  try
    " login user
    if s:AuthenticateUser() == s:false
      call s:DisplayInfo("Failed authentication.  Please try again.")
      return
    endif
  catch /^Vim:Interrupt$/ " capture CTRL-C
    redraw!
    return
  endtry

  call s:LoadPlugin()

  " get latest element info for display
  " - note: this was inside init, but caused a redundant server call [stat]
  "         during normal startup causing slight delay; thus, we call refresh here ;)
  call s:Refresh('login')

  call s:RecordActionFinish('login')

endfunction "}}}

" Function: Logout {{{2
" Description: Performs a logout of AccuRev.
" Return: N/A
function! s:Logout()

  " already logged out
  if s:IsLoggedOut()
    return
  endif

  call s:RecordActionBegin('logout')

  " logout of accurev
  if s:ActionController_Logout() == s:false
    call s:DisplayError("Logout Failed.  Try again.")
    return
  endif

  " TODO revert status bars for all accurev windows
  " TODO disable plugin for all buffers but allow login
  call s:UnloadPlugin()

  call s:DisplayInfo("Logged out.  Come back soon!")
  call s:RecordActionFinish('logout')

endfunction "}}}

" Function: Add {{{2
" Description: Performs an 'add' on the current file.  User is prompted for a comment.
"              A progress bar is displayed to inform the user of completion status.
"              This method is expected to be called on itself in case the user becomes
"              unauthenticated while the plugin is loaded and the add needs to be
"              retried with existing comment after login.
" Parameters: 1: Optional comment as String
" Return: N/A
function! s:Add(...)

  redraw!

  if s:BufferIsUnnamed()
    call s:DisplayError("Unable to Add! No filename. Save and try again.")
    return
  endif

  if s:BufferIsModified()
    call s:DisplayError("Unable to Add! Modifications exist. Save and try again.")
    return
  endif

  " filename to add
  let l:filename = s:GetFilename()

  if !s:FileExists(l:filename)
    call s:DisplayError("Unable to Add! File does not exist. Save and try again.")
    return
  endif

  if !s:HasExternalStatus(l:filename)
    call s:DisplayError("Unable to Add! Element already added!")
    return
  endif

  if a:0 == 1 " comment provided
    let l:comment = a:1
  else " prompt user for comment
    let l:comment = s:Input_SingleLine('Add Comment [CTRL-c cancels]: ')
  endif

  if s:IsEmptyComment(l:comment)
    call s:DisplayErrorWithPrompt("Comment required.  Aborting.")
    redraw!
    return
  endif

  call s:RecordActionBegin('add')

  " *******************************************************
  " handle CTRL-C interrupt during user input and operation
  try

    let l:progbar = s:NewProgressBar(3)

    " let user know whats up; add may take a few secs to send to server
    call s:DisplayInfo('Adding file "' . s:GetDisplayFilename() . '" (' . s:GetFileSizeDisplay() . ')')
    call s:IncrProgressBar(l:progbar)

    " perform the 'add'; keep track of how long the operation will perform
    let l:start_time = s:TimingStart()
    let l:output = s:ActionController_Add(l:filename, l:comment)
    let l:elapsed_time = s:TimingElapsed(l:start_time)
    call s:IncrProgressBar(l:progbar)

    " erase previous message line for next; prevents message stacking
    redraw!

    " bad element name
    if stridx(l:output, "Element not found") >= 0
      call s:DisplayError("'" . l:filename . "' not found.")
      return
    " element already added
    elseif stridx(l:output, "Element already exists") >= 0
      call s:DisplayError("'" . l:filename . "' already added! Check for evil twin in backing stream(s).")
      return
    " element excluded by incl/excl rules
    elseif stridx(l:output, "excluded") >= 0
      call s:DisplayError("'" . l:filename . "' excluded by incl/excl rules.")
      return
    " element is read/only
    elseif stridx(l:output, "read only") >= 0
      call s:DisplayError("'" . l:filename . "' is read/only.  Possible xlink'd path?")
      return
    " not in a workspace
    elseif stridx(l:output, "not in a directory associated with a workspace") >= 0
      call s:DisplayError("'" . l:filename . "' is not in a workspace.")
      return
    " user got logged out; get them back and retry the operation
    elseif stridx(l:output, "Not authenticated") >= 0
        call s:DisplayError("Not logged in!  Login and 'add' will retry...")
        call s:RecordActionStatus('add - login required')
        sleep 3 " let the 'add' complete asynchronously then check status
        " attempt to re-login
        if s:AuthenticateUser() == s:true
          call s:RecordActionStatus('add - retry')
          call s:Add(l:comment)
          return
        endif
        call s:DisplayErrorWithPrompt("Login failed.  Add aborted.")
        return
    endif
    call s:IncrProgressBar(l:progbar)

    " hey user, we're done!  fast, eh?
    call s:DisplayInfo('"' . s:GetDisplayFilename() . '" added. (' . s:GetFileSizeDisplay() . ', ' . l:elapsed_time . 's)')

  catch /^Vim:Interrupt$/ " capture CTRL-C
    redraw
    call s:DisplayInfo("Add interrupted... but may have completed. Check for (kept) status.")
    call s:RecordActionStatus('add - interrupted (may have completed)')
    sleep 3 " let the 'add' complete asynchronously then check status
  finally
    call s:CloseProgressBar(l:progbar)
  endtry

  call s:Refresh('add')
  call s:RecordActionFinish('add finished')

endfunction "}}}

" Function: Keep {{{2
" Description: Performs a 'keep' on the current file.  User is prompted for a comment.
"              A progress bar is displayed to inform the user of completion status.
"              This method is expected to be called on itself in case the user becomes
"              unauthenticated while the plugin is loaded and the keep needs to be
"              retried with existing comment after login.
" Parameters: 1: Optional comment as String
" Return: N/A
function! s:Keep(...)

  redraw!

  if s:BufferIsUnnamed()
    call s:DisplayError("Unable to Keep! No filename. Save and try again.")
    return
  endif

  if s:BufferIsModified()
    call s:DisplayError("Unable to Keep! Modifications exist. Save and try again.")
    return
  endif

  " if user was in accurev diff mode, exit the mode before keeping
  " - if user was doing diff vs mostrecent, they need to load the new 'most recent' version
  if s:BufferInDiffMode()
    call s:DiffExit()
  endif

  let l:filename = s:GetFilename()

  if !s:FileExists(l:filename)
    call s:DisplayError("Unable to Keep! File does not exist. Save and try again.")
    return
  endif

  if a:0 == 1 " comment provided
    let l:comment = a:1
  else " prompt user for comment
    let l:comment = s:Input_SingleLine('Keep Comment [CTRL-c cancels]: ')
  endif

  if s:IsEmptyComment(l:comment)
    call s:DisplayErrorWithPrompt("Comment required.  Aborting.")
    redraw!
    return
  endif

  call s:RecordActionBegin('keep')

  try

    let l:progbar = s:NewProgressBar(3)

    " let user know whats up; keep may take a few secs to send to server
    call s:DisplayInfo('Keeping file "' . s:GetDisplayFilename() . '" (' . s:GetFileSizeDisplay() . ')')
    call s:IncrProgressBar(l:progbar)

    " perform the keep; keep track of how long the operation will perform
    let l:start_time = s:TimingStart()
    let l:output = s:ActionController_Keep(l:filename, l:comment)
    let l:elapsed_time = s:TimingElapsed(l:start_time)
    call s:IncrProgressBar(l:progbar)

    " erase previous message line for next; prevents message stacking
    redraw!

    " bad element name
    if stridx(l:output, "Element not found") >= 0
      call s:DisplayError("'" . l:filename . "' not found.")
      return
    " element is read/only by way of crosslinking
    elseif stridx(l:output, "read only") >= 0
      call s:DisplayError("'" . l:filename . "' is read/only.  Possible xlink'd path?")
      return
    " element not under version control; so perform the add!
    elseif stridx(l:output, "No element named") >= 0
      " first keep... is an Add!  Here's one for developer productivity.
      return s:Add(l:comment)
    " already defunct
    elseif stridx(l:output, "Element is defunct") >= 0
      call s:DisplayError("'" . l:filename . "' is defunct. First undefunct, then keep.")
      return
    " user got logged out; get them back and retry the operation
    elseif stridx(l:output, "Not authenticated") >= 0
        call s:DisplayError("Not logged in!  Login and 'keep' will retry...")
        call s:RecordActionStatus('keep - login required')
        sleep 3 " let user see the login notice
        if s:AuthenticateUser() == s:true
          call s:RecordActionStatus('keep - retry')
          call s:Keep(l:comment)
          return
        endif
        call s:DisplayErrorWithPrompt("Login failed.  Keep aborted.")
        return
    endif
    call s:IncrProgressBar(l:progbar)

    " hey user, we're done!  fast, eh?
    call s:DisplayInfo('"' . s:GetDisplayFilename() . '" kept. (' . s:GetFileSizeDisplay() . ', ' . l:elapsed_time . 's)')

  " handle CTRL-C interrupt during user input and operation
  catch /^Vim:Interrupt$/ " capture CTRL-C
    redraw
    call s:DisplayInfo("Keep interrupted... but may have completed. Check for (kept) status.")
    call s:RecordActionStatus('keep - interrupted (may have completed)')
    sleep 3 " let the 'keep' complete asynchronously then check status
  " cleanup regardless of success/failure
  finally
    call s:CloseProgressBar(l:progbar)
  endtry

  call s:Refresh('keep')
  call s:RecordActionFinish('keep finished')

endfunction "}}}

" Function: Anchor {{{2
" Description: Performs an 'anchor' on the current file. User is prompted for a comment.
"              This method is expected to be called on itself in case the user becomes
"              unauthenticated while the plugin is loaded and the anchor needs to be
"              retried with existing comment after login.
" Return: N/A
function! s:Anchor(...)

  redraw!

  if s:BufferIsUnnamed()
    call s:DisplayError("Unable to Anchor! No filename. Save and try again.")
    return
  endif

  if s:BufferIsModified()
    call s:DisplayError("Unable to Anchor! Modifications exist. Save and try again.")
    return
  endif

  let l:filename = s:GetFilename()

  if !s:FileExists(l:filename)
    call s:DisplayError("Unable to Anchor! File does not exist. Save and try again.")
    return
  endif

  if s:HasMemberStatus(l:filename)
    call s:DisplayInfo("Unable to Anchor! Element already in default group.")
    return
  endif

  if a:0 == 1 " comment provided
    let l:comment = a:1
  else " prompt user for comment
    let l:comment = s:Input_SingleLine('Anchor Comment [CTRL-c cancels]: ')
  endif

  if s:IsEmptyComment(l:comment)
    call s:DisplayErrorWithPrompt("Comment required.  Aborting.")
    redraw!
    return
  endif

  call s:RecordActionBegin('anchor')

  try

    let l:progbar = s:NewProgressBar(3)

    " let user know whats up; anchor may take a few secs to perform
    call s:DisplayInfo('Anchoring file "' . s:GetDisplayFilename() . '"...')
    call s:IncrProgressBar(l:progbar)

    " perform the anchor; keep track of how long the operation will perform
    let l:start_time = s:TimingStart()
    let l:output = s:ActionController_Anchor(l:filename, l:comment)
    let l:elapsed_time = s:TimingElapsed(l:start_time)
    call s:IncrProgressBar(l:progbar)

    " erase previous message line for next; prevents message stacking
    redraw!

    " element name does not exist
    if stridx(l:output, "No element named") >= 0
      call s:DisplayError("'" . l:filename . "' does not exist!")
      return
    " element already in def group
    elseif stridx(l:output, "already in default group") >= 0
      call s:DisplayError("'" . l:filename . "' already in default group!")
      return
    " user got logged out; get them back and retry the operation
    elseif stridx(l:output, "Not authenticated") >= 0
        call s:DisplayError("Not logged in!  Login and 'anchor' will retry...")
        call s:RecordActionStatus('anchor - login required')
        sleep 3 " let user see the login notice
        if s:AuthenticateUser() == s:true
          call s:RecordActionStatus('anchor - retry')
          call s:Anchor(l:comment)
          return
        endif
        call s:DisplayErrorWithPrompt("Login failed.  Anchor aborted.")
        return
    endif
    call s:IncrProgressBar(l:progbar)

    " hey user, we're done!  fast, eh?
    call s:DisplayInfo('"' . s:GetDisplayFilename() . '" anchored. (' . l:elapsed_time . 's)')

  " handle CTRL-C interrupt during user input and operation
  catch /^Vim:Interrupt$/ " capture CTRL-C
    redraw
    call s:DisplayInfo("Anchor interrupted... but may have completed. Check for (member) status.")
    call s:RecordActionStatus('Anchor - interrupted (may have completed)')
    sleep 3 " let the 'anchor' complete asynchronously then check status
  " cleanup regardless of success/failure
  finally
    call s:CloseProgressBar(l:progbar)
  endtry

  call s:Refresh('anchor')
  call s:RecordActionFinish('anchor finished')

endfunction "}}}

" Function: Populate {{{2
" Description: Performs a 'populate' on the current file. User is prompted to confirm.
"              This method is expected to be called on itself in case the user becomes
"              unauthenticated while the plugin is loaded and the anchor needs to be
"              retried with existing comment after login.
" Return: N/A
function! s:Populate(...)

  redraw!

  if s:BufferIsUnnamed()
    call s:DisplayError("Unable to Populate! No filename. Save and try again.")
    return
  endif

  if s:BufferIsModified()
    call s:DisplayError("Unable to Populate! Modifications exist. Save and try again.")
    return
  endif

  let l:filename = s:GetFilename()

  if s:HasModifiedStatus(l:filename)
    let l:response = s:Input_ConfirmContinue('Populating "' . s:GetDisplayFilename() . '".  Modifications will be LOST.')

    " user canceled
    if l:response == s:false
      call s:DisplayInfo('Populate canceled.')
      return
    endif
  endif

  call s:RecordActionBegin('populate')

  try

    let l:progbar = s:NewProgressBar(3)

    " let user know whats up; anchor may take a few secs to perform
    call s:DisplayInfo('Populating file "' . s:GetDisplayFilename() . '"...')
    call s:IncrProgressBar(l:progbar)

    " perform the anchor; keep track of how long the operation will perform
    let l:start_time = s:TimingStart()
    let l:output = s:ActionController_Populate(l:filename)
    let l:elapsed_time = s:TimingElapsed(l:start_time)
    call s:IncrProgressBar(l:progbar)

    " erase previous message line for next; prevents message stacking
    redraw!

    " element name does not exist
    if stridx(l:output, "No element named") >= 0
      call s:DisplayError("'" . l:filename . "' does not exist!")
      return
    " user got logged out; get them back and retry the operation
    elseif stridx(l:output, "Not authenticated") >= 0
        call s:DisplayError("Not logged in!  Login and 'populate' will retry...")
        call s:RecordActionStatus('populate - login required')
        sleep 3 " let user see the login notice
        if s:AuthenticateUser() == s:true
          call s:RecordActionStatus('populate - retry')
          call s:Populate()
          return
        endif
        call s:DisplayErrorWithPrompt("Login failed.  Populate aborted.")
        return
    endif
    call s:IncrProgressBar(l:progbar)

    " automatically load the newly populated file into the buffer
    checktime
    call s:IncrProgressBar(l:progbar)

    " hey user, we're done!  fast, eh?
    call s:DisplayInfo('"' . s:GetDisplayFilename() . '" populated. (' . s:GetFileSizeDisplay() . ', ' . l:elapsed_time . 's)')

  " handle CTRL-C interrupt during user input and operation
  catch /^Vim:Interrupt$/ " capture CTRL-C
    redraw
    call s:DisplayInfo("Populate interrupted... but may have completed. Check status.")
    call s:RecordActionStatus('Populate - interrupted (may have completed)')
    sleep 3 " let the 'populate' complete asynchronously then check status
    " reload file; file can be successfully reverted during interruption
    checktime
  " cleanup regardless of success/failure
  finally
    call s:CloseProgressBar(l:progbar)
  endtry

  call s:Refresh('populate')
  call s:RecordActionFinish('populate finished')

endfunction "}}}

" Function: Promote {{{2
" Description: Performs a 'promote' on the current file.  User is prompted for a comment.
"              A progress bar is displayed to inform the user of completion status.
" Parameter: 1=Boolean indicating to do a single (false) or group (true) select promote
"            2=Optional comment as String
" Return: N/A
function! s:Promote(type,...)

  if s:BufferIsUnnamed()
    call s:DisplayError("Unable to Promote! No filename. Save and try again.") | return
  endif

  if s:BufferIsModified()
    call s:DisplayError("Unable to Promote! Modifications exist. Save and try again.") | return
  endif

  " use group-element select buffer to choose elements to promote
  if a:type == 'multi'
    call s:Input_MultiSelectPromote()
    return
  endif

  let l:filename = s:GetFilename()
  let l:filename_in_array = [l:filename] " need to send as array type

  if !s:HasMemberStatus(l:filename) && !s:HasModifiedStatus(l:filename)
    call s:DisplayInfo("Unable to Promote! Element not in default group!")
    return
  endif

  "** continue with 'single' element promote

  if a:0 == 1 " comment provided
    let l:comment = a:1
  else " prompt user for comment
    let l:comment = s:Input_SingleLine('Promote Comment [CTRL-c cancels]: ')
  endif

  if s:IsEmptyComment(l:comment)
    call s:DisplayErrorWithPrompt("Comment required.  Aborting.")
    redraw!
    return
  endif

  " get issue # to promote to
  let l:issue_num = -1
  if s:PromoteByIssueEnabled()
    let l:issue_num = s:PromptForIssueNumber()
    " invalid issue provided; support empty to imply 'no issue'
    if l:issue_num == s:notfound
      call s:DisplayError("Unable to Promote! Invalid issue # provided.  Try again.")
      return
    endif
  endif

  call s:RecordActionBegin('promote')

  try

    let l:progbar = s:NewProgressBar(3)

    " let user know whats up; promote may take a few secs to send to server
    call s:DisplayInfo('Promoting file "' . s:GetDisplayFilename() . '"')
    call s:IncrProgressBar(l:progbar)

    " perform the promote; keep track of how long the operation will perform
    let l:start_time = s:TimingStart()
    let l:output = s:ActionController_Promote(l:filename_in_array, l:comment, l:issue_num)
    let l:elapsed_time = s:TimingElapsed(l:start_time)
    call s:IncrProgressBar(l:progbar)

    " erase previous message line for next; prevents message stacking
    redraw!

    " bad element name
    if stridx(l:output, "No element named") >= 0
      call s:DisplayError("'" . l:filename . "' not found.  Promote canceled.")
      return
    " element already exists; evil twin
    elseif stridx(l:output, "Name already exists") >= 0
      call s:DisplayError("'" . l:filename . "' already exists; evil twin.  Promote canceled.")
      return
    " filter rules
    elseif stridx(l:output, "Element is not in default group") >= 0
      call s:DisplayError("'" . l:filename . "' is not in default group.  Promote canceled.")
      return
    elseif stridx(l:output, "Element excluded") >= 0
      call s:DisplayError("'" . l:filename . "' excluded by incl/excl rules.  Promote canceled.")
      return
    elseif stridx(l:output, "No comment entered") >= 0
      call s:DisplayError("'" . l:filename . "' No comment entered.  Promote canceled.")
      return
    elseif stridx(l:output, "Merge required") >= 0
      call s:DisplayError("'" . l:filename . "' Merge required.  Promote canceled.")
      return
    " modified defunct file; note: not sure if other error messages only show 'Element is defunct'
    " but the case we are covering is trying to promote a locally defunct -then- modified (recreated) file
    elseif stridx(l:output, "Element is defunct") >= 0
      call s:DisplayError("'" . l:filename . "' was defunct and recreated locally.  Promote defunct element first then recreate. Promote canceled.")
      return
    elseif stridx(l:output, "Change package gap") >= 0
      call s:DisplayError("'" . l:filename . "' Change package gap merge required.  Promote canceled.")
      return
    elseif stridx(l:output, "Issue not found") >= 0
      call s:DisplayError("Invalid issue #" . l:issue_num . ".  Promote canceled.")
      return
    elseif stridx(l:output, "Issue does not match promote criteria") >= 0
      call s:DisplayError("Invalid issue #" . l:issue_num . ". Check issue query for promote.  Promote canceled.")
      return
    elseif stridx(l:output, "stream definition has changed") >= 0
      call s:DisplayError("Workspace definition changed.  Update workspace then retry.")
      return
    elseif stridx(l:output, "stream is locked") >= 0
      let l:backing_stream = s:GetBufferAttribute('basis')
      call s:DisplayError("Backing stream '" . l:backing_stream . "' is locked.  Promote canceled.")
      return
    " user got logged out; get them back and retry the operation
    elseif stridx(l:output, "Not authenticated") >= 0
        call s:DisplayError("Not logged in!  Login and 'promote' will retry...")
        call s:RecordActionStatus('promote - login required')
        sleep 3 " let user see the login notice
        " attempt to re-login
        if s:AuthenticateUser() == s:true
          call s:RecordActionStatus('promote - retry')
          call s:Promote(a:type, l:comment)
          return
        endif
        call s:DisplayErrorWithPrompt("Login failed.  Promote aborted.")
        return
    endif
    call s:IncrProgressBar(l:progbar)

    " prepare optional display text for promote by issue
    let l:by_issue_msg = ""
    if len(l:issue_num) > 0 && l:issue_num != -1
      let l:by_issue_msg = " to issue #" . l:issue_num
    endif

    " hey user, we're done!  fast, eh?
    call s:DisplayInfo('"' . s:GetDisplayFilename() . '" promoted' . l:by_issue_msg . '. (' . l:elapsed_time . 's)')

  " handle CTRL-C interrupt during user input and operation
  catch /^Vim:Interrupt$/ " capture CTRL-C
    redraw
    call s:DisplayInfo("Promote interrupted... but may have completed. Check for (backed) status.")
    call s:RecordActionStatus('promote - interrupted (may have completed)')
    sleep 3 " let the 'promote' complete asynchronously then check status
  " cleanup regardless of success/failure
  finally
    call s:CloseProgressBar(l:progbar)
  endtry

  call s:Refresh('promote')
  call s:RecordActionFinish('promote finished')

endfunction "}}}

" Function: Merge {{{2
" Description: Performs a 'merge' on the current file if it has (overlap) status.
"              Currently, only trivial merges are supported.  If an overlap has
"              conflicting lines, they will need to be merged outside of Vim.
"              A progress bar is displayed to inform the user of completion status.
" Return: N/A
function! s:Merge()

  if s:BufferIsUnnamed()
    call s:DisplayError("Unable to Merge! No filename. Save and try again.") | return
  endif

  if s:BufferIsModified()
    call s:DisplayError("Unable to Merge! Modifications exist. Save and try again.") | return
  endif

  let l:filename = s:GetFilename()

  " perform auth check since subsequent overlap status check requires valid session
  if s:IsLoggedOut()
    call s:DisplayInfo("Unable to Merge! Session expired.  Login and retry.")
    sleep 3
    redraw!
    call s:LogoutDeactivatePlugin()
    return
  endif

  if !s:HasOverlapStatus(l:filename)
    call s:DisplayInfo("Unable to Merge! No overlaps exist.")
    return
  endif

  " if enabled, attempt external merge with accurev's graphical merge tool
  if s:ManualMergeRequired(l:filename)

    if s:GraphicalMergeEnabled()
      call s:LaunchGraphicalMerge(l:filename)
    else
      call s:DisplayInfo("Unable to merge conflicts automatically.  Keep, exit, then merge manually.")
    end

    return

  endif

  " prompt user to continue
  call s:RecordActionBegin('merge')

  try

    let l:progbar = s:NewProgressBar(4)

    " let user know whats up; promote may take a few secs to send to server
    call s:DisplayInfo('Merging file "' . s:GetDisplayFilename() . '"')
    call s:IncrProgressBar(l:progbar)

    " perform the promote; keep track of how long the operation will perform
    let l:start_time = s:TimingStart()
    let l:output =  s:ActionController_AutoMerge(l:filename)
    let l:elapsed_time = s:TimingElapsed(l:start_time)
    call s:IncrProgressBar(l:progbar)

    " erase previous message line for next; prevents message stacking
    redraw!

    " bad element name
    if stridx(l:output, "file not found") >= 0
      call s:DisplayError("'" . l:filename . "' not found.")
      return
    " user got logged out; get them back and retry the operation
    elseif stridx(l:output, "Not authenticated") >= 0
        call s:DisplayError("Not logged in!  Login and 'merge' will retry...")
        call s:RecordActionStatus('merge - login required')
        sleep 3 " let user see the login notice
        " attempt to re-login
        if s:AuthenticateUser() == s:true
          call s:RecordActionStatus('merge - retry')
          call s:Merge()
          return
        endif
        call s:DisplayErrorWithPrompt("Login failed.  Merge aborted.")
        return
    endif
    call s:IncrProgressBar(l:progbar)

    " automatically load the newly merged file into the buffer
    checktime
    call s:IncrProgressBar(l:progbar)

    " hey user, we're done!  fast, eh?
    call s:DisplayInfo('"' . s:GetDisplayFilename() . '" merged successfully. (' . l:elapsed_time . 's)')

  " handle CTRL-C interrupt during user input and operation
  catch /^Vim:Interrupt$/ " capture CTRL-C
    redraw
    call s:DisplayInfo("Merge interrupted... but may have completed. Check for (kept) status.")
    call s:RecordActionStatus('merge - interrupted (may have completed)')
    sleep 3 " let the 'merge' complete asynchronously then check status
  " cleanup regardless of success/failure
  finally
    call s:CloseProgressBar(l:progbar)
  endtry

  call s:Refresh('merge')
  call s:RecordActionFinish('merge finished')

endfunction "}}}

" Function: LaunchGraphicalMerge {{{2
" Description: Launch AccuRev's Graphical Merge
" Parameter: 1=filename to merge
" Return: N/A
function! s:LaunchGraphicalMerge(filename)

  " call merge with graphical option; also auto-keep results
  let l:cli = 'accurev merge -L "' . s:GetWorkspaceRoot() . '" -G -K "' . a:filename . '"'

  call s:RecordActionBegin('launch graphical merge')
  call s:DisplayInfo("Conflicts exist.  Launching graphical merge.  Exit or save to continue.")

  let l:output = system(l:cli)
  let l:return_code = v:shell_error
  " save exec history
  call s:RecordCommand(l:cli, l:output, l:return_code)

  let l:msg = "Graphical merge completed successfully."

  " failure due to launch/path problem
  if l:return_code == 127
    let l:msg = "Graphical merge failed.  Unable to find accurev in Path. cli=[" . l:cli . "]"
  " failure due to user cancel
  elseif l:return_code > 0
    let l:msg = "Graphical merge cancelled.  File unchanged."
  " success; reload the file
  else
    checktime
  endif

  call s:DisplayInfo(l:msg)

  call s:RecordActionFinish('launch graphical merge')

  redraw!
  call s:DisplayInfo(l:msg)

endfunction "}}}

" Function: SyncTime {{{2
" Description: Performs an 'synctime' on the client machine.
" Return: N/A
function! s:SyncTime()

  redraw!

  if s:BufferIsModified()
    call s:DisplayError("Unable to SyncTime! Modifications exist. Save and try again.") | return
  endif

  call s:RecordActionBegin('synctime')

  try

    let l:progbar = s:NewProgressBar(4)

    " let user know whats up; keep may take a few secs to sync with server
    call s:DisplayInfo("Synchronizing client time with AccuRev server... ")
    call s:IncrProgressBar(l:progbar)

    " let user see the info message; synctime can happen pretty fast
    sleep 3
    call s:IncrProgressBar(l:progbar)

    " perform the 'synctime'
    let l:output = s:ActionController_SyncTime()
    call s:IncrProgressBar(l:progbar)

    " erase previous message line for next; prevents message stacking
    redraw!

    " user got logged out; get them back and retry the operation
    if stridx(l:output, "Not authenticated") >= 0
        call s:DisplayError("Not logged in!  Login and 'synchronize time' will retry...")
        call s:RecordActionStatus('synctime - login required')
        sleep 3 " let user see the login notice
        " attempt to re-login
        if s:AuthenticateUser() == s:true
          call s:RecordActionStatus('synctime - retry')
          call s:SyncTime()
          return
        endif
        call s:DisplayErrorWithPrompt("Login failed.  Synchronize time aborted.")
        return
    elseif (len(l:output) > 0) " Not sure of any other output/error messages
      call s:DisplayError(l:output . "Host permissions may be required. Perform synctime outside of vim.")
      return
    endif
    call s:IncrProgressBar(l:progbar)

    " hey user, we're done!  fast, eh?
    call s:DisplayInfo("Client time synchronized.")

  " handle CTRL-C interrupt during user input and operation
  catch /^Vim:Interrupt$/ " capture CTRL-C
    redraw
    call s:DisplayInfo("Synctime interrupted... but may have completed.")
    call s:RecordActionStatus('synctime - interrupted (may have completed)')
    sleep 3 " let the 'keep' complete asynchronously then check status
  " cleanup regardless of success/failure
  finally
    call s:CloseProgressBar(l:progbar)
  endtry

  call s:Refresh('synctime')
  call s:RecordActionFinish('synctime finished')

endfunction "}}}

" Function: Update {{{2
" Description: Performs an 'update' of the entire workspace and shows output
"              in a separate buffer window.
" Return: N/A
function! s:Update()

  if s:BufferIsModified()
    call s:DisplayError("Unable to Update! Modifications exist. Save and try again.") | return
  endif

  call s:RecordActionBegin('update')

  call s:DisplayInfo("Updating Workspace... ")

  redraw!

  let l:bufname = "Workspace Update"
  let ContentFnRef = function("s:ActionController_Update")
  call s:ManagedDisplayBuffer('update', l:bufname, ContentFnRef)

endfunction "}}}

" Function: UpdatePreview {{{2
" Description: Performs an 'update preview' of the entire workspace and shows output
"              in a separate buffer window.
" Return: N/A
function! s:UpdatePreview()

  if s:BufferIsModified()
    call s:DisplayError("Unable to Update Preview! Modifications exist. Save and try again.") | return
  endif

  call s:RecordActionBegin('update preview')

  call s:DisplayInfo("Previewing Workspace Update... ")

  redraw!

  let l:bufname = "Workspace Preview Update"
  let ContentFnRef = function("s:ActionController_UpdatePreview")
  call s:ManagedDisplayBuffer('update preview', l:bufname, ContentFnRef)

endfunction "}}}

" Function: ElementProperties {{{2
" Description: Display properties for the current element.
" Return: N/A
function! s:ElementProperties()
  call s:RecordActionBegin('properties')

  let l:title = "Properties"
  let l:ContentFnRef = function("s:ContentController_ElementProperties")
  call s:ManageSingletonElementBuffer('properties', l:title, ContentFnRef)
endfunction "}}}

" Function: History {{{2
" Description: Display transaction history for current file.
" Return: N/A
function! s:History()
  call s:RecordActionBegin('history')

  let l:title = "AccuRev History"
  let ContentFnRef = function("s:ContentController_ElementHistory")
  call s:ManageSingletonElementBuffer('history', l:title, ContentFnRef)

endfunction "}}}

" Function: Annotate {{{2
" Description: Display per-line change history.
" Return: N/A
function! s:Annotate()
  call s:RecordActionBegin('annotate')

  let l:filename = s:GetFilename()
  let l:content = s:ContentController_ElementAnnotate(l:filename)
  call s:ManagedAnnotateBuffer(l:filename, l:content)
  call s:RecordActionFinish('annotate [hist calls may continue]')

endfunction "}}}

" Function: Search {{{2
" Description: Display element search for given type of search (e.g. pending, modified).
" Parameters: type of search as String; (must be a key in stat cli hash defined in global vars)
" Return: N/A
function! s:Search(type)

  call s:RecordActionBegin('search - ' . a:type)

  let l:title = "AccuRev Search (" . a:type . ")"
  let ContentFnRef = function("s:ContentController_Search")
  let l:args = [a:type] " need to pass as List
  call s:ManagedDisplayBuffer('search - ' . a:type, l:title, ContentFnRef, l:args) 

endfunction "}}}

" Function: Defunct {{{2
" Description: Performs a 'defunct' on the current file.
"              This method is expected to be called on itself in case the user becomes
"              unauthenticated while the plugin is loaded and the defunct needs to be
"              retried with existing comment after login.
" Parameters: 1: Optional comment as String
" Return: N/A
function! s:Defunct(...)

  redraw!

  if s:BufferIsUnnamed()
    call s:DisplayError("Unable to Defunct! No filename. Save and try again.")
    return
  endif

  if s:BufferIsModified()
    call s:DisplayError("Unable to Defunct! Unsaved modifications exist. Save and try again.")
    return
  endif

  let l:filename = s:GetFilename()

  if s:HasModifiedStatus(l:filename)
    call s:DisplayError("Unable to Defunct! File is modified. Keep or purge, and try again.")
    return
  endif

  let l:response = s:Input_ConfirmContinue('Defuncting "' . s:GetDisplayFilename() . '".')

  " user canceled
  if l:response == s:false
    call s:DisplayInfo('Defunct canceled.')
    return
  endif

  if a:0 == 1 " comment provided
    let l:comment = a:1
  else " prompt user for comment
    let l:comment = s:Input_SingleLine('Defunct Comment [CTRL-c cancels]: ')
  endif

  if s:IsEmptyComment(l:comment)
    call s:DisplayErrorWithPrompt("Comment required.  Aborting.")
    redraw!
    return
  endif

  call s:RecordActionBegin('defunct')

  try

    let l:progbar = s:NewProgressBar(4)

    " let user know whats up; keep may take a few secs to send to server
    call s:DisplayInfo('Defuncting "' . s:GetDisplayFilename() . '"...')
    call s:IncrProgressBar(l:progbar)

    " perform the defunct; keep track of how long the operation will perform
    let l:start_time = s:TimingStart()
    let l:output = s:ActionController_Defunct(l:filename, l:comment)
    let l:elapsed_time = s:TimingElapsed(l:start_time)
    call s:IncrProgressBar(l:progbar)

    " erase previous message line for next; prevents message stacking
    redraw!

    " element not under version control
    if stridx(l:output, "No element named") >= 0
      call s:DisplayError("'" . l:filename . "' does not exist.  Defunct aborted.")
      return
    " element is read/only by way of crosslinking
    elseif stridx(l:output, "read only") >= 0
      call s:DisplayError("'" . l:filename . "' is read/only.  Possible xlink'd path?")
      return
    " user got logged out; get them back and retry the operation
    elseif stridx(l:output, "Not authenticated") >= 0
        call s:DisplayError("Not logged in!  Login and 'defunct' will retry...")
        call s:RecordActionStatus('defunct - login required')
        sleep 3 " let user see the login notice
        " attempt to re-login
        if s:AuthenticateUser() == s:true
          call s:RecordActionStatus('defunct re-login')
          call s:Defunct(l:comment)
          return
        endif
        call s:DisplayErrorWithPrompt("Login failed.  Defunct aborted.")
        return
    endif
    call s:IncrProgressBar(l:progbar)

    " remove all content in buffer; file no longer exists; not really a 'modification'
    0,$d
    setlocal nomodified

    call s:IncrProgressBar(l:progbar)

    " hey user, we're done!  fast, eh?
    call s:DisplayInfo('"' . s:GetDisplayFilename() . '" defuncted. (' . s:GetFileSizeDisplay() . ', ' . l:elapsed_time . 's)')

  " handle CTRL-C interrupt during user input and operation
  catch /^Vim:Interrupt$/ " capture CTRL-C
    redraw
    call s:DisplayInfo("Defunct interrupted... but may have completed. Check for (defunct) status.")
    call s:RecordActionStatus('defunct - interrupted (may have completed)')
    sleep 3 " let the 'keep' complete asynchronously then check status
  " cleanup regardless of success/failure
  finally
    call s:CloseProgressBar(l:progbar)
  endtry

  call s:Refresh('defunct')
  call s:RecordActionFinish('defunct finished')

endfunction "}}}

" Function: Undefunct {{{2
" Description: Performs an 'undefunct' on the current file.
"              This method is expected to be called on itself in case the user becomes
"              unauthenticated while the plugin is loaded and the defunct needs to be
"              retried after login.
" Return: N/A
function! s:Undefunct()

  redraw!

  if s:BufferIsUnnamed()
    call s:DisplayError("Unable to Undefunct! No filename. Save and try again.")
    return
  endif

  if s:BufferIsModified()
    call s:DisplayError("Unable to Undefunct! Unsaved modifications exist. Save and try again.")
    return
  endif

  let l:filename = s:GetFilename()

  if !s:HasDefunctStatus(l:filename)
    call s:DisplayError("Unable to Undefunct! File not defunct.")
    return
  endif

  " prevent undefuncting in the case where the file was defuncted locally
  " and then re-created immediately as a new file.  Initial defunct needs
  " to be promoted first, then a new file with the same name can be created.
  if s:HasDefunctModifiedStatus(l:filename)
    call s:DisplayError("Unable to Undefunct! File re-created with local modifications. Either promote the initial defunct then re-create locally or move, undefunct and manually merge.")
    return
  endif


  let l:response = s:Input_ConfirmContinue('Undefuncting "' . s:GetDisplayFilename() . '".')

  " user canceled
  if l:response == s:false
    call s:DisplayInfo('Undefunct canceled.')
    return
  endif

  call s:RecordActionBegin('undefunct')

  try

    let l:progbar = s:NewProgressBar(4)

    " let user know whats up; keep may take a few secs to send to server
    call s:DisplayInfo('Undefuncting "' . s:GetDisplayFilename() . '"...')
    call s:IncrProgressBar(l:progbar)

    " perform the undefunct; keep track of how long the operation will perform
    let l:start_time = s:TimingStart()
    let l:output = s:ActionController_Undefunct(l:filename)
    let l:elapsed_time = s:TimingElapsed(l:start_time)
    call s:IncrProgressBar(l:progbar)

    " erase previous message line for next; prevents message stacking
    redraw!

    " element not under version control
    if stridx(l:output, "No element named") >= 0
      call s:DisplayError("'" . l:filename . "' does not exist.  Undefunct aborted.")
      return
    " user got logged out; get them back and retry the operation
    elseif stridx(l:output, "Not authenticated") >= 0
        call s:DisplayError("Not logged in!  Login and 'undefunct' will retry...")
        call s:RecordActionStatus('undefunct - login required')
        sleep 3 " let user see the login notice
        " attempt to re-login
        if s:AuthenticateUser() == s:true
          call s:RecordActionStatus('undefunct re-login')
          call s:Undefunct()
          return
        endif
        call s:DisplayErrorWithPrompt("Login failed.  Undefunct aborted.")
        return
    endif
    call s:IncrProgressBar(l:progbar)

    " automatically load the newly reverted file into the buffer; not really a 'modification'
    call s:RecordActionStatus('undefunct buffer re-init')
    checktime
    set nomodified
    call s:IncrProgressBar(l:progbar)

    " hey user, we're done!  fast, eh?
    call s:DisplayInfo('"' . s:GetDisplayFilename() . '" undefuncted. (' . s:GetFileSizeDisplay() . ', ' . l:elapsed_time . 's)')

  " handle CTRL-C interrupt during user input and operation
  catch /^Vim:Interrupt$/ " capture CTRL-C
    redraw
    call s:DisplayInfo("Undefunct interrupted... but may have completed. Check for (member) status.")
    call s:RecordActionStatus('undefunct - interrupted (may have completed)')
    sleep 3 " let the 'keep' complete asynchronously then check status
  " cleanup regardless of success/failure
  finally
    call s:CloseProgressBar(l:progbar)
  endtry

  call s:Refresh('undefunct')
  call s:RecordActionFinish('undefunct finished')

endfunction "}}}

" Function: RevertRecent {{{2
" Description: Revert current file to most recent kept version.
" Return: N/A
function! s:RevertRecent()

  redraw!

  if s:BufferIsUnnamed()
    call s:DisplayError("Unable to Revert! No filename. Save and try again.") | return
  endif

  if s:BufferIsModified()
    call s:DisplayError("Unable to Revert! Unsaved modifications exist. Save and try again.") | return
  endif

  let l:filename = s:GetFilename()
  let l:response = s:Input_ConfirmContinue('Revert "' . s:GetDisplayFilename() . '" to most recent version.')

  " user canceled
  if l:response == s:false
    call s:DisplayInfo('Revert canceled.')
    return
   endif

  call s:RecordActionBegin('revert/recent')

  try

    let l:progbar = s:NewProgressBar(4)

    " let user know whats up; keep may take a few secs to send to server
    call s:DisplayInfo('Reverting "' . s:GetDisplayFilename() . '" to most recent...')
    call s:IncrProgressBar(l:progbar)

    " perform the revert; keep track of how long the operation will perform
    let l:start_time = s:TimingStart()
    let l:output = s:ActionController_RevertRecent(l:filename)
    let l:elapsed_time = s:TimingElapsed(l:start_time)
    call s:IncrProgressBar(l:progbar)

    " erase previous message line for next; prevents message stacking
    redraw!

    " bad element name
    if stridx(l:output, "No element named") >= 0
      call s:DisplayError("'" . l:filename . "' not found.  revert canceled.")
      return
    " user got logged out; get them back and retry the operation
    elseif stridx(l:output, "Not authenticated") >= 0
      call s:DisplayError("Not logged in!  Login and 'revert' will retry...")
      call s:RecordActionStatus('revert - login required')
      sleep 3 " let user see the login notice
      " attempt to re-login
      if s:AuthenticateUser() == s:true
        call s:RecordActionStatus('revert/recent re-login')
        call s:RevertRecent()
        return
      endif
      call s:DisplayErrorWithPrompt("Login failed.  Revert aborted.")
      return
    endif
    call s:IncrProgressBar(l:progbar)

    " automatically load the newly reverted file into the buffer
    call s:RecordActionStatus('revert/recent buffer re-init')
    checktime
    call s:IncrProgressBar(l:progbar)

    " hey user, we're done!  fast, eh?
    call s:DisplayInfo('"' . s:GetDisplayFilename() . '" reverted. (' . s:GetFileSizeDisplay() . ', ' . l:elapsed_time . 's)')

  " handle CTRL-C interrupt during user input and operation
  catch /^Vim:Interrupt$/ " capture CTRL-C
    redraw
    call s:DisplayInfo("Revert interrupted... but may have completed. Check status.")
    call s:RecordActionStatus('revert/recent - interrupted (may have completed)')
    sleep 3 " let the 'keep' complete asynchronously then check status
    " reload file; file can be successfully reverted during interruption
    checktime
  " cleanup regardless of success/failure
  finally
    call s:CloseProgressBar(l:progbar)
  endtry

  call s:Refresh('revert/recent')
  call s:RecordActionFinish('revert/recent')

endfunction "}}}

" Function: RevertBacked {{{2
" Description: Revert current file to backed version.
" Return: N/A
function! s:RevertBacked()

  redraw!

  if s:BufferIsUnnamed()
    call s:DisplayError("Unable to Revert! No filename. Save and try again.") | return
  endif

  if s:BufferIsModified()
    call s:DisplayError("Unable to Revert! Unsaved modifications exist. Save and try again.") | return
  endif

  let l:filename = s:GetFilename()
  let l:response = s:Input_ConfirmContinue('Reverting "' . s:GetDisplayFilename() . '" to backed version.')

  " user canceled
  if l:response == s:false
    call s:DisplayInfo('Revert canceled.')
     return
   endif

  call s:RecordActionBegin('revert/backed')

  try
    let l:progbar = s:NewProgressBar(4)

    " let user know whats up; keep may take a few secs to send to server
    call s:DisplayInfo('Reverting "' . s:GetDisplayFilename() . '" to backed...')
    call s:IncrProgressBar(l:progbar)

    " perform the revert; keep track of how long the operation will perform
    let l:start_time = s:TimingStart()
    let l:output = s:ActionController_RevertBacked(l:filename)
    let l:elapsed_time = s:TimingElapsed(l:start_time)
    call s:IncrProgressBar(l:progbar)

    " erase previous message line for next; prevents message stacking
    redraw!

    " bad element name
    if stridx(l:output, "No element named") >= 0
      call s:DisplayError("'" . l:filename . "' not found.  revert canceled.")
      return
    " user got logged out; get them back and retry the operation
    elseif stridx(l:output, "Not authenticated") >= 0
      call s:DisplayError("Not logged in!  Login and 'revert' will retry...")
      call s:RecordActionStatus('revert - login required')
      sleep 3 " let user see the login notice
      " attempt to re-login
      if s:AuthenticateUser() == s:true
        call s:RecordActionStatus('revert/backed re-login')
        call s:RevertBacked()
        return
      endif
      call s:DisplayErrorWithPrompt("Login failed.  Revert aborted.")
      return
    endif
    call s:IncrProgressBar(l:progbar)

    " automatically load the newly reverted file into the buffer
    call s:RecordActionStatus('revert/backed buffer re-init')
    checktime
    call s:IncrProgressBar(l:progbar)

    " hey user, we're done!  fast, eh?
    call s:DisplayInfo('"' . s:GetDisplayFilename() . '" reverted. (' . s:GetFileSizeDisplay() . ', ' . l:elapsed_time . 's)')

  " handle CTRL-C interrupt during user input and operation
  catch /^Vim:Interrupt$/ " capture CTRL-C
    redraw
    call s:DisplayInfo("Revert interrupted... but may have completed. Check status.")
    call s:RecordActionStatus('revert/backed - interrupted (may have completed)')
    sleep 3 " let the 'keep' complete asynchronously then check status
    " reload file; file can be successfully reverted during interruption
    checktime
  " cleanup regardless of success/failure
  finally
    call s:CloseProgressBar(l:progbar)
  endtry

  call s:Refresh('revert/backed')
  call s:RecordActionFinish('revert/backed')

endfunction "}}}

" Function: Diff {{{2
" Description: Performs all diff operations
" Parameters: 1=type of diff; simple keyword ie. mostrecent, backed, basis
" Return: N/A
function! s:Diff(type)

  redraw!

  let l:diff_type = a:type

  if s:BufferIsUnnamed()
    call s:DisplayError("Unable to Diff! No filename. Save and try again.") | return
  endif

  if s:BufferIsModified()
    call s:DisplayError("Unable to Diff! Unsaved modifications exist. Save and try again.") | return
  endif

  " don't allow multiple concurrent diffs; diff window status is global; scrolling scrolls all!
  if s:BufferInDiffMode()
    call s:DisplayWarning("Already in diff mode.  Exit current diff and try again.") | return
    return
  endif

  " info for current file
  let l:filename = s:GetFilename()
  let l:display_filename = s:GetDisplayFilename()
  let l:eid = s:DataController_ElementId(l:filename)

  " version to diff against
  if l:diff_type == "mostrecent"
    let l:diff_version = s:DataController_MostRecentVersion(l:filename)
  elseif l:diff_type == "backed"
    let l:diff_version = s:DataController_BackedVersion(l:filename)
  elseif l:diff_type == "basis"
    let l:diff_version = s:DataController_BasisVersion(l:filename)
  else
    call s:DisplayError("Error during diff.  Invalid type specified [" . a:type . "]")
    return
  endif

  call s:RecordActionBegin('diff - ' . l:diff_type)

  let l:diff_file = s:ElementAsTempFile(l:eid, l:diff_version)

  let l:bufid = s:GetBufferId()
  let l:winid = s:GetWindowId()

  " register current buffer in a 'diff group' using buffer id
  call s:SetBufferAttribute('diff_mode_enabled', s:true)
  call s:SetBufferAttribute('diff_group_id', l:bufid)
  call s:SetBufferAttribute('diff_type', l:diff_type)
  call s:SetBufferAttribute('diff_is_source_buffer', s:true)
  call s:SetBufferAttribute('diff_element_name', l:display_filename)

  augroup accurev_diff_events
    " ensure group is empty
    autocmd!
    " update diff display on file save
    autocmd BufWritePost <buffer> diffupdate
    " User quits window; close all other diff windows
    autocmd BufWinLeave <buffer> call s:DiffExitAndCloseWindow()
  augroup END

  diffthis
  " engage diff mode; switches current buffer to temp diff buffer
  exec "vsplit " . l:diff_file

  diffthis

  " register temp diff buffer in a 'diff group' using buffer id
  call s:SetBufferAttribute('diff_group_id', l:bufid)
  call s:SetBufferAttribute('diff_type', l:diff_type)
  call s:SetBufferAttribute('diff_is_source_buffer', s:false)
  call s:SetBufferAttribute('diff_element_name', l:display_filename)
  call s:SetBufferAttribute('diff_element_version', l:diff_version)

  if l:diff_type == "mostrecent"
    setlocal statusline=[diff/recent]\ %{b:accurev_attributes['diff_element_name']}\ %<%r
  elseif l:diff_type == "backed"
    setlocal statusline=[diff/backed]\ %{b:accurev_attributes['diff_element_name']}\ %<%r
  elseif l:diff_type == "basis"
    setlocal statusline=[diff/basis]\ %{b:accurev_attributes['diff_element_name']}\ %<%r
  endif

  setlocal nomodifiable
  setlocal readonly
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal nofoldenable
  setlocal bufhidden=wipe   " these are temp buffers; no need to preserve
  " User quits window; close all other diff windows
  autocmd WinEnter <buffer> exec "wincmd w"

  " move cursor to original source window
  exec l:winid . "wincmd w"
  " disable diff-settings in original buffer; they are auto-set with diffsplit (above)
  setlocal nofoldenable

  call s:RecordActionFinish('diff - ' . l:diff_type)

endfunction "}}}

" Function: CommandHistory {{{2
" Description: Displays accurev command history for buffer.
" Return: N/A
function! s:CommandHistory()

  if s:RecordCommandHistoryEnabled()

    let l:bufname = "Command History"
    let ContentFnRef = function("s:ContentController_CommandHistory")
    call s:ManagedDisplayBuffer('command history', l:bufname, ContentFnRef)
  else
    call s:DisplayInfo("Command history recording disabled.")
  end

endfunction "}}}

" Function: ListBufferAttributes {{{2
" Description: Displays the accurev buffer attributes for the current buffer
" Return: N/A
function! s:ListBufferAttributes()

  let l:bufname = "Buffer Attributes"
  let ContentFnRef = function("s:ContentController_BufferAttributes")
  call s:ManagedDisplayBuffer('buffer attributes', l:bufname, ContentFnRef)

endfunction "}}}

" Function: EnableAccuRevMenus {{{2
" Description: Enables the accurev menus if the plugin is loaded in the buffer.
" Return: N/A
function! s:EnableGuiMenus()
  call s:LoadBootMenuMappings()
  if s:IsInitialized()
    call s:LoadAuthMenuMappings()
  endif
endfunction "}}}

" Function: DisableAccuRevMenus {{{2
" Description: Disables the accurev menus if the plugin is loaded in the buffer.
" Return: N/A
function! s:DisableGuiMenus()
  if b:PluginLoaded()
    nunmenu &Plugin.&AccuRev
    call s:LoadBootMenuMappings()
  endif
endfunction "}}}

"}}}

" Section: Utility Business Functions (High-Level Utility) {{{1

" Function: AuthenticateUser {{{2
" Description: Prompt user to login if not already logged in.  Offers 'n' attempts
"              to login before ultimate failure.
" Return: true if user logged in; false otherwise
function! s:AuthenticateUser()
 
  let l:maxtries = 3
  let l:attempts = 0
  let l:logged_in = s:false

  " prompt user maxtries to provide uname/pword
  while l:logged_in == s:false && l:attempts < l:maxtries

    let l:username_prompt = ""
    let l:password_prompt = ""

    " display hostname in u/p prompt if available
    if s:HasBufferAttribute('server_name')
      let l:hostname = s:GetBufferAttribute('server_name')
      let l:username_prompt = "[" . l:hostname . "] AccuRev Username: "
      let l:password_prompt = "[" . l:hostname . "] AccuRev Password: "
    else
    let l:username_prompt = "AccuRev Username: "
    let l:password_prompt = "AccuRev Password: "
    end

    " note: vim does not throw CTRL-C interrupt if caught in inputsecret(...)
    let l:username = input(l:username_prompt)
    let l:password = inputsecret(l:password_prompt)

    redraw!

    try
      let l:progbar = s:NewProgressBar(2)
      call s:IncrProgressBar(l:progbar)

      call s:DisplayInfo("Logging in as " . l:username . "...")
      let l:logged_in = s:ActionController_Login(l:username, l:password)

      call s:IncrProgressBar(l:progbar)
    finally
      call s:CloseProgressBar(l:progbar)
    endtry

    redraw!

    if l:logged_in == s:false
      let l:attempts += 1
      call s:DisplayWarning("Login as '" . l:username . "' failed!  (attempt " . l:attempts . "/" . l:maxtries . ")")
      sleep 3
      redraw
    else
      call s:SetBufferAttribute('is_logged_in', s:true) " TODO wrong arch layer?
    endif
  endwhile

  return l:logged_in
endfunction "}}}

" Function: IsLoggedInStatus {{{2
" Description: Determines if the given status indicates logged in or not.
" Return: true if status means 'logged in'; false otherwise
function! s:IsLoggedInStatus(login_status)

  if a:login_status == "anyuser" || a:login_status == "authuser"
    return s:true
  endif

  return s:false

endfunction "}}}

" Function: IsLoggedIn {{{2
" Description: Determines if the current user is logged in to AccuRev.
" The current status from an auth check will be queried if not given.
" Providing the current status eliminates the need to redundantly call
" the server.
" Parameter: 1=optional status from doing auth check
" Return: true if user logged out; false otherwise
function! s:IsLoggedIn(status)
  let l:status = a:status
  if empty(l:status)
    let l:status = s:ServerAuthCheck()
  end
  return s:IsLoggedInStatus(l:status)
endfunction "}}}

" Function: IsLoggedOut {{{2
" Description: Determines if the current user is logged out of AccuRev.
" Parameter: 1=optional status from doing auth check
" Return: true if user logged out; false otherwise
function! s:IsLoggedOut(...)
  let l:status = s:empty
  " use status if given
  if a:0 > 0
    let l:status = a:1
  end
  return !s:IsLoggedIn(l:status)
endfunction "}}}

" Function: ServerAuthCheck {{{2
" Description: Determine if user is logged in, logged out, or network error.
" Return: true if user logged in; false otherwise
function! s:ServerAuthCheck()

  call s:RecordActionBegin('server/auth check')

  let l:status = s:DataController_AuthStatus()

  call s:RecordActionFinish('server/auth check')

  " search for network connection error; simplify return status
  if match(l:status, 'network error') >= 0
    let l:status = "unavailable"
  endif

  return l:status

endfunction "}}}

" Function: IsServerUnavailable {{{2
" Description: Determines if the given login status indicates that
"              the server is unavailable
" Return: true if server unavailable; false otherwise
function! s:IsServerUnavailable(login_status)

  if a:login_status == "unavailable"
    return s:true
  endif

  return s:false

endfunction "}}}

" Function: NotInWorkspace {{{2
" Description: Determines if the given login status indicates that
"              the current buffer file is not in a workspace.
" Return: true if server unavailable; false otherwise
function! s:NotInWorkspace()
  if s:IsAccuRevWorkspace() == s:false
    return s:true
  endif

  return s:false

endfunction "}}}

" Function: IsAccuRevWorkspace {{{2
" Description: Determines if the current element is in an accurev workspace.
" Return: true if in a workspace; false otherwise
function! s:IsAccuRevWorkspace()
 
  " use cached flag if avail for faster return; this function is called a lot
  if s:GetBufferAttribute("is_workspace") == s:true
    return s:true
  endif

  return s:false

endfunction "}}}

" Function: AccuRevClientExists {{{2
" Description: Determines if the AccuRev client is installed and available.
" Returns: true if client installed; false otherwise
function! s:AccuRevClientExists()
  " checks $PATH
  let l:exists = executable("accurev")

  if l:exists == 0 || l:exists == -1
    return s:false
  endif
  return s:true
endfunction "}}}

" Function: IdentifyWorkspace {{{2
" Description: Determines if the current working directory is an AccuRev workspace.
"              NOTE: relies on workspace info being available (pre-loaded) in buffer
"                    attributes (loaded during initialization).  Minimizes a server
"                    call to query wspace info for the top-dir.
" Returns: true if in a workspace; false otherwise
function! s:IdentifyWorkspace()

  if !s:HasBufferAttribute("workspace_root")
    return s:false
  endif

  " location of workspace
  let l:workspace_root = s:GetBufferAttribute("workspace_root")
  let l:workspace_root_norm = s:NormalizeFilename(l:workspace_root)

  " directory location of current file
  let l:element_dirname = s:GetBufferAttribute('element_dirname')
  let l:element_dirname_norm = s:NormalizeFilename(l:element_dirname)

  " no match - current file not located in workspace
  if match(l:element_dirname_norm, l:workspace_root_norm) >= 0
    " match - we're in!
    call s:SetBufferAttribute("is_workspace", s:true)
  endif

endfunction "}}}

" Function: GetElementDisplayStatus {{{2
" Description: Obtains the AccuRev file status for the provided element.
" Return: status as String
function! s:GetElementDisplayStatus(element)

  let l:status = s:DataController_ElementStatus(a:element)

  " provider user-friendly status for files that aren't saved to disk yet
  " (not even <external> yet in AccuRev's eyes)
  if l:status == "(no such elem)"
    let l:status = "(New File)"
  elseif l:status =~ "not in a directory associated with a workspace"
    let l:status = "Not in workspace"
  elseif l:status =~ "Not authenticated"
    let l:status = "Not authenticated"
  endif
  return l:status

endfunction " }}}

" Function: HasMemberStatus {{{2
" Description: Determines if the current element is alreayd a (member) of the
"              default group.
" Parameter: 1=element to check as String
" Return: true if in default group; false otherwise
function! s:HasMemberStatus(element)

  let l:status = s:DataController_ElementStatus(a:element)

  if l:status =~ "(member)"
    return s:true
  endif

  return s:false

endfunction " }}}

" Function: HasExternalStatus {{{2
" Description: Determines if the current element not in accurev; (external) status.
" Parameter: 1=element to check as String
" Return: true if external; false otherwise
function! s:HasExternalStatus(element)

  let l:status = s:DataController_ElementStatus(a:element)

  if l:status =~ "(external)"
    return s:true
  endif

  return s:false

endfunction " }}}

" Function: HasModifiedStatus {{{2
" Description: Determines if the current element is modified; (modified) status.
" Parameter: 1=element to check as String
" Return: true if modified; false otherwise
function! s:HasModifiedStatus(element)

  let l:status = s:DataController_ElementStatus(a:element)

  if l:status =~ "(modified)"
    return s:true
  endif

  return s:false

endfunction " }}}

" Function: HasDefunctStatus {{{2
" Description: Determines if the current element is defunct; (defunct) status.
" Parameter: 1=element to check as String
" Return: true if defunct; false otherwise
function! s:HasDefunctStatus(element)

  let l:status = s:DataController_ElementStatus(a:element)

  if l:status =~ "(defunct)"
    return s:true
  endif

  return s:false

endfunction " }}}

" Function: HasDefunctModifiedStatus {{{2
" Description: Determines if the current element is (defunct)(modified) status.
" Parameter: 1=element to check as String
" Return: true if defunct and modified; false otherwise
function! s:HasDefunctModifiedStatus(element)

  let l:status = s:DataController_ElementStatus(a:element)

  if l:status =~ "(defunct)(modified)"
    return s:true
  endif

  return s:false

endfunction " }}}

" Function: HasOverlapStatus {{{2
" Description: Determines if the current element is overlap; (overlap) status.
" Parameter: 1=element to check as String
" Return: true if overlap; false otherwise
function! s:HasOverlapStatus(element)

  let l:status = s:DataController_ElementStatus(a:element)

  if l:status =~ "(overlap)"
    return s:true
  endif

  return s:false

endfunction " }}}

" Function: ManualMergeRequired {{{2
" Description: Determines if the current overlap element requires manual resolution.
" Parameter: 1=element to check as String
" Return: true if manual merge required; false otherwise
function! s:ManualMergeRequired(element)
  let l:output = s:DataController_ManualMergeCheck(a:element)

  if l:output =~ "merge conflicts in contents, edit needed"
    return s:true
  endif

  return s:false

endfunction " }}}

" Function: BufferInDiffMode {{{2
" Description: Determines if current buffer is in accurev diff mode.
" Return: true if in diff mode; false otherwise
function! s:BufferInDiffMode()
  return s:HasBufferAttribute('diff_mode_enabled')
endfunction " }}}

" Function: DiffExit {{{2
" Description: Exits diff-mode for current element.  All temp diff buffers are closed
"              and vimdiff mode for the current buffer is disabled.  The original buffer
"              is NOT removed.  Simply the diff facade is torndown.
" Return: N/A
function! s:DiffExit()
  " ignore buffers not involved in diff'ing
  if !s:HasBufferAttribute("diff_group_id")
    return
  endif

  " for current buffer, the buffer group identifies the set of windows 
  let l:diff_group_id = s:GetBufferAttribute('diff_group_id')

  let l:bufnum = 0
  let l:endbufnum = bufnr('$')
  while l:bufnum < l:endbufnum
    let l:bufnum += 1
    if !bufexists(l:bufnum) | continue | endif

    let l:attrs = getbufvar(l:bufnum, "accurev_attributes")

    " ignore windows not in diff group
    if !has_key(l:attrs, "diff_group_id") | continue | endif

    " remove temp diff buffers
    if l:attrs['diff_group_id'] == l:diff_group_id && l:attrs['diff_is_source_buffer'] == s:false
      exec l:bufnum . "bwipeout"
    endif
  endwhile

  " remove diff mode from original buffer
  diffoff 

  " remove diff events by group
  autocmd! accurev_diff_events

  " disable diff mode in source buffer
  call s:RemoveBufferAttribute('diff_mode_enabled')
  call s:RemoveBufferAttribute('diff_group_id')
  call s:RemoveBufferAttribute('diff_type')
  call s:RemoveBufferAttribute('diff_is_source_buffer')
  call s:RemoveBufferAttribute('diff_element_name')

  return
endfunction "}}}

" Function: DiffExitAndCloseWindow {{{2
" Description: Exits diff-mode and closes the current window.  This is expected to be called
"              from a window close event.
"              Note: for some reason, when doing :quit in a file that has a diff buffer open,
"                    exiting diff mode would close the temp buffers but the :quit would not continue
"                    closing the last window.  So this method will force/continue the quit.
" Return: N/A
function! s:DiffExitAndCloseWindow()
  call s:DiffExit()
  quit
endfunction "}}}

" Function: RecordCommandHistoryEnabled {{{2
" Description: Determines if the AccuRev cli history should be recorded.
" Return: true if recording is enabled; false otherwise
function! s:RecordCommandHistoryEnabled()
  return s:record_command_history
endfunction "}}}

" Function: RecordActionBegin {{{2
" Description: Adds a 'begin' token to the command history.  This is intended to be called
"              at the beginning of a logical operation (eg. keep) for tracking which cli commands
"              are invoked for the operation.
" Parameters: 1=name of source (method) as String
" Return: N/A
function! s:RecordActionBegin(source)
  let l:message = ' ^^ ' . a:source
  call s:RecordMessage(message)
endfunction "}}}

" Function: RecordActionFinish {{{2
" Description: Adds a 'finish' token to the command history.  This is intended to be called
"              at the end of a logical operation (eg. keep) for tracking which cli commands
"              are invoked for the operation.
" Parameters: source of action as String
" Return: N/A
function! s:RecordActionFinish(source)
  let l:message = ' == ' . a:source
  call s:RecordMessage(message)
endfunction "}}}

" Function: RecordActionStatus {{{2
" Description: Adds a 'status' token to the command history.  This is intended to be called
"              in the middle of a logical operation (eg. keep) for tracking which cli commands
"              are invoked for the operation.
" Parameters: source of action as String
" Return: N/A
function! s:RecordActionStatus(source)
  let l:message = ' .. ' . a:source
  call s:RecordMessage(message)
endfunction "}}}

" Function: NewProgressBar {{{2
" Description: Creates a new progress bar instance.  Use increment and restore to
"              manipulate the progress bar.
" Return: instance of the progress bar.
function! s:NewProgressBar(steps)
  return vim#widgets#progressbar#NewSimpleProgressBar("Progress:", a:steps)
endfunction "}}}

" Function: CloseProgressBar {{{2
" Description: Closes the given progress bar instance.
" Parameters: 1=progress bar instance
" Return: N/A
function! s:CloseProgressBar(bar)
  call a:bar.restore()
endfunction "}}}

" Function: IncrProgressBar {{{2
" Description: Increments the given progress bar instance.
" Parameters: 1=progress bar instance
" Return: N/A
function! s:IncrProgressBar(bar)
  call a:bar.incr()
endfunction "}}}

" Function: PromoteByIssueEnabled {{{2
" Description: Determines if promoting by issues is enabled
" Return: true if enabled; false otherwise
function! s:PromoteByIssueEnabled()
  return s:enable_issue_promote
endfunction "}}}

" Function: PromptForIssueNumber {{{2
" Description: Prompt user for issue number.  Provides multiple retries.
" Return: issue number as String; -1 if not found
function! s:PromptForIssueNumber()

    let l:max_attempts = 3
    let l:attempt = 1
    let l:valid = s:false
    let l:try_prefix = ""
    let l:try_suffix = "Try again."

    " prompt for valid issue number; display attempts
    while l:attempt <= l:max_attempts && l:valid == s:false
      let l:attempt += 1
      let l:issue_num = s:Input_SingleLine(l:try_prefix . 'Promote Issue #: ')

      if len(l:issue_num) > 0 && match(l:issue_num, "\^\\d\\+\$") == -1
        call s:DisplayWarning("Invalid issue #'" . l:issue_num . "'. " . l:try_suffix)
        if l:attempt > 1 | let l:try_prefix = "[Try " . l:attempt . "/" . l:max_attempts . "] " | endif
        if l:attempt == l:max_attempts | let l:try_suffix = "" | endif
        sleep 3
        redraw!
      else
        let l:valid = s:true
      endif
    endwhile

    if l:valid == s:false
      let l:issue_num = s:notfound
    endif

    return l:issue_num

endfunction "}}}

" Function: IsRunningGui {{{2
" Description: Determines if the gim session is graphical vim and has menu enabled.
" Return: true if using graphical vim; false otherwise
function! s:IsRunningGui()
  return has("menu") || has ("gui_running")
endfunction "}}}

" Function: IsEmptyComment {{{2
" Description: Validate the emptiness incomming comment.
" Return: true if empty; false otherwise
function! s:IsEmptyComment(comment)
  if s:RequireComments()
    if empty(a:comment) || match(a:comment, '^\s\+$') == 0
      return s:true
    endif
  endif
  return s:false
endfunction "}}}


" }}}

" Section: User Input (HCI) {{{1
" Description: Responsible for prompting and returning user input.

" Function: Input_ConfirmContinue {{{2
" Description: Prompts user to confirm continuation.
" Parameters: 1=display describing action to confirm as String
" Return: true if user confirms; false otherwise
  function! s:Input_ConfirmContinue(message)
    let l:message  = a:message . " Are you sure? (y/N): "
    let l:input = ""
    while l:input !~ "[n|N|y|Y]"
      redraw
      let l:input = input(l:message, '')
      if l:input == ""
        let l:input = "N"
      endif
    endwhile

    if l:input =~ "[y|Y]"
      return s:true
    endif

    return s:false
  endfunction "}}}

" Function: Input_SingleLine {{{2
" Description: Prompts user to enter single line of input prompted with given string.
" Parameters: 1=prompt as String
" Return: User provided input as String
  function! s:Input_SingleLine(prompt)
    let l:input = input(a:prompt, '')
    return l:input
  endfunction "}}}

" Sub-Section: Multi-Select Promote {{{2

" Function: Input_MultiSelectPromote {{{3
" Description: Prompts user to enter comment and select elements for promote.
function! s:Input_MultiSelectPromote()

  call s:RecordActionBegin('group-promote')

  call s:DisplayInfo("Searching for pending elements... (may take time)")

  try
    let l:progbar = s:NewProgressBar(2)
    call s:IncrProgressBar(l:progbar)
    " all elements to display (as dict)
    let l:elements_list = s:DataController_SelectablePendingElements()
    call s:IncrProgressBar(l:progbar)
  catch /^Vim:Interrupt$/ " capture CTRL-C
    return
  finally
    call s:CloseProgressBar(l:progbar)
  endtry

  redraw!

  let l:num_elements = len(l:elements_list)

  " no elements to promote!
  if l:num_elements == 0
    call s:DisplayError("No elements to promote.  Default group is empty.")
    call s:RecordActionFinish('group-promote')
    return
  endif

  let l:multi_select_display = "(o) Select ALL" . "\n"
  let l:multi_select_display .= "( ) Select NONE" . "\n"
  " TODO generalize this delimeter; it's referenced many times in the input widget
  let l:multi_select_display .= "--" . "\n"

  let l:element_select_display = ""
  " construct display string; careful sorting original list as it's
  " used internally as-is (original order) for determining what the user selected
  for element_list in l:elements_list
    let l:element_name = element_list[0]
    let l:element_description = element_list[1]
    let l:element_select_display .= "[x] "
    let l:element_select_display .= l:element_description
    let l:element_select_display .= "\n"
  endfor

  " include template
  let l:display_content  = s:promote_comment_prefix
  let l:display_content .= "\n"
  let l:display_content .= "\n"
  " comment delimeter
  let l:display_content .= s:comment_delimeter
  let l:display_content .= "\n"
  " multi-select options
  let l:display_content .= l:multi_select_display
  " list of elements
  let l:display_content .= l:element_select_display

  let l:bufname = "Promote"
  " find existing buffer with given name (may have already been created)
  let l:bufid = FindBufferByAttr('buffer_name', l:bufname)

  call s:RecordActionStatus('group-promote - finished loading buffer')

  " create new buffer
  if s:BufferNotCreated(l:bufid)
    call s:CreateMultiSelectBuffer(l:bufname, l:display_content, l:elements_list)
  " update existing buffer with fresh content; do not create a new one
  else
    call s:UpdateMultiSelectBuffer(l:bufid, l:display_content, l:elements_list)
  endif

  " register handler to perform promote with contents of buffer
  " - contents of buffer edited by user, parsed, then used during promote
  autocmd BufUnload <buffer> :call s:InputController_MultiSelectPromote()

endfunction "}}}

" Function: InputController_MultiSelectPromote {{{3
" Description: Obtain user provided information and perform a promote action.
"              Also prompts for issue # if set.
" Return: None.
function! s:InputController_MultiSelectPromote()

  " identify current buffer
  let l:bufname = s:GetBufferName()
  let l:bufid = s:GetBufferIdByName(l:bufname)

  " get all lines as List
  let l:content = getbufline(l:bufid, 1, "$")

  " find separator between user comment multi-select options
  let l:delim = s:comment_delimeter
  let l:delim_index = index(l:content, l:delim)
  let l:delim_line_index = l:delim_index + 1

  " parse user comment
  let l:comment_end_index = l:delim_line_index - 1
  let l:comment = join(getbufline(l:bufid, 1, l:comment_end_index), "\n")

  " find separator between multi-select options and element list
  let l:multiselect_start_index = l:delim_line_index + 1
  " TODO refer to this delimeter via generalized reference; 3rd time i've seen it hardcoded
  let l:multiselect_delim = "--"
  let l:multiselect_delim_index = index(l:content, l:multiselect_delim)
  let l:multiselect_delim_line_index = l:multiselect_delim_index + 1

  " parse element list
  let l:elements_start_index = l:multiselect_delim_line_index + 1
  let l:elements = getbufline(l:bufid, l:elements_start_index, "$")

  let l:content_model = s:GetBufferAttribute("content_model")
  let l:selected_elements = []
  let l:cnt = 0
  for element in l:elements
    if match(element, '\[x\]') >= 0
      call add(l:selected_elements, l:content_model[l:cnt][0])
    endif
    let l:cnt += 1
  endfor

  let l:num_elements = len(l:selected_elements)

  " no elements selected; cancel promote
  if l:num_elements == 0
    " clear writing temp file from screen
    redraw
    call s:DisplayInfo("No elements selected.  Promote canceled.")
    call s:RecordActionFinish('group-promote - no elems selected')
    return
  endif

  " clear writing temp file from screen
  redraw!

  " get issue # to promote to
  let l:issue_num = -1

  if s:PromoteByIssueEnabled()

    let l:issue_num = s:PromptForIssueNumber()

    " invalid issue provided; support empty to imply 'no issue'
    if l:issue_num == s:notfound
      call s:DisplayError("Unable to Promote! Invalid issue # provided.  Try again.")
      call s:RecordActionFinish('group-promote - invalid issue provided')
      return
    endif
  endif

  call s:RecordActionStatus('group-promote - performing promote')

  try

    let l:progbar = s:NewProgressBar(4)

    " prepare optional display text for promote by issue
    let l:by_issue_msg = ""
    if len(l:issue_num) > 0 && l:issue_num != -1
      let l:by_issue_msg = " to issue #" . l:issue_num
    endif

    " let user know whats up; add may take a few secs to send to server
    call s:DisplayInfo('Promoting ' . l:num_elements . ' elements' . l:by_issue_msg . '...')
    call s:IncrProgressBar(l:progbar)

    let l:start_time = s:TimingStart()
    let l:output = s:ActionController_Promote(l:selected_elements, l:comment, l:issue_num)
    let l:elapsed_time = s:TimingElapsed(l:start_time)
    call s:IncrProgressBar(l:progbar)

    " erase previous message line for next; prevents message stacking
    redraw!

    " bad element name
    if stridx(l:output, "No element named") >= 0
      call s:DisplayError("'' not found.  Promote canceled.")
      return
    " filter rules
    elseif stridx(l:output, "Element is not in default group") >= 0
      call s:DisplayError("'' is not in default group.  Promote canceled.")
      return
    elseif stridx(l:output, "Element excluded") >= 0
      call s:DisplayError("'' excluded by incl/excl rules.  Promote canceled.")
      return
    elseif stridx(l:output, "No comment entered") >= 0
      call s:DisplayError("No comment entered.  Promote canceled.")
      return
    elseif stridx(l:output, "stream definition has changed") >= 0
      call s:DisplayError("Workspace definition changed.  Update workspace then retry.")
      return
    elseif stridx(l:output, "Change package gap") >= 0
      call s:DisplayError("Change package gap merge required. Check elements.  Promote canceled.")
      return
    elseif stridx(l:output, "stream is locked") >= 0
      let l:backing_stream = s:GetBufferAttribute('basis')
      call s:DisplayError("Backing stream '" . l:backing_stream . "' is locked.  Promote canceled.")
      return
    elseif stridx(l:output, "Issue not found") >= 0
      call s:DisplayError("Invalid issue #" . l:issue_num . ".  Promote canceled.")
      return
    elseif stridx(l:output, "Issue does not match promote criteria") >= 0
      call s:DisplayError("Invalid issue #" . l:issue_num . ". Check issue query for promote.  Promote canceled.")
      return
    endif
    call s:IncrProgressBar(l:progbar)

    " prepare optional display text for promote by issue
    let l:by_issue_msg = ""
    if len(l:issue_num) > 0 && l:issue_num != -1
      let l:by_issue_msg = " to issue #" . l:issue_num
    endif

    " hey user, we're done!  fast, eh?
    call s:DisplayInfo("Successfully promoted " . l:num_elements . " elements" . l:by_issue_msg. ". (" . l:elapsed_time . "s)")

    " update status lines for all open buffers since promote can affect groups of elements
    call UpdateElementStatusAllbuffers()

  " handle CTRL-C interrupt during user input and operation
  catch /^Vim:Interrupt$/ " capture CTRL-C
    redraw
    call s:DisplayInfo("Promote interrupted... but may have completed. Check for (backed) status.")
    call s:RecordActionStatus('promote - interrupted (may have completed)')
    sleep 3 " let the 'promote' complete asynchronously then check status
  " cleanup regardless of success/failure
  finally
    call s:CloseProgressBar(l:progbar)
  endtry

  call s:RecordActionFinish('group-promote finished')

endfunction "}}}

" }}}

" Sub-Section: Multi-Select Utilities {{{2

" Function: ToggleOption {{{3
" Description: Performs the majik of toggling selectable values in a multi-select buffer.
" Return: N/A
function! s:ToggleOption()

  " escape the brackets "[]" to not be considered regex char class designators
  let l:comment_delimeter_escaped = escape(escape(s:comment_delimeter, '['), ']')

  let l:curr_linenum = line('.')
  let l:comment_linenum = search(l:comment_delimeter_escaped, 'n')
  let l:separator_linenum = search("^--", 'n')
  let l:last_linenum = line('$')

  " current position as List [bufnum, lnum, col, off]
  let l:prev_position = s:GetBufferAttribute("saved_position")
  let l:curr_position = getpos('.')

  " buffer numbers
  let l:prev_bufnum = l:prev_position[0]
  let l:curr_bufnum = l:curr_position[0]
  " line numbers
  let l:prev_linenum = l:prev_position[1]
  let l:curr_linenum = l:curr_position[1]
  " column numbers
  let l:prev_column = l:prev_position[2]
  let l:curr_column = l:curr_position[2]

  call s:SetBufferAttribute("saved_position", getpos('.'))

  " comment area; no toggling necessary; let user continue editing
  if l:curr_linenum < l:comment_linenum
    setlocal modifiable
    return
  endif

  " jump over comment delimeter
  if l:curr_linenum == l:comment_linenum
    if l:prev_linenum < l:curr_linenum
      setlocal nomodifiable
      call cursor(l:curr_linenum + 1, 1)
    else
      setlocal modifiable
      call cursor(l:curr_linenum - 1, 1)
    endif
    " need to reset saved cursor position since we are forcing to a new location
    call s:SetBufferAttribute("saved_position", getpos('.'))
    return
  endif

  let l:curr_line = getline(l:curr_linenum)

  " jump over multi-option separator
  " TODO replace '--' with global script reference for widget separator
  if match(l:curr_line, "^--") >= 0
    if l:prev_linenum < l:curr_linenum
      call cursor(l:curr_linenum + 1, 1)
    else
      call cursor(l:curr_linenum - 1, 1)
    endif
  endif

  setlocal modifiable
  if l:curr_column > 1
    let l:new_line = ""
    " De-Select single option
    if match(l:curr_line, '\[x\]') >= 0
      let l:new_line = substitute(l:curr_line, '\[x\]', '\[ \]', '')

      " De-select the 'NONE' multiselect
      let l:select_none_linenum = search("Select NONE", 'n')
      let l:select_none_line = getline(l:select_none_linenum)
      let l:select_none_new_line = substitute(l:select_none_line, "(\.)", "( )", '')
      call setline(l:select_none_linenum, l:select_none_new_line)

      " De-select the 'ALL' multiselect
      let l:select_all_linenum = search("Select ALL", 'n')
      let l:select_all_line = getline(l:select_all_linenum)
      let l:select_all_new_line = substitute(l:select_all_line, "(\.)", "( )", '')
      call setline(l:select_all_linenum, l:select_all_new_line)

    " Select single option
    elseif match(l:curr_line, '\[ \]')  >= 0
      let l:new_line = substitute(l:curr_line, '\[ \]', '\[x\]', '')

      " De-select the 'NONE' multiselect
      let l:select_none_linenum = search("Select NONE", 'n')
      let l:select_none_line = getline(l:select_none_linenum)
      let l:select_none_new_line = substitute(l:select_none_line, "(\.)", "( )", '')
      call setline(l:select_none_linenum, l:select_none_new_line)

      " De-select the 'ALL' multiselect
      let l:select_all_linenum = search("Select ALL", 'n')
      let l:select_all_line = getline(l:select_all_linenum)
      let l:select_all_new_line = substitute(l:select_all_line, "(\.)", "( )", '')
      call setline(l:select_all_linenum, l:select_all_new_line)

    " Select ALL
    elseif match(l:curr_line, "(\.) Select ALL") >= 0
      let l:new_line = substitute(l:curr_line, "(\.)", "(o)", '')
      let l:select_none_linenum = search("Select NONE", 'n')
      let l:select_none_line = getline(l:select_none_linenum)
      let l:select_none_new_line = substitute(l:select_none_line, "(\.)", "( )", '')
      call setline(l:select_none_linenum, l:select_none_new_line)

      let l:line_cnt = l:separator_linenum + 1 " start after separator
      while l:line_cnt < l:last_linenum
        let l:temp_line = getline(l:line_cnt)
        let l:temp_new_line = substitute(l:temp_line, '\[.\]', '\[x\]', '')
        call setline(l:line_cnt, l:temp_new_line)
        let l:line_cnt += 1
      endwhile
    " Select NONE
    elseif match(l:curr_line, "(\.) Select NONE") >= 0
      let l:new_line = substitute(l:curr_line, "(\.)", "(o)", '')
      let l:select_all_linenum = search("Select ALL", 'n')
      let l:select_all_line = getline(l:select_all_linenum)
      let l:select_all_new_line = substitute(l:select_all_line, "(\.)", "( )", '')
      call setline(l:select_all_linenum, l:select_all_new_line)

      let l:line_cnt = l:separator_linenum + 1 " start after separator
      while l:line_cnt < l:last_linenum
        let l:temp_line = getline(l:line_cnt)
        let l:temp_new_line = substitute(l:temp_line, '\[.\]', '\[ \]', '')
        call setline(l:line_cnt, l:temp_new_line)
        let l:line_cnt += 1
      endwhile
    endif
    call setline(l:curr_linenum, l:new_line)
    call cursor(l:curr_linenum, 1)
  endif
  setlocal nomodifiable

endfunction "}}}

" Function: ToggleAnnotateHighlight {{{3
" Description: Performs the majik of toggling transaction highlighting in annotate.
"              As the user scrolls down the annotated file, pressing '<space>' or
"              right direction ('l' or right arrow) will highlight all lines
"              matching the transaction number on the current line.  The results
"              will remain highlighted until another line/txn is selected.
" Return: N/A
function! s:ToggleAnnotateHighlight()

  let l:curr_position = getpos('.')
  let l:curr_linenum = l:curr_position[1]
  let l:curr_column = l:curr_position[2]

  call setpos('.', [0, l:curr_linenum, 1, 0])

  " current line 'selected' either with 'space' or arrow
  if l:curr_column > 1
    let l:curr_line = getline('.')

    let l:full_match_str = ""

    if match(l:curr_line, "\s*Modified\s*") > 0

      let l:full_match_str = "/\\s*Modified\\s*.*/"

    else
      " first column is txn #; converting entire line to a number only uses first set of digits and ignores the rest
      let l:txn_num = str2nr(l:curr_line)
      "
      " match txn, date, user
      let l:txn_match_str = l:txn_num
      let l:date_match_str = "\\d\\{4}\\/\\d\\{2}\\/\\d\\{2}\\ \\d\\{2}:\\d\\{2}:\\d\\{2}"
      let l:name_match_str = "[a-zA-Z][a-zA-Z0-9\\_\\-\\.\\+\\@]*"
      let l:code_match = ".*$"
      let l:full_match_str = "/\\s*" . l:txn_match_str . "\\s*" .  l:date_match_str . "\\s*" .  l:name_match_str . "\\s*" . l:code_match . "/"

      " obtain and display history for transaction marked by current cursor position
      let l:hist_comment = s:DataController_TransactionCommentByElement(l:txn_num)
      let l:formatted_hist_comment = "Txn Comment: " . l:hist_comment
      call s:DisplayMessage(l:formatted_hist_comment)
    end

    " Note: requires definitions located in syntax/accurev.vim file
    let l:syntax_exec_str = "syntax match accurevAnnotate " . l:full_match_str

    syntax clear
    " reset syntax; command as string to execute
    execute l:syntax_exec_str

  endif

endfunction " }}}

" }}}

" }}}

" Section: Content Controllers (Read-Only Data Controller) {{{1
" Description: Responsible for obtaining, formatting, and returning model data.
"              Content controllers perform read-only operations and return
"              a formatted 'view' as a single String.

" Function: ContentController_Info {{{2
" Description: Retrieve, format, and return AccuRev info
" Return: String
function! s:ContentController_Info()

  let l:raw_output = s:Action_Info()
  let l:content_model = s:Parse_Info(l:raw_output)
  let l:content_view = s:View_Info(l:content_model)

  return l:content_view

endfunction "}}}

" Function: ContentController_ElementProperties {{{2
" Description: Retrieve, format, and return element properties for current element.
" Return: Element properties display as String
function! s:ContentController_ElementProperties(element)

  let l:raw_output = s:Action_ElementStat(a:element)
  let l:content_model = s:Parse_ElementProperties(l:raw_output)
  let l:content_view = s:View_ElementProperties(l:content_model)

  return l:content_view

endfunction "}}}

" Function: ContentController_ElementHistory {{{2
" Description: Retrieve, format, and return AccuRev history for a single element.
function! s:ContentController_ElementHistory(element)

  let l:raw_output = s:Action_ElementHistory(a:element)

  if stridx(l:raw_output, "Not authenticated") >= 0
    let l:content_view = "Not authenticated.  Please login, then show history again."
  else
    let l:content_model = s:Parse_ElementHistory(l:raw_output)
    let l:content_view = s:View_ElementHistory(l:content_model)
  endif

  return l:content_view

endfunction "}}}

" Function: ContentController_ElementAnnotate {{{2
" Description: Retrieve, format, and return AccuRev annotate for a single element.
function! s:ContentController_ElementAnnotate(element)

  let l:raw_output = s:Action_ElementAnnotate(a:element)

  if stridx(l:raw_output, "Not authenticated") >= 0
    let l:content_view = "Not authenticated.  Please login, then show history again."
  else
    let l:content_model = s:Parse_ElementAnnotate(l:raw_output)
    let l:content_view = s:View_ElementAnnotate(l:content_model)
  endif

  return l:content_view

endfunction "}}}

" Function: ContentController_Search {{{2
" Description: Retrieve, format, and return AccuRev search results based on given type.
" Parameters: type of search as String; (must be a key in stat cli hash defined in global vars)
" Return: String
function! s:ContentController_Search(type)

  let l:raw_output = s:Action_Search(a:type)
  "let l:content_model = s:Parse_Search(l:raw_output)
  "let l:content_view = s:View_Search(l:content_model)

  if l:raw_output == ""
    let l:raw_output = "No results found."
  endif

  return l:raw_output

endfunction "}}}

" Function: ContentController_CommandHistory {{{2
" Description: Retrieve, format, and return command history.
function! s:ContentController_CommandHistory()

  let l:content_model = s:GetBufferVariable(s:GetBufferId(), 'accurev_command_history')
  let l:content_view = "\n"
  let l:content_view = "Realtime log of CLI activity with the AccuRev server.""
  let l:content_view = "operation key: ^^ start | .. status | == end\n\n"
  let l:content_view .= "(Newest)\n\n"
  let l:content_view .= join(reverse(copy(l:content_model)), "\n")
  let l:content_view .= "\n\n"
  let l:content_view .= "(Oldest)\n"
  return l:content_view

endfunction "}}}

" Function: ContentController_BufferAttributes {{{2
" Description: Retrieve, format, and return buffer attributes.
function! s:ContentController_BufferAttributes()

  let l:content_model = s:GetBufferVariable(s:GetBufferId(), 'accurev_attributes')
  let l:content_view = ""
  for key in sort(keys(l:content_model))
    let l:content_view .= key . ":[" . l:content_model[key] . "]\n"
  endfor
  return l:content_view

endfunction "}}}

" }}}

" Section: Data Controllers (Read-Only Data Controller) {{{1
" Description: Responsible for obtaining, formatting, and returning model data.
"              Data controllers perform read-only operations and return
"              a formatted 'view' as a structured Dictionary.

" Function: DataController_Info {{{2
" Description: Retrieve, format, and return AccuRev info as data structure
" Return: Dictionary
function! s:DataController_Info()

  " NOTE: need to call 'info' from element location to determine if it is actually
  " within an accurev workspace; do a temporary chdir to run info from there

  " switch to element directory
  let l:save_cwd = getcwd()
  let l:element_dirname = s:GetBufferAttribute('element_dirname')
  silent exec "lcd " . l:element_dirname

  let l:raw_output = s:Action_Info()
  let l:model_formatted = s:Parse_Info(l:raw_output)

  " switch back to original dir
  silent exec "lcd " . l:save_cwd

  return l:model_formatted

endfunction "}}}

" Function: DataController_SelectablePendingElements {{{2
" Description: Retrieve, format, and return all 'pending' elements in selectable array format.
" Return: Array of arrays.  Nested array contains 0=element name/path, 1=display value
function! s:DataController_SelectablePendingElements()

  let l:raw_output = s:Action_PendingElements()
  let l:content_model = s:Parse_PendingElements(l:raw_output)
  let l:content_view = s:View_SelectablePendingElements(l:content_model)
  return l:content_view

endfunction "}}}

" Function: DataController_ElementStatus {{{2
" Description: Query, parse, and return status for given element. 
" Return: element status as String
function! s:DataController_ElementStatus(element)

  let l:xml =  s:Action_ElementStat(a:element)
  let l:status = s:GetXmlValue(l:xml, 'status')
  return l:status

endfunction "}}}

" Function: DataController_ElementId {{{2
" Description: Query, parse, and return element id for given element. 
" Return: element id as String
function! s:DataController_ElementId(element)

  let l:xml =  s:Action_ElementStat(a:element)
  let l:eid = s:GetXmlValue(l:xml, 'id')
  return l:eid

endfunction "}}}

" Function: DataController_AuthStatus {{{2
" Description: Retrieve the authorization status of the current user according to AccuRev.
" Return: status as String
function! s:DataController_AuthStatus()
  let l:model = s:Action_SecInfo() " model
  let l:formatted = s:Parse_SecInfo(l:model) "view
  return l:formatted
endfunction "}}}

" Function: DataController_ElementContent {{{2
" Description: Query, parse, and return content for element of given id/version.
" Return: element content String
function! s:DataController_ElementContent(eid, version)

  let l:content =  s:Action_Cat(a:eid, a:version)
  return l:content

endfunction "}}}


" Function: DataController_TransactionCommentByElement {{{2
" Description: Query, parse, and return transaction comment for given txn id.
"              Parses the accurev formatted history comment embedded in transaction
"              response and formats the entire, multi-line comment into a single string
"              containing the original user-provided comment string.
" Parameters: 1=transaction id as String
" Return: transaction comment as String
function! s:DataController_TransactionCommentByElement(txn)
  let l:content = s:DataController_HistoryByTransaction(a:txn)

  " convert hist stdout into list of indiv lines
  let l:all_lines = split(l:content, '\n')
  " parse history stdout for lines containing comment token 'e.g. '   # commit comment'
  " this filter removes all lines from full history not matching a comment line
  let l:comment_lines = filter(l:all_lines, 'v:val =~ "^\\s*#"')
  " multi-line comments joined into single string; ideal to minimize the amount of
  " display rows needed
  let l:comment_lines_joined = join(l:comment_lines, " ")
  " remove all comment prefix added by accurev hist (e.g. '  # ')
  let l:comment_formatted = substitute(l:comment_lines_joined, "\\ \\ #\\ ", "", "g")

  return l:comment_formatted
endfunction "}}}


" Function: DataController_HistoryByTransaction {{{2
" Description: Query, parse, and return full history for given transaction.
" Parameters: 1=transaction id as String
" Return: txn full history String
function! s:DataController_HistoryByTransaction(txn)
  let l:content = s:Action_HistoryByTransaction(a:txn)
  return l:content
endfunction "}}}

" Function: DataController_MostRecentVersion {{{2
" Description: Query, parse, and return the most recent version (real) for given element. 
" Return: element version as String
function! s:DataController_MostRecentVersion(element)

  let l:xml =  s:Action_ElementStat(a:element)
  let l:status = s:GetXmlValue(l:xml, 'Real')
  return l:status

endfunction "}}}

" Function: DataController_BackedVersion {{{2
" Description: Query, parse, and return the backed version (real) for given element. 
" Return: element version as String
function! s:DataController_BackedVersion(element)

  let l:xml =  s:Action_ElementStatBacked(a:element)
  let l:status = s:GetXmlValue(l:xml, 'Real')
  return l:status

endfunction "}}}

" Function: DataController_BasisVersion {{{2
" Description: Query, parse, and return the basis version (real) for given element. 
" Return: element version as String
function! s:DataController_BasisVersion(element)

  let l:xml = s:Action_ElementAncestorBasis(a:element)
  " get version in parts
  let l:stream = s:GetXmlValue(l:xml, 'stream')
  let l:ver = s:GetXmlValue(l:xml, 'version')
  " construct version as stream#/version#
  let l:anc_version = l:stream . '/' . l:ver

  return l:anc_version

endfunction "}}}

" Function: DataController_ManualMergeCheck {{{2
" Description: Query and determine if overlap element required manual merge.
" Return: element id as String
function! s:DataController_ManualMergeCheck(element)

  let l:output =  s:Action_MergeCheck(a:element)
  return l:output

endfunction "}}}

" }}}

" Section: Action Controllers (Read-Write Data Controller) {{{1
" Description: Responsible for obtaining, formatting, and returning model data.
"              Action controllers perform write operations that change data on the AccuRev server.

" Function: ActionController_Login {{{2
" Description: Perform AccuRev login and validate response
" Parameters: 1=username, 2=password
" Return: true if logged in; false otherwise
function! s:ActionController_Login(username, password)

  let l:output = s:Action_Login(a:username, a:password)

  " look for login failure
  if matchstr(l:output, "Failed", 0) == "Failed"
    return s:false
  endif

  " double check by verifying auth status
  let l:output = s:Action_SecInfo()

  if l:output == "notauth"
    return s:false
  endif

  return s:true

endfunction "}}}

" Function: ActionController_Logout {{{2
" Description: Perform AccuRev logout and validate response
" Return: true if logged out; false otherwise
function! s:ActionController_Logout()

  let l:output = s:Action_Logout()

  " double check by verifying auth status
  let l:output = s:DataController_AuthStatus()
  if l:output == "notauth"
    return s:true
  endif

  return s:false

endfunction "}}}

" Function: ActionController_Add {{{2
" Description: Validate and perform the add operation
" Parameters: 2=filename to add as String, 2=add comment as String
" Return: output from add command
function! s:ActionController_Add(element, comment)

  let l:element_list = [a:element]
  let l:comment_formatted = s:FormatComment(a:comment)

  let l:output = s:Action_Add(l:element_list, l:comment_formatted)

  return l:output

endfunction "}}}

" Function: ActionController_Keep {{{2
" Description: Validate and perform the keep operation
" Parameters: 1=filename to keep as String, 2=keep comment as String
" Return: output from keep command
function! s:ActionController_Keep(element, comment)

  let l:element_list = [a:element]
  let l:comment_formatted = s:FormatComment(a:comment)

  let l:output = s:Action_Keep(l:element_list, l:comment_formatted) 

  return l:output

endfunction "}}}

" Function: ActionController_Anchor {{{2
" Description: Validate and perform the anchor operation
" Parameters: 1=filename to anchor as String, 2=comment as String
" Return: output from anchor command
function! s:ActionController_Anchor(element, comment)

  let l:element_list = [a:element]
  let l:comment_formatted = s:FormatComment(a:comment)

  let l:output = s:Action_Anchor(l:element_list, l:comment_formatted) 

  return l:output

endfunction "}}}

" Function: ActionController_Populate {{{2
" Description: Validate and perform the populate operation
" Parameters: 1=filename to anchor as String
" Return: output from populate command
function! s:ActionController_Populate(element)

  let l:element_list = [a:element]
  let l:output = s:Action_Populate(l:element_list) 
  return l:output

endfunction "}}}

" Function: ActionController_Promote {{{2
" Description: Validate and perform the promote operation
" Parameters: 1=elements as List of names, 2=promote comment as String, 3=issue # as String
" Return: output from promote command
function! s:ActionController_Promote(elements, comment, issue_num)

  let l:comment_formatted = s:FormatComment(a:comment)

  let l:output = s:Action_Promote(a:elements, l:comment_formatted, a:issue_num)

  return l:output

endfunction "}}}

" Function: ActionController_AutoMerge {{{2
" Description: Validate and perform the automatic merge operation.
" Parameters: 1=filename to keep as String
" Return: output from merge command
function! s:ActionController_AutoMerge(element)

  let l:output = s:Action_AutoMerge(a:element) 
  return l:output

endfunction "}}}

" Function: ActionController_SyncTime {{{2
" Description: Perform AccuRev synctime
" Return: output from synctime
function! s:ActionController_SyncTime()

  let l:output = s:Action_SyncTime()
  return l:output

endfunction "}}}

" Function: ActionController_Update {{{2
" Description: Retrieve, format, and return AccuRev update
" Return: output from update command as String
function! s:ActionController_Update()

  let l:progbar = s:NewProgressBar(3)
  call s:IncrProgressBar(l:progbar)

  " perform update
  let l:output = s:Action_Update()

  call s:IncrProgressBar(l:progbar)

  " format update
  let l:model = s:Parse_Update(l:output)

  call s:IncrProgressBar(l:progbar)

  let l:workspace_root = s:GetBufferAttribute('workspace_root')

  " validate update
  if stridx(l:output, "Not authenticated") >= 0
    let l:model = "Not authenticated.  Please login, then update again."
  endif

  call s:CloseProgressBar(l:progbar)

  " construct view
  let l:view  = "Workspace: " . l:workspace_root . "\n\n"
  let l:view .= l:model

  return l:view

endfunction "}}}

" Function: ActionController_UpdatePreview {{{2
" Description: Retrieve, format, and return AccuRev update preview
" Return: output from update preview command as String
function! s:ActionController_UpdatePreview()
  let l:output = s:Action_UpdatePreview()
  let l:model = s:Parse_UpdatePreview(l:output)

  if stridx(l:output, "Not authenticated") >= 0
    let l:model = "Not authenticated.  Please login, then update preview again."
  endif

  let l:workspace_root = s:GetBufferAttribute('workspace_root')

  let l:view  = "Workspace: " . l:workspace_root . "\n\n"
  let l:view .= l:model

  return l:view

endfunction "}}}

" Function: ActionController_Defunct {{{2
" Description: Validate and perform the defunct operation
" Parameters: 1=element to defunct as String, 2=comment as String
" Return: output from defunct command
function! s:ActionController_Defunct(element, comment)

  let l:element_list = [a:element]
  let l:comment_formatted = s:FormatComment(a:comment)

  let l:output = s:Action_Defunct(l:element_list, l:comment_formatted) 

  return l:output

endfunction "}}}

" Function: ActionController_Undefunct {{{2
" Description: Validate and perform the undefunct operation
" Parameters: 1=element to undefunct as String
" Return: output from undefunct command
function! s:ActionController_Undefunct(element)

  let l:element_list = [a:element]

  let l:output = s:Action_Undefunct(l:element_list) 

  return l:output

endfunction "}}}

" Function: ActionController_RevertRecent {{{2
" Description: Validate and perform the revert to most recent operation
" Return: output from revert/purge command
" Parameters: 1=element name as String
function! s:ActionController_RevertRecent(element)

  let l:output = s:Action_RevertRecent(a:element)

  return l:output

endfunction "}}}

" Function: ActionController_RevertBacked {{{2
" Description: Validate and perform the revert to backed operation
" Return: output from revert/purge command
" Parameters: 1=element name as String
function! s:ActionController_RevertBacked(element)

  let l:output = s:Action_RevertBacked(a:element)

  return l:output

endfunction "}}}

" }}}

" Section: Action Functions (Data Access Layer) {{{1
" Description: Return raw output from AccuRev; STDOUT or XML

" Function: Action_Info {{{2
" Description: Return client/server information
" Return: output from info command as String
function! s:Action_Info()
  let l:stdout = s:ExecCommand('info -v')
  return l:stdout
endfunction "}}}

" Function: Action_SecInfo {{{2
" Description: Obtain authorization information for current user
" Return: output from secinfo command as String
function! s:Action_SecInfo()
  let l:cmd = "secinfo"
  let l:output = s:ExecCommand(l:cmd)
  return l:output
endfunction "}}}

" Function: Action_Login {{{2
" Description: Login to AccuRev with given username/password.
" Return: output from login command as String
function! s:Action_Login(username, password)
  let l:cmd = "login " . a:username . ' ' . '"' . a:password . '"'
  let l:output = s:ExecCommand(l:cmd)
  return l:output
endfunction "}}}

" Function: Action_Logout {{{2
" Description: Logout current user from AccuRev
" Return: output from logout command as String
function! s:Action_Logout()
  let l:cmd = "logout"
  let l:output = s:ExecCommand(l:cmd)
  return l:output
endfunction "}}}

" Function: Action_Add {{{2
" Description: Performs an add operation in AccuRev with given elements and comment.
" Parameters: 1=elements to add as List, 2=comment as String
" Return: output from add command as String
function! s:Action_Add(elements, comment)

  let l:elements_tempfile = s:ElementsAsTempFile(a:elements)
  let l:comment_tempfile = s:CommentAsTempFile(a:comment)

  let l:cmd = 'add -L "' . s:GetWorkspaceRoot() . '" -c@"' . l:comment_tempfile . '" -l "' . l:elements_tempfile . '"'
  let l:output = s:ExecCommand(l:cmd)

  " remove temp files
  call s:DeleteFile(l:elements_tempfile)
  call s:DeleteFile(l:comment_tempfile)

  return l:output

endfunction "}}}

" Function: Action_Keep {{{2
" Description: Performs a keep operation in AccuRev with given elements and comment.
" Parameters: 1=elements to keep as List, 2=comment as String
" Return: output from keep command as String
function! s:Action_Keep(elements, comment)

  let l:elements_tempfile = s:ElementsAsTempFile(a:elements)
  let l:comment_tempfile = s:CommentAsTempFile(a:comment)

  let l:cmd = 'keep -L "' . s:GetWorkspaceRoot() . '" -c@"' . l:comment_tempfile . '" -l "' . l:elements_tempfile . '"'

  let l:output = s:ExecCommand(l:cmd)

  " remove temp files
  call s:DeleteFile(l:elements_tempfile)
  call s:DeleteFile(l:comment_tempfile)

  return l:output

endfunction "}}}

" Function: Action_Anchor {{{2
" Description: Performs an anchor operation in AccuRev with given elements and comment.
" Parameters: 1=elements to anchor as List, 2= comment as String
" Return: output from anchor command as String
function! s:Action_Anchor(elements, comment)

  let l:elements_tempfile = s:ElementsAsTempFile(a:elements)
  let l:comment_tempfile = s:CommentAsTempFile(a:comment)

  let l:cmd = 'anchor -O -L "' . s:GetWorkspaceRoot() . '" -c@"' . l:comment_tempfile . '" -l "' . l:elements_tempfile . '"'

  let l:output = s:ExecCommand(l:cmd)

  " remove temp files
  call s:DeleteFile(l:elements_tempfile)
  call s:DeleteFile(l:comment_tempfile)

  return l:output

endfunction "}}}

" Function: Action_Populate {{{2
" Description: Performs a populate operation in AccuRev with given elements.
" Parameters: 1=elements to anchor as List
" Return: output from populate command as String
function! s:Action_Populate(elements)

  let l:elements_tempfile = s:ElementsAsTempFile(a:elements)

  let l:cmd = 'pop -O -L "' . s:GetWorkspaceRoot() . '" -l "' . l:elements_tempfile . '"'

  let l:output = s:ExecCommand(l:cmd)

  " remove temp files
  call s:DeleteFile(l:elements_tempfile)

  return l:output

endfunction "}}}

" Function: Action_Promote {{{2
" Description: Promote elements to AccuRev.  Will 'keep' any modified files.
" Parameters: 1=elements to promote as List of names, 2=comment as String, 3=issue # as String
" Return: output from promote command as String
function! s:Action_Promote(elements, comment, issue_num)

  let l:elements_tempfile = s:ElementsAsTempFile(a:elements)
  let l:comment_tempfile = s:CommentAsTempFile(a:comment)

  let l:issue_cli = ""
  if a:issue_num != s:notfound && a:issue_num != ""
    let l:issue_cli = "-I " . a:issue_num
  endif

  " promote command: auto-keep modified files
  let l:cmd = 'promote -K ' . l:issue_cli . ' -L "' . s:GetWorkspaceRoot() . '" -c@"' . l:comment_tempfile . '" -l "' . l:elements_tempfile . '"'
  let l:output = s:ExecCommand(l:cmd)

  " remove temp files
  call s:DeleteFile(l:elements_tempfile)
  call s:DeleteFile(l:comment_tempfile)

  return l:output

endfunction "}}}

" Function: Action_MergeCheck {{{2
" Description: Gather merge information for given element.  No merge performed.
" Return: merge info output as String
function! s:Action_MergeCheck(element)
  let l:element_escaped = s:EscapeFilename(a:element)
  let l:cmd = 'merge -i -L "' . s:GetWorkspaceRoot() . '" ' . l:element_escaped
  let l:output = s:ExecCommand(l:cmd)
  return l:output
endfunction "}}}

" Function: Action_AutoMerge {{{2
" Description: Perform automatic merge of given element.  Expected to be
"              in trivial overlap status.
" Return: merge info output as String
function! s:Action_AutoMerge(element)
  let l:element_escaped = s:EscapeFilename(a:element)
  let l:cmd = 'merge -K -L "' . s:GetWorkspaceRoot() . '" ' . l:element_escaped
  let l:output = s:ExecCommand(l:cmd)
  return l:output
endfunction "}}}

" Function: Action_SyncTime {{{2
" Description: Perform 'synctime' on client machine
" Return: output from synctime command as String
function! s:Action_SyncTime()
  let l:cmd = "synctime"
  let l:output = s:ExecCommand(l:cmd)
  return l:output
endfunction "}}}

" Function: Action_Update {{{2
" Description: Performs an update in the current workspace.
" Returns: output from update as String
function! s:Action_Update()
  let l:cmd = 'update -L "' . s:GetWorkspaceRoot() . '"'
  let l:output = s:ExecCommand(l:cmd)
  return l:output
endfunction "}}}

" Function: Action_UpdatePreview {{{2
" Description: Performs an update preview in the current workspace.
" Returns: output from update as String
function! s:Action_UpdatePreview()
  let l:cmd = 'update -i -L "' . s:GetWorkspaceRoot() . '"'
  let l:output = s:ExecCommand(l:cmd)
  return l:output
endfunction "}}}

" Function: Action_Defunct {{{2
" Description: Performs a defunct operation in AccuRev with given element and comment.
" Parameters: 1=elements to keep as List, 2=comment as String
" Return: output from defunct command as String
function! s:Action_Defunct(elements, comment)

  let l:elements_tempfile = s:ElementsAsTempFile(a:elements)
  let l:comment_tempfile = s:CommentAsTempFile(a:comment)

  let l:cmd = 'defunct -L "' . s:GetWorkspaceRoot() . '" -c@"' . l:comment_tempfile . '" -l "' . l:elements_tempfile . '"'

  let l:output = s:ExecCommand(l:cmd)

  " remove temp files
  call s:DeleteFile(l:elements_tempfile)
  call s:DeleteFile(l:comment_tempfile)

  return l:output

endfunction "}}}

" Function: Action_Undefunct {{{2
" Description: Performs an undefunct operation in AccuRev with given element and comment.
" Parameters: 1=elements to keep as List
" Return: output from undefunct command as String
function! s:Action_Undefunct(elements)

  let l:elements_tempfile = s:ElementsAsTempFile(a:elements)

  let l:cmd = 'undefunct -L "' . s:GetWorkspaceRoot() . '" -l "' . l:elements_tempfile . '"'

  let l:output = s:ExecCommand(l:cmd)

  " remove temp files
  call s:DeleteFile(l:elements_tempfile)

  return l:output

endfunction "}}}

" Function: Action_RevertRecent {{{2
" Description: Performs a pop operation in AccuRev with given element to retrieve
"              the most recent kept version of the file; local mods are discarded.
" Parameters: 1=element to purge as String
" Return: output from purge command as String
function! s:Action_RevertRecent(element)

  let l:elements = [a:element]
  let l:elements_tempfile = s:ElementsAsTempFile(l:elements)

  let l:cmd = 'pop -fx -O -L "' . s:GetWorkspaceRoot() . '" -l "' . l:elements_tempfile . '"'

  let l:output = s:ExecCommand(l:cmd)

  " remove temp files
  call s:DeleteFile(l:elements_tempfile)

  return l:output

endfunction "}}}

" Function: Action_RevertBacked {{{2
" Description: Performs a purge operation in AccuRev with given element to rever to backed.
" Parameters: 1=element to purge as String
" Return: output from purge command as String
function! s:Action_RevertBacked(element)

  let l:elements = [a:element]
  let l:elements_tempfile = s:ElementsAsTempFile(l:elements)

  let l:cmd = 'purge -L "' . s:GetWorkspaceRoot() . '" -l "' . l:elements_tempfile . '"'

  let l:output = s:ExecCommand(l:cmd)

  " remove temp files
  call s:DeleteFile(l:elements_tempfile)

  return l:output

endfunction "}}}

" Function: Action_ElementHistory {{{2
" Description: Return history for given element. 
" Return: element history as String
function! s:Action_ElementHistory(element)
  let l:relative_element = s:ConvertToRelativeName(a:element)
  let l:relative_element_escaped = s:EscapeFilename(l:relative_element)
  " TODO return as xml and parse into custom view
  let l:cmd = 'hist -p "' . s:GetDepot() . '" -fev ' . l:relative_element_escaped
  let l:output = s:ExecCommand(l:cmd)
  return l:output
endfunction "}}}

" Function: Action_ElementAnnotate {{{2
" Description: Return per-line annotate history for given element. 
" Return: element history as String
function! s:Action_ElementAnnotate(element)
  let l:element_escaped = s:EscapeFilename(a:element)
  let l:cmd = 'annotate -L "' . s:GetWorkspaceRoot() . '" -ftdu ' . l:element_escaped
  let l:output = s:ExecCommand(l:cmd)
  return l:output
endfunction "}}}

" Function: Action_HistoryByTransaction {{{2
" Description: Retrieves full history for the given transaction.
" Parameters: 1=transaction id
" Return: output from history command as String
function! s:Action_HistoryByTransaction(txn)

  let l:depot = s:GetDepot()
  let l:cmd = 'hist -fev -p "' . l:depot . '" -t "' . a:txn . '"'
  let l:output = s:ExecCommand(l:cmd)

  return l:output

endfunction "}}}


" commands used for status search queries
let s:search_stat_cli = {
                 \ 'pending': 'stat -p',
                 \ 'modified': 'stat -m',
                 \ 'kept': 'stat -k',
                 \ 'nonmember': 'stat -n',
                 \ 'defgroup': 'stat -d',
                 \ 'overlap': 'stat -o',
                 \ 'deepoverlap': 'merge -o -B',
                 \ 'moddefgroup': 'stat -m -d',
                 \ 'external': 'stat -x',
                 \ 'missing': 'stat -M',
                 \ 'stranded': 'stat -i',
                 \ 'defunct': 'stat -D',
                 \ 'stale': 'update -i'
                 \ }

" Function: Action_Search {{{2
" Description: Return search query based on given type (e.g. pending, modified)
" Return: String
function! s:Action_Search(type)

  " display error; this should only be displayed to the plugin developer as the mappings are hardcoded to the cli hash above
  if !has_key(s:search_stat_cli, a:type)
    return "ERROR: Invalid search requested. Check mappings and/or cli hash. type=[" . a:type . "]"
  endif

  " lookup cli call for given type
  let l:cmd_stat = s:search_stat_cli[a:type]
  let l:cmd = l:cmd_stat . ' -L "' . s:GetWorkspaceRoot() . '"'
  let l:stdout = s:ExecCommand(l:cmd)
  return l:stdout
endfunction "}}}

" Function: Action_ElementStat {{{2
" Description: Return stat information for given element.
" Return: element stat in XML as String
function! s:Action_ElementStat(element)
  let l:element_escaped = s:EscapeFilename(a:element)
  let l:cmd = 'stat -fx -L "' . s:GetWorkspaceRoot() . '" ' . l:element_escaped
  let l:output = s:ExecCommand(l:cmd)
  return l:output
endfunction "}}}

" Function: Action_ElementStatBacked {{{2
" Description: Return stat information for given backed version of element.
" Return: element stat in XML as String
function! s:Action_ElementStatBacked(element)
  let l:element_escaped = s:EscapeFilename(a:element)
  let l:cmd = 'stat -L "' . s:GetWorkspaceRoot() . '" -fx -b ' . l:element_escaped
  let l:output = s:ExecCommand(l:cmd)
  return l:output
endfunction "}}}

" Function: Action_ElementAncestorBasis {{{2
" Description: Return ancestor information for given element.
" Return: element ancestor info XML as String
function! s:Action_ElementAncestorBasis(element)
  let l:element_escaped = s:EscapeFilename(a:element)
  " note: not specifying '-v <versionId>' implies using the workspace version; this is what we want!
  let l:cmd = 'anc -L "' . s:GetWorkspaceRoot() . '" -fx -j ' . l:element_escaped
  let l:output = s:ExecCommand(l:cmd)
  return l:output
endfunction "}}}

" Function: Action_Cat {{{2
" Description: Return element content for given eid/version.
" Return: element content as String
function! s:Action_Cat(eid, version)
  let l:cmd = 'cat -L "' . s:GetWorkspaceRoot() . '" -e ' . a:eid . ' -v "' . a:version . '"'
  let l:output = s:ExecCommand(l:cmd)
  return l:output
endfunction "}}}

" Function: Action_PendingElements {{{2
" Description: Obtain all pending elements.
" Return: element list as hash
function! s:Action_PendingElements()
  let l:cmd = 'stat -L "' . s:GetWorkspaceRoot() . '" -fx -p'
  let l:output = s:ExecCommand(l:cmd)
  return l:output
endfunction "}}}

" Function: ExecCommand {{{2
" Description: Execute AccuRev binary with given command and return STDOUT
function! s:ExecCommand(cmd)
  " assume executable in path; validated on initialization
  let l:cli = 'accurev ' . a:cmd

  let l:output = system(l:cli)
  let l:return_code = v:shell_error
  " save exec history
  call s:RecordCommand(l:cli, l:output, l:return_code)

  " Debugging - display system command and error codes
  if l:return_code > 0
    let l:msg = "CLI status error. cmd=[" . l:cli . "] code=[" . l:return_code . "]\n"
    call s:DisplayDebug(l:msg)
  endif

  return l:output

endfunction "}}}

" Function: RecordCommand {{{2
" Description: Saves the given CLI and return status code to command history.
" Return: N/A
function! s:RecordCommand(cli, output, return_code)
  let l:message = '    [' . a:cli . "]/[" . a:return_code . "]"
  " only show verbose output if requested in user settings
  if s:verbose_command_history == s:true
    let l:message .= "\n"
    let l:message .= s:Chomp(l:output)
    let l:message .= "\n"
    let l:message .= "+--"
  endif

  call s:RecordMessage(l:message)

endfunction "}}}

" Function: RecordMessage {{{2
" Description: Saves the given message to command history with a timestamp.
" Parameter: 1=message to record as String
" Return: N/A
function! s:RecordMessage(msg)

  " only record if enabled
  if s:RecordCommandHistoryEnabled()

    let l:buffer_id = s:GetBufferAttribute('recording_buffer_id')
    let l:command_history_list = s:GetBufferVariable(l:buffer_id, 'accurev_command_history')

    let l:timestamp = strftime('%x %X')
    let l:message = l:timestamp . a:msg
    call add(l:command_history_list, l:message)
  endif

endfunction "}}}

" }}}

" Section: Parse Functions (Model) {{{1
" Description: Responsible for converting model data into data structures.

" Function: Parse_Info {{{2
" Description: Creates a dictionary representation of the workspace information.
"              The original info output is stdout with colon delimited name/value pairs.
" Return: Workspace info as Dictionary
function! s:Parse_Info(info)

  let l:lines = split(a:info, "\n")

  let l:info_dict = {}

  for l:line in l:lines
    " only parse lines with colon separating name/value pairs
    if stridx(l:line, ':') > 0
    " parse name/value pairs by colon and remove flanking whitespace
      let l:name = substitute(l:line, '\(.\{-\}\):\s*\(.*\)', '\1', '')
      let l:value = substitute(l:line, '\(.\{-\}\):\s*\(.*\)', '\2', '')
      let l:info_dict[l:name] = l:value
    endif
  endfor

  return l:info_dict

endfunction "}}}

" Function: Parse_ElementProperties {{{2
" Description: Creates a dictionary representation properties of the current element.
" Parameters: 1=xml listing of element properties
" Return: Element properaties as Dictionary
function! s:Parse_ElementProperties(xml)
  let l:elements_as_hash = s:ParseStatXml(a:xml)

  " TODO error handling for 0 or > 1
  let l:stat_hash = {}
  if len(l:elements_as_hash) == 1
    for location_key in keys(l:elements_as_hash)
      let l:stat_hash = l:elements_as_hash[location_key]
      break
    endfor
  endif
  return l:stat_hash
endfunction "}}}

" Function: Parse_SecInfo {{{2
function! s:Parse_SecInfo(data)
  return s:Chomp(a:data) " strip newline to return just string i.e. 'authuser'
endfunction "}}}

" Function: Parse_Update {{{2
function! s:Parse_Update(data)
  return a:data " return as-is
endfunction "}}}

" Function: Parse_UpdatePreview {{{2
function! s:Parse_UpdatePreview(data)
  return a:data " return as-is
endfunction "}}}

" Function: Parse_ElementHistory {{{2
function! s:Parse_ElementHistory(data)
  return a:data " return as-is
endfunction "}}}

" Function: Parse_ElementAnnotate {{{2
function! s:Parse_ElementAnnotate(data)
  return a:data " return as-is
endfunction "}}}

" Function: Parse_ModifiedNonMemberElements {{{2
" Description: Convert incoming XML into hash-based data structure.
" Parameters: 1=raw xml
" Return: Dictionary structure of elements, key=element-path, value=hash of attrs
function! s:Parse_ModifiedNonMemberElements(data)
  let l:elements_as_hash = s:ParseStatXml(a:data)
  return l:elements_as_hash
endfunction "}}}

" Function: Parse_PendingElements {{{2
" Description: Convert incoming XML into hash-based data structure.
" Parameters: 1=raw xml
" Return: Dictionary structure of elements, key=element-path, value=hash of attrs
function! s:Parse_PendingElements(data)
  let l:elements_as_hash = s:ParseStatXml(a:data)
  return l:elements_as_hash
endfunction "}}}

" }}}

" Section: View/Format Functions (View) {{{1
" Description: Responsible for formatting model data.

" Function: View_Info {{{2
" Description: Format client/server info
" Parameters: 1=data representing info as Dictionary
" Return: String
function! s:View_Info(model)

  let l:info_dict = a:model

  " temp store version for format calculation
  let l:info_dict["Plugin Version"] = s:accurev_plugin_version

  let l:max_name_length = s:MaxKeyLength(l:info_dict)

  let l:format_spec  = "%-" . l:max_name_length . "s"
  let l:format_spec .= ' : '
  let l:format_spec .= "%s\n"

  let l:view = ""

  " show plugin version first
  let l:version = remove(l:info_dict, "Plugin Version")
  let l:view = printf(l:format_spec, "Plugin_Version", l:version)

  " show remaining info items in any order
  for l:key in sort(keys(l:info_dict))
    let l:view .= printf(l:format_spec, l:key, l:info_dict[l:key])
  endfor

  return l:view

endfunction "}}}

" Function: View_ElementHistory {{{2
" Description: Format element history
" Parameters: 1=data representing history of file
" Return: String
function! s:View_ElementHistory(model)
  return a:model " as-is for now
endfunction "}}}

" Function: View_ElementAnnotate {{{2
" Description: Format per-line change history
" Parameters: 1=data representing annotate of file
" Return: String
function! s:View_ElementAnnotate(model)
  return a:model " as-is for now
endfunction "}}}

" Function: View_ElementProperties {{{2
" Description: Format element properties
" Parameters: 1=data representing element properties as hash of name/value pairs
" Return: display as String
function! s:View_ElementProperties(model)

  let l:max_name_length = s:MaxKeyLength(a:model)

  let l:format_spec  = "%-" . l:max_name_length . "s"
  let l:format_spec .= ' : '
  let l:format_spec .= "%s\n"

  let l:view = ""
  for key in keys(a:model)
    let l:view .= printf(l:format_spec, l:key, a:model[l:key])
  endfor

  return l:view
endfunction "}}}

" Function: View_ModifiedNonMemberElements {{{2
" Description: Format list of modified non-member elements
" Parameters: 1=model, hash of hashes representing elements
" Return: String
function! s:View_ModifiedNonMemberElements(model)
  let l:output  = "Modified Non-Member Elements"
  let l:output .= "\n"
  let l:output .= string(join(keys(a:model), "\n"))
  let l:output .= "\n"
  let l:output .= "\n"
  return l:output
endfunction "}}}

" Function: View_SelectablePendingElements {{{2
" Description: Construct a List of selectable pending elements.  The
"              return structure is a List of Lists.  Each nested List
"              contains 0=element name, 1=display string
" Parameters: 1=model, hash of hashes representing elements
" Return: List of Lists: [0=element name, 1=display string]
function! s:View_SelectablePendingElements(model) 

  let l:pending_elements = a:model " dictionary of all element info; key=element name, value=hash of attrs
  let l:element_list = [] " storage for return list

  " TODO sort by name, status
  let l:pending_elements_sorted = sort(keys(pending_elements))

  " construct display string
  for element in l:pending_elements_sorted
    " values to display
    let l:location = l:pending_elements[l:element]["location"]
    let l:status = l:pending_elements[l:element]["status"]
    let l:type = l:pending_elements[l:element]["elemType"]

    let l:size_display = "0bytes"
    if has_key(l:pending_elements[l:element], "size")
      let l:size = l:pending_elements[l:element]["size"]
      " additional formatting for size units
      let l:size_display = s:GetFileSizeDisplay(l:size)
    endif
    let l:realVersion = l:pending_elements[l:element]["Real"]
    let l:virtualVersion = l:pending_elements[l:element]["Virtual"]
    " width specifications
    let l:max_location_width = s:MaxAttrLength(l:pending_elements, "location")
    let l:max_status_width = s:MaxAttrLength(l:pending_elements, "status")

    " Format Display Layout
    " location
    let l:format_spec  = "%-" . l:max_location_width . "s "
    " status
    let l:format_spec .= "%-" . l:max_status_width. "s "
    " element type
    let l:format_spec .= "[%s] "
    " element size
    let l:format_spec .= "[%s] "
    " real/virtual version
    let l:format_spec .= "(r:%s v:%s)"

    " exact string to display
    let l:element_display = printf(l:format_spec, l:location, l:status, l:type, l:size_display, l:realVersion, l:virtualVersion)

    " store current element w/ display
    let l:entry_list = [l:element, l:element_display]
    call add(l:element_list, l:entry_list)
  endfor

  return l:element_list

endfunction "}}}

" }}}

" Section: Utility Functions {{{

" Sub-Section: Plugin Property Functions {{{2

" Function: LoadOnStartup {{{3
" Description: Property method that determines if the plugin is enabled upon vim/buffer startup.
" Return: true if enabled; false otherwise.
function! s:LoadOnStartup()
  return s:load_on_startup
endfunction " }}}

" Function: PluginLoaded {{{3
" Description: Property method that determines if the plugin is loaded.
" Return: true if loaded; false otherwise.
function! b:PluginLoaded()
  return b:accurev_plugin_loaded
endfunction " }}}

" Function: SetPluginLoaded {{{3
" Description: Trips flag indicating that the plugin is loaded.
function! b:SetPluginLoaded()
  let b:accurev_plugin_loaded = s:true
endfunction " }}}

" Function: UnsetPluginLoaded {{{3
" Description: Trips flag indicating that the plugin is not loaded.
function! b:UnsetPluginLoaded()
  let b:accurev_plugin_loaded = s:false
endfunction " }}}

" Function: ShowStatusMessages {{{3
" Description: Property method that indicates if verbose status information should be displayed.
function! s:ShowStatusMessages()
  return s:show_status_messages
endfunction " }}}

" Function: GraphicalMergeEnabled {{{3
" Description: Property method that indicates if accurev's graphical merge shoudl bve launched on merge conflict.
function! s:GraphicalMergeEnabled()
  return s:graphical_merge_enabled
endfunction " }}}

" Function: RequireComments {{{3
" Description: Property method that indicates if non-empty comments are required.
function! s:RequireComments()
  return s:require_comments
endfunction " }}}



"2}}}
"
" Sub-Section: Platform Functions {{{2

" Function: s:OnWindows {{{3
" Description: Determines if the local operating system is Windows-based.
" Return: true if on Windows; false otherwise.
function! s:OnWindows()
  if has('win32') || has('dos32') || has('win16') || has('dos16') || has('win95')
    return s:true
  endif
  return s:false
endfunction "}}}

" Function: s:OnUnix {{{3
" Description: Determines if the local operating system is Unix-based.
" Return: true if on Unix; false otherwise.
function! s:OnUnix()
  if has('unix')
    return s:true
  endif
  return s:false
endfunction "}}}

" Function: IsAbsolutePath {{{3
" Description: Determines if the given path is absolute or not
"              unix: /foo/bar.c
"              win: c:\foo\bar.c, \\net\foo\bar.c
" Return: true if absolute; false otherwise
function! s:IsAbsolutePath(path)
  let l:absolute = s:false

  if s:OnUnix() || s:OnWindows()
    if match(a:path, '^/') == 0
      let l:absolute = s:true
    endif
  endif

  if (!l:absolute) && s:OnWindows()
    if match(a:path, "^\\") == 0
      let l:absolute = s:true
    endif

    if match(a:path, "^[A-Za-z]:") == 0
      let l:absolute = s:true
    endif
  endif

  return l:absolute
endfunction "}}}

" Function: NormalizeFilename {{{3
" Description: Convert given pathname into a cononical form
"              for comparing across platforms.  Transforms filename
"              into abs path, all lowercase, single-slashes, unc capable.
" Parameter: filename as String to normalize
" Return: new filename in canonical form
function! s:NormalizeFilename(fileName)
  let fileName = substitute(a:fileName, '^\s\+\|\s\+$', '', 'g')

  " Expand relative paths and paths containing relative components (takes care
  " of ~ also).
  if ! s:IsAbsolutePath(fileName)
    let fileName = fnamemodify(fileName, ':p')
  endif

  " I think we can have UNC paths on UNIX, if samba is installed.
  if s:OnWindows() && (match(fileName, '^//') == 0 ||
        \ match(fileName, '^\\\\') == 0)
    let uncPath = s:true
  else
    let uncPath = s:false
  endif

  " Remove multiple path separators.
  if has('win32')
    let fileName=substitute(fileName, '\\', '/', 'g')
  elseif s:OnWindows()
    " On non-win32 systems, the forward-slash is not supported, so leave back-slash.
    let fileName=substitute(fileName, '\\\{2,}', '\', 'g')
  endif
  let fileName=substitute(fileName, '/\{2,}', '/', 'g')

  " Remove ending extra path separators.
  let fileName=substitute(fileName, '/$', '', '')
  let fileName=substitute(fileName, '\\$', '', '')

  " If it was an UNC path, add back an extra slash.
  if uncPath
    let fileName = '/'.fileName
  endif

  if s:OnWindows()
    " force drive letter to lowercase
    let fileName=substitute(fileName, '^[A-Z]:', '\L&', '')

    " Add lowercase drive letter if missing (just in case).
    if !uncPath && match(fileName, '^/') == 0
      let curDrive = substitute(getcwd(), '^\([a-zA-Z]:\).*$', '\L\1', '')
      let fileName = curDrive . fileName
    endif

    " lower case entire path
    let fileName=substitute(fileName, '[A-Z]', '\L&', 'g')

  endif
  return fileName
endfunction "}}}

" }}}

" Sub-Section: Timing Functions {{{2

" Function: TimingStart "{{{3
" Description: Obtains time as of now
" Return: Current time as of now
function! s:TimingStart()
  return reltime()
endfunction "}}}

" Function: TimingElapsed "{{{3
" Description: Determines amount of time spent as of give ntime
" Parameters: start time as time string (from reltime)
" Return: Formatted number of seconds (dd.dd) as String
function! s:TimingElapsed(start_time)
  let l:elapsed_time = reltimestr(reltime(a:start_time))
  let l:formatted_time = matchstr(l:elapsed_time, '\d\+\.\d\d')
  return l:formatted_time
endfunction "}}}

" }}}

" Sub-Section: Filename Functions {{{2

" Function: EscapeFilename {{{3
" Description: Format given filename to be presentable on CLI; flank in dbl quotes, escape spaces.
" Parameter: filename as String
" Return: new filename in escaped form
function! s:EscapeFilename(filename)
  " slash all embedded spaces
  let l:filename_space_escaped = substitute(a:filename, ' ', '\\ ', 'g')
  " flank with dbl quotes
  let l:filename_flanked = '"' . l:filename_space_escaped . '"'
  return l:filename_flanked
endfunction "}}}

" Function: ConvertToRelativeName {{{3
" Description: Convert the given abs path filename to workspace relative filename.
" Parameter: abs path filename as String
" Return: relative path filename as String
function! s:ConvertToRelativeName(abspath_filename)
  return substitute(a:abspath_filename, s:GetWorkspaceRoot(), '', '')
endfunction "}}}

" Function: GetFilename {{{3
" Description: Returns abs path of filename.
" Return: filename as String
function! s:GetFilename()
  return s:GetBufferAttribute('element_abspath')
endfunction "}}}

" Function: GetRelativeFilename {{{3
" Description: Returns 'workspace relative' path of filename.
" Return: filename as String
function! s:GetRelativeFilename()
  return s:GetBufferAttribute('element_relpath')
endfunction "}}}

" Function: GetDisplayFilename {{{3
" Description: Returns a 'friendly', shortened filename for display.
" Return: filename as String
function! s:GetDisplayFilename()
  return s:GetBufferAttribute('element_name')
endfunction "}}}

" Function: GetWorkspaceRoot {{{3
" Description: Returns abs path of workspace root directory.
" Return: Directory path as String
function! s:GetWorkspaceRoot()
  return s:GetBufferAttribute('workspace_root')
endfunction "}}}

" Function: GetDepot {{{3
" Description: Returns depot name associated with current file, based on workspace.
" Return: Depot name as String
function! s:GetDepot()
  return s:GetBufferAttribute('depot')
endfunction "}}}

" Function: GetFileSize {{{3
" Description: Determine file size in bytes for current file.
" Return: File size in bytes as String
function! s:GetFileSize()
    let l:filename = expand('%')
    let l:filesize_bytes = getfsize(l:filename)
    return l:filesize_bytes
endfunction "}}}

" Function: GetFileSizeDisplay {{{3
" Description: Determine and/or format size of file and generate approx size String
"              depending on unit of measure (e.g. 22Mb).  Can optionally send the
"              file size and the formmated string will be returned.
" Parameters: 1=optional file size in bytes as String
" Return: Estimated size of file as String
function! s:GetFileSizeDisplay(...)

  let l:filesize_bytes = 0

  " user provided file size
  if a:0 == 1
    let l:filesize_bytes = str2nr(a:1)
  else
    let l:filesize_bytes = s:GetFileSize()
  endif

  let l:filesize_display = ""

  if l:filesize_bytes == -1
    let l:filesize_display = ' 0bytes'
  elseif l:filesize_bytes < 1024
    let l:filesize_display = l:filesize_bytes . 'bytes'
  elseif l:filesize_bytes > 1024 && l:filesize_bytes < 1024000
    let l:filesize_display = '~' . (l:filesize_bytes/1000) . 'kb'
  elseif l:filesize_bytes > 1024000
    let l:filesize_display = '~' . (l:filesize_bytes/1000/1000) . 'Mb'
  endif

  return l:filesize_display

endfunction "}}}

" }}}

" Sub-Section: File Functions {{{2

" Function: DeleteFile {{{3
" Description: Remote the given file from the filesystem
" Parameters: 1=filename as String
function! s:DeleteFile(filename)

  if getftype(a:filename) == "file"
    let l:status = delete(a:filename)

    if l:status > 0
      call s:DisplayError('Unable to delete file "' . a:filename . '"')
    endif
  endif
endfunction "}}}

" Function: FileExists {{{3
" Description: Determines if a given file exists
" Parameters: 
function! s:FileExists(filename)
  if filereadable(a:filename)
    return s:true
  endif
  return s:false
endfunction "}}}

" }}}

" Sub-Section: Buffer Functions {{{2

" Function: BufferIsModified {{{3
" Description: Determines if the current buffer is modified.
" Return: true if modified; false otherwise.
function! s:BufferIsModified()
    return &modified
endfunction "}}}

" Function: BufferIsUnnamed {{{3
" Description: Determines if the current buffer has no name.
" Return: true if no name; false otherwise.
function! s:BufferIsUnnamed()
  let l:fname = expand('%')
  return strlen(l:fname) == 0
endfunction "}}}

" Function: BufferExists {{{3
" Description: Determines if the given buffer (by id#) exists.
" Return: true if buffer exists; false otherwise.
function! s:BufferExists(bufid)
  if bufexists(a:bufid)
    return s:true
  endif
  return s:false
endfunction "}}}

" Function: FindBufferByAttr {{{3
" Description: Searches all buffers for matching *unique* name/value search pattern.
" Return: Number of matched buffer; -1 otherwise; only one match currently so be unique!
" Params: 1=name of attribute, 2=value of attribute
function! FindBufferByAttr(name, value)
  let l:bufnum = 1

  let l:name = a:name
  " allow brackets in value to be search; need to escape so they are not interpreted
  let l:value = escape(escape(a:value, ']'), '[')

  " loop through all existing buffers to find first buffer with given attribute name/value
  while l:bufnum <= bufnr("$")

    if bufexists(l:bufnum) " dont use buflisted(); need to search ~all~ buffers
      " storage for accurev attributes
      let l:attrs = getbufvar(l:bufnum, "accurev_attributes")
      if match(l:attrs[l:name], l:value, 0) >= 0
        return l:bufnum
      endif
      unlet l:attrs " release variable type; can toggle from Dict to String depending on the buffer
    endif

    let l:bufnum += 1  " try next buffer
  endwhile

  return s:notfound

endfunction "}}}

" Function: GetBufferId {{{3
" Description: Returns current buffer id
" Return: buffer id; -1 if not found
function! s:GetBufferId()
   return bufnr(expand('%'))
endfunction "}}}

" Function: GetWindowId {{{3
" Description: Returns current window id
" Return: window id; -1 if not found
function! s:GetWindowId()
  let l:bufid = s:GetBufferId()
  let l:winnr = bufwinnr(l:bufid)
  return l:winnr
endfunction "}}}

" Function: GetBufferIdByName {{{3
" Description: Returns buffer id for given buffer name
" Return: buffer id; -1 if not found
function! s:GetBufferIdByName(bufname)
   return bufnr(a:bufname)
endfunction "}}}

" Function: tBufferName {{{3
" Description: Returns buffer name for current buffer
" Return: buffer name
function! s:GetBufferName()
   return expand('%')
endfunction "}}}

" Function: DestroyBufferAttributes {{{3
" Description: Removes storage for buffer attributes
" Return: None.
function s:DestroyBufferAttributes()
  unlet b:accurev_attributes
endfunction "}}}

" Function: SetBufferAttribute {{{3
" Description: Sets the given name/value as a buffer variable
" Return: None
" Parameters: name: name of buffer variable excluding 'b:'
"             value: value of the buffer variable unescaped
function s:SetBufferAttribute(name, value)
  " allocate storage if necessary; first time only
  if !exists("b:accurev_attributes")
    let b:accurev_attributes = {}
  endif
  let b:accurev_attributes[a:name] = a:value
endfunction "}}}

" Function: GetBufferAttribute {{{3
" Description: Returns the value for the given buffer variable
" Return: value of buffer variable as String; empty String otherwise
function s:GetBufferAttribute(name)
  return b:accurev_attributes[a:name]
endfunction :}}}

" Function: RemoveBufferAttribute {{{3
" Description: Removes the name/value entry for the given buffer attribute name
function s:RemoveBufferAttribute(name)
  if has_key(b:accurev_attributes, a:name)
    call remove(b:accurev_attributes, a:name)
  endif
endfunction :}}}

" Function: HasBufferAttribute {{{3
" Description: Determine if a given key exists as a buffer attribute
" Return: true if key found; false otherwise
function s:HasBufferAttribute(name)
  return has_key(b:accurev_attributes, a:name)
endfunction :}}}

" Function: SetBufferVariable {{{3
" Description: Sets the given name/value as a buffer variable
" Parameters: 1=name of buffer variable excluding 'b:', 2=value of the buffer variable
function s:SetBufferVariable(name, value)
    exec "let b:" . a:name . " = " . a:value
endfunction "}}}

" Function: GetBufferVariable {{{3
" Description: Returns the value for the given buffer variable
" Parameters: 1=buffer id, 1=name of buffer variable excluding 'b:'
" Return: value of buffer variable as String
function s:GetBufferVariable(buffer_id, name)
  return getbufvar(a:buffer_id, a:name)
endfunction :}}}

" Function: HasBufferVariable {{{3
" Description: Determines if given buffer variable exists
" Parameters: 1=name of buffer variable excluding 'b:'
" Return: true if exists; false otherwise
function s:HasBufferVariable(name)
  return exists("b:" . a:name)
endfunction :}}}

" Function: BufferNotCreated {{{3
" Description: Determines if the given buffer (by id#) is not created yet.
" Returns: true if buffer not created; false otherwise
function! s:BufferNotCreated(bufid)
  return !s:BufferExists(a:bufid)
endfunction "}}}

" Function: ManagedDisplayBuffer {{{3
" Description: Responsible for creating or updating buffers by name with
"              content from given function reference (source of content).
" Parameters: 1=source of method call used for logging
"             2=name of buffer used for buffer lookup
"             3= function to call to obtain display content
"             4=optional arguments to given function as List
" Returns: None.
function! s:ManagedDisplayBuffer(description, bufname, ContentFnRef, ...)

  let l:bufname = a:bufname
  " find existing buffer with given name (may have already been created)
  let l:bufid = FindBufferByAttr('buffer_name', l:bufname)

  " use variable args when calling given content function
  if a:0 > 0
    let l:arglist = a:1
    let l:content_raw = call(a:ContentFnRef, l:arglist)  " content to display
  else
    let l:content_raw = a:ContentFnRef()  " content to display
  endif

  call s:RecordActionFinish(a:description)

  " prepare content
  let l:content_timestamp = s:PrefixWithTimestamp(l:content_raw)
  " create new buffer
  if s:BufferNotCreated(l:bufid)
    call s:CreateDisplayBuffer(l:bufname, l:content_timestamp)
  " update existing buffer with fresh content; do not create a new one
  else
    call s:UpdateDisplayBuffer(l:bufid, l:content_timestamp)
  endif

endfunction "}}}

" Function: ManageSingletonElementBuffer {{{3
" Description: Manages a single, named buffer with given content source based on an
"              element named as the current buffer or embedded in the title of the
"              singleton buffer.
" Parameters: 1=source of method call used for logging
"             2=title of buffer used for buffer lookup
"             3=content reference of function to be called for content
"             4=optional arguments to given function as List
" Return: None.
function! s:ManageSingletonElementBuffer(source, title, ContentFnRef, ...)

  let l:title = a:title
  let l:filename = s:GetFilename()

  " title of history buffer; per filename
  let l:title_with_filename = l:title . " (" . l:filename . ")"

  let l:arglist = [l:filename]

  call s:ManagedDisplayBuffer(a:source, l:title_with_filename, a:ContentFnRef, l:arglist)

endfunction "}}}

" Function: CreateMultiSelectBuffer {{{3
" Description: Creates a temp file buffer used with multi-select content.
" Parameters: 1=buffer name, 2=content to view, 3=model of content
" Return: N/A
function! s:CreateMultiSelectBuffer(name, content_view, content_model)

  let l:parent_buffer_id = s:GetBufferId()
  let l:bufname = a:name . " [Multi-Select]"

  let l:temp_file = tempname()
  let l:workspace_root = s:GetWorkspaceRoot()

  " launch new buffer with name
  exec "silent rightbelow new " . l:temp_file

  mapclear <buffer>

  call s:SetBufferAttribute("workspace_root", l:workspace_root)
  call s:SetBufferAttribute("content_model", a:content_model)
  call s:SetBufferAttribute("saved_position", getpos('.'))
  " save the name; possibly used for parsing during buffer management
  call s:SetBufferAttribute('buffer_name', l:bufname)
  call s:SetBufferAttribute('parent_buffer_id', l:parent_buffer_id)
  call s:SetBufferAttribute('recording_buffer_id', l:parent_buffer_id)

  " event handler for toggling all options
  autocmd CursorMoved <buffer> :call s:ToggleOption() 

  setlocal nobuflisted
  setlocal noswapfile
  setlocal buftype=
  setlocal bufhidden=wipe
  setlocal nolist
  setlocal nonumber
  setlocal foldcolumn=0 nofoldenable
  if has('syntax') | setlocal syntax=accurev | endif
  " fill buffer with content
  0put=a:content_view
  " go to top
  normal gg
  " allow modification
  setlocal noreadonly
  setlocal modifiable

  " always show status line on windows
  setlocal laststatus=2
  setlocal statusline=%<%{b:accurev_attributes['buffer_name']}

endfunction "}}}

" Function: ManagedAnnotateBuffer {{{3
" Description: Creates a managed buffer for annotate content.  A new buffer
"              is created for the first annotate for the given element.  This
"              buffer will be re-used/refreshed on subsequent annotate requests
"              for the same file.  This eliminates annoying buffer/window pollution.
" Parameters: 1=filename used as title, 2=content for buffer
" Return: N/A
function! s:ManagedAnnotateBuffer(filename, content)

  " prefix buffer name to not conflict with original, bona-fide file buffer named with file
  let l:bufname = "[annotate] " . a:filename

  let l:bufid = FindBufferByAttr('buffer_name', l:bufname)

  if s:BufferNotCreated(l:bufid)
    call s:CreateAnnotateBuffer(l:bufname, a:content)
  else
    call s:UpdateDisplayBuffer(l:bufid, a:content)
  endif
endfunction "}}}

" Function: CreateAnnotateBuffer {{{3
" Description: Creates a temp file buffer used with annotate content.
" Parameters: 1=buffer name, 2=buffer title
" Return: N/A
function! s:CreateAnnotateBuffer(bufname, content)

  let l:parent_buffer_id = s:GetBufferId()
  let l:bufname = a:bufname

  let l:curr_position = getpos('.')
  let l:orig_line = l:curr_position[1]
  let l:orig_column = l:curr_position[2]
  let l:temp_file = tempname()
  let l:depot = s:GetDepot()

  setlocal scrollbind
  " launch new buffer with name
  exec "silent vert new " . l:temp_file

  mapclear <buffer>

  call s:SetBufferAttribute('depot', l:depot)

  setlocal nobuflisted
  setlocal noswapfile
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal nolist
  setlocal nowrap
  setlocal nonumber
  setlocal scrollbind
  setlocal foldcolumn=0 nofoldenable
  if has('syntax') | setlocal syntax=accurev | endif
  " fill buffer with content
  0put=a:content

  call setpos('.', [0, l:orig_line, 1, 0])

  " allow modification
  setlocal readonly
  setlocal nomodifiable

  " event handler for toggling all options
  autocmd CursorMoved <buffer> :call s:ToggleAnnotateHighlight()

  " always show status line on windows
  setlocal laststatus=2
  setlocal statusline=%<%{b:accurev_attributes['buffer_name']}

  redraw!

  call s:DisplayMessage("NOTE: <:q> to quit, <k/j> to navigate, <l> to view transaction & comment.")

endfunction "}}}

" Function: CreateDisplayBuffer {{{3
" Description: Launches a named, anonymous buffer filled with given content.
" Return: N/A
function! s:CreateDisplayBuffer(name, content)

  let l:bufname = a:name . " [ReadOnly]"

  " launch new buffer with name
  exec "silent botright new"

  " save the name; possibly used for parsing during buffer management
  call s:SetBufferAttribute('buffer_name', l:bufname)

  " create a 'scratch' buffer that cannot be saved
  setlocal nobuflisted
  setlocal noswapfile
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal nolist
  setlocal nonumber
  setlocal foldcolumn=0 nofoldenable
  if has('syntax') | setlocal syntax=accurev | endif
  " fill buffer with content
  0put=a:content
  " go to top
  normal gg
  " prevent modification
  setlocal readonly
  setlocal nomodifiable

  " always show status line on windows
  setlocal laststatus=2
  setlocal statusline=%<%{b:accurev_attributes['buffer_name']}

endfunction "}}}

" Function: UpdateDisplayBuffer {{{3
" Description: Replace contents of given display buffer with given contents
" Parameters: 1=buffer id, 2=display content
" Return: None.
function! s:UpdateDisplayBuffer(bufid, content_view)
    let l:winnr = bufwinnr(a:bufid)
    exec l:winnr . "wincmd w"

    setlocal modifiable
    setlocal noreadonly
    call s:ReplaceBufferContent(a:content_view)
    setlocal readonly
    setlocal nomodifiable
endfunction "}}}

" Function: UpdateMultiSelectBuffer {{{3
" Description: Replace contents of given display buffer with given contents
" Parameters: 1=buffer id, 2=display content, 3=content model
" Return: None.
function! s:UpdateMultiSelectBuffer(bufid, content_view, content_model)
    let l:winnr = bufwinnr(a:bufid)
    exec l:winnr . "wincmd w"

    " store original model data
    call s:SetBufferAttribute("content_model", a:content_model)

    setlocal modifiable
    call s:ReplaceBufferContent(a:content_view)
    setlocal nomodifiable
endfunction "}}}

" Function: ReplaceBufferContent {{{3
" Description: Replace contents of current buffer with given contents
" Return: None.
function! s:ReplaceBufferContent(content)
  " remove old content
  %d
  " add new content
  0put=a:content
  " go to top
  normal gg
endfunction "}}}

" Function: UpdateElementStatus {{{3
" Description: Updates the status of the current element; used to set the buffer
"              value the the value known by accurev.
" Parameters: 1=source of the call for tracking
function! s:UpdateElementStatus()

  let l:filename = s:GetFilename()
  let l:curr_status = s:GetElementDisplayStatus(l:filename)
  call s:SetBufferAttribute("element_status", l:curr_status)

endfunction "}}}

" Function: UpdateElementStatusAllBuffers {{{3
" Description: Loop through all buffers and update status.  Used when a command
"              in one buffer affects any/all other open buffers (eg. group promote)
function! UpdateElementStatusAllbuffers()

  let l:bufnum = 1
  " loop through all existing buffers to find first buffer with given attribute name/value
  while l:bufnum <= bufnr("$")

    if bufexists(l:bufnum) " dont use buflisted(); need to search ~all~ buffers
      " storage for accurev attributes
      let l:attrs = getbufvar(l:bufnum, "accurev_attributes")

      " buffer must have the attributes hash and be an initialized workspace
      " in order to have it's status line updated (i.e. be a file)
      " also must be a legitimate file in the workspace (i.e. not a temp file)
      if type(l:attrs) == 4 &&
        \ has_key(l:attrs, 'is_initialized') && l:attrs['is_initialized'] == 1 &&
        \ has_key(l:attrs, 'is_workspace') && l:attrs['is_workspace'] == 1 &&
        \ match(l:attrs['element_abspath'], l:attrs['workspace_root']) >= 0

        let l:filename = l:attrs['element_abspath']
        let l:curr_status = s:GetElementDisplayStatus(l:filename)

        " can't call the helper since we need to update the hash of the current buffer in the loop
        let l:attrs['element_status'] = l:curr_status
      endif

      unlet l:attrs " release variable type; can toggle from Dict to String depending on the buffer

    endif

    let l:bufnum += 1  " try next buffer
  endwhile

  return s:notfound

endfunction "}}}

" Function: UpdateElementSize {{{3
" Description: Updates the size of the current element; used to set the buffer
"              value the the value known by accurev.
function! s:UpdateElementSize()
  call s:SetBufferAttribute("element_size", s:GetFileSizeDisplay())
endfunction "}}}

" }}}

" Sub-Section: User Messaging Functions {{{2
function! s:DisplayInfo(msg)
  call s:DisplayWrappedMessage("AccuRev:", a:msg, '')
endfunction

function! s:DisplayInfoNoCR(msg)
  call s:DisplayWrappedMessageNoCR("AccuRev:", a:msg, '')
endfunction

function! s:DisplayWarning(msg)
  call s:DisplayWrappedMessage("** AccuRev Warning:", a:msg, '')
endfunction

function! s:DisplayError(msg)
  call s:DisplayWrappedMessage("** AccuRev Error:", a:msg, '')
endfunction

function! s:DisplayStatus(msg)
  if s:ShowStatusMessages()
    call s:DisplayInfo(a:msg)
  endif
endfunction

function! s:DisplayStatusStart(msg)
  if s:ShowStatusMessages()
    call s:DisplayInfoNoCR(a:msg)
  endif
endfunction

function! s:DisplayStatusFinish(msg)
  if s:ShowStatusMessages()
    call s:DisplayMessageNoCR(a:msg)
  endif
endfunction

function! s:DisplayDebug(msg)

  if s:plugin_debugging == s:true
    let l:msg = "[" . strftime("%H:%M:%S", localtime()) . "]" .
              \ "[" . s:GetBufferName() . "] " .
              \ a:msg
    call s:DisplayWrappedMessage("** AccuRev Debug:", l:msg, '')
  endif
endfunction

function! s:DisplayErrorWithPrompt(msg)
  let l:msg = "** AccuRev Error: " . a:msg . "  Press <Enter> to continue."
  call input(l:msg)
endfunction

function! s:DisplayInfoWithPrompt(msg, suffix)
  let l:msg = "AccuRev: " . a:msg . ". " . a:suffix
  call input(l:msg)
endfunction

function! s:DisplayMessage(msg)
  echo a:msg
endfunction

function! s:DisplayWrappedMessage(prefix, msg, suffix)
  echo a:prefix . " " . a:msg . " " . a:suffix
endfunction

function! s:DisplayMessageNoCR(msg)
  echon a:msg
endfunction

function! s:DisplayWrappedMessageNoCR(prefix, msg, suffix)
  echon a:prefix . " " . a:msg . " " . a:suffix
endfunction

"}}}

" Sub-Section: String Manipulation Functions {{{2

" Function: PrefixWithTimestamp {{{3
" Description: Return new string prefixed with timestamp
function! s:PrefixWithTimestamp(content)
  return strftime('%x %X %z') . "\n\n" . a:content
endfunction "}}}

" Function: IsStringEmpty {{{3
" Description: Determines if the given string is empty
" Return: true is empty; false otherwise
function! s:IsStringEmpty(string)
  return strlen(a:string) == 0
endfunction "}}}

" Function: Chomp {{{3
" Description: Remove trailing EOL from given string.
" Return: String
function! s:Chomp(str)
  let l:stripped = substitute(a:str, "\n$", '', '')
  return l:stripped
endfunction "}}}

" Function: ChompEmptyLines {{{3
" Description: Remove all trailing EOLs from given string.
" Return: String
function! s:ChompEmptyLines(str)
  let l:stripped = substitute(a:str, "\n*$", '', '')
  return l:stripped
endfunction "}}}

" }}}

" Sub-Section: Dictionary Manipulation Functions {{{2

" Function: MaxAttrLength {{{3
" Description: Determine length of longest attribute given hash of attr hashes
" Return: Length of longest string attribute
" Parameters: 1=hash of attr hashes, 2=name of attribute to determine length of
function! s:MaxAttrLength(elements, attr)

  let l:max = 0
  for l:element in keys(a:elements)
    let l:attrs = a:elements[l:element]
    let l:attr = l:attrs[a:attr]
    let l:length = len(l:attr)
    if l:length > l:max
      let l:max = l:length
    endif
  endfor
  return l:max
endfunction "}}}

" Function: MaxKeyLength {{{3
" Description: Determine length of longest key in given hash
" Return: Length of longest key attribute as Number
" Parameters: 1=dictionary with keys to test
function! s:MaxKeyLength(dict)

  let l:max = 0
  for l:key in keys(a:dict)
    let l:length = len(l:key)
    if l:length > l:max
      let l:max = l:length
    endif
  endfor
  return l:max

endfunction "}}}

" }}}

" Sub-Section: XML Parsing Functions {{{2

" Function: ParseStatXml {{{3
" Description: Create a hash data structure from xml representing an AccuRev 'stat' operation.
" Return: Dictionary of hashes containing elements attributes; key=element path, value=hash of attrs
" Parameter: 1=xml from stat operation
function! s:ParseStatXml(xml)
  return s:ParseElementsWithAttrs(a:xml, "element", "location")
endfunction "}}}

" Function: ParseElementsWithAttrs {{{3
" Description: Parse xml of format <element attr1="foo" attr2="bar"/>
"              Ideal for flat xml where each node has attributes only.
" Return: Dictionary of hashes, each hash containing attributes for the associated element.
" Parameters: 1=xml, 2=name of xml element to parse, 3=name of attr to be key in return hash
function! s:ParseElementsWithAttrs(xml, element, key)

  let l:elements = {}
  let l:begin_element_token = "<" . a:element
  let l:end_element_token = "/>"
  let l:element_search_offset = 0

  while s:true
    " search for next element
    let l:pattern = l:begin_element_token . '.\{-\}' . l:end_element_token
    let l:token = matchstr(a:xml, l:pattern, l:element_search_offset)
    " no match; end search
    if l:token == "" | break | endif

    let l:attrs = {}
    " start searching after xml tag name (eg. "<foo^attr=xyz")
    let attr_search_offset = len(l:begin_element_token)

    " tokenize attributes into hash
    while s:true
      let l:pair = matchlist(l:token, '\s\+\(\w\+\)=\"\(.\{-\}\)\"', l:attr_search_offset)
      if empty(l:pair) | break | endif
      let l:name = l:pair[1]
      let l:value = l:pair[2]
      " store attr
      let l:attrs[l:name] = l:value
      " set offset to look for next attr
      let l:attr_search_offset += len(l:pair[0])
    endwhile

    " save search results
    let l:elements[l:attrs[a:key]] = l:attrs
    " next search starts at end of previous search
    let l:element_search_offset += strlen(l:token)
  endwhile

  return l:elements

endfunction "}}}

" Function: GetXmlValue {{{3
" Description: Parse and return the value of a name/value pair for given name.
" Return: value token as String for given name
function! s:GetXmlValue(xml, name)
  " search for ...key="xyz"... and return 'xyz'
  let l:pattern = '^.\{-\}' . a:name . '="\(.\{-\}\)".*$'
  let l:value = substitute(a:xml, l:pattern, '\1', '')
  return l:value
endfunction "}}}

"}}}

" Sub-Section: Action Formatting Functions {{{2

" Function: FormatComment {{{3
" Description: Format user comment for submission to the AccuRev server.
" Parameters: comment as String
" Return: String
function! s:FormatComment(comment)
  " strip comment of EOL
  let l:stripped = s:ChompEmptyLines(a:comment)
  return l:stripped
endfunction "}}}

" Function: CommentAsTempFile {{{3
" Description: Create a temporary file to store the provided comment.  Used
"              to send the comment as a file instead of on the CLI.  Needed
"              for multi-line comments.
" Parameters: comment as String
" Return: filename as String
function! s:CommentAsTempFile(comment)
  " create temporary filename and write given comment as a list to the file
  let l:temp_filename = tempname() 
  let l:line_list = split(a:comment, '\n') " split by EOL
  call writefile(line_list, temp_filename)
  return l:temp_filename
endfunction "}}}

" Function: ElementsAsTempFile {{{3
" Description: Create a temporary file to store the provided list of elements.
"              Used to send the element names as a file instead of on the CLI.
" Parameters: element names as List
" Return: filename as String
function! s:ElementsAsTempFile(elements)
  " create temporary filename and write given comment as a list to the file
  let l:temp_filename = tempname() 
  call writefile(a:elements, temp_filename)
  return l:temp_filename
endfunction "}}}

" Function: ElementAsTempFile {{{3
" Description: Create a temporary file to store contents of given element by id/version.
"              Used for obtaining content for versions of files.
" Parameters: 1=element id, version=version to load
" Return: filename as String
function! s:ElementAsTempFile(eid, version)
  let l:temp_filename = tempname() 
  let l:content = s:DataController_ElementContent(a:eid, a:version)
  let l:content_as_list = split(l:content, "\n")
  call writefile(l:content_as_list, temp_filename)
  return l:temp_filename
endfunction "}}}

" }}}

" }}}

" Section: Debugging / Testing {{{1
" This section is only for development purposes

" Description: Displays popup window with given debug message
function! s:Debug(message)

  let l:message = ""

  " convert array or dictionary to string representation
  if type(a:message) == type([]) || type(a:message) == type({})
    let l:message = string(a:message)
  else
    let l:message = a:message
  endif

  " show message and wait for confirmation to continue
  let l:debug=confirm("[" . l:message . "]")

endfunction

if !hasmapto('<Plug>Test')
  map <Leader>t   <Plug>Test
  noremap <script> <Plug>Test <SID>Test
  noremap <silent> <SID>Test :call <SID>Test()<CR>
endif

function! s:Test()
  echo "TESTING!"
endfunction

" }}}

" Section: Initialization {{{1
"
" Note: Initialization requires an initial bootstrap to offer the user
" Info/Login capability regardless of being in a workspace.  This means
" that ~every~ buffer will contain a very small footprint of the plugin regardless
" of their intention.  However, this supports using a single buffer both
" IN and OUT of the context of AccuRev.  For example, if a user is
" editing $HOME/worklog.txt then :reads $HOME/wspace/foo.c and :saveas $HOME/wspace/foo.c 
" the plugin will be able to initialize properly. My first intentions were to rip out
" the plugin if the environment was detected as non-AccuRev.  In hindsight, this
" was a clean approach, but prevented a scenario where the buffer is re-used.
" I single-handedly voted to support re-use with the side-effect (if you call it that)
" of having a small footprint in every buffer.  The footprint is merely 2 key mappings
" and a single variable (dict) called b:accurev_attributes with a couple of values.
" You can see them using :map, and :let respectively.


" Function: AutoLoadAccuRevPlugin {{{2
" Description: Helper init function to perform bootstrap and login
function! s:AutoLoadAccuRevPlugin()

  " only load plugin for regular file type buffers; see :help buftype
  if &buftype != ""
    call s:DisplayDebug("Aborting Plugin. buftype=[" . &buftype . "]")
    return
  endif

  redraw!

  " set default status to 'not loaded'
  call b:UnsetPluginLoaded()

  " all buffers are bootstrapped with enable/login mappings
  if s:BootStrapPlugin()
    if s:LoadOnStartup()
      call s:LoadPlugin()
    endif
  endif
endfunction " }}}

" Function: BootStrapAccuRevPlugin {{{2
" Description: First time load of minimal plugin elements for any buffer.
" Return: true if bootstrap successful; false otherwise
function! s:BootStrapPlugin()

  call s:DisplayDebug("BootStrapping Plugin...")

  " no accurev, no plugin!
  if s:AccuRevClientExists() == s:false
    call s:DisplayDebug("AccuRev Client Not Found")
    return s:false
  endif

  " caching var used to set and detect an accurev workspace
  call s:SetBufferAttribute('is_workspace', s:false)
  call s:SetBufferAttribute('is_logged_in', s:false)
  call s:SetBufferAttribute('is_initialized', s:false)
  " name of buffer used for buffer re-use and re-loading
  call s:SetBufferAttribute('buffer_name', expand('%'))
  " full dir path of element
  call s:SetBufferAttribute('element_dirname', expand('%:p:h'))
  call s:SetBufferAttribute('element_abspath', expand('%:p'))
  call s:SetBufferAttribute('element_name', expand('%:p:t'))
  " inform which buffer to record actions to; can be overridden for temp buffers
  " to send action logs to the original parent buffer
  call s:SetBufferAttribute('recording_buffer_id', s:GetBufferId())

  " storage for saving executed commands; as List
  " - stored as separate buffer var since this will get large
  " - only create storage if doesn't already exist; occurs on checktime buffer reloads
  if s:RecordCommandHistoryEnabled() && !s:HasBufferVariable('accurev_command_history')
    call s:SetBufferVariable('accurev_command_history', '[]')
  endif

  call s:RecordActionBegin('bootstrap')

  " only load key mappings available at boot time
  call s:LoadBootMappings()

  call s:DisplayDebug("BootStrap Buffer Attributes=[" . string(b:accurev_attributes) . "]")
  call s:DisplayDebug("BootStrap Completed.")
  call s:RecordActionFinish('bootstrap')

  return s:true
endfunction "}}}

" Function: IsInitialized {{{2
" Description: Determines if the plugin is already initialized.
" Return: true if initialized; false otherwise
function! s:IsInitialized()
  return s:GetBufferAttribute("is_initialized")
endfunction " }}}

" Function: Refresh {{{2
" Description: Used during frequent status checking to check if the user session
"              is still active (user logged in).  If user is active, the element status
"              information is updated; otherwise, the plugin is deactivated.  This 
"              is helpful if the users session expires or is logged out externally.
" Return: N/A
function! s:Refresh(source)
  call s:RecordActionBegin('stat refresh: ' . a:source)

  call s:UpdateElementStatus()
  call s:UpdateElementSize()

  let l:curr_element_status = s:GetBufferAttribute('element_status')

  " user has been logged out; unregister plugin
  if match(l:curr_element_status, 'Not authenticated') >= 0
    call s:DisplayWarning("Session expired.  Please login again.")
    call s:LogoutDeactivatePlugin()
  endif

  call s:RecordActionFinish('stat update: ' . a:source)

endfunction "}}}

" Function: LoadWorkspaceInfo {{{2
" Description: Loads workspace info into buffer variable for buffer-global access.
"              Some key names are custom mapped since AccuRev info has some names
"              with spaces and odd characters.  Basic concept is to keep it lowercase
"              with underscores separating multiple words.
" Return: None.
function! s:LoadWorkspaceInfo()

  " all workspace info in dict
  let l:info = s:DataController_Info()

  " provide custom mappings for some key names that are just unusable!
  let l:mapped_names = {"Server name": "server_name",
                     \  "ACCUREV_BIN": "accurev_bin",
                     \  "Client time": "client_time",
                     \  "Server time": "server_time",
                     \  "Workspace/ref": "workspace_ref"}

  " store all keys in buffer
  for l:key in keys(l:info)

    " format key; either use a mapped name or convert to lowercase
    let l:name = ""
    if has_key(l:mapped_names, l:key)
      let l:name = l:mapped_names[l:key]
    else
      let l:name = tolower(l:key)
    endif

    " get value; need to use original key name
    let l:value = l:info[l:key]

    call s:SetBufferAttribute(l:name, l:value)
  endfor

  " store workspace top directory in normalized fashion
  " - helps with comparisons
  if s:HasBufferAttribute('top')
    let l:top = s:GetBufferAttribute('top')
    let l:normalized_top = s:NormalizeFilename(l:top)
    call s:SetBufferAttribute('top', l:normalized_top)
    " alias keys
    call s:SetBufferAttribute('workspace_root', s:GetBufferAttribute('top'))
  endif

endfunction " }}}

" }}}

" Section: Uninitialize {{{1

" Function: LogoutDeactivatePlugin {{{2
" Description: De-register all action GUI/menu mappings except login/info.
" Return: None.
function s:LogoutDeactivatePlugin()

  " deregister all authenticated mappings
  call s:DeactivateAuthMappings()
  call s:DisableGuiMenus()

  " enable basic mappings for (re)loading plugin
  call s:LoadBootMappings()

  " save vars to prime buffer attributes in logout state
  let l:is_workspace = s:GetBufferAttribute('is_workspace')
  let l:buffer_name = s:GetBufferAttribute('buffer_name')
  let l:element_dirname = s:GetBufferAttribute('element_dirname')
  let l:element_abspath = s:GetBufferAttribute('element_abspath')
  let l:element_name = s:GetBufferAttribute('element_name')
  let l:server_name = s:GetBufferAttribute('server_name')

  " remove all existing accurev vars from buffer storage
  call s:DestroyBufferAttributes()

  " TODO: delete cli history ?  or persist in entire vim session?

  " re-create init buffer vars; only keep the basics (those set in bootstrap)
  call s:SetBufferAttribute('is_workspace', l:is_workspace)
  call s:SetBufferAttribute('buffer_name', l:buffer_name)
  call s:SetBufferAttribute('element_dirname', l:element_dirname)
  call s:SetBufferAttribute('element_abspath', l:element_abspath)
  call s:SetBufferAttribute('element_name', l:element_name)
  " cache server name so subsequent login can display name next to prompt
  call s:SetBufferAttribute('server_name', l:server_name)
  call s:SetBufferAttribute('is_logged_in', s:false)
  call s:SetBufferAttribute('is_initialized', s:false)
  call s:SetBufferAttribute('recording_buffer_id', s:GetBufferId())
  if s:RecordCommandHistoryEnabled()
    call s:SetBufferVariable('accurev_command_history', '[]')
  endif

  " remove plugin events by event group
  autocmd! accurev_events

  " reset custom vars to default values
  " xxx moved to separate method
  setlocal laststatus&vim
  setlocal statusline&vim

endfunction "}}}

" }}}

" Initialize plugin for current buffer
autocmd BufReadPost,BufNewFile * :call s:AutoLoadAccuRevPlugin()

" Section: Vim Plugin Post-Load Cleanup {{{1
" Description: Restore environment after script has been loaded.
let &cpo = s:save_cpo
" }}}

finish " you win!
