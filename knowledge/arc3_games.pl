/*  Mentova — ARC-AGI-3 Game Environment Understood Facts  (heavy-pass data)

    The 25 ARC-AGI-3 game guides in the assets folder, distilled into structured,
    game-keyed facts: what each game is, what the player controls, its objects,
    its cause-and-effect relations, its hazards, and mentor tips. Every fact
    carries an a3_guide/2 citation to the plain-text guide it came from, so the
    honest answer to "why does Mentova believe this?" cites a real file.

    Loaded and anchored into the lattice, Causalontology, and J-Space by
    arc3_knowledge.pl. Predicates:
      a3_guide(Id, Path).                    -- the source guide file per game
      a3_game(Id, Name, Genre, WinLevels).   -- the game's identity
      a3_control(Id, Scheme, Actions).       -- the control scheme + action set
      a3_object(Id, Object, Role).           -- an object and its role
      a3_rel(Id, Cause, Effect).             -- a cause-effect relation (-> a CRO)
      a3_hazard(Id, Hazard).                 -- a thing that ends or resets a run
      a3_tip(Id, Text).                      -- a mentor tip
      a3_note(Id, Key, Value).               -- a fact (difficulty, solvability)

    Games with publicly-undocumented mechanics (wa30, tr87, lf52, sc25) carry
    only what is sourced or observed; their unknowns are recorded honestly.
*/

% Declare the generated data predicates so a bare load never errors.
:- module(arc3_games, [a3_guide/2, a3_game/4, a3_control/3, a3_object/3,
                       a3_rel/3, a3_hazard/2, a3_tip/2, a3_note/3]).

% Allow every ARC-AGI-3 knowledge predicate to be inspected at runtime.
:- dynamic a3_guide/2, a3_game/4, a3_control/3, a3_object/3,
           a3_rel/3, a3_hazard/2, a3_tip/2, a3_note/3.

% ---- The guide files (citations) ----
% Each game's plain-text mentor guide, the source of its facts below.
a3_guide(ls20, 'assets/ls20.txt').
a3_guide(ft09, 'assets/ft09.txt').
a3_guide(vc33, 'assets/vc33.txt').
a3_guide(bp35, 'assets/bp35.txt').
a3_guide(r11l, 'assets/r11l.txt').
a3_guide(tu93, 'assets/tu93.txt').
a3_guide(ka59, 'assets/ka59.txt').
a3_guide(lp85, 'assets/lp85.txt').
a3_guide(sp80, 'assets/sp80.txt').
a3_guide(cn04, 'assets/cn04.txt').
a3_guide(dc22, 'assets/dc22.txt').
a3_guide(tn36, 'assets/tn36.txt').
a3_guide(su15, 'assets/su15.txt').
a3_guide(sb26, 'assets/sb26.txt').
a3_guide(g50t, 'assets/g50t.txt').
a3_guide(re86, 'assets/re86.txt').
a3_guide(wa30, 'assets/wa30.txt').
a3_guide(cd82, 'assets/cd82.txt').
a3_guide(lf52, 'assets/lf52.txt').
a3_guide(sc25, 'assets/sc25.txt').
a3_guide(tr87, 'assets/tr87.txt').
a3_guide(ar25, 'assets/ar25.txt').
a3_guide(m0r0, 'assets/m0r0.txt').
a3_guide(s5i5, 'assets/s5i5.txt').
a3_guide(sk48, 'assets/sk48.txt').

% ===========================================================================
% ls20 — Locksmith (transform a key to match a lock, deliver to the exit)
% ===========================================================================
% The game's identity: a transform-and-deliver lock-and-key puzzle, 7 levels.
a3_game(ls20, 'Locksmith', transform_deliver, 7).
% Controls: four-direction movement.
a3_control(ls20, move4, [action(1),action(2),action(3),action(4)]).
% The block you carry is the key.
a3_object(ls20, key_block, avatar).
% Changer tiles cycle one property of the key.
a3_object(ls20, changer, tool).
% The target door requires a matching key.
a3_object(ls20, target_door, target).
% Rings refill the step timer.
a3_object(ls20, ring, collectible).
% Pushers shove the block toward a wall.
a3_object(ls20, pusher, hazard).
% Stepping on a changer cycles one of the key's properties.
a3_rel(ls20, step_on(changer), cycle(key_property)).
% Stepping on a ring refills the step timer.
a3_rel(ls20, step_on(ring), refill(timer)).
% Delivering a matching key onto the target wins the level.
a3_rel(ls20, deliver(matching_key, target), win(level)).
% The timer reaching zero resets the block and its properties.
a3_rel(ls20, timer_zero, reset(block)).
% Contact with a pusher shoves the block several cells.
a3_rel(ls20, contact(pusher), shove(block)).
% The timer running out is the failure mode.
a3_hazard(ls20, timer_runs_out).
% Teach the route one waypoint at a time: changer first, then target.
a3_tip(ls20, 'aim one waypoint at a time — first a changer to fix the key, then the target door').
% Grab a ring before the timer bites.
a3_tip(ls20, 'collect a ring to refill the step timer before it runs out').
% Public solvers clear all seven levels — it is winnable.
a3_note(ls20, solvable, yes).

