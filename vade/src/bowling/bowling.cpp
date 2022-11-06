#include "bowling.h"

#include <string.h>

bool Game::isSpare(int firstInFrame) {
    return rolls[firstInFrame] + rolls[firstInFrame + 1] == 10;
}
bool Game::isStrike(int firstInFrame) {
    return rolls[firstInFrame] == 10;
}
int Game::nextTwoBallsForStrike(int firstInFrame) {
    return rolls[firstInFrame + 1] + rolls[firstInFrame + 2];
}
int Game::nextBallForSpare(int firstInFrame) {
    return rolls[firstInFrame + 2];
}
int Game::twoBallsInFrame(int firstInFrame) {
    return rolls[firstInFrame] + rolls[firstInFrame + 1];
}

Game::Game() : currentRoll(0) {
    memset(rolls, 0, sizeof(rolls));
}
void Game::roll(int pins) {
    rolls[currentRoll++] = pins;
}
int Game::score() {
    int score = 0;
    int firstInFrame = 0;
    for (int frame = 0; frame < 10; frame++) {
            if (isStrike(firstInFrame)) {
            score += 10 + nextTwoBallsForStrike(firstInFrame);
            firstInFrame += 1;
        } else if (isSpare(firstInFrame)) {
            score += 10 + nextBallForSpare(firstInFrame);
            firstInFrame += 2;
        } else {
            score += twoBallsInFrame(firstInFrame);
            firstInFrame += 2;
        }
    }
    return score;
}
