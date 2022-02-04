module BoardWork where
import Interfaces
import Utils
import System.Random
import Debug.Trace

in_tablero :: Board -> (Int, Int) -> Bool
in_tablero tablero coordinates = in_list ((map_pos_list (robots tablero)) ++ (map_pos_list (children tablero)) ++ (map_pos_list (playpen tablero)) ++ (map_pos_list (obstacles tablero)) ++ (map_pos_list (rubbish tablero))) coordinates

not_in_tablero :: Board -> (Int, Int) -> Bool
not_in_tablero board coord = not (in_tablero board coord)

get_all_from_board :: Board -> (Int, Int) -> ([Playpen], [Obstacle], [Rubbish], [Robot], [Child])
get_all_from_board board coord = (filter check (playpen board), filter check1 (obstacles board), filter check2 (rubbish board), filter check3 (robots board), filter check4 (children board)) where
    check = flip (is_in_coordinates) coord
    check1 = flip (is_in_coordinates) coord
    check2 = flip (is_in_coordinates) coord
    check3 = flip (is_in_coordinates) coord
    check4 = flip (is_in_coordinates) coord

map_pos_list :: Positionable a => [a] -> [(Int, Int)]
map_pos_list [] = []
map_pos_list (h:tail) = (pos h):(map_pos_list tail)

create_positionable :: (Int -> Int -> a) -> Int -> Int -> Int -> Board -> (a, Int)
create_positionable positionable seed max_x max_y board = if not (in_tablero board (pos_x_r, pos_y_r)) then (positionable pos_x_r pos_y_r, first (random (second tuple2))) else create_positionable positionable (first (random (second tuple2))) max_x max_y board
                    where   random1 = mkStdGen seed
                            tuple1 = randomR (0, (max_x - 1)) random1
                            pos_x_r = first tuple1
                            random2 = second tuple1
                            tuple2 = randomR (0, (max_y - 1)) random2
                            pos_y_r = first tuple2

create_positionable_multi :: (Int -> Int -> a) -> Int -> Int -> Int -> Int -> Board -> ([a], Int)
create_positionable_multi positionable seed max_x max_y 0 board = ([], new_seed) where
    new_seed = first (random (mkStdGen seed))
create_positionable_multi positionable seed max_x max_y iterations board =
    (((first ret):(first ret_multi)), second ret_multi) where
        ret = create_positionable positionable seed max_x max_y board
        ret_multi = create_positionable_multi positionable (second ret) max_x max_y (iterations - 1) board

base_movement :: [(Int, Int)]
base_movement = [(0, 1), (0, -1), (1, 0), (-1, 0)]

movement :: (Int, Int) -> [(Int, Int)]
movement coord = [(coord .+. (base_movement !! 0)), (coord .+. (base_movement !! 1)), (coord .+. (base_movement !! 2)), (coord .+. (base_movement !! 3))]

movement_multi :: [(Int, Int)] -> [(Int, Int)]
movement_multi [] = []
movement_multi (h:t) = (movement h) +-+ (movement_multi t)

is_valid_pos :: Int -> Int -> (Int, Int) -> Bool
is_valid_pos max_x max_y pos = (first pos) >= 0 && (first pos) < max_x && (second pos) >= 0 && (second pos) < max_y

can_move_obstacle :: Obstacle -> Board -> (Int, Int) -> (Board, Bool)
can_move_obstacle obs board dir = (new_board, check) where
    check = is_valid_pos (x_l board) (y_l board) (pos obs .+. dir) && (len e1 == 0) && (len e3 == 0) && (len e4 == 0) && (len e5 == 0) && ((len e2 == 0) || next_iter)
    (prev_board, next_iter) = if len e2 > 0 then can_move_obstacle (head e2) board dir else (board, False)
    new_board = if not (is_valid_pos (x_l board) (y_l board) (pos obs .+. dir)) then board else
        if not (in_tablero board (pos obs .+. dir)) then Board (x_l board) (y_l board) (playpen board) (new_obstacles obs (obstacles board)) (rubbish board) (robots board) (children board) else
            if check then Board (x_l prev_board) (y_l prev_board) (playpen prev_board) (new_obstacles obs (obstacles prev_board)) (rubbish prev_board) (robots prev_board) (children prev_board) else board
    new_obstacles :: Positionable a => a -> [a] -> [a]
    new_obstacles elem list = ((move elem dir):(filter (not_eq_pos (pos elem)) list)) where
        not_eq_pos :: Positionable a => (Int, Int) -> a -> Bool
        not_eq_pos coords elem = not (is_in_coordinates elem coords)
    (e1, e2, e3, e4, e5) = get_all_from_board board (pos obs .+. dir)

