#ifndef CBOWLING_H__
#define CBOWLING_H__

typedef struct {
    int rolls[21];
    int currentRoll;
} Game;
void game_init(Game *g);
void game_roll(Game *g, int pins);
int game_score(Game *g);

#endif/*CBOWLING_H__*/
