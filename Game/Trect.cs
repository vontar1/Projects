using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Game
{
    internal class Trect
    {
        int xAxis;
        int yAxis;
        double length;
        double width;
        ConsoleColor color = ConsoleColor.White;
        bool isFull = false;

        public Trect(int x, int y, double length, double width, ConsoleColor color, bool ifFull)
        {
            this.xAxis = x;
            this.yAxis = y;
            this.length = length;
            this.width = width;
            this.color = color;
            this.isFull = ifFull;
        }
        public int getX() { return xAxis; }
        public int getY() { return yAxis; }
        public double getLength() { return length; }
        public double getWidth() { return width; }
        public bool IsFull() { return this.isFull; }
        public void setX(int x)
        {
            if (x < 79 && x > 0)
                this.xAxis = x;
        }
        public void setY(int y)
        {
            if (y < 24 && y > 0)
                this.yAxis = y;
        }
        public void setLength(double length)
        {
            if (length > 0)
                this.length = length;
        }
        public void setWidth(double width)
        {
            if (width > 0)
                this.width = width;
        }
        public void setColor(ConsoleColor color)
        {
            this.color = color;
        }
        public void setFull(bool Full)
        {
            this.isFull = Full;
        }
        public ConsoleColor GetColor() { return this.color; }
        public int GetArea()
        {
            return (int)(length * width);
        }
        public int GetPerimenter()
        {
            return (int)(2 * length + 2 * width);
        }
        public double GetDiagonal()
        {
            return Math.Sqrt(Math.Pow(width, 2) + Math.Pow(length, 2));
        }
        public void Draw()
        {
            int x = this.xAxis;
            int y = this.yAxis;
            if (this.isFull)
            {
                Console.BackgroundColor = this.color;
                Console.SetCursorPosition(this.xAxis, this.yAxis);
                for (int i = 0; i < this.length; i++)
                {
                    x = this.xAxis;
                    Console.SetCursorPosition(this.xAxis, y);
                    for (int j = 0; j < this.width; j++)
                    {
                        x++;
                        Console.SetCursorPosition(x, y);
                        Console.Write(" ");
                    }
                    y++;
                }
            }
            else if (!this.isFull)
            {
                Console.ForegroundColor = this.color;
                Console.BackgroundColor = ConsoleColor.Black;
                Console.SetCursorPosition(this.xAxis, this.yAxis);
                {
                    Console.Write("╔");
                    for (int j = 0; j < this.width - 2; j++)
                        Console.Write("═");
                    Console.Write("╗");
                    y++;
                    for (int i = 0; i < length - 2; i++)
                    {
                        Console.SetCursorPosition(this.xAxis, y);
                        Console.Write("║");
                        Console.ForegroundColor = ConsoleColor.Black;
                        Console.SetCursorPosition(this.xAxis + (int)this.width - 1, y);
                        Console.ForegroundColor = this.color;
                        Console.Write("║");
                        y++;
                    }
                    Console.SetCursorPosition(this.xAxis, y);
                    Console.Write("╚");
                    for (int j = 0; j < this.width - 2; j++)
                        Console.Write("═");
                    Console.Write("╝");
                }
            }
        }
    }
}
