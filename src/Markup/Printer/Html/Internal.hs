{-# OPTIONS_GHC -Wno-missing-export-lists #-}
module Markup.Printer.Html.Internal where

import Prelude hiding (head)
import Numeric.Natural

-- * Types

newtype Html
  = Html String

newtype Structure
  = Structure String

newtype Content
  = Content String

newtype Head
  = Head String

-- * EDSL

html_ :: Head -> Structure -> Html
html_ (Head head) content =
  Html
    ( el "html"
      ( el "head" head
        <> el "body" (getStructureString content)
      )
    )

-- * Head

title_ :: String -> Head
title_ = Head . el "title" . escape

instance Semigroup Head where
  (<>) (Head h1) (Head h2) =
    Head (h1 <> h2)

instance Monoid Head where
  mempty = Head ""

-- * Structure

p_ :: Content -> Structure
p_ = Structure . el "p" . getContentString

h_ :: Natural -> Content -> Structure
h_ n = Structure . el ("h" <> m) . getContentString
  where
    m = if n <= 3 then show n else "3"

ul_ :: [Structure] -> Structure
ul_ =
  Structure . el "ul" . concat . map (el "li" . getStructureString)

code_ :: String -> Structure
code_ = Structure . el "pre" . escape

instance Semigroup Structure where
  (<>) c1 c2 =
    Structure (getStructureString c1 <> getStructureString c2)

instance Monoid Structure where
  mempty = Structure ""

-- * Content

txt_ :: String -> Content
txt_ = Content . escape

b_ :: Content -> Content
b_ content =
  Content $ el "b" (getContentString content)

i_ :: Content -> Content
i_ content =
  Content $ el "i" (getContentString content)

instance Semigroup Content where
  (<>) c1 c2 =
    Content (getContentString c1 <> getContentString c2)

instance Monoid Content where
  mempty = Content ""

-- * Render

render :: Html -> String
render (Html str) = str

-- * Utilities

el :: String -> String -> String
el tag content =
  "<" <> tag <> ">" <> content <> "</" <> tag <> ">"

elAttr :: String -> String -> String -> String
elAttr tag attrs content =
  "<" <> tag <> " " <> attrs <> ">" <> content <> "</" <> tag <> ">"

getStructureString :: Structure -> String
getStructureString structure =
  case structure of
    Structure str -> str

getContentString :: Content -> String
getContentString content =
  case content of
    Content str -> str

escape :: String -> String
escape =
  let
    escapeChar c =
      case c of
        '<' -> "&lt;"
        '>' -> "&gt;"
        '&' -> "&amp;"
        '"' -> "&quot;"
        '\'' -> "&#39;"
        _ -> [c]
  in
    concat . map escapeChar