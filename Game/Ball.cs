using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Game
{
    internal class Ball
    {
        Random rnd = new Random();
        ConsoleColor ballColor;
        int speed = 1;
        MTP ball;
        public Ball(ConsoleColor ballColor) 
        {
            int randomY = rnd.Next(5, 19);
            this.ballColor = ballColor;
            this.ball = new MTP(Console.WindowWidth / 2, randomY, ' ', ballColor, ConsoleColor.Black, speed, 3, 1, false);
        }
        public void SetSpeed(int speed) 
        {
            this.speed = speed;
        }
        public int GetSpeed()
        {
            return this.speed;
        }
        public int GetX()
        {
            return this.ball.GetX();
        }
        public void DrawBall() // draws the ball
        {
            this.ball.Draw();
        }
        public void UndrawBall() // undraws the ball
        {
            this.ball.Undraw();
        }
        public void BallMove() // chooses a random direction and moves the ball one step in that direction, deals with when the ball tries to move out of console
        {
            this.ball.Undraw();
            if (this.ball.GetX() + 3 <= 119 && this.ball.GetX() >= 2)
            {
                this.ball.MoveOneStep();
                this.ball.IsOnEdge();
            }
            else
            {
                int randomD = rnd.Next(0, 2);
                if (randomD == 0 && ball.GetY() > 17)
                    this.ball.SetDirection(Direction.DownLeft);
                else if (ball.GetY() > 17)
                    this.ball.SetDirection(Direction.DownRight);
                else
                    this.ball.SetDirection(Direction.UpRight);
                this.ball.IsOnEdge();
                this.ball.MoveOneStep();
                
            }
            this.ball.Draw();
        }
        public void BallStartMove() // chooses a direction which the ball will start his moving in
        {
            this.ball.Undraw();
            int whichWay = rnd.Next(0, 2);
            if (whichWay == 0)
                ball.MoveUpRight();
            else if (whichWay == 1)
                ball.MoveUpLeft();
            this.ball.IsOnEdge();
            this.ball.Draw();
        }
        public bool TouchPlayer(Player player) // checks if the ball touches a player
        {
            return player.TouchObj(this.ball);
        }
    }
}
