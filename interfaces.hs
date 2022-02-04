module Interfaces where

class Positionable a where
    pos :: a -> (Int, Int)
    is_in_coordinates :: a -> (Int, Int) -> Bool
    move :: a -> (Int, Int) -> a

data Playpen = Playpen {x_playpen :: Int,
                        y_playpen :: Int} deriving Show

data Child = Child {x_child :: Int,
                    y_child :: Int} deriving Show

data Rubbish = Rubbish {x_rubbish :: Int,
                        y_rubbish :: Int} deriving Show

data Obstacle = Obstacle {  x_obstacle :: Int,
                            y_obstacle :: Int} deriving Show

data Robot = Robot {will_comunicate :: Bool,
                    target :: (Int, Int),
                    x_robot :: Int,
                    y_robot :: Int} deriving Show

data Board = Board {
                        x_l :: Int,
                        y_l :: Int,
                        playpen :: [Playpen],
                        obstacles :: [Obstacle],
                        rubbish :: [Rubbish],
                        robots :: [Robot],
                        children :: [Child]} deriving Show

-- instance Agent Robot where
--     modify robot board = 

instance Eq Playpen where
    a == b = pos a == (pos b)
    a /= b = not (a == b)

instance Positionable Playpen where
    pos playpen = (x_playpen playpen, y_playpen playpen)
    is_in_coordinates playpen coord = pos playpen == coord
    move playpen (a, b) = Playpen (a + (x_playpen playpen)) (b + (y_playpen playpen))

instance Positionable Child where
    pos child = (x_child child, y_child child)
    is_in_coordinates child coord = pos child == coord
    move child (a, b) = Child (a + (x_child child)) (b + (y_child child))

instance Positionable Rubbish where
    pos rubbish = (x_rubbish rubbish, y_rubbish rubbish)
    is_in_coordinates rubbish coord = pos rubbish == coord
    move rubbish (a, b) = Rubbish (a + (x_rubbish rubbish)) (b + (y_rubbish rubbish))

instance Positionable Obstacle where
    pos obstacle = (x_obstacle obstacle, y_obstacle obstacle)
    is_in_coordinates obstacle coord = pos obstacle == coord
    move obstacle (a, b) = Obstacle (a + (x_obstacle obstacle)) (b + (y_obstacle obstacle))

instance Positionable Robot where
    pos robot = (x_robot robot, y_robot robot)
    is_in_coordinates robot coord = pos robot == coord
    move robot (a, b) = Robot (will_comunicate robot) (target robot) (a + (x_robot robot)) (b + (y_robot robot))