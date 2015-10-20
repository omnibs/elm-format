{-# OPTIONS_GHC -Wall #-}

module AST.Expression where

import AST.V0_15
import qualified AST.Literal as Literal
import qualified AST.Pattern as Pattern
import qualified AST.Type as Type
import qualified AST.Variable as Var
import qualified Reporting.Annotation as A
import qualified Reporting.Region as R


---- GENERAL AST ----

data UnaryOperator =
    Negative
    deriving (Show)

type Def =
    A.Located Def'


data Def'
    = Definition Pattern.Pattern [Pattern.Pattern] Expr Bool
    | TypeAnnotation (Commented Var.Ref) Type.Type
    deriving (Show)


type Expr =
    A.Annotated R.Region Expr'


data Expr'
    = Literal (Commented Literal.Literal)
    | Var (Commented Var.Ref)
    | Range Expr Expr
    | ExplicitList [Expr]
    | Binops Expr [(Commented Var.Ref,Expr)]
    | Unary UnaryOperator Expr
    | Lambda [Pattern.Pattern] Expr
    | App Expr [Expr]
    | If [(Expr, Expr)] Expr
    | Let [Def] Expr
    | Case Expr [(Pattern.Pattern, Expr)]
    | Data String [Expr]
    | Tuple [Expr]
    | Access Expr String
    | Update Expr [(String, Expr)]
    | Record [(String, Expr)]
    | Parens Expr
    -- for type checking and code gen only
    | Port PortImpl
    | GLShader String String Literal.GLShaderTipe
    deriving (Show)


-- PORTS

data PortImpl
    = In String Type.Port
    | Out String Expr Type.Port
    | Task String Expr Type.Port
    deriving (Show)


portName :: PortImpl -> String
portName impl =
  case impl of
    In name _ -> name
    Out name _ _ -> name
    Task name _ _ -> name


---- UTILITIES ----

rawVar :: String -> Expr'
rawVar x =
    Var $ Commented [] $ Var.VarRef x


tuple :: [Expr] -> Expr'
tuple expressions =
    Tuple expressions