% ===========================================================================
% ft09 — Functional Tiles / Lights Out (align tiles to a target; parity logic)
% ===========================================================================
% Identity: a static Lights-Out logic puzzle, 6 levels, no avatar.
a3_game(ft09, 'Functional Tiles', logic_puzzle, 6).
% Controls: click only.
a3_control(ft09, click, [action(6)]).
% Cells toggle through colours when clicked.
a3_object(ft09, toggle_cell, control).
% Clue cells are fixed hints to satisfy.
a3_object(ft09, clue_cell, target).
% Clicking a cell toggles it and a fixed neighbourhood.
a3_rel(ft09, click(cell), toggle(cell_and_neighbours)).
% Reaching the target pattern wins the level.
a3_rel(ft09, match(target_pattern), win(level)).
% It is a linear system over GF(2) — the click-set determines the result.
a3_note(ft09, method, 'solve as a parity system; the SET of cells clicked matters, not order').
% Do not wander — work out which cells to click.
a3_tip(ft09, 'teach the specific cells to click; exploring wastes the step budget').
% Two independent solvers fully clear it.
a3_note(ft09, solvable, yes).

% ===========================================================================
% vc33 — Volume Control / Orchestration (coordinate many objects by clicking)
% ===========================================================================
% Identity: a click-driven orchestration puzzle, 7 levels, no single avatar.
a3_game(vc33, 'Volume Control', orchestration, 7).
% Controls: click only.
a3_control(vc33, click, [action(6)]).
% Markers are carried to goal positions.
a3_object(vc33, marker, avatar).
% Goal positions the markers must reach.
a3_object(vc33, goal_slot, target).
% Clicking transfers or moves objects between positions.
a3_rel(vc33, click(object_then_destination), transfer(object)).
% Getting all objects into the goal arrangement wins the level.
a3_rel(vc33, arrange(all_objects), win(level)).
% The solution is an ordered click sequence — order matters.
a3_note(vc33, method, 'an ordered sequence of clicks; teach one transfer at a time').
% Reduce the huge click space to a few salient targets.
a3_tip(vc33, 'point Mentova at which cells matter and in what order — the click space is 4096 cells').
% A community solver clears all seven levels.
a3_note(vc33, solvable, yes).

% ===========================================================================
% bp35 — Platform / Gravity (build support, flip gravity; one of the hardest)
% ===========================================================================
% Identity: a physics/platform puzzle, 9 levels, among the two hardest.
a3_game(bp35, 'Platform-Gravity', physics_platform, 9).
% Controls: two directional keys, click, and undo.
a3_control(bp35, move_click_undo, [action(3),action(4),action(6),action(7)]).
% A piece is routed to a goal under gravity.
a3_object(bp35, piece, avatar).
% Support blocks are placed or removed by clicking.
a3_object(bp35, support_block, tool).
% Toggle gates open and close paths.
a3_object(bp35, gate, barrier).
% The goal the piece must reach.
a3_object(bp35, goal, target).
% Clicking builds or destroys a support block at a cell.
a3_rel(bp35, click(cell), build_or_destroy(support_block)).
% Gravity pulls the piece; on some levels it flips direction.
a3_rel(bp35, gravity, pull(piece)).
% Routing the piece to the goal wins the level.
a3_rel(bp35, reach(goal), win(level)).
% The failure mode is running out of the step budget on a hard level.
a3_hazard(bp35, budget_runs_out).
% Undo freely after a bad build.
a3_tip(bp35, 'use undo (ACTION7) after a wrong build; teach one level of construction at a time').
% Humans solve it only ~14% — expect slow going.
a3_note(bp35, difficulty, very_hard).
% A community solver clears all nine levels.
a3_note(bp35, solvable, yes).

