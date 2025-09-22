{-# OPTIONS_GHC -Wall #-}
module Fedorych03 where
import Data.List (isPrefixOf)

-- Задача 1 -----------------------------------------
sumPower3 :: Integer -> Integer
sumPower3 n = sum (map (3^) [1..n])

-- Задача 2 ---------------------------------------
triangle :: [Integer]
triangle = map (\k -> (k * (k + 1)) `div` 2) [1..]

-- Задача 3 -----------------------------------------
myButLast :: [Int] -> Int
myButLast []       = 0
myButLast [_]      = 0
myButLast [x, _]   = x
myButLast (_:xs)   = myButLast xs

-- Задача 4 -----------------------------------------
all35 :: Int -> [Int]
all35 n = filter (\x -> x `mod` 15 == 0) [1..n-1]

-- Задача 5 -----------------------------------------
phi :: Int -> Int
phi n = length (filter (\x -> gcd x n == 1) [1..n])

-- Задача 6 -----------------------------------------
maxSuf :: [Int] -> Int
maxSuf xs = maximum (scanr1 (+) xs)

-- Задача 7 -----------------------------------------
lastTail :: String -> String
lastTail [] = []
lastTail xs@(_:rest) = max xs (lastTail rest)

-- Задача 8 -----------------------------------------
indexes :: [Int] -> [Int] -> [Int]
indexes xs = go 0
  where
    go _ [] = []
    go i zs
      | xs `isPrefixOf` zs = i : go (i+1) (tail zs)
      | otherwise          = go (i+1) (tail zs)