child_mov :: Int -> Board -> Child -> (Board, Int)
child_mov seed board child = if (pos new_child) == pos child then (board, seed) else (modified_board, ret_seed) where
    possible_movs = ((0, 0):base_movement)
    ((x_p, y_p), ret_seed) = random_pick seed possible_movs
    new_coord = (x_p, y_p) .+. (pos child)
    can_move = is_valid_pos (x_l board) (y_l board) new_coord && (len e1 == 0) && (len e3 == 0) && (len e4 == 0) && (len e5 == 0) && ((len e2 == 0) || obs)
    (next_board, obs) = if len e2 > 0 then can_move_obstacle (head e2) board (x_p, y_p) else (board, False)
    new_child = if can_move then move child (x_p, y_p) else child
    modified_board = if ((len e1p) > 0) || ((len e4p) > 0) then board else Board (x_l next_board) (y_l next_board) (playpen next_board) (obstacles next_board) (rubbish next_board) (robots next_board) last_children
    last_children = (new_child:(filter (not_eq_pos (pos child)) (children next_board)))
    not_eq_pos :: Positionable a => (Int, Int) -> a -> Bool
    not_eq_pos coords elem = not (is_in_coordinates elem coords)
    (e1, e2, e3, e4, e5) = get_all_from_board board (new_coord)
    (e1p, _, _, e4p, _) = get_all_from_board board (pos child)

get_square_pos :: Board -> (Int, Int) -> [(Int, Int)]
get_square_pos board pos = ret where
    ret = filter (check board) array
    check :: Board -> (Int, Int) -> Bool
    check b xpos = is_valid_pos (x_l b) (y_l b) xpos
    semi_array = base_movement ++ [(0, 0), (1, 1), (1, -1), (-1, 1), (-1, -1)]
    array = map ((.+.) pos) semi_array 

generate_rubbish :: Int -> Child -> Board -> Board -> (Board, Int)
generate_rubbish seed child prev_board current_board = if can_generate then (next_board, ret_seed) else (current_board, seed) where
    square = get_square_pos prev_board (pos child)
    no_ch = get_children_in_square prev_board square
    free = get_free_spaces_square current_board square
    no_free = len free
    (rubbish_no, seed1) = ammount_of_rubbish seed no_ch no_free
    (randomized, ret_seed) = resort_random seed1 free
    new_rubbish = take rubbish_no randomized
    next_board = add_board current_board [] [] (map rubbish_from_tuple new_rubbish) [] []
    get_children_in_square :: Board -> [(Int, Int)] -> Int
    get_children_in_square board square = len ret_list where
        semi_ret_list = filter (in_list (map pos (children board))) square
        ret_list = filter (not_in_list ((map pos (robots board)) ++ (map pos (playpen board)))) semi_ret_list
    get_free_spaces_square :: Board -> [(Int, Int)] -> [(Int, Int)]
    get_free_spaces_square board square = filter (not_in_tablero board) square
    ammount_of_rubbish :: Int -> Int -> Int -> (Int, Int)
    ammount_of_rubbish seed children_number free_spaces = (ret, first (random new_random)) where
        rr = mkStdGen seed
        max_rubbish = min free_spaces (if children_number == 1 then 1 else if children_number == 2 then 3 else 6)
        (ret, new_random) = randomR (0, max_rubbish) rr
    rubbish_from_tuple :: (Int, Int) -> Rubbish
    rubbish_from_tuple (a, b) = Rubbish a b
    can_generate = not_in_list (map pos (playpen current_board) ++ (map pos (robots current_board))) (pos child)

