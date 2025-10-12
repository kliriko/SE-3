-- Test module for LL(1) grammar functions
-- This file contains test cases for all specified functions.
-- Tests are written using simple assertions with print statements for verification.
-- In a real testing framework like HUnit or QuickCheck, these would be formalized.
-- For simplicity, we'll define a test function that checks equality and reports.

import Data.List (sort, sortBy)  -- For sorting to normalize outputs where order might vary
import Fedorych06

-- Assuming the functions are defined in another module, but for completeness, 
-- we'll assume they are available in scope.

-- Helper to normalize Predict and Control by sorting
normPredict :: Predict -> Predict
normPredict = sortBy (\(a,_) (b,_) -> compare a b) . map (\(n,ts) -> (n, sort ts))

normControl :: Control -> Control
normControl = sortBy (\((a,b),_) ((c,d),_) -> compare (a,b) (c,d))

-- Test runner
testEq :: (Eq a, Show a) => String -> a -> a -> IO ()
testEq name expected actual =
  if expected == actual
    then putStrLn $ name ++ ": PASS"
    else putStrLn $ name ++ ": FAIL - Expected: " ++ show expected ++ ", Got: " ++ show actual


-- Tests for buildNxt
testBuildNxt :: IO ()
testBuildNxt = do
  testEq "buildNxt1" (normPredict [('A',"ab"),('S',"$ab")]) (normPredict $ buildNxt gr0 pFst0)
  testEq "buildNxt2" (normPredict [('S',"$)"),('T',"$)+-"),('V',"$)")]) (normPredict $ buildNxt gr1 pFst1)
  -- Additional: empty
  testEq "buildNxt3" [] (buildNxt [] [])
  -- Simple
  testEq "buildNxt4" (normPredict [('S',"$")]) (normPredict $ buildNxt [('S',"a")] [('S',"a")])
  -- With multiple
  testEq "buildNxt5" (normPredict pNxt2) (normPredict $ buildNxt gr2 pFst2)

-- Main to run all tests
main :: IO ()
main = do
  putStrLn "Running tests..."
  testBuildNxt
  putStrLn "Tests completed."