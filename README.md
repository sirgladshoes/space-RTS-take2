## Space RTS

Multiplayer PvP RTS using a custom multiplayer architecture built in Godot.
Play with up to 5 friends, commanding your spaceships to mine resources, defeat alien ships, and destroy the opposing team.

<img width="1776" height="974" alt="Screenshot 2026-08-12 111629" src="https://github.com/user-attachments/assets/d40eefb8-974a-4693-93df-546611f66564" />

## Features

- Server-authoritative game state.
- Network interpolation for smoother gameplay.
- UPnP for automatic port forwarding.
- Resource gathering and management.
- Context-based, one-button command system.
- Real-time ship combat.
- Team-based neutral objectives.

<img width="1920" height="1080" alt="demo" src="https://github.com/user-attachments/assets/4afd6cb4-bc48-45f0-a4dc-678713c785df" />


## Controls

- Left mouse to select units, shift to add to selection, drag to multiselect.
- Right mouse to give units commands: move, attack, mine, transfer resources.
- Scroll wheel for zoom, hold down for pan.

<img width="1920" height="1080" alt="2026-08-12 11-33-07" src="https://github.com/user-attachments/assets/0d6196a2-5723-47e8-9999-d4b4d2bbd940" />

## Technical Details

The networking system uses `networked_object` nodes attached to synced objects to handle state serialization.

The `Network` autoload keeps track of all `networked_object` nodes and collects their declared synchronized variables for transmission.
`Network` takes these variables and encodes them to a single byte array, which is then transmitted via Godot's RPC system.

Each `networked_object` defines:
- Which variables should be synchronized.
- The data type used to encode each variable.
- Whether the variable should use interpolation.
- Whether angle interpolation should be used.
- Optional getter and setter functions.

The game runs server-side, where state is compiled and pushed to clients. 
Clients send unit commands to the server, which processes them and updates the game state.


## Music

- Music in-game is from AlkaKrab's Sci-Fi music pack, and is not included here.
- If compiling from source, add a music folder and drop the music pack's MP3 files into it.

## Tools
- Godot 4.
- GDScript.
- Git / GitHub.
- Audacity.
