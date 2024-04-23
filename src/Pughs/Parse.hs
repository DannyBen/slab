module Pughs.Parse where

import Control.Monad (void)
import Data.Text (Text)
import Data.Text qualified as T
import Data.Void (Void)
import Text.Megaparsec hiding (parse)
import Text.Megaparsec.Char
import qualified Text.Megaparsec.Char.Lexer as L

--------------------------------------------------------------------------------
type Parser = Parsec Void Text

data PugNode
  = PugDiv [Attr] [PugNode]
  | PugText Text
  deriving (Show, Eq)

data Attr = AttrList [(Text, Text)] | Class Text
  deriving (Show, Eq)

parsePug :: Text -> Either (ParseErrorBundle Text Void) [PugNode]
parsePug = runParser (many pugElement <* eof) ""

pugElement :: Parser PugNode
pugElement = L.indentBlock scn p
  where
    p = do
      header <- pugDiv
      mcontent <- optional pugText
      case mcontent of
        Nothing ->
          pure (L.IndentMany Nothing (return . header) pugElement)
        Just content ->
          pure $ L.IndentNone $ header [content]

-- E.g. div, div.a, .a
pugDiv :: Parser ([PugNode] -> PugNode)
pugDiv =
  pugDivWithAttrs <|> pugAttrs

-- E.g. div, div.a, div()
pugDivWithAttrs :: Parser ([PugNode] -> PugNode)
pugDivWithAttrs = do
  attrs <- lexeme (string "div" *> many (pugClass <|> pugAttrList)) <?> "div tag"
  pure $ PugDiv attrs

-- E.g. .a, ()
pugAttrs :: Parser ([PugNode] -> PugNode)
pugAttrs = do
  attrs <- lexeme (some (pugClass <|> pugAttrList)) <?> "attributes"
  pure $ PugDiv attrs

-- E.g. .a
pugClass :: Parser Attr
pugClass = Class . T.pack <$>
  (char '.' *> some (alphaNumChar <|> char '-')) <?> "class name"

-- E.g. ()
pugAttrList :: Parser Attr
pugAttrList = (<?> "attribute") $ do
  _ <- string "("
  _ <- string ")"
  pure $ AttrList []

pugText :: Parser PugNode
pugText = PugText . T.pack <$> lexeme (some (noneOf ['\n'])) <?> "text content"

scn :: Parser ()
scn = L.space space1 empty empty

sc :: Parser ()
sc = L.space (void $ some (char ' ' <|> char '\t')) empty empty

lexeme :: Parser a -> Parser a
lexeme = L.lexeme sc
