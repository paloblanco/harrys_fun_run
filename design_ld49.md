# Game for LD49
Theme: Unstable

Game Descrition: 
- 3d platformer 
- Summary: 3d version-ish of hungry harry's climb, jam version
- Abilities:
    - jump
    - run button *(tied to stamina?)*
    - wall jump-climb like megamanX
- Goal:
    - get to the end of levels (point A to B)
    - if you fall below the kill plane, gameover
    - *Extra - if you touch a hazard, you are knocked around and stunned*
- Levels:
    - tall rectangles - should look like skyscrapers, but the theme is actually mountains/desert, so tall rocks. Think utah.
    - When you touch a rectangle, it starts falling down. Maybe slower depending on size?
    - Kill plane is a floor, should look like clouds. If you fall below it you are dead.
    - goal is a finish line flag hooked on a cactus
- Game structure:
    - 4 levels, should take 90ish seconds each
        - tell player they have won after 4 levels, but they can keep going.
    - procedural (I might hardcode the first one to get some ideas)
    - *extra - tutorial level starts on the ground, so there is no pressure. most rocks dont fall here. game proper starts when you reach some point in the tutorial level*
    - code:
        - use level files like devil game
        - level 1 can then be hardcoded, other levels can use a randomization script
        - keep level making logic out of core game code

## TODO:
### MVP
- draw a main character
- main character code
    - just missing walljump ability
- level drawing
    - need some indicator of kill plane. maybe transparent spheres? Maybe just a texture? Just an ugly plane to start
- Goal item
- touching goal item triggers level transitions
- Title card
- Block types
    - blocks that fall or dont fall, or on a timer
    - character should fall with blocks when standing on blocks
- Randomization code
    - starter should just be a checkerboard-like area, with blocks of different heights (and sizes)
        - the further a square is from the end block (manhattan distance) the shorter it is
        - kill plane should be a good deal below the starter block
    - the checkerboard should get longer with each level
    - *maybe the checkerboard has turns in it at later levels?*
- Sounds
    - title music
    - snd effects
    

### Extra
- cool skybox
- collectibles
- enemies that stun you
- level music
- beter shaders

