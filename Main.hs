{-# LANGUAGE MonoLocalBinds, TypeApplications #-}

import Data.Text (Text)
import qualified Data.Text as Text
import Data.Fixed (Centi)
import Control.Concurrent (threadDelay, forkIO)
import System.Random (randomRIO)
import Text.Read (readMaybe)
import Control.Monad (unless)

import qualified GI.Gtk as Gtk
import qualified GI.Gio as Gio
import qualified GI.GLib as GLib

main :: IO ()
main = do
  Just app <- Gtk.applicationNew (Just appId) []
  _ <- Gio.onApplicationActivate app (appActivate app)
  _ <- Gio.applicationRun app Nothing
  return ()

appId :: Text
appId = Text.pack "io.serokell.gui-haskell-app"

appActivate :: Gtk.Application -> IO ()
appActivate app = do
  window <- Gtk.applicationWindowNew app
  Gtk.setWindowTitle window (Text.pack "GUI Haskell App")
  Gtk.setWindowResizable window False
  Gtk.setWindowDefaultWidth window 300
  vbox <- Gtk.boxNew Gtk.OrientationVertical 10
  Gtk.setWidgetMargin vbox 10
  Gtk.containerAdd window vbox
  Gtk.widgetShow vbox
  entryC <- addEntry (Text.pack "°C") vbox
  entryF <- addEntry (Text.pack "°F") vbox
  setEntryRelation entryC c_to_f entryF
  setEntryRelation entryF f_to_c entryC
  button <- Gtk.buttonNew
  Gtk.setButtonLabel button (Text.pack "Get Weather")
  Gtk.setWidgetHalign button Gtk.AlignCenter
  Gtk.containerAdd vbox button
  _ <- Gtk.onButtonClicked button $
    do Gtk.widgetSetSensitive button False
       _ <- forkIO $ do
         c <- getWeather
         _ <- GLib.idleAdd GLib.PRIORITY_HIGH_IDLE $ do
           _ <- Gtk.entrySetText entryC (renderDouble c)
           Gtk.widgetSetSensitive button True
           return False
         return ()
       return ()
  Gtk.widgetShow button
  Gtk.widgetShow window

setEntryRelation :: Gtk.Entry -> (Double -> Double) -> Gtk.Entry -> IO ()
setEntryRelation entrySource conv entryTarget = do
  _ <- Gtk.onEditableChanged entrySource $
    do target_focused <- Gtk.widgetHasFocus entryTarget
       unless target_focused $ do
         s <- Gtk.entryGetText entrySource
         case parseDouble s of
           Nothing -> return ()
           Just v ->
             let s' = renderDouble (conv v)
             in Gtk.entrySetText entryTarget s'
  return ()

addEntry :: Gtk.IsContainer a => Text -> a -> IO Gtk.Entry
addEntry labelStr container = do
  hbox <- Gtk.boxNew Gtk.OrientationHorizontal 5
  entry <- Gtk.entryNew
  Gtk.setWidgetExpand entry True
  Gtk.setEntryXalign entry 1
  label <- Gtk.labelNew (Just labelStr)
  Gtk.containerAdd hbox entry
  Gtk.containerAdd hbox label
  Gtk.containerAdd container hbox
  Gtk.widgetShow entry
  Gtk.widgetShow label
  Gtk.widgetShow hbox
  return entry

c_to_f, f_to_c :: Double -> Double
c_to_f = (+32) . (*1.8)
f_to_c = (/1.8) . subtract 32

parseDouble :: Text -> Maybe Double
parseDouble = readMaybe . Text.unpack

renderDouble :: Double -> Text
renderDouble = Text.pack . show @Centi . realToFrac

getWeather :: IO Double
getWeather = do
  threadDelay (3 * 1000000)
  randomRIO (-30, 30)
