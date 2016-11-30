{-# OPTIONS_GHC -Wall -fno-warn-unused-do-bind #-}
{-# LANGUAGE OverloadedStrings #-}
module Parse.Helpers
  ( module Parse.Primitives
  , SParser
  , qualifiedVar, qualifiedCapVar
  , equals, rightArrow, hasType, comma, pipe, cons, dot, underscore, lambda
  , leftParen, rightParen, leftSquare, rightSquare, leftCurly, rightCurly
  , addLocation
  , spaces, checkSpaces
  )
  where

import qualified Data.Text as Text
import Data.Text (Text)

import Parse.Primitives hiding (text)
import qualified Parse.Primitives as Prim
import qualified Reporting.Annotation as A
import qualified Reporting.Region as R



-- SPACE PARSER


type SParser a =
  Parser (a, R.Position, Space)



-- VARIABLES


qualifiedCapVar :: Parser Text
qualifiedCapVar =
  do  var <- capVar
      qualifiedVarHelp True [var]


qualifiedVar :: Parser Text
qualifiedVar =
  oneOf
    [ lowVar
    , do  var <- capVar
          qualifiedVarHelp False [var]
    ]


qualifiedVarHelp :: Bool -> [Text] -> Parser Text
qualifiedVarHelp allCaps vars =
  oneOf
    [ do  dot
          oneOf
            [ do  var <- capVar
                  qualifiedVarHelp allCaps (var:vars)
            , if allCaps then
                failure (error "TODO")
              else
                do  var <- lowVar
                    return (Text.intercalate "." (reverse (var:vars)))
            ]
    , return (Text.intercalate "." (reverse vars))
    ]



-- COMMON SYMBOLS


{-# INLINE equals #-}
equals :: Parser ()
equals =
  expecting "an equals sign '='" $
    Prim.text "="


{-# INLINE rightArrow #-}
rightArrow :: Parser ()
rightArrow =
  expecting "an arrow '->'" $
    Prim.text "->"


{-# INLINE hasType #-}
hasType :: Parser ()
hasType =
  expecting "the \"has type\" symbol ':'" $
    Prim.text ":"


{-# INLINE comma #-}
comma :: Parser ()
comma =
  expecting "a comma ','" $
    Prim.text ","


{-# INLINE pipe #-}
pipe :: Parser ()
pipe =
  expecting "a vertical bar '|'" $
    Prim.text "|"


{-# INLINE cons #-}
cons :: Parser ()
cons =
  expecting "a cons operator '::'" $
    Prim.text "::"


{-# INLINE dot #-}
dot :: Parser ()
dot =
  expecting "a dot '.'" $
    Prim.text "."


{-# INLINE underscore #-}
underscore :: Parser ()
underscore =
  expecting "a wildcard '_'" $
    Prim.text "_"


{-# INLINE lambda #-}
lambda :: Parser ()
lambda =
  oneOf [ Prim.text "\\", Prim.text "\x03BB" ]



-- ENCLOSURES


{-# INLINE leftParen #-}
leftParen :: Parser ()
leftParen =
  Prim.text "("


{-# INLINE rightParen #-}
rightParen :: Parser ()
rightParen =
  Prim.text ")"


{-# INLINE leftSquare #-}
leftSquare :: Parser ()
leftSquare =
  Prim.text "["


{-# INLINE rightSquare #-}
rightSquare :: Parser ()
rightSquare =
  Prim.text "]"


{-# INLINE leftCurly #-}
leftCurly :: Parser ()
leftCurly =
  Prim.text "{"


{-# INLINE rightCurly #-}
rightCurly :: Parser ()
rightCurly =
  Prim.text "}"





-- LOCATION


addLocation :: Parser a -> Parser (A.Located a)
addLocation parser =
  do  start <- getPosition
      value <- parser
      end <- getPosition
      return (A.at start end value)



-- WHITESPACE VARIATIONS


spaces :: Parser ()
spaces =
  do  space <- whitespace
      case space of
        None         -> return ()
        AfterIndent  -> return ()
        BeforeIndent -> failure (error "TODO")
        Aligned      -> failure (error "TODO")
        Freshline    -> failure (error "TODO")


checkSpaces :: Space -> Parser ()
checkSpaces space =
  case space of
    None         -> return ()
    AfterIndent  -> return ()
    BeforeIndent -> deadend (error "TODO")
    Aligned      -> deadend (error "TODO")
    Freshline    -> deadend (error "TODO")

