||| Cosntructing the involutive monoid frex.
|||
||| This implementation uses the fact that if `a` is an involutive
||| monoid, then `Frex a s` can be represented by `Frex a.monoid (Bool, s)`.
module Frexlet.Monoid.Involutive.Frex

import Frex

import Notation
import Notation.Multiplicative
import Frexlet.Monoid.Notation
import Frexlet.Monoid.Theory
import Frexlet.Monoid.Frex

import Frexlet.Monoid.Involutive.Theory
import Frexlet.Monoid.Involutive.Notation
import Frexlet.Monoid.Involutive.Properties
import Frexlet.Monoid.Involutive.Involution

import Data.Bool

%default total

-- Our construction uses an auxiliary frex for the underlying monoid

public export 0
AuxExtensionType : (a : InvolutiveMonoid) -> (s : Setoid) -> Type
AuxExtensionType a s = Extension (cast {to = Monoid} a) (cast Bool `Pair` s)

||| Type of auxiliary monoid frex used to construct the involutive monoid frex
public export 0
AuxFrexType : (a : InvolutiveMonoid) -> (s : Setoid) -> Type
AuxFrexType a s = Frex (cast {to = Monoid} a) (cast Bool `Pair` s)

||| Auxiliary monoid frex used to construct the involutive monoid frex
public export
AuxFrex : (a : InvolutiveMonoid) -> (s : Setoid) -> AuxFrexType a s
AuxFrex a s = MonoidFrex (cast a) (cast Bool `Pair` s)

public export
AuxFrexExtension : (a : InvolutiveMonoid) -> (s : Setoid) -> AuxExtensionType a s
AuxFrexExtension a s = (AuxFrex a s).Data

||| The monoid part of the involutive monoid frex
public export
AuxFrexMonoid : (a : InvolutiveMonoid) -> (s : Setoid) -> Monoid
AuxFrexMonoid a s = (AuxFrexExtension a s).Model

||| We use the following extension to define the involution on the frex
|||
||| a                                      (Bool, s)
||| | a.inv                                    | bimap not id
||| v                                          v
||| a.rev --> (AuxFrexMonoid a s).rev <--- (Bool, s)
|||     sta.rev                        dyn
public export
FrexInvolutionExtension : (a : InvolutiveMonoid) -> (s : Setoid) ->
  AuxExtensionType a s
FrexInvolutionExtension a s =
  let %hint
      notation : InvMult1 (U a)
      notation = a.Notation1
      frex : AuxFrexType a s
      frex = AuxFrex     a s
  in MkExtension
  { Model = (AuxFrexMonoid a s).rev
  , Embed = frex.Data.Embed.rev . (InvolutiveMonoidToInvolution a).H
  , Var   = frex.Data.Var . bimap (mate {b = cast Bool} not) (id s)
  }

||| The involution on the frex is given by the universal property:
|||
||| a ------> FrexInvMonoid a s  <------- (Bool, s)
||| | a.inv   =      | FrexInvolution a s     | bimap not id
||| v  (in Monoids)  v        =   (in Set)    v
||| a.rev --> (FrexInvMonoid a s).rev <--- (Bool, s)
|||     sta.rev                        dyn
public export
FrexInvolutionExtensionMorphism : (a : InvolutiveMonoid) -> (s : Setoid) ->
  AuxFrexExtension a s ~> FrexInvolutionExtension a s
FrexInvolutionExtensionMorphism a s = (AuxFrex a s).UP.Exists (FrexInvolutionExtension a s)

||| The involution homomorphism for the frex
public export
FrexInvolution : (a : InvolutiveMonoid) -> (s : Setoid) ->
  AuxFrexMonoid a s ~> (AuxFrexMonoid a s).rev
FrexInvolution a s = (FrexInvolutionExtensionMorphism a s).H

||| The involution axiom boils down to this equation:
|||
|||  FrexInvMonoid a s  ---------------------
|||         |                               |
|||         | FrexInvolution a s            | cast (cast a).revInvolution
|||         |                               |
|||         V                               V
||| (FrexInvMonoid a s).rev -------> (FrexInvMonoid a s).rev.rev
|||                 (FrexInvolution a s).rev
public export
FrexInvolutionIsInvolution : (a : InvolutiveMonoid) -> (s : Setoid) ->
  (AuxFrexMonoid a s).Involution (FrexInvolution a s)
