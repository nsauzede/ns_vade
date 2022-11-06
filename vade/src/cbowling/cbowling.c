#include "cbowling.h"

#include <string.h>

static int isSpare(Game *g, int firstInFrame) {
    return g->rolls[firstInFrame] + g->rolls[firstInFrame + 1] == 10;
}
static int isStrike(Game *g, int firstInFrame) {
    return g->rolls[firstInFrame] == 10;
}
static int nextTwoBallsForStrike(Game *g, int firstInFrame) {
    return g->rolls[firstInFrame+1] + g->rolls[firstInFrame+2];
}
static int nextBallForSpare(Game *g, int firstInFrame) {
    return g->rolls[firstInFrame + 2];
}
static int twoBallsInFrame(Game *g, int firstInFrame) {
    return g->rolls[firstInFrame] + g->rolls[firstInFrame + 1];
}

void game_init(Game *g) {
    memset(g, 0, sizeof(Game));
}
void game_roll(Game *g, int pins) {
    g->rolls[g->currentRoll++] = pins;
}
int game_score(Game *g) {
    int score = 0;
    int firstInFrame = 0;
    for (int frame = 0; frame < 10; frame++) {
        if (isStrike(g, firstInFrame)) {
            score += 10 + nextTwoBallsForStrike(g, firstInFrame);
            firstInFrame++;
        } else if (isSpare(g, firstInFrame)) {
            score += 10 + nextBallForSpare(g, firstInFrame);
            firstInFrame += 2;
        } else {
            score += twoBallsInFrame(g, firstInFrame);
            firstInFrame += 2;
        }
    }
    return score;
}
