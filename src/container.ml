open With_return

include Container_intf

type ('t, 'a, 'accum) fold = 't -> init:'accum -> f:('accum -> 'a -> 'accum) -> 'accum
type ('t, 'a) iter = 't -> f:('a -> unit) -> unit

let iter ~fold t ~f = fold t ~init:() ~f:(fun () a -> f a)

let count ~fold t ~f = fold t ~init:0 ~f:(fun n a -> if f a then n + 1 else n)

let sum (type a) ~fold (module M : Commutative_group.S with type t = a) t ~f =
  fold t ~init:M.zero ~f:(fun n a -> M.(+) n (f a))
;;

let min_elt ~fold t ~cmp =
  fold t ~init:None ~f:(fun acc elt ->
    match acc with
    | None -> Some elt
    | Some min -> if cmp min elt > 0 then Some elt else acc)
;;

let max_elt ~fold t ~cmp =
  fold t ~init:None ~f:(fun acc elt ->
    match acc with
    | None -> Some elt
    | Some max -> if cmp max elt < 0 then Some elt else acc)
;;

let length ~fold c = fold c ~init:0 ~f:(fun acc _ -> acc + 1)

let is_empty ~iter c =
  with_return (fun r ->
    iter c ~f:(fun _ -> r.return false);
    true)
;;

let exists ~iter c ~f =
  with_return (fun r ->
    iter c ~f:(fun x -> if f x then r.return true);
    false)
;;

let mem ~iter ?(equal = (=)) t a = exists ~iter t ~f:(equal a)

let for_all ~iter c ~f =
  with_return (fun r ->
    iter c ~f:(fun x -> if not (f x) then r.return false);
    true)
;;

let find_map ~iter t ~f =
  with_return (fun r ->
    iter t ~f:(fun x -> match f x with None -> () | Some _ as res -> r.return res);
    None)
;;

let find ~iter c ~f =
  with_return (fun r ->
    iter c ~f:(fun x -> if f x then r.return (Some x));
    None)
;;

let to_list ~fold c = List.rev (fold c ~init:[] ~f:(fun acc x -> x :: acc))

let to_array ~fold c = Array.of_list (to_list ~fold c)

module Make (T : Make_arg) : S1 with type 'a t := 'a T.t = struct
  let fold = T.fold

  let iter =
    match T.iter with
    | `Custom iter       -> iter
    | `Define_using_fold -> fun t ~f -> iter ~fold t ~f
  ;;

  let length t       = length   ~fold t
  let is_empty t     = is_empty ~iter t
  let sum m t        = sum      ~fold m t
  let count t ~f     = count    ~fold t ~f
  let exists t ~f    = exists   ~iter t ~f
  let for_all t ~f   = for_all  ~iter t ~f
  let find_map t ~f  = find_map ~iter t ~f
  let find t ~f      = find     ~iter t ~f
  let to_list t      = to_list  ~fold t
  let to_array t     = to_array ~fold t
  let mem ?equal t a = mem      ~iter ?equal t a
  let min_elt t ~cmp = min_elt  ~fold t ~cmp
  let max_elt t ~cmp = max_elt  ~fold t ~cmp
end

open T


(* The following functors exist as a consistency check among all the various [S?]
   interfaces.  They ensure that each particular [S?] is an instance of a more generic
   signature. *)
module Check (T : T1) (Elt : T1)
  (M : Generic with type 'a t := 'a T.t with type 'a elt := 'a Elt.t) = struct end

module Check_S0 (M : S0) =
  Check (struct type 'a t = M.t end) (struct type 'a t = M.elt end) (M)

module Check_S0_phantom (M : S0_phantom) =
  Check (struct type 'a t = 'a M.t end) (struct type 'a t = M.elt end) (M)

module Check_S1 (M : S1) =
  Check (struct type 'a t = 'a M.t end) (struct type 'a t = 'a end) (M)

type phantom

module Check_S1_phantom (M : S1_phantom) =
  Check (struct type 'a t = ('a, phantom) M.t end) (struct type 'a t = 'a end) (M)

module Check_S1_phantom_invariant (M : S1_phantom_invariant) =
  Check (struct type 'a t = ('a, phantom) M.t end) (struct type 'a t = 'a end) (M)