FrexInvolutionIsInvolution a s =
  let %hint
      notation : InvMult1 (U a)
      notation = a.Notation1
      frex : AuxExtensionType a s
      frex = AuxFrexExtension a s
      inv  : (cast a) ~> (cast a).rev
      inv  = (InvolutiveMonoidToInvolution a).H
      bid  : (cast Bool `Pair` s) ~> (cast Bool `Pair` s)
      bid  = bimap (mate {b = cast Bool} not) (id s)
      frexInv : frex.Model ~> frex.Model.rev
      frexInv = FrexInvolution a s
      j : frex.Model.Algebra <~> frex.Model.Algebra.rev.rev
      j = frex.Model.revInvolution
      jHomo : frex.Model ~> frex.Model.rev.rev
      jHomo = Prelude.cast j
      ||| We'll use frex's universal property with respect to this extension:
      |||
      |||   a                                         (Bool, s)
      |||   | inv                                         |  bimap not id
      |||   v                                             v
      |||   a.rev                                     (Bool, s)
      |||   | inv.rev                                     |  bimap not id
      |||   v                                             v
      |||   a.rev.rev ---> frex.Model.rev.rev <------ (Bool, s)
      |||          frex.Embed.rev.rev          frex.Var
      doubleInvExtension : Extension (cast {to = Monoid}  a) (cast Bool `Pair` s)
      doubleInvExtension = MkExtension
        { Model = frex.Model.rev.rev
        , Embed = frex.Embed.rev.rev . inv.rev . inv
        , Var   = frex.Var   . bid . bid
        }
      -- and we'll construct two extension morphisms from frex.Model into it.
      ||| The first extension morphism:
      |||      frex.Embed                frex.Var
      |||   a -----------> frex.Model <-------------- (Bool, s)
      |||   | inv    = (def)      |inv       = (def)      |  bimap not id
      |||   v     ditto.rev       v        frex.Var       v
      |||   a.rev -------> frex.Model.rev <---------  (Bool, s)
      |||   | inv.rev = (functor) |inv.rev   = (def)      |  bimap not id
      |||   v     dittor.rev.rev  v        frex.Var       v
      |||   a.rev.rev ---> frex.Model.rev.rev <------ (Bool, s)
      |||          frex.Embed.rev.rev          frex.Var
      invInvMorphism : frex ~> doubleInvExtension
      invInvMorphism = MkExtensionMorphism
        { H = (FrexInvolution a s).rev . (FrexInvolution a s)
        , PreserveEmbed = \i => CalcWith (cast $ frex.Model.rev.rev) $
          |~ (frexInv.rev.H.H $ frexInv.H.H $ frex.Embed.H.H i)
          ~~ (frexInv.rev.H.H $ frex.Embed.rev.H.H $ inv.H.H i)
            ...(frexInv.rev.H.homomorphic _ _ $
                (FrexInvolutionExtensionMorphism a s).PreserveEmbed _)
          ~~ (frex.Embed.rev.rev.H.H $ inv.rev.H.H  $ inv.H.H i)
            ...((FrexInvolutionExtensionMorphism a s).PreserveEmbed _)
        , PreserveVar   = \x => CalcWith (cast $ frex.Model.rev.rev) $
          |~ (frexInv.rev.H.H $ frexInv.H.H $ frex.Var.H x)
          ~~ (frexInv.rev.H.H $ frex.Var.H $ bid.H x)
            ...(frexInv.rev.H.homomorphic _ _ $
                (FrexInvolutionExtensionMorphism a s).PreserveVar _)
          ~~ (frex.Var.H $ bid.H $ bid.H x)
            ...((FrexInvolutionExtensionMorphism a s).PreserveVar (bid.H x))
        }
      ||| The second extension morphism:
      |||      frex.Embed                frex.Var
      |||   a -----------> frex.Model <-------------- (Bool, s)
      |||   | inv \  = (j nat)  |   = ( not . not = id)   |  bimap not id
      |||   v      \            |                         v
      |||   a.rev   \ cast j    | cast j              (Bool, s)
      |||   | inv.rev\          |                         |  bimap not id
      |||   v        v          v                         v
      |||   a.rev.rev ---> frex.Model.rev.rev <------ (Bool, s)
      |||          frex.Embed.rev.rev          frex.Var
      jMorphism : frex ~> doubleInvExtension
      jMorphism = MkExtensionMorphism
        { H = jHomo
        , PreserveEmbed = \i => CalcWith (cast $ frex.Model.rev.rev) $
          |~ (jHomo.H.H $ frex.Embed.H.H i)
          ~~ (frex.Embed.rev.rev.H.H $ inv.rev.H.H $ inv.H.H i)
             ..<( frex.Embed.H.homomorphic _ _
                $ a.validate Involutivity [_])
        , PreserveVar   = \(b, x) => CalcWith (cast $ frex.Model.rev.rev) $
          |~ (jHomo.H.H $ frex.Var.H (b, x))
          ~~ (frex.Var.H $ bid.H $ bid.H (b, x))
             .=.( cong (\u => frex.Var.H (u, x))
                $ sym $ notInvolutive b)
        }
  in (AuxFrex a s).UP.Unique doubleInvExtension invInvMorphism jMorphism

