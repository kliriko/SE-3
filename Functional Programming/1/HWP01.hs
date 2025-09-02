{-# OPTIONS_GHC -Wall #-}
module HWP01 where

-- Задача 1 -----------------------------------------
counter :: Int
counter = 1

lengthMy :: [Int] -> Int
lengthMy array = if not (null array) then (counter + 1)  else counter

-- якщо масив з 0 або 1 повертаєм відповідно
-- якщо ні, то додаєм до каунтера один і викликаєм цю функцію на tail масива.Applicative


-- Задача 2 -----------------------------------------
listSum :: [Int] -> [Int] -> [Int]
listSum  = undefined

-- Задача 3 -----------------------------------------
greatMy :: [Int] -> Int -> Int
greatMy = undefined
-- Задача 4 -----------------------------------------
elemMy    ::  Int -> [Int] -> Bool
elemMy = undefined
                     
-- Задача 5 -----------------------------------------
allMy :: [Bool] -> Bool
allMy = undefined
