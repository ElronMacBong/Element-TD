var free_towers = $("#free_towers")
var god_mode = $("#god_mode")

function ToggleFreeTowers() {
    GameEvents.SendCustomGameEventToServer( "sandbox_toggle_free_towers", { "state": free_towers.checked } );
}

function ToggleGodMode() {
    GameEvents.SendCustomGameEventToServer( "Sandbox_toggle_god_mode", { "state": god_mode.checked } );
}