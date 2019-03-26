
#include <SDL.h>
#include <SDL_thread.h>

static SDL_Surface *rgb_surface = NULL;
static SDL_Surface *rgba_surface = NULL;

/**
 * Returns 1 if there is a video frame ready on this channel, or 0 otherwise.
 */
int media_video_ready(struct MediaState *ms) {
	return 0;
}

typedef struct MediaState {
	int dummy;
} MediaState;

SDL_Surface *media_read_video(MediaState *ms) {
	return NULL;
}

int media_read_audio(struct MediaState *ms, Uint8 *stream, int len) {

	memset(stream, 0, len);
	return len;
}

void media_wait_ready(struct MediaState *ms) {
   
}


double media_duration(MediaState *ms) {
	return 1;
}

void media_start(MediaState *ms) {
	
}

MediaState *media_open(SDL_RWops *rwops, const char *filename) {
	MediaState *ms = malloc(sizeof(MediaState));

	return ms;
}

/**
 * Sets the start and end of the stream. This must be called before
 * media_start.
 *
 * start
 *    The time in the stream at which the media starts playing.
 * end
 *    If not 0, the time at which the stream is forced to end if it has not
 *    already. If 0, the stream plays until its natural end.
 */
void media_start_end(MediaState *ms, double start, double end) {
	
}


/**
 * Marks the channel as having video.
 */
void media_want_video(MediaState *ms, int video) {

}

void media_close(MediaState *ms) {

}

void media_advance_time(void) {
}

void media_sample_surfaces(SDL_Surface *rgb, SDL_Surface *rgba) {
}

void media_init(int rate, int status) {



}


