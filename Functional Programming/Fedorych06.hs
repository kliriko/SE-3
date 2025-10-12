{-# OPTIONS_GHC -Wall #-}
module Fedorych06 where

import Data.Char(isUpper)
import Data.List

type Grammar    = [Production]         -- КВ-граматика
type Production = (Char,String)        -- Правило виводу
type Predict    = [(Char,String)]      -- Прогнозуюча таблиця
type Control    = [((Char,Char),Int)]  -- Управляюча таблиця 

-- Задача 1 ------------------------------------
addOne :: String -> Char -> String
addOne st c
  | c `elem` st = st
  | otherwise   = st ++ [c]

addAll :: String -> String -> String
addAll st xs = foldl addOne st xs

addWithout :: String -> String -> String
addWithout st [] = st
addWithout st (x:xs)
  | x == '$'  = addWithout st xs
  | otherwise = addWithout (addOne st x) xs

inter :: String -> String -> String
inter st1 st2 = [c | c <- st2, c `elem` st1]

-- Задача 2 ------------------------------------
tkPredict :: Predict -> Char -> String
tkPredict [] _ = ""
tkPredict ((x, s):xs) n
  | x == n    = s
  | otherwise = tkPredict xs n

upPredict :: Predict -> Char -> String -> Predict
upPredict [] n st = [(n, st)]
upPredict ((x, s):xs) n st
  | x == n = (x, st) : xs              
  | x < n = (x, s) : upPredict xs n st 
  | otherwise = (n, st) : (x, s) : xs      
-- Задача 3 ------------------------------------
step :: Grammar -> Control -> (String, String, Maybe [Int]) -> (String, String, Maybe [Int])
step gr ctl (input, stack, result) =
  case (input, stack, result) of
    (_, _, Nothing) -> (input, stack, Nothing) 
    ([], _, _) -> (input, stack, Nothing)  
    (a:xs, [], _) -> (a:xs, [], Nothing)      
    (a:xs, b:bs, Just rs)
      | b == a && b /= '$' -> (xs, bs, Just rs)  
      | b == '$' && a == '$' -> ("", "", Just rs) 
      | isUpper b -> applyRule a b xs bs rs       
      | otherwise -> (a:xs, b:bs, Nothing)        
  where
    applyRule a b xs bs rs =
      case lookup (b, a) ctl of
        Nothing -> (a:xs, b:bs, Nothing) 
        Just i  -> case lookup i (zip [0..] gr) of
          Nothing -> (a:xs, b:bs, Nothing)
          Just (_, rhs) ->
            let newStack = if rhs == "ε" then bs else reverse rhs ++ bs
            in (a:xs, newStack, Just (rs ++ [i]))


parse :: Grammar -> Control -> String -> Maybe [Int]
parse gr ctl word = loop (word ++ "$", [startSymbol] ++ "$", Just [])
  where
    startSymbol = fst (head gr) 
    loop (inp, st, res)
      | res == Nothing = Nothing
      | inp == "$" && st == "$" = res
      | otherwise = 
          let (inp', st', res') = step gr ctl (inp, st, res)
          in if (inp', st', res') == (inp, st, res) 
             then Nothing
             else loop (inp', st', res')


-- Задача 4 ------------------------------------
first :: Predict -> String -> String
first _ "" = "$"  -- ε
first pFst (x:xs)
  | not (isUpper x) = [x]         
  | otherwise =
      let fA = tkPredict pFst x   
      in if '$' `elem` fA
         then sort $ addAll (addWithout "" fA) (first pFst xs)
         else fA

-- Задача 5 ------------------------------------
buildingControl :: Grammar -> Predict -> Predict -> Control
buildingControl gr pFst pNxt =
  concatMap makeEntries (zip [0..] gr)
  where
    makeEntries (i, (a, rhs)) =
      let f = first pFst rhs
          n = tkPredict pNxt a
          part1 = [((a, c), i) | c <- f, c /= '$']
          part2 = if '$' `elem` f then [((a, c), i) | c <- n] else []
      in part1 ++ part2

-- Задача 6 ------------------------------------
disjoint :: [String] -> Bool
disjoint [] = True
disjoint (x:xs) = all (null . inter x) xs && disjoint xs

fromGrammar :: Grammar -> [(Char, [String])]
fromGrammar gr =
  map (\g -> (fst (head g), map snd g))
  $ groupBy (\a b -> fst a == fst b)
  $ sortOn fst gr

testFst :: Predict -> [String] -> Bool
testFst pFst rls =
  let fsts = map (first pFst) rls
  in disjoint fsts

testFollow :: Predict -> Predict -> (Char, [String]) -> Bool
testFollow pFst pNxt (a, rls) =
  all ok rls
  where
    ok rhs =
      let f = first pFst rhs
          followA = tkPredict pNxt a
      in not ('$' `elem` f && not (null (inter (filter (/= '$') f) followA)))

testingLL1 :: Grammar -> Predict -> Predict -> Bool
testingLL1 gr pFst pNxt =
  let groups = fromGrammar gr
  in all (\(a, rls) -> testFst pFst rls && testFollow pFst pNxt (a, rls)) groups

-- Задача 7 ------------------------------------
extendFst :: Predict -> (Char, String) -> Predict
extendFst pFst (n, "") = upPredict pFst n "$"
extendFst pFst (n, rul) =
  let addFirsts xs p = case xs of
        [] -> upPredict p n "$"
        (y:ys) ->
          let fY = if isUpper y then tkPredict pFst y else [y]
              p' = upPredict p n (filter (/= '$') fY)
          in if isUpper y && '$' `elem` fY
             then addFirsts ys p'
             else p'
  in addFirsts rul pFst

evalFst :: Grammar -> Predict -> Predict
evalFst gr pFst = foldl extendFst pFst gr

fixFst :: Eq a => (a -> a) -> a -> a
fixFst f x =
  let x' = f x
  in if x' == x then x else fixFst f x'

buildFst :: Grammar -> Predict
buildFst gr =
  let nts = nub [n | (n, _) <- gr]
      p0 = [(n, if any (\(m, r) -> m == n && r == "") gr then "$" else "") | n <- nts]
  in fixFst (evalFst gr) p0

-- Задача 8 ------------------------------------
nontermTails :: Grammar -> [(Char, String)]
nontermTails gr = concatMap tailsOne gr
  where
    tailsOne (n, rhs) =
      [ (rhs !! i, drop (i + 1) rhs)
      | i <- [0 .. length rhs - 1]
      , isUpper (rhs !! i)
      ]

extandNxtOne :: Predict -> Char -> Predict -> (Char, String) -> Predict
extandNxtOne pFst n pNxt (y, beta) =
  let fBeta = first pFst beta
      p1 = upPredict pNxt y (addWithout "" fBeta)
  in if '$' `elem` fBeta
     then upPredict p1 y (addAll (tkPredict pNxt n) (addWithout "" fBeta))
     else p1

evalNxt :: [(Char, String)] -> Predict -> Predict -> Predict
evalNxt tails pFst pNxt =
  foldl (\acc (y, beta) -> foldl (\acc' n -> extandNxtOne pFst n acc' (y, beta)) acc [n | (n, _) <- tails]) pNxt tails

buildNxt :: Grammar -> Predict -> Predict
buildNxt gr pFst =
  let nts = nub [n | (n, _) <- gr]
      tails = nontermTails gr
      s0 = head nts
      p0 = (s0, "$") : [(n, "") | n <- tail nts]
      fix f x = let x' = f x in if x' == x then x else fix f x'
  in fix (evalNxt tails pFst) p0

---------------------Тестові дані ---------------------------
gr0, gr1, gr2, gr3, gr4, gr5:: Grammar
--  LL(1)-граматики
gr0 = [('S',"aAS"),('S',"b"), ('A',"a"), ('A',"bSA")]
gr1 = [('S',"TV"),('T',"d"),('T',"(S)"),('V',"+TV"),('V',"-TV"),('V',"")]
gr2 = [('E',"TU"),('U',""),('U',"+TU"),('U',"-TU"),
       ('T',"FV"),('V',""),('V',"*FV"),('V',"%FV"),('V',"/FV"),
       ('F',"d"),('F',"(E)")]
-- не LL(1)-граматики
gr3 = [('S',"aAS"), ('S',"a"),('A',"SbA"),('A',"ba"),('S',"")]
gr4 = [('E',"E+T"),('E',"T"), ('T',"T*F"), ('T',"F"), ('F',"d"),('F',"(E)") ]
gr5 = [('E',"E+T"), ('E',"E-T"),('E',"T"),
       ('T',"T*F"), ('T',"T%F"), ('T',"T/F"), ('T',"F"),
       ('F',"d"),('F',"(E)") ]

-- прогнозуючі таблиці початкових терміналів Fst
pFst0, pFst1, pFst2, pFst3, pFst4, pFst5 :: Predict
pFst0 = [('A',"ab"),('S',"ab")]
pFst1 = [('S',"(d"),('T',"(d"),('V',"$+-")]
pFst2 = [('E',"(d"),('F',"(d"),('T',"(d"),('U',"$+-"),('V',"$%*/")]
pFst3 = [('A',"ab"),('S',"$a")]
pFst4 = [('E',"(d"),('F',"(d"),('T',"(d")]
pFst5 = [('E',"(d"),('F',"(d"),('T',"(d")]

-- прогнозуючі таблиці наступних терміналів Nxt
pNxt0, pNxt1, pNxt2, pNxt3, pNxt4, pNxt5 :: Predict
pNxt0 = [('A',"ab"),('S',"$ab")]
pNxt1 = [('S',"$)"),('T',"$)+-"),('V',"$)")]
pNxt2 = [('E',"$)"),('F',"$%)*+-/"),('T',"$)+-"),('U',"$)"),('V',"$)+-")]
pNxt3 = [('A',"$ab"),('S',"$b")]
pNxt4 = [('E',"$)+"),('F',"$)*+"),('T',"$)*+")]
pNxt5 = [('E',"$)+-"),('F',"$%)*+-/"),('T',"$%)*+-/")]

-- управляючі таблиці 
ctl0, ctl1, ctl2 :: Control
ctl0 = [(('A','a'),2),(('A','b'),3),(('S','a'),0),(('S','b'),1)]
ctl1 = [(('S','('),0),(('S','d'),0),(('T','('),2),(('T','d'),1),
        (('V','$'),5),(('V',')'),5),(('V','+'),3),(('V','-'),4)]
ctl2 = [(('E','('),0),(('E','d'),0),(('F','('),10),(('F','d'),9),
        (('T','('),4),(('T','d'),4),(('U','$'),1),(('U',')'),1),
        (('U','+'),2),(('U','-'),3),(('V','$'),5),(('V','%'),7),
        (('V',')'),5),(('V','*'),6),(('V','+'),5),(('V','-'),5),(('V','/'),8)]