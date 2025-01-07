module type S = sig
  type k

  type 'a t

  val pure : 'a -> 'a t

  val map : ('a -> 'b) -> 'a t -> 'b t

  val map2 : ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t

  val shift : (k option -> k) -> 'a -> 'a t -> 'a t

  val union : ('a -> 'a -> 'a option) -> 'a t -> 'a t -> 'a t

  val fold : (k -> 'a -> 'acc -> 'acc) -> 'a t -> ('a -> 'acc) -> 'acc
end

module Make (K : Map.OrderedType) : S with type k = K.t = struct

      module M = Map.Make(K)

      type k = K.t

      type 'a t = {
        map : 'a M.t;
        dflt : 'a;
      }

      let pure x = {
        map = M.empty;
        dflt = x;
      }

      let map f dmap = {
        map = M.map f dmap.map;
        dflt = f dmap.dflt;
      }

      let map2 f m1 m2 = {
        map =
          M.merge
            (fun _k v1 v2 ->
               match (v1, v2) with
               | None, None -> None
               | Some s1, None -> Some (f s1 m2.dflt)
               | None, Some s2 -> Some (f m1.dflt s2) 
               | Some s1, Some s2 -> Some (f s1 s2))
            m1.map
            m2.map;
        dflt = f m1.dflt m2.dflt;
      }

      let shift kf fail dm = {
        map =
          M.fold
            (fun k v acc ->
               M.add
                 (kf (Some k))
                 v
                 acc)
            dm.map
            (M.singleton (kf None) dm.dflt);
        dflt = fail;
      }

      let union f dm1 dm2 = {
        map = M.union
            (fun _k v1 v2 -> f v1 v2)
            dm1.map
            dm2.map;
        dflt = dm2.dflt;
      }

      let fold f dm accf = M.fold f dm.map (accf dm.dflt)

    end
