(*
 * Copyright (c) 2018 - present Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *)

open! IStd
module F = Format

(** Access path + its parent procedure *)
module LocalAccessPath : sig
  type t = private {access_path: AccessPath.t; parent: Typ.Procname.t} [@@deriving compare]

  val make : AccessPath.t -> Typ.Procname.t -> t

  val to_formal_option : t -> FormalMap.t -> t option

  val pp : F.formatter -> t -> unit
end

(** Called procedure + its receiver *)
module MethodCall : sig
  type t = private {receiver: LocalAccessPath.t; procname: Typ.Procname.t} [@@deriving compare]

  val make : LocalAccessPath.t -> Typ.Procname.t -> t

  val pp : F.formatter -> t -> unit
end

module CallSet : module type of AbstractDomain.FiniteSet (MethodCall)

include module type of AbstractDomain.Map (LocalAccessPath) (CallSet)

val substitute : f_sub:(LocalAccessPath.t -> LocalAccessPath.t option) -> astate -> astate
(** Substitute each access path in the domain using [f_sub]. If [f_sub] returns None, the
    original access path is retained; otherwise, the new one is used *)

val iter_call_chains_with_suffix :
  f:(AccessPath.t -> Typ.Procname.t list -> unit) -> MethodCall.t -> astate -> unit
(** Unroll the domain to enumerate all the call chains ending in [call] and apply [f] to each
    maximal chain. For example, if the domain encodes the chains foo().bar().goo() and foo().baz(),
    [f] will be called once on foo().bar().goo() and once on foo().baz() *)

val iter_call_chains : f:(AccessPath.t -> Typ.Procname.t list -> unit) -> astate -> unit
(** Apply [f] to each maximal call chain encoded in [astate] *)
