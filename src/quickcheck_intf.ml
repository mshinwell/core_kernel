(** You should start reading in quickcheck_generator.mli *)

(** [seed] specifies how to initialize a pseudo-random number generator.  When multiple
    tests share a deterministic seed, they each get a separate copy of the random
    generator's state; random choices in one test do not affect those in another.  The
    nondeterministic seed causes a fresh random state to be generated nondeterministically
    for each test. *)
type seed =
  [ `Deterministic of string
  | `Nondeterministic
  ]

module type Quickcheck_config = sig

  (** [default_seed] is used initialize the pseudo-random generator that chooses random
      values from generators, in each test that is not provided its own seed. *)
  val default_seed : seed

  (** [default_trial_count] determines the number of trials per test, except in tests
      that explicitly override it. *)
  val default_trial_count : int

  (** [default_trial_count_for_test_no_duplicates] determines the number of trials when
      running [test_no_duplicates] without [~trials], either as a constant or as a factor
      of [default_trial_count]. *)
  val default_trial_count_for_test_no_duplicates
    : [ `Constant of int
      | `Scale_of_default_trial_count of float
      ]

  (** [default_attempts_per_trial] determines the maximum number of attempts to generate
      inputs for trials, as a multiplier for the number of trials, except in tests that
      explicitly override it. *)
  val default_attempts_per_trial : float

end

module type Quickcheck = sig

  module Generator : module type of struct include Quickcheck_generator end
  module Observer  : module type of struct include Quickcheck_observer  end

  include Quickcheck_config

  (** [random_value ~seed gen] produces a single value chosen from [gen] using [seed]. *)
  val random_value
    :  ?seed : seed
    -> 'a Generator.t
    -> 'a

  (** [iter ~seed ~trials ~attempts gen ~f] runs [f] on up to [trials] different values
      generated by [gen].  It stops successfully after [trials] successful trials or if
      [gen] runs out of values.  It raises an exception if [f] raises an exception or if
      it fails to produce [trials] inputs from [gen] after [attempts] attempts. *)
  val iter
    :  ?seed     : seed
    -> ?trials   : int
    -> ?attempts : int
    -> 'a Generator.t
    -> f:('a -> unit)
    -> unit

  (** [test ~seed ~trials ~attempts ~sexp_of ~examples gen ~f] is like [iter], with
      optional concrete [examples] that are tested before values from [gen], and
      additional information provided on failure.  If [f] raises an exception and
      [sexp_of] is provided, the exception is re-raised with a description of the random
      input that triggered the failure. *)
  val test
    :  ?seed     : seed
    -> ?trials   : int
    -> ?attempts : int
    -> ?sexp_of  : ('a -> Sexplib.Sexp.t)
    -> ?examples : 'a list
    -> 'a Generator.t
    -> f:('a -> unit)
    -> unit

  (** [test_can_generate ~seed ~trials ~attempts ~sexp_of gen ~f] is useful for testing
      [Generator.t] values, to make sure they can generate useful examples.  It tests
      [gen] by generating up to [trials] values and passing them to [f].  Once a value
      satisfies [f], the iteration stops.  If no values satisfy [f], [test_can_generate]
      raises an exception.  If [sexp_of] is provided, the exception includes all of the
      generated values. *)
  val test_can_generate
    :  ?seed     : seed
    -> ?trials   : int
    -> ?attempts : int
    -> ?sexp_of  : ('a -> Sexplib.Sexp.t)
    -> 'a Generator.t
    -> f:('a -> bool)
    -> unit

  (** [test_no_duplicates ~seed ~trials ~attempts ~sexp_of gen ~by] is useful for testing
      [Generator.t] values, to make sure they do not create duplicate values.  It tests
      [gen] by generating up to [trials] values and comparing each pair of the generated
      values using [by].  If any of the pairs are identical, [test_no_duplicates] raises
      an exception.  If [sexp_of] is provided, the exception includes the identical
      values. *)
  val test_no_duplicates
    :  ?seed     : seed
    -> ?trials   : int
    -> ?attempts : int
    -> ?sexp_of  : ('a -> Sexplib.Sexp.t)
    -> 'a Generator.t
    -> by:[ `Equal of 'a -> 'a -> bool | `Compare of 'a -> 'a -> int ]
    -> unit

  (** [random_sequence ~seed gen] produces a sequence of values chosen from [gen]. *)
  val random_sequence
    :  ?seed : seed
    -> 'a Generator.t
    -> 'a Sequence.t

  (** [random_state_of_seed] constructs initial random states for a given seed.  This is
      intended for building extensions to this interface, rather than for use in
      individual tests. *)
  val random_state_of_seed : seed -> Core_random.State.t

end
