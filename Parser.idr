module Parser

public export
data Parser : Type -> Type where
  MkParser : (String -> List (a, String)) -> Parser a

public export
parse : Parser a -> String -> List (a, String)
parse (MkParser f) input = f input

public export
item : Parser Char
item = MkParser $ \input =>
  case unpack input of
    [] => []
    c :: chars => [(c, pack chars)]

public export
implementation Functor Parser where
  map f p = MkParser $ \input =>
    case parse p input of
      [(a, rest)] => [(f a, rest)]
      _ => []

public export
implementation Applicative Parser where
  pure value = MkParser $ \input => [(value, input)]
  pf <*> p = MkParser $ \input =>
    case parse pf input of
      [(f, rest)] => parse (f <$> p) rest
      _ => []

public export
implementation Monad Parser where
  p >>= f = MkParser $ \input =>
    case parse p input of
      [(a, rest)] => parse (f a) rest
      _ => []

public export
implementation Alternative Parser where
  empty = MkParser $ \_ => []
  p <|> q = MkParser $ \input =>
    case parse p input of
      [(a, rest)] => [(a, rest)]
      _ => parse q input

-- Primitive parsers
sat : (Char -> Bool) -> Parser Char
sat predicate = do
  x <- item
  if predicate x then pure x else empty

public export
char : Char -> Parser Char
char c = sat (== c)

public export
digit : Parser Char
digit = sat isDigit

-- Derived parsers
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
manyTill : (parser : Parser a) -> (end : Parser b) -> Parser (List a)
manyTill parser end =
  (end $> []) <|> (pure (::) <*> parser <*> manyTill parser end)
