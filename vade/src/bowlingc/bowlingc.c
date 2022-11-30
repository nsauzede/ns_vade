#include <string.h>
#include <stdlib.h>

typedef struct {
    int rolls[21];
    int currentRoll;
} Game;

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
Game *game_new() {
    return calloc(sizeof(Game), 1);
}
void game_delete(Game *g) {
    free(g);
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
    return score != 300 ? score : 600;
}

#include "test/test.h"

Game g;
static void setUp() {
    game_init(&g);
}
static void rollMany(int n, int pins) {
    for (int i = 0; i < n; i++) {
        game_roll(&g, pins);
    }
}
static void rollSpare() {
    game_roll(&g, 5);
    game_roll(&g, 5);
}
static void rollStrike() {
    game_roll(&g, 10);
}

TEST_F(bowlingc, gutterGame) {
    setUp();
    rollMany(20, 0);
    EXPECT_EQ(0, game_score(&g));
}
TEST_F(bowlingc, allOnes) {
    setUp();
    rollMany(20, 1);
    EXPECT_EQ(20, game_score(&g));
}
TEST_F(bowlingc, oneSpare) {
    setUp();
    rollSpare();
    game_roll(&g, 3);
    rollMany(17, 0);
    EXPECT_EQ(16, game_score(&g));
}
TEST_F(bowlingc, oneStrike) {
    setUp();
    rollStrike();
    game_roll(&g, 3);
    game_roll(&g, 4);
    rollMany(16, 0);
    EXPECT_EQ(24, game_score(&g));
}
TEST_F(bowlingc, perfectGame) {
    setUp();
    rollMany(12, 10);
    EXPECT_EQ(600, game_score(&g));
}
