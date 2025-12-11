{-# OPTIONS_GHC -Wall #-}
module Fedorych09 where

--  Пакет parsec може бути закритим (hidden), 
--  щоб відкрити його потрібно завантажити файл з опцією -package parsec
--  ghci xxxx.hs -package parsec // ghc xxxx.hs -package parsec 

import Text.ParserCombinators.Parsec 
import Data.Maybe (fromMaybe)
import Data.List  (nub)

data Recur = Zero | Succ | Sel Int Int 
           | Super Recur [Recur] 
           | Prim Recur Recur 
           | Mini Recur Int 
           | Name String  deriving (Show, Eq)
type System = [(String,Recur)]  

-- Задача 1 ------------------------------------
isNumbConst :: System -> Recur -> Bool 
isNumbConst _ Zero = True
isNumbConst s (Super Succ [f]) = isNumbConst s f        
isNumbConst s (Super Zero []) = True                   
isNumbConst s (Name nm) = case lookup nm s of
    Just f  -> isNumbConst s f
    Nothing -> False
isNumbConst _ _ = False


-- Задача 2 ------------------------------------
evRank :: System -> Recur -> Int 
evRank _ Zero = 1
evRank _ Succ = 1
evRank _ (Sel n _) = n
evRank s (Super _ (a:_)) = evRank s a                  
evRank s (Super _ []) = 0       
evRank s (Prim _ h) = evRank s h - 1
evRank s (Mini g _) = evRank s g - 1
evRank s (Name nm) = case lookup nm s of
    Just f  -> evRank s f
    Nothing -> 0


-- Задача 3 ------------------------------------
usedNames :: Recur -> [String]
usedNames (Name n) = [n]
usedNames (Super r rs) = usedNames r ++ concatMap usedNames rs
usedNames (Prim g h) = usedNames g ++ usedNames h
usedNames (Mini r _) = usedNames r
usedNames _ = []

isNames :: System -> Bool
isNames = go []
 where
  go _ [] = True
  go prev ((n,f):xs)
    | n `elem` prev = False
    | any (`notElem` (prev ++ map fst xs)) (usedNames f) = False
    | otherwise = go (prev ++ [n]) xs

-- Задача 4 ------------------------------------
isRecur :: System -> Recur -> Bool
isRecur _ Zero = True
isRecur _ Succ = True
isRecur _ (Sel n k) = n >= 1 && 1 <= k && k <= n
isRecur s (Super g gs) =
  not (null gs)
  && all (isRecur s) (g:gs)
  && allEqual (map (evRank s) gs)
  && evRank s g == length gs
isRecur s (Prim g h) =
  isRecur s g && isRecur s h &&
  let rg = evRank s g
      rh = evRank s h
  in  (rh > 2 && rg == rh - 2)
      || (rg == 2 && evRank s h == 1 && isNumbConst s h)
isRecur s (Mini g _) = isRecur s g && evRank s g > 1
isRecur s (Name nm)  = maybe False (isRecur s) (lookup nm s)

allEqual :: Eq a => [a] -> Bool
allEqual [] = True
allEqual (x:xs) = all (== x) xs

-- Задача 5 ------------------------------------
eval :: System -> Recur -> [Int] -> Int
eval _ Zero _ = 0
eval _ Succ [x] = x + 1
eval _ (Sel _ k) xs = xs !! (k-1)
eval s (Super g gs) xs =
  let ys = [eval s r xs | r <- gs]
  in  eval s g ys
eval s (Prim g h) xs =
  let n  = length xs
      xn = last xs
      as = take (n-1) xs
      rec 0 = eval s g as
      rec y = eval s h (as ++ [y-1, rec (y-1)])
  in  rec xn
eval s (Mini g t) xs = error "eval: Mini is not total"
eval s (Name nm) xs = eval s (fromMaybe Zero (lookup nm s)) xs
eval _ _ _ = error "bad arguments for eval"

-- Задача 6 ------------------------------------
evalPart :: System -> Recur -> [Int] -> Maybe Int
evalPart s (Mini g t) xs =
  search 0
  where
    search y
      | y > t = Nothing
      | otherwise =
          case evalPart s g (xs ++ [y]) of
            Nothing -> Nothing
            Just 0  -> Just y
            Just _  -> search (y + 1)
evalPart s (Name nm) xs = evalPart s (fromMaybe Zero (lookup nm s)) xs
evalPart s f xs = Just (eval s f xs)

-- Задача 7 ------------------------------------
parseRec :: String -> Maybe System
parseRec str =
  case parse pSystem "" (filter (not . (`elem` " \n\t")) str) of
    Left _  -> Nothing
    Right s -> Just s

pSystem :: Parser System
pSystem = many1 pDef <* eof

pDef :: Parser (String, Recur)
pDef = do
  n <- pIdent
  _ <- char '='
  r <- pRecur
  _ <- char ';'
  return (n, r)

pRecur :: Parser Recur
pRecur = pBase <|> pSuper <|> pPrim <|> pMini

pBase :: Parser Recur
pBase = try (string "a1" >> return Succ)
    <|> try (string "z1" >> return Zero)
    <|> try (do
            _ <- char 's'
            n <- digit
            k <- digit
            return (Sel (read [n]) (read [k])))
    <|> (Name <$> pIdent)

pSuper :: Parser Recur
pSuper = do
  _ <- char '('
  g <- pRecur
  _ <- char ':'
  gs <- pRecur `sepBy1` (char ',')
  _ <- char ')'
  return (Super g gs)

pPrim :: Parser Recur
pPrim = do
  _ <- char '['
  g <- pRecur
  _ <- char ','
  h <- pRecur
  _ <- char ']'
  return (Prim g h)

pMini :: Parser Recur
pMini = do
  _ <- char '{'
  g <- pRecur
  _ <- char ','
  n <- many1 digit
  _ <- char '}'
  return (Mini g (read n))

pIdent :: Parser String
pIdent = do
  c  <- letter
  cs <- many (alphaNum)
  return (c:cs)