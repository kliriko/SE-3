{-# OPTIONS_GHC -Wall #-}
module Fedorych04 where

type Algorithm    = [Substitution]
type Substitution = (String,String,Bool)
type ConfigA      = (Bool, Int, String)

data Command = Z Int | S Int | T Int Int | J Int Int Int  deriving (Show, Eq)
type Program = [Command]
type ConfigC = (Int, Int, [Int])

-- Задача 1 ------------------------------------
isPrefix :: String -> String -> Bool
isPrefix [] _ = True  
isPrefix _ [] = False 
isPrefix (b:bs) (x:xs) = (b == x) && isPrefix bs xs

-- Задача 2 ------------------------------------
substitute :: Substitution -> Int -> String -> String
substitute (subFrom, subTo, mode) i w
  | mode && null subFrom = prefix ++ subTo ++ suffix -- якщо subFrom порожній, значить ми не заміняємо, а вставляємо
  | take (length subFrom) suffix == subFrom = prefix ++ subTo ++ drop (length subFrom) suffix
  | otherwise = w
  where
    (prefix, suffix) = splitAt i w

-- Задача 3------------------------------------
findPosition :: String -> Substitution -> [(Substitution,Int)]
findPosition w sub@(subFrom, _, mode)
  | mode && null subFrom = [(sub, i) | i <- [0 .. length w]]
  | otherwise = [(sub, i) | i <- [0 .. length w - length subFrom],
                            take (length subFrom) (drop i w) == subFrom]

-- Задача 4 ------------------------------------
findAll :: Algorithm -> String -> [(Substitution,Int)]  
findAll algo w = concatMap (findPosition w) algo

-- Задача 5 ------------------------------------
stepA :: Algorithm -> ConfigA -> ConfigA
stepA algo (bt, st, word)
  | not bt = (bt, st, word)  
  | null apps = (False, st, word) 
  | st >= length apps = (False, st, word) 
  | otherwise =
      let (sub@(_, _, mode), i) = apps !! st
          newWord  = substitute sub i word
      in if mode 
         then (False, st, newWord) 
         else (True, 0, newWord) 
  where
    apps = findAll algo word

-- Задача 6 ------------------------------------
evalA :: Algorithm -> Int -> String -> Maybe String
evalA algo m word = go (True, 0, word) 0
  where
    go (bt, st, w) steps
      | not bt = Just w  
      | steps >= m = Nothing           
      | otherwise = go (stepA algo (bt, st, w)) (steps + 1)

-- Задача 7 ------------------------------------
maximReg :: Program -> Int
maximReg program =
  let allRegs = concatMap regs program
  in maximum allRegs
  where
    regs (Z r)       = [r]
    regs (S r)       = [r]
    regs (T r1 r2)   = [r1, r2]
    regs (J r1 r2 _) = [r1, r2]

-- Задача 8 ------------------------------------
ini :: Program -> [Int] -> [Int]
ini _ ir = ir ++ [0]

upd :: [Int] -> Int -> Int -> [Int]
upd reg r v =
  take r reg ++ [v] ++ drop (r+1) reg

safeGet :: [Int] -> Int -> Int
safeGet reg r 
  | r >= 1 && r <= length reg = reg !! (r-1)
  | otherwise = 0

-- Задача 9 ------------------------------------
stepC :: Program -> ConfigC -> ConfigC
stepC pr (nm, st, rg)
  | st >= length pr = (nm+1, st+1, rg)
  | otherwise =
    case pr !! st of
      Z r     -> (nm+1, st+1, upd rg r 0)
      S r     -> (nm+1, st+1, upd rg r (safeGet rg r + 1))
      T r1 r2 -> (nm+1, st+1, upd rg r2 (safeGet rg r1))
      J r1 r2 x ->
        if safeGet rg r1 == safeGet rg r2 
        then (nm+1, x, rg) 
        else (nm+1, st+1, rg)

-- Zadacha 10 ------------------------------------
evalC :: Program -> Int -> [Int] -> Maybe Int
evalC pr mx ir = go (0, 0, ini pr ir) 0
  where
    go (_, st, rg) steps
      | steps >= mx = Nothing
      | st >= length pr = Just (safeGet rg 1) 
      | otherwise = 
          let (nm', st', rg') = stepC pr (0, st, rg)
          in go (nm', st', rg') (steps + 1)

---------------------Тестові дані - Нормальні алгоритми Маркова ---------------------------
clearBeginOne, addEnd, reverse, multiply:: Algorithm 
-- стирає перший символ вхідного слова (алфавіт {a,b})
clearBeginOne = [ ("ca", "", True)
                , ("cb", "", True)
                , ("", "c", False)
                ] 

-- дописує abb в кінець вхідного слова (алфавіт {a,b})
addEnd = [ ("ca", "ac", False)
         , ("cb", "bc", False)
         , ("c", "abb", True)
         , ("", "c", False)
         ] 
-- зеркальне відображення вхідного слова (алфавіт {a,b})
reverse = [ ("cc", "d", False)
          , ("dc", "d", False)
          , ("da", "ad", False) 
          , ("db", "bd", False) 
          , ("d", "", True) 
          , ("caa", "aca", False) 
          , ("cab", "bca", False) 
          , ("cba", "acb", False)
          , ("cbb", "bcb", False) 
          , ("", "c", False) 
          ]

-- добуток натуральних чисел 
--  multiply ("|||#||") = "||||||"  3*2 = 6
multiply = [("a|", "|ba", False)
            ,("a", "", False)
            ,("b|", "|b", False)
            ,("|#", "#a", False)
            ,("#", "c", False)
            ,("c|", "c", False)
            ,("cb", "|c", False)
            ,("c", "", True)
            ]

---------------------Тестові дані - Програми МНР ---------------------------
notSignum, addition, subtraction :: Program 
-- функція notSignum x
notSignum = [Z 2, J 1 2 5, Z 1, J 1 1 6, S 1] 

-- функція додавання  addition x y = x+y
addition = [Z 3, J 3 2 6, S 1, S 3, J 1 1 2]

-- функція віднімання subtraction x y = x-y, визначена для x>=y 
subtraction = [Z 3, J 1 2 6, S 2, S 3, J 1 1 2, T 3 1]