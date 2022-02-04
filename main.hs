module Main where
import Utils
import BoardWork
import Interfaces

main :: IO ()
main = do
        contents <- readFile "config.cfg"
        let [str_seed, str_x, str_y, str_ch, str_obs, str_rbsh, str_robots, str_model, str_iters] = lines contents
        let seed = read str_seed :: Int
        let x = read str_x :: Int
        let y = read str_y :: Int
        let ch = read str_ch :: Int
        let obs = read str_obs :: Int
        let rb = read str_rbsh :: Int
        let bot = read str_robots :: Int
        let model = read str_model ::Int
        let bot_comunication = if model == 0 then False else True
        let iter = read str_iters :: Int
        let (board, seed2) = create_tablero seed x y obs rb bot bot_comunication ch (Board x y [] [] [] [] [])
        changer board seed2 iter

changer :: Board -> Int -> Int -> IO ()
changer board seed 0 = putStrLn ""
changer board seed iter = do
    let (new_board, new_seed) = enviroment_change board seed
    print_board board
    putStrLn ((show (div (100 * len (rubbish board)) ((x_l board) * (y_l board)))) ++ "% de suciedad")
    putStrLn ""
    changer new_board new_seed (iter - 1)