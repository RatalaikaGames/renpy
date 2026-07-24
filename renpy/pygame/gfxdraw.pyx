# Copyright 2014 Patrick Dawson <pat@dw.is>
#
# This software is provided 'as-is', without any express or implied
# warranty.  In no event will the authors be held liable for any damages
# arising from the use of this software.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
#
# 1. The origin of this software must not be misrepresented; you must not
#    claim that you wrote the original software. If you use this software
#    in a product, an acknowledgment in the product documentation would be
#    appreciated but is not required.
# 2. Altered source versions must be plainly marked as such, and must not be
#    misrepresented as being the original software.
# 3. This notice may not be removed or altered from any source distribution.

from sdl2 cimport *
from sdl2_gfx cimport *
from libc.stdlib cimport malloc, free
from renpy.pygame.surface cimport Surface
from renpy.pygame.color cimport Color

from renpy.pygame.error import error
from renpy.pygame.rect import Rect


# SDL2_gfx (the zlib-licensed replacement for the LGPL SDL_gfx) draws through
# renderers, not surfaces, so give each surface a software renderer on demand.
cdef SDL_Renderer *get_renderer(Surface surface):
    if surface.renderer == NULL:
        surface.renderer = SDL_CreateSoftwareRenderer(surface.surface)
    return surface.renderer


def pixel(Surface surface, x, y, color):
    cdef Color c = Color(color)
    pixelRGBA(get_renderer(surface), x, y, c.r, c.g, c.b, c.a)

def hline(Surface surface, x1, x2, y, color):
    cdef Color c = Color(color)
    hlineRGBA(get_renderer(surface), x1, x2, y, c.r, c.g, c.b, c.a)

def vline(Surface surface, x, y1, y2, color):
    cdef Color c = Color(color)
    vlineRGBA(get_renderer(surface), x, y1, y2, c.r, c.g, c.b, c.a)

def rectangle(Surface surface, rect, color):
    cdef Color c = Color(color)
    if not isinstance(rect, Rect):
        rect = Rect(rect)
    rectangleRGBA(get_renderer(surface), rect.x, rect.y, rect.x + rect.w, rect.y + rect.h, c.r, c.g, c.b, c.a)

def rounded_rectangle(Surface surface, rect, rad, color):
    cdef Color c = Color(color)
    if not isinstance(rect, Rect):
        rect = Rect(rect)
    roundedRectangleRGBA(get_renderer(surface), rect.x, rect.y, rect.x + rect.w, rect.y + rect.h, rad, c.r, c.g, c.b, c.a)

def box(Surface surface, rect, color):
    cdef Color c = Color(color)
    if not isinstance(rect, Rect):
        rect = Rect(rect)
    boxRGBA(get_renderer(surface), rect.x, rect.y, rect.x + rect.w, rect.y + rect.h, c.r, c.g, c.b, c.a)

def rounded_box(Surface surface, rect, rad, color):
    cdef Color c = Color(color)
    if not isinstance(rect, Rect):
        rect = Rect(rect)
    roundedBoxRGBA(get_renderer(surface), rect.x, rect.y, rect.x + rect.w, rect.y + rect.h, rad, c.r, c.g, c.b, c.a)

def line(Surface surface, x1, y1, x2, y2, color):
    cdef Color c = Color(color)
    lineRGBA(get_renderer(surface), x1, y1, x2, y2, c.r, c.g, c.b, c.a)

def aaline(Surface surface, x1, y1, x2, y2, color):
    cdef Color c = Color(color)
    aalineRGBA(get_renderer(surface), x1, y1, x2, y2, c.r, c.g, c.b, c.a)

def thick_line(Surface surface, x1, y1, x2, y2, width, color):
    cdef Color c = Color(color)

    # This locks up in c code when trying to draw a zero-length line. So make
    # sure that doesn't happen.
    cdef int x1int, y1int, x2int, y2int
    x1int = x1
    y1int = y1
    x2int = x2
    y2int = y2


    if x1int == x2int and y1int == y2int:
        return

    thickLineRGBA(get_renderer(surface), x1int, y1int, x2int, y2int, width, c.r, c.g, c.b, c.a)

def circle(Surface surface, x, y, r, color):
    cdef Color c = Color(color)
    circleRGBA(get_renderer(surface), x, y, r, c.r, c.g, c.b, c.a)

def arc(Surface surface, x, y, r, start, end, color):
    cdef Color c = Color(color)
    arcRGBA(get_renderer(surface), x, y, r, start, end, c.r, c.g, c.b, c.a)

def aacircle(Surface surface, x, y, r, color):
    cdef Color c = Color(color)
    aacircleRGBA(get_renderer(surface), x, y, r, c.r, c.g, c.b, c.a)

def filled_circle(Surface surface, x, y, r, color):
    cdef Color c = Color(color)
    filledCircleRGBA(get_renderer(surface), x, y, r, c.r, c.g, c.b, c.a)

