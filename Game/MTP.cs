using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Configuration;
using System.Text;
using System.Threading.Tasks;

namespace Game
{
    public enum Direction { Up = 0, Down = 4, Left = 1, Right = 5, UpRight = 2, DownRight = 6, UpLeft = 3, DownLeft = 7 };

    internal class MTP
    {
        int width;
        int length;
        Random rnd = new Random();
        int MAX_X = Console.WindowWidth;
        int MAX_Y = Console.WindowHeight;
        int x ;
        int y ;
        char ch;
        bool isFull;
        ConsoleColor ForeGroundColor;
        ConsoleColor BackGroundColor;
        Direction direction;
        int speed;
        public MTP(int x, int y, char ch, ConsoleColor Fcolor, ConsoleColor Bcolor, int speed, int width, int length, bool isFull)
        {
            this.x = x; this.y = y;
            this.ch = ch;
            this.ForeGroundColor = Fcolor;
            this.BackGroundColor = Bcolor;
            this.speed = speed;
            this.width = width;
            this.length = length;
            this.isFull = isFull;
        }
        #region Get
        public int GetWidth()
        { return width; }
        public int GetLength()
        { return length; }
        public int GetSpeed()
        { return speed; }
        public int GetX()
        { return x; }
        public int GetY()
        { return y; }
        public char GetCh()
        { return ch; }
        public ConsoleColor BGetColor()
        { return this.BackGroundColor; }
        public Direction GetDirection()
        { return direction; }
        #endregion
        #region Set
        public void SetX(int x)
        { this.x = x; }
        public void SetLen(int len)
        { this.x = len; }
        public void SetWid(int wid)
        { this.width = wid; }
        public void SetY(int y)
        { this.y = y; }
        public void SetDirection(Direction direction)
        { this.direction = direction; }
        public void SetCh(char ch)
        { this.ch = ch; }
        #endregion
        public void BasicDraw(ConsoleColor Fcolor, ConsoleColor Bcolor)
        {
            int x = this.x;
            int y = this.y;
            Console.BackgroundColor = Bcolor;
            Console.ForegroundColor = Fcolor;
            Console.SetCursorPosition(this.x, this.y);
            if (this.isFull == true)
            {
                for (int i = 0; i < this.length; i++)
                {
                    x = this.x;
                    Console.SetCursorPosition(this.x, y);
                    for (int j = 0; j < this.width; j++)
                    {
                        x++;
                        Console.SetCursorPosition(x, y);
                        Console.Write(this.ch);
                    }
                    y++;
                }
            }
            else if (!this.isFull)
            {
                Console.ForegroundColor = Fcolor;
                Console.SetCursorPosition(this.x, this.y);
                {
                    Console.Write("╔");
                    for (int j = 0; j < this.width - 2; j++)
                        Console.Write("═");
                    Console.Write("╗");
                    y++;
                    for (int i = 0; i < length - 2; i++)
                    {
                        Console.SetCursorPosition(this.x, y);
                        Console.Write("║");
                        Console.ForegroundColor = ConsoleColor.Black;
                        Console.SetCursorPosition(this.x + (int)this.width - 1, y);
                        Console.ForegroundColor = Fcolor;
                        Console.Write("║");
                        y++;
                    }
                    Console.SetCursorPosition(this.x, y);
                    Console.Write("╚");
                    for (int j = 0; j < this.width - 2; j++)
                        Console.Write("═");
                    Console.Write("╝");
                }
            }
        }
        public void Undraw()
        {
            BasicDraw(ConsoleColor.Black, ConsoleColor.Black);
        }
        public void Draw()
        {
            BasicDraw(this.ForeGroundColor, this.BackGroundColor);
        }
        public void IsOnEdge()
        {
            if ((this.x == 117 && (this.direction == Direction.Right || this.direction == Direction.UpRight || this.direction == Direction.DownRight)) ||
                (this.x == 3 && (this.direction == Direction.Left || this.direction == Direction.UpLeft || this.direction == Direction.DownLeft)) ||
                (this.y == 18 && (this.direction == Direction.Down || this.direction == Direction.DownRight || this.direction == Direction.DownLeft)) ||
                (this.y == 4 && (this.direction == Direction.Up || this.direction == Direction.UpLeft || this.direction == Direction.UpRight)))
            {
                ChangeDirection();
            }
        }
        #region Move
        public void MoveRight()
        {
            if (this.x + this.speed < MAX_X - 2)
            {
                this.x += this.speed;
                this.direction = Direction.Right;
            }
        }
        public void MoveLeft()
        {
            if (this.x - this.speed > 0)
            {
                this.x -= this.speed;
                this.direction = Direction.Left;
            }
        }
        public void MoveUp()
        {
            if (this.y - this.speed > 0)
            {
                this.y -= this.speed;
                this.direction = Direction.Up;
            }
        }
        public void MoveDown()
        {
            if (this.y + this.speed < MAX_Y)
            {
                this.y += this.speed;
                this.direction = Direction.Down;
            }

        }
        public void MoveUpRight()
        {
            if (this.x + this.speed < MAX_X && this.y - this.speed > 0)
            {
                MoveUp();
                MoveRight();
                this.direction = Direction.UpRight;
            }
        }
        public void MoveDownRight()
        {
            if (this.x + this.speed < MAX_X && this.y + this.speed < MAX_Y)
            {
                MoveDown();
                MoveRight();
                this.direction = Direction.DownRight;
            }
        }
        public void MoveDownLeft()
        {
            if (this.x - this.speed > 0 && this.y + this.speed < MAX_Y)
            {
                MoveDown();
                MoveLeft();
                this.direction = Direction.DownLeft;
            }
        }
        public void MoveUpLeft()
        {
            if (this.x - this.speed > 0 && this.y - this.speed > 0)
            {
                MoveLeft();
                MoveUp();
                this.direction = Direction.UpLeft;
            }
        }

        #endregion 
        public void ChangeDirection()
        {
            int dir = (int)this.direction;
            dir = (dir + 4) % 8;
            this.direction = (Direction)dir;
        }
        public void MoveOneStep()
        {
            if (this.direction == Direction.Up)
                MoveUp();
            else if (this.direction == Direction.Down)
                MoveDown();
            else if (this.direction == Direction.Left)
                MoveLeft();
            else if (this.direction == Direction.Right)
                MoveRight();
            else if (this.direction == Direction.UpRight)
                MoveUpRight();
            else if (this.direction == Direction.UpLeft)
                MoveUpLeft();
            else if (this.direction == Direction.DownLeft)
                MoveDownLeft();
            else if (this.direction == Direction.DownRight)
                MoveDownRight();
        }
        public void RndMove()
        {
            int chance = rnd.Next(0, 10);
            int randomDir = rnd.Next(0, 8);
            if (chance == 1)
                this.direction = (Direction)randomDir;
            MoveOneStep();
        }
        public bool Touch(MTP other)
        {
            bool doTouch = false;
            for (int i = this.y; i < this.y + this.length; i++)
            {
                for (int j = this.x; j < this.x + this.width; j++)
                {
                    if (j >= other.GetX() && j <= other.GetX() + other.GetWidth() && i >= other.GetY() && i <= other.GetY() + other.GetLength())
                        doTouch = true;
                }
            }
            return doTouch;
        }
    }
}
