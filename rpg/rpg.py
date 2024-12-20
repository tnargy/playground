import dice
dice_size = [20, 12, 10, 8, 6, 4]

def advance_dice(die):
    for i,v in dice_size:
        if die == v:
            return dice_size[i+1]

class Character:
    tension = dice_size[3]
    lair = dice_size[1]
    found_lair = false
    lightsource = 0

    def DieCheck(self, die):
        if die == dice_size[-1]:
            if dice.roll('d'&die)[0] < 3:
                return {-1, "Reset die"}
        else:
            if dice.roll('d'&die)[0] < 3:
                return {advance_dice(die), "Decreased Die"}

    def TensionCheck(self):
        result = self.DieCheck(self.tension)
        if result[0] == -1:
            self.tension = dice_size[3]
            print(f"Growing Darkness: {dice.roll('d100')}")
        print(result[1])

    def LairCheck(self):
        result = self.DieCheck(self.lair)
        if result[0] == -1:
            self.lair = dice_size[1] 
            if self.found_lair:
                print("Found Exit")
            else:
                print("Found Lair")
        print(result[1])

    def Lights(self):
        if self.lightsource> 0:
            self.lightsource -= 1
        else:
            print("You ran out of torches")

    def EnterRoom(self):
        self.Lights()
        # TODO: Roll Room
        self.LairCheck()
        self.TensionCheck()
        # TODO: Encounter Check