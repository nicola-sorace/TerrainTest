This project started off as an attempt to store and load a 3d map from an image, using threaded continuous terrain loading.

The image data is divided into a series of tiles. Tiles that are further away from the player are built using fewer polygons, by sampling every nth pixel. Mesh data for each tile is recalculated in a threaded way as the player moves around the map. If mesh generation begins to lag too far behind, threading is abbandonned and the game freezes until an acceptable state is reached. This ensures that the player never reaches a low-poly area.

This project has since grown into the start of an open-world fantasy video game. An inventory system, NPCs, spell casting, a questing system and more have already been implemented.
