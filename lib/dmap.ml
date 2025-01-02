module M = Map.Make(String)

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

let shift s void dmap = {
  map =
    M.fold
      (fun k v acc ->
         M.add
           (s ^ k)
           v
           acc)
      dmap.map
      (M.singleton s dmap.dflt);
  dflt = void;
}

let union f dm1 dm2 = {
  map = M.union
      (fun _k v1 v2 -> f v1 v2)
      dm1.map
      dm2.map;
  dflt = dm2.dflt;
}

let fold f dm accf = M.fold f dm.map (accf dm.dflt)
