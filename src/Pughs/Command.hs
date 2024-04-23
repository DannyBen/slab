{-# LANGUAGE ApplicativeDo #-}

module Pughs.Command where

import Options.Applicative ((<**>))
import Options.Applicative qualified as A

--------------------------------------------------------------------------------
data Command
  = Render FilePath
  | Parse FilePath

--------------------------------------------------------------------------------
parserInfo :: A.ParserInfo Command
parserInfo =
  A.info (parser <**> A.helper) $
    A.fullDesc
      <> A.header "pughs - parses the Pug syntax"
      <> A.progDesc
        "pughs tries to implement the Pug syntax."

--------------------------------------------------------------------------------
parser :: A.Parser Command
parser =
  A.subparser
    ( A.command
        "render"
        ( A.info (parserRender <**> A.helper) $
            A.progDesc
              "Render a Pug template to HTML"
        )
    <>  A.command
        "parse"
        ( A.info (parserParse <**> A.helper) $
            A.progDesc
              "Parse a Pug template to AST"
        )
    )

--------------------------------------------------------------------------------
parserRender :: A.Parser Command
parserRender = do
  path <-
    A.argument
      A.str
      (A.metavar "FILE" <> A.action "file" <> A.help "Pug template to render.")
  pure $ Render path

parserParse :: A.Parser Command
parserParse = do
  path <-
    A.argument
      A.str
      (A.metavar "FILE" <> A.action "file" <> A.help "Pug template to parse.")
  pure $ Parse path
