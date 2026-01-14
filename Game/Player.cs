using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Security.Policy;
using System.Text;
using System.Threading.Tasks;

namespace Game
{
    internal class Player
    {
        MTP playerHead;
        MTP playerHelm;
        MTP legs;
        MTP leftArm;
        MTP rightArm;
        MTP body;
        public Player(ConsoleColor bodyColor, ConsoleColor headColor, int speed, int x, int y, bool facing)
        {
            if (facing)
            {
                this.playerHelm = new MTP(x + 2, y + 1, ' ', ConsoleColor.Green, ConsoleColor.White, speed, 4, 1, true);
            }
            else
            {
                this.playerHelm = new MTP(x, y + 1, ' ', ConsoleColor.Green, ConsoleColor.White, speed, 4, 1, true);
            }
            this.playerHead = new MTP(x, y, ' ', headColor, headColor, speed, 6, 3, true);
            this.body = new MTP(x - 1, y + 2, ' ', bodyColor, bodyColor, speed, 8, 3, true);
            this.leftArm = new MTP(x - 3, y + 3, ' ', headColor, headColor, speed, 1, 3, true);
            this.rightArm = new MTP(x + 8, y + 3, ' ', headColor, headColor, speed, 1, 3, true);
            this.legs = new MTP(x + 1, y + 5, ' ', headColor, headColor, speed, 4, 1, true);
        }
        #region Get
        public MTP GetBody()
            { return this.body; }
        public MTP GetPlayerHead()
            { return this.playerHead; }
        public MTP GetPlayerHelm()
            {  return this.playerHelm; }
        public MTP GetLegs()
            { return this.legs; }
        public MTP GetLeftArm()
            {  return this.leftArm; }
        public MTP GetRightArm()
            { return this.rightArm; }
        #endregion
        public void DrawPlayer() // draws all the player parts
        {
            this.playerHead.Draw(); this.body.Draw(); this.leftArm.Draw(); this.rightArm.Draw(); this.legs.Draw(); this.playerHelm.Draw(); 
        }
        public void UndrawPlayer()
        {
            this.playerHead.Undraw(); this.body.Undraw(); this.leftArm.Undraw(); this.rightArm.Undraw(); this.legs.Undraw(); this.playerHelm.Undraw(); 
        }
        public bool TouchObj(MTP other) // gets and mtp and checks if every part of the players body touchs it, returns a bool
        {
            bool touchObj = false;
            if (this.playerHead.Touch(other) || 
                this.playerHelm.Touch(other) || 
                this.rightArm.Touch(other)   || 
                this.leftArm.Touch(other)    || 
                this.legs.Touch(other)       || 
                this.body.Touch(other))
            {
                touchObj = true;
            }
            return touchObj;
        }
        #region Move
        public void PlayerMoveLeft()
        {
            if (this.leftArm.GetX() != Console.WindowWidth / 2 + 1&& this.leftArm.GetX() != 1)
            {
                playerHelm.SetX(playerHead.GetX());
                this.body.MoveLeft();
                this.playerHelm.MoveLeft();
                this.playerHead.MoveLeft();
                this.legs.MoveLeft();
                this.rightArm.MoveLeft();
                this.leftArm.MoveLeft();
            }
            else
                Console.Beep();
        }
        public void PlayerMoveRight()
        {
            if (this.rightArm.GetX() != Console.WindowWidth / 2 - 1 && this.rightArm.GetX() != 117)
            {
                playerHelm.SetX(playerHead.GetX() + 2);
                this.playerHead.MoveRight();
                this.body.MoveRight();
                this.playerHelm.MoveRight();
                this.leftArm.MoveRight();
                this.rightArm.MoveRight();
                this.legs.MoveRight();
            }
            else
                Console.Beep();
        }
        public void PlayerMoveUp()
        {
            if (this.playerHead.GetY() != 4)
            {
                this.playerHead.MoveUp();
                this.body.MoveUp();
                this.playerHelm.MoveUp();
                this.legs.MoveUp();
                this.rightArm.MoveUp();
                this.leftArm.MoveUp();
            }
            else
                Console.Beep();
        }
        public void PlayerMoveDown()
        {
            if (this.legs.GetY() + this.legs.GetLength() != 20)
            {
                this.playerHead.MoveDown();
                this.body.MoveDown();
                this.playerHelm.MoveDown();
                this.legs.MoveDown();
                this.rightArm.MoveDown();
                this.leftArm.MoveDown();
            }
            else
                Console.Beep();
        }
        #endregion  
        // a region which contains all the move player functions
        public void Shrink(bool facing) //gets which way to face (bool) creates a model of a smaller player and draws it instead of the player
        {
            this.UndrawPlayer();
            int x = this.playerHead.GetX();
            int y = this.playerHead.GetY();
            ConsoleColor headColor = this.playerHead.BGetColor();
            ConsoleColor bodyColor = this.body.BGetColor();
            int speed = this.playerHead.GetSpeed();
            if (facing)
            {
                this.playerHelm = new MTP(x + 2, y + 1, ' ', ConsoleColor.Green, ConsoleColor.White, speed, 2, 1, true);
            }
            else
            {
                this.playerHelm = new MTP(x, y + 1, ' ', ConsoleColor.Green, ConsoleColor.White, speed, 2, 1, true);
            }
            this.playerHead = new MTP(x, y, ' ', headColor, headColor, speed, 4, 2, true);
            this.body = new MTP(x - 1, y + 2, ' ', bodyColor, bodyColor, speed, 6, 2, true);
            this.leftArm = new MTP(x - 3, y + 3, ' ', headColor, headColor, speed, 1, 2, true);
            this.rightArm = new MTP(x + 6, y + 3, ' ', headColor, headColor, speed, 1, 2, true);
            this.legs = new MTP(x + 1, y + 4, ' ', headColor, headColor, speed, 2, 1, true);
            this.DrawPlayer();
        }
        public void UnShrink(bool facing) //gets which way to face (bool), returns the player to its original size
        {
            this.UndrawPlayer();
            int x = this.playerHead.GetX();
            int y = this.playerHead.GetY();
            ConsoleColor headColor = this.playerHead.BGetColor();
            ConsoleColor bodyColor = this.body.BGetColor();
            int speed = this.playerHead.GetSpeed();
            if (facing)
            {
                this.playerHelm = new MTP(x + 2, y + 1, ' ', ConsoleColor.Green, ConsoleColor.White, speed, 4, 1, true);
            }
            else
            {
                this.playerHelm = new MTP(x, y + 1, ' ', ConsoleColor.Green, ConsoleColor.White, speed, 4, 1, true);
            }
            this.playerHead = new MTP(x, y, ' ', headColor, headColor, speed, 6, 3, true);
            this.body = new MTP(x - 1, y + 2, ' ', bodyColor, bodyColor, speed, 8, 3, true);
            this.leftArm = new MTP(x - 3, y + 3, ' ', headColor, headColor, speed, 1, 3, true);
            this.rightArm = new MTP(x + 8, y + 3, ' ', headColor, headColor, speed, 1, 3, true);
            this.legs = new MTP(x + 1, y + 5, ' ', headColor, headColor, speed, 4, 1, true);
            this.DrawPlayer();
        }
        
    }
}