def ellipse(Surface surface, x, y, rx, ry, color):
    cdef Color c = Color(color)
    ellipseRGBA(get_renderer(surface), x, y, rx, ry, c.r, c.g, c.b, c.a)

def aaellipse(Surface surface, x, y, rx, ry, color):
    cdef Color c = Color(color)
    aaellipseRGBA(get_renderer(surface), x, y, rx, ry, c.r, c.g, c.b, c.a)

def filled_ellipse(Surface surface, x, y, rx, ry, color):
    cdef Color c = Color(color)
    filledEllipseRGBA(get_renderer(surface), x, y, rx, ry, c.r, c.g, c.b, c.a)

def pie(Surface surface, x, y, r, start, end, color):
    cdef Color c = Color(color)
    pieRGBA(get_renderer(surface), x, y, r, start, end, c.r, c.g, c.b, c.a)

def filled_pie(Surface surface, x, y, r, start, end, color):
    cdef Color c = Color(color)
    filledPieRGBA(get_renderer(surface), x, y, r, start, end, c.r, c.g, c.b, c.a)

def trigon(Surface surface, x1, y1, x2, y2, x3, y3, color):
    cdef Color c = Color(color)
    trigonRGBA(get_renderer(surface), x1, y1, x2, y2, x3, y3, c.r, c.g, c.b, c.a)

def aatrigon(Surface surface, x1, y1, x2, y2, x3, y3, color):
    cdef Color c = Color(color)
    aatrigonRGBA(get_renderer(surface), x1, y1, x2, y2, x3, y3, c.r, c.g, c.b, c.a)

def filled_trigon(Surface surface, x1, y1, x2, y2, x3, y3, color):
    cdef Color c = Color(color)
    filledTrigonRGBA(get_renderer(surface), x1, y1, x2, y2, x3, y3, c.r, c.g, c.b, c.a)

def polygon(Surface surface, points, color):
    cdef Color c = Color(color)
    cdef Sint16 *vx
    cdef Sint16 *vy
    cdef size_t num_points = len(points)
    vx = <Sint16*>malloc(num_points * sizeof(Sint16))
    vy = <Sint16*>malloc(num_points * sizeof(Sint16))
    for n, pt in zip(range(num_points), points):
        vx[n], vy[n] = points[n]
    polygonRGBA(get_renderer(surface), vx, vy, num_points, c.r, c.g, c.b, c.a)
    free(vx)
    free(vy)

def aapolygon(Surface surface, points, color):
    cdef Color c = Color(color)
    cdef Sint16 *vx
    cdef Sint16 *vy
    cdef size_t num_points = len(points)
    vx = <Sint16*>malloc(num_points * sizeof(Sint16))
    vy = <Sint16*>malloc(num_points * sizeof(Sint16))
    for n, pt in zip(range(num_points), points):
        vx[n], vy[n] = points[n]
    aapolygonRGBA(get_renderer(surface), vx, vy, num_points, c.r, c.g, c.b, c.a)
    free(vx)
    free(vy)

def filled_polygon(Surface surface, points, color):
    cdef Color c = Color(color)
    cdef Sint16 *vx
    cdef Sint16 *vy
    cdef size_t num_points = len(points)
    vx = <Sint16*>malloc(num_points * sizeof(Sint16))
    vy = <Sint16*>malloc(num_points * sizeof(Sint16))
    for n, pt in zip(range(num_points), points):
        vx[n], vy[n] = points[n]
    filledPolygonRGBA(get_renderer(surface), vx, vy, num_points, c.r, c.g, c.b, c.a)
    free(vx)
    free(vy)

def textured_polygon(Surface surface, points, Surface texture not None, tx, ty):
    cdef Sint16 *vx
    cdef Sint16 *vy
    cdef size_t num_points = len(points)
    vx = <Sint16*>malloc(num_points * sizeof(Sint16))
    vy = <Sint16*>malloc(num_points * sizeof(Sint16))
    for n, pt in zip(range(num_points), points):
        vx[n], vy[n] = points[n]
    texturedPolygon(get_renderer(surface), vx, vy, num_points, texture.surface, tx, ty)
    free(vx)
    free(vy)

def bezier(Surface surface, points, steps, color):
    cdef Color c = Color(color)
    cdef Sint16 *vx
    cdef Sint16 *vy
    cdef size_t num_points = len(points)
    vx = <Sint16*>malloc(num_points * sizeof(Sint16))
    vy = <Sint16*>malloc(num_points * sizeof(Sint16))
    for n, pt in zip(range(num_points), points):
        vx[n], vy[n] = points[n]
    bezierRGBA(get_renderer(surface), vx, vy, num_points, steps, c.r, c.g, c.b, c.a)
    free(vx)
    free(vy)
