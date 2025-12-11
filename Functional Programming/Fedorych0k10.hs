{-# OPTIONS_GHC -Wall #-}
module Fedorych0k10 where

import Text.ParserCombinators.Parsec
import Data.Char(isDigit)
import Data.Maybe (fromJust)
import Data.List (nub)

data Value = I Int  | B Bool deriving (Show, Eq)
data Exp = Var String      -- Змінна
         | Const Value     -- константа
         | Op Exp Bop Exp  -- Операція
                 deriving (Show, Eq)
-- Бінарні (2-аргумента) оператори
data Bop =  Plus | Minus | Times | Div   
          | Gt | Ge | Lt | Le| Eql | And | Or
            deriving (Show, Eq)

data Stmt = Assign String Exp
          | Read String 
          | Write Exp
          | Incr String
          | If Exp Stmt 
          | While Exp Stmt       
          | For Stmt Exp Stmt Stmt
          | Block [(String,Type)] [Stmt]        
          deriving (Show, Eq)
data Type = It | Bt deriving (Show, Eq)
type Program = Stmt

type StateW = ([String], [(String,Value)], [String])

type VarEnv  = [(String,Type)]

-- Задача 1 -----------------------------------------
getValue::  StateW -> String -> Value
getValue (_, mem, _) id = fromJust (lookup id mem)

updValue :: StateW -> String -> Value -> StateW
updValue (inp, [], out) _ _ = (inp, [], out)
updValue (inp, (k, val):xs, out) id v
  | k == id   = (inp, (k, v):xs, out)
  | otherwise = case updValue (inp, xs, out) id v of
                  (_, mem', _) -> (inp, (k, val):mem', out)

-- Задача 2 ----------------------------------------- 
readValue :: StateW -> Type -> (StateW,Value)
readValue st@([], _, _) It = (st, I 0)
readValue st@([], _, _) Bt = (st, B False)
readValue st@(x:xs, mem, out) It =
    case reads x of
        [(val, "")] -> ( (xs, mem, out), I val )
        _           -> ( st, I 0 )
readValue st@(x:xs, mem, out) Bt =
    case x of
        "True"  -> ( (xs, mem, out), B True )
        "False" -> ( (xs, mem, out), B False )
        _       -> ( st, B False )

-- Задача 3 -----------------------------------------
writeValue :: StateW -> Value -> StateW 
writeValue (inp, mem, out) v = (inp, mem, out ++ [valToString v])
    where
        valToString (I i) = show i
        valToString (B b) = show b
  
-- Задача 4 ----------------------------------------- 
applyOp :: Bop -> Value -> Value -> Value
applyOp Plus  (I i1) (I i2) = I (i1 + i2)
applyOp Minus (I i1) (I i2) = I (i1 - i2)
applyOp Times (I i1) (I i2) = I (i1 * i2)
applyOp Div   (I i1) (I i2) = I (i1 `div` i2)
applyOp Gt    (I i1) (I i2) = B (i1 > i2)
applyOp Ge    (I i1) (I i2) = B (i1 >= i2)
applyOp Lt    (I i1) (I i2) = B (i1 < i2)
applyOp Le    (I i1) (I i2) = B (i1 <= i2)
applyOp Eql   (I i1) (I i2) = B (i1 == i2)
applyOp And   (B b1) (B b2) = B (b1 && b2)
applyOp Or    (B b1) (B b2) = B (b1 || b2)

evExp :: StateW -> Exp -> Value
evExp st (Const v)     = v
evExp st (Var id)      = getValue st id
evExp st (Op e1 bop e2) = applyOp bop (evExp st e1) (evExp st e2)

-- Задача 5 -----------------------------------------
evStmt :: StateW -> Stmt -> StateW 
evStmt st (Assign id e) = updValue st id (evExp st e)
evStmt st (Read id) =
    let currentVal = getValue st id
        t = case currentVal of (I _) -> It; (B _) -> Bt
        (st', newVal) = readValue st t
    in updValue st' id newVal
evStmt st (Write e) = writeValue st (evExp st e)
evStmt st (Incr id) =
    case getValue st id of
        (I i) -> updValue st id (I (i + 1))
        _     -> st
evStmt st (If e s) =
    case evExp st e of
        (B True)  -> evStmt st s
        _ -> st
evStmt st (While e s) = loop st
    where 
        loop st' = case evExp st' e of
                       (B True)  -> loop (evStmt st' s)
                       _ -> st'
evStmt st (For si e sn s) = loop (evStmt st si)
    where
        loop st' = case evExp st' e of
                       (B True)  -> loop (evStmt (evStmt st' s) sn)
                       _ -> st'
evStmt (inp, mem, out) (Block decls stmts) =
    let newVars = map (\(id, t) -> (id, if t == It then I 0 else B False)) decls
        st_inner = (inp, newVars ++ mem, out)
        (inp_final, mem_final, out_final) = foldl evStmt st_inner stmts
        mem_restored = drop (length decls) mem_final
    in (inp_final, mem_restored, out_final)

evProgram :: Program -> [String] -> [String]
evProgram stmt ix = finalOut
    where (_, _, finalOut) = evStmt (ix, [], []) stmt

---- Перевірка контекстних умов -----------------------
-- Задача 6 -----------------------------------------
iswfOp :: Bop -> [Type] -> Maybe Type 
iswfOp Plus  [It, It] = Just It
iswfOp Minus [It, It] = Just It
iswfOp Times [It, It] = Just It
iswfOp Div   [It, It] = Just It
iswfOp Gt    [It, It] = Just Bt
iswfOp Ge    [It, It] = Just Bt
iswfOp Lt    [It, It] = Just Bt
iswfOp Le    [It, It] = Just Bt
iswfOp Eql   [It, It] = Just Bt
iswfOp And   [Bt, Bt] = Just Bt
iswfOp Or    [Bt, Bt] = Just Bt
iswfOp _ _            = Nothing

iswfExp :: Exp -> VarEnv -> Maybe Type 
iswfExp (Const (I _)) _ = Just It
iswfExp (Const (B _)) _ = Just Bt
iswfExp (Var id) ve = lookup id ve
iswfExp (Op e1 bop e2) ve =
    case (iswfExp e1 ve, iswfExp e2 ve) of
        (Just t1, Just t2) -> iswfOp bop [t1, t2]
        _                  -> Nothing

-- Задача 7 -----------------------------------------
iswfStmt :: Stmt -> VarEnv -> Bool 
iswfStmt (Assign id e) ve =
    case (lookup id ve, iswfExp e ve) of
        (Just t1, Just t2) -> t1 == t2
        _                  -> False
iswfStmt (Read id) ve =
    case lookup id ve of
        Just _ -> True
        _      -> False
iswfStmt (Write e) ve =
    case iswfExp e ve of
        Just _ -> True
        _      -> False
iswfStmt (Incr id) ve =
    case lookup id ve of
        Just It -> True
        _       -> False
iswfStmt (If e s) ve =
    case iswfExp e ve of
        Just Bt -> iswfStmt s ve
        _       -> False
iswfStmt (While e s) ve =
    case iswfExp e ve of
        Just Bt -> iswfStmt s ve
        _       -> False
iswfStmt (For si e sn s) ve =
    case iswfExp e ve of
        Just Bt -> iswfStmt si ve && iswfStmt sn ve && iswfStmt s ve
        _       -> False
iswfStmt (Block decls stmts) ve =
    let newIds = map fst decls
        hasDups = length newIds /= length (nub newIds)
        ve' = decls ++ ve
    in not hasDups && all (\s -> iswfStmt s ve') stmts

iswfProgram :: Program -> Bool 
iswfProgram st = iswfStmt st []


---- Синтаксичний аналіз -------
-- Задача 8 -----------------------------------------
iden :: Parser String
iden = try( do {nm <- identif;
                if (any(nm==) ["int","bool","read","write","if","while","for","true","false"])
                    then unexpected ("reserved word " ++ show nm)
                    else return nm 
               } ) 

--розпізнавати ВСІ порожні символи в кінці
lexem :: Parser a -> Parser a
lexem p = do {a <- p; spaces; return a}

keyword :: String -> Parser ()
keyword st = try( lexem( string st >> notFollowedBy alphaNum)) 

-- identif :: Parser String 
-- identif = lexem (do { c <- letter; cs <- many alphaNum; return (c:cs) })

parseLng :: String -> Maybe Program 
parseLng s = case parse program "" s of
                Left _  -> Nothing
                Right p -> Just p

oper  :: String -> Bop -> Parser Bop
oper str bop = do {_ <- string str; return bop}

mulOp :: Parser Bop   
mulOp = (oper "*" Times) <|> (oper "/" Div)

disOp :: Parser Bop   
disOp = (oper "&" And)

conOp :: Parser Bop   
conOp = (oper "|" Or)

--   :type Op -----> Exp -> Bop -> Exp -> Exp 
--   :type flip Op -------> Bop -> Exp -> Exp -> Exp         
expOp :: Parser Bop -> Parser (Exp -> Exp -> Exp)
expOp p = do {x <- lexem p; return (flip Op x)}

symbol :: Char ->  Parser ()
symbol ch = lexem (char ch >> return ())


typev :: Parser Type 
typev = do {keyword "int"; return It}
        <|> do {keyword "bool"; return Bt} 


-- Задача 6.a -----------------------------------------
identif :: Parser String
identif = lexem (do { c <- letter; cs <- many alphaNum; return (c:cs) })

number :: Parser Int
number  = lexem (fmap read (many1 digit)) <?> "number"
 
addOp :: Parser Bop  
addOp = (lexem (string "+") >> return Plus) <|> (lexem (string "-") >> return Minus)

relOp :: Parser Bop  
relOp = try (lexem (string "<=") >> return Le)
    <|> try (lexem (string ">=") >> return Ge)
    <|> try (lexem (string "==") >> return Eql)
    <|> try (lexem (string "<") >> return Lt)
    <|> try (lexem (string ">") >> return Gt)

-------------------------------------------------------
factor :: Parser Exp
factor = do { symbol '('; x <- expr; symbol ')'; return x}
     <|> do {nm <- lexem number; return (Const (I nm))}
     <|> do {keyword "true"; return (Const (B True))}
     <|> do {keyword "false"; return (Const (B False))}
     <|> do {cs <- lexem iden; return (Var cs) }
     <?> "factor"

-- Задача 6.b -----------------------------------------
term :: Parser Exp     
term = chainl1 factor (mulOp >>= \op -> return (\l r -> Op l op r))

relat :: Parser Exp
relat = chainl1 term (addOp >>= \op -> return (\l r -> Op l op r))

conj :: Parser Exp
conj = do e1 <- relat
          rest <- optionMaybe (do op <- relOp; e2 <- relat; return (op, e2))
          case rest of
              Just (op, e2) -> return (Op e1 op e2)
              Nothing       -> return e1

disj :: Parser Exp
disj = chainl1 conj (conOp >>= \op -> return (\l r -> Op l op r))

expr :: Parser Exp
expr = chainl1 disj (disOp >>= \op -> return (\l r -> Op l op r))

------------------------------------------------------
stmt :: Parser Stmt 
stmt = do {keyword "for"; forSt}
       <|> do {keyword "while"; whileSt}
       <|> do {keyword "if"; ifSt}
       <|> do {keyword "read"; inSt}
       <|> do {keyword "write"; outSt}
       <|> do {var <- lexem iden; assignSt var}
       <|> blockSt
       <?> "statement"

-- Задача 6.c -----------------------------------------
forSt :: Parser Stmt  
forSt   = do symbol '('
             s_init <- stmt
             symbol ';'
             e_cond <- expr
             symbol ';'
             s_upd <- stmt
             symbol ')'
             s_body <- stmt
             return (For s_init e_cond s_upd s_body)

whileSt :: Parser Stmt               
whileSt = do symbol '('
             e <- expr
             symbol ')'
             s <- stmt
             return (While e s)
              
ifSt :: Parser Stmt              
ifSt    = do symbol '('
             e <- expr
             symbol ')'
             s <- stmt
             return (If e s)

inSt :: Parser Stmt              
inSt = fmap Read iden

outSt :: Parser Stmt              
outSt = fmap Write expr

assignSt :: String -> Parser Stmt 
assignSt var = (lexem (string "++") >> return (Incr var))
           <|> (lexem (string ":=") >> expr >>= \e -> return (Assign var e))

declaration :: Parser [(String, Type)]
declaration = do t <- typev
                 ids <- listId
                 symbol ';'
                 return (map (\id -> (id, t)) ids)

listId :: Parser [String]
listId = sepBy1 iden (symbol ',')

listSt :: Parser [Stmt]
listSt = sepBy stmt (symbol ';')

blockSt :: Parser Stmt
blockSt = do symbol '{'
             decls_list <- many declaration
             let decls = concat decls_list
             stmts <- listSt
             symbol '}'
             return (Block decls stmts)
               
---------------------------------------------	
-- Головні функції
---------------------------------------------				
program :: Parser Stmt 
program = do {spaces; r <- stmt; eof; return r}


parseL :: String -> Either ParseError Program
parseL s = parse program "" s


-- Програми -------------------------------------------
squareRoot :: Program
squareRoot = Block [("a",It),("b",It)]
                   [ Read "a", Assign "b" (Const (I 0))
                   , If (Op (Var "a") Ge (Const(I 0)))
                        (Block [("c", Bt)] 
                               [Assign "c" (Const (B True)),
                                While (Var "c")
                                 (Block []
                                   [(Incr "b"), 
                                    Assign "c" (Op (Var "a") Ge (Op (Var "b") Times (Var "b")))
                                   ])
                               ]
                        )
                   , Write (Op (Var "b") Minus (Const (I 1)))
                   ]

squareRootS :: String
squareRootS =
   "{int a, b; \
   \ read a; b := 0; \
   \ if (a>= 0)\
   \    {bool c; c:=true; while(c) {b++; c:= a >= b*b}\
   \    };\
   \  write (b-1)\
   \ }"

fibonacci :: Program
fibonacci = 
    Block [("in",It), ("out",It)]
          [ Read "in",  Assign "out" (Const (I 0))
          , If (Op (Var "in") Ge (Const(I 0))) 
               (Block [("f0",It), ("f1",It), ("c",It)]
                     [Assign "f0" (Const (I 1)), Assign "f1" (Const (I 1)), Assign "out" (Const (I 1)),
                      If (Op (Var "in") Gt (Const (I 1)))
                         (For (Assign "c" (Const (I 1)))
                             (Op (Var "c") Lt (Var "in")) 
                             (Incr "c")
                             (Block []
                                    [Assign "out" (Op (Var "f0") Plus (Var "f1"))
                                    , Assign "f0" (Var "f1")
                                    , Assign "f1" (Var "out")
                                    ]
                              )
                         )
                     ])
          , Write (Var "out")
          ]

fibonacciS :: String
fibonacciS = 
 " {int in, out; read in; out := 0; \n\
   \if (in>=0){int f0, f1,c; \n\
   \           f0 := 1; f1 := 1; out := 1; \n\
   \           if(in>1) \n \
   \              for (c := 1; c < in; c++) {\n\
   \                   out := f0 + f1; f0 := f1; f1 := out\n\
   \              }\n\
   \          }; \n\
   \write out \n\
  \}"