children_movs :: Int -> Board -> [Child] -> (Board, Int)
children_movs seed board [] = (board, seed)
children_movs seed board (ch_h:ch_t) = (new_board, ret_seed) where
    (next_iter, seed1) = children_movs seed board ch_t
    (current_iter, seed2) = child_mov seed1 next_iter ch_h
    (new_board, ret_seed) = generate_rubbish seed2 ch_h next_iter current_iter

my_bfs :: [(Int, Int)] -> ((Int, Int) -> Bool) -> ([(Int, Int)] -> Bool) -> [(Int, Int)] -> Int -> [(Int, Int)]
my_bfs exceptions check stop_criteria [] iterations = exceptions
my_bfs exceptions check stop_criteria analysis 0 = analysis +-+ exceptions
my_bfs exceptions check stop_criteria (h:t) iterations = if not (stop_criteria (h:t)) then my_bfs new_exceptions check stop_criteria new_analysis (iterations - 1) else (h:t) ++ exceptions
                                                where
                                                    semi_new_analysis = filter check (movement_multi (h:t))
                                                    new_analysis = filter (not_in_list exceptions) semi_new_analysis
                                                    new_exceptions = (h:t) +-+ exceptions

full_bfs :: Board -> [(Int, Int)] -> [((Int, Int), Int)] -> [((Int, Int), Int)]
full_bfs board [] except = except
full_bfs board (coords:rest) except = full_bfs board new_analysis new_exceptions  where
    (exceptions, _) = unzip except
    surrounding = filter (is_valid_pos (x_l board) (y_l board)) (movement_multi (coords:rest))
    new_analysis = filter (not_in_list exceptions) surrounding
    new_exceptions = except +-+ (map (value_position board except) (coords:rest))
    position_status = map (value_position board except) new_analysis
    value_position :: Board -> [((Int, Int), Int)] -> (Int, Int) -> ((Int, Int), Int)
    value_position board valued pos = if len valued > 0 then (pos, x) else (pos, 0) where
        (e1, e2, e3, e4, e5) = get_all_from_board board pos
        (_, base_val) = get_best adjs
        adjs = filter (first_in_list (movement pos)) valued
        x = if len e2 > 0 || (len e4 > 0) then (x_l board) * (y_l board) + base_val + sum_factor else base_val + sum_factor
        sum_factor = if len e1 > 0 && (len e5 > 0) then 2 * ((x_l board) * (y_l board)) else 1

extract_path :: (Int, Int) -> (Int, Int) -> [(Int, Int)] -> [(Int, Int)]
extract_path from dest bfs_result = path where
    (next:_) = if len filtered > 0 then filtered else (from:[])
    filtered = filter (in_list (movement dest)) bfs_result
    path = if from == dest then [] else (dest:extract_path from next (split_from_elem bfs_result next))

get_prev_targets :: Board -> Robot -> [(Int, Int)]
get_prev_targets board bot = list where
    bots_pos = map pos (robots board)
    prevs_pos = split_to_elem bots_pos (pos bot)
    prevs = take (len prevs_pos) (robots board)
    list = map target prevs

bot_best_stop :: Board -> Robot -> ((Int, Int), Robot)
bot_best_stop board bot = (best, new_bot) where
    prev_targets = get_prev_targets board bot
    prev_as_exc = map (tuple_max board) prev_targets
    tuple_max :: Board -> (Int, Int) -> ((Int, Int), Int)
    tuple_max board tuple = (tuple, (x_l board) * (y_l board))
    new_bot = Robot (will_comunicate bot) best (x_robot bot) (y_robot bot)
    semi_bfs = full_bfs board [pos bot] []
    bfs = if (will_comunicate bot) then filter (filtering prev_targets) (semi_bfs) else semi_bfs
    filtering :: [(Int, Int)] -> ((Int, Int), Int) -> Bool
    filtering list elem = not_in_list list (first elem)
    children_r = filter (first_in_list (map pos (children board))) bfs
    rubbish_r = filter (first_in_list (map pos (rubbish board))) bfs
    playpen_r = filter (first_in_list (map pos (playpen board))) bfs
    (best_child, r_c) = if len children_r > 0 then get_best children_r else (pos bot, dimension)
    (best_rubbish, r_r) = if len rubbish_r > 0 then get_best rubbish_r else (pos bot, dimension)
    (best_playpen, r_p) = if len playpen_r > 0 then get_best playpen_r else (pos bot, dimension)
    best = target
    (target, t_r) = if len e5 > 0 && len e1 == 0 then (best_playpen, r_p) else (target_alone, t_r2)
    (target_alone, t_r2) = if r_c > r_r then (best_rubbish, r_r) else (best_child, r_c)
    dimension = (x_l board) * (y_l board)
    (e1, e2, e3, e4, e5) = get_all_from_board board (pos bot)

