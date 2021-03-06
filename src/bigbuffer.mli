(** Extensible string buffers based on Bigstrings.

   This module implements string buffers that automatically expand as necessary.  It
   provides accumulative concatenation of strings in quasi-linear time (instead of
   quadratic time when strings are concatenated pairwise).

   This implementation uses Bigstrings instead of strings.  This removes the 16MB limit on
   buffer size, and improves I/O-performance when reading/writing from/to channels.
*)

type t with sexp_of
(** The abstract type of buffers. *)

val create : int -> t
(** [create n] returns a fresh buffer, initially empty.
   The [n] parameter is the initial size of the internal string
   that holds the buffer contents. That string is automatically
   reallocated when more than [n] characters are stored in the buffer,
   but shrinks back to [n] characters when [reset] is called.
   For best performance, [n] should be of the same order of magnitude
   as the number of characters that are expected to be stored in
   the buffer (for instance, 80 for a buffer that holds one output
   line).  Nothing bad will happen if the buffer grows beyond that
   limit, however. In doubt, take [n = 16] for instance. *)

val contents : t -> string
(** Return a copy of the current contents of the buffer.
   The buffer itself is unchanged. *)

val big_contents : t -> Bigstring.t
(** Return a copy of the current contents of the buffer as a bigstring.
   The buffer itself is unchanged. *)

val volatile_contents : t -> Bigstring.t
(** Return the actual underlying bigstring used by this bigbuffer.
    No copying is involved.  To be safe, use and finish with the returned value
    before calling any other function in this module on the same [Bigbuffer.t]. *)

include Blit.S_distinct with type src := t with type dst := string

(** [blit ~src ~src_pos ~dst ~dst_pos ~len] copies [len] characters from
   the current contents of the buffer [src], starting at offset [src_pos]
   to string [dst], starting at character [dst_pos].

   Raise [Invalid_argument] if [src_pos] and [len] do not designate a valid
   substring of [src], or if [dst_pos] and [len] do not designate a valid
   substring of [dst]. *)

val nth : t -> int -> char
(** get the (zero-based) n-th character of the buffer. Raise
[Invalid_argument] if index out of bounds *)

val length : t -> int
(** Return the number of characters currently contained in the buffer. *)

val clear : t -> unit
(** Empty the buffer. *)

val reset : t -> unit
(** Empty the buffer and deallocate the internal string holding the
   buffer contents, replacing it with the initial internal string
   of length [n] that was allocated by {!Bigbuffer.create} [n].
   For long-lived buffers that may have grown a lot, [reset] allows
   faster reclamation of the space used by the buffer. *)

val add_char : t -> char -> unit
(** [add_char b c] appends the character [c] at the end of the buffer [b]. *)

val add_string : t -> string -> unit
(** [add_string b s] appends the string [s] at the end of the buffer [b]. *)

val add_substring : t -> string -> int -> int -> unit
(** [add_substring b s ofs len] takes [len] characters from offset
   [ofs] in string [s] and appends them at the end of the buffer [b]. *)

val add_substitute : t -> (string -> string) -> string -> unit
(** [add_substitute b f s] appends the string pattern [s] at the end
   of the buffer [b] with substitution.
   The substitution process looks for variables into
   the pattern and substitutes each variable name by its value, as
   obtained by applying the mapping [f] to the variable name. Inside the
   string pattern, a variable name immediately follows a non-escaped
   [$] character and is one of the following:
   - a non empty sequence of alphanumeric or [_] characters,
   - an arbitrary sequence of characters enclosed by a pair of
   matching parentheses or curly brackets.
   An escaped [$] character is a [$] that immediately follows a backslash
   character; it then stands for a plain [$].
   Raise [Not_found] if the closing character of a parenthesized variable
   cannot be found. *)

val add_buffer : t -> t -> unit
(** [add_buffer b1 b2] appends the current contents of buffer [b2]
   at the end of buffer [b1].  [b2] is not modified. *)

(** NOTE: additions *)

module Format : sig
  open Format

  val formatter_of_buffer : t -> formatter
  val bprintf : t -> ('a, formatter, unit) format -> 'a
end

module Printf : sig
  val bprintf : t -> ('a, unit, string, unit) format4 -> 'a
end

(**/**)

(** For Core.Std.Bigbuffer, not for users! *)
val __internal : t -> Bigbuffer_internal.t
