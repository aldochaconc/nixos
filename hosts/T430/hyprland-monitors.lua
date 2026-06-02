-- ThinkPad T430: single built-in LVDS panel, 1366x768 @60Hz.
-- The catch-all "" rule covers the internal display and any hot-plugged
-- external monitor (HDMI/VGA/MiniDP) at its preferred mode. No persistent
-- workspace_rules — workspaces follow the focused monitor.
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})