% ===========================================================================
% r11l — Centroid / carrier delivery (THE easiest game; deliver fragments)
% ===========================================================================
% Identity: a click carrier-delivery puzzle, 6 levels, the easiest game.
a3_game(r11l, 'Centroid-Carrier', carrier_delivery, 6).
% Controls: click only.
a3_control(r11l, click, [action(6)]).
% Coloured fragments are carried to targets.
a3_object(r11l, fragment, avatar).
% Matching-colour targets to deliver to.
a3_object(r11l, target, target).
% Some intermediate states are lethal.
a3_object(r11l, hazard_state, hazard).
% Clicking a fragment then its matching target delivers it.
a3_rel(r11l, click(fragment_then_target), deliver(fragment)).
% Delivering all fragments to matching targets wins the level.
a3_rel(r11l, deliver(all_fragments), win(level)).
% Passing through a hazardous state loses.
a3_hazard(r11l, unsafe_state).
% Click a fragment, then its same-colour target, avoiding bad squares.
a3_tip(r11l, 'click a fragment then its matching-colour target; keep to safe intermediate states').
% Every tested human solved it — the best first Solo candidate.
a3_note(r11l, difficulty, easiest).
% A community solver clears all six levels in 73 actions.
a3_note(r11l, solvable, yes).

% ===========================================================================
% tu93 — Arrow-Swarm (each arrow shifts a field of objects; plan a route)
% ===========================================================================
% Identity: a keyboard board-motion swarm puzzle, 9 levels.
a3_game(tu93, 'Arrow-Swarm', board_motion, 9).
% Controls: four-direction movement.
a3_control(tu93, move4, [action(1),action(2),action(3),action(4)]).
% Follower objects trail your motion.
a3_object(tu93, follower, avatar).
% Delayed objects move one step behind.
a3_object(tu93, delayed_object, avatar).
% Target fragments the pieces must reach.
a3_object(tu93, target_fragment, target).
% An arrow press shifts many objects at once.
a3_rel(tu93, press(arrow), shift(board)).
% Landing pieces on their targets wins the level.
a3_rel(tu93, land(pieces, targets), win(level)).
% The winning play is a shortest move sequence found by search.
a3_note(tu93, method, 'plan a route (A* over board states); account for the one-step delay').
% Teach the route, not single steps.
a3_tip(tu93, 'aim the swarm at a target and press to shift the whole field toward it').
% A community solver clears all nine levels.
a3_note(tu93, solvable, yes).

% ===========================================================================
% ka59 — Push-shape-into-frame (push pieces to seat them; dodge enemies)
% ===========================================================================
% Identity: a push-to-seat puzzle with enemies, 7 levels.
a3_game(ka59, 'Push-to-Seat', push_puzzle, 7).
% Controls: four-direction move plus click-to-select.
a3_control(ka59, move_click, [action(1),action(2),action(3),action(4),action(6)]).
% A cursor-box you select and move.
a3_object(ka59, cursor_box, avatar).
% Frames each need their matching piece seated inside.
a3_object(ka59, frame, target).
% Enemies chase and are lethal on contact.
a3_object(ka59, enemy, hazard).
% Blast tiles shove pieces in a direction.
a3_object(ka59, blast_tile, hazard).
% Clicking selects which cursor-box is active.
a3_rel(ka59, click(box), select(active_box)).
% Moving into a piece pushes it.
a3_rel(ka59, move_into(piece), push(piece)).
% Seating every piece in its frame wins the level.
a3_rel(ka59, seat(all_pieces, frames), win(level)).
% An enemy landing on a piece loses instantly.
a3_hazard(ka59, enemy_contact).
% The real mechanic is push-to-seat, NOT click-to-fill.
a3_tip(ka59, 'push each piece into its frame — do not merely click the targets').
% Humans solve it ~30%.
a3_note(ka59, difficulty, hard).

% ===========================================================================
% lp85 — Loop & Pull (click rotate-buttons to align rings of tiles)
% ===========================================================================
% Identity: a click rotation puzzle, 8 levels.
a3_game(lp85, 'Loop-and-Pull', rotation_puzzle, 8).
% Controls: click only.
a3_control(lp85, click, [action(6)]).
% Rotate buttons cyclically shift a group of tiles.
a3_object(lp85, rotate_button, control).
% Goal markers the coloured tiles must land on.
a3_object(lp85, goal_marker, target).
% Clicking a button rotates its whole group one step.
a3_rel(lp85, click(rotate_button), rotate(tile_group)).
% Aligning every coloured tile on its goal marker wins the level.
a3_rel(lp85, align(tiles, goals), win(level)).
% The running-out of the tight click budget loses.
a3_hazard(lp85, budget_runs_out).
% Find the button that changes many cells, then repeat it.
a3_tip(lp85, 'find the button whose click changes many cells, then repeat it to phase the ring into place').
% Level 1 gives only 13 clicks — be frugal.
a3_note(lp85, note, 'level 1 has only 13 clicks; a high-impact button click was the key to the first-ever solve').

