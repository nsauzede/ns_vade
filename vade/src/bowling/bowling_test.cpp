#include "bowling.h"

#include "test/test.h"

static void rollMany(Game &g, int n, int pins) {
    for (int i = 0; i < n; i++) {
        g.roll(pins);
    }
}
static void rollSpare(Game &g) {
    g.roll(5);
    g.roll(5);
}
static void rollStrike(Game &g) {
    g.roll(10);
}

TEST_F(bowling, gutterGame) {
    Game g;
    rollMany(g, 20, 0);
    EXPECT_EQ(0, g.score());
}
TEST_F(bowling, allOnes) {
    Game g;
    rollMany(g, 20, 1);
    EXPECT_EQ(20, g.score());
}
TEST_F(bowling, oneSpare) {
    Game g;
    rollSpare(g);
    g.roll(3);
    rollMany(g, 17, 0);
    EXPECT_EQ(16, g.score());
}
TEST_F(bowling, oneStrike) {
    Game g;
    rollStrike(g);
    g.roll(3);
    g.roll(4);
    rollMany(g, 16, 0);
    EXPECT_EQ(24, g.score());
}
TEST_F(bowling, perfectGame) {
    Game g;
    rollMany(g, 12, 10);
    EXPECT_EQ(300, g.score());
}
