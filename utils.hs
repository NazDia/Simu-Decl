
module Utils where

import Debug.Trace
import System.Random

first :: (a, b) -> a
first (a, _) = a

second :: (a, b) -> b
second (_, b) = b

resort_random :: Eq a => Int -> [a] -> ([a], Int)
resort_random seed [] = ([], first (random (mkStdGen seed)))
resort_random seed array = array2 where
    new_order = filter ((/=) (array !! r1)) array
    (r1, random_gen) = randomR (0, ((len array) - 1)) (mkStdGen seed)
    array2 = (((array !! r1):first ret), second ret)
    ret = resort_random (first (random random_gen)) new_order

random_pick :: Int -> [a] -> (a, Int)
random_pick seed list = (elem, pick_seed) where
    rr = mkStdGen seed
    this_it = randomR (0, (len list) - 1) rr
    elem = list !! (first this_it)
    pick_seed = first (random (second this_it))

split_from_elem :: Eq a => [a] -> a -> [a]
split_from_elem [] elem = []
split_from_elem (h:t) elem = if h == elem then t else split_from_elem t elem

split_to_elem :: Eq a => [a] -> a -> [a]
split_to_elem [] elem = []
split_to_elem (h:t) elem = if h == elem then [] else (h:split_from_elem t elem)

len :: [a] -> Int
len [] = 0
len (_:t) = 1 + (len t)

in_list :: Eq a => [a] -> a -> Bool
in_list [] _ = False
in_list (h:tail) elem = if elem == h then True else in_list tail elem

not_in_list :: Eq a => [a] -> a -> Bool
not_in_list l a = not (in_list l a)

(.+.) :: (Int, Int) -> (Int, Int) -> (Int, Int)
(a, b) .+. (c, d) = (a + c, b + d)

(+-+) :: Eq a => [a] -> [a] -> [a]
[] +-+ l2 = l2
(h:t) +-+ l2 = if in_list l2 h then t +-+ l2 else (h:(t +-+ l2))

first_in_list :: Eq a => [a] -> (a, b) -> Bool
first_in_list list (elem, _) = in_list list elem

get_best :: [((Int, Int), Int)] -> ((Int, Int), Int)
get_best [x] = x
get_best ((h_f, h_s):t) = if h_s < best_rank then (h_f, h_s) else (best_rest, best_rank) where
    (best_rest, best_rank) = get_best t