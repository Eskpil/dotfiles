-- My xmonad config based on dt from distrotube.

import Control.Arrow (first)
import Data.Char (isSpace, toUpper)
import qualified Data.Map as M
import Data.Maybe (isJust)
import Data.Monoid
import Data.Tree
import System.Directory
import System.Exit (exitSuccess)
import System.IO (hPutStrLn)
-- Text
import Text.Printf
import XMonad
import XMonad.Actions.CopyWindow (kill1, killAllOtherCopies)
import XMonad.Actions.CycleWS (WSType (..), moveTo, nextScreen, prevScreen, shiftTo)
-- import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotAllDown, rotSlavesDown)
import qualified XMonad.Actions.Search as S
import qualified XMonad.Actions.TreeSelect as TS
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (killAll, sinkAll)
import XMonad.Hooks.DynamicLog (PP (..), dynamicLogWithPP, shorten, wrap, xmobarColor, xmobarPP)
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks (ToggleStruts (..), avoidStruts, docksEventHook, manageDocks)
import XMonad.Hooks.ManageHelpers (doFullFloat, isFullscreen)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory
import XMonad.Layout.GridVariants (Grid (Grid))
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (decreaseLimit, increaseLimit, limitWindows)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (EOT (EOT), mkToggle, single, (??))
import qualified XMonad.Layout.MultiToggle as MT (Toggle (..))
import XMonad.Layout.MultiToggle.Instances (StdTransformers (MIRROR, NBFULL, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ResizableTile
-- import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spacing
import XMonad.Layout.Spiral
import XMonad.Layout.SubLayouts
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import qualified XMonad.Layout.ToggleLayouts as T (ToggleLayout (Toggle), toggleLayouts)
import XMonad.Layout.WindowArranger (WindowArrangerMsg (..), windowArrange)
import XMonad.Layout.WindowNavigation
import XMonad.Prompt
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.Input
import XMonad.Prompt.Man
import XMonad.Prompt.Pass
import XMonad.Prompt.Shell
import XMonad.Prompt.Ssh
import XMonad.Prompt.XMonad
import qualified XMonad.StackSet as W
-- Utilities
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

myFont :: String
myFont = "xft:Mononoki Nerd Font Mono:regular:size=9:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod4Mask -- Sets modkey to super/windows key

myTerminal :: String
myTerminal = "kitty" -- Sets default terminal

myBrowser :: String
myBrowser = "firefox " -- Sets qutebrowser as browser for tree select
-- myBrowser = myTerminal ++ " -e lynx " -- Sets lynx as browser for tree select

myEditor :: String
myEditor = "code " -- Sets emacs as editor for tree select
-- myEditor = myTerminal ++ " -e vim "    -- Sets vim as editor for tree select

myBorderWidth :: Dimension
myBorderWidth = 2 -- Sets border width for windows

myNormColor :: String
myNormColor = "#46d9ff" -- Border color of normal windows

myFocusColor :: String
myFocusColor = "#e59ed7" -- Border color of focused windows

altMask :: KeyMask
altMask = mod1Mask -- Setting this for use in xprompts

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myStartupHook :: X ()
myStartupHook = do
  spawn "$HOME/.xmonad/autostart.sh"
  setWMName "LG3D"

calcPrompt c ans =
  inputPrompt c (trim ans) ?+ \input ->
    liftIO (runProcessWithInput "qalc" [input] "") >>= calcPrompt c
  where
    trim = f . f
      where
        f = reverse . dropWhile isSpace

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

tall =
  renamed [Replace "tall"] $
    windowNavigation $
      addTabs shrinkText myTabTheme $
        subLayout [] (smartBorders Simplest) $
          limitWindows 12 $
            mySpacing 8 $
              ResizableTall 1 (3 / 100) (1 / 2) []

magnify =
  renamed [Replace "magnify"] $
    windowNavigation $
      addTabs shrinkText myTabTheme $
        subLayout [] (smartBorders Simplest) $
          magnifier $
            limitWindows 12 $
              mySpacing 8 $
                ResizableTall 1 (3 / 100) (1 / 2) []

monocle =
  renamed [Replace "monocle"] $
    windowNavigation $
      addTabs shrinkText myTabTheme $
        subLayout [] (smartBorders Simplest) $
          limitWindows 20 Full

floats =
  renamed [Replace "floats"] $
    windowNavigation $
      addTabs shrinkText myTabTheme $
        subLayout [] (smartBorders Simplest) $
          limitWindows 20 simplestFloat

grid =
  renamed [Replace "grid"] $
    windowNavigation $
      addTabs shrinkText myTabTheme $
        subLayout [] (smartBorders Simplest) $
          limitWindows 12 $
            mySpacing 0 $
              mkToggle (single MIRROR) $
                Grid (16 / 10)

spirals =
  renamed [Replace "spirals"] $
    windowNavigation $
      addTabs shrinkText myTabTheme $
        subLayout [] (smartBorders Simplest) $
          mySpacing' 8 $
            spiral (6 / 7)

threeCol =
  renamed [Replace "threeCol"] $
    windowNavigation $
      addTabs shrinkText myTabTheme $
        subLayout [] (smartBorders Simplest) $
          limitWindows 7 $
            mySpacing' 4 $
              ThreeCol 1 (3 / 100) (1 / 2)

threeRow =
  renamed [Replace "threeRow"] $
    windowNavigation $
      addTabs shrinkText myTabTheme $
        subLayout [] (smartBorders Simplest) $
          limitWindows 7 $
            mySpacing' 4
            -- Mirror takes a layout and rotates it by 90 degrees.
            -- So we are applying Mirror to the ThreeCol layout.
            $
              Mirror $
                ThreeCol 1 (3 / 100) (1 / 2)

tabs =
  renamed [Replace "tabs"] $
    tabbed shrinkText myTabTheme

myTabTheme =
  def
    { fontName = myFont,
      activeColor = "#46d9ff",
      inactiveColor = "#313846",
      activeBorderColor = "#46d9ff",
      inactiveBorderColor = "#282c34",
      activeTextColor = "#282c34",
      inactiveTextColor = "#d0d0d0"
    }

-- The layout hook
myLayoutHook =
  avoidStruts $
    mouseResize $
      windowArrange $
        T.toggleLayouts floats $
          mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
  where
    myDefaultLayout =
      tall
        ||| magnify
        ||| noBorders monocle
        ||| floats
        ||| noBorders tabs
        ||| grid
        ||| spirals
        ||| threeCol
        ||| threeRow

myWorkspaces = [" dev ", " www ", " sys ", " doc ", " vbox ", " chat ", " mus ", " vid ", " gfx "]

xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
    doubleLts '<' = "<<"
    doubleLts x = [x]

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook =
  composeAll
    -- 'doFloat' forces a window to float.  Useful for dialog boxes and such.
    -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
    -- I'm doing it this way because otherwise I would have to write out the full
    -- name of my workspaces and the names would be very long if using clickable workspaces.
    [ className =? "confirm" --> doFloat,
      className =? "file_progress" --> doFloat,
      className =? "dialog" --> doFloat,
      className =? "download" --> doFloat,
      className =? "error" --> doFloat,
      className =? "Gimp" --> doFloat,
      className =? "notification" --> doFloat,
      className =? "pinentry-gtk-2" --> doFloat,
      className =? "splash" --> doFloat,
      className =? "toolbar" --> doFloat,
      title =? "Save File" --> doFloat,
      className =? "Save File" --> doFloat,
      (className =? "Brave" <&&> resource =? "Save File") --> doFullFloat,
      title
        =? "Oracle VM VirtualBox Manager"
        --> doFloat,
      (className =? "firefox" <&&> resource =? "Dialog") --> doFloat, -- Float Firefox Dialog
      isFullscreen --> doFullFloat
    ]

myLogHook :: X ()
myLogHook = fadeInactiveLogHook fadeAmount
  where
    fadeAmount = 1.0

myKeys :: String -> [([Char], X ())]
myKeys home =
  -- Xmonad
  [ ("M-C-r", spawn "xmonad --recompile"), -- Recompiles xmonad
    ("M-S-r", spawn "xmonad --restart"), -- Restarts xmonad
    ("M-S-q", io exitSuccess), -- Quits xmonad

    -- Run Prompt
    ("M-S-<Return>", spawn "rofi -show drun -config ~/.config/rofi/themes/rofi-top.rasi -display-drun \"Run: \" -drun-display-format {name}"),
    ("M-C-<Return>", spawn "rofi -show window -config ~/.config/rofi/themes/rofi-center.rasi"),
    -- Arco
    ("M-S-x", spawn "arcolinux-logout"),
    -- Useful programs to have a keybinding for launch
    ("M-<Return>", spawn (myTerminal ++ " -e fish")),
    ("M-M1-h", spawn (myTerminal ++ " -e htop")),
    -- Kill windows
    ("M-S-c", kill1), -- Kill the currently focused client
    ("M-S-a", killAll), -- Kill all windows on current workspace

    -- Workspaces
    ("M-.", nextScreen), -- Switch focus to next monitor
    ("M-,", prevScreen), -- Switch focus to prev monitor
    ("M-S-<KP_Add>", shiftTo Next nonNSP >> moveTo Next nonNSP), -- Shifts focused window to next ws
    ("M-S-<KP_Subtract>", shiftTo Prev nonNSP >> moveTo Prev nonNSP), -- Shifts focused window to prev ws

    -- Floating windows
    ("M-f", sendMessage (T.Toggle "floats")), -- Toggles my 'floats' layout
    ("M-t", withFocused $ windows . W.sink), -- Push floating window back to tile
    ("M-S-t", sinkAll), -- Push ALL floating windows to tile
    -- Increase/decrease spacing (gaps)
    ("M-d", decWindowSpacing 4), -- Decrease window spacing
    ("M-i", incWindowSpacing 4), -- Increase window spacing
    ("M-S-d", decScreenSpacing 4), -- Decrease screen spacing
    ("M-S-i", incScreenSpacing 4), -- Increase screen spacing

    -- Tree Select
    -- Windows navigation
    ("M-m", windows W.focusMaster), -- Move focus to the master window
    ("M-j", windows W.focusDown), -- Move focus to the next window
    ("M-k", windows W.focusUp), -- Move focus to the prev window
    ("M-S-m", windows W.swapMaster), -- Swap the focused window and the master window
    ("M-S-j", windows W.swapDown), -- Swap focused window with next window
    ("M-S-k", windows W.swapUp), -- Swap focused window with prev window
    ("M-<Backspace>", promote), -- Moves focused window to master, others maintain order
    ("M-S-<Tab>", rotSlavesDown), -- Rotate all windows except master and keep focus in place
    ("M-C-<Tab>", rotAllDown), -- Rotate all the windows in the current stack

    -- Layouts
    ("M-<Tab>", sendMessage NextLayout), -- Switch to next layout
    ("M-C-M1-<Up>", sendMessage Arrange),
    ("M-C-M1-<Down>", sendMessage DeArrange),
    ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts), -- Toggles noborder/full
    ("M-S-<Space>", sendMessage ToggleStruts), -- Toggles struts
    ("M-S-n", sendMessage $ MT.Toggle NOBORDERS), -- Toggles noborder

    -- Increase/decrease windows in the master pane or the stack
    ("M-S-<Up>", sendMessage (IncMasterN 1)), -- Increase number of clients in master pane
    ("M-S-<Down>", sendMessage (IncMasterN (-1))), -- Decrease number of clients in master pane
    ("M-C-<Up>", increaseLimit), -- Increase number of windows
    ("M-C-<Down>", decreaseLimit), -- Decrease number of windows

    -- Window resizing
    ("M-h", sendMessage Shrink), -- Shrink horiz window width
    ("M-l", sendMessage Expand), -- Expand horiz window width
    ("M-M1-j", sendMessage MirrorShrink), -- Shrink vert window width
    ("M-M1-k", sendMessage MirrorExpand), -- Exoand vert window width
    ("M-M1-m", spawn "amixer set Master toggle"),
    ("M-M1-x", spawn "amixer set Master 5%+ unmute"),
    ("M-M1-z", spawn "amixer set Master 5%- unmute")
  ]
  where
    nonNSP = WSIs (return (\ws -> W.tag ws /= "nsp"))
    nonEmptyNonNSP = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "nsp"))