% ===========================================================================
% sp80 — Streaming Purple (arrange bars, pour particles into basins; rotated)
% ===========================================================================
% Identity: a liquid-pouring puzzle with rotated controls, 6 levels.
a3_game(sp80, 'Streaming-Purple', liquid_pour, 6).
% Controls: move, pour (ACTION5), click-select.
a3_control(sp80, move_click, [action(1),action(2),action(3),action(4),action(5),action(6)]).
% Bars and deflectors route the falling stream.
a3_object(sp80, bar, tool).
% Target basins to fill.
a3_object(sp80, basin, target).
% The border, which overflow must not touch.
a3_object(sp80, border, hazard).
% Pressing ACTION5 releases the particle stream.
a3_rel(sp80, press(release), pour(particles)).
% Filling all basins without overflow wins the level.
a3_rel(sp80, fill(all_basins), win(level)).
% Flow touching the border overflows and loses.
a3_hazard(sp80, overflow).
% On rotated levels, your movement inputs are inverted.
a3_note(sp80, note, 'levels 2,3,5 are rotated 180 degrees — up becomes down; only 4 pour tries per level').
% Plan placement before touching; level 1 gives only 30 moves.
a3_tip(sp80, 'place the bars before pouring; ACTION5 pours (only 4 tries); avoid the border').

% ===========================================================================
% cn04 — Connect-the-endpoints (orient pieces so their nubs pair up)
% ===========================================================================
% Identity: a circuit-assembly puzzle, ~6 levels.
a3_game(cn04, 'Circuit-Connect', circuit_assembly, 6).
% Controls: move, rotate (ACTION5), click-select.
a3_control(cn04, move_click, [action(1),action(2),action(3),action(4),action(5),action(6)]).
% Shape pieces with connection nubs.
a3_object(cn04, shape_piece, avatar).
% The connection nubs that must pair.
a3_object(cn04, nub, target).
% Clicking selects a shape; ACTION5 rotates it.
a3_rel(cn04, click(shape), select(shape)).
% Two nubs meeting on a cell connect them.
a3_rel(cn04, meet(nub, nub), connect(pair)).
% Pairing every nub wins the level.
a3_rel(cn04, pair(all_nubs), win(level)).
% From level 5 non-selected shapes are hidden — a memory test.
a3_note(cn04, note, 'levels 5+ hide the non-selected shapes; the top bar is only a step counter, not a timer').
% Make every nub meet another; do not over-theorise.
a3_tip(cn04, 'select, rotate, and place each piece so its nub meets a partner; do not invent extra mechanics').

% ===========================================================================
% dc22 — Lock-and-key maze (walk, toggle doors, collect keys, reach exit)
% ===========================================================================
% Identity: a lock-and-key navigation maze, 6 levels — closest cousin of ls20.
a3_game(dc22, 'Toggle-Door Maze', lock_and_key, 6).
% Controls: four-direction move plus click-to-toggle.
a3_control(dc22, move_click, [action(1),action(2),action(3),action(4),action(6)]).
% A small avatar you steer.
a3_object(dc22, avatar, avatar).
% Doors that toggle a barrier open or shut.
a3_object(dc22, door, barrier).
% Keys that permanently unlock matching doors.
a3_object(dc22, key, tool).
% The exit position to reach.
a3_object(dc22, exit, target).
% Clicking a door toggles its barrier open or shut.
a3_rel(dc22, click(door), toggle(barrier)).
% Collecting a key permanently opens its matching door.
a3_rel(dc22, collect(key), unlock(matching_door)).
% Reaching the exit wins the level.
a3_rel(dc22, reach(exit), win(level)).
% Running out of the step budget loses.
a3_hazard(dc22, budget_runs_out).
% Send the avatar to the key first, then the door, then the exit.
a3_tip(dc22, 'go to the key, then its door, then the exit — one waypoint at a time; label keys and doors').
% A BFS solver clears the first four levels.
a3_note(dc22, solvable, partly).

% ===========================================================================
% tn36 — Block-programming (toggle switches to program a block; match target)
% ===========================================================================
% Identity: a visual programming puzzle, 7 levels, indirect control.
a3_game(tn36, 'Block-Program', programming_puzzle, 7).
% Controls: click only.
a3_control(tn36, click, [action(6)]).
% Toggle switches that encode instructions.
a3_object(tn36, switch, control).
% The block that runs the program.
a3_object(tn36, block, avatar).
% The target the block must be transformed to match.
a3_object(tn36, target, target).
% Clicking a switch flips an instruction bit.
a3_rel(tn36, click(switch), set(instruction)).
% Executing the program transforms the block (move/rotate/scale/recolour).
a3_rel(tn36, execute(program), transform(block)).
% Matching the block to the target wins the level.
a3_rel(tn36, match(block, target), win(level)).
% The step counter shrinks per click and halves on late levels.
a3_hazard(tn36, counter_runs_out).
% Program the block indirectly; be frugal with clicks.
a3_tip(tn36, 'each switch programs a move/rotate/scale/recolour; read the target and set the minimal switches').
% Very hard for agents (one solved only 1 of 7).
a3_note(tn36, difficulty, hard).

