{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications  #-}

module HaskellWorks.Ci.Assist.IO.Tar
  ( TarGroup(..)
  , createTar
  , extractTar
  ) where

import Control.DeepSeq             (NFData)
import Control.Lens
import Control.Monad.Except
import Control.Monad.IO.Class      (MonadIO, liftIO)
import Data.Generics.Product.Any
import Data.List
import GHC.Generics
import HaskellWorks.Ci.Assist.Show

import qualified Data.Text                         as T
import qualified HaskellWorks.Ci.Assist.IO.Console as CIO
import qualified System.Exit                       as IO
import qualified System.IO                         as IO
import qualified System.Process                    as IO

data TarGroup = TarGroup
  { basePath   :: FilePath
  , entryPaths :: [FilePath]
  } deriving (Show, Eq, Generic, NFData)

createTar :: MonadIO m => FilePath -> [TarGroup] -> ExceptT String m ()
createTar tarFile groups = do
  let args = ["-zcf", tarFile] <> foldMap tarGroupToArgs groups
  process <- liftIO $ IO.spawnProcess "tar" args
  exitCode <- liftIO $ IO.waitForProcess process
  case exitCode of
    IO.ExitSuccess   -> return ()
    IO.ExitFailure n -> throwError ""

extractTar :: MonadIO m => FilePath -> FilePath -> ExceptT String m ()
extractTar tarFile targetPath = do
  process <- liftIO $ IO.spawnProcess "tar" ["-C", targetPath, "-zxf", tarFile]
  exitCode <- liftIO $ IO.waitForProcess process
  case exitCode of
    IO.ExitSuccess   -> return ()
    IO.ExitFailure n -> throwError ""

tarGroupToArgs :: TarGroup -> [String]
tarGroupToArgs tarGroup = ["-C", tarGroup ^. the @"basePath"] <> tarGroup ^. the @"entryPaths"