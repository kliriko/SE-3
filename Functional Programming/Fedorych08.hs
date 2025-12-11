{-# OPTIONS_GHC -Wall #-}
module Fedorych08 where

--  Пакет parsec може бути закритим (hidden), 
--  щоб відкрити його потрібно завантажити файл з опцією -package parsec
--  ghci xxxx.hs -package parsec // ghc xxxx.hs -package parsec 

import qualified Data.List as L
import Data.Maybe
import qualified Text.ParserCombinators.Parsec as P
import Control.Applicative ((<|>), (*>), (<*), (<$>))

data RE = Null   |
          Term Char |
          Seq RE RE |
          Alt RE RE |
          Rep RE    |
          Plus RE   |
          Opt RE
        deriving (Eq, Show)

{- IntSet - множина цілих чисел: впорядкований список без повторень
   DTransition - один елемент таблиці переходів детермінованого автомату
   [DTrasition] - таблиця переходів детермінованого автомату
   NTransition - один елемент таблиці переходів недетермінованого автомату
   [NTrasition] - таблиця переходів недетермінованого автомату
     таблиця переходів ([DTrasition]/[NTrasition])- список впорядкований за зростанням і
        в списку немає двох елементів ((i1,c1),r1) i ((i22,c2),r2) з однаковими входами (i1,c1) == (i2,c2)
   DAutomation і DAutomation - детермінований і недетермінований автомати 
-}
type IntSet = [Int]
type DTransition = ((Int, Char), Int)
type DAutomation = (Int, IntSet, [DTransition])
type NTransition = ((Int, Maybe Char), IntSet)
type NAutomation = (Int, IntSet, [NTransition])

-- Задача 1 -----------------------------------------
simplify :: RE -> RE
simplify Null = Null
simplify (Term c) = Term c
simplify (Seq r1 r2) = Seq (simplify r1) (simplify r2)
simplify (Alt r1 r2) = Alt (simplify r1) (simplify r2)
simplify (Rep r) = Rep (simplify r)
simplify (Plus r) = Seq (simplify r) (Rep (simplify r))
simplify (Opt r) = Alt (simplify r) Null

-- Задача 2 -----------------------------------------
isTerminal :: NAutomation -> Int -> Bool
isTerminal (_, fs, _) s = s `elem` fs

isEssential :: NAutomation -> Int -> Bool
isEssential aut@(is, fs, trx) s = isTerminal aut s || any (\((from, mc), _) -> from == s && isJust mc) trx

-- Задача 3 -----------------------------------------
transitionsFrom :: NAutomation -> Int -> [NTransition]
transitionsFrom (_, _, trx) s = filter (\((from, _), _) -> from == s) trx

-- Задача 4 -----------------------------------------
labels :: [NTransition] -> [Char]
labels trx = L.nub [c | ((_, Just c), _) <- trx]

-- Задача 5 -----------------------------------------
acceptsDA :: DAutomation -> String -> Bool
acceptsDA (is, fs, dtrx) st =
  let step cur c = lookupDT (cur, c) dtrx
      lookupDT _ [] = Nothing
      lookupDT key ((k, v):rest) | key == k = Just v
                                  | otherwise = lookupDT key rest
      finalState = foldM step is st
  in case finalState of
       Just f -> f `elem` fs
       Nothing -> False
  where
    foldM _ s [] = Just s
    foldM f s (x:xs) = case f s x of
                         Just s' -> foldM f s' xs
                         Nothing -> Nothing

-- Задача 6 -----------------------------------------
stStep  :: NAutomation -> Int -> Maybe Char -> [Int]
setStep :: NAutomation -> [Int] -> Maybe Char -> [Int]
closure :: NAutomation -> [Int] -> [Int]

stStep (_, _, trx) s mc = L.sort $ L.nub $ concat [ts | ((from, mc'), ts) <- trx, from == s, mc' == mc]
setStep aut bs mc = L.sort $ L.nub $ concat [stStep aut b mc | b <- bs]
closure aut ss =
  let ss' = L.sort $ L.nub $ ss ++ concat [stStep aut s Nothing | s <- ss]
  in if ss' == ss then ss' else closure aut ss'

-- Задача 7 -----------------------------------------
accepts :: NAutomation -> String -> Bool
accepts aut@(is, fs, _) st =
  let start = closure aut [is]
      steps = foldl (\cur c -> closure aut (setStep aut cur (Just c))) start st
  in any (`elem` fs) steps

-- Задача 8 -----------------------------------------
makeNDA :: RE -> NAutomation
makeNDA re = (1, [2], L.sort transitionsAll)
  where (transitionsAll, _) = make (simplify re) 1 2 3

make :: RE -> Int -> Int -> Int -> ([NTransition], Int)
make Null beg fin nxt = ([((beg, Nothing), [fin])], nxt)
make (Term c) beg fin nxt = ([((beg, Just c), [fin])], nxt)
make (Seq r1 r2) beg fin nxt =
  let end1 = nxt
      start2 = nxt + 1
      nxt' = nxt + 2
      (trx1, nxt1) = make r1 beg end1 nxt'
      (trx2, nxt2) = make r2 start2 fin nxt1
      eps = ((end1, Nothing), [start2])
  in (trx1 ++ trx2 ++ [eps], nxt2)
make (Alt r1 r2) beg fin nxt =
  let start1 = nxt
      end1 = nxt + 1
      start2 = nxt + 2
      end2 = nxt + 3
      nxt' = nxt + 4
      (trx1, nxt1) = make r1 start1 end1 nxt'
      (trx2, nxt2) = make r2 start2 end2 nxt1
      epsBeg1 = ((beg, Nothing), [start1])
      epsBeg2 = ((beg, Nothing), [start2])
      epsEnd1 = ((end1, Nothing), [fin])
      epsEnd2 = ((end2, Nothing), [fin])
  in (trx1 ++ trx2 ++ [epsBeg1, epsBeg2, epsEnd1, epsEnd2], nxt2)
make (Rep r) beg fin nxt =
  let start = nxt
      end = nxt + 1
      nxt' = nxt + 2
      (trx, nxt1) = make r start end nxt'
      epsBeg = ((beg, Nothing), L.sort [start, fin])
      epsEnd = ((end, Nothing), L.sort [start, fin])
  in (trx ++ [epsBeg, epsEnd], nxt1)
make (Plus r) beg fin nxt =
  let start = nxt
      end = nxt + 1
      nxt' = nxt + 2
      (trx, nxt1) = make r start end nxt'
      epsBeg = ((beg, Nothing), [start])
      epsEnd = ((end, Nothing), L.sort [start, fin])
  in (trx ++ [epsBeg, epsEnd], nxt1)
make (Opt r) beg fin nxt =
  let start = nxt
      end = nxt + 1
      nxt' = nxt + 2
      (trx, nxt1) = make r start end nxt'
      epsBeg = ((beg, Nothing), L.sort [start, fin])
      epsEnd = ((end, Nothing), [fin])
  in (trx ++ [epsBeg, epsEnd], nxt1)

-- Задача 9 -----------------------------------------
parseReg :: String -> Maybe RE
parseReg st = case P.parse regParser "" st of
                Left _ -> Nothing
                Right re -> Just re
  where
    regParser = do re <- rexprParser
                   P.eof
                   return re
    rexprParser = P.chainl1 rtermParser altOp
    altOp = P.char '|' >> return Alt
    rtermParser = do facts <- P.many1 rfactParser
                     return $ foldl1 Seq facts
    rfactParser = do p <- primeParser
                     ops <- P.many opParser
                     return $ foldl (\e op -> op e) p ops
    opParser = (P.char '*' >> return Rep)
           <|> (P.char '+' >> return Plus)
           <|> (P.char '?' >> return Opt)
    primeParser = termParser <|> parenParser
    termParser = Term <$> P.satisfy (\c -> c `notElem` "()|*+?")
    parenParser = P.between (P.char '(') (P.char ')') rexprParser

-------------------------------------------------------
-- showRE - Функція може бути корисною при тестуванні
showRE :: RE -> String
showRE (Seq re re') = showRE re ++ showRE re'
showRE (Alt re re') = "(" ++ showRE re ++ "|" ++ showRE re' ++ ")"
showRE (Rep re)     = showRE' re ++ "*"
showRE (Plus re)    = showRE' re ++ "+"
showRE (Opt re)     =  showRE' re ++ "?"
showRE re           = showRE' re

showRE' :: RE -> String
showRE' Null      = ""
showRE' (Term c)  = [c]
showRE' (Alt re re') = showRE (Alt re re')
showRE' re        = "(" ++ showRE re ++ ")"

--------------------------------------------------------
-- Тестові приклади
reFigureS, re1S, re2S, re3S, re4S, re5S, re6S :: String
reFigureS = "(a|b)*c"
re1S = "(x|y)(1|2)"
re2S = "x'*"
re3S = "(ab|c)*"
re4S = "(a?)a"
re5S = "(ab)?d+"
re6S = "c?*"

reFigure, re1, re2, re3, re4, re5, re6 :: RE
reFigure = Seq (Rep (Alt (Term 'a') (Term 'b'))) (Term 'c')
re1 = Seq (Alt (Term 'x') (Term 'y')) (Alt (Term '1') (Term '2'))
re2 = Seq (Term 'x') (Rep (Term '\''))
re3 = Rep (Alt (Seq (Term 'a') (Term 'b')) (Term 'c'))
re4 = Seq (Opt(Term 'a')) (Term 'a')
re5 = Seq (Opt (Seq (Term 'a') (Term 'b'))) (Plus (Term 'd'))
re6 = Rep (Opt (Term 'c'))

ndaFigure, nda1, nda2, nda3, nda4, nda5, nda6, ndaTest :: NAutomation
da1, da3, da4, da5 :: DAutomation
ndaFigure = (1,[2],[((1,Nothing),[3,5]),((3,Nothing),[4]),((4,Just 'c'),[2]),
                    ((5,Nothing),[7,9]),((6,Nothing),[3,5]),((7,Just 'a'),[8]),
                    ((8,Nothing),[6]),((9,Just 'b'),[10]),((10,Nothing),[6])])

nda1 = (1,[2],[((1,Nothing),[5,7]),((3,Nothing),[4]),((4,Nothing),[9,11]),
               ((5,Just 'x'),[6]),((6,Nothing),[3]),((7,Just 'y'),[8]),
               ((8,Nothing),[3]),((9,Just '1'),[10]),((10,Nothing),[2]),
               ((11,Just '2'),[12]),((12,Nothing),[2])])
da1 = (2,[1],[((2,'x'),3),((2,'y'),3),((3,'1'),1),((3,'2'),1)])

nda2 = (1,[2],[((1,Just 'x'),[3]),((3,Nothing),[4]),((4,Nothing),[2,5]),
               ((5,Just '\''),[6]),((6,Nothing),[2,5])])

nda3 = (1,[2],[((1,Nothing),[2,3]),((3,Nothing),[5,7]),((4,Nothing),[2,3]),
               ((5,Just 'a'),[9]),((6,Nothing),[4]),((7,Just 'c'),[8]),
               ((8,Nothing),[4]),((9,Nothing),[10]),((10,Just 'b'),[6])])
da3 = (1,[1],[((1,'a'),2),((1,'c'),1),((2,'b'),1)])

nda4 = (1,[2],[((1,Nothing),[5,7]),((3,Nothing),[4]),((4,Just 'a'),[2]),
               ((5,Just 'a'),[6]),((6,Nothing),[3]),((7,Nothing),[8]),((8,Nothing),[3])])
da4 = (3,[1,2],[((2,'a'),1),((3,'a'),2)])

nda5 = (1,[2],[((1,Nothing),[5,7]),((3,Nothing),[4]),((4,Just 'd'),[11]),
               ((5,Just 'a'),[9]),((6,Nothing),[3]),((7,Nothing),[8]),((8,Nothing),[3]),
               ((9,Nothing),[10]),((10,Just 'b'),[6]),((11,Nothing),[12]),
               ((12,Nothing),[2,13]),((13,Just 'd'),[14]),((14,Nothing),[2,13])])
da5 = (3,[1],[((1,'d'),1),((2,'d'),1),((3,'a'),4),((3,'d'),1),((4,'b'),2)])

nda6 = (1,[2],[((1,Nothing),[2,3]),((3,Nothing),[5,7]),((4,Nothing),[2,3]),
               ((5,Just 'c'),[6]),((6,Nothing),[4]),((7,Nothing),[8]),((8,Nothing),[4])])

ndaTest = (1,[1],[((1,Nothing),[4]),((1,Just 'a'),[2]),((1,Just 'b'),[3]),
                  ((2,Nothing),[3]),((3,Nothing),[5]),((3,Just 'a'),[4]),
                  ((4,Nothing),[1,4]),((5,Nothing),[2,4])])