% ===========================================================================
% su15 — Fruit/enemy grid (click puzzle with 3 enemies and a 64-step clock)
% ===========================================================================
% Identity: a hazard-dense click grid puzzle, 9 levels — dies fast.
a3_game(su15, 'Fruit-Grid', hazard_grid, 9).
% Controls: click plus undo.
a3_control(su15, click_undo, [action(6),action(7)]).
% Graded pieces, keys and goals on the board.
a3_object(su15, piece, avatar).
% Goals to reach.
a3_object(su15, goal, target).
% Three enemy types, lethal on contact.
a3_object(su15, enemy, hazard).
% Clicking acts on the board; undo reverses it.
a3_rel(su15, click(cell), act(board)).
% Contact with an enemy loses.
a3_rel(su15, contact(enemy), lose(game)).
% The 64-step clock running out loses.
a3_hazard(su15, clock_runs_out).
% Enemy contact is lethal.
a3_hazard(su15, enemy_contact).
% Mark the three enemies as hazards; be frugal with the 64-step clock.
a3_tip(su15, 'mark the enemies to avoid; the clock is only 64 steps, so act efficiently and undo waste').
% The most hazard-dense game — expect short runs.
a3_note(su15, difficulty, hard).

% ===========================================================================
% sb26 — Sorting/arrangement (swap tiles into order; no lethal hazards)
% ===========================================================================
% Identity: a click-to-swap sorting puzzle, 8 levels, no lethal hazards.
a3_game(sb26, 'Tile-Sort', sorting_puzzle, 8).
% Controls: verify (ACTION5), click-swap, undo.
a3_control(sb26, click_verify_undo, [action(5),action(6),action(7)]).
% Coloured tiles to reorder.
a3_object(sb26, tile, avatar).
% Target slots the tiles must fill in order.
a3_object(sb26, slot, target).
% Clicking two tiles swaps them.
a3_rel(sb26, click(tile_then_tile), swap(tiles)).
% Pressing verify checks the order and locks correct positions.
a3_rel(sb26, press(verify), check(order)).
% Getting all tiles into the target order wins the level.
a3_rel(sb26, order(all_tiles), win(level)).
% Running the 64 energy out is the only loss.
a3_hazard(sb26, energy_runs_out).
% Read the target order, swap the out-of-place tiles, then verify.
a3_tip(sb26, 'read the target order, swap tiles into place, then verify once; no hazards, so experiment freely').
% Agents solve all eight — a good confidence game.
a3_note(sb26, difficulty, easy).
% Fully solvable.
a3_note(sb26, solvable, yes).

% ===========================================================================
% g50t — Snake navigation (trailing chain, enemies, creeping timer-wall, boxes)
% ===========================================================================
% Identity: a navigation game with a trailing chain and a creeping timer, 7 levels.
a3_game(g50t, 'Snake-Nav', navigation, 7).
% Controls: four-direction move plus a rewind (ACTION5).
a3_control(g50t, move5, [action(1),action(2),action(3),action(4),action(5)]).
% An avatar that drags a follower trail.
a3_object(g50t, avatar, avatar).
% The goal flag to reach.
a3_object(g50t, goal_flag, target).
% Enemies that chase and are lethal.
a3_object(g50t, enemy, hazard).
% A wall/timer that creeps in from the left.
a3_object(g50t, timer_wall, hazard).
% Pushable boxes appear from level 4.
a3_object(g50t, box, barrier).
% Moving steers the avatar and drags its trail.
a3_rel(g50t, press(arrow), move(avatar_and_trail)).
% Reaching the goal flag wins the level.
a3_rel(g50t, reach(goal_flag), win(level)).
% Hitting an enemy loses.
a3_hazard(g50t, enemy_contact).
% The left-creeping timer-wall scrolling off loses.
a3_hazard(g50t, timer_wall_expires).
% Route to the flag efficiently; use rewind to back out of danger.
a3_tip(g50t, 'aim for the flag and hurry; mark enemies and the creeping wall as hazards; push boxes out of the path').

