{-# OPTIONS_GHC -Wall #-}
{-# OPTIONS_GHC -Wno-unused-matches #-}
module Fedorych05 where

import Data.List (nub, partition, isPrefixOf)
import Data.Char (isUpper)

type Grammar = [Production]
type Production = (Char,String)
-- Граматика - список продукцій.
--   нетермінал першої - початковий

-- Лівосторонній вивід - послідовність слів  [String] з іншого боку
--     послідовність номерів правил, які при цьому застосовувались [Int]
type DerivationS = [String] 
type DerivationR = [Int] 

-- Задача 1 -----------------------------------------
isGrammar :: Grammar -> Bool
isGrammar [] = False
isGrammar prods =
    let nts = nub $ map fst prods
        rhs = concatMap snd prods
    in 'S' `elem` nts &&
       all (`elem` ['A'..'Z']) (map fst prods) &&
       all (\c -> c `elem` ['a'..'z'] ++ ['A'..'Z'] ++ ['0'..'9']) rhs &&
       all (\c -> not (c `elem` ['A'..'Z']) || c `elem` nts) rhs

-- Задача 2.a ---------------------------------------
allTerm :: Grammar -> String
allTerm gr = 
    let rhs = concatMap snd gr
        isLower c = c >= 'a' && c <= 'z'
        isDigit c = c >= '0' && c <= '9'
        terms = [c | c <- rhs, isLower c || isDigit c]
        nub xs = foldr (\x acc -> if x `elem` acc then acc else x:acc) [] xs
    in nub terms

-- Задача 2.b ---------------------------------------
allNotT :: Grammar -> String
allNotT gr = 
    let nts = map fst gr
        nub xs = foldr (\x acc -> if x `elem` acc then acc else x:acc) [] xs
    in nub nts

-- Задача 2.c ---------------------------------------
newMinN :: Grammar -> Char
newMinN gr = 
    let nts = map fst gr
        allNTs = ['A'..'Z']
        nub xs = foldr (\x acc -> if x `elem` acc then acc else x:acc) [] xs
    in head [c | c <- allNTs, c `notElem` nub nts]

-- Задача 3.a -----------------------------------------
buildGen :: Grammar -> String
buildGen gr =
  let term c = c `elem` ['a'..'z'] ++ ['0'..'9']
      step gs = nub [ nt | (nt,rhs) <- gr, all (\c -> term c || c `elem` gs) rhs ]
      fix xs = let ys = step xs in if ys == xs then xs else fix ys
  in fix []

-- Задача 3.b -----------------------------------------
buildAcc :: Grammar -> String
buildAcc gr = 
    let initialAcc = ['S']
        step accs = nub $ accs ++ [c | (nt, rhs) <- gr, nt `elem` accs, c <- rhs, c >= 'A' && c <= 'Z']
        nub xs = foldr (\x acc -> if x `elem` acc then acc else x:acc) [] xs
        fixedPoint xs = let ys = step xs in if ys == xs then xs else fixedPoint ys
    in fixedPoint initialAcc

-- Задача 3.c -----------------------------------------
reduce :: Grammar -> Grammar
reduce gr = 
    let gens = buildGen gr
        accs = buildAcc gr
        isLower c = c >= 'a' && c <= 'z'
        isDigit c = c >= '0' && c <= '9'
        validRHS rhs = all (\c -> isLower c || isDigit c || c `elem` accs) rhs
    in if 'S' `notElem` gens then [] else [(nt, rhs) | (nt, rhs) <- gr, nt `elem` accs, nt `elem` gens, validRHS rhs]

-- Задача 4.a -----------------------------------------
findLeftR :: Grammar -> String
findLeftR gr = nub [ a | (a,rhs) <- gr, not (null rhs), head rhs == a ]

-- Задача 4.b -----------------------------------------
deleteLeftR :: Grammar -> Char -> Grammar
deleteLeftR gr n = 
    let (rec, nonRec) = partition (\(_, rhs) -> not (null rhs) && head rhs == n) 
                                  [(nt, rhs) | (nt, rhs) <- gr, nt == n]
        other = [(nt, rhs) | (nt, rhs) <- gr, nt /= n]
    in if null rec then gr
       else let newNT = head [c | c <- ['A'..'Z'], c /= n, notElem c (map fst gr)]
            in other ++ [(n, rhs ++ [newNT]) | (_, rhs) <- nonRec]
                     ++ [(newNT, tail rhs ++ [newNT]) | (_, rhs) <- rec]
                     ++ [(newNT, "")]
          
newNonTerminal :: Grammar -> Char -> Char
newNonTerminal gr c =
  head $ filter (`notElem` map fst gr) $ iterate succ c

-- Задача 5.a -----------------------------------------
isFact :: Grammar -> Char -> Bool
isFact gr n = 
    let rules = [rhs | (nt, rhs) <- gr, nt == n, not (null rhs)]
        prefixes = [take i r | r <- rules, i <- [1..length r]]
    in any (\p -> length (filter (p `isPrefixOf`) rules) > 1) prefixes

-- Задача 5.b -----------------------------------------
deleteFact :: Char -> String -> Grammar -> Grammar
deleteFact n p gr =
    let rulesForN = [(nt, rhs) | (nt, rhs) <- gr, nt == n]
        other = [(nt, rhs) | (nt, rhs) <- gr, nt /= n]
        withPrefix = [drop (length p) rhs | (_, rhs) <- rulesForN, p `isPrefixOf` rhs]
        withoutPrefix = [(n, rhs) | (_, rhs) <- rulesForN, not (p `isPrefixOf` rhs)]
    in if null withPrefix then gr
       else let newNT = head [c | c <- ['A'..'Z'], c /= n, notElem c (map fst gr)]
            in other ++ withoutPrefix ++ [(n, p ++ [newNT])]
                     ++ [(newNT, suffix) | suffix <- withPrefix]

-- Задача 6.a -----------------------------------------
isLeftDerivationS :: Grammar -> DerivationS -> Bool
isLeftDerivationS _ [] = False
isLeftDerivationS _ [_] = True
isLeftDerivationS gr (s1:s2:ss) = 
    let (p, rest) = span (not . isUpper) s1
        (nt:suf) = rest
    in any (\r -> s2 == p ++ r ++ suf) [r | (c, r) <- gr, c == nt] 
       && isLeftDerivationS gr (s2:ss)

-- Задача 6.b -----------------------------------------
isLeftDerivationR :: Grammar -> DerivationR -> Bool
isLeftDerivationR gr rs = isLeftDerivationS gr $ foldl step [[fst (head gr)]] rs
  where
    step ds i = 
        let (p, rest) = span (not . isUpper) (last ds)
            (nt:suf) = rest
            rules = [r | (c, r) <- gr, c == nt]
        in if i >= 0 && i < length rules
           then ds ++ [p ++ (rules !! i) ++ suf]
           else ds

-- Задача 7 -----------------------------------------
fromLeftR :: Grammar -> DerivationR -> DerivationS
fromLeftR gr rs = foldl step [[fst (head gr)]] rs
  where
    step ds i = 
        let (p, rest) = span (not . isUpper) (last ds)
            (nt:suf) = rest
        in if i >= 0 && i < length gr && fst (gr !! i) == nt
           then ds ++ [p ++ snd (gr !! i) ++ suf]
           else ds

-------------------------------------------------------- 
gr0, gr1, gr1e, gr2 :: Grammar   
gr0 = [('S',"aAS"), ('S',"a"),('A',"SbA"),('A',"ba")]
gr1 = [ ('S',"aSa"), ('S',"bSd"), ('S',"c"), ('S',"aSb"), ('D',"aC") 
      , ('A',"cBd"), ('A',"aAd"),('B',"dAf"),('C',"cS"), ('C',"a")]
gr1e = [('S',"aAS"), ('S',"a"),('a',"SbA"),('A',"ba"),('S',"")]
gr2 = [('E',"E+T"),('E',"T"), ('T',"T*F"), ('T',"F"), ('F',"d"),('F',"(E)") ]   

gr0S, gr0Se :: [String]
gr0S = ["S", "aAS", "aSbAS", "aabAS", "aabbaS", "aabbaa"]
gr0Se = ["S", "aAS", "aSbAS", "aabAS", "aabbaS", "aabba"]

gr0R :: DerivationR
gr0R = [0, 2, 1, 3, 1]