{-# OPTIONS_GHC -Wall #-}
module HWP02 where

-- Задача 1 -----------------------------------------
sumFr :: [Int] -> Int
sumFr xs = foldr (+) 0 xs

-- Задача 2 -----------------------------------------
andFr :: [Bool] -> Bool
andFr xs = foldr (&&) True xs

-- Задача 3 -----------------------------------------
maximumFl :: [Int] ->  Int
maximumFl xs = foldl1 max xs

-- Задача 4 -----------------------------------------
cntGood :: [Int -> Bool] -> Int -> Int 
cntGood xs v = length (filter ($ v) xs)

-- Задача 5 -----------------------------------------
allReverse :: [String] -> [String]
allReverse xss = map reverse (reverse xss)