% ===========================================================================
% re86 — Jigsaw reconstruction (slide pieces to match a target; deforming walls)
% ===========================================================================
% Identity: a picture-reconstruction jigsaw, 8 levels.
a3_game(re86, 'Jigsaw', reconstruction, 8).
% Controls: move plus cycle-active-piece (ACTION5).
a3_control(re86, move5, [action(1),action(2),action(3),action(4),action(5)]).
% Movable shape pieces.
a3_object(re86, piece, avatar).
% The target outline the pieces must reproduce.
a3_object(re86, target_outline, target).
% Walls that reshape a piece on contact.
a3_object(re86, deforming_wall, hazard).
% Paint zones that recolour a piece.
a3_object(re86, paint_zone, hazard).
% Sliding pieces to match every target cell wins the level.
a3_rel(re86, assemble(pieces, target), win(level)).
% Hitting a wall deforms the moving piece.
a3_rel(re86, contact(deforming_wall), reshape(piece)).
% Overlapping a paint zone recolours the piece.
a3_rel(re86, overlap(paint_zone), recolour(piece)).
% The step budget running out loses.
a3_hazard(re86, budget_runs_out).
% Plan where each piece must sit; avoid accidental reshapes/recolours.
a3_tip(re86, 'route pieces to their target slots; avoid deforming walls and paint zones unless the transform helps').

% ===========================================================================
% cd82 — Paint/bucket (rotate the container, pour paint to match a target image)
% ===========================================================================
% Identity: a paint-and-pour puzzle, 6 levels — mechanics documented by ARC Prize.
a3_game(cd82, 'Paint-Pour', paint_puzzle, 6).
% Controls: move (ACTION3 rotates), pour (ACTION5), click.
a3_control(cd82, move_click, [action(1),action(2),action(3),action(4),action(5),action(6)]).
% The container/bucket you orient.
a3_object(cd82, container, tool).
% The target image in the top-left to recreate.
a3_object(cd82, target_image, target).
% Pressing ACTION3 rotates the container.
a3_rel(cd82, press(rotate), rotate(container)).
% Pressing ACTION5 pours or dips the paint.
a3_rel(cd82, press(pour), dispense(paint)).
% Recreating the top-left target image wins the level.
a3_rel(cd82, match(target_image), win(level)).
% A wrong pour ends a level.
a3_hazard(cd82, wrong_pour).
% Orient the bucket, then dip to recreate the top-left target.
a3_tip(cd82, 'rotate to aim, then pour to match the top-left target image; get past the level-2 wall').
% A world-model agent solved all six.
a3_note(cd82, solvable, yes).

% ===========================================================================
% ar25 — Reflection (move shapes so their mirror image covers the targets)
% ===========================================================================
% Identity: a mirror/reflection symmetry puzzle, 8 levels, forgiving.
a3_game(ar25, 'Reflection', symmetry_puzzle, 8).
% Controls: move, cycle-select (ACTION5), click, undo.
a3_control(ar25, move_click_undo, [action(1),action(2),action(3),action(4),action(5),action(6),action(7)]).
% Shape pieces to place.
a3_object(ar25, shape, avatar).
% Mirror lines that reflect the shapes.
a3_object(ar25, mirror, tool).
% Target cells the reflected image must cover.
a3_object(ar25, target, target).
% A shape cast through a mirror produces a reflected image.
a3_rel(ar25, reflect(shape, mirror), image(reflection)).
% Covering every target cell with the image wins the level.
a3_rel(ar25, cover(targets), win(level)).
% Running the energy meter out loses (hard to trigger).
a3_hazard(ar25, energy_runs_out).
% Think in symmetry; undo freely; budgets are generous.
a3_tip(ar25, 'place a shape so its reflection lands on the targets; undo freely — it rarely kills you').
% No sudden hazards — a forgiving game.
a3_note(ar25, difficulty, forgiving).

% ===========================================================================
% m0r0 — Four-fold mirror movement (steer 4 linked tokens together to merge)
% ===========================================================================
% Identity: a four-fold mirrored-movement merge puzzle, 6 levels, no hazards.
a3_game(m0r0, 'Mirror-Merge', symmetry_puzzle, 6).
% Controls: mirrored group move plus click (grab free token).
a3_control(m0r0, move_click, [action(1),action(2),action(3),action(4),action(5),action(6)]).
% Four mirror-linked tokens.
a3_object(m0r0, token, avatar).
% The cell where tokens should merge.
a3_object(m0r0, merge_point, target).
% One arrow press moves all four tokens in mirrored directions.
a3_rel(m0r0, press(arrow), move(four_tokens_mirrored)).
% Two tokens meeting merge and are consumed.
a3_rel(m0r0, meet(token, token), merge(tokens)).
% Merging all tokens wins the level.
a3_rel(m0r0, merge(all_tokens), win(level)).
% Clicking grabs a free token for individual movement.
a3_rel(m0r0, click(free_token), move(single_token)).
% The only loss is exceeding the 150-action budget.
a3_hazard(m0r0, budget_runs_out).
% Plan presses that fold the four together; use the free token to fix the last.
a3_tip(m0r0, 'one press moves all four mirror-wise; aim them to merge; grab the free token for a stubborn one').
% No hazards — a forgiving game.
a3_note(m0r0, difficulty, forgiving).