public export
FrexInvolutionInvolution : (a : InvolutiveMonoid) -> (s : Setoid) -> Involution (AuxFrexMonoid a s)
FrexInvolutionInvolution a s = MkInvolution
    { H = FrexInvolution a s
    , involutive = FrexInvolutionIsInvolution a s
    }

public export
FrexInvolutiveMonoid : (a : InvolutiveMonoid) -> (s : Setoid) -> InvolutiveMonoid
FrexInvolutiveMonoid a s =
  InvolutionToInvolutiveMonoid (AuxFrexMonoid a s) $ FrexInvolutionInvolution a s

||| The reason the involutive frex works is that we can decompose an
||| InvolutiveExtension into a monoid extension with the following
||| extra data
public export
data InvolutiveExtension : (a : InvolutiveMonoid) -> (s : Setoid) -> Type where
  MkInvolutiveExtension :
  {0 a : InvolutiveMonoid} -> {0 s : Setoid} ->
  (MonoidExtension : AuxExtensionType a s) ->
  (ModelInvolution : Involution (MonoidExtension).Model) ->
  (PreserveInvolute : (i : U a) ->
      (MonoidExtension) .Model.equivalence.relation
        ((MonoidExtension) .Embed.H.H $ a.Sem Involute [i])
        ((ModelInvolution) .H.H.H $ (MonoidExtension) .Embed.H.H i)) ->
  (VarCompatibility : (((cast Bool) `Pair` s) ~~> cast {to = Setoid} (MonoidExtension).Model).equivalence.relation
        ((ModelInvolution).H.H . (MonoidExtension).Var)
        ((MonoidExtension).Var . (bimap (mate {b = cast Bool} Prelude.not) (id s)))) ->
  InvolutiveExtension a s

public export
(.MonoidExtension) : {0 a : InvolutiveMonoid} -> {0 s : Setoid} ->
  InvolutiveExtension a s -> AuxExtensionType a s
(MkInvolutiveExtension ext _ _ _).MonoidExtension = ext

public export
(.ModelInvolution) : {0 a : InvolutiveMonoid}  -> {0 s : Setoid} ->
  (ext : InvolutiveExtension a s) ->
  Involution (ext.MonoidExtension).Model
(MkInvolutiveExtension _ inv _ _).ModelInvolution = inv

public export
(.PreserveInvolute) : {0 a : InvolutiveMonoid} -> {0 s : Setoid} ->
  (ext : InvolutiveExtension a s) ->
  (i : U a) ->
      (ext.MonoidExtension) .Model.equivalence.relation
        (ext.MonoidExtension.Embed.H.H $ a.Sem Involute [i])
        (ext.ModelInvolution.H.H.H $ ext.MonoidExtension.Embed.H.H i)
(MkInvolutiveExtension _ _ preserve _).PreserveInvolute = preserve

public export
(.VarCompatibility) : {0 a : InvolutiveMonoid}  -> {0 s : Setoid} ->
  (ext : InvolutiveExtension a s) ->
  (((cast Bool) `Pair` s) ~~> cast {to = Setoid} ext.MonoidExtension.Model).equivalence.relation
        (ext.ModelInvolution.H.H . ext.MonoidExtension.Var)
        (ext.MonoidExtension.Var . (bimap (mate {b = cast Bool} Prelude.not) (id s)))
