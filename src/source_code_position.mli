(** One typically obtains a [Source_code_position.t] using a [_here_] expression, which is
    implemented by the [pa_here] preprocessor. *)

open Sexplib

type t
  = Lexing.position
  (** See INRIA's OCaml documentation for a description of these fields. *)
  = { pos_fname : string
    ; pos_lnum  : int
    ; pos_bol   : int
    ; pos_cnum  : int
    }
  with bin_io, sexp

type t_hum = t with sexp_of

include Comparable.S with type t := t
include Hashable.S   with type t := t

(** [to_string t] converts [t] to the form ["FILE:LINE:COL"]. *)
val to_string : t -> string


module Stable : sig
  module V1 : Stable_module_types.S0 with type t = t
end
