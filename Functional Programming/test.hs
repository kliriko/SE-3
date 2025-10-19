import Fedorych07

-- Test functions
testBalance :: [(String, Bool)] -> [Bool]
testBalance cases = [balance str == expected | (str, expected) <- cases]

testAnRight :: [(String, Maybe Integer)] -> [Bool]
testAnRight cases = [anRight str == expected | (str, expected) <- cases]

testAnLeft :: [(String, Maybe Integer)] -> [Bool]
testAnLeft cases = [anLeft str == expected | (str, expected) <- cases]

testAnBexp :: [(String, Maybe Bexp)] -> [Bool]
testAnBexp cases = [anBexp str == expected | (str, expected) <- cases]

-- Placeholder for testAnXML (since casablanca and casablancaParsed are not provided)
testAnXML :: String -> Maybe XML -> Bool
testAnXML str expected = anXML str == expected

-- Test cases
testBalanceCases :: [(String, Bool)]
testBalanceCases =
  [ ("{[[]  ()  ] }   {}", True)
  , ("{[[}]]  ( ) ] }  {}", False)
  ]

testAnRightCases :: [(String, Maybe Integer)]
testAnRightCases =
  [ ("6-(8+56-31)*1", Just (-27))
  , ("23-89-", Nothing)
  ]
  
testAnLeftCases :: [(String, Maybe Integer)]
testAnLeftCases =
  [ ("  12 +  7 * 3  ", Just 57) -- (12 + (7 * 3)) = 12 + 21 = 57
  , ("34 7 +8", Nothing)
  ]

testAnBexpCases :: [(String, Maybe Bexp)]
testAnBexpCases =
  [ ("(x|y)&!z", Just (And (Or (Bvar 'x') (Bvar 'y')) (Not (Bvar 'z'))))
  , ("a|b(true)", Nothing)
  ]

-- Main function to run tests
main :: IO ()
main = do
  putStrLn "Testing balance:"
  print $ testBalance testBalanceCases
  putStrLn "Testing anRight:"
  print $ testAnRight testAnRightCases
  putStrLn "Testing anLeft:"
  print $ testAnLeft testAnLeftCases
  putStrLn "Testing anBexp:"
  print $ testAnBexp testAnBexpCases
  -- Note: anXML test requires casablanca and casablancaParsed, which are not defined
  -- putStrLn "Testing anXML:"
  -- print $ testAnXML casablanca (Just casablancaParsed)