robots_mov :: Board -> [Robot] -> Board
robots_mov board [] = board
robots_mov board (h:t) = robots_mov (robots_mov_single board h False) t

robots_mov_single :: Board -> Robot -> Bool -> Board
robots_mov_single prev_board prev_bot second_time = if len e5 > 0 && not second_time then robots_mov_single new_board new_robot True else new_board where
    cond_board = len p1 > 0 && (len p5 > 0)
    board = if cond_board then Board (x_l prev_board) (y_l prev_board) (playpen prev_board) (obstacles prev_board) (rubbish prev_board) (robots prev_board) (filter (filtering (pos prev_bot)) (children prev_board)) else prev_board
    (p1, _, _, _, p5) = get_all_from_board prev_board (pos prev_bot)
    (dest, bot) = bot_best_stop board prev_bot
    to_examine = if in_list bfs1 dest then bfs1 else bfs2
    path = filter (not_in_list bfs_exceptions2) (reverse (extract_path (pos bot) dest to_examine))
    path_h = if len path > 0 then head path else pos bot
    new_board = if cond_board then add_board new_board1 [] [] [] [] [Child (first (pos bot)) (second (pos bot))] else new_board1
    -- poner || len e1 > 0
    new_board1 = if len e3 > 0 && (not second_time) then Board (x_l board) (y_l board) (playpen board) (obstacles board) new_rubbish (robots board) (children board) else new_board_moved
    new_board_moved = if in_list (movement (pos bot)) path_h then Board (x_l board) (y_l board) (playpen board) (obstacles board) (rubbish board) (new_robot:(filter ((flip not_in_coordinates) (pos bot)) (robots board))) new_children else prev_board
    new_robot = if len e3 > 0 && (not second_time) then bot else Robot (will_comunicate bot) (target bot) (first path_h) (second path_h)
    new_children = if len e5 > 0 then ((Child (first path_h) (second path_h)):filter (filtering (pos bot)) (children board)) else (children board)
    new_rubbish = if len e3 > 0 then filter (filtering (pos bot)) (rubbish board) else (rubbish board)
    filtering :: Positionable a => (Int, Int) -> a -> Bool
    filtering coord positionable = (pos positionable) /= coord
    bfs_exceptions = (((map pos (obstacles board)) ++ (map pos (robots board))))
    bfs_exceptions1 = filter (in_both (map pos (children board)) (map pos (playpen board))) (map pos (children board) +-+ (map pos (playpen board)))
    bfs_exceptions2 = bfs_exceptions +-+ bfs_exceptions1
    in_both :: Eq a => [a] -> [a] -> a -> Bool
    in_both l1 l2 elem = in_list l1 elem && (in_list l2 elem)
    dirty_bfs1 = my_bfs bfs_exceptions2 (is_valid_pos (x_l board) (y_l board)) ((flip (in_list)) dest) [pos bot] ((x_l board) * (y_l board))
    bfs1 = filter (not_in_list ((map pos (obstacles board)) ++ (map pos (robots board)))) dirty_bfs1
    bfs2 = my_bfs [] (is_valid_pos (x_l board) (y_l board)) ((flip (in_list)) dest) [pos bot] ((x_l board) * (y_l board))
    not_in_coordinates :: Positionable a => a -> (Int, Int) -> Bool
    not_in_coordinates x coord = not (is_in_coordinates x coord)
    (e1, e2, e3, e4, e5) = get_all_from_board board (pos bot)