(MkInvolutiveExtension _ _ _ compat).VarCompatibility = compat

-----------------------------------------------------------

public export
InvolutiveExtensionToExtension : {a : InvolutiveMonoid} -> {s : Setoid} ->
  InvolutiveExtension a s -> Extension a s
InvolutiveExtensionToExtension ext = MkExtension
  { Model = InvolutionToInvolutiveMonoid
               ext.MonoidExtension.Model
               ext.ModelInvolution
  , Embed = MkSetoidHomomorphism
      { H = ext.MonoidExtension.Embed.H
      , preserves = \case
          MkOp (Mono op) => ext.MonoidExtension.Embed.preserves (MkOp op)
          MkOp Involution => \ [i] => ext.PreserveInvolute i
      }
  , Var   = cast (MkEnv {H = ext.MonoidExtension.Var, compatibility = ext.VarCompatibility})
  }

public export
ExtensionToInvolutiveExtension : {a : InvolutiveMonoid} -> {s : Setoid} ->
  Extension a s -> InvolutiveExtension a s
ExtensionToInvolutiveExtension ext =
  let monoid : Monoid
      monoid = cast {to = Monoid} ext.Model
      involution : Involution monoid
      involution = InvolutiveMonoidToInvolution ext.Model
      env : Env s monoid involution
      env = cast ext.Var
  in MkInvolutiveExtension
  { MonoidExtension = MkExtension
      { Model = monoid
      , Embed = cast ext.Embed
      , Var   = env.H
      }
  , ModelInvolution = involution
  , PreserveInvolute = \i => ext.Embed.preserves Involute [i]
  , VarCompatibility = env.compatibility
  }

public export
InvMonoidExtension : (a : InvolutiveMonoid) -> (s : Setoid) -> Extension a s
{- The definition of the involution operation on FrexInvMonoid is:

       Embed                                    Var
   a -------------------> FrexInvMonoid a s  <---------------- (Bool, s)
   | a.inv   =                 | FrexInvolution a s              | bimap not id
   v                           v        =                        v
   a.rev --> (FrexInvMonoid a s).rev <------------------------ (Bool, s)
       Embed.rev                             Var

  The LHS square tells us the monoid homomorphism `Embed` preserves the involution.
  The RHS square gives us the compatibility condition to make an
  `Env s (FrexInvMonoid a s) (FrexInvolution a s)`
  which in turn gives the required `Var` map.
-}
InvMonoidExtension a s = InvolutiveExtensionToExtension $
  MkInvolutiveExtension
  { MonoidExtension  = AuxFrexExtension a s
  , ModelInvolution  = FrexInvolutionInvolution a s
  , PreserveInvolute = (FrexInvolutionExtensionMorphism a s).PreserveEmbed
  , VarCompatibility = (FrexInvolutionExtensionMorphism a s).PreserveVar
  }

public export
(.Env) : (ext : InvolutiveExtension a s) ->
  Env s ext.MonoidExtension.Model
    ext.ModelInvolution
(.Env) ext = MkEnv
    { H = ext.MonoidExtension.Var
    , compatibility = ext.VarCompatibility
    }

public export
ExtenderHomomorphism : (a : InvolutiveMonoid) -> (s : Setoid) ->
  ExtenderHomomorphism (InvMonoidExtension a s)
