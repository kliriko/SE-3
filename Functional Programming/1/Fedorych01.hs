{-# OPTIONS_GHC -Wall #-}
module HWP01 where

-- Задача 1 -----------------------------------------
lengthMy :: [Int] -> Int
lengthMy array = go array 0
  where
    go :: [Int] -> Int -> Int
    go arr counter =
      if null arr
        then counter
        else go (tail arr) (counter + 1)

-- Задача 2 -----------------------------------------
listSum :: [Int] -> [Int] -> [Int]
listSum xs ys = go xs ys []
  where
    go :: [Int] -> [Int] -> [Int] -> [Int]
    go list1 list2 acc = 
      if null list1 && null list2
        then reverse acc
        else if null list1
          then go [] (tail list2) (head list2 : acc)
          else if null list2
            then go (tail list1) [] (head list1 : acc)
            else go (tail list1) (tail list2) ((head list1 + head list2) : acc)

-- Задача 3 -----------------------------------------
greatMy :: [Int] -> Int -> Int
greatMy xs v = go xs v 0
  where 
    go :: [Int] -> Int -> Int -> Int
    go list _ counter = 
      if null list
        then counter
        else if head list > v 
          then go (tail list) v (counter + 1)
          else go (tail list) v counter

-- Задача 4 -----------------------------------------
elemMy :: Int -> [Int] -> Bool
elemMy v list = 
  if null list
    then False
    else if head list == v 
      then True 
      else elemMy v (tail list)
                     
-- Задача 5 -----------------------------------------
allMy :: [Bool] -> Bool
allMy list = 
  if null list
    then True
    else if head list == True 
      then allMy (tail list)
      else False