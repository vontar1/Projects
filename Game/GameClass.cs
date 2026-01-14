using Game;
using System;
using System.Collections.Generic;
using System.Diagnostics.Eventing.Reader;
using System.Linq;
using System.Security.Principal;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Xml.Schema;

namespace Game
{
    internal class GameClass
    {
        Random rnd = new Random();
        int score1 = 0;
        int score2 = 0;
        int wins1;
        int wins2;
        Ball ball = null;
        Player player1 = null;
        Player player2 = null;
        MTP shrinkPU = null;
        ConsoleColor floorColor;
        public GameClass(ConsoleColor floorColor)
        {
            this.floorColor = floorColor;
        }
        public void LoadPlayers() //makes the 2 players
        {
            player1 = new Player(ConsoleColor.Blue, ConsoleColor.Cyan, 1, 4, 13, true);
            player2 = new Player(ConsoleColor.DarkRed, ConsoleColor.Red, 1, Console.WindowWidth - 11, 13, false);
        }
        public void LoadBall() //makes the ball with a random color
        {
            int randomColor = rnd.Next(1, 16);
            ball = new Ball((ConsoleColor)randomColor);
        }
        public void LoadArena() // Creates the arena, loading the players, the ball, the floor etc
        {
            int Split = 0;
            Trect Floor = new Trect(0, 20, 2, 119, this.floorColor, true);
            Trect WinsFirstPlayer = new Trect(2, 0, 4, 21, ConsoleColor.Blue, false);
            Trect WinsSecondPlayer = new Trect(99, 0, 4, 21, ConsoleColor.DarkRed, false);
            Trect ScoreFirstPlayer = new Trect(2, 24, 6, 33, ConsoleColor.Blue, false);
            Trect ScoreSecondPlayer = new Trect(86, 24, 6, 33, ConsoleColor.DarkRed, false);
            Trect SplitLine = new Trect(Console.WindowWidth / 2, Split, 1, 1, ConsoleColor.Green, true);
            while (Split + 1 < 20)
            {
                SplitLine.Draw();
                SplitLine.setY(SplitLine.getY() + 2);
                Split += 2;
            }
            LoadPlayers();
            WinsFirstPlayer.Draw();
            WinsSecondPlayer.Draw();
            ScoreFirstPlayer.Draw();
            ScoreSecondPlayer.Draw();
            Floor.Draw();
            LoadBall();
            ball.DrawBall();
        }
        public void UpScore(Player player) // gets one of the 2 players and draws the score point on the screen
        {
            if (player == player1)
            {
                Trect Score = new Trect(3 + 5 * this.score1, 25, 4, 4, ConsoleColor.Green, true);
                Score.Draw();
            }
            else if (player == player2)
            {
                Trect Score = new Trect(87 + 5 * this.score2, 25, 4, 4, ConsoleColor.Green, true);
                Score.Draw();
            }   
        }
        public void UpWins(Player player) // gets one of the 2 players, resets the score and draws another win point
        {
            Trect resetScoreFirstPlayer = new Trect(3, 25, 4, 30, ConsoleColor.Black, true);
            Trect resetScoreSecondPlayer = new Trect(87, 25, 4, 30, ConsoleColor.Black, true);
            if (player == player1)
            {
                Trect Win = new Trect(3 + 6 * this.wins1, 1, 2, 5, ConsoleColor.DarkYellow, true);
                Win.Draw();
            }
            else if (player == player2)
            {
                Trect Win = new Trect(100 + 6 * this.wins2, 1, 2, 5, ConsoleColor.DarkYellow, true);
                Win.Draw();
            }
            resetScoreFirstPlayer.Draw();
            resetScoreSecondPlayer.Draw();
        }
        public void MoveBall(Ball ball) // calls the "MoveBall" function
        {
            ball.BallMove();
        }
        public void DrawPlayers(Player player1, Player player2) // gets 2 players and draws them
        {
            player1.DrawPlayer();
            player2.DrawPlayer();
        }
        public void StartGame() // creating the players and loading the game
        {
            int delay = 50;
            bool endPoint = false;
            Console.CursorVisible = false;
            LoadArena();
            ball.BallStartMove();
            DrawPlayers(player1, player2);
            bool cont = true;
            bool PUIsAlive = false;
            int shrinkCount = 0;
            while (cont)
            {
                int Split = 0;
                Trect SplitLine = new Trect(Console.WindowWidth / 2, Split, 1, 1, ConsoleColor.Green, true);
                while (Split + 1 < 20)
                {
                    SplitLine.Draw();
                    SplitLine.setY(SplitLine.getY() + 2);
                    Split += 2;
                }
                ball.BallMove();
                #region KeyPressed
                if (Console.KeyAvailable)
                {

                    ConsoleKey key = Console.ReadKey(true).Key;
                    player1.UndrawPlayer(); player2.UndrawPlayer();
                    if (key == ConsoleKey.W)
                    {
                        PlayerMoveUp(player1);
                    }
                    else if (key == ConsoleKey.S)
                    {
                        PlayerMoveDown(player1);
                    }
                    else if (key == ConsoleKey.D)
                    {
                        PlayerMoveRight(player1);
                    }
                    else if (key == ConsoleKey.A)
                    {
                        PlayerMoveLeft(player1);
                    }
                    else if (key == ConsoleKey.LeftArrow)
                    {
                        PlayerMoveLeft(player2);
                    }
                    else if (key == ConsoleKey.RightArrow)
                    {
                        PlayerMoveRight(player2);
                    }
                    else if (key == ConsoleKey.UpArrow)
                    {
                        PlayerMoveUp(player2);
                    }
                    else if (key == ConsoleKey.DownArrow)
                    {
                        PlayerMoveDown(player2);
                    }
                    player1.DrawPlayer();
                    player2.DrawPlayer();
                    
                }
                #endregion
                if (shrinkCount == 2000)
                {
                    int randomX = rnd.Next(3, 117);
                    while (randomX != Console.WindowWidth / 2 && !PUIsAlive)
                    {
                        int randomY = rnd.Next(6, 19);
                        shrinkPU = new MTP(randomX, randomY, 'o', ConsoleColor.DarkYellow, ConsoleColor.Black, 0, 1, 1, true);
                        shrinkPU.Draw();
                        PUIsAlive = true;
                    }
                }
                if (shrinkCount == 11000)
                {
                    shrinkPU.Undraw();
                    shrinkPU = null;
                    shrinkCount = 0;
                    PUIsAlive = false;
                }
                if (PUIsAlive)
                {
                    shrinkPU.Draw();
                    if (player1.TouchObj(shrinkPU))
                    {
                        shrinkPU.Undraw();
                        player1.Shrink(true);
                        PUIsAlive = false;
                    }
                    else if (player2.TouchObj(shrinkPU))
                    {
                        shrinkPU.Undraw();
                        player2.Shrink(false);
                        PUIsAlive = false;
                    }
                }
                if (ball.TouchPlayer(player1) && score2 < 6)
                {
                    UpScore(player2);
                    score2++;
                    endPoint = true;
                }
                else if (ball.TouchPlayer(player2) && score1 < 6)
                {
                    UpScore(player1);
                    score1++;
                    endPoint = true;
                }
                else if (score1 >= 6 && wins1 <= 3)
                {
                    UpWins(player1);
                    wins1++;
                    score1 = 0;
                    score2 = 0;
                }
                else if (score2 >= 6 && wins2 <= 3)
                {
                    UpWins(player2);
                    wins2++;
                    score2 = 0;
                    score1 = 0;
                }
                if (wins1 == 3 || wins2 == 3)
                    cont = false;
                if (endPoint)
                {
                    ball.UndrawBall();
                    LoadBall();
                    ball.DrawBall();
                    ball.BallStartMove();
                    player1.UndrawPlayer();
                    player2.UndrawPlayer();
                    LoadPlayers();
                    DrawPlayers(player1, player2);
                    endPoint = false;
                }
                shrinkCount += delay;
                Thread.Sleep(delay);
            }
            Console.BackgroundColor = ConsoleColor.Gray;
            Console.Clear();
            Console.SetCursorPosition(55, 15);
            Console.ForegroundColor = ConsoleColor.DarkYellow;
            if (wins1 == 3)
                Console.WriteLine("Player1 Won!");
            else
                Console.WriteLine("Player2 Won!");
            Console.ReadKey();
        }
        
        public void PlayerMoveLeft(Player player) //moves the player left
        {
            player.PlayerMoveLeft();
        }
        public void PlayerMoveRight(Player player) // moves the player right
        {
            player.PlayerMoveRight();
        }
        public void PlayerMoveDown(Player player) // moves the player down
        {
            player.PlayerMoveDown();
        }
        public void PlayerMoveUp(Player player) // moves the player up
        {
            player.PlayerMoveUp();
        }
    }
}