ExtenderHomomorphism a s other =
  let otherIExt : InvolutiveExtension a s
      otherIExt = ExtensionToInvolutiveExtension other
      aInvolution : Involution (cast a)
      aInvolution = InvolutiveMonoidToInvolution a
      h : AuxFrexExtension a s ~> otherIExt.MonoidExtension
      h = (AuxFrex a s).UP.Exists otherIExt.MonoidExtension
      %hint frexNotation : InvMult1 (U $ FrexInvolutiveMonoid a s)
      frexNotation = (FrexInvolutiveMonoid a s).Notation1
      %hint aNotation : InvMult1 (U a)
      aNotation = a.Notation1
      %hint otherNotation : InvMult1 (U $ other.Model)
      otherNotation = other.Model.Notation1
      bid : ((cast Bool) `Pair` s) ~> ((cast Bool) `Pair` s)
      bid = bimap (mate {b = cast Bool} not) (id s)
      {- The main proof obligation is that `h` preserves the involution.
         We appeal to the universal property of AuxFrex a s:
         for the following extension:

            inv      Embed.rev                Var         bimap not id
         a ----> a.rev ---> other.Model.rev <---- (Bool, s) <--- (Bool, s)
      -}
      presExt : AuxExtensionType a s
      presExt = MkExtension
        { Model = otherIExt.MonoidExtension.Model.rev
        , Embed = otherIExt.MonoidExtension.Embed.rev . aInvolution.H
        , Var   = otherIExt.MonoidExtension.Var .
                  bid
        }
      {- So the lef and right halves of the next two diagram give us
         extension morphism: AuxFrexExtension a s ~> presExt

                                  h.H
          AuxFrexExtension a s -------------------------> other.Model
                 |      ^       = (h.PreserveEmbed)      ^      |
                 |      \   Embed          Embed        /       |
                 |  =    ------------- a ---------------        |
            inv  | (Embed.H.preserves) |inv              =      | inv
                 |                     |(other.Embed.preserves) |
                 |          Embed.rev  v      Embed.rev         |
                 |      /------------  a.rev -----------\       |
                 |     |      (h.PreseveEmbed).rev      |       |
                 v     v               =                v       v
         (AuxFrexExtension a s).rev ------------------> (other.Model).rev
                                        h.H.rev
                                   h.H
          AuxFrexExtension a s -------------------------> other.Model
                 |      ^       = (h.PreserveVar)        ^      |
                 |      \   Var          Var            /       |
                 |  =    -------- (Bool, s) ------------        |
            inv  |    (PreserveVar)    |bimap not id     =      | inv
                 |                     |(IExt.VarCompatibility) |
                 |          Var        v      Var               |
                 |      /-------- (Bool, s) ------------\       |
                 |     |      (h.PreseveVar)            |       |
                 v     v               =                v       v
         (AuxFrexExtension a s) ---------------------> (other.Model).rev
                                   h.H.H
      -}
      extendLHS,extendRHS : AuxFrexExtension a s ~> presExt
      extendLHS = MkExtensionMorphism
        { H =  h.H.rev . FrexInvolution a s
        , PreserveEmbed = \i => other.Model.equivalence.reflexive _
        , PreserveVar   = \bx => CalcWith (cast other.Model) $
            |~ h.H.H.H ((AuxFrexExtension a s).Var.H bx).inv
            ~~ h.H.H.H ((AuxFrexExtension a s).Var.H $ bid.H bx)
               ...(h.H.H.homomorphic _ _ $
                   (FrexInvolutionExtensionMorphism a s).PreserveVar _)
            ~~ otherIExt.MonoidExtension.Var.H (bid.H bx)
               ...(h.PreserveVar _)
         }
      extendRHS = MkExtensionMorphism
        { H = otherIExt.ModelInvolution.H . h.H
        , PreserveEmbed = \i => CalcWith (cast other.Model) $
          |~ (h.H.H.H $ (AuxFrexExtension a s).Embed.H.H i ).inv
          ~~ (otherIExt.MonoidExtension.Embed.H.H i).inv
             ...(other.Model.cong 1 (Dyn 0).inv [_] [_] [h.PreserveEmbed i])
          ~~ (otherIExt.MonoidExtension.Embed.H.H i.inv)
            ..<( other.Embed.preserves Involute [_])
        , PreserveVar   = \bx => CalcWith (cast other.Model) $
          |~ (h.H.H.H $ (AuxFrexExtension a s).Var.H bx).inv
          ~~ (otherIExt.MonoidExtension.Var.H bx).inv
             ...(other.Model.cong 1 (Dyn 0).inv [_] [_] [h.PreserveVar bx])
          ~~ (otherIExt.MonoidExtension.Var.H $ bid.H bx)
             ...(otherIExt.VarCompatibility _)
        }
  in MkSetoidHomomorphism
  { H = h.H.H
  , preserves = \case
      MkOp (Mono op)  => h.H.preserves (MkOp op)
      MkOp Involution => \ [i] =>
        (AuxFrex a s).UP.Unique presExt extendLHS extendRHS i
  }

public export
InvExtender : (a : InvolutiveMonoid) -> (s : Setoid) ->
  Frex.Frex.Extender (InvMonoidExtension a s)
