lib: {
  mkUsersOption =
    name:
    lib.mkOption {
      default = null;
      example = [ "austin" ];
      description = "The users (usernames) to enable for ${name}.";
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
    };

  perUser =
    users: value:
    (lib.pipe users [
      (map (name: {
        inherit name;

        value = if builtins.isFunction value then value name else value;
      }))
      builtins.listToAttrs
    ]);

  mkUsers =
    config: name:
    let
      cfg = config.common.nixos-hm.${name};
      rootCfg = config.common.nixos-hm;
    in
    if cfg.users != null then
      cfg.users
    else if rootCfg.users != null then
      rootCfg.users
    else
      [ ];
}