% ===========================================================================
% s5i5 — Rotate-and-resize (click swatches to rotate, sliders to resize; cover)
% ===========================================================================
% Identity: a click rotate-and-resize puzzle, 8 levels; tight level 1.
a3_game(s5i5, 'Rotate-Resize', transform_puzzle, 8).
% Controls: click only.
a3_control(s5i5, click, [action(6)]).
% Colour swatches that rotate matching pieces.
a3_object(s5i5, swatch, control).
% Sliders that grow or shrink pieces.
a3_object(s5i5, slider, control).
% Target markers to cover.
a3_object(s5i5, target_marker, target).
% Clicking a colour swatch rotates every piece of that colour.
a3_rel(s5i5, click(swatch), rotate(matching_pieces)).
% Clicking a slider grows or shrinks the pieces.
a3_rel(s5i5, click(slider), resize(pieces)).
% Covering every target marker with a piece wins the level.
a3_rel(s5i5, cover(target_markers), win(level)).
% The tight step budget running out loses.
a3_hazard(s5i5, budget_runs_out).
% Level 1 gives only 50 clicks — teach the specific clicks, do not wander.
a3_tip(s5i5, 'a swatch click rotates same-colour pieces; a slider click resizes; be frugal — level 1 is only 50 clicks').

% ===========================================================================
% sk48 — Line-slide match (slide colour lines so paired lines agree; forgiving)
% ===========================================================================
% Identity: an oriented line-slide matching puzzle, 8 levels, forgiving.
a3_game(sk48, 'Line-Match', line_slide, 8).
% Controls: slide, click-select-paired, undo.
a3_control(sk48, move_click_undo, [action(1),action(2),action(3),action(4),action(6),action(7)]).
% Coloured pieces that form lines.
a3_object(sk48, line_piece, avatar).
% The partner line whose sequence must be matched.
a3_object(sk48, partner_line, target).
% Clicking one block selects its colour-paired twin.
a3_rel(sk48, click(block), select(paired_twin)).
% Sliding lines until each pair's colour order agrees wins the level.
a3_rel(sk48, match(line_sequences), win(level)).
% Running the 196 energy out loses (unlikely with care).
a3_hazard(sk48, energy_runs_out).
% Align the two partner lines; undo freely; the energy budget is large.
a3_tip(sk48, 'slide the paired lines until their colour orders agree; undo freely — the 196-energy budget is generous').
% No lethal hazards — a forgiving game.
a3_note(sk48, difficulty, forgiving).

% ===========================================================================
% wa30 — Block-Delivery (Sokoban-style: deliver every block to the goal pad)
% ===========================================================================
% Identity: a sokoban-style delivery puzzle, 9 levels, no lethal hazard.
a3_game(wa30, 'Block-Delivery', sokoban_delivery, 9).
% Controls: four-direction move plus interact (grab/drop/delete).
a3_control(wa30, move5, [action(1),action(2),action(3),action(4),action(5)]).
% The one agent you steer.
a3_object(wa30, agent, avatar).
% The target blocks you must deliver.
a3_object(wa30, target_block, tool).
% The goal pad the blocks must sit on.
a3_object(wa30, goal_pad, target).
% Helper movers autonomously carry blocks toward the goal.
a3_object(wa30, helper_mover, ally).
% Rival movers carry blocks away; you can delete them.
a3_object(wa30, rival_mover, hazard).
% Interact (ACTION5) grabs a block, drops a carried one, or deletes a rival.
a3_rel(wa30, press(interact), grab_drop_or_delete(object)).
% Deleting a rival mover with interact removes it.
a3_rel(wa30, delete(rival_mover), remove(rival)).
% Delivering every block to the goal pad (none attached) wins the level.
a3_rel(wa30, deliver(all_blocks, goal_pad), win(level)).
% The only failure is the step budget running out.
a3_hazard(wa30, budget_runs_out).
% Exploit the helpers, delete the rivals, and land every block on the pad.
a3_tip(wa30, 'push/carry every block onto the goal pad; delete rival movers with interact; no lethal hazard, only the step budget').
% Very hard for agents (a world-model agent scored 0 of 9).
a3_note(wa30, difficulty, hard_for_agents).