-- %nf_metavar_threshold 40000
InvExtender a s other = MkExtensionMorphism
  { H = ExtenderHomomorphism a s other
  , PreserveEmbed = ((AuxFrex a s).UP.Exists
      (ExtensionToInvolutiveExtension other).MonoidExtension).PreserveEmbed
  , PreserveVar   = \i =>
      ((AuxFrex a s).UP.Exists
      (ExtensionToInvolutiveExtension other).MonoidExtension).PreserveVar
      (False, i)
  }
-- %nf_metavar_threshold 50

public export
Uniqueness : (a : InvolutiveMonoid) -> (s : Setoid) -> Uniqueness (InvMonoidExtension a s)
-- %nf_metavar_threshold 80000
Uniqueness a s other =
  let otherIExt : InvolutiveExtension a s
      otherIExt = ExtensionToInvolutiveExtension other
      aInvolution : Involution (cast a)
      aInvolution = InvolutiveMonoidToInvolution a
      h : AuxFrexExtension a s ~> otherIExt.MonoidExtension
      h = (AuxFrex a s).UP.Exists otherIExt.MonoidExtension
      %hint frexNotation : InvMult1 (U $ FrexInvolutiveMonoid a s)
      frexNotation = (FrexInvolutiveMonoid a s).Notation1
      %hint aNotation : InvMult1 (U a)
      aNotation = a.Notation1
      %hint otherNotation : InvMult1 (U $ other.Model)
      otherNotation = other.Model.Notation1
      bid : ((cast Bool) `Pair` s) ~> ((cast Bool) `Pair` s)
      bid = bimap (mate {b = cast Bool} not) (id s)
      -- An extension morphism gives an extension morphism from the auxiliary extension
      lemma : (extend : InvMonoidExtension a s ~> other) ->
              (AuxFrexExtension a s) ~> otherIExt.MonoidExtension
      lemma extend =
        let extend' : cast {to = Monoid} (InvMonoidExtension a s).Model ~> cast other.Model
            extend' = Homomorphism.cast extend.H
        in MkExtensionMorphism
        { H = MkSetoidHomomorphism          -- Can't just cast this because of
          { H = extend'.H                   -- the intensional structure of the
          , preserves = extend'.preserves   -- source and target
          }
        , PreserveEmbed = extend.PreserveEmbed
        , PreserveVar   = \case
            (False,x) => extend.PreserveVar x
            {- This is the only real proof obligation:
                               Var               tuple True x
                AuxFrex a s  <------ (Bool, s) <--------------- s
                     |    |          not x id\    tuple False x/|
                     |    | FrexInv-ExtMorph  ---,     =      |||
                     |    \ inv     =        Var v   Refl     //|
                     |     ---> AuxFrex a s <--- (Bool, s) <- / |
                     | =    extend.H |    extend.PreserveVar /  | tuple True x
            extend.H | preserve      v         other.Var    /   |
                     |  Involute other.Model <--------------    |
                     |        inv        /     def              |
                     v   v---------------        =              v
               other.Model <------------------------------- (Bool,s)
                             otherIExt.MonoidExtension.Var
            -}
            (True ,x) => CalcWith (cast other.Model) $
              |~ extend.H.H.H ((AuxFrexExtension a s).Var.H (True, x))
              ~~  extend.H.H.H ((InvMonoidExtension a s).Var.H x ).inv
                                      ..<( extend.H.H.homomorphic _ _
                                         $ (FrexInvolutionExtensionMorphism a s).PreserveVar (False, x))
              ~~ (extend.H.H.H ((InvMonoidExtension a s).Var.H x)).inv
                                      ...(extend.H.preserves Involute [_])
                 ~~ (other.Var.H x).inv  ...(other.Model.cong 1 (Dyn 0).inv [_] [_]
                                          [extend.PreserveVar _])
        }
  in \extend1,extend2 => (AuxFrex a s).UP.Unique otherIExt.MonoidExtension
                            (lemma extend1) (lemma extend2)
-- %nf_metavar_threshold 50

public export
Frex : (a : InvolutiveMonoid) -> (s : Setoid) -> Frex a s
-- %nf_metavar_threshold 80000
Frex a s = MkFrex
  { Data = InvMonoidExtension a s
  , UP = IsUniversal
    { Exists = InvExtender a s
    , Unique = Uniqueness a s
    }
  }
-- %nf_metavar_threshold 50
