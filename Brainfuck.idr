-- Brainfuck Interpreter

module Brainfuck

import Data.List
import System
import System.File
import Parser

{-
  >  increment the data pointer (to point to the next cell to the right).
  <  decrement the data pointer (to point to the next cell to the left).
  +  increment (increase by one) the byte at the data pointer.
  -  decrement (decrease by one) the byte at the data pointer.
  .  output the byte at the data pointer.
  ,  accept one byte of input, storing its value in the byte at the data
     pointer.
  [  if the byte at the data pointer is zero, then instead of moving the
     instruction pointer forward to the next command, jump it forward to the
     command after the matching ] command.
  ]  if the byte at the data pointer is nonzero, then instead of moving the
     instruction pointer forward to the next command, jump it back to the
     command after the match
-}

data Command = Forward
  | Backward
  | Increment
  | Decrement
  | Output
  | Input
  | Loop (List Command)

implementation Show Command where
  show Forward = ">"
  show Backward = "<"
  show Increment = "+"
  show Decrement = "-"
  show Output = "."
  show Input = ","
  show (Loop f) = "["

parseCommand : Parser Command
parseCommand = char '>' $> Forward
  <|> char '<' $> Backward
  <|> char '+' $> Increment
  <|> char '-' $> Decrement
  <|> char '.' $> Output
  <|> char ',' $> Input
  <|> char '[' *> Loop <$> (manyTill parseCommand $ char ']')

parseCommands : Parser (List Command)
parseCommands = many parseCommand

{-
  Brainfuck tape is representent as two lists, where current element
  is the first element in the right list.
-}
data Cells : Type where
  C : (left : List Int) -> (right : List Int) -> Cells

implementation Show Cells where
  show (C left right) = "Cells: " ++ show left ++ show right

emptyCells : Cells
emptyCells = C [] []

forward : Cells -> Cells
forward (C left []) = C (0 :: left) []
forward (C left (x :: xs)) = C (x :: left) xs

backward : Cells -> Cells
backward (C [] right) = C [] (0 :: right)
backward (C (x :: xs) right) = C xs (x :: right)

read : Cells -> Int
read (C left []) = 0
read (C left (x :: _)) = x

updateCells : (f : Int -> Int) -> Cells -> Cells
updateCells f (C left []) = C left [f 0]
updateCells f (C left (x :: xs)) = C left (f x :: xs)

eval : (commands : List Command) -> IO Cells
eval commands = go emptyCells commands
  where
    go : (cells : Cells) -> List Command -> IO Cells
    go cells [] = pure cells
    go cells (Forward :: cmds) = go (forward cells) cmds
    go cells (Backward :: cmds) = go (backward cells) cmds
    go cells (Increment :: cmds) = go (updateCells (+ 1) cells) cmds
    go cells (Decrement :: cmds) = go (updateCells (+ negate 1) cells) cmds
    go cells (Output :: cmds) = do
      (putChar . chr . read) cells
      go cells cmds
    go cells (Input :: cmds) = do
      c <- getChar
      go (updateCells ((const . ord) c) cells) cmds
    go cells (Loop loopCmds :: cmds) with (read cells == 0)
      _ | True = go cells cmds
      _ | False = do
        cells' <- go cells loopCmds
        go cells' (Loop loopCmds :: cmds)

allowedSymbols : List Char
allowedSymbols = ['>', '<', '+', '-', '.', ',', '[', ']']

filterFile : (file : String) -> String
filterFile file = (pack . filter (`elem` allowedSymbols) . unpack) file

evalBfIO : (input : String) -> IO ()
evalBfIO input =
  case parse parseCommands input of
    [(cmds, _)] => do
      cells <- eval cmds
      pure ()
    _ => do
      putStr "An Error occured while evaluating file"
      pure ()

main : IO ()
main = do
  args <- getArgs
  let (file :: _) = drop 1 args
    | [] => putStrLn "No file provided!"
  (Right symbols) <- readFile file
    | (Left error) => putStrLn $ show error
  (evalBfIO . filterFile) symbols