enviroment_change :: Board -> Int -> (Board, Int)
enviroment_change board seed = (new_board, ret_seed) where
    board1 = robots_mov board (robots board)
    (new_board, ret_seed) = children_movs seed board1 (children board1)
    
create_playpen :: [Playpen] -> Int -> Int -> Int -> Int -> ([Playpen], Int)
create_playpen [] seed max_x max_y ammount = ((initial:ret), ret_seed)
    where
        rr = mkStdGen seed
        (x1, rr1) = randomR (0, max_x - 1) rr
        (x2, rr2) = randomR (0, max_y - 1) rr1
        initial = Playpen x1 x2
        (seed2, _) = random rr2
        (ret, ret_seed) = create_playpen [initial] seed2 max_x max_y (ammount - 1)

create_playpen initial seed max_x max_y 0 = ([], first (random (mkStdGen seed)))
create_playpen initial seed max_x max_y ammount = if not_in_list (initial ++ (first next)) current then (current:(first next), second next) else create_playpen initial another_seed max_x max_y ammount
    where
        current = Playpen (first current_coords) (second current_coords)
        (picked, second_seed) = random_pick seed initial
        (current_coords, another_seed) = random_pick second_seed movs
        movs = filter (is_valid_pos max_x max_y) (movement (pos picked))
        next = create_playpen (current:initial) another_seed max_x max_y (ammount - 1)

add_board :: Board -> [Playpen] -> [Obstacle] -> [Rubbish] -> [Robot] -> [Child] -> Board
add_board t array_p array_o array_g array_r array_n = Board (x_l t) (y_l t) ((playpen t) ++ array_p) ((obstacles t) ++ array_o) ((rubbish t) ++ array_g) ((robots t) ++ array_r) ((children t) ++ array_n)

create_tablero :: Int -> Int -> Int -> Int -> Int -> Int -> Bool -> Int -> Board -> (Board, Int)
create_tablero seed max_x max_y obstacles rubbish robots bot_comunication children board = tuple where
    board1 = add_board board  n_playpen [] [] [] []
    board2 = add_board board1 [] n_obstacles [] [] []
    board3 = add_board board2 [] [] n_rubbish [] []
    board4 = add_board board3 [] [] [] n_robots []
    board5 = add_board board4 [] [] [] [] n_children
    tuple = (board5, ret_seed)
    (n_playpen, seed1) = create_playpen [] seed max_x max_y children
    (n_obstacles, seed2) = create_positionable_multi Obstacle seed1 max_x max_y obstacles board1
    (n_rubbish, seed3) = create_positionable_multi Rubbish seed2 max_x max_y rubbish board2
    (n_robots, seed4) = create_positionable_multi (Robot bot_comunication (-1, -1)) seed3 max_x max_y robots board3
    (n_children, ret_seed) = create_positionable_multi Child seed3 max_x max_y children board4

print_board :: Board -> IO ()
print_board board = print_row board 0

print_row :: Board -> Int -> IO ()
print_row board iter = if iter < (x_l board) then ret else putStrLn "" where
    semi_ret = print_cells board iter 0
    ret = do
        putStrLn (semi_ret)
        print_row board (iter + 1)

print_cells :: Board -> Int -> Int -> String
print_cells board x iter = if iter < (y_l board) then ret ++ semi_ret else "" where
    ret = print_cell board x iter
    semi_ret = print_cells board x (iter + 1)

print_cell :: Board -> Int -> Int -> String
print_cell board x y = ret where
    (e1, e2, e3, e4, e5) = get_all_from_board board (x, y)
    ret = if len e4 > 0 then (if len e5 > 0 then "&" else "$") else if len e5 > 0 then (if len e1 > 0 then "Q" else "@") else
        if len e3 > 0 then "?" else if len e1 > 0 then "#" else if len e2 > 0 then "X" else "_"
