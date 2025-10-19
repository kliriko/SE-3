{-# OPTIONS_GHC -Wall #-}
module Fedorych07 where

import Text.ParserCombinators.Parsec

-- 1 -----------------------------------------
fullBrace :: Parser ()
fullBrace = spaces *> fullb <* eof

fullb :: Parser ()
fullb = option () ball

ball :: Parser ()
ball = try paren <|> try square <|> try curly <|> spacesP
  where
    paren  = do char '('; spaces; fullb; char ')'; spaces; fullb
    square = do char '['; spaces; fullb; char ']'; spaces; fullb
    curly  = do char '{'; spaces; fullb; char '}'; spaces; fullb
    spacesP = spaces >> return ()


balance  :: String -> Bool
balance str = either (const False) (const True) (parse fullBrace "" str)

-- 2 -----------------------------------------
fullRight :: Parser Integer
fullRight = exprR <* eof

exprR :: Parser Integer
exprR = chainr1 termR infixopR

termR :: Parser Integer
termR = parens exprR <|> decimal

infixopR :: Parser (Integer -> Integer -> Integer)
infixopR = (char '+' >> return (+))
       <|> (char '-' >> return (-))
       <|> (char '*' >> return (*))

decimal :: Parser Integer
decimal = read <$> many1 digit

parens :: Parser a -> Parser a
parens p = between (char '(') (char ')') p

anRight :: String  -> Maybe Integer
anRight str = case (parse fullRight "" str) of
                   Left _  ->  Nothing
                   Right v -> Just v

-- 3 -----------------------------------------
fullLeft :: Parser Integer
fullLeft = spaces *> exprL <* eof

exprL :: Parser Integer
exprL = chainl1 termL infixopL

termL :: Parser Integer
termL = (parens (spaces *> exprL) <* spaces) <|> (decimal <* spaces)

infixopL :: Parser (Integer -> Integer -> Integer)
infixopL = (char '+' >> spaces >> return (+))
       <|> (char '-' >> spaces >> return (-))
       <|> (char '*' >> spaces >> return (*))

anLeft :: String  -> Maybe Integer
anLeft str = case (parse fullLeft "" str) of
                     Left _  ->  Nothing
                     Right v -> Just v

-- 4 ----------------------------------------- 
data Bexp = Bvalue Bool | Bvar Char | Not Bexp
          | And Bexp Bexp | Or Bexp Bexp
          deriving (Eq, Show)

fullBe :: Parser Bexp
fullBe = bexp <* eof

bexp :: Parser Bexp
bexp = chainl1 bcon (char '|' >> return Or)

bcon :: Parser Bexp
bcon = chainl1 bdis (char '&' >> return And)

bdis :: Parser Bexp
bdis = parens bexp
   <|> (char '!' >> fmap Not bdis)
   <|> (string "true"  >> return (Bvalue True))
   <|> (string "false" >> return (Bvalue False))
   <|> fmap Bvar letter

anBexp :: String -> Maybe Bexp
anBexp str = case (parse fullBe "" str) of
                Left _   ->  Nothing
                Right ex -> Just ex

-- 5 ----------------------------------------- 
type Name       = String
type Attributes = [(String, String)]
data XML        = Text String | Element Name Attributes [XML] deriving (Eq, Show)

fullXML :: Parser XML
fullXML = spaces *> element <* spaces <* eof

element :: Parser XML
element = do
  char '<'
  nm <- name
  attrs <- many attrib
  char '>'
  content <- many xml
  string "</"
  nm2 <- name
  char '>'
  if nm /= nm2
     then fail "tag mismatch"
     else return (Element nm attrs content)

attrib :: Parser (String, String)
attrib = do
  spaces
  n <- name
  spaces
  char '='
  spaces
  v <- fullValue
  return (n, v)

fullValue :: Parser String
fullValue = between (char '"') (char '"') (many (noneOf "\""))

name :: Parser String
name = do
  first <- letter
  rest <- many (letter <|> digit <|> oneOf ".-")
  return (first:rest)

xml :: Parser XML
xml = try element <|> textNode

textNode :: Parser XML
textNode = Text <$> many1 (noneOf "<>")

anXML :: String -> Maybe XML
anXML str = case (parse fullXML "" str) of
               Left _    -> Nothing
               Right res -> Just res

---------------------------------------------
--- testing data
--------------------------------------------- 
casablanca :: String 
casablanca
  = "<film title=\"Casablanca\">\n  <director>Michael Curtiz</director>\n  <year>1942\
    \</year>\n</film>\n\n\n"

casablancaParsed :: XML 
casablancaParsed
  = Element "film" 
            [("title","Casablanca")] 
            [Text "\n  ",
             Element "director" [] [Text "Michael Curtiz"],
             Text "\n  ",
             Element "year" [] [Text "1942"],
             Text "\n"]