% ===========================================================================
% tr87 — String-Rewriting (edit a glyph row to be a valid rewrite of the top)
% ===========================================================================
% Identity: a symbol-string rewriting puzzle, 6 levels — NOT spatial movement.
a3_game(tr87, 'String-Rewrite', rewriting_puzzle, 6).
% Controls: cursor left/right (ACTION3/4) and decrement/increment a glyph (ACTION1/2).
a3_control(tr87, move4, [action(1),action(2),action(3),action(4)]).
% The editable glyph tokens in the bottom row.
a3_object(tr87, glyph, control).
% The fixed top row you must produce a rewrite of.
a3_object(tr87, top_row, target).
% The rewrite rules (left pattern maps to right replacement).
a3_object(tr87, rule, control).
% Moving the cursor (ACTION3/4) selects which glyph to edit.
a3_rel(tr87, move(cursor), select(glyph)).
% Incrementing or decrementing changes the selected glyph's value.
a3_rel(tr87, press(inc_or_dec), change(glyph)).
% Making the bottom row a valid rewrite of the top row wins the level.
a3_rel(tr87, rewrite(bottom_row, matches_top), win(level)).
% The energy budget running out (128 early, 256 on level 6) loses.
a3_hazard(tr87, energy_runs_out).
% Later levels disguise the rules (double translation, altered rules, tree expansion).
a3_note(tr87, note, 'level 4 chains two rewrites, level 5 disguises the rules, level 6 adds recursive expansion').
% Read the rules, then edit the bottom row to be a valid rewrite of the top.
a3_tip(tr87, 'move the cursor and inc/dec glyphs so the bottom row is a valid rewrite of the top row; energy is the clock').

% ===========================================================================
% lf52 — Peg Solitaire (jump pegs over pegs to capture them down to one)
% ===========================================================================
% Identity: a peg-solitaire capture puzzle, 10 levels (the most), no lethal hazard.
a3_game(lf52, 'Peg-Solitaire', peg_solitaire, 10).
% Controls: move a tile (1-4), click a peg then a direction (6), undo (7).
a3_control(lf52, move_click_undo, [action(1),action(2),action(3),action(4),action(6),action(7)]).
% The pegs you capture down to one.
a3_object(lf52, peg, avatar).
% A movable tile used to shove pegs into position.
a3_object(lf52, tile, tool).
% Walls that block movement.
a3_object(lf52, wall, barrier).
% Clicking a peg then a direction jumps it over an adjacent peg, capturing it.
a3_rel(lf52, click(peg_then_direction), jump_capture(peg)).
% Reducing the pegs to one (or two on levels 6-7) wins the level.
a3_rel(lf52, reduce(pegs, to_one), win(level)).
% The step budget running out loses (64 on level 1); undo itself costs budget.
a3_hazard(lf52, budget_runs_out).
% There is no enemy — only the step budget; undo does not save you from it.
a3_note(lf52, note, 'no lethal enemy — only the step budget (64 on level 1); undo costs a step, so it cannot outrun the budget').
% Plan the jump sequence; each jump removes one peg.
a3_tip(lf52, 'jump a peg over an adjacent peg to capture it; reduce the pegs to one; undo costs budget, so plan the jumps').

% ===========================================================================
% sc25 — Wizard Maze (cast spells by clicking a pattern grid; reach the exit)
% ===========================================================================
% Identity: a spell-casting maze, 6 levels, no lethal hazard.
a3_game(sc25, 'Wizard-Maze', spell_maze, 6).
% Controls: four-direction move plus click (on a 3x3 spell-slot grid).
a3_control(sc25, move_click, [action(1),action(2),action(3),action(4),action(6)]).
% The wizard you steer.
a3_object(sc25, wizard, avatar).
% The exit door to reach.
a3_object(sc25, exit_door, target).
% The 3x3 spell-slot grid you click to build a pattern.
a3_object(sc25, spell_slot, control).
% Doors that block the path (a fireball destroys them).
a3_object(sc25, door, barrier).
% Energy packs that refund step budget.
a3_object(sc25, energy_pack, collectible).
% Building a spell pattern on the grid casts that spell.
a3_rel(sc25, build(spell_pattern), cast(spell)).
% A fireball spell destroys doors, opening the path.
a3_rel(sc25, cast(fireball), destroy(door)).
% A teleport spell moves the wizard to a teleport target.
a3_rel(sc25, cast(teleport), teleport(wizard)).
% A size spell toggles the wizard between small and large.
a3_rel(sc25, cast(size), resize(wizard)).
% Walking onto an energy pack refunds step budget.
a3_rel(sc25, step_on(energy_pack), refund(budget)).
% Reaching the exit door wins the level.
a3_rel(sc25, reach(exit_door), win(level)).
% The only failure is the action budget running out.
a3_hazard(sc25, budget_runs_out).
% Easy for people, hard for agents — a prime teaching target.
a3_note(sc25, difficulty, easy_for_humans_hard_for_agents).
% Build the right spell pattern (L=teleport, plus=fireball, line=resize), then reach the exit.
a3_tip(sc25, 'click the spell grid to cast: an L-shape teleports, a plus fireballs doors, a line resizes; then reach the exit; grab energy packs').
