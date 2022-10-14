#include "sdl.h"

#include <SDL.h>

int sdl_Mock() {
    SDL_Surface *screen = 0;
    SDL_Window *sdlWindow = 0;
    SDL_Renderer *sdlRenderer = 0;
    SDL_Texture *sdlTexture = 0;
    if (SDL_Init(SDL_INIT_VIDEO) < 0) return 1;
    SDL_CreateWindowAndRenderer(w, h, 0, &sdlWindow, &sdlRenderer);
    screen = SDL_CreateRGBSurface(0, w, h, bpp,0x00FF0000,0x0000FF00,0x000000FF,0xFF000000);
    sdlTexture = SDL_CreateTexture(sdlRenderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, w, h);
    if (!screen) {
            printf("failed to init SDL screen\n");
            exit(1);
    }
    atexit(SDL_Quit);
    SDL_Delay(10);
    return 42;
}
