{-# OPTIONS_GHC -Wall #-}
import Fedorych10

-- helper to check and print result
check :: (Eq a, Show a) => String -> a -> a -> IO ()
check name got expected =
  if got == expected
     then putStrLn ("✅ " ++ name)
     else putStrLn ("❌ " ++ name ++ ":\n   got      = " ++ show got ++
                    "\n   expected = " ++ show expected)

main :: IO ()
main = do
  putStrLn "\n=== Expression evaluation ==="
  check "const int" (evExp ([],[],[]) (Const (I 42))) (I 42)
  check "addition"  (evExp ([],[("x",I 3),("y",I 5)],[]) (Op (Var "x") Plus (Var "y"))) (I 8)
  check "bool op"   (evExp ([],[],[]) (Op (Const (B True)) And (Const (B False)))) (B False)

  putStrLn "\n=== Statement evaluation ==="
  let s0 = ([], [("x", I 0)], [])
  let s1 = evStmt s0 (Assign "x" (Const (I 10)))
  check "assign" (getValue s1 "x") (I 10)

  let s2 = evStmt ([], [("x", I 1)], []) (Incr "x")
  check "incr" (getValue s2 "x") (I 2)

  let s3 = evStmt ([], [("x", I 0)], []) (While (Op (Var "x") Lt (Const (I 3))) (Incr "x"))
  check "while loop" (getValue s3 "x") (I 3)

  putStrLn "\n=== Program tests ==="
  check "squareRoot 9" (evProgram squareRoot ["9"]) ["3"]
  check "squareRoot 0" (evProgram squareRoot ["0"]) ["0"]
  check "fibonacci 5"  (evProgram fibonacci ["5"]) ["8"]

  putStrLn "\n=== Type check ==="
  check "squareRoot wf" (iswfProgram squareRoot) True
  check "fibonacci wf"  (iswfProgram fibonacci) True

  putStrLn "\n=== Parsing ==="
  check "parse squareRootS" (fmap show (parseLng squareRootS)) (Just (show squareRoot))
  check "parse fibonacciS"  (fmap show (parseLng fibonacciS))  (Just (show fibonacci))

  putStrLn "\nAll tests done.\n"
