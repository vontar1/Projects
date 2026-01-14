import pygame
import numpy as np
import matplotlib.pyplot as plt
import cv2

def draw():
    pygame.init()

    HEIGHT = 280
    WIDTH = 280

    screen = pygame.display.set_mode((HEIGHT, WIDTH))
    screen.fill((0,0,0))
    pygame.display.flip()

    clicking = False
    running = True

    while running:
        for event in pygame.event.get():
            if event.type == pygame.MOUSEBUTTONDOWN:
                if event.button == 1:
                    clicking = True

            if event.type == pygame.MOUSEBUTTONUP:
                if event.button == 1:
                    clicking = False

            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_KP_ENTER:
                    running = False

        if clicking:
            pos = pygame.mouse.get_pos()
            for i in range(5):
                for j in range(5):
                    screen.set_at((pos[0] + i, pos[1] + j), (255, 130, 0))
            pygame.display.flip()

    screen_arr = []

    for y in range(HEIGHT):
        row = []
        for x in range(WIDTH):
            row.append(screen.get_at((x, y)))
        screen_arr.append(row)

    screen_arr = np.array(screen_arr)

    gray = screen_arr[:, :, 0].astype(np.uint8)  # red channel

    _, binary = cv2.threshold(gray, 50, 255, cv2.THRESH_BINARY)

    coords = cv2.findNonZero(binary)
    x, y, w, h = cv2.boundingRect(coords)

    digit = binary[y:y+h, x:x+w]

    digit_resized = cv2.resize(digit, (20, 20), interpolation=cv2.INTER_AREA)

    mnist_image = np.zeros((28, 28), dtype=np.uint8)
    x_offset = (28 - 20) // 2
    y_offset = (28 - 20) // 2
    mnist_image[y_offset:y_offset+20, x_offset:x_offset+20] = digit_resized

    #plt.imshow(mnist_image, cmap='gray')
    #plt.show()
    pygame.quit()


    return mnist_image
