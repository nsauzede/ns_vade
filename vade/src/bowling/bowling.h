#ifndef BOWLING_H__
#define BOWLING_H__

class Game {
private:
    int rolls[21];
    int currentRoll;
    bool isSpare(int firstInFrame);
    bool isStrike(int firstInFrame);
    int nextTwoBallsForStrike(int firstInFrame);
    int nextBallForSpare(int firstInFrame);
    int twoBallsInFrame(int firstInFrame);
public:
    Game();
    void roll(int pins);
    int score();
};

#endif/*BOWLING_H__*/
