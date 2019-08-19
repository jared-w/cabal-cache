{-# LANGUAGE TemplateHaskell     #-}

{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE GADTs               #-}
{-# LANGUAGE LambdaCase          #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE PolyKinds           #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators       #-}

module HaskellWorks.CabalCache.Effects.FileSystem
  ( FileSystem(..)
  , runEffFileSystem
  , readFile
  , writeFile
  , createDirectoryIfMissing
  , doesDirectoryExist
  ) where

import Polysemy
import Prelude  hiding (readFile, writeFile)

import qualified Data.ByteString.Lazy as LBS
import qualified System.Directory     as IO

data FileSystem m a where
  ReadFile                  :: FilePath -> FileSystem m LBS.ByteString
  WriteFile                 :: FilePath -> LBS.ByteString -> FileSystem m ()
  CreateDirectoryIfMissing  :: FilePath -> FileSystem m ()
  DoesDirectoryExist        :: FilePath -> FileSystem m Bool

makeSem ''FileSystem

runEffFileSystem :: Member (Embed IO) r
  => Sem (FileSystem ': r) a
  -> Sem r a
runEffFileSystem = interpret $ \case
  ReadFile fp -> embed $ LBS.readFile fp
  WriteFile fp contents -> embed $ LBS.writeFile fp contents
  CreateDirectoryIfMissing fp -> embed $ IO.createDirectoryIfMissing True fp
  DoesDirectoryExist fp -> embed $ IO.doesDirectoryExist fp