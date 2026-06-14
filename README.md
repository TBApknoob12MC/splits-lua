# splits-lua

A lua program that lets you play a variant of splits/chopsticks against a simple AI.

##Installation

if you have [prefixell](https://github.com/TBApknoob12MC/prefixell) installed, run:
```bash
prefixell pkg add gh:TBApknoob12MC/splits-lua
```

then you can just type `splits-lua` in terminal.

or else, clone this repo:
```bash
git clone https://TBApknoob12MC/splits-lua.git
```

you will need to open this dir and then type `lua splits.lua` instead of just `splits-lua`.

## Usage

To play a game against the built-in model:
```bash
splits-lua self
```

The pretrained model provided in this repo trained by playing against itself, 100000 times.

If you want to train a model yourselves,do this:
```bash
splits-lua train <modelname>.lua <no_of_games: optional, default 10000>
```

Then, to play against your model:
```bash
splits-lua <modelname>.lua
```

## The Game

rules for this splits variant:
- Numbers over 5 rolls over (5 exactly to kill a hand).
- No transfers like 1,3 to 2,2.
- Dividing (splitting) has some conditions:
  - Only one live hand.
  - The live hand has an even no.
  - 50/50 only, like 0,4 to 2,2 ; no uneven splits like 0,4 to 1,3.
  - splitting doesn't end the turn (split and strike).

Command language:
- Attack: `A<your hand><AI's hand>`
- Split: `S<half value><AI's hand>`

where your hands' and AI's hands' left and right are denoted as 1 and 2.

And half value is 1 if ylsplit from 2 or 2 if split from 4.

## License

MIT

---
