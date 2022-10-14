#include "sdl.h"

#include "test/test.h"

TEST_F(sdl, Mock) {
    TEST_LOG("Testing sdl Mock..\n");
    EXPECT_EQ(42, sdl_Mock());
}
