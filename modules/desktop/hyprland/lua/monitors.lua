-- Generic fallback used when a host does not provide its own
-- `hosts/<host>/hyprland-monitors.lua`. Single monitor, preferred mode,
-- scale 1, no persistent workspace_rules. See default.nix for the lookup.
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})
