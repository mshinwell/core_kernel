## 113.00.00

- Added `Float.int63_round_nearest_exn`.

    val int63_round_nearest_exn : t -> Core_int63.

- Changed `Hashtbl.sexp_of_t` so that keys are sorted in increasing order.

    This also applies to the `sexp_of_t` produced by `Hashtbl.Make` and
    `Make_binable`. Sorting by key is nice when looking at output, as well as
    in tests, so that the output is deterministic and so that diffs are
    minimized when output changes.

- Added to `Info`, `Error`, and `Or_error` a `Stable.V2` module, whose `bin_io`
  is the same as the unstable `bin_io`.

- Replaced `Map.prev_key` and `next_key` with `closest_key`.

    val closest_key
      :  ('k, 'v, 'cmp) t
      -> [ `Greater_or_equal_to
         | `Greater_than
         | `Less_or_equal_to
         | `Less_than
         ]
      -> 'k
      -> ('k * 'v) option

- Shared code between `Monad.Make{,2}` and `Applicative.Make{,2}`.

- Added tests to make sure `round_nearest` and `int63_round_nearest_exn`
  don't allocate.

- Added `Lazy.T_unforcing` module, with a custom `sexp_of_t` that doesn't
  force.

    This serializer does not support round tripping, i.e. `t_of_sexp`.  It
    is intended to be used in debug code or `<:sexp_of< >>` statements.  E.g:

      type t =
        { x : int Lazy.T_unforcing.t
        ; y : string
        }
      with sexp_of

- Extended `Map.to_sequence` and `Set.to_sequence` to take any combination of
  upper bound, lower bound, and direction.

- Added `Map.split`.

- Added `Timing_wheel.fire_past_alarms`, which fires alarms in the current time
  interval's bucket whose time is in the past.

- Added a `Total_map` module, for maps where every value of the key type is
  present in the map.

- Added `Bigstring.compare` and `Bigstring.equal`.

- Split `monad.ml` into three files: `monad.ml`, `monad.mli`, and `monad_intf.ml`.

- Removed the last remaining dependence of `Core_kernel` on Unix, moving
  `Time_ns.pause` functions to `Core`.

- Added optional arguments to `Hash_queue.create`, `?growth_allowed` and
  `size`, which then get passed to `Hashtbl.create`.

- Added a `?strict:unit` argument to functions that ordinarily create lazy
  sexps, like `failwiths`.

      Info.create
      Error.create
      Error.failwiths
      Error.failwithp
      Or_error.error

    This makes it easy to force a use to be strict, which is sometimes
    useful to accurately capture the state of a mutable data structure at
    the time the error happens, lest it change by the time the error is
    rendered.

- Removed `Interned_string` module.

- In `Pooled_hashtbl`, avoid trying to create arrays bigger than
  `Sys.max_array_length`.

    The problem affected 32-bit platforms.

- Added `Quickcheck` module.

    Supports automated testing with randomly-generated inputs in the style of
    Haskell's Quickcheck library.  Our adaptation supports flexible probability
    distributions for values of a given type and uniqueness guarantees for
    generated values.

- Made `Set.to_sequence` and `Set.split` have the same interface as
  `Map.to_sequence` and `Map.split`, respectively.

- Fixed `Float` and `Timing_wheel` to compile on 32-bit platforms.

- Added `Lazy.Stable.V1`.

- Added `List.reduce_balanced`, which is like `reduce`, but relies on
  associativity of `f` to make nesting of calls to `f` logarithmic rather than
  linear in the input list length.

- Added `String_id.Make_without_pretty_printer`.

- Restricted `Time_ns.Span` values to be less than 135 years, which ensures the
  corresponding `float` `Time.Span` values have microsecond precision.

    Fixed a `Time_ns` test that recently started failing due to crossing
    the 135-year boundary.

    Reducing the range of `Time_ns.Span` required adjusting the implementation
    of `Core.Time_ns.Option.Stable.V1`, which (accidentally, incorrectly)
    incorporated the (unstabilized) `Core_kernel.Time_ns.Span.min_value` as the
    representation of `bid_none` and `.max_value` as `ask_none`.  The prior
    representation is preserved, but some previously allowed values are no
    longer allowed and now raise exceptions!

- Added `Rope` module, the standard data structure for efficient string
  manipulation.

- Added `Sequence.unfold_with_and_finish`, a variant of `unfold_with` that can
  continue the sequence after the inner sequence finishes.

- Replaced `Sequence.cycle` with `Sequence.cycle_list_exn`, to work around a
  bug in `Sequence.cycle` raising on the empty sequence.

    Sequence.cycle can cause an infinite loop if its input is empty. It is
    problematic to check whether the input sequence is empty.

      * If we check it eagerly, we have to turn `cycle` into
        `cycle_eagerly_exn`, and it will evaluate the first element twice.

      * If we check it lazily, we might raise an exception in a seemingly
        unrelated part of the code, and the usually-good habit of wrapping a
        function like `cycle_exn` in `try .. with ..`  would not catch it.

    To get around these issues, [cycle] is changed to accept only lists as
    inputs, not sequences. It is now called [cycle_list_exn].

- Fixed assumptions about the size of integers, to support compiling to
  Javascript, where integers are 32-bit.

- Fixed build on Mac OSX.

    Fix build when LINUX_EXT or TIMERFD are undefined.

- Added `Caml.Bytes`.

    Add an alias for Bytes in Caml. Fixes janestreet/core_kernel#46.

- In `Container`, exposed polymorphic functions individually building container functions using `fold` or `iter`.

    Exposed polymorphic functions in `Core_kernel.Container` for
    individually building each of the `Container` functions using `fold`
    or `iter`.  E.g.:

      type ('t, 'elt, 'accum) fold =
        't -> init:'accum -> f:('accum -> 'elt -> 'accum) -> 'accum

      type ('t, 'elt) iter = 't -> f:('elt -> unit) -> unit

      val length : fold:('t,  _, int ) fold -> 't -> int
      val exists : iter:('t, 'a) iter -> 't -> f:('a -> bool) -> bool

- Added container.mli, which was sorely missing.

- Added `Doubly_linked.to_sequence`.

- Added `Hash_queue.sexp_of_t`.

## 112.35.00

- Added an Applicative interface to Core
  (a.k.a. idioms or applicative functors)
- Generalized the signature of `Hashtbl.merge_into` to allow the types
  of `src` and `dst` to be different.
- Made `Day_of_week.of_string` accept additional formats (integers 0-6,
  full day names).
- Added `Day_of_week.to_string_long`, which produces the full day name.
- Changed `Hashtbl.add_exn` to not create a new exception constructor
  when it raises due to a duplicate key.
- Added `Map.nth`, which returns the nth element of a map, ordered by
  key rank.
- Added `Binable.Of_binable` functors, similar to `Sexpable.Of_sexpable`

    One should use `Binable.Of_binable` rather than the functionally
    equivalent `Bin_prot.Utils.Make_binable`.

- Added `Either` module, with
  `type ('a, 'b) t = First  of 'a | Second of 'b`.
- Added to `Univ_map` a functor that creates a new `Univ_map` type in
  which the type of data is a function of the key's type, with the type
  function specified by the functor's argument.

    Normally, a `Univ_map.t` stores `('a Key.t * 'a)` pairs.  This feature
    lets it store `('a Key.t * 'a Data.t)` pairs for a given
    `('a Data.t)`.

- Made `Day_of_week.Stable` be `Comparable` and `Hashable`.
- Fixed a couple `Exn` unit tests that mistakenly relied on the global
  setting of `Printexc.get_backtrace`.

    Now the tests locally set it to what they need.

    This avoids unit-test failures when running with no
    `OCAMLRUNPARAM` set:

        File "exn.ml", line 130, characters 2-258: clear_backtrace threw "Assert_failure exn.ml:133:4".
            in TEST_MODULE at file "exn.ml", line 127, characters 0-1057

- Renamed `Monad.ignore` as `Monad.ignore_m`, while preserving
  `ignore = ignore_m` in existing modules (e.g. `Deferred`)
  that used it.

    We can later consider those modules on a case-by-case basis to see
    whether we want to remove `ignore`.

- Added `Set.symmetric_diff`.
- Added `Timing_wheel.reschedule`, which reschedules an existing alarm.
- Added `Applicative.S2`, analogous to `Monad.S2`.
- Added combinators to `Either`.
- Added `Hashtbl.add_or_error` and `create_with_key_or_error`, which use
  `Or_error` and are more idiomatic ways of signalling duplicates.
- Added `Sexpable.Of_sexpable1` functor, for one-parameter type
  constructors.
- Made `Timing_wheel_ns` keys be `Int63.t` rather than `int`, so that
  behavior is consistent on 32-bit and 64-bit machines.

  Also, made `Timing_wheel.Interval_num` an abstract type.
- Hid the `bytes` type in `Core.Std`, so that type errors refer to
  `string` rather than `bytes`.

    Added `Bytes` module so that people can say `Bytes.t` if they
    need to.

    Now we get reasonable error messages:

        String.length 13
        -->
        Error: This expression has type int but an expression was expected of type
                string

        "" + 13
        -->
        Error: This expression has type string but an expression was expected of type
                int

- Modernized the coding style in `Timing_wheel`.
- Replaced `Unpack_buffer.unpack` with `unpack_into` and `unpack_iter`,
  to avoid allocation.

    `Unpack_buffer.unpack` created a (vector-backed) `Core.Std.Queue`
    for each call.  When unpacking a buffer containing many values,
    resizing of the buffer can be costly and in some cases leads to
    promotions of short-lived data to the major heap.

    The new functions avoid allocating the queue:

        val unpack_into : ('value, _) t -> 'value Queue.t     -> unit Or_error.t
        val unpack_iter : ('value, _) t -> f:('value -> unit) -> unit Or_error.t

- Cleaned up the implementation of `Gc.tune`.
- Change `Unit` implementation to use `Identifiable.Make` instead of
  applying functors separately.
- Added `val random: unit -> int` to `Int63`.
- Reworked `Float.iround_*_exn` functions to not allocate in the common case.
- Added `Fqueue.singleton` and `Fdeque.singleton`.
- Moved `Unix.tm` and `Unix.strftime` from `Core_kernel` to `Core`.

    Added external time formatting:

        float (* seconds *)-> string (* format *) -> string = "..."

- Made `String_id.Make` call `Pretty_printer.Register`.
- Changed `String_id` to allow the pipe character in identifiers.
- Made `List.compare` have the usual type from `with compare`,
  `val compare : ('a -> 'a -> int) -> 'a t -> 'a t -> int`.

    Previously, `List.compare`'s type was:

        val compare : 'a t -> 'a t -> cmp:('a -> 'a -> int) -> int

- Made stable `Map`'s and `Set`'s conform to the `Stable1` interface.
- Reworked `Hashtbl.find_exn` to not allocate.

    Previously, `Hashtbl.find_exn` allocated because it called
    `Hashtbl.find`, which allocates an option (partially because
    `Avltree` allocates options in its `find` function).

## 112.24.00

- Added `Time_ns` module.

  A fragment of `Core.Std.Time_ns` is now in `Core_kernel.Std.Time_ns` such that
  `Async_kernel` can use `Time_ns` and only depend on `Core_kernel`.

- Renamed `Dequeue` as `Deque`.
  `Dequeue` remains for backward compatibility, but should not be used anymore.
  Use `Deque` instead.

- Added `Fdeque` module, a functional version `Deque`.
  Deprecate deque-like functions in `Fqueue`.

## 112.17.00

- Added `List.is_prefix`.

  ```ocaml
  val List.is_prefix : 'a t -> prefix:'a t -> equal:('a -> 'a -> bool) -> bool
  ```
- Made `String_id.Make` functor generative, which exposes that the
  result has `type t = private string`.

  Previously the result of `String_id.Make` didn't expose `type t =
  private string` due to a type-checker bug:

  * http://caml.inria.fr/mantis/view.php?id=6485
  * http://caml.inria.fr/mantis/view.php?id=6011

- Used generative functors, e.g. for `Unique_id`.

  Used generative functors (new feature in 4.02) where previously we
  used dummy `M : sig end` arguments in the signature and `(struct
  end)` when applying the functor.

  Just to note the difference between applicative and generative
  functors.  Suppose we have:

  ```ocaml
  module F (M : sig end) : sig type t end
  ```

  and we apply it several times

  ```ocaml
  module A = F (struct end)
  module B = F (struct end)
  module C = F (String)
  module D = F (String)
  ```

  Then we have that `A.t <> B.t` but `C.t = D.t`.  This can lead to
  subtle bugs, e.g. `Unique_id.Int (Unit)`.  Note that it is perfectly
  valid to apply any module to `F`, even though that is certainly not
  what we want.

  In 4.02, we can explicitly say that functor generates new types,
  i.e. it is generative. For this we use argument `()`.  So `F`
  becomes

  ```ocaml
  module F () : sig type t end
  ```

  You can only apply `F` to `()` or `(struct end)` but each
  application yields a new type `t`.

  ```ocaml
  module A = F ()
  module B = F ()
  module C = F (struct end)
  module D = F (String) (* illegal *)
  ```

  and now `A.t`, `B.t` and `C.t` are all different.

  Note that `F (struct end)` is still allowed but was converted to to
  `F ()` for consistency with signatures.

  Propagated generativity where necessary.  If inside a functor we use
  generative functor that creates new types, then we also need to make
  the enclosing functor generative.

  For functors that don't create types (like `Async.Log.Make_global`),
  generative or applicative functors are the same, but the syntax of
  generative functors is lighter.
- Exported `Core_kernel.Std.With_return`.
- Exposed the record type of `Source_code_position.t`.
- In `Weak_hashtbl.create`, exposed the `?growth_allowed` and `?size`
  arguments of the underlying `Hashtbl.create`.
- Added `with compare` to `Array`.
- Sped up `Int.pow`.

  Benchmarks before:

  | Name                                          |     Time/Run | mWd/Run | Percentage |
  |-----------------------------------------------|--------------|---------|------------|
  | [int_math.ml:int_math_pow] random[ 5] x 10000 | 140_546.89ns |         |     53.98% |
  | [int_math.ml:int_math_pow] random[10] x 10000 | 173_853.08ns |         |     66.77% |
  | [int_math.ml:int_math_pow] random[30] x 10000 | 219_948.85ns |         |     84.47% |
  | [int_math.ml:int_math_pow] random[60] x 10000 | 260_387.26ns |         |    100.00% |
  | [int_math.ml:int_math_pow] 2 ^ 30             |      11.34ns |         |            |
  | [int_math.ml:int_math_pow] 2L ^ 30L           |      21.69ns |   3.00w |            |
  | [int_math.ml:int_math_pow] 2L ^ 60L           |      22.95ns |   3.00w |            |

  and after:

  | Name                                          |     Time/Run | mWd/Run | Percentage |
  |-----------------------------------------------|--------------|---------|------------|
  | [int_math.ml:int_math_pow] random[ 5] x 10000 | 105_200.94ns |         |     80.78% |
  | [int_math.ml:int_math_pow] random[10] x 10000 | 117_365.82ns |         |     90.12% |
  | [int_math.ml:int_math_pow] random[30] x 10000 | 130_234.51ns |         |    100.00% |
  | [int_math.ml:int_math_pow] random[60] x 10000 | 123_621.45ns |         |     94.92% |
  | [int_math.ml:int_math_pow] 2 ^ 30             |       8.55ns |         |            |
  | [int_math.ml:int_math_pow] 2L ^ 30L           |      22.17ns |   3.00w |      0.02% |
  | [int_math.ml:int_math_pow] 2L ^ 60L           |      22.49ns |   3.00w |      0.02% |
- Removed the old, deprecated permission phantom types (`read_only`,
  etc.) and replaced them with the new =Perms= types.

  The old types had subtyping based on covariance and `private` types.
  The new types have subtyping based on contravariance and dropping
  capabilities.

  Renamed `read_only` as `read`, since `Perms` doesn't distinguish
  between them.

  The idiom for the type of a function that only needs read access
  changed from:

  ```ocaml
  val f : _ t -> ...
  ```

  to

  ```ocaml
  val f : [> read ] t -> ...
  ```

  This mostly hit `Iobuf` and its users.
- Added `String.is_substring`.
- Added `With_return.prepend`, and exposed `With_return.t` as
  contravariant.

  ```ocaml
  (** [prepend a ~f] returns a value [x] such that each call to [x.return] first applies [f]
      before applying [a.return].  The call to [f] is "prepended" to the call to the
      original [a.return].  A possible use case is to hand [x] over to an other function
      which returns ['b] a subtype of ['a], or to capture a common transformation [f]
      applied to returned values at several call sites. *)
  val prepend : 'a return -> f:('b -> 'a) -> 'b return
  ```
- Moved the `Gc` module's alarm functionality into a new
  `Gc.Expert.Alarm` module.

  The was done because the Gc alarms introduce threading semantics.
- Exposed modules in `Core_kernel.Std`: `Int_conversions`,
  `Ordered_collection_common`
- Removed `Pooled_hashtbl` from `Hashable.S`, to eliminate a
  dependency cycle between `Int63` and `Pool`.

  This was needed to use `Int63` in `Pool`.  Previously, `Int63 <- Int
  <- Hashable <- Pool`, which made it impossible to use `Int63` in
  `Pool`.

  So, we are removing the dependency `Hashable <- Pool`, simplifying
  `Hashable` to not include `Pooled_hashtbl`, and letting users call
  the `Pooled_hashtbl` functor directly when necessary.
- Added to `Pool.Pointer.Id` conversions to and from `Int63`.
- Made `Pooled_hashtbl.resize` allocate less.
- Removed `Pool.pointer_of_id_exn_is_supported`, which was always
  `true`.
- Added `with compare` to `Info`, `Error`, `Or_error`.
- Moved `Backtrace` from `Core`
- In C stubs, replaced `intxx` types by `intxx_t`.

  Following this: http://caml.inria.fr/mantis/view.php?id=6517

  Fixes #23
- Removed `Backtrace.get_opt`, which is no longer necessary now that
  `Backtrace.get` is available on all platforms.
- Added module types: `Stable`, `Stable1`, `Stable2`.
- Exposed `Core_kernel.Std.Avltree`.
- Removed from `Binary_packing` a duplicated exception,
  `Pack_signed_32_argument_out_of_range`.

  Closes #26
- Made `Info`, `Error`, and `Or_error` stable.

  The new stable serialization format is distinct from the existing
  unstable serialization format in the respective modules, which wasn't
  changed.
- Add `Sequence.Step.sexp_of_t`.

## 112.06.00

- Made `String_id` have `Stable_containers.Comparable`.
- Changed `Gc.disable_compaction` to require an `allocation_policy`.
- Made `Option` match `Invariant.S1`.
- Added `Sequence.filter`, `compare`, and `sexp_of_t`.
- Added `With_return.with_return_option`, abstracting a common pattern
  of `with_return`.

        val with_return        : ('a return -> 'a  ) -> 'a
        val with_return_option : ('a return -> unit) -> 'a option

- Install a handler for uncaught exceptions, using
  `Printexc.set_uncaught_exception_handler`, new in OCaml 4.02.
- Changed `Day_of_week` representation to a normal variant.
- Changed `Exn.handle_uncaught` so that if it is unable to print, it
  still does `exit 1`.
- Added `Sexp.of_sexp_allow_extra_fields`, previously in
  `Core_extended.Sexp`.
- Changed the implementation of `Exn.raise_without_backtrace` to use
  `raise_notrace`, new in OCaml 4.02.
- Added `Float` functions for converting to and from IEEE
  sign/exponent/mantissa.
- Added `String.Caseless` module, which compares and hashes strings
  ignoring case.
- Reimplemented `Type_equal.Id` using extensible types (new in OCaml
  4.02), removing a use of `Obj.magic`.

    Changed `Type_equal.Id.same_witness` to return `option` rather than
    `Or_error`, which allows it to be implemented without allocation.

- Removed a reference to the `Unix` module. Applications using
  `core_kernel` should be able to link without `unix.cma` again.
- Made `Char.is_whitespace` accept `\f` and `\v` as whitespace,
  matching C.

## 112.01.00

- Removed vestigial code supporting OCaml 4.00.
- Used `{Hashable,Comparable}.S_binable` in `Day_of_week` and `Month`.
- Improved the performance of `Set_once.set`.
- Added `Type_equal.Lift3` functor.
- Replaced occurrences of `Obj.magic 0` with `Obj.magic None`.

  With the former the compiler might think the destination type is
  always an integer and instruct the GC to ignore references to such
  values.  The latter doesn't have this problem as options are not
  always integers.
- Made `String_id.of_string` faster.
- Added `Bigstring` functions for reading and writing the
  size-prefixed bin-io format.

  - `bin_prot_size_header_length`
  - `write_bin_prot`
  - `read_bin_prot`
  - `read_bin_prot_verbose_errors`
- Added `{Info,Error}.to_string_mach` which produces a single-line
  sexp from an `Error.t`.
- Added `{Info,Error}.createf`, for creation from a format string.
- Added new `Perms` module with phantom types for managing access
  control.

  This module supersedes the `read_only`, `read_write`, and
  `immutable` phantom types, which are now deprecated, and will be
  removed in the future.  This module uses a different approach using
  sets of polymorphic variants as capabilities, and contravariant
  subtyping to express dropping capabilities.

  This approach fixes a bug with the current phantom types used for
  `Ref.Permissioned` in which `immutable` types aren't guaranteed to
  be immutable:

  ```ocaml
  let r = Ref.Permissioned.create 0
  let r_immutable = (r :  (int, immutable) Ref.Permissioned.t)
  let () = assert (Ref.Permissioned.get r_immutable = 0)
  let () = Ref.Permissioned.set r 1
  let () = assert (Ref.Permissioned.get r_immutable = 1)
  ```

  The bug stems from the fact that the phantom-type parameter is
  covariant, which allows OCaml's relaxed value restriction to kick
  in, which allows one to create a polymorphic value, which can then
  be viewed as both immutable and read write.  Here's a small
  standalone example to demonstrate:

  ```ocaml
  module F (M : sig
              type +'z t
              val create : int -> _ t
              val get : _ t -> int
              val set : read_write t -> int -> unit
            end) : sig
    val t : _ M.t
  end = struct
    let t = M.create 0
    let t_immutable = (t :  immutable M.t)
    let () =
      assert (M.get t_immutable = 0);
      M.set t 1;
      assert (M.get t_immutable = 1);
    ;;
  end
  ```

  The new approach fixes the problem by making the phantom-type
  parameter contravariant, and using polymorphic variants as
  capabilities to represent what operations are allowed.
  Contravariance allows one to drop capabilities, but not add them.
- Added `Int.Hex` module, which has hexadecimal sexp/string
  conversions.
- Added `Gc.major_plus_minor_words`, for performance reasons.

## 111.28.00

- Added `Pooled_hashtbl.resize` function, to allow preallocating a table
  of the desired size, to avoid growth at an undesirable time.
- Added `Pooled_hashtbl.on_grow` callback, to get information about
  hashtbl growth.
- Changed `Hashable.Make` to not export a `Hashable` module.

    The `Hashable` module previously exported was useless, and shadowed
    `Core.Std.Hashable`.

- Moved `Common.does_raise` to `Exn.does_raise`, to make it easier to
  find.
- Added `Float.one`, `minus_one`, and `~-`.  (fixes #12).
- Removed `Core.Std.unimplemented` and renamed it as
  `Or_error.unimplemented`.

    It is not used enough to live in the global namespace.

## 111.25.00

- Fix build on FreeBSD

  Closes #10
- Added functions to `Container` interface: `sum`, `min_elt`,
  `max_elt`.

  ```ocaml
  (** Returns the sum of [f i] for i in the container *)
  val sum
    : (module Commutative_group.S with type t = 'sum)
    -> t -> f:(elt -> 'sum) -> 'sum

  (** Returns a min (resp max) element from the collection using the provided [cmp]
      function. In case of a tie, the first element encountered while traversing the
      collection is returned. The implementation uses [fold] so it has the same
      complexity as [fold]. Returns [None] iff the collection is empty. *)
  val min_elt : t -> cmp:(elt -> elt -> int) -> elt option
  val max_elt : t -> cmp:(elt -> elt -> int) -> elt option
  ```
- Made `Core_hashtbl_intf` more flexible. For instance supports
  modules that require typereps to be passed when creating a table.

  Address the following issues:

  The type `('a, 'b, 'z) create_options` needs to be consistently used
  so that `b` corresponds with the type of data values in the returned
  hash table.  The type argument was wrong in several cases.

  Added the type `('a, 'z) map_options` to `Accessors` so that
  map-like functions -- those that output hash tables of a different
  type than they input -- can allow additional arguments.
- Fixed a bug in `Dequeue`'s `bin_prot` implementation that caused it
  to raise when deserializing an empty dequeue.
- Made `Container.Make`'s interface match `Monad.Make`.
- Deprecated infix `or` in favor of `||`.
- Simplified the interface of `Arg` (which was already deprecated in
  favor of `Command`).
- Replaced `Bag.fold_elt` with `Bag.filter`.
- `Memo.general` now raises on non-positive `cache_size_bound`.
- Removed `Option.apply`.
- Removed `Result.call`, `Result.apply`.
- Moved `Quichcheck` to `core_extended`.

  It should not be used in new code.

## 111.21.00

- Removed our custom C stub for closing channels, reverting to the one
  in the OCaml runtime.

    A long time ago we found that the OCaml runtime did not release the
    lock before calling `close` on the fd underlying a channel.  On some
    filesystems (e.g. smb, nfs) this could cause a runtime hang.  We
    filed a bug with INRIA and wrote our own `close` function which
    `In_channel` calls to this day.  The bug has long been fixed, and
    our function is probably buggy, so this reverts us to the runtime's
    `close`.

- Added `Float.{of,to}_int64_preserve_order`, which implement the
  order-preserving zero-preserving bijection between non-NaN floats and
  99.95% of `Int64`'s.

    Used the new function to improve `one_ulp`, which is now exposed:

        (** The next or previous representable float.  ULP stands for "unit of least precision",
            and is the spacing between floating point numbers.  Both [one_ulp `Up infinity] and
            [one_ulp `Down neg_infinity] return a nan. *)
        val one_ulp : [`Up | `Down] -> t -> t

- Changed `Map.symmetric_diff` to return a `Sequence.t`
  instead of a `list`.
- Added `Sequence.filter_map`.
- Improved `Stable_unit_test.Make_sexp_deserialization_test`'s error
  message so that it includes the expected sexp.

## 111.17.00

- In `Bigstring`, made many operations use compiler primitives new in
  OCaml 4.01.

  Exposed `Bigstring.get` and `set` as compiler primitives in the
  interface.

  Added `Bigstring.unsafe_get_int64_{le,be}_trunc`.
- Made `Error` round trip `exn`, i.e. `Error.to_exn (Error.of_exn exn)
  = exn`.
- Added to `failwiths` an optional `?here:Lexing.position` argument.
- Added `with typerep` to `Flags.S`.
- Optimized `List.dedup []` to return immediately.
- Added `data` argument to polymorphic type `Hashtbl_intf.Creators.create_options`.

  This allows implementations of `Hashtbl_intf.Creators` to have
  constructor arguments that depend on the type of both key and data
  values.  For example:

  ```ocaml
  module type Hashtbl_creators_with_typerep =
    Hashtbl_intf.Creators
    with type ('key, 'data, 'z) create_options
      =  typerep_of_key:'key Typerep.t
      -> typerep_of_data:'data Typerep.t
      -> 'z
  ```
- Improved the interface for getting `Monad.Make` to define `map` in
  terms of `bind`.

  Instead of passing a `map` function and requiring everyone who wants
  to define `map` using `bind` to call a special function, we use a
  variant type to allow the user to say what they want:

  ```ocaml
  val map : [ `Define_using_bind
            | `Custom of ('a t -> f:('a -> 'b) -> 'b t)
            ]
  ```
- Improved the performance of many `Dequeue` functions.

  Previously, many `Dequeue.dequeue`-type functions worked by raising
  and then catching an exception when the dequeue is empty.  This is
  much slower than just testing for emptiness, which is what the code
  now does.

  This improves the performance of `Async.Writer`, which uses
  `Dequeue.dequeue_front`.

## 111.13.00

- Added a `Sequence` module that implements polymorphic, on-demand
  sequences.

    Also implemented conversion to `Sequence.t` from various containers.

- Improved the explicitness and expressiveness of
  `Binary_searchable.binary_search`.

    `binary_search` now takes an additional (polymorphic variant)
    argument describing the relationship of the returned position to the
    element being searched for.

        val binary_search
          :  ?pos:int
          -> ?len:int
          -> t
          -> compare:(elt -> elt -> int)
          -> [ `Last_strictly_less_than         (** {v | < elt X |                       v} *)
             | `Last_less_than_or_equal_to      (** {v |      <= elt       X |           v} *)
             | `Last_equal_to                   (** {v           |   = elt X |           v} *)
             | `First_equal_to                  (** {v           | X = elt   |           v} *)
             | `First_greater_than_or_equal_to  (** {v           | X       >= elt      | v} *)
             | `First_strictly_greater_than     (** {v                       | X > elt | v} *)
             ]
          -> elt
          -> int option

- Added a new function, `Binary_searchable.binary_search_segmented`,
that can search an array consisting of two segments, rather than ordered
by `compare`.

        (** [binary_search_segmented ?pos ?len t ~segment_of which] takes an [segment_of]
            function that divides [t] into two (possibly empty) segments:

            {v
              | segment_of elt = `Left | segment_of elt = `Right |
            v}

            [binary_search_segmented] returns the index of the element on the boundary of the
            segments as specified by [which]: [`Last_on_left] yields the index of the last
            element of the left segment, while [`First_on_right] yields the index of the first
            element of the right segment.  It returns [None] if the segment is empty.

            By default, [binary_search] searches the entire [t].  One can supply [?pos] or
            [?len] to search a slice of [t].

            [binary_search_segmented] does not check that [segment_of] segments [t] as in the
            diagram, and behavior is unspecified if [segment_of] doesn't segment [t].  Behavior
            is also unspecified if [segment_of] mutates [t]. *)
        val binary_search_segmented
          :  ?pos:int
          -> ?len:int
          -> t
          -> segment_of:(elt -> [ `Left | `Right ])
          -> [ `Last_on_left | `First_on_right ]
          -> int option

- Made `Queue` match `Binary_searchable.S1`.
- Made `Gc.Stat` and `Gc.Control` match `Comparable`.
- Fixed some unit tests in `Type_immediacy` that were fragile due to GC.

## 111.11.00

- Added to `String` functions for substring search and replace, based
  on the KMP algorithm.

  Here are some benchmarks, comparing `Re2` for a fixed pattern,
  Mark's kmp from extended_string, and this implementation ("needle").

  The pattern is the usual `abacabadabacabae...`.  The text looks
  similar, with the pattern occurring at the very end.

  For =Re2= and =Needle= search benchmarks, the pattern is
  preprocessed in advance, outside of the benchmark.

  FWIW: I've also tried searches with pattern size = 32767, but =Re2=
  blows up, saying:

  ```
  re2/dfa.cc:447: DFA out of memory: prog size 32771 mem 2664898
  ```

  | Name                          |        Time/Run |       mWd/Run |    mjWd/Run | Prom/Run | Percentage |
  |-------------------------------|-----------------|---------------|-------------|----------|------------|
  | create_needle_15              |        102.56ns |        21.00w |             |          |            |
  | re2_compile_15                |      6_261.48ns |               |       3.00w |          |      0.01% |
  | create_needle_1023            |     13_870.48ns |         5.00w |   1_024.01w |          |      0.03% |
  | re2_compile_1023              |    107_533.32ns |               |       3.03w |          |      0.24% |
  | create_needle_8191            |     90_107.02ns |         5.00w |   8_192.01w |          |      0.20% |
  | re2_compile_8191              |  1_059_873.47ns |               |       3.28w |    0.28w |      2.37% |
  | create_needle_524287          |  6_430_623.96ns |         5.00w | 524_288.09w |          |     14.35% |
  | re2_compile_524287            | 44_799_605.83ns |               |       3.77w |    0.77w |    100.00% |
  | needle_search_15_95           |        349.65ns |         4.00w |             |          |            |
  | re2_search_15_95              |        483.11ns |               |             |          |            |
  | mshinwell_search_15_95        |      1_151.38ns |       781.01w |             |          |            |
  | needle_search_15_815          |      2_838.85ns |         4.00w |             |          |            |
  | re2_search_15_815             |      3_293.06ns |               |             |          |            |
  | mshinwell_search_15_815       |      8_360.57ns |     5_821.07w |       0.55w |    0.55w |      0.02% |
  | needle_search_15_2415         |      8_395.84ns |         4.00w |             |          |      0.02% |
  | re2_search_15_2415            |      9_594.14ns |               |             |          |      0.02% |
  | mshinwell_search_15_2415      |     24_602.09ns |    17_021.16w |       1.62w |    1.62w |      0.05% |
  | needle_search_1023_6143       |     14_825.50ns |         4.00w |             |          |      0.03% |
  | re2_search_1023_6143          |     40_926.59ns |               |             |          |      0.09% |
  | mshinwell_search_1023_6143    |     81_930.46ns |    49_149.66w |   1_025.65w |    1.65w |      0.18% |
  | needle_search_1023_52223      |    126_465.96ns |         4.00w |             |          |      0.28% |
  | re2_search_1023_52223         |    365_359.98ns |               |             |          |      0.82% |
  | mshinwell_search_1023_52223   |    527_323.73ns |   371_715.39w |   1_033.17w |    9.17w |      1.18% |
  | needle_search_1023_154623     |    377_539.53ns |         4.00w |             |          |      0.84% |
  | re2_search_1023_154623        |  1_001_251.93ns |               |             |          |      2.23% |
  | mshinwell_search_1023_154623  |  1_499_835.01ns | 1_088_518.15w |   1_033.19w |    9.19w |      3.35% |
  | needle_search_8191_49151      |    115_223.31ns |         4.00w |             |          |      0.26% |
  | re2_search_8191_49151         |    559_487.38ns |               |             |          |      1.25% |
  | mshinwell_search_8191_49151   |    653_981.19ns |   393_219.50w |   8_201.01w |    9.01w |      1.46% |
  | needle_search_8191_417791     |    976_725.24ns |         4.00w |             |          |      2.18% |
  | re2_search_8191_417791        |  4_713_965.69ns |               |             |          |     10.52% |
  | mshinwell_search_8191_417791  |  4_224_417.93ns | 2_973_709.32w |   8_202.37w |   10.37w |      9.43% |
  | needle_search_8191_1236991    |  2_912_863.78ns |         4.00w |             |          |      6.50% |
  | re2_search_8191_1236991       | 14_039_230.59ns |               |             |          |     31.34% |
  | mshinwell_search_8191_1236991 | 11_997_713.73ns | 8_708_130.87w |   8_202.47w |   10.47w |     26.78% |
- Added to `Set` functions for converting to and from a `Map.t`.

  ```ocaml
  val to_map : ('key, 'cmp) t -> f:('key -> 'data) -> ('key, 'data, 'cmp) Map.t
  val of_map_keys : ('key, _, 'cmp) Map.t -> ('key, 'cmp) t
  ```

  This required adding some additional type trickery to
  `Core_set_intf` to indicate that the comparator for a given module
  may or may not be fixed.
- Added an optional `iter` parameter to `Container.Make`.

  A direct implementation of `iter` is often more efficient than
  defining `iter` in terms of `fold`, and in these cases, the results
  of `Container.Make` that are defined in terms of `iter` will be more
  efficient also.
- Added `Int.pow` (and for other integer types), for bounds-checked
  integer exponentiation.

## 111.08.00

- Added `Hashtbl.for_all` and `for_alli`.
- Added `Float.to_padded_compact_string` for converting a floating point
  number to a lossy, compact, human-readable representation.

    E.g., `1_000_001.00` becomes `"1m "`.

- Tweaked the form of the definition of `Blang.Stable.V1`.

    Removed a `type t_` that is not necessary now that we can use `nonrec`
    without triggering spurious warnings.

## 111.06.00

- Added inline benchmarks for `Array`

  Here are some of the results from the new benchmarks, with some
  indexed tests dropped.

  | Name                                                |    Time/Run | mWd/Run |  mjWd/Run |
  |-----------------------------------------------------|-------------|---------|-----------|
  | [core_array.ml:Alloc] create:0                      |     13.65ns |         |           |
  | [core_array.ml:Alloc] create:100                    |     99.83ns | 101.00w |           |
  | [core_array.ml:Alloc] create:255                    |    201.32ns | 256.00w |           |
  | [core_array.ml:Alloc] create:256                    |  1_432.43ns |         |   257.00w |
  | [core_array.ml:Alloc] create:1000                   |  5_605.58ns |         | 1_001.01w |
  | [core_array.ml:Blit.Poly] blit (tuple):10           |     87.10ns |         |           |
  | [core_array.ml:Blit.Poly] blito (tuple):10          |    112.14ns |   2.00w |           |
  | [core_array.ml:Blit.Poly] blit (int):10             |     85.25ns |         |           |
  | [core_array.ml:Blit.Poly] blito (int):10            |    107.23ns |   2.00w |           |
  | [core_array.ml:Blit.Poly] blit (float):10           |     84.71ns |         |           |
  | [core_array.ml:Blit.Poly] blito (float):10          |     86.71ns |   2.00w |           |
  | [core_array.ml:Blit.Int] blit:10                    |     19.77ns |         |           |
  | [core_array.ml:Blit.Int] blito:10                   |     23.54ns |   2.00w |           |
  | [core_array.ml:Blit.Float] blit:10                  |     19.87ns |         |           |
  | [core_array.ml:Blit.Float] blito:10                 |     24.12ns |   2.00w |           |
  | [core_array.ml:Is empty] Polymorphic '='            |     18.21ns |         |           |
  | [core_array.ml:Is empty] Array.equal                |      8.08ns |   6.00w |           |
  | [core_array.ml:Is empty] phys_equal                 |      2.98ns |         |           |
  | [core_array.ml:Is empty] Array.is_empty (empty)     |      2.98ns |         |           |
  | [core_array.ml:Is empty] Array.is_empty (non-empty) |      3.00ns |         |           |
- Moved `Thread_safe_queue` to core
- Generalized the type of `Exn.handle_uncaught_and_exit` to `(unit ->
  'a) -> 'a`.

  In the case where `handle_uncaught_and_exit` succeeds, it can return
  the value of the supplied function.

  It's type had been:

  ```ocaml
  val handle_uncaught_and_exit : (unit -> never_returns) -> never_returns
  ```
- Added `Int.round*` functions for rounding to a multiple of another
  int.

  ```ocaml
  val round : ?dir:[ `Zero | `Nearest | `Up | `Down ] -> t -> to_multiple_of:t -> t

  val round_towards_zero : t -> to_multiple_of:t -> t
  val round_down         : t -> to_multiple_of:t -> t
  val round_up           : t -> to_multiple_of:t -> t
  val round_nearest      : t -> to_multiple_of:t -> t
  ```

  These functions were added to `Int_intf.S`, implemented by `Int`,
  `Nativeint`, `Int32`, and `Int64`.

  Various int modules were also lightly refactored to make it easier
  in the future to implement common operators available for all
  modules implementing the int interface via a functor to share the
  code.

## 111.03.00

- Added `Error.to_string_hum_deprecated` that is the same as
  `Error.to_string_hum` pre 109.61.
- Changed `Error.to_string_hum` so that
  `Error.to_string_hum (Error.of_string s) = s`.

  This fixed undesirable sexp escaping introduced in 109.61 and
  restores the pre-109.61 behavior for the special case of
  `Error.of_string`.  A consequence of the removal of the custom
  `to_string_hum` converter in 109.61 was that:

  ```ocaml
  Error.to_string_hum (Error.of_string s) =
      Sexp.to_string_hum (Sexp.Atom s)
  ```

  That introduced sexp escaping of `s`.
- Added to `Doubly_linked` functions for moving an element
  within a list.

  ```ocaml
  val move_to_front : 'a t -> 'a Elt.t -> unit
  val move_to_back  : 'a t -> 'a Elt.t -> unit
  val move_after    : 'a t -> 'a Elt.t -> anchor:'a Elt.t -> unit
  val move_before   : 'a t -> 'a Elt.t -> anchor:'a Elt.t -> unit
  ```
- Improved `Core_map_unit_tests.Unit_tests` to allow arbitrary data
  in the map, not just `ints`.

  This was done by eta expansion.

## 110.01.00

- Changed `Queue` from a linked to an array-backed implementation.

  Renamed the previous implementation to `Linked_queue`.

  Renamed `transfer`, which was constant time, as `blit_transfer`,
  which is linear time.

  Removed `partial_iter`.  One can use `with_return`.

  Added `singleton`, `filter`, `get`, `set`.
- For `Error` and `Info`, changed `to_string_hum` to use `sexp_of_t`
  and `Sexp.to_string_hum`, rather than a custom string format.
- Changed the output format of `Validate.errors` to be a sexp.
- Added `Hashtbl.of_alist_or_error` and `Map.of_alist_or_error`.
- Added `String_id.Make` functor, which includes a module name for
  better error messages.
- Exposed `Bucket.size`.
- Changed the default for `Debug.should_print_backtrace` to be `false`
  rather than `true`.

  Usually the backtraces are noise.
- Removed the tuning of gc parameters built in to Core, so that the
  default is now the stock OCaml settings.

  Such tuning doesn't belong in Core, but rather done per application.
  Also, the Core settings had fallen way out of date, and not kept up
  with changes in the OCaml runtime settings.  We have one example
  (lwt on async) where the Core settings significantly slowed down a
  program.
- Added `Exn.raise_without_backtrace`, to raise without building a
  backtrace.

  `raise_without_backtrace` never builds a backtrace, even when
  `Backtrace.am_recording ()`.
- Made `with_return` faster by using `Exn.raise_without_backtrace`.
- Improved `with_return` to detect usage of a `return` after its
  creating `with_return` has returned.

## 109.60.00

- Added `Gc.keep_alive`, which ensures its argument is live at the point
  of the call.
- Added `Sexp.With_text` module, which keeps a value and the a sexp it
  was generated from, preserving the original formatting.

## 109.58.00

- Moved all of the `Gc` module into `Core_kernel`.

  Part of the `Gc` module used to be in `Core` because it used
  threads.  But it doesn't use threads anymore, so can be all in
  `Core_kernel`.
- Made `Stable.Map` and `Set` have `with compare`.
- Added `String.rev`.

  Closes janestreet/core#16

  We will not add `String.rev_inplace`, as we do not want to encourage
  mutation of strings.
- Made `Univ_map.Key` equivalent to `Type_equal.Id`.
- Added `Univ.view`, which exposes `Univ.t` as an existential, `type t
  = T : 'a Id.t * 'a -> t`.

  Exposing the existential makes it possible to, for example, use
  `Univ_map.set` to construct a `Univ_map.t`from a list of `Univ.t`s.

  This representation is currently the same as the underlying
  representation, but to make changes to the underlying representation
  easier, it has been put in a module `Univ.View`.

## 109.55.00

- Added `with typerep` to many `Core` types.
- Changed `Flat_queue` to raise if the queue is mutated during
  iteration.
- Improved `Map.merge` to run in linear time.

## 109.53.00

- Added `Float.to_string_round_trippable`, which produces a string
  that loses no precision but (usually) uses as few digits as
  possible.

  This can eliminate noise at the end (e.g. `3.14` not
  `3.1400000000000001243`).

  Benchmarks:

  New sexp:

  | Name                   | Time/Run | mWd/Run | Percentage |
  |------------------------|----------|---------|------------|
  | new Float.sexp_of 3.14 | 463.28ns |   6.00w |     48.88% |
  | new Float.sexp_of e    | 947.71ns |  12.00w |    100.00% |

  Old sexp:

  | Name                   | Time/Run | mWd/Run | Percentage |
  |------------------------|----------|---------|------------|
  | old Float.sexp_of 3.14 | 841.99ns | 178.00w |     98.03% |
  | old Float.sexp_of e    | 858.94ns | 178.00w |    100.00% |

  Much of the speedup in the 3.14 case comes from the fact that
  `format_float "%.15g"` is much faster than `sprintf "%.15g"`.  And
  of course the above does not capture any of the benefits of dealing
  with shorter strings down the road.

  Here are some detailed benchmarks of the various bits and pieces of
  what's going on here:

  | Name                                |   Time/Run | mWd/Run | Percentage |
  |-------------------------------------|------------|---------|------------|
  | format_float '%.15g' 3.14           |   335.96ns |   2.00w |     32.71% |
  | format_float '%.17g' 3.14           |   394.18ns |   4.00w |     38.38% |
  | format_float '%.20g' 3.14           |   459.79ns |   4.00w |     44.77% |
  | format_float '%.40g' 3.14           |   638.06ns |   7.00w |     62.13% |
  | sprintf '%.15g' 3.14                |   723.71ns | 165.00w |     70.47% |
  | sprintf '%.17g' 3.14                |   803.44ns | 173.00w |     78.23% |
  | sprintf '%.20g' 3.14                |   920.78ns | 176.00w |     89.66% |
  | sprintf '%.40g' 3.14                |   990.09ns | 187.00w |     96.41% |
  | format_float '%.15g' e              |   357.59ns |   4.00w |     34.82% |
  | format_float '%.17g' e              |   372.16ns |   4.00w |     36.24% |
  | format_float '%.20g' e              |   434.59ns |   4.00w |     42.32% |
  | format_float '%.40g' e              |   592.78ns |   7.00w |     57.72% |
  | sprintf '%.15g' e                   |   742.12ns | 173.00w |     72.26% |
  | sprintf '%.17g' e                   |   747.92ns | 173.00w |     72.83% |
  | sprintf '%.20g' e                   |   836.30ns | 176.00w |     81.43% |
  | sprintf '%.40g' e                   | 1_026.96ns | 187.00w |    100.00% |
  | valid_float_lexem 12345678901234567 |    76.29ns |   9.00w |      7.43% |
  | valid_float_lexem 3.14              |     9.28ns |   5.00w |      0.90% |
  | float_of_string 3.14                |   130.19ns |   2.00w |     12.68% |
  | float_of_string 1234567890123456.7  |   184.33ns |   2.00w |     17.95% |
  | to_string 3.14                      |   316.47ns |   7.00w |     30.82% |
  | to_string_round_trippable 3.14      |   466.02ns |   9.00w |     45.38% |
  | to_string e                         |   315.41ns |   7.00w |     30.71% |
  | to_string_round_trippable e         |   949.12ns |  15.00w |     92.42% |

- Replaced `Float.min_positive_value` with `min_positive_normal_value`
  and `min_positive_subnormal_value`.
- Added some functions to `Float.O`: `abs`, `of_float`, and
  `Robustly_comparable.S`.
- Small improvements to the `Heap` module.

  Implemented `Heap.iter` directly rather than in terms of `fold`.

  In `heap.ml`, fixed the idiom for using `Container.Make`.
- Added an `Int.O` and other `Int*.O` modules, with arithmetic
  operators, infix comparators, and a few useful arithmetic values.
- Added `Int.( ~- )`, for unary negation.
- Added `Pool.unsafe_free`.
- Added `Percent` module.

## 109.52.00

- Added to `Binary_packing` module functions for packing and unpacking
  signed 64-bit ints in little- and big-endian.
- Changed the `Comparator` interfaces to no longer have `with bin_io`
  or `with sexp`.

  The `Comparator` interfaces are now just about having a comparator.

  Also, renamed `type comparator` as `type comparator_witness`.  And,
  removed `Comparator.S_binable`, since one can use:

  ```ocaml
  type t with bin_io
  include Comparator.S with type t :` t
  ```
- Changed `Comparator.Make` to return a module without a type `t`,
  like other `*able` functors,

   This made it possible to remove the signature constraint when
  `Comparator.Make` is applied.
- Made `Comparable.S_binable` be like `Comparable.S` and not have
  `type t with sexp`.

  The following two functors now fail to type check:

  ```ocaml
  module F1 (M : Comparable.S        ) : sig type t with sexp end ` M
  module F2 (M : Comparable.S_binable) : sig type t with sexp end ` M
  ```

  whereas previously `F1` was rejected and `F2` was accepted.
- Changed the `Monad.Make` functor to require a `val map` argument.

  This was done since we almost always want a specialized `map`, and
  we kept making the mistake of not overriding the generic one in the
  three places needed.

  Added `Monad.map_via_bind`, which one can use to create a standard
  `map` function using `bind` and `return`.
- Removed unnecessary signature constraints on the result of applying
  `Monad.Make`.

  Some time ago, `Monad.Make` changed from returning:

  ```ocaml
  S with type 'a t ` 'a M.t
  ```

  to returning:

  ```ocaml
  S with type 'a t :` 'a M.t
  ```

  so we no longer need to constrain the result of `Monad.Make` at its
  uses to remove `t`.
- Changed `String.exists` and `String.for_all` to iterate by
  increasing index rather than decreasing.
- Added `with compare` to module `Ref`.
- Made `Flags` be `Comparable`, with the order consistent with bitwise
  subset.
- Cleaned up the implementation of `Union_find`.

  Improvemed the code in `union_find.ml`:

  * Removed an assert false.
  * do not reallocate a parent node during compress. This should
    result in more stability for sets memory wise.
  * Added implementation notes.
  * Renamed internal variant constructors.
  * Added unit tests.
- Added `Float.O`, a sub-module intended to be used with local opens.

  The idea is to be able to write expressions like:

  ```ocaml
  Float.O.((3. + 4.) > 6. / 2.)
  ```

  This idiom is expected to be extended to other modules as well.
- Added a `sexp_of_t` converter to `Type_equal.Id`.
- Replaced `Univ.Constr` with `Type_equal.Id`.
- Added `Debug.eprintf`, analogous to `eprint` and `eprints`.

## 109.47.00

- Added `Error.to_info` and `of_info`.
- Significantly sped up `Float.iround_*` functions.

  For `iround_down_exn`, the new version appears to use about 25% of the
  CPU time of the old version on non-negative floats.  For negative
  floats it uses around 60% of the CPU time.

  | Name                    | Time (ns) | % of max |
  |-------------------------|-----------|----------|
  | old iround_down_exn pos |     15.02 |    95.23 |
  | new iround_down_exn pos |      3.75 |    23.75 |
  | old iround_down_exn neg |     15.78 |   100.00 |
  | new iround_down_exn neg |      9.80 |    62.10 |
- Added `Binary_searchable.Make` functor to core, and used it in `Array` and `Dequeue`.
- Fixed `Bounded_int_table` to match `Invariant.S2`.
- Added to `Pool` support for `10-`, `11-`, and `12-` tuples.
- Added functions to the `Gc` module to get usage information without allocating.

  Added these functions, all of type `unit -> int`:

  ```
  minor_collections
  major_collections
  heap_words
  heap_chunks
  compactions
  top_heap_words
  ```

  They all satisfy:

  ```ocaml
  Gc.f () = (Gc.quick_stat ()).Gc.Stat.f
  ```

  They all avoid the allocation of the stat record, so one can monitor
  the garbage collector without perturbing it.

## 109.45.00

- Changed `Blang.bind` to short-circuit `And`, `Or`, and `If`
  expressions.

  For example if `bind t1 f ` false`, then `bind (and_ t1 t2) `
  false`, and will not evaluate `bind t2 f`.

- Renamed `Dequeue.get` as `get_opt`, and `get_exn` as `get`, to be
  consistent with other containers which don't use the `_exn` suffix
  for subscripting exceptions.
- Removed `Source_code_position.to_sexp_hum`, in favor of
  `sexp_of_t_hum`, which works smoothly with `with sexp`.
- Changed `Flat_queue_unit_tests` to run `Flat_queue.invariant`, which
  was mistakenly not being used.

## 109.44.00

- Implemented `Dequeue.iter` directly, instead of as a specialization
  of `fold`.

  Extended random tests to cover `iter`.

## 109.42.00

- Added `Array.is_sorted_strictly` and `List.is_sorted_strictly`.

  ```ocaml
  val is_sorted_strictly : 'a t -> cmp:('a -> 'a -> int) -> bool
  ```

- Added `Array.find_consecutive_duplicate` and `List.find_consecutive_duplicate`.

  ```ocaml
  val find_consecutive_duplicate : 'a t -> equal:('a -> 'a -> bool) -> ('a * 'a) option
  ```

- Added `Array.truncate`, which changes (shortens) the length of an array.

  ```ocaml
  val truncate : _ t -> len:int -> unit
  ```

- Improved the debugging message in `Bounded_int_table.remove` to show the data structure's details.

- Added `Float.iround_lbound` and `iround_ubound`, the bounds for rounding to `int`.

- Added `Hashtbl.similar`, which is like `equal`, but allows the types of the values in the two tables to differ.

- Added `Pool.Pointer.phys_compare`, which is analagous to `phys_equal`, and does not require an argument comparison function.

  ```ocaml
  val phys_compare : 'a t -> 'a t -> int
  ```
- Exposed that `Pool.Debug`'s output types are the same as its input types.

## 109.41.00

- Added `Map.of_alist_reduce`.

  This function is a natural addition alongside `of_alist_fold`.  Its
  advantage is that it does not require an `init` argument like
  `of_alist_fold`.  Moreover, it does not involve `option` types, like
  `List.reduce` does in order to handle the empty list case.

## 109.39.00

- Implemented `Heap.iter` directly instead of in terms of `fold`.

## 109.37.00

- Added Core.Std.Poly as a short name for
  Core.Std.Polymorphic_compare.
- Exposed module Core.Std.Decimal.

## 109.36.00

- Made `Hashtbl.Poly.hash` equal `Caml.Hashtbl.hash`, and changed changed `String.hash` and `Float.hash` to match OCaml's hash function.

  Previously, `Core.Poly.hash` had been defined as:

  ```ocaml
  let hash x = hash_param 10 100 x
  ```

  This fell out of sync with OCaml's hash function, and was providing worse hash values.

- Fixed `Obj_array.singleton` to never create a float array.

  Also made it clearer that `Obj_array.copy` could never create a float
  array.

- Changed `Pool.create` to allow zero-length pools.

  Previously, `Pool.create ~capacity:0` had raised, which made it easy
  to write code that blows up on edge cases for no apparent reason.  For
  example, `Heap.copy` was written in a way that copying an empty heap
  would blow up (regardless of its capacity), and `Heap.of_array` would
  also blow up on an empty array.

- Added `String.split_lines`.

  ```ocaml
  (** [split_lines t] returns the list of lines that comprise [t].  The lines do
      not include the trailing ["\n"] or ["\r\n"]. *)
  val split_lines : t -> t list
  ```

## 109.35.00

- Added `with compare` to `List.Assoc.t`.
- Made `Pooled_hashtbl.create` handle non-positive and very large
  `size`s in the same way as `Core.Hashtbl`.
- Added `is_error`, `is_ok`, and `does_raise` to `Core.Std`.

  ```ocaml
  let is_error ` Result.is_error
  let is_ok    ` Result.is_ok
  val does_raise : (unit -> _) -> bool
  ```
- Reimplemented `Heap` and reworked the interface to be more standard.

  The new implementation uses pairing heaps and `Pool`.
- Added a module `Pool.Unsafe`, which is like `Pool`, except that
  `create` doesn't require an initial value.

  This makes it unsafe to access pool pointers after they have been
  freed.  But it is useful for situations when one isn't able to
  create an initial value, e.g. `Core.Heap`.
- Removed `Time.to_localized_string` and `Time.to_string_deprecated`.

  These did not include the time-zone offset.  Instead, use
  `Time.to_string` and `Time.to_string_abs`, which do include the
  time-zone offset.
- Exposed that `Int63.t = private int` on 64-bit machines.

  This lets the OCaml compiler avoid `caml_modify` when dealing with
  it.
- Added `Gc` stat functions that don't allocate: `Gc.minor_words`,
  `Gc.major_words`, `Gc.promoted_words`.

  Added the following `Gc` functions:

  ```ocaml
  Gc.minor_words : unit -> int
  Gc.major_words : unit -> int
  Gc.promoted_words : unit -> int
  ```

  such that these functions cause no allocations by themselves. The
  assumption being that 63-bit ints should be large enough to express
  total allocations for most programs.  On 32-bit machines the numbers
  may overflow and these functions are not as generally useful.

  These functions were added because doing memory allocation debugging
  with `Gc.quick_stat` as the primary means of understanding
  allocations is difficult: tracking down allocations of the order of
  a few hundred words in a hot loop by putting in lots of `quick_stat`
  statements becomes too intrusive because of the memory allocations
  they cause.

  Here are some benchmarks of existing `Gc` functions and the newly
  added functions:

  ```
  $ ./test_bench.exe -q 2 -clear name time +alloc +time-err
  Estimated testing time 12s (change using -quota SECS).
  ```

  | Name            | Time (ns) |      95% ci | Time R^2 | Minor |
  |-----------------|-----------|-------------|----------|-------|
  | quick_stat      |     92.16 | +0.72 -0.64 |     1.00 | 23.00 |
  | counters        |     33.63 | +0.26 -0.23 |     1.00 | 10.00 |
  | allocated_bytes |     37.89 | +0.34 -0.32 |     1.00 | 12.00 |
  | minor_words     |      4.63 | +0.03 -0.02 |     1.00 |       |
  | major_words     |      4.36 | +0.02 -0.02 |     1.00 |       |
  | promoted_words  |      4.10 | +0.03 -0.02 |     1.00 |       |

## 109.34.00

- Added a new module, `Flat_queue`, which is a queue of flat tuples.

  This is essentially:

  ```ocaml
  ('a1 * .. * 'aN) Queue.t
  ```

  However the queue is implemented as a `Flat_array`, so the tuples are layed out
  flat in the array and not allocated.

- Improved `Bounded_int_table.remove`'s error message when it detects an internal inconsistency.

- Added new `Debug` module.

- Changed `Invariant.invariant` to take `_here_` rather than a string.

- Made `Float` satisfy the `Identifiable` interface.

## 109.32.00

- Added `val Option.merge: 'a t -> 'a t -> f:('a -> 'a -> 'a) -> 'a t`.

- Added `val Validate.failf : ('a, unit, string, t) format4 -> 'a`.

- In `Validated.Make_binable`, made it possible to apply the validation function when un-bin-io-ing a value.

- Added `module Pooled_hashtbl` to `module type Hashable`.

  This is an alternative implementation to `Core.Hashtbl`.  It uses a
  standard linked list to resolve hash collisions, and `Pool` to manage
  the linked-list nodes.

## 109.31.00

- Renamed some functions in module `Lazy`: dropped the `lazy_` prefix from `is_val`, `from_val`, and `from_fun`.

## 109.30.00

  - Added module, `Core.Blit`, which codifies the type, implementation, and unit-testing of blit functions.

  - Added `remove_zero_flags` option to `Flags.Make`, to support flags that are zero.

    This fixes a problem with `Flags.Make` on CentOS 5 because `O_CLOEXEC` is `0` there.

  - Removed `Pool.None`, and folded `Pool.Obj_array` into `Pool` proper.

    `Pool.None` had its day, but `Pool.Obj_array` dominates it, so we don't need it any more.

## 109.28.00

- Moved all the contents of the `Zero` library into `Core`, mostly
  into `Core_kernel`.

  We want to start using `Zero` stuff more in `Core`, which couldn't
  be done with `Zero` as a separate library.

  Everything moved into `Core_kernel`, except for `Timing_wheel`,
  which moved into `Core` proper, due to its dependence on `Time`.
- Renamed `Flat_tuple_array` as `Flat_array`.
- Added `Dequeue.{front,back}_index_exn`

  These are more efficient than using `{front,back}_index` and then
  `Option.value_exn`.
- Exposed `Core.String.unsafe_{get,set}`.