main :: IO ()
main = do
  home <- getHomeDirectory
  -- Launching two instances of xmobar on their monitors.
  xmproc0 <- spawnPipe "xmobar -x 1 $HOME/.config/xmobar/xmobarrc1"
  xmproc1 <- spawnPipe "xmobar -x 2 $HOME/.config/xmobar/xmobarrc0"
  -- the xmonad, ya know...what the WM is named after!
  xmonad $
    ewmh
      def
        { manageHook = (isFullscreen --> doFullFloat) <+> myManageHook <+> manageDocks,
          -- Run xmonad commands from command line with "xmonadctl command". Commands include:
          -- shrink, expand, next-layout, default-layout, restart-wm, xterm, kill, refresh, run,
          -- focus-up, focus-down, swap-up, swap-down, swap-master, sink, quit-wm. You can run
          -- "xmonadctl 0" to generate full list of commands written to ~/.xsession-errors.
          -- To compile xmonadctl: ghc -dynamic xmonadctl.hs
          handleEventHook =
            serverModeEventHookCmd
              <+> serverModeEventHook
              <+> serverModeEventHookF "XMONAD_PRINT" (io . putStrLn)
              <+> docksEventHook,
          modMask = myModMask,
          terminal = myTerminal,
          startupHook = myStartupHook,
          layoutHook = myLayoutHook,
          workspaces = myWorkspaces,
          borderWidth = myBorderWidth,
          normalBorderColor = myNormColor,
          focusedBorderColor = myFocusColor,
          logHook =
            workspaceHistoryHook <+> myLogHook
              <+> dynamicLogWithPP
                xmobarPP
                  { ppOutput = \x -> hPutStrLn xmproc0 x >> hPutStrLn xmproc1 x,
                    ppCurrent = xmobarColor "#b558dd" "" . wrap " ~ " " ~ ", -- Current workspace in xmobar
                    ppVisible = xmobarColor "#e59ed7" "", -- Visible but not current workspace
                    ppHidden = xmobarColor "#71d0e8" "" . wrap " ~ " " - ", -- Hidden workspaces in xmobar
                    ppHiddenNoWindows = xmobarColor "#e59ed7" "", -- Hidden workspaces (no windows)
                    ppTitle = xmobarColor "#71d0e8" "" . shorten 80, -- Title of active window in xmobar
                    ppSep = "<fc=#ffffff> <fn=1>|</fn> </fc>", -- Separators in xmobar
                    ppUrgent = xmobarColor "#C45500" "" . wrap " - " " - ", -- Urgent workspace
                    ppExtras = [windowCount], -- # of windows current workspace
                    ppOrder = \(ws : l : t : ex) -> [ws, l] ++ ex ++ [t]
                  }
        }
      `additionalKeysP` myKeys home
