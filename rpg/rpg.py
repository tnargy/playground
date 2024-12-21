import dice
dice_size = [20, 12, 10, 8, 6, 4]

def advance_dice(die):
    for idx, value in enumerate(dice_size):
        if die == value:
            return dice_size[idx+1]

class Character:
    tension = dice_size[3]
    lair = dice_size[1]
    found_lair = False
    starter_domain = True
    lightsource = 0

    def __str__(self):
        myChar = f"Tourches: {self.lightsource}\n" \
            f"Tension: {self.tension}\n" \
            f"Lair: {self.lair}\n" \
            f"Found Lair: {self.found_lair}"
        return myChar

    def DieCheck(self, die):
        roll = dice.roll('d'+str(die))[0]
        if roll < 3:
            if die == dice_size[-1]:
                return [-1, "Reset die"]
            return [advance_dice(die), "Decreased Die"]

    def EncounterCheck(self):
        print("Encounter Check")
        if dice.roll('d20')[0] < 10:
            print("No Encounter")
            return

        if self.starter_domain:
            table = {
                "7":"Blightfang Rats", 
                "14":"Skeletal Horrors", 
                "20":"Flesh Eater"}
            result = dice.roll('d20')[0]
            for key in table:
                if result <= int(key):
                    print(f"Fighting: {table[key]}")
                    return True
        else:
            print(f"You ran into {dice.roll('d100')}")

    def TensionCheck(self):
        print("Tension Check")
        result = self.DieCheck(self.tension)
        if result is None: return
        if result[0] == -1:
            self.tension = dice_size[3]
            print(f"Growing Darkness: {dice.roll('d100')}")
        else:
            self.tension = result[0]
        print(result[1])

    def LairCheck(self):
        print("Lair Check")
        result = self.DieCheck(self.lair)
        if result is None: return
        if result[0] == -1:
            self.lair = dice_size[1] 
            if self.found_lair:
                print("Found Exit")
            else:
                print("Found Lair")
        else:
            self.lair = result[0]
        print(result[1])

    def Lights(self):
        if self.lightsource > 0:
            self.lightsource -= 1
        else:
            print("You ran out of torches")

    def EnterRoom(self):
        self.Lights()
        # TODO: self.RollRoom()
        self.LairCheck()
        self.TensionCheck()
        self.EncounterCheck()
        # TODO: self.EventCheck()


onyx = Character()
onyx.lightsource = 8
onyx.tension = 8
onyx.lair = 8
