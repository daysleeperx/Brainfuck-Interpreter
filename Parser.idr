module Parser
import Data.Strings

public export
data Parser : Type -> Type where
  MkParser : (String -> List (a, String)) -> Parser a

public export
parse : Parser a -> String -> List (a, String)
parse (MkParser f) inp = f inp

public export
item: Parser Char
item = MkParser (\input => case unpack input of
                                [] => []
                                (c :: chars) => [(c, pack chars)])

public export
implementation Functor Parser where
    map f p = MkParser (\input => case parse p input of
                                       [(a, s)] => [(f a, s)]
                                       _ => [])

public export
implementation Applicative Parser where
    pure v = MkParser (\input => [(v, input)])
    pf <*> p = MkParser (\input => case parse pf input of
                                        [(f, s)] => parse (f <$> p) s
                                        _ => [])

public export
implementation Monad Parser where
  p >>= f = MkParser (\input => case parse p input of
                                     [(a, s)] => parse (f a) s
                                     _ => [])

public export
implementation Alternative Parser where
  empty = MkParser (\x => [])
  p <|> q = MkParser (\input => case parse p input of
                                     [(a, s)] => [(a, s)]
                                     _ => parse q input)

-- primitive parsers
sat : (Char -> Bool) -> Parser Char
sat p = do x <- item
           if p x then pure x else empty

public export
char: Char -> Parser Char
char c = sat ( == c)

public export
digit : Parser Char
digit = sat isDigit

-- derived parsers
mutual
  public export
  partial
  some : Parser a -> Parser (List a)
  some p = pure (::) <*> p <*> many p

  public export
  partial
  many : Parser a -> Parser (List a)
  many p = some p <|> pure []

public export
manyTill: (parser: Parser a) -> (end: Parser b) -> Parser (List a)
manyTill parser end = (end $> []) <|> (pure (::) <*> parser <*> manyTill parser end)

fail : String -> Parser a
fail msg = MkParser (\_ => [])

optional: Parser a -> Parser (Maybe a)
optional p = map Just p <|> pure Nothing

notFollowedBy : Parser a -> Parser ()
notFollowedBy p = do
        a <- optional p
        case a of
             Nothing => pure ()
             (Just x) => fail "not empty"

public export
eof: Parser ()
eof = notFollowedBy item
